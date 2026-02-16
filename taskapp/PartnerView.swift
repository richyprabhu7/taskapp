import SwiftUI
import Combine
import FirebaseAuth

/// Invite your partner/spouse by email. When they download the app and sign in, the connection is created.
struct PartnerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var partnerManager: PartnerManager
    @EnvironmentObject var authManager: AuthManager
    
    @State private var inviteEmail = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("Invite your partner or spouse by email. They'll get the invite when they download the app and sign in with that email—then you're connected.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let partnerId = partnerManager.partnerId, partnerManager.partnerDisplayName != nil {
                    Section(header: Text("Connected")) {
                        HStack {
                            Image(systemName: "heart.circle.fill")
                                .foregroundColor(.pink)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(partnerManager.partnerDisplayName ?? "Partner")
                                    .font(.body)
                                if let email = partnerManager.partnerEmail, !email.isEmpty {
                                    Text(email)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                } else if let invite = partnerManager.sentInvite {
                    Section(header: Text("Invite sent")) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Waiting for \(invite.toEmail) to join")
                                    .font(.body)
                                Text("They'll be connected when they sign in with this email.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("Cancel invite", role: .destructive) {
                                partnerManager.cancelInvite()
                            }
                            .font(.caption)
                        }
                    }
                } else {
                    Section(header: Text("Invite partner")) {
                        TextField("Partner's email", text: $inviteEmail)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        Button(action: sendInvite) {
                            Label("Send invite", systemImage: "paperplane.fill")
                        }
                        .disabled(inviteEmail.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .navigationTitle("Partner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                partnerManager.fetchPartnerProfile()
            }
        }
    }
    
    private func sendInvite() {
        let email = inviteEmail.trimmingCharacters(in: .whitespaces)
        guard !email.isEmpty else { return }
        partnerManager.sendInvite(toEmail: email)
        inviteEmail = ""
        dismiss()
    }
}
