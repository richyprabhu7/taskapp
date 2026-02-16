import { useState, useEffect } from 'react'
import { doc, onSnapshot, runTransaction } from 'firebase/firestore'
import { auth, db } from '../firebase'

function weekId(date: Date = new Date()): string {
  const d = new Date(date)
  const start = new Date(d.getFullYear(), 0, 1)
  const diff = d.getTime() - start.getTime()
  const oneWeek = 7 * 24 * 60 * 60 * 1000
  const week = Math.ceil((diff / oneWeek) + (start.getDay() / 7))
  return `${d.getFullYear()}-W${week}`
}

export function getCurrentWeekId(): string {
  return weekId()
}

export function usePoints(partnerId: string | null) {
  const [currentUserTotalPoints, setCurrentUserTotalPoints] = useState(0)
  const [currentUserWeekPoints, setCurrentUserWeekPoints] = useState(0)
  const [partnerWeekPoints, setPartnerWeekPoints] = useState(0)
  const [partnerName, setPartnerName] = useState('Partner')

  const uid = auth.currentUser?.uid ?? null

  useEffect(() => {
    if (!uid) return
    const unsub = onSnapshot(doc(db, 'users', uid), (snap) => {
      const data = snap.data()
      setCurrentUserTotalPoints((data?.totalPoints as number) ?? 0)
      const weekly = (data?.weeklyPoints as Record<string, number>) ?? {}
      setCurrentUserWeekPoints(weekly[weekId()] ?? 0)
    })
    return () => unsub()
  }, [uid])

  useEffect(() => {
    if (!partnerId) {
      setPartnerWeekPoints(0)
      setPartnerName('Partner')
      return
    }
    const unsub = onSnapshot(doc(db, 'users', partnerId), (snap) => {
      const data = snap.data()
      const weekly = (data?.weeklyPoints as Record<string, number>) ?? {}
      setPartnerWeekPoints(weekly[weekId()] ?? 0)
      setPartnerName((data?.displayName as string) ?? (data?.email as string) ?? 'Partner')
    })
    return () => unsub()
  }, [partnerId])

  const isFriday = new Date().getDay() === 5
  const weekWinnerText =
    currentUserWeekPoints > partnerWeekPoints
      ? 'You win! 🏆'
      : partnerWeekPoints > currentUserWeekPoints
        ? `${partnerName} wins! 🏆`
        : "It's a tie! 🤝"

  return {
    currentUserTotalPoints,
    currentUserWeekPoints,
    partnerWeekPoints,
    partnerName,
    isFriday,
    weekWinnerText,
    currentWeekId: weekId(),
  }
}

export function awardForCreate(createdByUserId: string, assignedToEmail: string, currentUserEmail: string) {
  if (createdByUserId !== auth.currentUser?.uid) return
  const points = assignedToEmail === currentUserEmail ? 2 : 1
  addPoints(createdByUserId, points)
}

export function awardForComplete(userId: string) {
  addPoints(userId, 5)
}

function addPoints(userId: string, points: number) {
  const wid = weekId()
  const ref = doc(db, 'users', userId)
  runTransaction(db, (tx) => {
    return tx.get(ref).then((docSnap) => {
      const data = docSnap.data() ?? {}
      const total = (data.totalPoints as number) ?? 0
      const weekly = (data.weeklyPoints as Record<string, number>) ?? {}
      weekly[wid] = (weekly[wid] ?? 0) + points
      tx.set(ref, {
        totalPoints: total + points,
        weeklyPoints: weekly,
        updatedAt: new Date(),
      }, { merge: true })
    })
  }).catch((err) => console.error('Points transaction failed', err))
}
