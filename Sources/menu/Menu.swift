import AppKit
import ArgumentParser

@main
struct Menu: ParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "menu",
		abstract: "Dynamic menu for the Mac",
		discussion: """
			menu reads a list of newline-separated items from stdin and presents them to the user.
			When the user selects an item and presses Return, their choice is printed to stdout and the menu terminated.
			Entering text will narrow the items to those matching the tokens in the input.
			""",
		version: "1.0.0"
	)

	@Option(name: .shortAndLong, help: "List choices vertically, with the given number of lines.")
	var lines: Int?

	@Flag(exclusivity: .chooseLast, help: "Define the position of the menu on the screen.")
	var position: Position = .top

	@Option(name: .shortAndLong, help: "Define the prompt to be displayed before the input.")
	var prompt: String?

	@Flag(name: .shortAndLong, help: "Define the visibility of the counter.")
	var counter: Bool = false

	@Option(name: .shortAndLong, help: "Display on the monitor number supplied.")
	var monitor: Int = 0

	func run() throws {
		let screen = try Screen.from(monitor)

		try MainActor.assumeIsolated {
			let app = NSApplication.shared
			let delegate = AppDelegate(screen: screen, menu: self)
			app.delegate = delegate
			app.setActivationPolicy(.accessory) // no Dock icon, no menu
			app.run()

			throw ExitCode.success
		}
	}
}

extension Menu {
	/// The menu position on the screen.
	enum Position: String, EnumerableFlag {
		/// Anchor the menu at the top of the screen.
		case top

		/// Anchor the menu at the bottom of the screen.
		case bottom

		static func name(for value: Menu.Position) -> NameSpecification {
			return .shortAndLong
		}
	}
}
