import Foundation
import FirebaseFirestore

/// Invite sent to a partner's email. When they sign in, the connection is created.
struct PartnerInvite: Identifiable, Codable {
    @DocumentID var id: String?
    var fromUserId: String
    var fromEmail: String
    var fromDisplayName: String
    var toEmail: String
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case fromUserId
        case fromEmail
        case fromDisplayName
        case toEmail
        case createdAt
    }
}
