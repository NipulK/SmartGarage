import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import UIKit


class DamageDetectionService: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage = ""

    private let db = Firestore.firestore()

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

        isLoading = true
        errorMessage = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {

            let result = self.generateDamageResult(for: damageType)

            self.saveDamageReport(
                userId: userId,
                vehicleId: vehicleId,
                vehicleName: vehicleName,
                damageType: result.damageType,
                severity: result.severity,
                confidence: result.confidence,
                estimatedCost: result.cost,
                completion: completion
            )
        }
    }

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
