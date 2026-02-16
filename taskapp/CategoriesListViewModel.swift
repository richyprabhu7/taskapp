import SwiftUI
import Combine

struct CategoriesListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var categoriesManager: CategoriesManager
    
    @State private var newCategoryName = ""
    @State private var showingAdd = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Task categories")) {
                    Text("Create categories to organize tasks (e.g. Work, Personal). You can pick a category when adding a task.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Section(header: Text("Your categories")) {
                    ForEach(categoriesManager.categories) { category in
                        HStack {
                            Text(category.name)
                            Spacer()
                            Button(role: .destructive) {
                                categoriesManager.deleteCategory(category)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                addCategorySheet
            }
        }
    }
    
    private var addCategorySheet: some View {
        NavigationView {
            Form {
                TextField("Category name", text: $newCategoryName)
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingAdd = false
                        newCategoryName = ""
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if !newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty {
                            categoriesManager.addCategory(name: newCategoryName)
                            showingAdd = false
                            newCategoryName = ""
                        }
                    }
                    .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
