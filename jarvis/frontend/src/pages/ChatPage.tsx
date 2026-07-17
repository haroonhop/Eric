import { useState } from 'react'
import { motion } from 'framer-motion'

export default function ChatPage() {
  const [message, setMessage] = useState('')
  const [messages, setMessages] = useState<Array<{role: string, content: string}>>([
    { role: 'assistant', content: 'Hello! I\'m JARVIS. How can I assist you today?' }
  ])

  const sendMessage = () => {
    if (!message.trim()) return
    setMessages([...messages, { role: 'user', content: message }])
    setMessage('')
    // API call will be implemented here
  }

  return (
    <div className="h-[calc(100vh-8rem)] glass-card flex flex-col">
      {/* Chat Messages */}
      <div className="flex-1 overflow-y-auto p-6 space-y-4">
        {messages.map((msg, idx) => (
          <motion.div
            key={idx}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}
          >
            <div className={`max-w-[70%] p-4 rounded-2xl ${
              msg.role === 'user' 
                ? 'bg-sky-500 text-white' 
                : 'bg-slate-800 text-slate-200'
            }`}>
              {msg.content}
            </div>
          </motion.div>
        ))}
      </div>

      {/* Input Area */}
      <div className="p-4 border-t border-slate-700">
        <div className="flex gap-4">
          <input
            type="text"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && sendMessage()}
            placeholder="Type your message..."
            className="flex-1 bg-slate-800 border border-slate-700 rounded-xl px-4 py-3 focus:outline-none focus:border-sky-500 transition-colors"
          />
          <button
            onClick={sendMessage}
            className="px-6 py-3 bg-gradient-to-r from-sky-500 to-indigo-500 rounded-xl font-semibold hover:opacity-90 transition-opacity"
          >
            Send
          </button>
        </div>
      </div>
    </div>
  )
}
