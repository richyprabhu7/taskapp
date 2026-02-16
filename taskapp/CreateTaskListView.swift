import SwiftUI
import Combine
import FirebaseAuth

struct TaskListView: View {
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var partnerManager: PartnerManager
    @EnvironmentObject var categoriesManager: CategoriesManager
    
    @State private var showingAddTask = false
    @State private var showingPartner = false
    @State private var showingCategories = false
    @State private var viewMode: TaskViewMode = .list
    @State private var selectedCalendarDate = Date()
    @State private var statusFilter: TaskStatusFilter = .toDo
    @State private var assigneeFilterEmail: String = ""
    @State private var showingFridayWinner = false
    
    private var assignablePeople: [(email: String, displayName: String)] {
        var list: [(email: String, displayName: String)] = [("", "All")]
        if let user = authManager.user {
            let email = user.email ?? ""
            let name = user.displayName?.isEmpty == false ? user.displayName! : (email.components(separatedBy: "@").first ?? email)
            list.append((email, name))
        }
        if let partnerEmail = partnerManager.partnerEmail, let partnerName = partnerManager.partnerDisplayName ?? partnerManager.partnerEmail {
            if !list.contains(where: { $0.email == partnerEmail }) {
                list.append((partnerEmail, partnerName))
            }
        }
        return list
    }
    
