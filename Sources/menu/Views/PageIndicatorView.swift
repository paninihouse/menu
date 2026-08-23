import SwiftUI

/// A status indicator shown at the trailing edge of the paginated list.
///
/// It combines a page-position arrow with an optional total-count counter:
/// - ` [>] ` on the first page (no counter)
/// - ` [<] ` on the last page (no counter)
/// - ` [<>] ` on a middle page (no counter)
/// - ` [10k] ` when the counter is enabled but only a single page is visible
/// - ` [<> | 10k] ` when both the counter is enabled and multiple pages exist
///
/// The view is hidden when there is nothing to show (no counter and a single
/// or unknown page).
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
