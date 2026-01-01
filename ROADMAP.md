# Project Roadmap: SmartInfiniteYield (SIY)

This document outlines the planned technical and user experience improvements for the SmartInfiniteYield project.

---

## Completed Features (v1.2.1)

### Technical Optimizations

| Feature | Status | Description |
|---------|--------|-------------|
| **Enhanced Bridge Reliability** | ✅ Complete | Event-based system using BindableEvents with `waitForBridge()` helper for instant bridge connection. |
| **Intelligent Command Caching** | ✅ Complete | Local cache using writefile/readfile to store successful AI translations. Configurable via CONFIG options. |
| **Advanced Target Resolution** | ✅ Complete | Levenshtein distance-based fuzzy matching for player names with prefix and contains matching. |
| **Code Optimization** | ✅ Complete | Reorganized codebase with helper functions, optimized patterns, and industry-standard formatting. |

### UI/UX Enhancements

| Feature | Status | Description |
|---------|--------|-------------|
| **Visual AI Processing** | ✅ Complete | Animated glowing aura with rotating gradient that pulses during AI processing. |
| **Command Preview** | ✅ Complete | Preview bar displays AI-generated command before execution for user verification. |
| **Mobile Quick Actions** | ✅ Complete | 9-button grid for one-tap commands on mobile devices. |

---

## Version 1.3.0 - Major Update (Planned)

Version 1.3 represents a significant evolution of SmartInfiniteYield, introducing multi-model AI support, a plugin ecosystem, and advanced automation features.

### 🧠 AI & Intelligence

#### 1. Multi-Model AI Support
The current system is locked to a single AI provider. Version 1.3 will introduce model flexibility.

- **Goal:** Allow users to switch between multiple AI models (OpenAI, Gemini, Claude, Local LLMs) via configuration.
- **Benefit:** Users can choose models based on speed, accuracy, cost, or privacy preferences. Local LLM support enables fully offline operation.
- **Implementation Notes:**
  - Add `CONFIG.ModelProvider` with options: `openai`, `gemini`, `claude`, `local`
  - Create abstraction layer for API calls to support different endpoints
  - Implement model-specific prompt optimization

#### 2. Conversation Memory & Context
Currently, each AI request is stateless with no memory of previous interactions.

- **Goal:** Implement short-term conversation memory that persists across commands within a session.
- **Benefit:** Enables contextual follow-ups like "do that again" or "faster this time" without repeating the full command.
- **Implementation Notes:**
  - Store last 5-10 interactions in memory
  - Include conversation history in AI context when relevant
  - Add `CONFIG.ConversationMemory` toggle

#### 3. Smart Command Suggestions
Proactively suggest commands based on game context and player behavior.

- **Goal:** Analyze game state and suggest relevant commands before the user types.
- **Benefit:** Reduces typing and helps users discover commands they didn't know existed.
- **Implementation Notes:**
  - Detect game type (obby, combat, roleplay) and suggest relevant commands
  - Track frequently used commands and surface them prominently
  - Show contextual tips in status bar

### 🔌 Plugin & Extension System

#### 4. Custom Plugin Architecture
Enable community-created extensions to expand functionality.

- **Goal:** Create a plugin API that allows users to add custom commands, UI elements, and integrations.
- **Benefit:** Community can extend SIY without modifying core code. Enables game-specific optimizations.
- **Implementation Notes:**
  - Define plugin manifest format (JSON/Lua)
  - Create plugin loader with sandboxed execution
  - Implement plugin marketplace browser within UI
  - Add `CONFIG.PluginsEnabled` and `CONFIG.PluginDirectory`

#### 5. Custom Quick Actions
Allow users to customize the mobile Quick Actions grid.

- **Goal:** Let users add, remove, and reorder Quick Action buttons with their own prompts.
- **Benefit:** Personalized one-tap commands for each user's playstyle.
- **Implementation Notes:**
  - Add Quick Actions editor UI
  - Store custom actions in local file
  - Support importing/exporting action sets

#### 6. Command Macros & Sequences
Enable recording and playback of command sequences.

