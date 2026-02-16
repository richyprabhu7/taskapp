import Foundation
import FirebaseFirestore

/// A contact/team member the user can assign tasks to.
struct TaskContact: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var displayName: String
    var addedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName
        case addedAt
    }
    
    init(id: String? = nil, email: String, displayName: String, addedAt: Date = Date()) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.addedAt = addedAt
    }
}
