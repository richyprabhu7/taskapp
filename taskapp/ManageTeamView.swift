import SwiftUI
import Combine
import FirebaseAuth

struct ManageTeamView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var contactsManager: ContactsManager
    @EnvironmentObject var authManager: AuthManager
    
    @State private var showingAddContact = false
    @State private var newEmail = ""
    @State private var newDisplayName = ""
    
    /// Current user + contacts for "assign to" list. Current user first, then contacts.
    private var assignablePeople: [(email: String, displayName: String)] {
        var list: [(email: String, displayName: String)] = []
        if let user = authManager.user {
            let email = user.email ?? ""
            let name = user.displayName?.isEmpty == false ? user.displayName! : (email.components(separatedBy: "@").first ?? email)
            list.append((email, name))
        }
        list += contactsManager.contacts.map { ($0.email, $0.displayName) }
        return list
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("Add people you want to assign tasks to. They'll appear in the \"Assign to\" list when creating tasks.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("You & team")) {
                    ForEach(assignablePeople, id: \.email) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.displayName)
                                    .font(.body)
                                Text(item.email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if item.email != authManager.user?.email {
                                Button(role: .destructive) {
                                    if let c = contactsManager.contacts.first(where: { $0.email == item.email }) {
                                        contactsManager.removeContact(c)
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Manage Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddContact = true }) {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddContact) {
                addContactSheet
            }
        }
    }
    
    private var addContactSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("New contact")) {
                    TextField("Display name", text: $newDisplayName)
                        .textContentType(.name)
                    TextField("Email", text: $newEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Add Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingAddContact = false
                        newEmail = ""
                        newDisplayName = ""
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if !newEmail.isEmpty {
                            contactsManager.addContact(email: newEmail, displayName: newDisplayName.isEmpty ? newEmail : newDisplayName)
                            showingAddContact = false
                            newEmail = ""
                            newDisplayName = ""
                        }
                    }
                    .disabled(newEmail.isEmpty)
                }
            }
        }
    }
}
