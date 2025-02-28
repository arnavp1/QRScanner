import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("shortcutOpenImage") private var shortcutOpenImage = "o"
    @AppStorage("shortcutPasteImage") private var shortcutPasteImage = "v"
    @AppStorage("shortcutScreenshot") private var shortcutScreenshot = "s"
    
    var body: some View {
        Form {
            Toggle("Launch at Login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { _, newValue in
                    updateLaunchAtLogin(enabled: newValue)
                }
            
            Section(header: Text("Keyboard Shortcuts")) {
                HStack {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Open Image")
                        Text("Paste from Clipboard")
                        Text("Take Screenshot")
                    }
                    Spacer()
                    VStack(alignment: .center, spacing: 8) {
                        TextField("", text: $shortcutOpenImage)
                            .frame(width: 40)
                            .multilineTextAlignment(.center)
                        TextField("", text: $shortcutPasteImage)
                            .frame(width: 40)
                            .multilineTextAlignment(.center)
                        TextField("", text: $shortcutScreenshot)
                            .frame(width: 40)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .padding()
        .frame(width: 400)
        .navigationTitle("Settings")
    }
    
    private func updateLaunchAtLogin(enabled: Bool) {
        let helperBundleID = "com.podichetty.QRScannerHelper"
        let loginItem = SMAppService.loginItem(identifier: helperBundleID)
        do {
            if enabled {
                try loginItem.register()
            } else {
                try loginItem.unregister()
            }
        } catch {
            print("Failed to toggle login item: \(error.localizedDescription)")
        }
    }
}
