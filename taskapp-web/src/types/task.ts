import type { Timestamp } from 'firebase/firestore'

export interface Task {
  id?: string
  title: string
  assignedTo: string
  assignedToName: string
  isCompleted: boolean
  createdAt: Timestamp | Date
  createdBy: string
  dueDate?: Timestamp | Date | null
  categoryId?: string | null
  categoryName?: string | null
}

export function taskDayDate(task: Task): Date {
  const d = task.dueDate
  if (d && (d instanceof Date || (typeof (d as Timestamp).toDate === 'function'))) {
    return d instanceof Date ? d : (d as Timestamp).toDate()
  }
  const c = task.createdAt
  return c instanceof Date ? c : (c as Timestamp).toDate()
}

export type TaskStatusFilter = 'all' | 'toDo' | 'done'

export function statusIncludes(filter: TaskStatusFilter, task: Task): boolean {
  if (filter === 'all') return true
  if (filter === 'toDo') return !task.isCompleted
  return task.isCompleted
}
