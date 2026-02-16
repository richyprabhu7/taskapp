import SwiftUI
import Combine
import FirebaseAuth

struct AssignablePerson: Identifiable {
    let id: String
    let email: String
    let displayName: String
}

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var partnerManager: PartnerManager
    @EnvironmentObject var categoriesManager: CategoriesManager
    
    @State private var title = ""
    @State private var selectedPersonId = ""
    @State private var selectedCategoryId: String = ""
    @State private var dueDate = Date()
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    
    private var assignablePeople: [AssignablePerson] {
        var list: [AssignablePerson] = []
        if let user = authManager.user {
            let email = user.email ?? ""
            let name = user.displayName?.isEmpty == false ? user.displayName! : (email.components(separatedBy: "@").first ?? email)
            list.append(AssignablePerson(id: email, email: email, displayName: name))
        }
        if let partnerEmail = partnerManager.partnerEmail {
            let partnerName = partnerManager.partnerDisplayName ?? partnerEmail
            if !list.contains(where: { $0.email == partnerEmail }) {
                list.append(AssignablePerson(id: partnerEmail, email: partnerEmail, displayName: partnerName))
            }
        }
        return list
    }
    
    private var selectedPerson: AssignablePerson? {
        assignablePeople.first { $0.id == selectedPersonId }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task title", text: $title)
                    
                    Picker("Assign to", selection: $selectedPersonId) {
                        Text("Select…").tag("")
                        ForEach(assignablePeople) { person in
                            Text(person.displayName).tag(person.id)
                        }
                    }
                    .onAppear {
                        if selectedPersonId.isEmpty, let first = assignablePeople.first {
                            selectedPersonId = first.id
                        }
                    }
                    
                    Picker("Category", selection: $selectedCategoryId) {
                        Text("None").tag("")
                        ForEach(categoriesManager.categories) { cat in
                            Text(cat.name).tag(cat.id ?? "cat-\(cat.name)")
                        }
                    }
                    
                    Button(action: { showingAddCategory = true }) {
                        Label("Add new category", systemImage: "plus.circle")
                    }
                    if showingAddCategory {
                        HStack {
                            TextField("Category name", text: $newCategoryName)
                            Button("Add") {
                                let name = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !name.isEmpty {
                                    categoriesManager.addCategory(name: name)
                                    newCategoryName = ""
                                    showingAddCategory = false
                                }
                            }
                            .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                    
                    DatePicker("Due date", selection: $dueDate, displayedComponents: .date)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") { addTask() }
                        .disabled(title.isEmpty || selectedPersonId.isEmpty)
                }
            }
        }
    }
    
    private func addTask() {
        guard let person = selectedPerson else { return }
        let category = selectedCategoryId.isEmpty ? nil : categoriesManager.categories.first { $0.id == selectedCategoryId }
        
        taskManager.addTask(
            title: title,
            assignedTo: person.email,
            assignedToName: person.displayName,
            dueDate: dueDate,
            categoryId: category?.id,
            categoryName: category?.name
        )
        dismiss()
    }
}