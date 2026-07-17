import { useState } from 'react'
import { motion } from 'framer-motion'

interface SettingsSection {
  id: string
  title: string
  icon: string
  settings: SettingItem[]
}

interface SettingItem {
  key: string
  label: string
  description: string
  type: 'toggle' | 'select' | 'input' | 'slider'
  value: any
  options?: string[]
}

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState('general')
  
  const settingsSections: SettingsSection[] = [
    {
      id: 'general',
      title: 'General',
      icon: '⚙️',
      settings: [
        {
          key: 'theme',
          label: 'Theme',
          description: 'Choose your preferred interface theme',
          type: 'select',
          value: 'dark',
          options: ['dark', 'light', 'auto']
        },
        {
          key: 'language',
          label: 'Language',
          description: 'Interface language',
          type: 'select',
          value: 'English',
          options: ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese']
        },
        {
          key: 'notifications',
          label: 'Notifications',
          description: 'Enable desktop notifications',
          type: 'toggle',
          value: true
        }
      ]
    },
    {
      id: 'ai',
      title: 'AI Model',
      icon: '🤖',
      settings: [
        {
          key: 'model',
          label: 'AI Model',
          description: 'Select the AI model to use',
          type: 'select',
          value: 'GPT-4 Turbo',
          options: ['GPT-4 Turbo', 'GPT-3.5', 'Claude', 'Local LLM']
        },
        {
          key: 'temperature',
          label: 'Creativity Level',
          description: 'Control response randomness (0-1)',
          type: 'slider',
          value: 0.7
        },
        {
          key: 'operationMode',
          label: 'Operation Mode',
          description: 'Online, offline, or auto mode',
          type: 'select',
          value: 'Auto',
          options: ['Auto', 'Online', 'Offline']
        }
      ]
    },
    {
      id: 'voice',
      title: 'Voice',
      icon: '🎤',
      settings: [
        {
          key: 'voiceEnabled',
          label: 'Voice Recognition',
          description: 'Enable voice commands',
          type: 'toggle',
          value: true
        },
        {
          key: 'wakeWord',
          label: 'Wake Word',
          description: 'Custom wake word to activate JARVIS',
          type: 'input',
          value: 'Hey Jarvis'
        },
        {
          key: 'voiceId',
          label: 'Voice',
          description: 'Select JARVIS voice',
          type: 'select',
          value: 'Default',
          options: ['Default', 'Male', 'Female', 'British', 'American']
        }
      ]
    },
    {
      id: 'privacy',
      title: 'Privacy',
      icon: '🔒',
      settings: [
        {
          key: 'memoryEnabled',
          label: 'Memory Storage',
          description: 'Store conversation history',
          type: 'toggle',
          value: true
        },
        {
          key: 'analytics',
          label: 'Usage Analytics',
          description: 'Help improve JARVIS with anonymous usage data',
          type: 'toggle',
          value: false
        },
        {
          key: 'encryption',
          label: 'Data Encryption',
          description: 'Encrypt stored conversations',
          type: 'toggle',
          value: true
        }
      ]
    },
    {
      id: 'automation',
      title: 'Automation',
      icon: '⚡',
      settings: [
        {
          key: 'automationEnabled',
          label: 'Automation',
          description: 'Enable task automation features',
          type: 'toggle',
          value: true
        },
        {
          key: 'safeMode',
          label: 'Safe Mode',
          description: 'Require confirmation for destructive actions',
          type: 'toggle',
          value: true
        }
      ]
    }
  ]

  const handleSettingChange = (sectionId: string, settingKey: string, newValue: any) => {
    console.log(`Setting changed: ${sectionId}.${settingKey} = ${newValue}`)
    // Implementation will save to backend
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <h1 className="text-4xl font-bold text-gradient mb-2">Settings</h1>
        <p className="text-slate-400">Configure JARVIS to your preferences</p>
      </motion.div>

      {/* Tabs */}
      <div className="flex gap-2 overflow-x-auto pb-2">
        {settingsSections.map((section) => (
          <button
            key={section.id}
            onClick={() => setActiveTab(section.id)}
            className={`px-4 py-2 rounded-lg whitespace-nowrap transition-all ${
              activeTab === section.id
                ? 'bg-gradient-to-r from-sky-500 to-indigo-500 text-white shadow-lg'
                : 'bg-slate-800 text-slate-400 hover:text-white hover:bg-slate-700'
            }`}
          >
            <span className="mr-2">{section.icon}</span>
            {section.title}
          </button>
        ))}
      </div>

      {/* Settings Content */}
      <div className="grid gap-6">
        {settingsSections
          .filter((section) => section.id === activeTab)
          .map((section) => (
            <motion.div
              key={section.id}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.3 }}
              className="glass-card p-6"
            >
              <h2 className="text-2xl font-semibold mb-6 flex items-center gap-3">
                <span className="text-3xl">{section.icon}</span>
                {section.title} Settings
              </h2>
              
              <div className="space-y-6">
                {section.settings.map((setting) => (
                  <div
                    key={setting.key}
                    className="flex items-center justify-between p-4 bg-slate-800/50 rounded-xl"
                  >
                    <div className="flex-1">
                      <h3 className="font-medium text-slate-200 mb-1">{setting.label}</h3>
                      <p className="text-sm text-slate-400">{setting.description}</p>
                    </div>
                    
                    <div className="ml-4">
                      {setting.type === 'toggle' && (
                        <button
                          onClick={() => handleSettingChange(section.id, setting.key, !setting.value)}
                          className={`relative w-14 h-7 rounded-full transition-colors ${
                            setting.value ? 'bg-sky-500' : 'bg-slate-600'
                          }`}
                          aria-label={`Toggle ${setting.label}`}
                        >
                          <div
                            className={`absolute top-1 w-5 h-5 bg-white rounded-full transition-transform ${
                              setting.value ? 'translate-x-8' : 'translate-x-1'
                            }`}
                          />
                        </button>
                      )}
                      
                      {setting.type === 'select' && (
                        <select
                          value={setting.value}
                          onChange={(e) => handleSettingChange(section.id, setting.key, e.target.value)}
                          className="bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 text-slate-200 focus:outline-none focus:border-sky-500"
                        >
                          {setting.options?.map((option) => (
                            <option key={option} value={option}>
                              {option}
                            </option>
                          ))}
                        </select>
                      )}
                      
                      {setting.type === 'input' && (
                        <input
                          type="text"
                          value={setting.value}
                          onChange={(e) => handleSettingChange(section.id, setting.key, e.target.value)}
                          className="bg-slate-700 border border-slate-600 rounded-lg px-3 py-2 text-slate-200 focus:outline-none focus:border-sky-500 w-64"
                        />
                      )}
                      
                      {setting.type === 'slider' && (
                        <div className="flex items-center gap-3">
                          <input
                            type="range"
                            min="0"
                            max="1"
                            step="0.1"
                            value={setting.value}
                            onChange={(e) => handleSettingChange(section.id, setting.key, parseFloat(e.target.value))}
                            className="w-32 accent-sky-500"
                          />
                          <span className="text-slate-300 w-12">{setting.value.toFixed(1)}</span>
                        </div>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </motion.div>
          ))}
      </div>

      {/* Save Button */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
        className="flex justify-end gap-4 pt-4"
      >
        <button className="px-6 py-3 bg-slate-700 hover:bg-slate-600 rounded-xl font-medium transition-colors">
          Reset to Defaults
        </button>
        <button className="px-6 py-3 bg-gradient-to-r from-sky-500 to-indigo-500 hover:opacity-90 rounded-xl font-medium transition-opacity shadow-lg">
          Save Changes
        </button>
      </motion.div>
    </div>
  )
}
