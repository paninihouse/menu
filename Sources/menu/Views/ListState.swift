import AppKit

/// Owns the pagination state and geometry logic for the list of choices,
/// decoupled from any particular rendering style (inline or rows).
///
/// The source of truth for the choices and the selection stays in
/// ``MenuState``; this type only computes *which* items are visible and keeps
/// the current page stable as the selection moves.
@MainActor
final class ListState: ObservableObject {
	@Published var pageStart: Int = 0
	@Published var containerWidth: CGFloat = 0
	@Published var resolvedFont: NSFont?

	/// Number of lines to display in the vertical (rows) style, or `nil` for
	/// the inline (single-row) style. Read from ``MenuState``.
	var lines: Int? { menuState.lines }
	var isVertical: Bool { lines != nil }

	private unowned let menuState: MenuState

	init(menuState: MenuState) {
		self.menuState = menuState
	}

	private var choices: [String] { menuState.choices }
	private var selection: Int { menuState.selection }

	// MARK: - Page bounds

	/// Index just past the last visible item in the inline page, or `nil`
	/// until the container width and font are known.
	var pageEnd: Int? {
		guard containerWidth > 0, resolvedFont != nil, !choices.isEmpty else { return nil }
		return fillForward(from: pageStart, width: containerWidth)
	}

	/// Index just past the last visible item in the vertical page, or `nil`
	/// until the line count is known.
	var verticalPageEnd: Int? {
		guard let lines, lines > 0, !choices.isEmpty else { return nil }
		return min(pageStart + lines, choices.count)
	}

	// MARK: - Width measurement

	/// Measures the rendered width of a choice, including the surrounding
	/// spaces used in the visible `Text`. Returns `nil` until the font is
	/// resolved.
	private func itemWidth(_ index: Int) -> CGFloat? {
		guard let font = resolvedFont else { return nil }
		return (" \(choices[index]) " as NSString)
			.size(withAttributes: [.font: font]).width
	}

	// MARK: - Inline page computation

	/// The range of indices currently visible on the inline row.
	func visibleRange(width: CGFloat) -> Range<Int> {
		let count = choices.count
		guard count > 0 else { return 0..<0 }

		guard width > 0, resolvedFont != nil else {
			// Not ready yet: show at least the selected item.
			let s = min(selection, count - 1)
			return s..<(s + 1)
		}

		let start = min(pageStart, count - 1)
		return start..<fillForward(from: start, width: width)
	}

	/// First index past the last item that fits when filling forward from
	/// `from`. The item at `from` is always included even if it overflows.
	private func fillForward(from: Int, width: CGFloat) -> Int {
		var end = from
		var used: CGFloat = 0
		while end < choices.count {
			guard let w = itemWidth(end) else { break }
			if end != from, used + w > width { break }
			used += w
			end += 1
		}
		return end
	}

	/// Returns a page start such that the page ends exactly at `last`, filling
	/// as many items backward as fit. `last` is always included even if it
	/// overflows.
	private func fillBackward(endingAt last: Int, width: CGFloat) -> Int {
		var start = last
		guard var used = itemWidth(last) else { return start }
		while start > 0 {
			guard let w = itemWidth(start - 1) else { break }
			if used + w > width { break }
			used += w
			start -= 1
		}
		return start
	}

	// MARK: - Vertical page computation

	/// The range of indices currently visible in the vertical page (one item
	/// per line), determined solely by `pageStart` and `lines`.
	func verticalRange() -> Range<Int> {
		guard let lines, lines > 0, !choices.isEmpty else { return 0..<0 }
		let start = min(pageStart, choices.count - 1)
		return start..<min(start + lines, choices.count)
	}

	// MARK: - Pagination

	/// Keeps the page stable when the selection stays inside the current
	/// window; otherwise shifts the page so the selection becomes visible.
	func handleSelectionChange(to newSelection: Int) {
		guard !choices.isEmpty else { return }

		if isVertical {
			guard let lines, lines > 0 else { return }
			let end = min(pageStart + lines, choices.count)
			if newSelection >= pageStart, newSelection < end { return }
			if newSelection >= end {
				pageStart = newSelection
			} else {
				pageStart = max(0, newSelection - lines + 1)
			}
		} else {
			guard containerWidth > 0, resolvedFont != nil else { return }
			let end = fillForward(from: pageStart, width: containerWidth)
			if newSelection >= pageStart, newSelection < end { return }
			if newSelection >= end {
				pageStart = newSelection
			} else {
				pageStart = fillBackward(endingAt: newSelection, width: containerWidth)
			}
		}
	}

	/// Recomputes the page so the current selection is visible. Used when the
	/// available width changes (e.g. on resize or first measurement).
	func ensureSelectionVisible() {
		handleSelectionChange(to: selection)
	}
}
