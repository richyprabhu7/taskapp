# Task App (Web)

Web version of the **couples task manager** — same Firebase backend as the iOS app. Sign in with Google, invite your partner by email, manage tasks with due dates and categories, and track points.

## Features

- **Google Sign-In** (Firebase Auth)
- **Partner**: Invite by email; when they sign in with that email, you’re connected
- **Tasks**: Title, assign to (you or partner), due date, category
- **List view**: Grouped by date (Today / Tomorrow / date) then by category
- **Filters**: Status (All / To Do / Done), Assignee
- **Categories**: Add/delete; assign when creating a task
- **Points**: +1 for creating a task for others, +2 for self, +5 on complete; weekly comparison with partner
- **Friday winner**: Once per week on Friday, a popup shows who’s ahead

## Tech stack

- **React 18** + **TypeScript**
- **Vite**
- **Tailwind CSS**
- **Firebase** (Auth + Firestore) — same project as the iOS app

## Setup

1. **Clone or copy this folder** (e.g. into a new repo):
   ```bash
   # If you want a separate repo: copy taskapp-web out, then:
   cd taskapp-web
   git init
   git remote add origin https://github.com/YOUR_USERNAME/taskapp-web.git
   ```

2. **Firebase**: Use the **same** Firebase project as your iOS app. In [Firebase Console](https://console.firebase.google.com/) → Project settings → Your apps → **Add app** → Web (</>). Copy the `firebaseConfig` values.

3. **Env**:
   ```bash
   cp .env.example .env
   ```
   Fill `.env` with your web app config:
   ```env
   VITE_FIREBASE_API_KEY=...
   VITE_FIREBASE_AUTH_DOMAIN=...
   VITE_FIREBASE_PROJECT_ID=...
   VITE_FIREBASE_STORAGE_BUCKET=...
   VITE_FIREBASE_MESSAGING_SENDER_ID=...
   VITE_FIREBASE_APP_ID=...
   ```

4. **Install and run**:
   ```bash
   npm install
   npm run dev
   ```
   Open the URL shown (e.g. http://localhost:5173).

5. **Auth domain**: In Firebase Console → Authentication → Sign-in method → Authorized domains, add `localhost` (and your production domain when you deploy).

## Separate GitHub repo

This app is meant to live in its **own repo** and folder:

- **Folder**: Keep `taskapp-web` as a standalone project (e.g. `~/Documents/taskapp-web`).
- **Git**: From inside `taskapp-web`, run:
  ```bash
  git init
  git add .
  git commit -m "Initial web app"
  git remote add origin https://github.com/YOUR_USERNAME/taskapp-web.git
  git push -u origin main
  ```
- Use a **new** GitHub repo (e.g. `taskapp-web`); do not push this code into the same repo as the iOS app unless you want a monorepo.

## Project structure

```
taskapp-web/
  src/
    components/   # Login, TaskList, AddTask, PartnerView, CategoriesView, TaskRow, PointsBanner, FridayWinner
    hooks/        # useAuth, usePartner, useTasks, useCategories, usePoints
    types/        # task, user (Task, TaskCategory, PartnerInvite, etc.)
    firebase.ts   # init and exports (auth, db, googleProvider)
    App.tsx
    main.tsx
    index.css
  .env.example
  package.json
  vite.config.ts
  tailwind.config.js
```

## Firestore

Same collections as the iOS app:

- `users/{uid}` — profile, `partnerId`, `totalPoints`, `weeklyPoints`
- `users/{uid}/categories` — category docs
- `tasks` — task docs (title, assignedTo, dueDate, categoryId, etc.)
- `invites` — partner invites (fromUserId, toEmail, …)

The web app and iOS app share data when using the same Firebase project.
