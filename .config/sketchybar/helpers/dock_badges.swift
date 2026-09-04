// Reads macOS Dock icon notification badges via the Accessibility API and
// prints one "AppName|Badge" line per badged app (e.g. "Slack|3").
//
// The Dock exposes each icon's badge text as the AXStatusLabel attribute.
// Reading another app's UI requires this binary to be granted Accessibility
// (System Settings -> Privacy & Security -> Accessibility).
//
// Build: swiftc -O dock_badges.swift -o dock_badges && codesign --force --sign - dock_badges
// Usage: ./dock_badges          prints badges (silent if not trusted)
//        ./dock_badges prompt   triggers the one-time Accessibility prompt
//        ./dock_badges debug    dumps trust state + Dock AX tree to stderr

import Cocoa
import ApplicationServices

func attr(_ el: AXUIElement, _ a: String) -> AnyObject? {
    var v: AnyObject?
    return AXUIElementCopyAttributeValue(el, a as CFString, &v) == .success ? v : nil
}
func attrNames(_ el: AXUIElement) -> [String] {
    var names: CFArray?
    return AXUIElementCopyAttributeNames(el, &names) == .success ? (names as? [String] ?? []) : []
}
func children(_ el: AXUIElement) -> [AXUIElement] {
    attr(el, kAXChildrenAttribute as String) as? [AXUIElement] ?? []
}

let mode = CommandLine.arguments.dropFirst().first ?? ""

if mode == "prompt" {
    let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
    _ = AXIsProcessTrustedWithOptions(opts)
    exit(0)
}

let err = FileHandle.standardError
func log(_ s: String) { err.write((s + "\n").data(using: .utf8)!) }

if mode == "debug" { log("AXIsProcessTrusted: \(AXIsProcessTrusted())") }

guard AXIsProcessTrusted() else { exit(0) }

guard let dock = NSRunningApplication
    .runningApplications(withBundleIdentifier: "com.apple.dock").first else {
    if mode == "debug" { log("no Dock process") }
    exit(0)
}
let app = AXUIElementCreateApplication(dock.processIdentifier)

// Recursively walk the Dock tree looking for items that carry a badge.
func walk(_ el: AXUIElement, depth: Int) {
    for child in children(el) {
        let role = attr(child, kAXRoleAttribute as String) as? String ?? "?"
        let title = attr(child, kAXTitleAttribute as String) as? String ?? ""
        let badge = attr(child, "AXStatusLabel") as? String

        if mode == "debug" {
            let names = attrNames(child).joined(separator: ",")
            log(String(repeating: "  ", count: depth)
                + "role=\(role) title=\(title.isEmpty ? "-" : title) "
                + "badge=\(badge ?? "-") attrs=[\(names)]")
        }

        if let badge = badge, !badge.isEmpty, !title.isEmpty {
            print("\(title)|\(badge)")
        }
        walk(child, depth: depth + 1)
    }
}
walk(app, depth: 0)
