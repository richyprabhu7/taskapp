export function Login({
  onSignIn,
  loading,
  error,
  onDismissError,
}: {
  onSignIn: () => Promise<void>
  loading: boolean
  error: string | null
  onDismissError: () => void
}) {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gray-50 px-4">
      <div className="w-full max-w-sm rounded-2xl bg-white shadow-lg p-8 text-center">
        <h1 className="text-2xl font-semibold text-gray-900 mb-2">Task App</h1>
        <p className="text-gray-500 text-sm mb-6">Couples task manager</p>
        {error && (
          <div className="mb-4 p-3 rounded-lg bg-red-50 text-red-800 text-sm text-left flex items-start gap-2">
            <span className="flex-1">{error}</span>
            <button type="button" onClick={onDismissError} className="shrink-0 text-red-600 hover:text-red-800" aria-label="Dismiss">×</button>
          </div>
        )}
        <button
          type="button"
          onClick={onSignIn}
          disabled={loading}
          className="w-full flex items-center justify-center gap-2 rounded-xl bg-gray-900 text-white py-3 px-4 font-medium hover:bg-gray-800 disabled:opacity-50"
        >
          {loading ? (
            'Signing in…'
          ) : (
            <>
              <svg className="w-5 h-5" viewBox="0 0 24 24">
                <path
                  fill="currentColor"
                  d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                />
                <path
                  fill="currentColor"
                  d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                />
                <path
                  fill="currentColor"
                  d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
                />
                <path
                  fill="currentColor"
                  d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
                />
              </svg>
              Sign in with Google
            </>
          )}
        </button>
      </div>
    </div>
  )
}
