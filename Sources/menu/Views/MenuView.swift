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
	}
}
