export function ConfigRequired() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gray-100 p-6">
      <div className="max-w-md w-full bg-white rounded-2xl shadow-lg p-8">
        <h1 className="text-xl font-semibold text-gray-900 mb-2">Firebase not configured</h1>
        <p className="text-gray-600 text-sm mb-4">
          Add your Firebase web app config so this app can connect to your project.
        </p>
        <ol className="list-decimal list-inside text-sm text-gray-700 space-y-2 mb-6">
          <li>Open Firebase Console → your project → Project settings → Your apps.</li>
          <li>Add a Web app (or use an existing one) and copy the <code className="bg-gray-100 px-1 rounded">firebaseConfig</code> values.</li>
          <li>In this project folder, copy <code className="bg-gray-100 px-1 rounded">.env.example</code> to <code className="bg-gray-100 px-1 rounded">.env</code>.</li>
          <li>Fill in <code className="bg-gray-100 px-1 rounded">.env</code> with the values (e.g. <code className="bg-gray-100 px-1 rounded">VITE_FIREBASE_PROJECT_ID=...</code>).</li>
          <li>Restart the dev server (<code className="bg-gray-100 px-1 rounded">npm run dev</code>) and refresh the page.</li>
        </ol>
        <p className="text-xs text-gray-500">
          Use the same Firebase project as your iOS app so both share the same data.
        </p>
      </div>
    </div>
  )
}
