import Foundation

enum TaskStatusFilter: String, CaseIterable {
    case all = "All"
    case toDo = "To Do"
    case done = "Done"
    
    func includes(_ task: Task) -> Bool {
        switch self {
        case .all: return true
        case .toDo: return !task.isCompleted
        case .done: return task.isCompleted
        }
    }
}
