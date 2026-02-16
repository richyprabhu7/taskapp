import { useState, useMemo, useEffect } from 'react'
import { statusIncludes, type TaskStatusFilter } from '../types/task'
import type { Task } from '../types/task'
import type { AssignablePerson } from '../types/user'
import { taskDayDate } from '../types/task'
import { TaskRow } from './TaskRow'
import { PointsBanner } from './PointsBanner'
import { AddTask } from './AddTask'
import { PartnerView } from './PartnerView'
import { CategoriesView } from './CategoriesView'
import { FridayWinner } from './FridayWinner'

function formatDateHeader(date: Date): string {
  const today = new Date()
  const tomorrow = new Date(today)
  tomorrow.setDate(tomorrow.getDate() + 1)
  if (
    date.getFullYear() === today.getFullYear() &&
    date.getMonth() === today.getMonth() &&
    date.getDate() === today.getDate()
  ) {
    return 'Today'
  }
  if (
    date.getFullYear() === tomorrow.getFullYear() &&
    date.getMonth() === tomorrow.getMonth() &&
    date.getDate() === tomorrow.getDate()
  ) {
    return 'Tomorrow'
  }
  return date.toLocaleDateString('en-US', { weekday: 'long', month: 'short', day: 'numeric' })
}

export function TaskList({
  tasks,
  assignablePeople,
  categories,
  partnerEmail,
  partnerDisplayName,
  sentInvite,
  isAcceptingInvite,
  currentUserTotalPoints,
  currentUserWeekPoints,
  partnerWeekPoints,
  partnerName,
  isFriday,
  weekWinnerText,
  currentWeekId,
  onToggleTask,
  onAddTask,
  onAddCategory,
  onDeleteCategory,
  onSendInvite,
  onCancelInvite,
  onSignOut,
}: {
  tasks: Task[]
  assignablePeople: AssignablePerson[]
  categories: Array<{ id?: string; name: string }>
  partnerEmail: string | null
  partnerDisplayName: string | null
  sentInvite: { toEmail: string } | null
  isAcceptingInvite: boolean
  currentUserTotalPoints: number
  currentUserWeekPoints: number
  partnerWeekPoints: number
  partnerName: string
  isFriday: boolean
  weekWinnerText: string
  currentWeekId: string
  onToggleTask: (task: Task) => void
  onAddTask: (params: {
    title: string
    assignedTo: string
    assignedToName: string
    dueDate: Date
    categoryId: string | null
    categoryName: string | null
  }) => Promise<void>
  onAddCategory: (name: string) => void
  onDeleteCategory: (cat: { id?: string; name: string }) => void
  onSendInvite: (email: string) => Promise<void>
  onCancelInvite: () => Promise<void>
  onSignOut: () => void
}) {
  const [viewMode, setViewMode] = useState<'list' | 'calendar'>('list')
  const [statusFilter, setStatusFilter] = useState<TaskStatusFilter>('toDo')
  const [assigneeFilter, setAssigneeFilter] = useState('')
  const [showMenu, setShowMenu] = useState(false)
  const [showAddTask, setShowAddTask] = useState(false)
  const [showPartner, setShowPartner] = useState(false)
  const [showCategories, setShowCategories] = useState(false)
  const [showFridayWinner, setShowFridayWinner] = useState(false)

  const filteredTasks = useMemo(() => {
    let list = tasks.filter((t) => statusIncludes(statusFilter, t))
    if (assigneeFilter) list = list.filter((t) => t.assignedTo === assigneeFilter)
    return list.sort(
      (a, b) => taskDayDate(a).getTime() - taskDayDate(b).getTime()
    )
  }, [tasks, statusFilter, assigneeFilter])

  const grouped = useMemo(() => {
    const byDay = new Map<string, Task[]>()
    for (const t of filteredTasks) {
      const d = taskDayDate(t)
      const start = new Date(d)
      start.setHours(0, 0, 0, 0)
      const key = start.getTime().toString()
      if (!byDay.has(key)) byDay.set(key, [])
      byDay.get(key)!.push(t)
    }
    const result: Array<{
      date: Date
      categories: Array<{ name: string; tasks: Task[] }>
    }> = []
    const sortedDays = Array.from(byDay.entries()).sort((a, b) => Number(a[0]) - Number(b[0]))
    for (const [timeStr, dayTasks] of sortedDays) {
      const date = new Date(Number(timeStr))
      const byCat = new Map<string, Task[]>()
      for (const t of dayTasks) {
        const name =
          t.categoryName?.trim() && t.categoryName ? t.categoryName : 'Uncategorized'
        if (!byCat.has(name)) byCat.set(name, [])
        byCat.get(name)!.push(t)
      }
      const uncat = byCat.get('Uncategorized') ?? []
      byCat.delete('Uncategorized')
      const sortedCats = Array.from(byCat.entries()).sort((a, b) => a[0].localeCompare(b[0]))
      const catList: Array<{ name: string; tasks: Task[] }> = [
        ...sortedCats.map(([name, list]) => ({
          name,
          tasks: list.sort(
            (a, b) => taskDayDate(a).getTime() - taskDayDate(b).getTime()
          ),
        })),
        ...(uncat.length
          ? [
              {
                name: 'Uncategorized' as const,
                tasks: uncat.sort(
                  (a, b) => taskDayDate(a).getTime() - taskDayDate(b).getTime()
                ),
              },
            ]
          : []),
      ]
      result.push({ date, categories: catList })
    }
    return result
  }, [filteredTasks])

  // Friday popup once per week
  useEffect(() => {
    if (!isFriday || !currentWeekId) return
    const last = typeof sessionStorage !== 'undefined' ? sessionStorage.getItem('lastFridayWinnerWeek') : null
    if (last !== currentWeekId) {
      if (typeof sessionStorage !== 'undefined') sessionStorage.setItem('lastFridayWinnerWeek', currentWeekId)
      setShowFridayWinner(true)
    }
  }, [isFriday, currentWeekId])

  return (
    <div className="min-h-screen flex flex-col bg-gray-50 dark:bg-gray-950">
      <header className="sticky top-0 z-10 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800">
        <div className="flex items-center justify-between px-4 py-3">
          <h1 className="text-lg font-semibold text-gray-900 dark:text-gray-100">Tasks</h1>
          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={() => setShowAddTask(true)}
              className="p-2 rounded-full text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800"
              aria-label="Add task"
            >
              <span className="text-xl leading-none">+</span>
            </button>
            <div className="relative">
              <button
                type="button"
                onClick={() => setShowMenu((v) => !v)}
                className="p-2 rounded-full text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800"
                aria-label="Menu"
              >
                ⋮
              </button>
              {showMenu && (
                <>
                  <div
                    className="fixed inset-0 z-10"
                    aria-hidden
                    onClick={() => setShowMenu(false)}
                  />
                  <div className="absolute right-0 mt-1 w-48 rounded-xl bg-white dark:bg-gray-800 shadow-lg border border-gray-200 dark:border-gray-700 py-1 z-20">
                    <button
                      type="button"
                      onClick={() => { setShowPartner(true); setShowMenu(false) }}
                      className="w-full text-left px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700"
                    >
                      Partner
                    </button>
                    <button
                      type="button"
                      onClick={() => { setShowCategories(true); setShowMenu(false) }}
                      className="w-full text-left px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700"
                    >
                      Categories
                    </button>
                    <button
                      type="button"
                      onClick={() => { onSignOut(); setShowMenu(false) }}
                      className="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100 dark:hover:bg-gray-700"
                    >
                      Sign Out
                    </button>
                  </div>
                </>
              )}
            </div>
          </div>
        </div>
        <div className="flex flex-wrap items-center gap-2 px-4 pb-3">
          <select
            value={viewMode}
            onChange={(e) => setViewMode(e.target.value as 'list' | 'calendar')}
            className="rounded-full border border-gray-300 dark:border-gray-600 bg-gray-100 dark:bg-gray-800 px-3 py-1.5 text-sm text-gray-900 dark:text-gray-100"
          >
            <option value="list">List</option>
            <option value="calendar">Calendar</option>
          </select>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value as TaskStatusFilter)}
            className="rounded-full border border-gray-300 dark:border-gray-600 bg-gray-100 dark:bg-gray-800 px-3 py-1.5 text-sm text-gray-900 dark:text-gray-100"
          >
            <option value="all">All</option>
            <option value="toDo">To Do</option>
            <option value="done">Done</option>
          </select>
          <select
            value={assigneeFilter}
            onChange={(e) => setAssigneeFilter(e.target.value)}
            className="rounded-full border border-gray-300 dark:border-gray-600 bg-gray-100 dark:bg-gray-800 px-3 py-1.5 text-sm text-gray-900 dark:text-gray-100"
          >
            <option value="">All</option>
            {assignablePeople.map((p) => (
              <option key={p.id} value={p.email}>
                {p.displayName}
              </option>
            ))}
          </select>
        </div>
      </header>

      <main className="flex-1 overflow-auto pb-20">
        {viewMode === 'calendar' ? (
          <div className="p-4 text-gray-500 text-sm">
            Calendar view: switch to List to see tasks grouped by day. Full calendar grid can be added later.
          </div>
        ) : filteredTasks.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-16 px-4">
            <p className="text-gray-500 mb-4">No tasks yet</p>
            <button
              type="button"
              onClick={() => setShowAddTask(true)}
              className="rounded-xl bg-gray-900 text-white px-6 py-3 font-medium"
            >
              Add Task
            </button>
          </div>
        ) : (
          <div className="p-4 space-y-6">
            {grouped.map(({ date, categories: catGroups }) => (
              <section key={date.getTime()}>
                <h2 className="flex items-center gap-2 text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                  {formatDateHeader(date)}
                </h2>
                <div className="space-y-4">
                  {catGroups.map((cat) => (
                    <div key={cat.name}>
                      <h3 className="text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">
                        {cat.name}
                      </h3>
                      <div className="rounded-xl bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-800 divide-y divide-gray-100 dark:divide-gray-800">
                        {cat.tasks.map((task) => (
                          <TaskRow
                            key={task.id}
                            task={task}
                            onToggle={() => onToggleTask(task)}
                            hideCategoryInSubtitle
                          />
                        ))}
                      </div>
                    </div>
                  ))}
                </div>
              </section>
            ))}
          </div>
        )}
      </main>

      <footer className="fixed bottom-0 left-0 right-0">
        <PointsBanner
          currentUserTotalPoints={currentUserTotalPoints}
          currentUserWeekPoints={currentUserWeekPoints}
          partnerWeekPoints={partnerWeekPoints}
          partnerName={partnerName}
        />
      </footer>

      {showAddTask && (
        <AddTask
          assignablePeople={assignablePeople}
          categories={categories}
          onAddCategory={onAddCategory}
          onAddTask={onAddTask}
          onClose={() => setShowAddTask(false)}
        />
      )}
      {showPartner && (
        <PartnerView
          partnerEmail={partnerEmail}
          partnerDisplayName={partnerDisplayName}
          sentInvite={sentInvite}
          isAcceptingInvite={isAcceptingInvite}
          onSendInvite={onSendInvite}
          onCancelInvite={onCancelInvite}
          onClose={() => setShowPartner(false)}
        />
      )}
      {showCategories && (
        <CategoriesView
          categories={categories}
          onAddCategory={onAddCategory}
          onDeleteCategory={onDeleteCategory}
          onClose={() => setShowCategories(false)}
        />
      )}
      {showFridayWinner && (
        <FridayWinner
          weekWinnerText={weekWinnerText}
          onDismiss={() => setShowFridayWinner(false)}
        />
      )}
    </div>
  )
}
