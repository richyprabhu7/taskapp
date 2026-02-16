import Foundation
import Combine
import FirebaseFirestore

struct Task: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var assignedTo: String
    var assignedToName: String
    var isCompleted: Bool
    var createdAt: Date
    var createdBy: String
    var dueDate: Date?
    var categoryId: String?
    var categoryName: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case assignedTo
        case assignedToName
        case isCompleted
        case createdAt
        case createdBy
        case dueDate
        case categoryId
        case categoryName
    }
    
    /// Date used for grouping by day (due date if set, else creation date)
    var dayDate: Date {
        dueDate ?? createdAt
    }
}