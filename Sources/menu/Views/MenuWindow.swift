import AppKit

final class MenuWindow: NSPanel {
	private let targetScreen: NSScreen
	private let position: Config.Position
	private let spotlight: Bool
	private let width: CGFloat?

	init(
		contentRect: NSRect,
		screen: NSScreen,
		position: Config.Position,
		spotlight: Bool,
		width: CGFloat?
	) {
		self.targetScreen = screen
		self.position = position
		self.spotlight = spotlight
		self.width = width
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
	///
	/// The horizontal origin mirrors ``Screen/frame(_:position:spotlight:width:height:)``:
	/// centered on screen when spotlight is on (using the configured width),
	/// flush to the left edge otherwise.
	///
	/// In spotlight mode the top edge is preserved across resizes by reading
	/// the previous frame's top edge (`frame.maxY`) and deriving the new origin
	/// from it. Because only the origin is ever moved (never the height), the
	/// height reported here is already the post-resize one, so `maxY - height`
	/// keeps the top edge fixed as the list grows and shrinks.
	func windowDidResize(_ notification: Notification) {
		guard let window = notification.object as? NSWindow, window === self else { return }
		let frame = window.frame

		let x: CGFloat = spotlight
			? targetScreen.frame.midX - (width ?? frame.width) / 2
			: targetScreen.frame.minX

		let y: CGFloat
		if spotlight {
			y = frame.maxY - frame.height
		} else {
			y = position == .top ? targetScreen.frame.maxY - frame.height : targetScreen.frame.minY
		}

		window.setFrameOrigin(NSPoint(x: x, y: y))
	}
}
