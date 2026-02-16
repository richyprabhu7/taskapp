# Task App (Web)

Web version of the **couples task manager** — same Firebase backend as the iOS app. Sign in with Google, invite your partner by email, manage tasks with due dates and categories, and track points. Data is shared with the iOS app when both use the same Firebase project.

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

1. **From the repo root** (or wherever `taskapp-web` lives):
   ```bash
   cd taskapp-web
   ```

2. **Firebase**: Use the **same** Firebase project as your iOS app. In [Firebase Console](https://console.firebase.google.com/) → Project settings → Your apps → **Add app** → Web (</>). Copy the `firebaseConfig` values.

3. **Environment**:
   ```bash
   cp .env.example .env
   ```
   Fill `.env` with your **web app** config (variable names must start with `VITE_`):
   ```env
   VITE_FIREBASE_API_KEY=...
   VITE_FIREBASE_AUTH_DOMAIN=...
   VITE_FIREBASE_PROJECT_ID=...
   VITE_FIREBASE_STORAGE_BUCKET=...
   VITE_FIREBASE_MESSAGING_SENDER_ID=...
   VITE_FIREBASE_APP_ID=...
   ```
   No spaces around `=`, no quotes unless the value contains spaces.

4. **Install and run**:
   ```bash
   npm install
   npm run dev
   ```
   Open the URL shown (e.g. http://localhost:5173). Restart the dev server after changing `.env`.

5. **Authorized domains**: Firebase Console → Authentication → Settings → **Authorized domains** → add `localhost` (and your production domain when you deploy). Without this, Google Sign-In will fail.

## Scripts

| Command        | Description              |
|----------------|--------------------------|
| `npm run dev`  | Start dev server         |
| `npm run build`| Production build to `dist/` |
| `npm run preview` | Serve the production build locally |

## Separate repo (optional)

You can keep `taskapp-web` in this repo (monorepo) or move it to its own repo:

- **Same repo**: It lives under `taskapp-web/` here; no extra steps.
- **New repo**: Copy the `taskapp-web` folder elsewhere, then:
  ```bash
  cd taskapp-web
  git init
  git add .
  git commit -m "Initial web app"
  git remote add origin https://github.com/YOUR_USERNAME/taskapp-web.git
  git push -u origin main
  ```

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
