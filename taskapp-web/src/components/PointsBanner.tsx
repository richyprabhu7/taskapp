export function PointsBanner({
  currentUserTotalPoints,
  currentUserWeekPoints,
  partnerWeekPoints,
  partnerName,
}: {
  currentUserTotalPoints: number
  currentUserWeekPoints: number
  partnerWeekPoints: number
  partnerName: string
}) {
  return (
    <div className="flex items-center justify-between px-5 py-3 bg-gray-100 dark:bg-gray-800 rounded-t-xl">
      <div className="flex items-center gap-2">
        <span className="text-yellow-500 text-xl">★</span>
        <div>
          <p className="text-xs text-gray-500">Your points</p>
          <p className="text-sm font-semibold text-gray-900 dark:text-gray-100">
            {currentUserTotalPoints} total · {currentUserWeekPoints} this week
          </p>
        </div>
      </div>
      <div className="flex items-center gap-2">
        <div className="text-right">
          <p className="text-xs text-gray-500">{partnerName}</p>
          <p className="text-sm font-semibold text-gray-900 dark:text-gray-100">
            {partnerWeekPoints} this week
          </p>
        </div>
        <span className="text-pink-500 text-xl">♥</span>
      </div>
    </div>
  )
}
