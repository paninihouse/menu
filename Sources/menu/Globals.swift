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
