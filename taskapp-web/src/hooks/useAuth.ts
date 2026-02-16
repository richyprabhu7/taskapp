import { useState, useEffect } from 'react'
import {
  onAuthStateChanged,
  signInWithPopup,
  signOut as fbSignOut,
  type User,
} from 'firebase/auth'
import { doc, setDoc } from 'firebase/firestore'
import { auth, db, googleProvider } from '../firebase'

export function useAuth() {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  const [authError, setAuthError] = useState<string | null>(null)

  useEffect(() => {
    const unsub = onAuthStateChanged(auth, (u) => {
      setUser(u ?? null)
      setLoading(false)
    })
    return unsub
  }, [])

  async function signInWithGoogle() {
    setAuthError(null)
    try {
      const result = await signInWithPopup(auth, googleProvider)
      const u = result.user
      await setDoc(
        doc(db, 'users', u.uid),
        {
          userId: u.uid,
          email: u.email ?? '',
          displayName: u.displayName ?? '',
          photoURL: u.photoURL ?? '',
        },
        { merge: true }
      )
      return u
    } catch (err: unknown) {
      const code = err && typeof err === 'object' && 'code' in err ? (err as { code: string }).code : ''
      const message = err && typeof err === 'object' && 'message' in err ? (err as { message: string }).message : String(err)
      if (code === 'auth/unauthorized-domain') {
        setAuthError('This domain is not allowed. In Firebase Console go to Authentication → Settings → Authorized domains and add "localhost".')
      } else if (code === 'auth/popup-closed-by-user') {
        setAuthError('Sign-in was cancelled.')
      } else {
        setAuthError(message || 'Sign-in failed. Try again.')
      }
      throw err
    }
  }

  async function signOut() {
    await fbSignOut(auth)
  }

  return { user, loading, authError, setAuthError, signInWithGoogle, signOut }
}
