import Foundation

/// Returns the strings read from standard input until EOF is reached.
///
/// Standard input is interpreted as `UTF-8`. Invalid bytes are replaced by
/// Unicode [replacement characters][rc].
///
/// [rc]:
/// https://unicode.org/glossary/#replacement_character
///
/// - Parameter strippingNewline: If `true`, newline characters and character
///   combinations are stripped from the result; otherwise, newline characters
///   or character combinations are preserved. The default is `true`.
/// - Returns: The string of characters read from standard input. If EOF has
///   already been reached when `readLine()` is called, the result is `nil`.
func readLines(strippingNewline: Bool = true) -> [String] {
	// If stdin is an interactive terminal (not piped/redirected), there is no
	// input to read. `readLine()` would block waiting for the user to type and
	// never reach EOF, hanging the program. Bail out early instead.
	guard isatty(STDIN_FILENO) == 0 else { return [] }

	var lines = [String]()

	while let line = readLine(strippingNewline: strippingNewline) {
		lines.append(line)
	}

	return lines
}

/// Replaces `\uXXXX` escape sequences (4 hex digits) in a string with the
/// Unicode scalars they represent, so that text coming from `stdin` can carry
/// arbitrary codepoints — handy for SF Symbols and other glyphs that are hard
/// to type in a shell.
///
/// Swift's `\u{...}` is a compile-time escape and only works inside source
/// literals; this runs on *runtime* text and therefore is the only way such a
/// sequence typed in a shell reaches the menu as an actual Unicode scalar.
/// Malformed escapes (fewer than 4 hex digits) are left verbatim.
func unescape(_ string: String) -> String {
	let hexDigits: Set<Character> = Set("0123456789abcdefABCDEF")

	var output = ""
	var chars = string.makeIterator()

	while let c = chars.next() {
		guard c == "\\" else { output.append(c); continue }
		guard let next = chars.next() else { output.append(c); break }

		guard next == "u" else {
			output.append("\\"); output.append(next)
			continue
		}

		var hex = ""
		while hex.count < 4, let h = chars.next(), hexDigits.contains(h) { hex.append(h) }

		if hex.count == 4, let value = UInt32(hex, radix: 16), let scalar = Unicode.Scalar(value) {
			output.unicodeScalars.append(scalar)
		} else {
			output.append("\\u"); output.append(hex)
		}
	}

	return output
}

/// Write data to the provided handle.
/// - Parameters:
///   - data: The data to write.
///   - handle: The handle to which data should be written.
func write(_ data: Data, to handle: FileHandle) {
	handle.write(data)
}

/// Write string to the provided handle.
/// - Parameters:
///   - string: The string to write.
///   - handle: The handle to which data should be written.
func write(_ string: String, to handle: FileHandle) {
	write(Data(string.utf8), to: handle)
}

/// Write string to the provided handle followed by a newline (`"\n"`).
/// - Parameters:
///   - string: The string to write.
///   - handle: The handle to which data should be written.
func writeln(_ string: String, to handle: FileHandle) {
	write(string + "\n", to: handle)
}
