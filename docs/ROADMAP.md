# Project Roadmap: SmartInfiniteYield (SIY)

> Building the most intuitive AI interface for Roblox command execution.

---

## Current Status

| | |
|---|---|
| **Version** | v1.3.3 Stable |
| **Phase** | Stabilization & Polish |
| **Last Updated** | January 16, 2026 |

---

## Release Timeline

| Version | Target | Focus | Status |
|---------|--------|-------|--------|
| v1.3.x | Q1 2026 | Stabilization & Bug Fixes | 🟢 Active |
| v1.4.0 | Q2 2026 | Advanced AI & Plugin System | 🟡 Planning |
| v1.5.0 | Q3 2026 | UI/UX Overhaul | 📋 Conceptual |
| v2.0.0 | 2027 | Next Generation | 🔮 Vision |

---

## 🚧 Current Focus: v1.3.x

Stabilizing the architecture introduced in v1.3.0.

- [x] Event-Based Bridge system
- [x] Sound feedback system
- [x] Onboarding tour
- [x] Theme inheritance
- [x] Plugin Bridge API (v2.0)
- [ ] Bridge edge case handling (disconnects, game switches)
- [ ] Mobile touch target refinements
- [ ] Performance profiling and optimization

---

## 📅 Next Release: v1.4.0

*Target: Q2 2026*

### 🧠 AI & Intelligence

| Feature | Description | Priority |
|---------|-------------|----------|
| **Multi-Model Support** | Switch between OpenAI, Gemini, Claude, Local LLMs | High |
| **Conversation Memory** | Short-term context for follow-up commands ("now faster") | High |
| **Smart Suggestions** | Context-aware recommendations based on game genre | Medium |
| **Command Macros** | Record and playback complex command sequences | Medium |

### 🔌 Plugin & Extension System

| Feature | Description | Priority |
|---------|-------------|----------|
| **Custom Plugin API** | Documented API for community extensions | High |
| **Custom Quick Actions** | User-editable mobile command grid | Medium |
| **Event Hooks** | Subscribe to SIY events from external scripts | Medium |

### 🎨 UI/UX Improvements

| Feature | Description | Priority |
|---------|-------------|----------|
| **In-Game Settings** | Collapsible panel to modify CONFIG without editing code | High |
| **History & Favorites** | Searchable command history and starred commands | Medium |
| **Theme Presets** | Dark, Light, OLED, and custom accent colors | Low |

---

## 🔭 Future Releases: v1.5.0+

### v1.5.0 - Experience Polish

| Feature | Description |
|---------|-------------|
| **Unified Error Handling** | Severity levels, user-facing messages, debug mode |
| **Comprehensive Type Safety** | Full LuaU type annotations |
| **In-Game Diagnostics** | Performance metrics, connection status panel |
| **Code Standardization** | EditorConfig, consistent patterns |

### v1.6.0 - Advanced Features

| Feature | Description |
|---------|-------------|
| **Game Profiles** | Automatic settings/macros per game ID |
| **Service Isolation** | Dependency injection pattern |
| **Internal Event Bus v2** | Typed events, middleware support |

---

## 🔮 Long-Term Vision

Conceptual features under research:

| Feature | Description | Status |
|---------|-------------|--------|
| **Voice Commands** | Speech-to-text for hands-free operation | Researching |
| **Visual Scripting** | Node-based command builder for automations | Concept |
| **Collaborative Mode** | Share commands/macros with friends in real-time | Concept |
| **Cross-Platform Sync** | Sync cache and settings across devices | Concept |

---

## ✅ Completed Milestones

### v1.3.3 - Type Safety & Performance (January 2026)

- Comprehensive LuaU type annotations (25+ typed fields)
- FastMap O(1) indexing with character groups
- Levenshtein distance optimization with early exit
- Drag system auto-cleanup on frame destruction
- Fixed cache commands (`clearcache`, `cacheinfo`) not executing

### v1.3.2 - Chat Persona & Bug Fixes (January 2026)

- Revamped CHAT mode persona (friendly, gamer-like)
- Fixed duplicate EventBus declaration
- Fixed drag system memory leak
- Fixed PluginBridge method name
- Removed 24 duplicate FastMap patterns

### v1.3.1 - Mobile & Bridge Improvements (January 2026)

- Bridge failure notification for users
- Mobile touch targets increased to 44px
- Mobile Quick Actions toggle relocated
- Fixed duplicate CHAT/CMD mode calls
- Fixed SoundManager connection leak

### v1.3.0 - Stabilization & Experience (January 2026)

- Event Bus architecture for decoupled communication
- Lifecycle Manager for clean re-execution
- Unified Error Handler with wrapping
- Sound System (Processing, Success, Error)
- Interactive 8-step Onboarding Tour
- Theme inheritance from Infinite Yield
- Plugin Bridge API v2.0

### v1.2.0 - Intelligence & Speed (December 2025)

- Hybrid Dual-Path Engine (Local + AI)
- Intelligent Caching with LRU eviction
- Fuzzy Player Targeting (Levenshtein distance)
- Mobile Quick Actions grid
- ChatGPT-like CHAT mode interface
- Waypoint system (`swp`, `gotowp`)
- Event-Based Bridge connection

### v1.1.0 - Security & Performance (November 2025)

- Cloudflare API protection
- Logic Engine v2
- Input sanitization layer
- Responsive UI improvements

### v1.0.0 - Initial Release (October 2025)

- AI translation (natural language → commands)
- Dual modes (CMD + CHAT)
- Processing indicator
- Basic UI

---

## How to Contribute

We welcome contributions at all levels!

1. Check [Issues](https://github.com/BokX1/InfiniteYieldWithAI/issues) for open tasks
2. Look for `good first issue` or `help wanted` labels
3. Read [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines
4. Fork → Branch → PR

---

## Feedback

Have a feature idea or found a bug?

- **Feature Requests**: [Open an issue](https://github.com/BokX1/InfiniteYieldWithAI/issues/new?template=feature_request.md)
- **Bug Reports**: [Open an issue](https://github.com/BokX1/InfiniteYieldWithAI/issues/new?template=bug_report.md)
- **Questions**: Use the `;discord` command in-game

---

*This roadmap is subject to change based on community feedback and priorities.*
