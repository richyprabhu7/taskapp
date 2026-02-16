import { useEffect, useMemo } from 'react'
import { useAuth } from './hooks/useAuth'
import { usePartner } from './hooks/usePartner'
import { useTasks } from './hooks/useTasks'
import { useCategories } from './hooks/useCategories'
import { usePoints } from './hooks/usePoints'
import type { AssignablePerson } from './types/user'
import { Login } from './components/Login'
import { TaskList } from './components/TaskList'

export default function App() {
  const { user, loading: authLoading, authError, setAuthError, signInWithGoogle, signOut } = useAuth()
  const partner = usePartner()
  const tasksData = useTasks()
  const categoriesData = useCategories()
  const points = usePoints(partner.partnerId)

  useEffect(() => {
    if (user && user.email) {
      partner.acceptPendingInviteIfNeeded(user.uid, user.email)
    }
  }, [user?.uid, user?.email])

  const assignablePeople: AssignablePerson[] = useMemo(() => {
    const list: AssignablePerson[] = []
    if (user) {
      const email = user.email ?? ''
      const name = user.displayName?.trim() ? user.displayName : email.split('@')[0] ?? email
      list.push({ id: email, email, displayName: name })
    }
    if (partner.partnerEmail && partner.partnerDisplayName) {
      if (!list.some((p) => p.email === partner.partnerEmail)) {
        list.push({
          id: partner.partnerEmail,
          email: partner.partnerEmail,
          displayName: partner.partnerDisplayName,
        })
      }
    }
    return list
  }, [user, partner.partnerEmail, partner.partnerDisplayName])

  if (authLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <p className="text-gray-500">Loading…</p>
      </div>
    )
  }

  if (!user) {
    return (
      <Login
        onSignIn={async () => { await signInWithGoogle() }}
        loading={false}
        error={authError}
        onDismissError={() => setAuthError(null)}
      />
    )
  }

  return (
    <TaskList
      tasks={tasksData.tasks}
      assignablePeople={assignablePeople}
      categories={categoriesData.categories}
      partnerEmail={partner.partnerEmail}
      partnerDisplayName={partner.partnerDisplayName}
      sentInvite={partner.sentInvite}
      isAcceptingInvite={partner.isAcceptingInvite}
      currentUserTotalPoints={points.currentUserTotalPoints}
      currentUserWeekPoints={points.currentUserWeekPoints}
      partnerWeekPoints={points.partnerWeekPoints}
      partnerName={points.partnerName}
      isFriday={points.isFriday}
      weekWinnerText={points.weekWinnerText}
      currentWeekId={points.currentWeekId}
      onToggleTask={tasksData.toggleCompletion}
      onAddTask={async (params) => {
        await tasksData.addTask(
          params.title,
          params.assignedTo,
          params.assignedToName,
          params.dueDate,
          params.categoryId,
          params.categoryName
        )
      }}
      onAddCategory={categoriesData.addCategory}
      onDeleteCategory={categoriesData.deleteCategory}
      onSendInvite={partner.sendInvite}
      onCancelInvite={partner.cancelInvite}
      onSignOut={signOut}
    />
  )
}
