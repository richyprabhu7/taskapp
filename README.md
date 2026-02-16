# Task App

A couples-focused task manager for iOS built with SwiftUI. Share tasks with your partner, organise by date and category, and earn points for getting things done.

## Features

- **Google Sign-In** — Sign in with your Google account.
- **Partner connection** — Invite your partner by email; when they install the app and sign in with that email, you’re connected. Assign tasks to yourself or your partner.
- **Tasks** — Create tasks with a title, due date, category, and assignee. Every task has a required due date.
- **List & calendar views** — View tasks in a list (grouped by date, then category) or in a calendar. Default sort is **upcoming first** (today, then tomorrow, then later).
- **Categories** — Create categories (e.g. Work, Personal, Cleaning) and assign them when creating a task or later from the home screen for uncategorized tasks.
- **Filters** — Filter by status (All / To Do / Done) and by assignee (All / you / partner).
- **Due today** — Tasks due today are highlighted with an orange “Today” badge and background.
- **Points** — Create a task for someone else: 1 point. Create a task for yourself: 2 points. Complete a task: 5 points. Points are shown in a banner and used for a weekly “Friday winner” popup.
- **Notifications** — Daily reminders at 9:00 and 9:00 PM for tasks due today and tomorrow (with permission).

## Tech stack

- **SwiftUI** — UI
- **Firebase** — Auth, Firestore
- **Google Sign-In (iOS)** — Sign-in with Google

## Requirements

- Xcode 26+
- iOS 17+
- A Firebase project with Authentication (Google) and Firestore enabled
- A Google Sign-In client ID and `GoogleService-Info.plist` in the app (see Setup)

## Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/richyprabhu7/taskapp.git
   cd taskapp
   ```

2. **Firebase**
   - Create a project at [Firebase Console](https://console.firebase.google.com).
   - Add an iOS app with bundle ID `rs.taskapp` (or match your Xcode bundle ID).
   - Enable **Authentication** → **Google**.
   - Enable **Firestore** and set security rules as needed for your app.

3. **GoogleService-Info.plist**
   - Download `GoogleService-Info.plist` from the Firebase project settings.
   - Place it in the `taskapp/taskapp/` folder (same level as `ContentView.swift`).
   - The file is listed in `.gitignore`; do not commit it if it contains secrets.

4. **Open in Xcode**
   - Open `taskapp.xcodeproj` in Xcode.
   - Resolve Swift packages (File → Packages → Resolve Package Versions).
   - Build and run on a simulator or device.

## Project structure

- **App** — `taskappApp.swift`, `ContentView.swift`
- **Auth** — `AuthManager.swift`, `LoginView.swift`
- **Partner** — `PartnerManager.swift`, `PartnerView.swift`, `PartnerInvite.swift`
- **Tasks** — `Task.swift`, `TaskManager.swift`, `AddTaskView.swift`, `CreateTaskListView.swift`, `TaskRowView`, `TaskFilters.swift`
- **Categories** — `Category.swift`, `CategoriesManager.swift`, `CategoriesListViewModel.swift`
- **Calendar** — `CalendarTasksView.swift`
- **Points** — `PointsManager.swift`
- **Notifications** — `NotificationManager.swift`

## License

Private / use as you like.
