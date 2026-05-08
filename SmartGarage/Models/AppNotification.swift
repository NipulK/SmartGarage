import Foundation
import FirebaseFirestore

struct AppNotification: Identifiable, Codable {

    @DocumentID var id: String?

    var receiverId: String
    var senderName: String

    var bookingId: String

    var title: String
    var body: String

    var isRead: Bool
    var isPopupShown: Bool

    var createdAt: Date
}
