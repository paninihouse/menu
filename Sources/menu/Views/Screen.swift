import AppKit
import ArgumentParser
import Foundation

enum Screen {
	/// Returns the screen for the provided monitor number.
	///
	/// - Parameter monitor: The monitor number associated with the screen.
	/// - Throws: `ExitCode.failure` to stop the program execution early.
	/// - Returns: The `NSScreen` from the monitor number or the main screen
	///            if out of range.
	static func from(_ monitor: Int) throws -> NSScreen {
		if monitor >= 0, monitor < NSScreen.screens.count {
			return NSScreen.screens[monitor]
		} else if let screen = NSScreen.main {
			return screen
		} else {
			writeln("No monitor founded", to: .standardError)
			throw ExitCode.failure
		}
	}

	/// Computes the menu height for a given number of choices: a single
	/// line for the inline style, or the input line plus one row per visible
	/// line (up to `lines`) for the vertical style. When there are no choices,
	/// only the input line is shown.
	///
	/// - Parameters:
	///   - choices: The number of choices currently presented.
	///   - lines: The maximum number of lines in the vertical style, or `nil`
	///           for the inline (single-row) style.
	/// - Returns: The menu height in points.
	static func menuHeight(choices: Int, lines: Int?) -> CGFloat {
		if let lines, lines > 0 {
			let visible = choices > 0 ? min(lines, choices) : 0
			return Config.height * CGFloat(visible + 1)
		}
		return Config.height
	}

	/// Frame of the menu within a screen, in global display coordinates.
	///
	/// - Parameters:
	///   - screen: The screen to calculate the menu frame for.
	///   - position: Whether the menu sits at the top or bottom
	///               of the screen.
	///   - height: The menu height in points (see ``Config/height``).
	///
	/// - Returns: An NSRect in screen coordinates. The menu spans
	///            the full width of the screen and is anchored at the top
	///            or bottom edge.
	static func frame(_ screen: NSScreen, position: Config.Position, height: CGFloat) -> NSRect {
		switch position {
		case .top:
			return NSRect(
				x: screen.frame.minX,
				y: screen.frame.maxY - height,
				width: screen.frame.width,
				height: height
			)
		case .bottom:
			return NSRect(
				x: screen.frame.minX,
				y: screen.frame.minY,
				width: screen.frame.width,
				height: height
			)
		}
	}
}
