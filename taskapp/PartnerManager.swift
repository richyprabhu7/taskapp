import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

/// Manages partner/spouse connection: send invite by email, connection is created when partner signs in.
class PartnerManager: ObservableObject {
    @Published var partnerId: String?
    @Published var partnerEmail: String?
    @Published var partnerDisplayName: String?
    @Published var sentInvite: PartnerInvite?
    @Published var isAcceptingInvite = false
    
    private let db = Firestore.firestore()
    private var userListener: ListenerRegistration?
    private var inviteListener: ListenerRegistration?
    
    init() {
        fetchMyUserAndInvite()
    }
    
    private var currentUserId: String? { Auth.auth().currentUser?.uid }
    
    private func fetchMyUserAndInvite() {
        guard let uid = currentUserId else { return }
        userListener = db.collection("users").document(uid).addSnapshotListener { [weak self] doc, _ in
            guard let data = doc?.data() else { return }
            DispatchQueue.main.async {
                self?.partnerId = data["partnerId"] as? String
                self?.fetchPartnerProfile()
            }
        }
        inviteListener = db.collection("invites")
            .whereField("fromUserId", isEqualTo: uid)
            .limit(to: 1)
            .addSnapshotListener { [weak self] snap, _ in
                let invite = snap?.documents.first.flatMap { try? $0.data(as: PartnerInvite.self) }
                DispatchQueue.main.async {
                    self?.sentInvite = invite
                }
            }
    }
    
    /// Fetch partner profile when we have partnerId
    func fetchPartnerProfile() {
        guard let pid = partnerId else {
            DispatchQueue.main.async { self.partnerDisplayName = nil; self.partnerEmail = nil }
            return
        }
        db.collection("users").document(pid).getDocument { [weak self] doc, _ in
            guard let data = doc?.data() else {
                DispatchQueue.main.async { self?.partnerDisplayName = nil; self?.partnerEmail = nil }
                return
            }
            let name = data["displayName"] as? String ?? (data["email"] as? String ?? "Partner")
            let email = data["email"] as? String ?? ""
            DispatchQueue.main.async {
                self?.partnerDisplayName = name
                self?.partnerEmail = email
            }
        }
    }
    
    /// Send invite to partner's email. They'll see it when they download the app and sign in.
    func sendInvite(toEmail: String) {
        guard let uid = currentUserId,
              let user = Auth.auth().currentUser else { return }
        let email = toEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !email.isEmpty, email != user.email else { return }
        
        let invite = PartnerInvite(
            fromUserId: uid,
            fromEmail: user.email ?? "",
            fromDisplayName: user.displayName ?? (user.email?.components(separatedBy: "@").first ?? "Someone"),
            toEmail: email,
            createdAt: Date()
        )
        do {
            _ = try db.collection("invites").addDocument(from: invite)
        } catch {
            print("Send invite error: \(error.localizedDescription)")
        }
    }
    
    /// Cancel a sent invite (delete it)
    func cancelInvite() {
        guard let invite = sentInvite, let id = invite.id else { return }
        db.collection("invites").document(id).delete()
    }
    
    /// Call after user signs in: if their email has a pending invite, create the connection.
    func acceptPendingInviteIfNeeded(userId: String, email: String, completion: @escaping () -> Void) {
        guard !email.isEmpty else { completion(); return }
        isAcceptingInvite = true
        db.collection("invites")
            .whereField("toEmail", isEqualTo: email.lowercased())
            .limit(to: 1)
            .getDocuments { [weak self] snap, _ in
                guard let doc = snap?.documents.first else {
                    DispatchQueue.main.async { self?.isAcceptingInvite = false; completion() }
                    return
                }
                guard let invite = try? doc.data(as: PartnerInvite.self) else {
                    DispatchQueue.main.async { self?.isAcceptingInvite = false; completion() }
                    return
                }
                let fromUserId = invite.fromUserId
                // Create connection: both users get partnerId
                let db = Firestore.firestore()
                let batch = db.batch()
                let fromRef = db.collection("users").document(fromUserId)
                let toRef = db.collection("users").document(userId)
                batch.setData(["partnerId": userId], forDocument: fromRef, merge: true)
                batch.setData(["partnerId": fromUserId], forDocument: toRef, merge: true)
                batch.deleteDocument(doc.reference)
                batch.commit { _ in
                    DispatchQueue.main.async {
                        self?.isAcceptingInvite = false
                        self?.partnerId = fromUserId
                        self?.fetchPartnerProfile()
                        completion()
                    }
                }
            }
    }
    
    deinit {
        userListener?.remove()
        inviteListener?.remove()
    }
}
