# SmartInfiniteYield (SIY)

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.3.2-green.svg)](docs/CHANGELOG.md)
[![Roblox](https://img.shields.io/badge/Platform-Roblox-red.svg)](https://www.roblox.com/)
[![Powered by Pollinations.AI](https://img.shields.io/badge/Powered%20by-Pollinations.AI-blueviolet.svg)](https://pollinations.ai/)

> **AI-Powered Natural Language Interface for Infinite Yield**  
> *Transform "make me fly fast" into `;fly ;flyspeed 5` instantly.*

---

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Usage Guide](#usage-guide)
- [Configuration](#configuration)
- [Architecture](#architecture)
- [Plugin API](#plugin-api)
- [FAQ](#faq)
- [Contributing](#contributing)
- [Roadmap](#roadmap)
- [Credits](#credits)
- [License](#license)

---

## Features

SmartInfiniteYield bridges natural language and precise command execution with a **Hybrid Dual-Path Engine**.

### 🧠 Intelligent Core

| Feature | Description |
|---------|-------------|
| **Hybrid Engine** | Zero-latency local execution for 400+ commands + AI fallback for complex queries |
| **Intelligent Caching** | Learns your phrases (e.g., "make me fast" → `;speed 50`) for instant future use |
| **Fuzzy Player Targeting** | Type "goto valk" and it resolves to "Valkorym" automatically |
| **Anti-Hallucination** | Validates AI-generated commands before execution to prevent errors |
| **Dynamic Command Map** | Commands extracted from IY's `cmds` table at runtime—always up-to-date |

### 📱 Smart Interface

| Feature | Description |
|---------|-------------|
| **Compact Mode** | Minimalist 65px height (CMD mode) keeps your screen clear |
| **Quick Actions** | One-tap mobile grid for toggleable commands (Fly, Noclip, ESP, etc.) |
| **Predictive Dropdown** | Google-style suggestions with priority ranking as you type |
| **Waypoint System** | Save locations (`swp base`) and teleport back (`waypoint base`) |
| **ChatGPT-like CHAT Mode** | **Friendly Companion** persona, bubbles with role indicators, timestamps, and memory |

### ✨ User Experience

| Feature | Description |
|---------|-------------|
| **Sound Feedback** 🎵 | Acoustic cues for success, error, and processing states |
| **Onboarding Tour** 🔦 | Interactive 8-step first-run guide |
| **Theme Inheritance** 🎨 | Automatically adopts your Infinite Yield theme colors |
| **Smooth Animations** | Pulsating glow effects and polished UI transitions |
| **Auto-Context Injection** | Game name, genre, team, and player count sent to AI |

### 🏗️ Architecture

| Feature | Description |
|---------|-------------|
| **Event Bus** | Decoupled communication between UI and logic layers |
| **Lifecycle Manager** | Clean startup/shutdown with proper memory cleanup |
| **Error Handler** | Centralized reporting prevents script crashes |
| **Plugin Bridge** | `_G.SIY` API for external script integration |

---

## Quick Start

### Prerequisites

A Roblox executor supporting one of:

- `syn.request` (Synapse)
- `http.request` / `http_request`
- `fluxus.request` (Fluxus)
- `request` (Generic)

### Installation

Copy and execute this script in your executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/BokX1/InfiniteYieldWithAI/refs/heads/main/InfiniteYieldWithAI.Lua"))()
```

> **Development Version**: Replace `InfiniteYieldWithAI.Lua` with `InfiniteYieldWithAI_Dev.Lua` for bleeding-edge features.

---

## Usage Guide

### Modes

| Mode | Color | Purpose | Example |
|------|-------|---------|---------|
| **CMD** | 🟠 Orange | Execute commands | "fly and goto john", "make all parts transparent" |
| **CHAT** | 🔵 Blue | Friendly chat | "How do I win this game, bestie?" |

### Quick Actions (Mobile)

Tap the ⚡ button to reveal a 3×3 grid of toggleable commands:

| | | |
|---|---|---|
| Fly | Speed | ESP |
| Noclip | Jump | Invisible |
| Teleport | Reset | Anti-Lag |

### Waypoint System

| Command | Description | Example |
|---------|-------------|---------|
| `swp [name]` | Save current position | `swp base` |
| `waypoint [name]` or `wp [name]` | Teleport to saved waypoint | `waypoint base` |
| `waypoints` | List all saved waypoints | |
| `deletewaypoint [name]` or `dwp [name]` | Delete a waypoint | `dwp base` |

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `Right Shift` | Toggle GUI visibility |
| `Enter` | Execute current input |

### Special Commands

| Command | Description |
|---------|-------------|
| `clearcache` | Wipe all learned command mappings |
| `cacheinfo` | Show cache statistics |

---

## Configuration

Customize SIY by modifying the `CONFIG` table at the top of the script:

### API Settings

| Option | Default | Description |
|--------|---------|-------------|
| `ApiKey` | `"Null"` | Optional Bearer token for API authentication |
| `Endpoint` | `"https://..."` | AI API endpoint URL |
| `Model` | `"openai"` | AI model to use |
| `MaxRetries` | `2` | Maximum API request retries |
| `RequestTimeout` | `10` | Seconds to wait for API response |

### Cache Settings

| Option | Default | Description |
|--------|---------|-------------|
| `CacheEnabled` | `true` | Enable/disable command learning |
| `CacheFile` | `"SIY_CommandCache.json"` | Local cache file name |
| `MaxCacheEntries` | `100` | Maximum cached commands (LRU eviction) |

### Rate Limiting

| Option | Default | Description |
|--------|---------|-------------|
| `AIRequestCooldown` | `0.5` | Minimum seconds between AI requests |

### UI Timing

| Option | Default | Description |
|--------|---------|-------------|
| `PreviewDelay` | `0.3` | Seconds to show preview before execution |
| `ErrorDisplayTime` | `2` | Seconds to display error messages |
| `StatusFadeTime` | `3` | Seconds before status text fades |
| `DropdownFocusDelay` | `0.15` | Delay before hiding dropdown on blur |
| `DropdownMaxItems` | `6` | Maximum dropdown suggestions |

### Fuzzy Matching

| Option | Default | Description |
|--------|---------|-------------|
| `FuzzyMatchMinThreshold` | `2` | Minimum Levenshtein distance threshold |
| `FuzzyMatchRatio` | `0.5` | Ratio of input length for threshold |
| `FuzzyMatchMinInputLength` | `3` | Minimum chars for fuzzy matching |

### Bridge Connection

| Option | Default | Description |
|--------|---------|-------------|
| `BridgeMaxRetries` | `5` | Max bridge connection retries |
| `BridgeRetryDelay` | `0.5` | Delay between retries (seconds) |
| `BridgeTimeout` | `15` | Total connection timeout (seconds) |

### Mobile UI

| Option | Default | Description |
|--------|---------|-------------|
| `MobileQuickActionScale` | `1.0` | Scale factor for quick actions |
| `MobileMinCellSize` | `44` | Minimum touch target size (iOS/Android standard) |

### Sound & Tour (v1.3.0+)

| Option | Default | Description |
|--------|---------|-------------|
| `EnableSounds` | `false` | Enable/disable acoustic feedback |
| `SoundVolume` | `0.5` | Volume level (0-1) |
| `EnableTour` | `true` | Show onboarding tour on first run |

---

## Architecture

SIY v1.3.x features an enterprise-grade modular architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                         SIY Core                            │
├─────────────────────────────────────────────────────────────┤
│  EventBus          │  Decoupled pub/sub communication      │
│  LifecycleManager  │  Startup/shutdown, memory cleanup     │
│  ErrorHandler      │  Centralized reporting, safe wrappers │
├─────────────────────────────────────────────────────────────┤
│                      Integrations                           │
├─────────────────────────────────────────────────────────────┤
│  IYIntegration     │  Scrape aliases, keybinds, commands   │
│  ThemeManager      │  Inherit IY theme colors              │
│  SoundManager      │  Play processing/success/error sounds │
├─────────────────────────────────────────────────────────────┤
│                      UI Managers                            │
├─────────────────────────────────────────────────────────────┤
│  AnimationManager  │  Smooth tweens, pulsating effects     │
│  TourManager       │  First-run onboarding flow            │
└─────────────────────────────────────────────────────────────┘
```

### Key Design Patterns

- **Namespace Isolation**: All globals use `SmartInfiniteYield` namespace
- **Connection Registry**: Centralized tracking prevents memory leaks
- **Event-Driven Communication**: UI and logic communicate via `EventBus`
- **Error Wrapping**: `ErrorHandler:wrap()` protects critical functions

---

## Plugin API

SIY exposes a global API at `_G.SIY` (v2.0) for external script integration:

### Methods

```lua
-- Execute a natural language command
_G.SIY.askAI("make me fly fast")

-- Execute a direct IY command
_G.SIY.executeCommand(";fly ;speed 100")

-- Get current status
local status = _G.SIY.getStatus()
-- Returns: { connected = true, mode = "CMD", ... }
```

### Events

Subscribe to SIY events via the internal EventBus:

| Event | Payload | Description |
|-------|---------|-------------|
| `AI_REQUEST_START` | `nil` | AI processing started |
| `AI_REQUEST_COMPLETE` | `{command}` | AI returned a command |
| `AI_REQUEST_ERROR` | `{error}` | AI request failed |
| `COMMAND_EXECUTED` | `{command}` | Command was executed |

---

## FAQ

### "Bridge not connected" error

The bridge connects SIY to Infinite Yield's command processor. If this fails:

1. **Wait a few seconds** – Bridge has auto-retry (5 attempts)
2. **Re-execute the script** – Clears stale connections
3. **Check executor compatibility** – Ensure HTTP requests work

### Which executors are supported?

Any executor with `http_request` or equivalent:

- ✅ Synapse X
- ✅ Fluxus
- ✅ KRNL
- ✅ Script-Ware
- ⚠️ Others may work if they support HTTP

### AI says "command not found"

- The AI only knows commands documented in Infinite Yield
- Try rephrasing your request
- Use `cacheinfo` to check if cached commands exist

### How do I clear learned commands?

Type `clearcache` in CMD mode to wipe all cached phrase-to-command mappings.

---

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

**Quick Start:**

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make changes to `InfiniteYieldWithAI_Dev.Lua`
4. Test thoroughly on PC and mobile
5. Submit a Pull Request

---

## Roadmap

### Current Focus (v1.3.x)

- Bridge reliability improvements
- Mobile experience refinements
- Performance optimizations

### Coming in v1.4.0

- 🧠 Multi-model AI support (GPT, Gemini, Claude)
- 🔌 Custom plugin system
- 🎨 In-game settings panel

See [ROADMAP.md](docs/ROADMAP.md) for the complete roadmap.

---

## Credits

| Contributor | Role |
|-------------|------|
| **[VolQ5](https://github.com/BokX1/RbxLuauLLM)** | Original Idea & Logic |
| **[Pollinations.AI](https://pollinations.ai)** | AI Integration & LLM Model |
| **[EdgeIY](https://github.com/EdgeIY/infiniteyield)** | Infinite Yield Backend |

---

## License

This project is licensed under the **Apache License 2.0** – see the [LICENSE](LICENSE) file for details.

```
Copyright 2025-2026 SmartInfiniteYield Contributors

Licensed under the Apache License, Version 2.0
```

---

<p align="center">
  <sub>Made with ❤️ by the SIY community</sub>
</p>
