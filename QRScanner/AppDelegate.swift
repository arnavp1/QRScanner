import Cocoa
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var screenshotManager = ScreenshotManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        registerGlobalShortcut()
        requestNotificationPermission()
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
                
                self.showNotification(title: "QR Code Detected", message: "Link copied to clipboard: \(link)")
                
            case .failure(let error):
                self.showNotification(title: "QR Scanner", message: error.localizedDescription)
            }
        }
    }
    
    func showNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error showing notification: \(error)")
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if !granted {
                print("Notification permission denied")
            }
        }
    }
    
    func registerGlobalShortcut() {
        print("Global shortcut registration would go here.")
    }
}
