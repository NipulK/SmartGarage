import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine


class VehicleService: ObservableObject {
    @Published var vehicles: [Vehicle] = []
    @Published var errorMessage = ""
    @Published var isLoading = false

    private let db = Firestore.firestore()

    func addVehicle(
        make: String,
        model: String,
        year: String,
        color: String,
        plate: String,
        vin: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not logged in."
            completion(false)
            return
        }

        let vehicle = Vehicle(
            userId: userId,
            make: make,
            model: model,
            year: year,
            color: color,
            plate: plate,
            vin: vin,
            createdAt: Date()
        )

        do {
            _ = try db.collection("vehicles").addDocument(from: vehicle) { error in
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

    func fetchVehicles() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        isLoading = true

        db.collection("vehicles")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false

                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }

                    self.vehicles = snapshot?.documents.compactMap { document in
                        try? document.data(as: Vehicle.self)
                    } ?? []
                }
            }
    }
}
