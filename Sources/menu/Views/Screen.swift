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
			write("No monitor founded", to: .standardError)
			throw ExitCode.failure
		}
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
	static func frame(_ screen: NSScreen, position: Menu.Position, height: CGFloat) -> NSRect {
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
