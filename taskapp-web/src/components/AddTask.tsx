import { useState, useEffect } from 'react'
import type { AssignablePerson } from '../types/user'
import type { TaskCategory } from '../types/user'

export function AddTask({
  assignablePeople,
  categories,
  onAddCategory,
  onAddTask,
  onClose,
}: {
  assignablePeople: AssignablePerson[]
  categories: TaskCategory[]
  onAddCategory: (name: string) => void
  onAddTask: (params: {
    title: string
    assignedTo: string
    assignedToName: string
    dueDate: Date
    categoryId: string | null
    categoryName: string | null
  }) => Promise<void>
  onClose: () => void
}) {
  const [title, setTitle] = useState('')
  const [selectedPersonId, setSelectedPersonId] = useState('')
  const [selectedCategoryId, setSelectedCategoryId] = useState('')
  const [dueDate, setDueDate] = useState(() => {
    const d = new Date()
    d.setHours(12, 0, 0, 0)
    return d.toISOString().slice(0, 10)
  })
  const [showNewCategory, setShowNewCategory] = useState(false)
  const [newCategoryName, setNewCategoryName] = useState('')
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    if (!selectedPersonId && assignablePeople.length) {
      setSelectedPersonId(assignablePeople[0].id)
    }
  }, [assignablePeople, selectedPersonId])

  const selectedPerson = assignablePeople.find((p) => p.id === selectedPersonId)
  const selectedCategory = selectedCategoryId
    ? categories.find((c) => (c.id ?? '') === selectedCategoryId)
    : null

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    if (!title.trim() || !selectedPerson) return
    setSubmitting(true)
    await onAddTask({
      title: title.trim(),
      assignedTo: selectedPerson.email,
      assignedToName: selectedPerson.displayName,
      dueDate: new Date(dueDate),
      categoryId: selectedCategory?.id ?? null,
      categoryName: selectedCategory?.name ?? null,
    })
    setSubmitting(false)
    onClose()
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/40">
      <div className="bg-white dark:bg-gray-900 w-full max-w-md rounded-t-2xl sm:rounded-2xl max-h-[90vh] overflow-y-auto shadow-xl">
        <div className="sticky top-0 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-700 px-4 py-3 flex items-center justify-between">
          <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100">New Task</h2>
          <button
            type="button"
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700"
          >
            Cancel
          </button>
        </div>
        <form onSubmit={handleSubmit} className="p-4 space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Task title
            </label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Task title"
              className="w-full rounded-xl border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 px-4 py-2 text-gray-900 dark:text-gray-100"
              autoFocus
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Assign to
            </label>
            <select
              value={selectedPersonId}
              onChange={(e) => setSelectedPersonId(e.target.value)}
              className="w-full rounded-xl border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 px-4 py-2 text-gray-900 dark:text-gray-100"
            >
              {assignablePeople.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.displayName}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Category
            </label>
            <select
              value={selectedCategoryId}
              onChange={(e) => setSelectedCategoryId(e.target.value)}
              className="w-full rounded-xl border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 px-4 py-2 text-gray-900 dark:text-gray-100"
            >
              <option value="">None</option>
              {categories.map((c) => (
                <option key={c.id ?? c.name} value={c.id ?? ''}>
                  {c.name}
                </option>
              ))}
            </select>
            <button
              type="button"
              onClick={() => setShowNewCategory((v) => !v)}
              className="mt-2 text-sm text-gray-600 dark:text-gray-400 hover:text-gray-900"
            >
              + Add new category
            </button>
            {showNewCategory && (
              <div className="mt-2 flex gap-2">
                <input
                  type="text"
                  value={newCategoryName}
                  onChange={(e) => setNewCategoryName(e.target.value)}
                  placeholder="Category name"
                  className="flex-1 rounded-xl border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 px-4 py-2 text-gray-900 dark:text-gray-100"
                />
                <button
                  type="button"
                  onClick={() => {
                    const name = newCategoryName.trim()
                    if (name) {
                      onAddCategory(name)
                      setNewCategoryName('')
                      setShowNewCategory(false)
                    }
                  }}
                  className="rounded-xl bg-gray-900 text-white px-4 py-2 text-sm font-medium"
                >
                  Add
                </button>
              </div>
            )}
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Due date
            </label>
            <input
              type="date"
              value={dueDate}
              onChange={(e) => setDueDate(e.target.value)}
              className="w-full rounded-xl border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 px-4 py-2 text-gray-900 dark:text-gray-100"
            />
          </div>
          <button
            type="submit"
            disabled={!title.trim() || !selectedPerson || submitting}
            className="w-full rounded-xl bg-gray-900 text-white py-3 font-medium disabled:opacity-50"
          >
            {submitting ? 'Adding…' : 'Add Task'}
          </button>
        </form>
      </div>
    </div>
  )
}
