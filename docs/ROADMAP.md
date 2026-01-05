# Project Roadmap: SmartInfiniteYield (SIY)

This document outlines the planned technical and user experience improvements for the SmartInfiniteYield project.

---

## Completed Features (v1.2.2)

### Technical Optimizations

| Feature | Status | Description |
|---------|--------|-------------|
| **Enhanced Bridge Reliability** | ✅ Complete | Event-based system using BindableEvents with `waitForBridge()` helper for instant bridge connection. |
| **Intelligent Command Caching** | ✅ Complete | Local cache using writefile/readfile to store successful AI translations. Configurable via CONFIG options. |
| **Advanced Target Resolution** | ✅ Complete | Levenshtein distance-based fuzzy matching for player names with prefix and contains matching. |
| **Code Optimization** | ✅ Complete | Reorganized codebase with helper functions, optimized patterns, and industry-standard formatting. |
| **API Request Resilience** | ✅ Complete | Endpoint calls honor `RequestTimeout`, retry up to `MaxRetries`, and surface clearer errors. |
| **HTTP Capability Guard** | ✅ Complete | Blocks only AI requests when executor HTTP support is unavailable, preserving offline functionality. |

### UI/UX Enhancements

| Feature | Status | Description |
|---------|--------|-------------|
| **Visual AI Processing** | ✅ Complete | Animated glowing aura with rotating gradient that pulses during AI processing. |
| **Command Preview** | ✅ Complete | Preview bar displays AI-generated command before execution for user verification. |
| **Mobile Quick Actions** | ✅ Complete | 9-button grid for one-tap commands on mobile devices. |
| **Compact Mode UI** | ✅ Complete | Streamlined header layout with compact mode dropdown and optimized spacing. |
| **ChatGPT-like CHAT Mode** | ✅ Complete | Modern message bubbles, role indicators, and timestamps for a conversational experience. |

---

## Version 1.3.0 - The Headless Engine (In Progress)

Version 1.3 represents a fundamental architectural shift, deconstructing the monolithic script into a **Client-Server model** to enable headless execution and robust AI feedback loops.

### 🏗️ Core Architecture: The "Headless" Engine

#### 1. The Injection Layer (The "Shim")
Trick the backend into running without a GUI to enable pure AI control.
- **Goal:** Decouple logic from presentation.
- **Key Tasks:**
  - [ ] **Dynamic Loading**: Fetch `IYsource.lua` content via `game:HttpGet`.
  - [ ] **Virtualization Shim**: Inject a mocking layer before compilation.
  - [ ] **Mock GUI**: Create dummy tables for UI elements (`Holder`, `Title`, etc.) that accept standard calls but do nothing.
  - [ ] **Metatable Protection**: Redirect `Instance.new` calls to dummy objects.

#### 2. Logic Hardening (The "Feedback Loop")
Ensure the AI knows exactly what happened after it issues a command.
- **Goal:** Implement a closed-loop communication system.
- **Key Tasks:**
  - [ ] **Closed-Loop Feedback**: Write (AI command) -> Read (`_G.IY_Output`) -> Report (AI Context).
  - [ ] **IO Redirection**: Overwrite `notify()` to write to shared tables instead of showing UI notifications.
  - [ ] **Crash Protection**: Wrap execution in `pcall` to catch and report backend errors safely.
  - [ ] **Concurrency Management**: Automatic cleanup of existing backend instances to prevent leaks.

#### 3. Standardization (The "Service Architecture")
Clean code structure for easy maintenance and updates.
- **Goal:** Implement a formal service-oriented pattern.
- **Key Tasks:**
  - [ ] **Service Pattern Separation**: Organize into `[CONFIG]`, `[SERVICES]`, and `[CONTROLLER]`.
  - [ ] **Unified API Contract**: Formalize `BridgeAPI.Execute(cmd)` and `BridgeAPI.GetOutput()`.
  - [ ] **Type Checking**: Add Luau `--!strict` definitions for robust development.
  - [ ] **Hot-Swap Support**: Allow updating the backend independently of the AI script.

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
