import SwiftUI

struct TextView: View {
	let string: String
	let style: Style
	let truncate: Text.TruncationMode

	init(_ string: String, style: Style = .normal, truncate: Text.TruncationMode = .tail) {
		self.string = string
		self.style = style
		self.truncate = truncate
	}

	enum Style: String {
		case normal
		case subtle
		case selected
	}

	private var background: Color {
		switch style {
		case .normal: .clear
		case .subtle: .clear
		case .selected: Config.selection
		}
	}

	private var foreground: Color {
		switch style {
		case .normal: Config.foreground
		case .subtle: Config.subtle
		case .selected: Config.foreground
		}
	}

	var body: some View {
		ZStack(alignment: .leading) {
			Rectangle()
				.foregroundStyle(background)

			Text(string)
				.foregroundStyle(foreground)
				.lineLimit(1)
				.truncationMode(truncate)
		}
		.frame(height: Config.height)
	}
}
