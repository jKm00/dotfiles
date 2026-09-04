// Fires a SketchyBar event the instant the macOS keyboard input source changes.
// This is the same distributed notification the native menu bar reacts to, so
// updates are immediate instead of poll-delayed.
//
// Build: swiftc -O keyboard_listener.swift -o keyboard_listener
// Run:   ./keyboard_listener   (stays alive; started in the background by sketchybarrc)

import Foundation

let sketchybar = "/opt/homebrew/bin/sketchybar"

func triggerKeyboardChange() {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: sketchybar)
    task.arguments = ["--trigger", "keyboard_change"]
    try? task.run()
}

let center = DistributedNotificationCenter.default()
center.addObserver(
    forName: NSNotification.Name("com.apple.Carbon.TISNotifySelectedKeyboardInputSourceChanged"),
    object: nil,
    queue: .main
) { _ in
    triggerKeyboardChange()
}

// Push an initial state on launch, then wait for notifications forever.
triggerKeyboardChange()
RunLoop.main.run()
