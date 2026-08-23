import AppKit
import SwiftUI

/// Monitors keyboard events and runs the appropriate actions.
@MainActor
final class KeyMonitor {
	private var eventMonitor: Any?

	var delegate: KeyMonitorDelegate

	init(delegate: KeyMonitorDelegate) {
		self.delegate = delegate
	}

	func start() {
		eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
			guard let self, NSApp.isActive else { return event }

			if self.handleKeyEvent(event) {
				return nil // consumed
			}
			return event
		}
	}

	func stop() {
		if let eventMonitor {
			NSEvent.removeMonitor(eventMonitor)
		}
	}

	/// Maps a key-down `NSEvent` to the SwiftUI `KeyEquivalent`/`EventModifiers`
	/// pair the bindings are configured with, dispatches the matching action
	/// (if any), and returns whether the event was consumed.
	private func handleKeyEvent(_ event: NSEvent) -> Bool {
		guard let key = keyEquivalent(for: event) else { return false }
		let modifiers = modifiers(for: event)

		if let action = Config.bindings.first(where: { $0.key == key && $0.modifiers == modifiers })?.action {
			switch action {
			case .confirm:
				delegate.confirm()
				return true
			case .confirmInput:
				delegate.confirmInput()
				return true
			case .quit:
				delegate.quit()
				return true
			case .complete:
				delegate.complete()
				return true
			case .forward:
				delegate.forward()
				return true
			case .backward:
				delegate.backward()
				return true
			}
		}

		return false
	}

	private func keyEquivalent(for event: NSEvent) -> KeyEquivalent? {
		// Special keys by hardware keyCode — these don't reliably come through
		// `charactersIgnoringModifiers` as their KeyEquivalent character.
		switch event.keyCode {
		case 36: return .return
		case 48: return .tab
		case 49: return .space
		case 51: return .delete
		case 53: return .escape
		case 123: return .leftArrow
		case 124: return .rightArrow
		case 125: return .downArrow
		case 126: return .upArrow
		default: break
		}

		// Printable characters. `charactersIgnoringModifiers` already applies
		// Shift, so it returns the shifted character ("P", "|", "_", ...).
		guard let chars = event.charactersIgnoringModifiers, let first = chars.first else {
			return nil
		}

		let flags = event.modifierFlags
		let hasOtherModifiers = flags.contains(.command)
			|| flags.contains(.control)
			|| flags.contains(.option)

		// When Shift is the only active modifier, fold it into the key itself so
		// bindings can target capitalized letters and second-layer symbols
		// directly (e.g. `.init("P", ...)` or `.init("|", ...)`). When Shift
		// accompanies another modifier, keep the lowercase form so combos like
		// Cmd-Shift-P still bind via `.command` + `.shift`.
		if flags.contains(.shift) && !hasOtherModifiers {
			return KeyEquivalent(first)
		}
		return KeyEquivalent(first.lowercased().first ?? first)
	}

	private func modifiers(for event: NSEvent) -> EventModifiers {
		var m: EventModifiers = []
		let flags = event.modifierFlags
		let hasOtherModifiers = flags.contains(.command)
			|| flags.contains(.control)
			|| flags.contains(.option)
		if flags.contains(.command) { m.insert(.command) }
		if flags.contains(.control) { m.insert(.control) }
		if flags.contains(.option) { m.insert(.option) }
		// Shift is only treated as a modifier when combined with another one;
		// on its own it's folded into the key's character (uppercase letter or
		// second-layer symbol), see `keyEquivalent(for:)`.
		if flags.contains(.shift) && hasOtherModifiers { m.insert(.shift) }
		if flags.contains(.capsLock) { m.insert(.capsLock) }
		return m
	}
}
