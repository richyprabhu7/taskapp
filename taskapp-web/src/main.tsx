import React, { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { isFirebaseConfigured } from './firebase'
import App from './App'
import { ConfigRequired } from './components/ConfigRequired'
import './index.css'

class ErrorBoundary extends React.Component<
  { children: React.ReactNode },
  { hasError: boolean; error: Error | null }
> {
  state = { hasError: false, error: null as Error | null }
  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error }
  }
  render() {
    if (this.state.hasError && this.state.error) {
      return (
        <div className="min-h-screen flex flex-col items-center justify-center bg-gray-100 p-6">
          <div className="max-w-md bg-white rounded-xl shadow p-6">
            <h1 className="text-lg font-semibold text-gray-900 mb-2">Something went wrong</h1>
            <pre className="text-sm text-red-700 bg-red-50 p-3 rounded overflow-auto">
              {this.state.error.message}
            </pre>
            <p className="text-sm text-gray-600 mt-3">
              Check the browser console for details. Fix the error and refresh.
            </p>
          </div>
        </div>
      )
    }
    return this.props.children
  }
}

const root = document.getElementById('root')!
createRoot(root).render(
  <StrictMode>
    <ErrorBoundary>
      {isFirebaseConfigured ? <App /> : <ConfigRequired />}
    </ErrorBoundary>
  </StrictMode>
)
