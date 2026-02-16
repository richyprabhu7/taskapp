import { useState } from 'react'

export function PartnerView({
  partnerEmail,
  partnerDisplayName,
  sentInvite,
  isAcceptingInvite,
  onSendInvite,
  onCancelInvite,
  onClose,
}: {
  partnerEmail: string | null
  partnerDisplayName: string | null
  sentInvite: { toEmail: string } | null
  isAcceptingInvite: boolean
  onSendInvite: (email: string) => Promise<void>
  onCancelInvite: () => Promise<void>
  onClose: () => void
}) {
  const [email, setEmail] = useState('')
  const [sending, setSending] = useState(false)

  async function handleSend(e: React.FormEvent) {
    e.preventDefault()
    const trimmed = email.trim().toLowerCase()
    if (!trimmed) return
    setSending(true)
    await onSendInvite(trimmed)
    setSending(false)
    setEmail('')
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/40">
      <div className="bg-white dark:bg-gray-900 w-full max-w-md rounded-t-2xl sm:rounded-2xl p-6 shadow-xl">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100">Partner</h2>
          <button type="button" onClick={onClose} className="text-gray-500 hover:text-gray-700">
            Done
          </button>
        </div>
        {partnerEmail ? (
          <p className="text-gray-600 dark:text-gray-400">
            Connected with <strong>{partnerDisplayName ?? partnerEmail}</strong>
          </p>
        ) : sentInvite ? (
          <div>
            <p className="text-gray-600 dark:text-gray-400 mb-2">
              Invite sent to <strong>{sentInvite.toEmail}</strong>
            </p>
            <button
              type="button"
              onClick={() => onCancelInvite()}
              className="text-sm text-red-600 hover:text-red-700"
            >
              Cancel invite
            </button>
          </div>
        ) : (
          <form onSubmit={handleSend} className="space-y-3">
            <p className="text-sm text-gray-500">Invite your partner by email. They’ll connect when they sign in.</p>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="Partner's email"
              className="w-full rounded-xl border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 px-4 py-2 text-gray-900 dark:text-gray-100"
            />
            <button
              type="submit"
              disabled={!email.trim() || sending || isAcceptingInvite}
              className="w-full rounded-xl bg-gray-900 text-white py-3 font-medium disabled:opacity-50"
            >
              {sending || isAcceptingInvite ? 'Sending…' : 'Send invite'}
            </button>
          </form>
        )}
      </div>
    </div>
  )
}
