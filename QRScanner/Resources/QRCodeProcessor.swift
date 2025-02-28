import Cocoa
import Vision

enum QRCodeError: Error {
    case noQRCodeFound
    case imageProcessingFailed
    case invalidImage
    
    var localizedDescription: String {
        switch self {
        case .noQRCodeFound:
            return "No QR code found in the image"
        case .imageProcessingFailed:
            return "Failed to process the image"
        case .invalidImage:
            return "Invalid or corrupted image"
        }
    }
}

class QRCodeProcessor {
    func processQRCode(in image: NSImage, completion: @escaping (Result<String, QRCodeError>) -> Void) {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            completion(.failure(.invalidImage))
            return
        }
        
        let request = VNDetectBarcodesRequest { request, error in
            if let error = error {
                completion(.failure(.imageProcessingFailed))
                print("Vision error: \(error.localizedDescription)")
                return
            }
            
            guard let results = request.results as? [VNBarcodeObservation],
                  !results.isEmpty else {
                completion(.failure(.noQRCodeFound))
                return
            }
            
            for result in results where result.symbology == .qr {
                if let payload = result.payloadStringValue {
                    completion(.success(payload))
                    return
                }
            }
            
            completion(.failure(.noQRCodeFound))
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            completion(.failure(.imageProcessingFailed))
        }
    }
}
