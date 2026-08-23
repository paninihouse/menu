import AppKit

@MainActor
protocol KeyMonitorDelegate {
	var state: MenuState { get }

	func confirm() -> Void
	func confirmInput() -> Void
	func quit() -> Void
	func complete() -> Void
	func forward() -> Void
	func backward() -> Void
}
