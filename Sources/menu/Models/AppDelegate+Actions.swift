import AppKit

extension AppDelegate {
	func confirm() {
		if let result = state.result {
			writeln(result, to: .standardOutput)
		}
		stopApp()
	}

	func confirmInput() {
		writeln(state.input, to: .standardOutput)
		stopApp()
	}

	@objc func quit() {
		stopApp()
	}

	func complete() {
		if let text = state.result { state.input = text }
	}

	func forward() {
		guard state.selection < state.choices.count - 1 else { return }
		state.selection += 1
	}

	func backward() {
		guard state.selection > 0 else { return }
		state.selection -= 1
	}

	private func stopApp() {
		NSApp.stop(nil)
		let event = NSEvent.otherEvent(
			with: .applicationDefined,
			location: .zero,
			modifierFlags: [],
			timestamp: 0,
			windowNumber: 0,
			context: nil,
			subtype: 0,
			data1: 0,
			data2: 0
		)
		NSApp.postEvent(event!, atStart: true)
	}
}
