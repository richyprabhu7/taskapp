import Foundation
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
    
    func addTask(title: String, assignedTo: String, assignedToName: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let newTask = Task(
            title: title,
            assignedTo: assignedTo,
            assignedToName: assignedToName,
            isCompleted: false,
            createdAt: Date(),
            createdBy: userId
        )
        
        do {
            _ = try db.collection("tasks").addDocument(from: newTask)
        } catch {
            print("Error adding task: \(error.localizedDescription)")
        }
    }
    
    func toggleTaskCompletion(task: Task) {
        guard let taskId = task.id else { return }
        
        db.collection("tasks").document(taskId).updateData([
            "isCompleted": !task.isCompleted
        ])
    }
    
    deinit {
        listener?.remove()
    }
}