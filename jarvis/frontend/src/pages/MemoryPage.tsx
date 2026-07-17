import { motion } from 'framer-motion'

export default function MemoryPage() {
  const memories = [
    { key: 'user_name', value: 'John Doe', category: 'profile', updated: '2 hours ago' },
    { key: 'preferred_language', value: 'English', category: 'preferences', updated: '1 day ago' },
    { key: 'work_schedule', value: '9 AM - 5 PM, Mon-Fri', category: 'schedule', updated: '3 days ago' },
    { key: 'project_deadline', value: 'December 31, 2024', category: 'tasks', updated: '1 week ago' },
  ]

  return (
    <div className="space-y-6">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <h1 className="text-4xl font-bold text-gradient mb-2">Memory Bank</h1>
        <p className="text-slate-400">Your personalized knowledge base and preferences</p>
      </motion.div>

      {/* Stats */}
      <div className="grid grid-cols-4 gap-4">
        <StatCard label="Total Memories" value="89" />
        <StatCard label="Categories" value="12" />
        <StatCard label="This Week" value="+15" />
        <StatCard label="Storage Used" value="2.4 MB" />
      </div>

      {/* Memories List */}
      <div className="glass-card p-6">
        <h2 className="text-2xl font-bold mb-6">Stored Memories</h2>
        <div className="space-y-4">
          {memories.map((memory, idx) => (
            <motion.div
              key={memory.key}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: idx * 0.1 }}
              className="flex items-center justify-between p-4 rounded-lg bg-slate-800/50 hover:bg-slate-800 transition-colors"
            >
              <div>
                <div className="font-medium text-sky-400">{memory.key}</div>
                <div className="text-slate-300">{memory.value}</div>
              </div>
              <div className="text-right">
                <div className="text-sm text-slate-500 capitalize">{memory.category}</div>
                <div className="text-xs text-slate-600">{memory.updated}</div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </div>
  )
}

function StatCard({ label, value }: { label: string; value: string }) {
  return (
    <div className="glass-card p-4 text-center">
      <div className="text-3xl font-bold text-sky-400 mb-1">{value}</div>
      <div className="text-sm text-slate-400">{label}</div>
    </div>
  )
}
