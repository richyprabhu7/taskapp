import Foundation
import FirebaseFirestore

struct Task: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var assignedTo: String
    var assignedToName: String
    var isCompleted: Bool
    var createdAt: Date
    var createdBy: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case assignedTo
        case assignedToName
        case isCompleted
        case createdAt
        case createdBy
    }
}