# Background blur

Set a backdrop blur to the entire menu.

This patch adds a `backgroundBlur` option (Double) to ``Config``.
Adjust the value to increase or decrease the blur effect behind the menu.

```swift
enum Config {
	/// The blur amount used for the menu background.
	static let backgroundBlur: Double = 10
}
```

> Warning: This patch uses private Apple APIs.
Future versions of macOS might break the functionality.

## Installation

```shell
curl -sL https://raw.githubusercontent.com/paninihouse/menu/refs/heads/master/patches/patch-background_blur-20260811-10fed47.patch | patch -p1
```

After applying, rebuild the program:

```shell
make install
```

## Author

Tommaso Negri [@tommasongr](https://github.com/tommasongr)