- **Goal:** Allow users to record a series of commands and replay them with a single trigger.
- **Benefit:** Automate repetitive tasks and create complex command chains.
- **Implementation Notes:**
  - Add macro recording mode (`/record`, `/stop`)
  - Store macros with names and optional delays
  - Support macro keybinds

### 🎨 UI/UX Overhaul

#### 7. Theme System & Customization
The current UI uses a fixed dark theme with orange accents.

- **Goal:** Implement a theme system with multiple presets and custom color options.
- **Benefit:** Users can personalize the interface to match their preferences or reduce eye strain.
- **Implementation Notes:**
  - Create theme presets: Dark, Light, OLED Black, High Contrast
  - Add color picker for accent colors
  - Store theme preferences in local config

#### 8. Advanced Settings Panel
Currently, configuration requires editing the script directly.

- **Goal:** Create an in-game settings panel for all CONFIG options.
- **Benefit:** Users can adjust settings without reloading the script or editing code.
- **Implementation Notes:**
  - Design collapsible settings categories
  - Add toggles, sliders, and dropdowns for each option
  - Implement real-time preview for visual settings

#### 9. Command History & Favorites
No way to quickly access previously used commands.

- **Goal:** Add command history browser and favorites system.
- **Benefit:** Quick access to frequently used or recent commands without retyping.
- **Implementation Notes:**
  - Store last 50 commands with timestamps
  - Add star/favorite functionality
  - Create searchable history panel

### 📊 Analytics & Monitoring

#### 10. Performance Dashboard
Users have no visibility into system performance.

- **Goal:** Add optional telemetry dashboard showing cache hit rates, AI response times, and command statistics.
- **Benefit:** Users can understand system performance and optimize their usage patterns.
- **Implementation Notes:**
  - Track cache hits vs misses
  - Measure AI response latency
  - Display statistics in collapsible panel
  - All telemetry local-only (no external reporting)

#### 11. Error Recovery & Diagnostics
When errors occur, users have limited debugging information.

- **Goal:** Implement comprehensive error logging with suggested fixes.
- **Benefit:** Faster troubleshooting and better user support.
- **Implementation Notes:**
  - Create error log with timestamps and context
  - Add "Report Issue" button that copies diagnostic info
  - Implement automatic retry with exponential backoff

### 🔒 Security & Privacy

#### 12. Enhanced Privacy Mode
Some users want to minimize data sent to external services.

- **Goal:** Add privacy mode that maximizes local processing and minimizes API calls.
- **Benefit:** Reduced data exposure for privacy-conscious users.
- **Implementation Notes:**
  - Expand FastMap to cover more natural language patterns
  - Add `CONFIG.PrivacyMode` that disables AI for non-essential features
  - Implement local-only fuzzy matching improvements

#### 13. Executor Compatibility Layer
Different executors have varying API support.

- **Goal:** Create comprehensive compatibility layer that gracefully handles missing APIs.
- **Benefit:** Consistent experience across all supported executors.
- **Implementation Notes:**
  - Detect executor capabilities on startup
  - Provide fallbacks for missing functions
  - Display compatibility warnings for limited executors

---

## Version 1.4.0 - Future Considerations

These features are under consideration for future releases beyond v1.3.

| Feature | Description | Status |
|---------|-------------|--------|
| **Voice Commands** | Speech-to-text input for hands-free operation | Under Research |
| **Game Profiles** | Automatic settings/macros per game | Planned |
| **Collaborative Mode** | Share commands with friends in real-time | Concept |
| **AI Training Mode** | Let users correct AI mistakes to improve accuracy | Under Research |
| **Visual Scripting** | Node-based command builder for complex automations | Concept |
| **Cross-Platform Sync** | Sync settings and cache across devices | Under Research |

---

## Contributing

We welcome community contributions! If you'd like to help implement any roadmap features:

1. Check the [Issues](https://github.com/BokX1/InfiniteYieldWithAI/issues) for open tasks
2. Fork the repository and create a feature branch
3. Submit a Pull Request with your implementation
4. Join discussions in the Discord server

---

*Last Updated: January 2, 2026*
