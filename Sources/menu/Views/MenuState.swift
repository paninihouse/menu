import AppKit
import FuzzyMatch

@MainActor
final class MenuState: ObservableObject {
	let prompt: String?
	let counter: Bool

	let stdin: [String]
	@Published var choices: [String]
	@Published var selection: Int = 0
	@Published var input = "" {
		didSet { match() }
	}

	var result: String? {
		guard !stdin.isEmpty else { return input }
		return choices.indices.contains(selection) ? choices[selection] : nil
	}

	init(prompt: String?, counter: Bool) {
		self.prompt = prompt
		self.counter = counter
		self.stdin = readLines()
		self.choices = stdin
	}

	private func match() {
		selection = 0

		guard !stdin.isEmpty else { return }
		guard !input.isEmpty else {
			choices = stdin
			return
		}

		let matcher = FuzzyMatcher(config: Config.matching)
		let query = matcher.prepare(input)
		let results = matcher.topMatches(stdin, against: query)
		self.choices = results.map(\.candidate)
	}

	func forward() {
		guard selection < choices.count - 1 else { return }
		selection += 1
	}

	func backward() {
		guard selection > 0 else { return }
		selection -= 1
	}
}
