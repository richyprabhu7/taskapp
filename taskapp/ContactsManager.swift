import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

/// Manages the current user's list of contacts (people they can assign tasks to).
class ContactsManager: ObservableObject {
    @Published var contacts: [TaskContact] = []
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        fetchContacts()
    }
    
    private var contactsPath: String? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return "users/\(uid)/contacts"
    }
    
    func fetchContacts() {
        guard let path = contactsPath else { return }
        listener = db.collection(path)
            .order(by: "displayName")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Contacts fetch error: \(error?.localizedDescription ?? "unknown")")
                    return
                }
                self?.contacts = documents.compactMap { doc in
                    try? doc.data(as: TaskContact.self)
                }
            }
    }
    
    func addContact(email: String, displayName: String) {
        guard let path = contactsPath else { return }
        let contact = TaskContact(email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                                  displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines))
        do {
            _ = try db.collection(path).addDocument(from: contact)
        } catch {
            print("Error adding contact: \(error.localizedDescription)")
        }
    }
    
    func removeContact(_ contact: TaskContact) {
        guard let path = contactsPath, let id = contact.id else { return }
        db.collection(path).document(id).delete()
    }
    
    deinit {
        listener?.remove()
    }
}
