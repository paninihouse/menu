import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, KeyMonitorDelegate {
	private var screen: NSScreen
	private var position: Menu.Position
	var state: MenuState
	var keyMonitor: KeyMonitor!
	private var window: MenuWindow!

	init(screen: NSScreen, menu: Menu) {
		self.screen = screen
		self.position = menu.position
		self.state = MenuState(prompt: menu.prompt, counter: menu.counter)

		super.init()
	}

	func applicationDidFinishLaunching(_ notification: Notification) {
		// Create the keyboard events monitor.
		self.keyMonitor = KeyMonitor(delegate: self)

		// Configure and present the window.
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

		// Start monitoring keyboard events.
		keyMonitor.start()

		// Quit right away if menu loses focus.
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(quit),
			name: NSWindow.didResignKeyNotification,
			object: window
		)
	}

	func applicationWillTerminate(_ notification: Notification) {
		// Stop monitoring keyboard events.
		keyMonitor.stop()

		// Stop monitoring menu losing focus.
		NotificationCenter.default.removeObserver(
			self,
			name: NSWindow.didResignKeyNotification,
			object: window
		)
	}
}
