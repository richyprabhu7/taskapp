import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var authManager: AuthManager
    
    @State private var title = ""
    @State private var selectedPerson = ""
    @State private var availableUsers: [String] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task title", text: $title)
                    
                    Picker("Assign to", selection: $selectedPerson) {
                        ForEach(availableUsers, id: \.self) { user in
                            Text(user).tag(user)
                        }
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addTask()
                    }
                    .disabled(title.isEmpty || selectedPerson.isEmpty)
                }
            }
            .onAppear {
                loadUsers()
            }
        }
    }
    
    private func loadUsers() {
        if let currentUserEmail = authManager.user?.email {
            availableUsers = [currentUserEmail]
            availableUsers.append("sherinjoy9528@gmail.com")
            selectedPerson = currentUserEmail
        }
    }
    
    private func addTask() {
        let assignedToName = selectedPerson.components(separatedBy: "@").first ?? selectedPerson
        
        taskManager.addTask(
            title: title,
            assignedTo: selectedPerson,
            assignedToName: assignedToName
        )
        
        dismiss()
    }
}