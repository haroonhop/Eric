import { useState } from 'react'
import { motion } from 'framer-motion'

export default function VoicePage() {
  const [isListening, setIsListening] = useState(false)
  const [isSpeaking, setIsSpeaking] = useState(false)

  return (
    <div className="h-[calc(100vh-8rem)] flex flex-col items-center justify-center">
      {/* Voice Visualization */}
      <motion.div
        className="relative mb-12"
        animate={{ scale: isListening ? 1.2 : 1 }}
      >
        <div className="w-48 h-48 rounded-full bg-gradient-to-br from-sky-500 to-indigo-600 flex items-center justify-center animate-pulse-glow relative">
          {/* Animated rings */}
          {isListening && (
            <>
              <motion.div
                className="absolute inset-0 rounded-full border-2 border-sky-400"
                animate={{ scale: [1, 1.5], opacity: [1, 0] }}
                transition={{ repeat: Infinity, duration: 1.5 }}
              />
              <motion.div
                className="absolute inset-0 rounded-full border-2 border-indigo-400"
                animate={{ scale: [1, 1.5], opacity: [1, 0] }}
                transition={{ repeat: Infinity, duration: 1.5, delay: 0.5 }}
              />
            </>
          )}
          <span className="text-6xl">🎤</span>
        </div>
      </motion.div>

      {/* Status */}
      <motion.h2
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        className="text-3xl font-bold text-gradient mb-4"
      >
        {isListening ? 'Listening...' : isSpeaking ? 'Speaking...' : 'Voice Assistant'}
      </motion.h2>

      <p className="text-slate-400 mb-8 text-center max-w-md">
        {isListening 
          ? 'Speak now... Say "Hey Jarvis" to activate' 
          : 'Click the microphone to start voice commands'}
      </p>

      {/* Controls */}
      <div className="flex gap-4">
        <motion.button
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.95 }}
          onClick={() => setIsListening(!isListening)}
          className={`px-8 py-4 rounded-xl font-semibold text-lg ${
            isListening
              ? 'bg-red-500 hover:bg-red-600'
              : 'bg-gradient-to-r from-sky-500 to-indigo-500 hover:opacity-90'
          }`}
        >
          {isListening ? 'Stop Listening' : 'Start Listening'}
        </motion.button>

        <motion.button
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.95 }}
          onClick={() => setIsSpeaking(!isSpeaking)}
          className="px-8 py-4 rounded-xl font-semibold text-lg bg-slate-700 hover:bg-slate-600 transition-colors"
        >
          {isSpeaking ? 'Stop Speaking' : 'Test Speech'}
        </motion.button>
      </div>

      {/* Waveform Visualization */}
      {isListening && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="mt-12 flex items-center gap-1"
        >
          {[...Array(20)].map((_, i) => (
            <motion.div
              key={i}
              className="w-1 bg-sky-400 rounded-full"
              animate={{
                height: [20, Math.random() * 60 + 20, 20],
              }}
              transition={{
                repeat: Infinity,
                duration: 0.5,
                delay: i * 0.05,
              }}
            />
          ))}
        </motion.div>
      )}
    </div>
  )
}
