import SwiftUI
import Combine
import GoogleSignInSwift

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "checklist")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("Task Manager")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Manage tasks together")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            GoogleSignInButton(action: {
                authManager.signInWithGoogle()
            })
            .frame(width: 280, height: 50)
            
            Spacer()
        }
        .padding()
    }
}