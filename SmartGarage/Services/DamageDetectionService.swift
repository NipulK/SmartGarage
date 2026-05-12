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
        damageType: String,
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
                        
                        let confidenceValue =
                        Int(firstResult.confidence * 100)

                        self.damageType = damageType
                        self.vehicleName = vehicleName
                        self.confidence = "\(confidenceValue)%"

                        // AI BASED SEVERITY
                        if confidenceValue >= 90 {

                            self.severity = "High"
                            self.estimatedCost = "$500 - $900"

                        } else if confidenceValue >= 75 {

                            self.severity = "Medium"
                            self.estimatedCost = "$250 - $500"

                        } else {

                            self.severity = "Low"
                            self.estimatedCost = "$80 - $250"
                        }

                        self.saveDamageReport(
                            userId: userId,
                            vehicleId: vehicleId,
                            vehicleName: vehicleName,
                            damageType: damageType,
                            severity: self.severity,
                            confidence: self.confidence,
                            estimatedCost: self.estimatedCost,
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
