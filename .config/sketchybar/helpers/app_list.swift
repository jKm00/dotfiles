// Lists the currently running "regular" macOS apps — the ones that appear in
// the Dock and the Cmd-Tab switcher — so the bar can render a flat taskbar of
// open apps (replacing the old AeroSpace per-workspace window query).
//
// Output: one "AppName|isFront" line per app, ordered by process id so the row
// stays stable as focus moves (only the highlight changes, icons don't shuffle).
// isFront is 1 for the frontmost app, 0 otherwise, e.g. "Ghostty|1".
//
// Needs no special permissions — NSWorkspace.runningApplications requires no
// Accessibility/Automation grant. Build:
//   swiftc -O app_list.swift -o app_list

import Cocoa

let ws = NSWorkspace.shared
let front = ws.frontmostApplication?.processIdentifier

let apps = ws.runningApplications
    .filter { $0.activationPolicy == .regular }
    .sorted { $0.processIdentifier < $1.processIdentifier }

for app in apps {
    guard let name = app.localizedName, !name.isEmpty else { continue }
    let isFront = (app.processIdentifier == front) ? "1" : "0"
    print("\(name)|\(isFront)")
}
