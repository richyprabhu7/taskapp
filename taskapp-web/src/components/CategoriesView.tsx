import { useState } from 'react'
import type { TaskCategory } from '../types/user'

export function CategoriesView({
  categories,
  onAddCategory,
  onDeleteCategory,
  onClose,
}: {
  categories: TaskCategory[]
  onAddCategory: (name: string) => void
  onDeleteCategory: (cat: TaskCategory) => void
  onClose: () => void
}) {
  const [newName, setNewName] = useState('')

  function handleAdd(e: React.FormEvent) {
    e.preventDefault()
    const name = newName.trim()
    if (name) {
      onAddCategory(name)
      setNewName('')
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/40">
      <div className="bg-white dark:bg-gray-900 w-full max-w-md rounded-t-2xl sm:rounded-2xl p-6 shadow-xl max-h-[80vh] overflow-hidden flex flex-col">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100">Categories</h2>
          <button type="button" onClick={onClose} className="text-gray-500 hover:text-gray-700">
            Done
          </button>
        </div>
        <form onSubmit={handleAdd} className="flex gap-2 mb-4">
          <input
            type="text"
            value={newName}
            onChange={(e) => setNewName(e.target.value)}
            placeholder="New category"
            className="flex-1 rounded-xl border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 px-4 py-2 text-gray-900 dark:text-gray-100"
          />
          <button
            type="submit"
            disabled={!newName.trim()}
            className="rounded-xl bg-gray-900 text-white px-4 py-2 font-medium disabled:opacity-50"
          >
            Add
          </button>
        </form>
        <ul className="overflow-y-auto space-y-1">
          {categories.map((c) => (
            <li
              key={c.id ?? c.name}
              className="flex items-center justify-between py-2 px-3 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800"
            >
              <span className="text-gray-900 dark:text-gray-100">{c.name}</span>
              <button
                type="button"
                onClick={() => onDeleteCategory(c)}
                className="text-sm text-red-600 hover:text-red-700"
              >
                Delete
              </button>
            </li>
          ))}
        </ul>
      </div>
    </div>
  )
}
