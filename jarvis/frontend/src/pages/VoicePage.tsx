import { useState, useEffect, useCallback } from 'react'
import { motion, AnimatePresence } from 'framer-motion'

interface VoiceCommand {
  id: string
  command: string
  timestamp: Date
  recognized: boolean
}

export default function VoicePage() {
  const [isListening, setIsListening] = useState(false)
  const [isSpeaking, setIsSpeaking] = useState(false)
  const [waveformHeight, setWaveformHeight] = useState<number[]>(Array(20).fill(20))
  const [lastCommand, setLastCommand] = useState<string>('')
  const [commands, setCommands] = useState<VoiceCommand[]>([])
  const [permissionGranted, setPermissionGranted] = useState<boolean | null>(null)

  // Generate animated waveform
  useEffect(() => {
    if (!isListening) {
      setWaveformHeight(Array(20).fill(20))
      return
    }

    const interval = setInterval(() => {
      setWaveformHeight(prev => 
        prev.map(() => Math.random() * 60 + 20)
      )
    }, 100)

    return () => clearInterval(interval)
  }, [isListening])

  // Request microphone permission on mount
  useEffect(() => {
    const requestPermission = async () => {
      try {
        if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
          setPermissionGranted(true)
        } else {
          setPermissionGranted(false)
        }
      } catch (error) {
        setPermissionGranted(false)
      }
    }
    requestPermission()
  }, [])

  const handleStartListening = useCallback(() => {
    setIsListening(true)
    setLastCommand('Listening...')
  }, [])

  const handleStopListening = useCallback(() => {
    setIsListening(false)
    if (lastCommand === 'Listening...') {
      setLastCommand('')
    }
  }, [lastCommand])

  const handleTestSpeech = useCallback(() => {
    setIsSpeaking(true)
    
    // Simulate speech synthesis
    if ('speechSynthesis' in window) {
      const utterance = new SpeechSynthesisUtterance("Hello! I am JARVIS, your intelligent assistant. How can I help you today?")
      utterance.onend = () => setIsSpeaking(false)
      speechSynthesis.speak(utterance)
    } else {
      setTimeout(() => setIsSpeaking(false), 2000)
    }
  }, [])

  const addCommand = useCallback((command: string) => {
    const newCommand: VoiceCommand = {
      id: Date.now().toString(),
      command,
      timestamp: new Date(),
      recognized: true
    }
    setCommands(prev => [newCommand, ...prev].slice(0, 10))
  }, [])

  return (
    <div className="h-[calc(100vh-8rem)] flex flex-col">
      {/* Header */}
      <div className="p-4 border-b border-slate-700 mb-6">
        <h2 className="text-2xl font-bold text-gradient">Voice Assistant</h2>
        <p className="text-sm text-slate-400 mt-1">
          {permissionGranted ? '✅ Speech recognition available' : '⚠️ Speech recognition not supported in this browser'}
        </p>
      </div>

      <div className="flex-1 flex flex-col items-center justify-center">
        {/* Voice Visualization */}
        <motion.div
          className="relative mb-12"
          animate={{ scale: isListening ? 1.2 : 1 }}
        >
          <div className="w-48 h-48 rounded-full bg-gradient-to-br from-sky-500 to-indigo-600 flex items-center justify-center animate-pulse-glow relative shadow-2xl">
            {/* Animated rings */}
            <AnimatePresence>
              {isListening && (
                <>
                  <motion.div
                    className="absolute inset-0 rounded-full border-2 border-sky-400"
                    initial={{ scale: 1, opacity: 1 }}
                    animate={{ scale: 1.5, opacity: 0 }}
                    exit={{ scale: 1, opacity: 0 }}
                    transition={{ repeat: Infinity, duration: 1.5 }}
                  />
                  <motion.div
                    className="absolute inset-0 rounded-full border-2 border-indigo-400"
                    initial={{ scale: 1, opacity: 1 }}
                    animate={{ scale: 1.5, opacity: 0 }}
                    exit={{ scale: 1, opacity: 0 }}
                    transition={{ repeat: Infinity, duration: 1.5, delay: 0.5 }}
                  />
                </>
              )}
            </AnimatePresence>
            <span className="text-6xl">{isListening ? '🎤' : isSpeaking ? '🔊' : '🎙️'}</span>
          </div>
        </motion.div>

        {/* Status */}
        <motion.h2
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="text-3xl font-bold text-gradient mb-4"
        >
          {isListening ? 'Listening...' : isSpeaking ? 'Speaking...' : lastCommand || 'Voice Assistant'}
        </motion.h2>

        <p className="text-slate-400 mb-8 text-center max-w-md">
          {isListening 
            ? 'Speak now... I\'m ready to hear your commands' 
            : isSpeaking
            ? 'Playing response...'
            : 'Click the microphone to start voice commands or use "Hey Jarvis" wake word'}
        </p>

        {/* Controls */}
        <div className="flex gap-4 mb-8">
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            onClick={isListening ? handleStopListening : handleStartListening}
            disabled={!permissionGranted}
            className={`px-8 py-4 rounded-xl font-semibold text-lg transition-all ${
              isListening
                ? 'bg-red-500 hover:bg-red-600 text-white shadow-lg shadow-red-500/30'
                : 'bg-gradient-to-r from-sky-500 to-indigo-500 hover:opacity-90 text-white shadow-lg shadow-sky-500/30'
            } ${!permissionGranted ? 'opacity-50 cursor-not-allowed' : ''}`}
            aria-label={isListening ? 'Stop listening' : 'Start listening'}
          >
            {isListening ? '⏹ Stop Listening' : '🎤 Start Listening'}
          </motion.button>

          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            onClick={handleTestSpeech}
            disabled={isSpeaking || !permissionGranted}
            className="px-8 py-4 rounded-xl font-semibold text-lg bg-slate-700 hover:bg-slate-600 transition-colors text-white disabled:opacity-50 disabled:cursor-not-allowed"
            aria-label="Test speech synthesis"
          >
            {isSpeaking ? '🔊 Speaking...' : '🔊 Test Speech'}
          </motion.button>
        </div>

        {/* Waveform Visualization */}
        <AnimatePresence>
          {isListening && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              className="mt-8 flex items-center gap-1 h-20"
              aria-label="Voice waveform visualization"
            >
              {waveformHeight.map((height, i) => (
                <motion.div
                  key={i}
                  className="w-1.5 bg-gradient-to-t from-sky-500 to-indigo-400 rounded-full"
                  animate={{ height }}
                  transition={{ duration: 0.1 }}
                  style={{ minHeight: '20px' }}
                />
              ))}
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* Recent Commands */}
      {commands.length > 0 && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="glass-card p-6 mx-8 mb-8"
        >
          <h3 className="text-lg font-semibold mb-4 text-slate-300">Recent Voice Commands</h3>
          <div className="space-y-2 max-h-40 overflow-y-auto">
            {commands.map((cmd) => (
              <div
                key={cmd.id}
                className="flex items-center justify-between p-3 bg-slate-800/50 rounded-lg"
              >
                <div className="flex items-center gap-3">
                  <span className="text-green-400">✓</span>
                  <span className="text-slate-200">{cmd.command}</span>
                </div>
                <span className="text-xs text-slate-500">
                  {cmd.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' })}
                </span>
              </div>
            ))}
          </div>
        </motion.div>
      )}
    </div>
  )
}
