import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore


class BookingService: ObservableObject {

    @Published var bookings: [Booking] = []
    @Published var errorMessage = ""
    @Published var isLoading = false

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

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

            _ = try db.collection("bookings")
                .addDocument(from: booking) { error in

                    DispatchQueue.main.async {

                        if let error = error {

                            self.errorMessage =
                            error.localizedDescription

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

        guard let userId =
            Auth.auth().currentUser?.uid else {

            errorMessage = "User not logged in"
            return
        }

        isLoading = true

        listener?.remove()

        listener = db.collection("bookings")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in

                DispatchQueue.main.async {

                    self.isLoading = false

                    if let error = error {

                        self.errorMessage =
                        error.localizedDescription

                        return
                    }

                    self.bookings =
                    snapshot?.documents.compactMap {

                        try? $0.data(as: Booking.self)

                    } ?? []
                }
            }
    }

    func fetchAllBookings() {

        isLoading = true

        listener?.remove()

        listener = db.collection("bookings")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in

                DispatchQueue.main.async {

                    self.isLoading = false

                    if let error = error {

                        self.errorMessage =
                        error.localizedDescription

                        return
                    }

                    self.bookings =
                    snapshot?.documents.compactMap {

                        try? $0.data(as: Booking.self)

                    } ?? []
                }
            }
    }

    func fetchBookingById(
        bookingId: String,
        completion: @escaping (Booking?) -> Void
    ) {

        db.collection("bookings")
            .document(bookingId)
            .getDocument { snapshot, error in

                DispatchQueue.main.async {

                    if let error = error {

                        self.errorMessage =
                        error.localizedDescription

                        completion(nil)
                        return
                    }

                    guard let snapshot = snapshot else {

                        completion(nil)
                        return
                    }

                    let booking =
                    try? snapshot.data(as: Booking.self)

                    completion(booking)
                }
            }
    }

    func fetchCustomerName(
        userId: String,
        completion: @escaping (String) -> Void
    ) {

        db.collection("users")
            .document(userId)
            .getDocument { snapshot, error in

                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        completion("Customer")
                        return
                    }

                    let data = snapshot?.data()
                    let fullName = data?["fullName"] as? String
                    let username = data?["username"] as? String

                    if let fullName,
                       !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        completion(fullName)
                    } else if let username,
                              !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        completion(username)
                    } else {
                        completion("Customer")
                    }
                }
            }
    }

    func updateBookingStatus(
        bookingId: String,
        status: String,
        completionNote: String? = nil,
        completion: @escaping (Bool) -> Void
    ) {
        var updateData: [String: Any] = [
            "status": status
        ]

        if status.lowercased() == "completed" {
            updateData["completionNote"] =
            completionNote?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }

        db.collection("bookings")
            .document(bookingId)
            .updateData(updateData) { error in

                DispatchQueue.main.async {

                    if let error = error {

                        self.errorMessage =
                        error.localizedDescription

                        completion(false)

                    } else {

                        completion(true)
                    }
                }
            }
    }
}
