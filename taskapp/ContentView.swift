import SwiftUI
import Combine
import FirebaseAuth

struct ContentView: View {
    @StateObject private var partnerManager = PartnerManager()
    @StateObject private var authManager = AuthManager()
    @StateObject private var taskManager = TaskManager()
    @StateObject private var categoriesManager = CategoriesManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                TaskListView()
                    .environmentObject(taskManager)
                    .environmentObject(authManager)
                    .environmentObject(partnerManager)
                    .environmentObject(categoriesManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            authManager.partnerManager = partnerManager
            if let user = authManager.user {
                partnerManager.acceptPendingInviteIfNeeded(userId: user.uid, email: user.email ?? "") { }
            }
        }
    }
}