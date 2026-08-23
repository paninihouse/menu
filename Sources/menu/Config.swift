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
	// static let font: Font = .system(size: 14, weight: .regular, design: .monospaced)
	static let font: Font = .custom("Comic code", fixedSize: 14)

	// NOTE: Customizing colors
	//
	// You can use system default colors and the standard SwiftUI
	// methods to define them. However, for convenience we added
	// support for hex colors too (see ``HEX``).
	//
	// E.g: `.hex("#000000")`

	/// The color used for texts.
	static let foreground: Color = .hex("#aed3f3")

	/// The color used for the prompt.
	static let subtle: Color = .hex("#aed3f3").opacity(0.5)

	/// The color used for the input cursor.
	static let cursor: Color = .hex("#32a9fe")

	/// The color used for the menu background.
	static let background: Color = .hex("#010408").opacity(0.825)

	/// The color used for the selected item background.
	static let selection: Color = .hex("#1f689d")

	/// The configuration used for fuzzy matching.
	///
	/// Check out the FuzzyMatch repo for usage details:
	/// https://github.com/ordo-one/FuzzyMatch
	static let matching: MatchConfig = .init(minScore: 0.7, algorithm: .editDistance(.default))

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
		.init(.return, .shift, action: .confirmInput),
		.init(.escape, action: .quit),
		.init(.tab, action: .complete),
		.init("j", .control, action: .next),
		.init("k", .control, action: .previous),
		.init("l", .control, action: .next),
		.init("h", .control, action: .previous),
	]
}

// MARK: Types reference

extension Config {
	/// An abstract action that a key binding can trigger.
	///
	/// The behaviour for each case lives in ``MenuView``;
	/// the config only decides *which* key performs *which* action.
	enum Action {
		/// Stop the menu and write the selected item to stdout.
		case confirm
		/// Stop the menu and write the raw input to stdout.
		case confirmInput
		/// Stop the menu without writing anything to stdout.
		case quit
		/// Replace the input with the currently selected item.
		case complete
		/// Move the selection forward by one.
		case next
		/// Move the selection backward by one.
		case previous
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
