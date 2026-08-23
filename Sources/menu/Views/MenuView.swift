import SwiftUI

struct MenuView: View {
	@StateObject var state: MenuState

	var body: some View {
		HStack(spacing: 0) {
			InputView()
			ListView()
		}
		.font(Config.font)
		.foregroundStyle(Config.foreground)
		.frame(width: .infinity, height: Config.height)
		.background(Config.background)
		.environmentObject(state)
		.onKeyPress { keyPress in
			let key = keyPress.key
			let modifiers = keyPress.modifiers
			let action = Config.bindings.first { $0.key == key && $0.modifiers == modifiers }?.action

			switch action {
			case .confirm:
				NotificationCenter.default.post(name: .stop, object: state.result)
				return .handled
			case .confirmInput:
				NotificationCenter.default.post(name: .stop, object: state.input)
				return .handled
			case .quit:
				NotificationCenter.default.post(name: .stop, object: nil)
				return .handled
			case .complete:
				if let text = state.result { state.input = text }
				return .handled
			case .next:
				state.next()
				return .handled
			case .previous:
				state.previous()
				return .handled
			case nil:
				return .ignored
			}
		}
	}
}
