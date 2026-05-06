import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class BookingService: ObservableObject {

    @Published var bookings: [Booking] = []
    @Published var errorMessage = ""
    @Published var isLoading = false

    private let db = Firestore.firestore()

    func createBooking(
        vehicleId: String,
        vehicleName: String,
        serviceType: String,
        bookingDate: String,
        timeSlot: String,
        completion: @escaping (Bool) -> Void
    ) {

        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not logged in"
            completion(false)
            return
        }

        let booking = Booking(
            userId: userId,
            vehicleId: vehicleId,
            vehicleName: vehicleName,
            serviceType: serviceType,
            bookingDate: bookingDate,
            timeSlot: timeSlot,
            status: "Pending",
            createdAt: Date()
        )

        do {
            _ = try db.collection("bookings").addDocument(from: booking) { error in

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

    func fetchBookings() {

        guard let userId = Auth.auth().currentUser?.uid else { return }

        isLoading = true

        db.collection("bookings")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in

                DispatchQueue.main.async {

                    self.isLoading = false

                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }

                    self.bookings = snapshot?.documents.compactMap {
                        try? $0.data(as: Booking.self)
                    } ?? []
                }
            }
    }
}
