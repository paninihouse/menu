import AppKit

final class MenuWindow: NSPanel {
	private let targetScreen: NSScreen
	private let position: Config.Position

	init(contentRect: NSRect, screen: NSScreen, position: Config.Position) {
		self.targetScreen = screen
		self.position = position
		super.init(
			contentRect: contentRect,
			styleMask: [.borderless],
			backing: .buffered,
			defer: false
		)

		animationBehavior = .none
		backgroundColor = .clear
		becomesKeyOnlyIfNeeded = true
		collectionBehavior = [
			.canJoinAllSpaces,
			.fullScreenAuxiliary,
			.fullScreenNone,
			.stationary,
		]
		hasShadow = false
		hidesOnDeactivate = false
		isFloatingPanel = true
		isMovable = false
		isOpaque = false
		isReleasedWhenClosed = false
		level = .floating

		// The window is its own delegate: it re-anchors itself to its screen
		// edge on every resize (see ``windowDidResize(_:)``).
		self.delegate = self
	}

	override var canBecomeMain: Bool { true }
	override var canBecomeKey: Bool { true }
}

extension MenuWindow: NSWindowDelegate {
	/// Re-anchors the window to its screen edge whenever it is resized.
	/// `NSHostingView` grows the window from its top-left corner to fit the
	/// SwiftUI content, which would move the bottom (or top) edge off screen;
	/// this snaps it back. It only moves the origin (never the height), so it
	/// can't loop.
	func windowDidResize(_ notification: Notification) {
		guard let window = notification.object as? NSWindow, window === self else { return }
		let frame = window.frame
		let y: CGFloat = position == .top ? targetScreen.frame.maxY - frame.height : targetScreen.frame.minY
		window.setFrameOrigin(NSPoint(x: frame.origin.x, y: y))
	}
}
