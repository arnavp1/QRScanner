import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var screenshotManager = ScreenshotManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "qrcode", accessibilityDescription: "QR Code Scanner")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 450)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView())
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open QR Scanner", action: #selector(togglePopover), keyEquivalent: "o"))
        menu.addItem(NSMenuItem(title: "Paste Image", action: #selector(pasteFromClipboard), keyEquivalent: "v"))
        menu.addItem(NSMenuItem(title: "Scan Screenshot", action: #selector(takeScreenshot), keyEquivalent: "s"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func togglePopover() {
        if let button = statusItem?.button, let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    @objc func pasteFromClipboard() {
        guard let clipboardImage = NSPasteboard.general.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage else {
            print("No image found in clipboard")
            return
        }
        processQRCode(in: clipboardImage)
    }
    
    @objc func takeScreenshot() {
        screenshotManager.captureScreenshot { [weak self] image in
            guard let image = image else { return }
            self?.processQRCode(in: image)
        }
    }
    
    func processQRCode(in image: NSImage) {
        let qrProcessor = QRCodeProcessor()
        qrProcessor.processQRCode(in: image) { result in
            switch result {
            case .success(let link):
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(link, forType: .string)
                print("QR Code Detected: Link copied to clipboard: \(link)")
            case .failure(let error):
                print("QR Scanner error: \(error.localizedDescription)")
            }
        }
    }
}
