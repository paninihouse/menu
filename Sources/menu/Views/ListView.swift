import SwiftUI

/// Inline list style: choices are laid out horizontally on a single row to
/// the right of the input line.
///
/// Pagination state and geometry live in ``ListState``; this view only
/// renders the visible items for the current page. It also reports the
/// *actual* width available to the row back to ``ListState`` so pagination is
/// computed against the real space, not the full menu width (which also has
/// to accommodate the input and page indicator).
struct ListView: View {
	@EnvironmentObject var state: MenuState
	@EnvironmentObject var listState: ListState

	var body: some View {
		GeometryReader { geometry in
			let width = geometry.size.width
			let visible = listState.visibleRange(width: width)

			HStack(spacing: 0) {
				ForEach(Array(visible), id: \.self) { index in
					let text = " \(state.choices[index]) "
					let selected = index == state.selection

					ZStack {
						Rectangle()
							.foregroundStyle(selected ? Config.selection : .clear)

						Text(text)
							.foregroundStyle(Config.foreground)
							.lineLimit(1)
							.truncationMode(.tail)
					}
					.fixedSize(horizontal: true, vertical: false)
				}
			}
			.onGeometryChange(for: CGFloat.self) { geometry in
				geometry.size.width
			} action: { _, newWidth in
				listState.containerWidth = newWidth
				listState.ensureSelectionVisible()
			}
		}
	}
}
