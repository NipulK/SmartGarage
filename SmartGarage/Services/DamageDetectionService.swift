import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import UIKit
import Vision
import CoreML

class DamageDetectionService: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage = ""

    @Published var damageReports: [DamageReport] = []

    @Published var damageType = ""
    @Published var severity = ""
    @Published var confidence = ""
    @Published var estimatedCost = ""
    @Published var vehicleName = ""

    private let db = Firestore.firestore()

    // MARK: - ANALYZE DAMAGE

    func analyzeDamage(
        image: UIImage,
        vehicleId: String,
        vehicleName: String,
        completion: @escaping (Bool) -> Void
    ) {

        guard let userId = Auth.auth().currentUser?.uid else {

            errorMessage = "User not logged in."
            completion(false)
            return
        }

        guard let ciImage = CIImage(image: image) else {

            errorMessage = "Invalid image."
            completion(false)
            return
        }

        isLoading = true
        errorMessage = ""

        do {

            let model = try VNCoreMLModel(
                for: MobileNetV2().model
            )

            let request = VNCoreMLRequest(model: model) { request, error in

                DispatchQueue.main.async {

                    if let results = request.results as? [VNClassificationObservation],
                       let firstResult = results.first {
                        
                        print("AI Prediction:", firstResult.identifier)
                        print("AI Confidence:", firstResult.confidence)
                        
                        let analysis = self.detectDamage(from: results)
                        let confidenceValue = Int(analysis.confidence * 100)

                        self.damageType = analysis.damageType
                        self.vehicleName = vehicleName
                        self.confidence = "\(confidenceValue)%"
                        self.severity = analysis.severity
                        self.estimatedCost = analysis.estimatedCost

                        self.saveDamageReport(
                            userId: userId,
                            vehicleId: vehicleId,
                            vehicleName: vehicleName,
                            damageType: analysis.damageType,
                            severity: analysis.severity,
                            confidence: "\(confidenceValue)%",
                            estimatedCost: analysis.estimatedCost,
                            completion: completion
                        )

                    } else {

                        self.isLoading = false
                        self.errorMessage = "AI analysis failed."
                        completion(false)
                    }
                }
            }

            let handler = VNImageRequestHandler(
                ciImage: ciImage,
                options: [:]
            )

            DispatchQueue.global(qos: .userInitiated).async {

                do {

                    try handler.perform([request])

                } catch {

                    DispatchQueue.main.async {

                        self.isLoading = false
                        self.errorMessage = error.localizedDescription
                        completion(false)
                    }
                }
            }

        } catch {

            isLoading = false
            errorMessage = error.localizedDescription
            completion(false)
        }
    }

    private func detectDamage(
        from observations: [VNClassificationObservation]
    ) -> (
        damageType: String,
        severity: String,
        confidence: Float,
        estimatedCost: String
    ) {
        let rankedResults = observations.prefix(5)
        let matchedResult = rankedResults.compactMap { observation in
            damageCategory(for: observation.identifier).map {
                (category: $0, confidence: observation.confidence)
            }
        }.first

        if let matchedResult {
            let details = damageDetails(for: matchedResult.category, confidence: matchedResult.confidence)
            return (
                matchedResult.category,
                details.severity,
                matchedResult.confidence,
                details.estimatedCost
            )
        }

        let topConfidence = observations.first?.confidence ?? 0
        return (
            "Damage Not Clearly Classified",
            "Unknown",
            topConfidence,
            "Requires inspection"
        )
    }

    private func damageCategory(for identifier: String) -> String? {
        let label = identifier.lowercased()

        if label.contains("windshield") ||
            label.contains("windscreen") ||
            label.contains("glass") ||
            label.contains("crack") {
            return "Windshield Crack"
        }

        if label.contains("headlight") ||
            label.contains("tail light") ||
            label.contains("taillight") ||
            label.contains("lamp") ||
            label.contains("broken light") {
            return "Headlight Damage"
        }

        if label.contains("bumper") ||
            label.contains("front") ||
            label.contains("collision") ||
            label.contains("crash") ||
            label.contains("impact") {
            return "Front Bumper Damage"
        }

        if label.contains("scratch") ||
            label.contains("scrape") ||
            label.contains("paint") ||
            label.contains("scuff") {
            return "Paint Scratch"
        }

        if label.contains("dent") ||
            label.contains("deform") ||
            label.contains("body damage") ||
            label.contains("panel") {
            return "Body Dent"
        }

        return nil
    }

    private func damageDetails(
        for damageType: String,
        confidence: Float
    ) -> (
        severity: String,
        estimatedCost: String
    ) {
        switch damageType {
        case "Windshield Crack":
            return ("High", "$300 - $900")
        case "Headlight Damage":
            return confidence >= 0.75 ? ("Medium", "$200 - $450") : ("Low", "$120 - $250")
        case "Front Bumper Damage":
            return confidence >= 0.75 ? ("High", "$450 - $700") : ("Medium", "$250 - $500")
        case "Paint Scratch":
            return ("Low", "$80 - $180")
        case "Body Dent":
            return confidence >= 0.75 ? ("Medium", "$150 - $300") : ("Low", "$80 - $180")
        default:
            return ("Unknown", "Requires inspection")
        }
    }
    
    // MARK: - FETCH DAMAGE REPORTS

    func fetchDamageReports() {

        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }

        db.collection("damageReports")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in

                DispatchQueue.main.async {

                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }

                    self.damageReports = snapshot?.documents.compactMap {
                        try? $0.data(as: DamageReport.self)
                    } ?? []
                }
            }
    }

    // MARK: - GENERATE RESULT

    private func generateDamageResult(
        for type: String
    ) -> (
        damageType: String,
        severity: String,
        confidence: String,
        cost: String
    ) {

        switch type {

        case "Dent":
            return (
                "Body Dent",
                "Medium",
                "92%",
                "$150 - $300"
            )

        case "Scratch":
            return (
                "Paint Scratch",
                "Low",
                "95%",
                "$80 - $180"
            )

        case "Broken Light":
            return (
                "Headlight Damage",
                "Medium",
                "97%",
                "$200 - $450"
            )

        case "Front Bumper Damage":
            return (
                "Front Bumper Damage",
                "High",
                "98%",
                "$450 - $700"
            )

        case "Windshield Crack":
            return (
                "Windshield Crack",
                "High",
                "96%",
                "$300 - $900"
            )

        default:
            return (
                "Unknown Damage",
                "Low",
                "80%",
                "$100 - $200"
            )
        }
    }

    // MARK: - SAVE DAMAGE REPORT

    private func saveDamageReport(
        userId: String,
        vehicleId: String,
        vehicleName: String,
        damageType: String,
        severity: String,
        confidence: String,
        estimatedCost: String,
        completion: @escaping (Bool) -> Void
    ) {

        let report = DamageReport(
            userId: userId,
            vehicleId: vehicleId,
            vehicleName: vehicleName,
            imageUrl: "local-image",
            damageType: damageType,
            severity: severity,
            confidence: confidence,
            estimatedCost: estimatedCost,
            createdAt: Date()
        )

        do {

            _ = try db.collection("damageReports")
                .addDocument(from: report) { error in

                    DispatchQueue.main.async {

                        self.isLoading = false

                        if let error = error {

                            self.errorMessage = error.localizedDescription
                            completion(false)

                        } else {

                            self.fetchDamageReports()
                            completion(true)
                        }
                    }
                }

        } catch {

            DispatchQueue.main.async {

                self.isLoading = false
                self.errorMessage = error.localizedDescription
                completion(false)
            }
        }
    }
}
