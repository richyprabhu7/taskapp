import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    @StateObject private var taskManager = TaskManager()
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                TaskListView()
                    .environmentObject(taskManager)
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}