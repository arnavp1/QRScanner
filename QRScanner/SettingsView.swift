import SwiftUI

struct SettingsView: View {
    @AppStorage("shortcutOpenImage") private var shortcutOpenImage = "o"
    @AppStorage("shortcutPasteImage") private var shortcutPasteImage = "v"
    @AppStorage("shortcutScreenshot") private var shortcutScreenshot = "s"
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Form {
                Section {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                        .toggleStyle(SwitchToggleStyle())
                        .onChange(of: darkModeEnabled) { _, newValue in
                            updateAppearance(enabled: newValue)
                        }
                }
                
                Section(header: Text("Keyboard Shortcuts").font(.headline)) {
                    ShortcutRow(label: "Open Image", shortcut: shortcutOpenImage)
                    ShortcutRow(label: "Paste Image", shortcut: shortcutPasteImage)
                    ShortcutRow(label: "Take Screenshot", shortcut: shortcutScreenshot)
                }
            }
            .formStyle(.grouped)
        }
        .padding()
        .frame(width: 400)
        .navigationTitle("QRScanner Settings")
    }
    
    private func updateAppearance(enabled: Bool) {
        NSApp.appearance = NSAppearance(named: enabled ? .darkAqua : .aqua)
    }
}

struct ShortcutRow: View {
    let label: String
    let shortcut: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            TextField("", text: .constant("⌘ + \(shortcut.uppercased())"))
                .disabled(true)
                .frame(width: 80)
                .multilineTextAlignment(.center)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.vertical, 4)
    }
}
