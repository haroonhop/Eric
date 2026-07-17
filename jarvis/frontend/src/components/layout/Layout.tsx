import { Outlet, Link, useLocation } from 'react-router-dom'
import { motion } from 'framer-motion'
import { useState } from 'react'

// Icons (using emoji for now, will be replaced with proper icons)
const navItems = [
  { path: '/', label: 'Home', icon: '🏠' },
  { path: '/chat', label: 'Chat', icon: '💬' },
  { path: '/voice', label: 'Voice', icon: '🎤' },
  { path: '/memory', label: 'Memory', icon: '🧠' },
  { path: '/tasks', label: 'Tasks', icon: '✅' },
  { path: '/automation', label: 'Automation', icon: '⚙️' },
  { path: '/agents', label: 'Agents', icon: '🤖' },
  { path: '/plugins', label: 'Plugins', icon: '🔌' },
  { path: '/settings', label: 'Settings', icon: '⚡' },
]

export default function Layout() {
  const location = useLocation()
  const [sidebarOpen, setSidebarOpen] = useState(true)

  return (
    <div className="flex h-screen bg-slate-900 overflow-hidden">
      {/* Sidebar */}
      <motion.aside
        initial={{ width: 250 }}
        animate={{ width: sidebarOpen ? 250 : 80 }}
        className="glass border-r border-slate-700 flex flex-col"
      >
        {/* Logo */}
        <div className="p-6 border-b border-slate-700">
          <motion.div
            className="flex items-center gap-3"
            animate={{ justifyContent: sidebarOpen ? 'flex-start' : 'center' }}
          >
            <div className="w-10 h-10 rounded-full bg-gradient-to-br from-sky-400 to-indigo-500 flex items-center justify-center animate-pulse-glow">
              <span className="text-white font-bold text-lg">J</span>
            </div>
            {sidebarOpen && (
              <motion.h1
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="text-xl font-bold text-gradient"
              >
                JARVIS AI
              </motion.h1>
            )}
          </motion.div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 p-4 space-y-2 overflow-y-auto">
          {navItems.map((item) => (
            <Link
              key={item.path}
              to={item.path}
              className={`flex items-center gap-3 px-4 py-3 rounded-lg transition-all duration-200 ${
                location.pathname === item.path
                  ? 'bg-sky-500/20 text-sky-400 border border-sky-500/30'
                  : 'text-slate-400 hover:bg-slate-800/50 hover:text-white'
              }`}
            >
              <span className="text-xl">{item.icon}</span>
              {sidebarOpen && (
                <motion.span
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="font-medium"
                >
                  {item.label}
                </motion.span>
              )}
            </Link>
          ))}
        </nav>

        {/* Toggle Button */}
        <button
          onClick={() => setSidebarOpen(!sidebarOpen)}
          className="m-4 p-2 rounded-lg bg-slate-800/50 hover:bg-slate-700/50 transition-colors text-slate-400 hover:text-white"
        >
          {sidebarOpen ? '◀' : '▶'}
        </button>
      </motion.aside>

      {/* Main Content */}
      <main className="flex-1 overflow-auto relative">
        {/* Particle Background */}
        <div className="particle-bg">
          <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-sky-900/20 via-slate-900/0 to-transparent"></div>
        </div>

        {/* Content */}
        <div className="relative z-10 p-8">
          <Outlet />
        </div>
      </main>
    </div>
  )
}
