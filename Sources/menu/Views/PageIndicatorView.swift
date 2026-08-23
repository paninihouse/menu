import SwiftUI

struct PageIndicatorView: View {
	let pageStart: Int
	let pageEnd: Int?
	let count: Int
	let counter: Bool

	var body: some View {
		if let text {
			TextView(text, style: .subtle)
		}
	}

	private var text: String? {
		guard count > 0 else { return nil }
		let arrow = arrowSymbol
		if counter, let arrow {
			return " [\(arrow) | \(counterLabel)] "
		} else if counter {
			return " [\(counterLabel)] "
		} else if let arrow {
			return " [\(arrow)] "
		} else {
			return nil
		}
	}

	/// The arrow describing the current page position, or `nil` when the page
	/// is single/unknown.
	private var arrowSymbol: String? {
		guard let end = pageEnd else { return nil }
		let isFirst = pageStart == 0
		let isLast = end >= count
		guard !(isFirst && isLast) else { return nil }
		switch (isFirst, isLast) {
		case (true, _): return ">"
		case (false, true): return "<"
		case (false, false): return "<>"
		}
	}

	private var counterLabel: String {
		count.formatted(.number.notation(.compactName))
	}
}
