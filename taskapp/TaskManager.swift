import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class TaskManager: ObservableObject {
    @Published var tasks: [Task] = []
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        fetchTasks()
    }
    
    func fetchTasks() {
        listener = db.collection("tasks")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching tasks: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.tasks = documents.compactMap { document -> Task? in
                    try? document.data(as: Task.self)
                }
            }
    }
    
    func addTask(title: String, assignedTo: String, assignedToName: String, dueDate: Date? = nil, categoryId: String? = nil, categoryName: String? = nil) {
        guard let userId = Auth.auth().currentUser?.uid,
              let currentEmail = Auth.auth().currentUser?.email else { return }
        
        let newTask = Task(
            title: title,
            assignedTo: assignedTo,
            assignedToName: assignedToName,
            isCompleted: false,
            createdAt: Date(),
            createdBy: userId,
            dueDate: dueDate,
            categoryId: categoryId,
            categoryName: categoryName
        )
        
        do {
            _ = try db.collection("tasks").addDocument(from: newTask)
            PointsManager.shared.awardForCreate(createdByUserId: userId, assignedToEmail: assignedTo, currentUserEmail: currentEmail)
        } catch {
            print("Error adding task: \(error.localizedDescription)")
        }
    }
    
    func toggleTaskCompletion(task: Task) {
        guard let taskId = task.id, let userId = Auth.auth().currentUser?.uid else { return }
        let newCompleted = !task.isCompleted
        
        db.collection("tasks").document(taskId).updateData([
            "isCompleted": newCompleted
        ])
        if newCompleted {
            PointsManager.shared.awardForComplete(userId: userId)
        }
    }
    
    func updateTaskCategory(taskId: String, categoryId: String?, categoryName: String?) {
        db.collection("tasks").document(taskId).updateData([
            "categoryId": categoryId ?? NSNull(),
            "categoryName": categoryName ?? NSNull()
        ])
    }
    
    /// Group by date then by category for list view. Soonest date first (upcoming). Returns (date, [(categoryName, tasks)]).
    func tasksGroupedByDayAndCategory(from tasks: [Task]) -> [(date: Date, categories: [(name: String, tasks: [Task])])] {
        let calendar = Calendar.current
        let byDay = Dictionary(grouping: tasks) { calendar.startOfDay(for: $0.dayDate) }
        return byDay
            .map { date, dayTasks in
                let byCat = Dictionary(grouping: dayTasks) { (task: Task) -> String in
                    task.categoryName?.trimmingCharacters(in: .whitespaces).isEmpty == false
                        ? (task.categoryName ?? "Uncategorized")
                        : "Uncategorized"
                }
                let sortedCats = byCat.sorted { a, b in
                    if a.key == "Uncategorized" { return false }
                    if b.key == "Uncategorized" { return true }
                    return a.key < b.key
                }
                let catTuples = sortedCats.map { (name: $0.key, tasks: $0.value.sorted { ($0.dueDate ?? $0.createdAt) < ($1.dueDate ?? $1.createdAt) }) }
                return (date: date, categories: catTuples)
            }
            .sorted { $0.date < $1.date }
    }
    
    /// Group tasks by day (for calendar etc.). Soonest date first.
    func tasksGroupedByDay(from tasks: [Task]) -> [(date: Date, tasks: [Task])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: tasks) { calendar.startOfDay(for: $0.dayDate) }
        return grouped
            .map { (date: $0.key, tasks: $0.value.sorted { ($0.dueDate ?? $0.createdAt) < ($1.dueDate ?? $1.createdAt) }) }
            .sorted { $0.date < $1.date }
    }
    
    deinit {
        listener?.remove()
    }
}