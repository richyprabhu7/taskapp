export interface PartnerInvite {
  id?: string
  fromUserId: string
  fromEmail: string
  fromDisplayName: string
  toEmail: string
  createdAt: { toDate: () => Date } | Date
}

export interface TaskCategory {
  id?: string
  name: string
  colorHex?: string | null
  order?: number | null
}

export interface AssignablePerson {
  id: string
  email: string
  displayName: string
}
