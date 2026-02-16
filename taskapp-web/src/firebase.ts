import { initializeApp, type FirebaseApp } from 'firebase/app'
import { getAuth, GoogleAuthProvider, type Auth } from 'firebase/auth'
import { getFirestore, type Firestore } from 'firebase/firestore'

const env = import.meta.env
const hasConfig =
  typeof env.VITE_FIREBASE_PROJECT_ID === 'string' &&
  env.VITE_FIREBASE_PROJECT_ID.length > 0 &&
  typeof env.VITE_FIREBASE_API_KEY === 'string' &&
  env.VITE_FIREBASE_API_KEY.length > 0

let app: FirebaseApp | null = null
let _auth: Auth | null = null
let _db: Firestore | null = null

if (hasConfig) {
  try {
    app = initializeApp({
      apiKey: env.VITE_FIREBASE_API_KEY,
      authDomain: env.VITE_FIREBASE_AUTH_DOMAIN,
      projectId: env.VITE_FIREBASE_PROJECT_ID,
      storageBucket: env.VITE_FIREBASE_STORAGE_BUCKET,
      messagingSenderId: env.VITE_FIREBASE_MESSAGING_SENDER_ID,
      appId: env.VITE_FIREBASE_APP_ID,
    })
    _auth = getAuth(app)
    _db = getFirestore(app)
  } catch (e) {
    console.error('Firebase init failed:', e)
  }
}

export const isFirebaseConfigured = Boolean(_auth && _db)
export const auth = _auth!
export const db = _db!
export const googleProvider = new GoogleAuthProvider()
