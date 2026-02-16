import Foundation
import Combine
import FirebaseFirestore

struct TaskCategory: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var colorHex: String?
    var order: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case colorHex
        case order
    }
    
    init(id: String? = nil, name: String, colorHex: String? = nil, order: Int? = 0) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.order = order
    }
}