    private var filteredTasks: [Task] {
        var list = taskManager.tasks.filter { statusFilter.includes($0) }
        if !assigneeFilterEmail.isEmpty {
            list = list.filter { $0.assignedTo == assigneeFilterEmail }
        }
        return list.sorted { ($0.dueDate ?? $0.createdAt) < ($1.dueDate ?? $1.createdAt) }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Single-line filter bar
                HStack(spacing: 10) {
                    Menu {
                        Button("List") { viewMode = .list }
                        Button("Calendar") { viewMode = .calendar }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: viewMode == .list ? "list.bullet" : "calendar")
                                .font(.subheadline.weight(.medium))
                            Text(viewMode.rawValue)
                                .font(.subheadline.weight(.medium))
                            Image(systemName: "chevron.down")
                                .font(.caption2.weight(.semibold))
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                    }
                    
                    Picker("Status", selection: $statusFilter) {
                        ForEach(TaskStatusFilter.allCases, id: \.self) { f in
                            Text(f.rawValue).tag(f)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Capsule())
                    
                    if !assignablePeople.isEmpty {
                        Picker("Assignee", selection: $assigneeFilterEmail) {
                            ForEach(assignablePeople, id: \.email) { p in
                                Text(p.displayName).tag(p.email)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                    }
                    
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                
                Divider()
                    .padding(.leading, 16)
                
                // Content below filters
                Group {
                    if filteredTasks.isEmpty && viewMode == .list {
                        emptyState
                    } else if viewMode == .calendar {
                        CalendarTasksView(tasks: filteredTasks, selectedDate: $selectedCalendarDate, viewMode: $viewMode)
                    } else {
                        listViewByDay
                    }
                }
                .navigationTitle("Tasks")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Button(action: { showingPartner = true }) {
                                Label("Partner", systemImage: "heart.circle")
                            }
                            Button(action: { showingCategories = true }) {
                                Label("Categories", systemImage: "folder")
                            }
                            Divider()
                            Button(role: .destructive, action: { authManager.signOut() }) {
                                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.circle")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddTask = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.tint)
                        }
                    }
                }
                
                Spacer(minLength: 0)
                
                // Points banner at bottom
                PointsBannerView()
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
                    .environmentObject(taskManager)
                    .environmentObject(authManager)
                    .environmentObject(partnerManager)
                    .environmentObject(categoriesManager)
            }
            .sheet(isPresented: $showingPartner) {
                PartnerView()
                    .environmentObject(partnerManager)
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showingCategories) {
                CategoriesListView()
                    .environmentObject(categoriesManager)
            }
            .sheet(isPresented: $showingFridayWinner) {
                FridayWinnerView(onDismiss: { showingFridayWinner = false })
            }
            .onAppear {
                if let pid = partnerManager.partnerId {
                    PointsManager.shared.fetchPartnerWeekPoints(partnerId: pid)
                } else {
                    PointsManager.shared.fetchPartnerWeekPoints(partnerId: nil)
                }
                partnerManager.fetchPartnerProfile()
                checkFridayPopup()
                NotificationManager.shared.requestPermission { _ in
                    NotificationManager.shared.scheduleTaskReminders(tasks: taskManager.tasks)
                }
            }
            .onChange(of: taskManager.tasks.count) { _, _ in
                NotificationManager.shared.scheduleTaskReminders(tasks: taskManager.tasks)
            }
        }
    }
    
    private func checkFridayPopup() {
        guard PointsManager.shared.isFriday else { return }
        let key = "lastFridayWinnerWeek"
        let weekId = PointsManager.currentWeekId
        let last = UserDefaults.standard.string(forKey: key) ?? ""
        if weekId != last {
            UserDefaults.standard.set(weekId, forKey: key)
            showingFridayWinner = true
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 28) {
            Image(systemName: "checklist")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("No tasks yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Text("Tap + to add your first task")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button(action: { showingAddTask = true }) {
                Label("Add Task", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var listViewByDay: some View {
        let grouped = taskManager.tasksGroupedByDayAndCategory(from: filteredTasks)
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        
        return List {
            ForEach(grouped, id: \.date) { dayGroup in
                Section(header: dateSectionHeader(dayGroup.date, formatter: formatter, calendar: calendar)) {
                    ForEach(dayGroup.categories, id: \.name) { cat in
                        Section(header: categorySectionHeader(cat.name)) {
                            ForEach(cat.tasks) { task in
                                TaskRowView(task: task, hideCategoryInSubtitle: true)
                                    .environmentObject(taskManager)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func dateSectionHeader(_ date: Date, formatter: DateFormatter, calendar: Calendar) -> some View {
        let label: String = {
            if calendar.isDateInToday(date) { return "Today" }
            if calendar.isDateInTomorrow(date) { return "Tomorrow" }
            return formatter.string(from: date)
        }()
        return HStack(spacing: 8) {
            Image(systemName: calendar.isDateInToday(date) ? "star.circle.fill" : "calendar")
                .font(.body)
                .foregroundColor(calendar.isDateInToday(date) ? .orange : .secondary)
            Text(label)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 6)
    }
    
    private func categorySectionHeader(_ name: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: name == "Uncategorized" ? "tray" : "folder.fill")
                .font(.subheadline)
                .foregroundColor(name == "Uncategorized" ? .secondary : .accentColor)
            Text(name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(name == "Uncategorized" ? .secondary : .primary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
    }
}

// MARK: - Points banner
struct PointsBannerView: View {
    @ObservedObject private var points = PointsManager.shared
    
    var body: some View {
        HStack(spacing: 20) {
            HStack(spacing: 8) {
                Image(systemName: "star.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.yellow)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your points")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(points.currentUserTotalPoints) total · \(points.currentUserWeekPoints) this week")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "heart.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.pink)
                VStack(alignment: .trailing, spacing: 2) {
                    Text(points.partnerName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(points.partnerWeekPoints) this week")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
    }
}

// MARK: - Friday winner popup
struct FridayWinnerView: View {
    var onDismiss: () -> Void
    @ObservedObject private var points = PointsManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            Text("🏆 Friday night winner 🏆")
                .font(.title2)
                .fontWeight(.bold)
            Text(points.weekWinnerText)
                .font(.title3)
            Text("You: \(points.currentUserWeekPoints) pts • \(points.partnerName): \(points.partnerWeekPoints) pts")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button("Done", action: onDismiss)
                .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct TaskRowView: View {
    let task: Task
    var hideCategoryInSubtitle: Bool = false
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var categoriesManager: CategoriesManager
    
    private var isDueToday: Bool {
        Calendar.current.isDateInToday(task.dayDate)
    }
    
    private var isUncategorized: Bool {
        let name = task.categoryName?.trimmingCharacters(in: .whitespaces) ?? ""
        return name.isEmpty
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: {
                taskManager.toggleTaskCompletion(task: task)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(task.title)
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? .gray : .primary)
                        .font(.body)
                    if isDueToday && !task.isCompleted {
                        Text("Today")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .clipShape(Capsule())
                    }
                }
                Text("Assigned to \(task.assignedToName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if !hideCategoryInSubtitle, let name = task.categoryName, !name.isEmpty {
                    Text(name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if isUncategorized {
                    addCategoryMenu
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(isDueToday && !task.isCompleted ? Color.orange.opacity(0.12) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var addCategoryMenu: some View {
        Menu {
            if categoriesManager.categories.isEmpty {
                Text("No categories yet")
                    .disabled(true)
            } else {
                ForEach(categoriesManager.categories) { cat in
                    Button(cat.name) {
                        guard let taskId = task.id else { return }
                        taskManager.updateTaskCategory(taskId: taskId, categoryId: cat.id, categoryName: cat.name)
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "folder.badge.plus")
                    .font(.caption)
                Text("Add category")
                    .font(.caption)
            }
            .foregroundColor(.accentColor)
        }
        .padding(.top, 2)
    }
}