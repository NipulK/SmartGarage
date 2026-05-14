import Foundation
import FirebaseFirestore


struct DamageReport: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var userId: String
    var vehicleId: String
    var vehicleName: String
    var imageUrl: String
    var damageType: String
    var severity: String
    var confidence: String
    var estimatedCost: String
    var createdAt: Date
}
