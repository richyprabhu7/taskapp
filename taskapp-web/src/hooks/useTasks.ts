import { useState, useEffect } from 'react'
import {
  collection,
  addDoc,
  updateDoc,
  doc,
  onSnapshot,
  orderBy,
  query,
  serverTimestamp,
  Timestamp,
  type Unsubscribe,
} from 'firebase/firestore'
import { auth, db } from '../firebase'
import type { Task } from '../types/task'
import { taskDayDate } from '../types/task'
import { awardForCreate, awardForComplete } from './usePoints'

function parseTask(docId: string, data: Record<string, unknown>): Task {
  const toDate = (v: unknown): Date | undefined => {
    if (v instanceof Date) return v
    if (v && typeof (v as Timestamp).toDate === 'function') return (v as Timestamp).toDate()
    return undefined
  }
  const createdAt = data.createdAt
  const createdDate =
    createdAt instanceof Date
      ? createdAt
      : createdAt && typeof (createdAt as Timestamp).toDate === 'function'
        ? (createdAt as Timestamp).toDate()
        : new Date()
  // Support both 'title' and 'Title' (some clients may use different casing)
  const rawTitle = data.title ?? data.Title
  const title = typeof rawTitle === 'string' ? rawTitle.trim() : ''
  return {
    id: docId,
    title: title || '(No title)',
    assignedTo: (data.assignedTo as string) ?? '',
    assignedToName: (data.assignedToName as string) ?? '',
    isCompleted: (data.isCompleted as boolean) ?? false,
    createdAt: createdDate,
    createdBy: (data.createdBy as string) ?? '',
    dueDate: data.dueDate ? toDate(data.dueDate) ?? null : null,
    categoryId: (data.categoryId as string) ?? null,
    categoryName: (data.categoryName as string) ?? null,
  }
}

export function useTasks() {
  const [tasks, setTasks] = useState<Task[]>([])

  useEffect(() => {
    const q = query(
      collection(db, 'tasks'),
      orderBy('createdAt', 'desc')
    )
    const unsub: Unsubscribe = onSnapshot(q, (snap) => {
      const list = snap.docs.map((d) => parseTask(d.id, d.data() as Record<string, unknown>))
      setTasks(list)
    })
    return () => unsub()
  }, [])

  async function addTask(
    title: string,
    assignedTo: string,
    assignedToName: string,
    dueDate: Date,
    categoryId: string | null,
    categoryName: string | null
  ) {
    const userId = auth.currentUser?.uid
    const currentEmail = auth.currentUser?.email ?? ''
    if (!userId) return
    const ref = await addDoc(collection(db, 'tasks'), {
      title: title.trim() || '(No title)',
      assignedTo,
      assignedToName,
      isCompleted: false,
      createdAt: serverTimestamp(),
      createdBy: userId,
      dueDate: Timestamp.fromDate(dueDate),
      categoryId: categoryId ?? null,
      categoryName: categoryName ?? null,
    })
    awardForCreate(userId, assignedTo, currentEmail)
    return ref.id
  }

  async function toggleCompletion(task: Task) {
    if (!task.id) return
    const userId = auth.currentUser?.uid
    if (!userId) return
    const newCompleted = !task.isCompleted
    await updateDoc(doc(db, 'tasks', task.id), { isCompleted: newCompleted })
    if (newCompleted) awardForComplete(userId)
  }

  async function updateTaskCategory(taskId: string, categoryId: string | null, categoryName: string | null) {
    await updateDoc(doc(db, 'tasks', taskId), {
      categoryId: categoryId ?? null,
      categoryName: categoryName ?? null,
    })
  }

  function tasksGroupedByDayAndCategory(
    taskList: Task[]
  ): Array<{ date: Date; categories: Array<{ name: string; tasks: Task[] }> }> {
    const byDay = new Map<string, Task[]>()
    for (const t of taskList) {
      const d = taskDayDate(t)
      const start = new Date(d)
      start.setHours(0, 0, 0, 0)
      const key = start.getTime().toString()
      if (!byDay.has(key)) byDay.set(key, [])
      byDay.get(key)!.push(t)
    }
    const result: Array<{ date: Date; categories: Array<{ name: string; tasks: Task[] }> }> = []
    const sortedDays = Array.from(byDay.entries()).sort((a, b) => Number(a[0]) - Number(b[0]))
    for (const [timeStr, dayTasks] of sortedDays) {
      const date = new Date(Number(timeStr))
      const byCat = new Map<string, Task[]>()
      for (const t of dayTasks) {
        const name = (t.categoryName?.trim() && t.categoryName) ? t.categoryName : 'Uncategorized'
        if (!byCat.has(name)) byCat.set(name, [])
        byCat.get(name)!.push(t)
      }
      const uncat = byCat.get('Uncategorized') ?? []
      byCat.delete('Uncategorized')
      const sortedCats = Array.from(byCat.entries()).sort((a, b) => a[0].localeCompare(b[0]))
      const categories: Array<{ name: string; tasks: Task[] }> = [
        ...sortedCats.map(([name, tasks]) => ({
          name,
          tasks: tasks.sort(
            (a, b) =>
              (taskDayDate(a).getTime() ?? 0) - (taskDayDate(b).getTime() ?? 0)
          ),
        })),
        ...(uncat.length ? [{ name: 'Uncategorized' as const, tasks: uncat.sort((a, b) => taskDayDate(a).getTime() - taskDayDate(b).getTime()) }] : []),
      ]
      result.push({ date, categories })
    }
    return result
  }

  return {
    tasks,
    addTask,
    toggleCompletion,
    updateTaskCategory,
    tasksGroupedByDayAndCategory,
    taskDayDate,
  }
}
