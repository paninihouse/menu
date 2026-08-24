import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, KeyMonitorDelegate {
	private var screen: NSScreen
	private var position: Menu.Position
	var state: MenuState
	var keyMonitor: KeyMonitor!
	private var window: MenuWindow!

	init(screen: NSScreen, menu: Menu) {
		self.screen = screen
		self.position = menu.position
		self.state = MenuState(prompt: menu.prompt, counter: menu.counter, lines: menu.lines)

		super.init()
	}

	func applicationDidFinishLaunching(_ notification: Notification) {
		// Create the keyboard events monitor.
		self.keyMonitor = KeyMonitor(delegate: self)

		// Configure and present the window.
		let height = Self.menuHeight(choices: state.choices.count, lines: state.lines)
		let frame = Screen.frame(screen, position: position, height: height)
		let window = MenuWindow(contentRect: frame)
		window.delegate = self
		window.contentView = NSHostingView(rootView: MenuView(state: self.state, position: position))
		window.makeKeyAndOrderFront(nil)
		self.window = window

		// Force the app to the foreground. `NSApp.activate()` (macOS 14+) only
		// activates "when appropriate" — which a background/subprocess launch
		// is *not*, so the app stays inactive, never resigns active, and the
		// dismiss-on-focus-loss never fires. The deprecated forcing variant
		// reliably brings the accessory app forward so didResignActive works.
		// NSApp.activate(ignoringOtherApps: true)
		NSApp.activate(ignoringOtherApps: true)

		// Start monitoring keyboard events.
		keyMonitor.start()

		// Quit right away if menu loses focus.
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(quit),
			name: NSWindow.didResignKeyNotification,
			object: window
		)
	}

	func applicationWillTerminate(_ notification: Notification) {
		// Stop monitoring keyboard events.
		keyMonitor.stop()

		// Stop monitoring menu losing focus.
		NotificationCenter.default.removeObserver(
			self,
			name: NSWindow.didResignKeyNotification,
			object: window
		)
	}

	// MARK: - NSWindowDelegate

	/// Re-anchors the window to its screen edge whenever it is resized.
	/// `NSHostingView` grows the window from its top-left corner to fit the
	/// SwiftUI content, which would move the bottom (or top) edge off screen;
	/// this snaps it back. It only moves the origin (never the height), so it
	/// can't loop.
	func windowDidResize(_ notification: Notification) {
		guard let window = notification.object as? NSWindow, window === self.window else { return }
		let frame = window.frame
		let y: CGFloat = position == .top ? screen.frame.maxY - frame.height : screen.frame.minY
		window.setFrameOrigin(NSPoint(x: frame.origin.x, y: y))
	}

	// MARK: - Window sizing

	/// Computes the menu height for a given number of choices: a single line
	/// for the inline style, or the input line plus one row per visible line
	/// (up to `lines`) for the vertical style. When there are no choices, only
	/// the input line is shown.
	private static func menuHeight(choices: Int, lines: Int?) -> CGFloat {
		if let lines, lines > 0 {
			let visible = choices > 0 ? min(lines, choices) : 0
			return Config.height * CGFloat(visible + 1)
		}
		return Config.height
	}
}
