import { useState, useEffect } from 'react'
import {
  collection,
  doc,
  getDoc,
  getDocs,
  addDoc,
  deleteDoc,
  onSnapshot,
  query,
  where,
  limit,
  writeBatch,
} from 'firebase/firestore'
import { auth, db } from '../firebase'
import type { PartnerInvite } from '../types/user'

export function usePartner() {
  const [partnerId, setPartnerId] = useState<string | null>(null)
  const [partnerEmail, setPartnerEmail] = useState<string | null>(null)
  const [partnerDisplayName, setPartnerDisplayName] = useState<string | null>(null)
  const [sentInvite, setSentInvite] = useState<PartnerInvite | null>(null)
  const [acceptingInvite, setAcceptingInvite] = useState(false)

  const uid = auth.currentUser?.uid ?? null

  useEffect(() => {
    if (!uid) return
    const unsubUser = onSnapshot(doc(db, 'users', uid), (snap) => {
      const data = snap.data()
      setPartnerId((data?.partnerId as string) ?? null)
    })
    return () => {
      unsubUser()
    }
  }, [uid])

  useEffect(() => {
    if (!partnerId) {
      setPartnerEmail(null)
      setPartnerDisplayName(null)
      return
    }
    getDoc(doc(db, 'users', partnerId)).then((snap) => {
      const data = snap.data()
      setPartnerEmail((data?.email as string) ?? null)
      setPartnerDisplayName((data?.displayName as string) ?? (data?.email as string) ?? 'Partner')
    })
  }, [partnerId])

  useEffect(() => {
    if (!uid) return
    const q = query(
      collection(db, 'invites'),
      where('fromUserId', '==', uid),
      limit(1)
    )
    const unsub = onSnapshot(q, (snap) => {
      const first = snap.docs[0]
      if (!first) {
        setSentInvite(null)
        return
      }
      const d = first.data()
      setSentInvite({
        id: first.id,
        fromUserId: d.fromUserId,
        fromEmail: d.fromEmail,
        fromDisplayName: d.fromDisplayName,
        toEmail: d.toEmail,
        createdAt: d.createdAt,
      })
    })
    return () => {
      unsub()
    }
  }, [uid])

  async function sendInvite(toEmail: string) {
    const email = toEmail.trim().toLowerCase()
    const user = auth.currentUser
    if (!uid || !user || !email || email === (user.email ?? '').toLowerCase()) return
    await addDoc(collection(db, 'invites'), {
      fromUserId: uid,
      fromEmail: user.email ?? '',
      fromDisplayName: user.displayName ?? user.email?.split('@')[0] ?? 'Someone',
      toEmail: email,
      createdAt: new Date(),
    })
  }

  async function cancelInvite() {
    if (!sentInvite?.id) return
    await deleteDoc(doc(db, 'invites', sentInvite.id))
    setSentInvite(null)
  }

  async function acceptPendingInviteIfNeeded(userId: string, email: string) {
    if (!email.trim()) return
    setAcceptingInvite(true)
    const q = query(
      collection(db, 'invites'),
      where('toEmail', '==', email.toLowerCase()),
      limit(1)
    )
    const snap = await getDocs(q)
    const inviteDoc = snap.docs[0]
    if (!inviteDoc) {
      setAcceptingInvite(false)
      return
    }
    const invite = inviteDoc.data() as PartnerInvite
    const fromUserId = invite.fromUserId
    const batch = writeBatch(db)
    batch.set(doc(db, 'users', fromUserId), { partnerId: userId }, { merge: true })
    batch.set(doc(db, 'users', userId), { partnerId: fromUserId }, { merge: true })
    batch.delete(doc(db, 'invites', inviteDoc.id))
    await batch.commit()
    setPartnerId(fromUserId)
    setAcceptingInvite(false)
  }

  return {
    partnerId,
    partnerEmail,
    partnerDisplayName,
    sentInvite,
    isAcceptingInvite: acceptingInvite,
    sendInvite,
    cancelInvite,
    acceptPendingInviteIfNeeded,
  }
}
