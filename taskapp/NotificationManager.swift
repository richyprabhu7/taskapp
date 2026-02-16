import Foundation
import UserNotifications

/// Sends daily reminders at 9am and 9pm for tasks due today and the next day.
final class NotificationManager {
    static let shared = NotificationManager()
    
    private let center = UNUserNotificationCenter.current()
    private let reminderIdentifierPrefix = "taskapp.reminder."
    
    private init() {}
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }
    
    /// Reschedule 9am and 9pm reminders with current task counts. Call when app enters foreground or tasks change.
    func scheduleTaskReminders(tasks: [Task]) {
        center.getNotificationSettings { [weak self] settings in
            guard settings.authorizationStatus == .authorized else { return }
            self?.scheduleReminders(tasks: tasks)
        }
    }
    
    private func scheduleReminders(tasks: [Task]) {
        center.removePendingNotificationRequests(withIdentifiers: ["taskapp.reminder.9am", "taskapp.reminder.9pm"])
        
        let calendar = Calendar.current
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        let tomorrowStart = calendar.date(byAdding: .day, value: 1, to: todayStart) ?? todayStart
        
        let dueToday = tasks.filter { !$0.isCompleted && calendar.isDate($0.dayDate, inSameDayAs: todayStart) }
        let dueTomorrow = tasks.filter { !$0.isCompleted && calendar.isDate($0.dayDate, inSameDayAs: tomorrowStart) }
        
        let body9am = reminderBody(today: dueToday, tomorrow: dueTomorrow, isMorning: true)
        let body9pm = reminderBody(today: dueToday, tomorrow: dueTomorrow, isMorning: false)
        
        // 9:00 AM daily
        var comp9 = DateComponents()
        comp9.hour = 9
        comp9.minute = 0
        let trigger9am = UNCalendarNotificationTrigger(dateMatching: comp9, repeats: true)
        let content9am = UNMutableNotificationContent()
        content9am.title = "Tasks reminder"
        content9am.body = body9am
        content9am.sound = .default
        let request9am = UNNotificationRequest(identifier: "taskapp.reminder.9am", content: content9am, trigger: trigger9am)
        center.add(request9am)
        
        // 9:00 PM daily
        var comp21 = DateComponents()
        comp21.hour = 21
        comp21.minute = 0
        let trigger9pm = UNCalendarNotificationTrigger(dateMatching: comp21, repeats: true)
        let content9pm = UNMutableNotificationContent()
        content9pm.title = "Tasks reminder"
        content9pm.body = body9pm
        content9pm.sound = .default
        let request9pm = UNNotificationRequest(identifier: "taskapp.reminder.9pm", content: content9pm, trigger: trigger9pm)
        center.add(request9pm)
    }
    
    private func reminderBody(today: [Task], tomorrow: [Task], isMorning: Bool) -> String {
        if today.isEmpty && tomorrow.isEmpty {
            return "No tasks due today or tomorrow."
        }
        var parts: [String] = []
        if !today.isEmpty {
            parts.append("\(today.count) due today")
        }
        if !tomorrow.isEmpty {
            parts.append("\(tomorrow.count) due tomorrow")
        }
        return parts.joined(separator: ", ") + "."
    }
}
