import SwiftUI
import Combine

enum TaskViewMode: String, CaseIterable {
    case list = "List"
    case calendar = "Calendar"
}

struct CalendarTasksView: View {
    var tasks: [Task]
    @EnvironmentObject var taskManager: TaskManager
    @Binding var selectedDate: Date
    @Binding var viewMode: TaskViewMode
    
    private let calendar = Calendar.current
    private let daysInWeek = 7
    
    var body: some View {
        VStack(spacing: 0) {
            // Month navigation
            HStack {
                Button(action: { selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthYearString(selectedDate))
                    .font(.headline)
                Spacer()
                Button(action: { selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(shortWeekdaySymbols(), id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: daysInWeek), spacing: 4) {
                ForEach(Array(daysInMonth().enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        dayCell(for: date)
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Tasks for selected day
            dayTasksView
        }
        .background(Color(.systemBackground))
    }
    
    private func dayCell(for date: Date) -> some View {
        let startOfDay = calendar.startOfDay(for: date)
        let count = tasks.filter { calendar.isDate($0.dayDate, inSameDayAs: date) }.count
        let isSelected = calendar.isDate(startOfDay, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        
        return Button(action: { selectedDate = startOfDay }) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(isSelected ? .white : (isToday ? .accentColor : .primary))
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : (isToday ? Color.accentColor.opacity(0.15) : Color.clear))
            )
        }
        .buttonStyle(.plain)
    }
    
    private var dayTasksView: some View {
        let dayStart = calendar.startOfDay(for: selectedDate)
        let dayTasks = tasks
            .filter { calendar.isDate($0.dayDate, inSameDayAs: selectedDate) }
            .sorted { ($0.dueDate ?? $0.createdAt) > ($1.dueDate ?? $1.createdAt) }
        
        return Group {
            if dayTasks.isEmpty {
                Text("No tasks for \(shortDateString(selectedDate))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else {
                List(dayTasks) { task in
                    TaskRowView(task: task)
                        .environmentObject(taskManager)
                }
                .listStyle(.plain)
            }
        }
    }
    
    private func monthYearString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func shortDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func shortWeekdaySymbols() -> [String] {
        calendar.shortWeekdaySymbols
    }
    
    private func daysInMonth() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedDate),
              let first = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)) else {
            return []
        }
        let firstWeekday = calendar.component(.weekday, from: first)
        let leadingBlanks = (firstWeekday - calendar.firstWeekday + 7) % 7
        var days: [Date?] = (0..<leadingBlanks).map { _ in nil }
        for day in range {
            if let d = calendar.date(byAdding: .day, value: day - 1, to: first) {
                days.append(d)
            }
        }
        return days
    }
}
