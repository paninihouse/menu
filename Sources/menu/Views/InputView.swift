import AppKit
import SwiftUI

struct InputView: View {
	@EnvironmentObject var state: MenuState
	@EnvironmentObject var list: ListState
	@Environment(\.fontResolutionContext) private var fontResolutionContext

	@State private var cursorHeight: CGFloat?
	@State private var cursorVisible = true
	@FocusState private var isFocused: Bool

	var body: some View {
		ZStack(alignment: .leading) {
			TextField("", text: $state.input)
				.textFieldStyle(.plain)
				.focused($isFocused)
				.onAppear { isFocused = true }
				.opacity(0)

			if let prompt = state.prompt, state.input.isEmpty {
				HStack(spacing: 0) {
					Text(" ")
					Text(prompt)
						.foregroundStyle(Config.subtle)
						.lineLimit(1)
						.truncationMode(.head)
					Text(" ")
				}
			}

			HStack(spacing: 0) {
				Text(" ")
				Text(state.input)
					.foregroundStyle(Config.foreground)
					.lineLimit(1)
					.truncationMode(.head)
				Rectangle()
					.foregroundStyle(Config.cursor)
					.frame(width: 1, height: cursorHeight)
					.opacity(cursorVisible ? 1 : 0)
				Text(" ")
			}
		}
		.frame(width: state.stdin.isEmpty || list.isVertical ? .infinity : 300)
		.task {
			let font = Config.font.resolve(in: fontResolutionContext).ctFont as NSFont
			cursorHeight = NSString(" ").size(withAttributes: [.font: font]).height
		}
		.task(id: state.input) {
			cursorVisible = true
			try? await Task.sleep(for: .seconds(0.65))
			guard !Task.isCancelled else { return }
			while !Task.isCancelled {
				cursorVisible = false
				try? await Task.sleep(for: .seconds(0.65))
				guard !Task.isCancelled else { return }
				cursorVisible = true
				try? await Task.sleep(for: .seconds(0.65))
			}
		}
	}
}
