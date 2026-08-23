import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
	private var screen: NSScreen
	private var position: Menu.Position
	var state: MenuState
	private var window: MenuWindow!

	init(screen: NSScreen, menu: Menu) {
		self.screen = screen
		self.position = menu.position
		self.state = MenuState(prompt: menu.prompt, counter: menu.counter)

		super.init()
	}

	func applicationDidFinishLaunching(_ notification: Notification) {
		let frame = Screen.frame(screen, position: position, height: Config.height)
		let window = MenuWindow(contentRect: frame)
		window.contentView = NSHostingView(rootView: MenuView(state: self.state))
		window.makeKeyAndOrderFront(nil)
		self.window = window

		// Force the app to the foreground. `NSApp.activate()` (macOS 14+) only
		// activates "when appropriate" — which a background/subprocess launch
		// is *not*, so the app stays inactive, never resigns active, and the
		// dismiss-on-focus-loss never fires. The deprecated forcing variant
		// reliably brings the accessory app forward so didResignActive works.
		// NSApp.activate(ignoringOtherApps: true)
		NSApp.activate(ignoringOtherApps: true)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(stop),
			name: .stop,
			object: nil
		)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(stop),
			name: NSWindow.didResignKeyNotification,
			object: window
		)
	}

	func applicationWillTerminate(_ notification: Notification) {
		NotificationCenter.default.removeObserver(
			self,
			name: .stop,
			object: nil
		)

		NotificationCenter.default.removeObserver(
			self,
			name: NSWindow.didResignKeyNotification,
			object: window
		)
	}

	@objc func stop(_ notification: Notification) {
		if let result = notification.object as? String {
			write(result, to: .standardOutput)
		}

		NSApp.stop(nil)
		let event = NSEvent.otherEvent(
			with: .applicationDefined,
			location: .zero,
			modifierFlags: [],
			timestamp: 0,
			windowNumber: 0,
			context: nil,
			subtype: 0,
			data1: 0,
			data2: 0
		)
		NSApp.postEvent(event!, atStart: true)
	}
}

extension Notification.Name {
	static let stop = Notification.Name("stop")
}
