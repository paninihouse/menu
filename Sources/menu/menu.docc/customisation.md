# Customisation

How to customise the program.

The program can be customised by editing the static properties inside the ``Config`` enum.

```swift
// Sources/menu/Config.swift

enum Config {
	static let height: Double     = 30

	static let font: Font = .custom("My Awesome Font", fixedSize: 14)

	static let foreground: Color   = .hex("#AED3F3")
	static let subtle: Color       = .hex("#AED3F3").opacity(0.5)
	static let cursor: Color       = .hex("#32A9FE")
	static let background: Color   = .hex("#010408").opacity(0.825)
	static let selection: Color    = .hex("#1F689D")

	static let match: MatchConfig = .init(minScore: 0.7, algorithm: .editDistance(.default))

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
```

## HEX Colors

You can use any standard SwiftUI color. For convenience, we also provide the ``HEX`` type for defining colors by hex code directly in source:

```swift
static let foreground: Color = .hex("#CDD6F4")
```

Supported formats (the leading `#` is optional): `#RGB`, `#RGBA`, `#RRGGBB`, `#RRGGBBAA`.
