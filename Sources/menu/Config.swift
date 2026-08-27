import ArgumentParser
import FuzzyMatch
import SwiftUI

/// The top-level configuration for the menu.
///
/// Set appearance and choose the menu position here.
/// This is the primary file a user edits to customise *menu*.
enum Config {
	/// The menu height in points (pt).
	///
	/// > Tip: Set this value to 30 to match the default Mac menu bar height.
	static let height: Double = 30

	// NOTE: Customizing font
	//
	// You can use system default fonts thanks to the standard SwiftUI
	// methods and access properties. However, you can also use your
	// preferred custom font.
	//
	// E.g: `.custom("Comic Code", fixedSize: 14)`

	/// The font used for all text in the menu.
	static let font: Font = .system(size: 14, weight: .regular, design: .monospaced)

	// NOTE: Customizing colors
	//
	// You can use system default colors and the standard SwiftUI
	// methods to define them. However, for convenience we added
	// support for hex colors too (see ``HEX``).
	//
	// E.g: `.hex("#000000")`

	/// The color used for texts.
	static let foreground: Color = .hex("#AED3F3")

	/// The color used for the prompt.
	static let subtle: Color = .hex("#AED3F3").opacity(0.5)

	/// The color used for the input cursor.
	static let cursor: Color = .hex("#32A9FE")

	/// The color used for the menu background.
	static let background: Color = .hex("#010408")

	/// The color used for the menu outline.
	static let outline: Color = .hex("#1f689d")

	/// The color used for the selected item background.
	static let selection: Color = .hex("#1F689D")

	/// The configuration used for fuzzy matching.
	///
	/// Check out the FuzzyMatch repo for usage details:
	/// https://github.com/ordo-one/FuzzyMatch
	static let match: MatchConfig = .init(minScore: 0.7, algorithm: .editDistance(.default))

	// NOTE: Customizing key bindings
	//
	// Each entry maps a key (plus optional modifiers) to an action.
	// The first matching binding wins, so list specific bindings before
	// general ones and feel free to add alternates — for example both the
	// arrow keys and Emacs-style Ctrl-n / Ctrl-p for moving the selection.
	//
	// Supported modifiers: `.command`, `.control`, `.option`, `.shift`,
	// `.numericPad`, `.capsLock`. They are matched exactly.
	static let bindings: [Binding] = [
		.init(.return, action: .confirm),
		.init(.return, .control, action: .confirmInput),
		.init(.escape, action: .quit),
		.init(.tab, action: .complete),
		.init("j", .control, action: .forward),
		.init("k", .control, action: .backward),
		.init("l", .control, action: .forward),
		.init("h", .control, action: .backward),
	]
}

// MARK: Types reference

extension Config {
	/// The menu position on the screen.
	///
	/// Used both as the CLI flag value (see ``Menu``) and by the window
	/// layout code (see ``Screen``).
	enum Position: String, EnumerableFlag {
		/// Anchor the menu at the top of the screen.
		case top

		/// Anchor the menu at the bottom of the screen.
		case bottom

		static func name(for value: Config.Position) -> NameSpecification {
			return .shortAndLong
		}
	}

	/// An abstract action that a key binding can trigger.
	///
	/// The behaviour for each case lives in ``MenuView``;
	/// the config only decides *which* key performs *which* action.
	enum Action {
		/// Quit `menu` and write the selected string to `stdout`.
		case confirm
		/// Quit `menu` and write the raw input to `stdout`.
		case confirmInput
		/// Quit `menu` without writing anything to `stdout`.
		case quit
		/// Replace input with the currently selected string.
		case complete
		/// Move selection forward by one.
		case forward
		/// Move selection backward by one.
		case backward
	}

	/// A single key binding: a key, optional modifiers, and the action it triggers.
	///
	/// `KeyEquivalent` covers both special keys (`.escape`, `.return`, `.tab`,
	/// `.upArrow`, `.downArrow`) and character keys (`KeyEquivalent("k")`).
	///
	/// Modifiers are matched exactly, so `Return` and `Shift-Return` are two
	/// distinct bindings.
	struct Binding {
		let key: KeyEquivalent
		let modifiers: EventModifiers
		let action: Action

		init(_ key: KeyEquivalent, _ modifiers: EventModifiers = [], action: Action) {
			self.key = key
			self.modifiers = modifiers
			self.action = action
		}
	}
}
