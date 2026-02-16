import SwiftUI
import Combine
import FirebaseCore
import GoogleSignIn

@main
struct TaskAppApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(Color(.systemBackground))
        }
    }
}