# Task App

A couples-focused task manager: **iOS app** (SwiftUI) and **web app** (React + Vite). Share tasks with your partner, organise by date and category, and earn points for getting things done. Both apps use the same Firebase project and share data.

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

- **iOS**: SwiftUI, Firebase (Auth + Firestore), Google Sign-In
- **Web**: React 18, TypeScript, Vite, Tailwind CSS, Firebase (Auth + Firestore)

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

- **taskapp/** — iOS app (SwiftUI)
  - App, Auth, Partner, Tasks, Categories, Calendar, Points, Notifications (see source files)
- **taskapp-web/** — Web app (React + Vite)
  - See [taskapp-web/README.md](taskapp-web/README.md) for setup and run instructions (`npm install`, `npm run dev`).

## License

Private / use as you like.
