import SwiftUI

struct ListView: View {
	@EnvironmentObject var state: MenuState
	@Environment(\.fontResolutionContext) private var fontResolutionContext

	@State private var containerWidth: CGFloat = 0
	@State private var resolvedFont: NSFont?

	/// Index of the leftmost visible item in the current page.
	@State private var pageStart: Int = 0

	var body: some View {
		HStack(spacing: 0) {
			GeometryReader { geometry in
				let width = geometry.size.width
				let visible = visibleRange(width: width)

				HStack(spacing: 0) {
					ForEach(Array(visible), id: \.self) { index in
						let selected = index == state.selection
						TextView(" \(state.choices[index]) ", style: selected ? .selected : .normal)
					}
				}
			}
			.task {
				resolvedFont = Config.font.resolve(in: fontResolutionContext).ctFont as NSFont
			}
			.onChange(of: state.selection) { oldSelection, newSelection in
				handleSelectionChange(from: oldSelection, to: newSelection)
			}
			.onGeometryChange(for: CGFloat.self) { geometry in
				geometry.size.width
			} action: { _, newWidth in
				containerWidth = newWidth
				ensureSelectionVisible()
			}

			PageIndicatorView(
				pageStart: pageStart,
				pageEnd: pageEnd,
				count: state.choices.count,
				counter: state.counter
			)
		}
	}

	// MARK: - Page bounds

	/// Index just past the rightmost visible item in the current page, or `nil`
	/// until the container width and font are known.
	private var pageEnd: Int? {
		guard containerWidth > 0, resolvedFont != nil, !state.choices.isEmpty else { return nil }
		return fillForward(from: pageStart, width: containerWidth)
	}

	// MARK: - Width measurement

	/// Measures the rendered width of a choice, including the surrounding
	/// spaces used in the visible `Text`. Returns `nil` until the font is
	/// resolved.
	private func itemWidth(_ index: Int) -> CGFloat? {
		guard let font = resolvedFont else { return nil }
		return (" \(state.choices[index]) " as NSString)
			.size(withAttributes: [.font: font]).width
	}

	// MARK: - Page computation

	/// The range of indices currently visible, filled forward from `pageStart`.
	private func visibleRange(width: CGFloat) -> Range<Int> {
		let count = state.choices.count
		guard count > 0 else { return 0..<0 }

		guard width > 0, resolvedFont != nil else {
			// Not ready yet: show at least the selected item.
			let s = min(state.selection, count - 1)
			return s..<(s + 1)
		}

		let start = min(pageStart, count - 1)
		let end = fillForward(from: start, width: width)
		return start..<end
	}

	/// First index past the last item that fits when filling forward from `from`.
	/// The item at `from` is always included even if it overflows.
	private func fillForward(from: Int, width: CGFloat) -> Int {
		let count = state.choices.count
		var end = from
		var used: CGFloat = 0
		while end < count {
			guard let iw = itemWidth(end) else { break }
			let cost = iw
			if end != from, used + cost > width { break }
			used += cost
			end += 1
		}
		return end
	}

	/// Returns a page start such that the page ends exactly at `last` (i.e.
	/// `last` is the rightmost visible item), filling as many items backward as
	/// fit. `last` is always included even if it overflows.
	private func fillBackward(endingAt last: Int, width: CGFloat) -> Int {
		var start = last
		guard let baseW = itemWidth(last) else { return start }
		var used = baseW
		while start > 0 {
			guard let prevW = itemWidth(start - 1) else { break }
			let cost = prevW
			if used + cost > width { break }
			used += cost
			start -= 1
		}
		return start
	}

	// MARK: - Pagination on selection change

	private func handleSelectionChange(from oldSelection: Int, to newSelection: Int) {
		guard containerWidth > 0, resolvedFont != nil, !state.choices.isEmpty else { return }

		let end = fillForward(from: pageStart, width: containerWidth)

		// Selection stays inside the current window: keep the page stable.
		if newSelection >= pageStart, newSelection < end { return }

		if newSelection >= end {
			// Moved forward past the rightmost item: swap to a new page whose
			// leftmost item is the new selection.
			pageStart = newSelection
		} else {
			// Moved backward past the leftmost item: swap to a new page whose
			// rightmost item is the new selection.
			pageStart = fillBackward(endingAt: newSelection, width: containerWidth)
		}
	}

	/// Recomputes the page so that the current selection is visible. Used when
	/// the available width changes (e.g. on resize or first measurement).
	private func ensureSelectionVisible() {
		guard containerWidth > 0, resolvedFont != nil, !state.choices.isEmpty else { return }

		let end = fillForward(from: pageStart, width: containerWidth)
		if state.selection >= pageStart, state.selection < end { return }

		if state.selection < pageStart {
			pageStart = fillBackward(endingAt: state.selection, width: containerWidth)
		} else {
			pageStart = state.selection
		}
	}
}
