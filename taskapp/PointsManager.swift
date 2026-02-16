import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

/// Gamification: points for creating tasks (1 for others, 2 for self) and completing tasks (5).
/// Weekly leaderboard for couples; Friday winner popup.
class PointsManager: ObservableObject {
    static let shared = PointsManager()
    
    @Published var currentUserTotalPoints: Int = 0
    @Published var currentUserWeekPoints: Int = 0
    @Published var partnerWeekPoints: Int = 0
    @Published var partnerName: String = "Partner"
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    private init() {
        fetchMyPoints()
    }
    
    private var currentUserId: String? { Auth.auth().currentUser?.uid }
    private var currentUserEmail: String? { Auth.auth().currentUser?.email }
    
    /// ISO week id e.g. "2026-W08"
    private static func weekId(for date: Date = Date()) -> String {
        let cal = Calendar.current
        let week = cal.component(.weekOfYear, from: date)
        let year = cal.component(.year, from: date)
        return "\(year)-W\(week)"
    }
    
    private func fetchMyPoints() {
        guard let uid = currentUserId else { return }
        listener = db.collection("users").document(uid).addSnapshotListener { [weak self] doc, _ in
            guard let data = doc?.data() else { return }
            DispatchQueue.main.async {
                self?.currentUserTotalPoints = data["totalPoints"] as? Int ?? 0
                let weekPoints = data["weeklyPoints"] as? [String: Int] ?? [:]
                self?.currentUserWeekPoints = weekPoints[Self.weekId()] ?? 0
            }
        }
    }
    
    /// Call after creating a task. Creator gets 2 if self-assigned, 1 if assigned to someone else.
    func awardForCreate(createdByUserId: String, assignedToEmail: String, currentUserEmail: String?) {
        guard createdByUserId == currentUserId else { return }
        let points = (assignedToEmail == currentUserEmail) ? 2 : 1
        addPointsAsync(userId: createdByUserId, points: points)
    }
    
    /// Call when a task is marked complete. Completer gets 5 points.
    func awardForComplete(userId: String) {
        addPoints(userId: userId, points: 5)
    }
    
    /// Call after creating a task (invokes addPoints).
    private func addPointsAsync(userId: String, points: Int) {
        addPoints(userId: userId, points: points)
    }
    
    private func addPoints(userId: String, points: Int) {
        let weekId = Self.weekId()
        let ref = db.collection("users").document(userId)
        db.runTransaction({ transaction, errorPointer -> Any? in
            let doc: DocumentSnapshot
            do {
                doc = try transaction.getDocument(ref)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            let total = (doc.data()?["totalPoints"] as? Int) ?? 0
            var weekly = (doc.data()?["weeklyPoints"] as? [String: Int]) ?? [:]
            weekly[weekId] = (weekly[weekId] ?? 0) + points
            transaction.setData([
                "totalPoints": total + points,
                "weeklyPoints": weekly,
                "updatedAt": FieldValue.serverTimestamp()
            ], forDocument: ref, merge: true)
            return nil
        }) { _, error in
            if let error = error {
                print("Points transaction failed: \(error.localizedDescription)")
            }
        }
    }
    
    /// Fetch partner's week points by partner user id (from connection). Call when showing banner or Friday popup.
    func fetchPartnerWeekPoints(partnerId: String?) {
        guard let pid = partnerId else {
            DispatchQueue.main.async { self.partnerWeekPoints = 0; self.partnerName = "Partner" }
            return
        }
        db.collection("users").document(pid).getDocument { [weak self] doc, _ in
            guard let data = doc?.data() else {
                DispatchQueue.main.async { self?.partnerWeekPoints = 0; self?.partnerName = "Partner" }
                return
            }
            let weekly = data["weeklyPoints"] as? [String: Int] ?? [:]
            let weekPoints = weekly[Self.weekId()] ?? 0
            let name = data["displayName"] as? String ?? (data["email"] as? String ?? "Partner")
            DispatchQueue.main.async {
                self?.partnerWeekPoints = weekPoints
                self?.partnerName = name
            }
        }
    }
    
    var isFriday: Bool {
        Calendar.current.component(.weekday, from: Date()) == 6
    }
    
    /// Current ISO week id for "once per week" logic
    static var currentWeekId: String { weekId() }
    
    var weekWinnerText: String {
        if currentUserWeekPoints > partnerWeekPoints { return "You win! 🏆" }
        if partnerWeekPoints > currentUserWeekPoints { return "\(partnerName) wins! 🏆" }
        return "It's a tie! 🤝"
    }
    
    deinit {
        listener?.remove()
    }
}
