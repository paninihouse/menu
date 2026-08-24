import SwiftUI

/// Vertical list style (dmenu-like): choices are laid out one per line,
/// showing at most `ListState.lines` lines and scrolling the page as the
/// selection moves. Its height is the sum of the visible rows, so the window
/// (sized by `NSHostingView` to fit the content) shrinks as matches drop.
struct RowsListView: View {
	@EnvironmentObject var state: MenuState
	@EnvironmentObject var listState: ListState

	var body: some View {
		let visible = listState.verticalRange()

		VStack(alignment: .leading, spacing: 0) {
			ForEach(Array(visible), id: \.self) { index in
				let text = " \(state.choices[index]) "
				let selected = index == state.selection

				ZStack(alignment: .leading) {
					Rectangle()
						.foregroundStyle(selected ? Config.selection : .clear)

					Text(text)
						.foregroundStyle(Config.foreground)
						.lineLimit(1)
						.truncationMode(.tail)
				}
				.frame(height: Config.height)
			}
		}
	}
}
