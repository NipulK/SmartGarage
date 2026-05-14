import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {

    @DocumentID var id: String?

    var senderId: String
    var senderName: String
    var messageText: String
    var bookingId: String
    var hiddenForStaffIds: [String]? = nil
    var createdAt: Date
}
