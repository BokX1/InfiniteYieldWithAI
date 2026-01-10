# Project Roadmap: SmartInfiniteYield (SIY)

This document outlines the planned technical and user experience improvements for the SmartInfiniteYield project.

---

## Version 1.3.0 - Stabilization & Experience (Q1 2026)

This release focuses on "Stabilization" (Core Architecture) and "Experience" (Smart Onboarding/UX), establishing a rock-solid foundation for future intelligence features.

### 🌟 Smart Onboarding Experience

- **Interactive "First-Run" Tour**: A guided, in-game walkthrough for new users.
  - **Live Interaction**: Highlights UI elements (Input, Mode Toggle) and guides the user to execute their first AI command.
  - **Context Awareness**: Recognizes the current game (e.g., "I see you're in a Tycoon! Try asking me to auto-click.")
  - **Visual Cues**: Uses pulsating glows to draw attention to relevant buttons.

### 🏗️ Core Architecture & Stabilization

- **Internal Event Bus**: A central "Signal" system to decouple UI, Logic, and Services, preventing spaghetti code.
- **Robust Lifecycle Management**: `Startup` and `Shutdown` controllers to ensure clean re-execution without crashes or memory leaks.
- **Unified Error Handling**: Centralized error reporting to gracefully handle failures without crashing the entire script.

### 🎨 UX & Integration

- **Native Theme Inheritance**: Automatically adopt the user's installed Infinite Yield theme colors and fonts by hooking into global `shade`/`text` tables.
- **Acoustic Feedback**: Subtle sound cues for AI processing states (Success chime, Error buzz, Processing hum).
- **Enhanced Dropdown Animations**: Smooth, polished transitions for the predictive text menu.

### 🧩 Ecosystem Utilization

- **Deep Source Integration**: Dynamically scrape IY's `Aliases` and `Keybinds` tables at runtime for full compatibility.
- **Plugin Bridge**: Expose SIY's AI capabilities (`askAI`, `executeSmartCommand`) to standard IY plugins, enabling AI-powered extensions.

### 🛡️ Code Quality

- **LuaU Type Strictness**: 100% type coverage for core modules.

---

## Version 1.4.0 - Advanced Intelligence & Ecosystem

Following the architectural stabilization in v1.3, we will focus on expanding intelligence and community features.

### 🧠 AI & Intelligence

- **Multi-Model Support**: Switch between OpenAI, Gemini, Claude, and Local LLMs.
- **Conversation Memory**: Short-term context persistence for follow-up commands.
- **Smart Suggestions**: Context-aware command recommendations based on game genre.

### 🔌 Plugin & Extension System

- **Custom Plugin API**: Allow community-created extensions and game-specific optimizations.
- **Custom Quick Actions**: User-editable mobile command grid.
- **Command Macros**: Record and playback complex command sequences.

### 🎨 UI/UX Overhaul

- **Theme System**: Presets (Dark, Light, OLED) and custom accent colors.
- **In-Game Settings**: Collapsible panel for all CONFIG options.
- **History & Favorites**: Searchable command history and starred commands.

---

## Future Considerations (v1.5.0+)

| Feature | Description | Status |
|---------|-------------|--------|
| **Voice Commands** | Speech-to-text input for hands-free operation | Under Research |
| **Game Profiles** | Automatic settings/macros per game | Planned |
| **Collaborative Mode** | Share commands with friends in real-time | Concept |
| **AI Training Mode** | Let users correct AI mistakes to improve accuracy | Under Research |
| **Visual Scripting** | Node-based command builder for complex automations | Concept |

---

## Contributing

We welcome community contributions! If you'd like to help implement any roadmap features:

1. Check the [Issues](https://github.com/BokX1/InfiniteYieldWithAI/issues) for open tasks
2. Fork the repository and create a feature branch
3. Submit a Pull Request with your implementation

---

*Last Updated: January 5, 2026*
