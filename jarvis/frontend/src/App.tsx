import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import Layout from './components/layout/Layout'
import HomePage from './pages/HomePage'
import ChatPage from './pages/ChatPage'
import VoicePage from './pages/VoicePage'
import MemoryPage from './pages/MemoryPage'
import TasksPage from './pages/TasksPage'
import AutomationPage from './pages/AutomationPage'
import AgentsPage from './pages/AgentsPage'
import PluginsPage from './pages/PluginsPage'
import SettingsPage from './pages/SettingsPage'

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
})

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Router>
        <Routes>
          <Route path="/" element={<Layout />}>
            <Route index element={<HomePage />} />
            <Route path="chat" element={<ChatPage />} />
            <Route path="voice" element={<VoicePage />} />
            <Route path="memory" element={<MemoryPage />} />
            <Route path="tasks" element={<TasksPage />} />
            <Route path="automation" element={<AutomationPage />} />
            <Route path="agents" element={<AgentsPage />} />
            <Route path="plugins" element={<PluginsPage />} />
            <Route path="settings" element={<SettingsPage />} />
          </Route>
        </Routes>
      </Router>
    </QueryClientProvider>
  )
}

export default App
