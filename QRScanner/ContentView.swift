import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var image: NSImage?
    @State private var result: String = "Scan a QR Code"
    @State private var showCopiedMessage: Bool = false
    
    private let qrProcessor = QRCodeProcessor()
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 20) {
                Group {
                    if let nsImage = image {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 300, maxHeight: 300)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    } else {
                        Image(systemName: "qrcode.viewfinder")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                            .frame(maxWidth: 300, maxHeight: 300)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .onDrop(of: [UTType.image.identifier], isTargeted: nil) { providers -> Bool in
                    providers.first?.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
                        if let data = data, let nsImage = NSImage(data: data) {
                            DispatchQueue.main.async {
                                self.image = nsImage
                                processImage(nsImage)
                            }
                        }
                    }
                    return true
                }
                
                VStack(spacing: 4) {
                    Text(result)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                        .multilineTextAlignment(.center)
                        .onTapGesture {
                            if result.starts(with: "http") {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(result, forType: .string)
                                withAnimation {
                                    showCopiedMessage = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation {
                                        showCopiedMessage = false
                                    }
                                }
                            }
                        }
                    
                    if showCopiedMessage {
                        Spacer().frame(height: 10)
                        Text("Copied!")
                            .foregroundColor(.blue)
                            .padding(4)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(4)
                            .transition(.opacity)
                    }
                }
                
                HStack(spacing: 15) {
                    Button("Open Image") {
                        openImage()
                    }
                    .keyboardShortcut("o", modifiers: .command)
                    
                    Button("Paste Image") {
                        pasteFromClipboard()
                    }
                    .keyboardShortcut("v", modifiers: .command)
                    
                    Button("Take Screenshot") {
                        takeScreenshot()
                    }
                    .keyboardShortcut("s", modifiers: .command)
                }
                .padding(.bottom)
            }
            .padding()
        }
        .frame(width: 400, height: 450)
    }
    
    private func takeScreenshot() {
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-c"]
        
        task.terminationHandler = { process in
            if process.terminationStatus == 0 {
                if let clipboardImage = NSPasteboard.general.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage {
                    DispatchQueue.main.async {
                        self.image = clipboardImage
                        self.processImage(clipboardImage)
                    }
                }
            } else {
                print("Screenshot canceled or failed.")
            }
        }
        
        do {
            try task.run()
        } catch {
            print("Error launching screencapture: \(error)")
        }
    }
    
    private func processImage(_ image: NSImage) {
        qrProcessor.processQRCode(in: image) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let link):
                    self.result = link
                case .failure(let error):
                    self.result = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func openImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .tiff, .bmp]
        panel.allowsMultipleSelection = false
        
        panel.begin { response in
            if response == .OK, let url = panel.url, let nsImage = NSImage(contentsOf: url) {
                DispatchQueue.main.async {
                    self.image = nsImage
                    self.processImage(nsImage)
                }
            }
        }
    }
    
    private func pasteFromClipboard() {
        guard let clipboardImage = NSPasteboard.general.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage else {
            self.result = "No image found in clipboard"
            return
        }
        
        self.image = clipboardImage
        self.processImage(clipboardImage)
    }
}
