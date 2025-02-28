import Cocoa

class ScreenshotManager {
    func captureScreenshot(completion: @escaping (NSImage?) -> Void) {
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-c"]
        
        task.terminationHandler = { process in
            if process.terminationStatus == 0 {
                if let image = NSPasteboard.general.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage {
                    completion(image)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
        
        try? task.run()
    }
}
