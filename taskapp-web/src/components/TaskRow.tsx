import type { Task } from '../types/task'
import { taskDayDate } from '../types/task'

function isDueToday(task: Task): boolean {
  const d = taskDayDate(task)
  const today = new Date()
  return (
    d.getFullYear() === today.getFullYear() &&
    d.getMonth() === today.getMonth() &&
    d.getDate() === today.getDate()
  )
}

export function TaskRow({
  task,
  onToggle,
  hideCategoryInSubtitle = false,
}: {
  task: Task
  onToggle: () => void
  hideCategoryInSubtitle?: boolean
}) {
  const dueToday = !task.isCompleted && isDueToday(task)

  return (
    <div
      className={`flex items-center gap-3 py-3 px-4 rounded-xl ${
        dueToday ? 'bg-orange-50 dark:bg-orange-900/20' : ''
      }`}
    >
      <button
        type="button"
        onClick={onToggle}
        className="shrink-0 w-6 h-6 rounded-full border-2 flex items-center justify-center focus:outline-none focus:ring-2 focus:ring-offset-1 focus:ring-gray-400"
        aria-label={task.isCompleted ? 'Mark incomplete' : 'Mark complete'}
      >
        {task.isCompleted ? (
          <span className="text-green-600 text-sm">✓</span>
        ) : null}
      </button>
      <div className="min-w-0 flex-1">
        <p
          className={`font-medium truncate ${
            task.isCompleted ? 'text-gray-500 line-through' : 'text-gray-900'
          }`}
          title={task.title}
        >
          {task.title || '(No title)'}
        </p>
        {(!hideCategoryInSubtitle || task.categoryName) && (
          <p className="text-sm text-gray-500 truncate">
            {dueToday && <span className="text-orange-600 font-medium mr-1">Today</span>}
            {task.assignedToName}
            {task.categoryName?.trim() ? ` · ${task.categoryName}` : ''}
          </p>
        )}
      </div>
    </div>
  )
}
