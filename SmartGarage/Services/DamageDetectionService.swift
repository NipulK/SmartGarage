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
        completion: @escaping (Bool) -> Void
    ) {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not logged in."
            completion(false)
            return
        }

        isLoading = true
        errorMessage = ""

        // Simulate AI processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.saveMockDamageReport(
                userId: userId,
                vehicleId: vehicleId,
                vehicleName: vehicleName,
                completion: completion
            )
        }
    }

    private func saveMockDamageReport(
        userId: String,
        vehicleId: String,
        vehicleName: String,
        completion: @escaping (Bool) -> Void
    ) {
        let report = DamageReport(
            userId: userId,
            vehicleId: vehicleId,
            vehicleName: vehicleName,
            imageUrl: "local-image",
            damageType: "Body Panel Dent",
            severity: "High",
            confidence: "96%",
            estimatedCost: "$450 - $600",
            createdAt: Date()
        )

        do {
            _ = try db.collection("damageReports").addDocument(from: report) { error in
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
