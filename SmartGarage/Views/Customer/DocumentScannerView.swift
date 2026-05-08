import SwiftUI
import VisionKit
import Vision
import PhotosUI

struct DocumentScannerView: UIViewControllerRepresentable {

    var onScanComplete: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onScanComplete: onScanComplete)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(
        _ uiViewController: VNDocumentCameraViewController,
        context: Context
    ) { }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {

        var onScanComplete: (String) -> Void

        init(onScanComplete: @escaping (String) -> Void) {
            self.onScanComplete = onScanComplete
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            var fullText = ""
            let group = DispatchGroup()

            for index in 0..<scan.pageCount {
                group.enter()

                let image = scan.imageOfPage(at: index)

                OCRHelper.recognizeText(from: image) { text in
                    fullText += "\n\(text)"
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                controller.dismiss(animated: true) {
                    self.onScanComplete(fullText)
                }
            }
        }

        func documentCameraViewControllerDidCancel(
            _ controller: VNDocumentCameraViewController
        ) {
            controller.dismiss(animated: true)
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFailWithError error: Error
        ) {
            controller.dismiss(animated: true)
        }
    }
}

struct OCRHelper {
    static func recognizeText(
        from image: UIImage,
        completion: @escaping (String) -> Void
    ) {
        guard let cgImage = image.cgImage else {
            completion("")
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                completion("")
                return
            }

            let text = observations.compactMap {
                $0.topCandidates(1).first?.string
            }
            .joined(separator: "\n")

            DispatchQueue.main.async {
                completion(text)
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage)

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    completion("")
                }
            }
        }
    }
}
