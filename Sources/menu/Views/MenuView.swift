import SwiftUI

struct MenuView: View {
	@StateObject private var state: MenuState
	@StateObject private var listState: ListState

	@Environment(\.fontResolutionContext) private var fontResolutionContext

	private let position: Config.Position

	init(state: MenuState, position: Config.Position) {
		_state = StateObject(wrappedValue: state)
		_listState = StateObject(wrappedValue: ListState(menuState: state))
		self.position = position
	}

	var body: some View {
		Group {
			if listState.isVertical {
				verticalBody
			} else {
				inlineBody
			}
		}
		.font(Config.font)
		.foregroundStyle(Config.foreground)
		.frame(maxWidth: .infinity)
		.border(state.outline ? Config.outline : .clear)
		.background(Config.background)
		.environmentObject(state)
		.environmentObject(listState)
		.task {
			listState.resolvedFont = Config.font.resolve(in: fontResolutionContext).ctFont as NSFont
		}
		.onChange(of: state.selection) { _, newSelection in
			listState.handleSelectionChange(to: newSelection)
		}
		.onGeometryChange(for: CGFloat.self) { geometry in
			geometry.size.width
		} action: { _, _ in
			// The list view reports its own available width to ``ListState``;
			// here we only react to container resizes so the selection stays
			// visible after the list view updates its measurement.
			listState.ensureSelectionVisible()
		}
	}

	// MARK: - Inline style

	private var inlineBody: some View {
		HStack(spacing: 0) {
			InputView()
			ListView()
			PageIndicatorView(
				pageStart: listState.pageStart,
				pageEnd: listState.pageEnd,
				count: state.choices.count,
				counter: state.counter
			)
		}
	}

	// MARK: - Vertical (rows) style

	private var inputLine: some View {
		HStack(spacing: 0) {
			InputView()
			Spacer(minLength: 0)
			PageIndicatorView(
				pageStart: listState.pageStart,
				pageEnd: listState.verticalPageEnd,
				count: state.choices.count,
				counter: state.counter
			)
		}
		.frame(height: Config.height)
	}

	private var verticalBody: some View {
		// The input line sits at the screen edge: at the top for `.top`, at the
		// bottom for `.bottom`. The list fills the rest.
		VStack(alignment: .leading, spacing: 0) {
			if position == .bottom {
				RowsListView()
				inputLine
			} else {
				inputLine
				RowsListView()
			}
		}
	}
}
