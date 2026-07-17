import { motion } from 'framer-motion'

export default function HomePage() {
  return (
    <div className="space-y-8">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center py-12"
      >
        <h1 className="text-5xl font-bold text-gradient mb-4">
          Welcome to JARVIS AI
        </h1>
        <p className="text-xl text-slate-400 max-w-2xl mx-auto">
          Your intelligent personal assistant powered by advanced AI. 
          Control your digital world with voice, chat, and automation.
        </p>
      </motion.div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <QuickActionCard
          icon="💬"
          title="Chat with JARVIS"
          description="Have natural conversations with AI"
          link="/chat"
          delay={0.1}
        />
        <QuickActionCard
          icon="🎤"
          title="Voice Commands"
          description="Control everything with your voice"
          link="/voice"
          delay={0.2}
        />
        <QuickActionCard
          icon="⚙️"
          title="Automation"
          description="Automate repetitive tasks"
          link="/automation"
          delay={0.3}
        />
        <QuickActionCard
          icon="🤖"
          title="AI Agents"
          description="Specialized agents for specific tasks"
          link="/agents"
          delay={0.4}
        />
        <QuickActionCard
          icon="🧠"
          title="Memory"
          description="Access your personalized knowledge base"
          link="/memory"
          delay={0.5}
        />
        <QuickActionCard
          icon="✅"
          title="Tasks"
          description="Manage your to-do lists and reminders"
          link="/tasks"
          delay={0.6}
        />
      </div>

      {/* Stats */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.7 }}
        className="glass-card p-8 mt-8"
      >
        <h2 className="text-2xl font-bold mb-6 text-center">System Status</h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
          <StatItem label="AI Model" value="GPT-4 Turbo" status="online" />
          <StatItem label="Voice Engine" value="Active" status="online" />
          <StatItem label="Automation" value="Enabled" status="online" />
          <StatItem label="Memory" value="89 Items" status="online" />
        </div>
      </motion.div>

      {/* Recent Activity */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.8 }}
        className="glass-card p-8"
      >
        <h2 className="text-2xl font-bold mb-6">Recent Activity</h2>
        <div className="space-y-4">
          <ActivityItem
            action="Completed task"
            description="Research on quantum computing"
            time="2 minutes ago"
          />
          <ActivityItem
            action="Voice command executed"
            description="Opened development environment"
            time="15 minutes ago"
          />
          <ActivityItem
            action="New memory stored"
            description="Project deadline: December 31"
            time="1 hour ago"
          />
          <ActivityItem
            action="Agent task completed"
            description="Marketing analysis report generated"
            time="3 hours ago"
          />
        </div>
      </motion.div>
    </div>
  )
}

interface QuickActionCardProps {
  icon: string
  title: string
  description: string
  link: string
  delay: number
}

function QuickActionCard({ icon, title, description, link, delay }: QuickActionCardProps) {
  return (
    <motion.a
      href={link}
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay }}
      whileHover={{ scale: 1.05, y: -5 }}
      className="glass-card p-6 block hover:border-sky-500/50 transition-all duration-300"
    >
      <div className="text-4xl mb-4">{icon}</div>
      <h3 className="text-xl font-semibold mb-2">{title}</h3>
      <p className="text-slate-400">{description}</p>
    </motion.a>
  )
}

interface StatItemProps {
  label: string
  value: string
  status: string
}

function StatItem({ label, value, status }: StatItemProps) {
  return (
    <div className="text-center">
      <div className="text-2xl font-bold text-sky-400 mb-1">{value}</div>
      <div className="text-sm text-slate-400 mb-2">{label}</div>
      <div className="inline-flex items-center gap-1 px-2 py-1 rounded-full bg-green-500/20 text-green-400 text-xs">
        <span className="w-2 h-2 rounded-full bg-green-400 animate-pulse"></span>
        {status}
      </div>
    </div>
  )
}

interface ActivityItemProps {
  action: string
  description: string
  time: string
}

function ActivityItem({ action, description, time }: ActivityItemProps) {
  return (
    <div className="flex items-center justify-between p-4 rounded-lg bg-slate-800/50 hover:bg-slate-800 transition-colors">
      <div>
        <div className="font-medium">{action}</div>
        <div className="text-sm text-slate-400">{description}</div>
      </div>
      <div className="text-sm text-slate-500">{time}</div>
    </div>
  )
}
