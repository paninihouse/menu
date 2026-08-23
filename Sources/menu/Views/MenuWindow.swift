import AppKit

final class MenuWindow: NSPanel {
	init(contentRect: NSRect) {
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
	}

	override var canBecomeMain: Bool { true }
	override var canBecomeKey: Bool { true }
}
