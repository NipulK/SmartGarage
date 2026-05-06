import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit

class DamageDetectionService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var uploadedImageUrl = ""

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    func uploadDamageImage(
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

        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            errorMessage = "Could not convert image."
            completion(false)
            return
        }

        isLoading = true
        errorMessage = ""

        let imageId = UUID().uuidString
        let imageRef = storage.reference().child("damageImages/\(userId)/\(imageId).jpg")

        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
                return
            }

            imageRef.downloadURL { url, error in
                DispatchQueue.main.async {
                    self.isLoading = false

                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        completion(false)
                        return
                    }

                    guard let urlString = url?.absoluteString else {
                        self.errorMessage = "Image URL not found."
                        completion(false)
                        return
                    }

                    self.uploadedImageUrl = urlString
                    self.saveMockDamageReport(
                        userId: userId,
                        vehicleId: vehicleId,
                        vehicleName: vehicleName,
                        imageUrl: urlString,
                        completion: completion
                    )
                }
            }
        }
    }

    private func saveMockDamageReport(
        userId: String,
        vehicleId: String,
        vehicleName: String,
        imageUrl: String,
        completion: @escaping (Bool) -> Void
    ) {
        let report = DamageReport(
            userId: userId,
            vehicleId: vehicleId,
            vehicleName: vehicleName,
            imageUrl: imageUrl,
            damageType: "Front Bumper Damage",
            severity: "High",
            confidence: "98%",
            estimatedCost: "$450 - $600",
            createdAt: Date()
        )

        do {
            _ = try db.collection("damageReports").addDocument(from: report) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            completion(false)
        }
    }
}
