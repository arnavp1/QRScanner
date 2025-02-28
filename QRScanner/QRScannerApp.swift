import SwiftUI

@main
struct QRScannerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        
        Settings {
            SettingsView()
        }
    }
}
