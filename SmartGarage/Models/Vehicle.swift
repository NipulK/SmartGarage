import Foundation
import FirebaseFirestore


struct Vehicle: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var make: String
    var model: String
    var year: String
    var color: String
    var plate: String
    var vin: String
    var createdAt: Date
}
