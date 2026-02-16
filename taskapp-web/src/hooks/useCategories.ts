import { useState, useEffect } from 'react'
import {
  collection,
  addDoc,
  deleteDoc,
  doc,
  onSnapshot,
  orderBy,
  query,
  type Unsubscribe,
} from 'firebase/firestore'
import { auth, db } from '../firebase'
import type { TaskCategory } from '../types/user'

export function useCategories() {
  const [categories, setCategories] = useState<TaskCategory[]>([])
  const uid = auth.currentUser?.uid ?? null

  useEffect(() => {
    if (!uid) return
    const path = `users/${uid}/categories`
    const q = query(
      collection(db, path),
      orderBy('name', 'asc')
    )
    const unsub: Unsubscribe = onSnapshot(q, (snap) => {
      const list = snap.docs.map((d) => ({
        id: d.id,
        name: (d.data().name as string) ?? '',
        colorHex: (d.data().colorHex as string) ?? null,
        order: (d.data().order as number) ?? null,
      }))
      setCategories(list)
    })
    return () => unsub()
  }, [uid])

  async function addCategory(name: string) {
    const trimmed = name.trim()
    if (!uid || !trimmed) return
    const path = `users/${uid}/categories`
    await addDoc(collection(db, path), {
      name: trimmed,
      order: categories.length,
    })
  }

  async function deleteCategory(cat: TaskCategory) {
    if (!uid || !cat.id) return
    const path = `users/${uid}/categories`
    await deleteDoc(doc(db, path, cat.id))
  }

  return { categories, addCategory, deleteCategory }
}
