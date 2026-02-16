import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

/// Manages task categories for the current user.
class CategoriesManager: ObservableObject {
    @Published var categories: [TaskCategory] = []
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        fetchCategories()
    }
    
    private var categoriesPath: String? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return "users/\(uid)/categories"
    }
    
    func fetchCategories() {
        guard let path = categoriesPath else { return }
        listener = db.collection(path)
            .order(by: "name", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Categories fetch error: \(error?.localizedDescription ?? "unknown")")
                    return
                }
                self?.categories = documents.compactMap { doc in
                    try? doc.data(as: TaskCategory.self)
                }
            }
    }
    
    func addCategory(name: String) {
        guard let path = categoriesPath, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let category = TaskCategory(name: name.trimmingCharacters(in: .whitespacesAndNewlines), order: categories.count)
        do {
            _ = try db.collection(path).addDocument(from: category)
        } catch {
            print("Error adding category: \(error.localizedDescription)")
        }
    }
    
    func deleteCategory(_ category: TaskCategory) {
        guard let path = categoriesPath, let id = category.id else { return }
        db.collection(path).document(id).delete()
    }
    
    deinit {
        listener?.remove()
    }
}
