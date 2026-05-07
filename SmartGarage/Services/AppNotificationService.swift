import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class AppNotificationService: ObservableObject {

    @Published var notifications: [AppNotification] = []

    private let db = Firestore.firestore()

    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    func createNotification(
        receiverId: String,
        senderName: String,
        bookingId: String,
        title: String,
        body: String
    ) {

        let notification = AppNotification(
            receiverId: receiverId,
            senderName: senderName,
            bookingId: bookingId,
            title: title,
            body: body,
            isRead: false,
            createdAt: Date()
        )

        do {

            _ = try db.collection("notifications")
                .addDocument(from: notification)

        } catch {

            print(error.localizedDescription)
        }
    }

    func fetchNotifications() {

        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }

        listener?.remove()

        listener = db.collection("notifications")
            .whereField("receiverId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in

                DispatchQueue.main.async {

                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }

                    self.notifications = snapshot?.documents.compactMap {
                        try? $0.data(as: AppNotification.self)
                    } ?? []
                }
            }
    }

    func markAsRead(notificationId: String) {

        db.collection("notifications")
            .document(notificationId)
            .updateData([
                "isRead": true
            ])
    }

    var unreadCount: Int {

        notifications.filter {
            !$0.isRead
        }.count
    }

    var latestUnreadNotification: AppNotification? {

        notifications.first(where: {
            !$0.isRead
        })
    }
}
