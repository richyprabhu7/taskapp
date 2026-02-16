export function FridayWinner({
  weekWinnerText,
  onDismiss,
}: {
  weekWinnerText: string
  onDismiss: () => void
}) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
      <div className="bg-white dark:bg-gray-900 rounded-2xl p-8 max-w-sm w-full text-center shadow-xl">
        <p className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-2">
          Friday winner
        </p>
        <p className="text-2xl font-bold text-yellow-600 dark:text-yellow-400 mb-6">
          {weekWinnerText}
        </p>
        <button
          type="button"
          onClick={onDismiss}
          className="w-full rounded-xl bg-gray-900 text-white py-3 font-medium"
        >
          Done
        </button>
      </div>
    </div>
  )
}
