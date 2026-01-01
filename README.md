# SmartInfiniteYield (SIY) - V1.2.1 Stable

**Original Idea by [VolQ5](https://github.com/BokX1/RbxLuauLLM) | Powered by Pollinations.AI (LLM Model)**

---

## Overview

**SmartInfiniteYield** is an open-source, next-generation wrapper for the popular Roblox admin script, [Infinite Yield](https://github.com/EdgeIY/infiniteyield). Unlike standard wrappers, SIY implements a **Self-Correcting Logic Engine** that translates natural language into precise execution strings.

The system features a **Recursive Feedback Loop**: if the AI targets a non-existent player or generates invalid syntax, the script detects the error, injects the correct server context, and forces the AI to fix its own mistake before executing. The API is protected by CloudFlare to prevent abuse.

---

## Key Features

### Intelligent Command Processing

| Feature | Description |
|---------|-------------|
| **Hybrid Execution Engine** | Zero-latency local execution for 200+ commands, with AI fallback for complex natural language |
| **Intelligent Caching** | Learns your phrases and executes them instantly without API calls |
| **Cache Management** | Use `clearcache` to reset learned commands, `cacheinfo` to view cache status |
| **Fuzzy Player Targeting** | Type partial names like "kill valk" and it resolves to "Valkorym" automatically |
| **Natural Chain Detection** | Understands requests like "fly and goto random" and splits them correctly |

### Smart Interface

| Feature | Description |
|---------|-------------|
| **Predictive Dropdown** | Google-style suggestions with priority ranking as you type |
| **Command Preview** | See exactly what will execute before it runs |
| **Visual Processing Indicator** | Animated glow effect shows when AI is thinking |
| **Mobile Quick Actions** | One-tap grid with 9 common commands for mobile users |

### Keybinds & Controls

| Feature | Description |
|---------|-------------|
| **Master Toggle** | Press `Right Shift` to instantly show/hide the interface |
| **Smart Binds** | Bind once, toggle automatically (e.g., `bind f fly` handles both fly and unfly) |
| **Adaptive UI** | Automatically scales for PC (500px) or Mobile (90% width) |

---

## Installation

### Prerequisites

You need a Roblox Executor that supports `request`, `http_request`, or `fluxus.request`. Standard Roblox Studio cannot run this script due to HTTP header restrictions.

### Quick Start

Copy and execute this script in your executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/BokX1/InfiniteYieldWithAI/refs/heads/main/InfiniteYieldWithAI.Lua"))()
```

### Development Version

For the latest features (may be unstable):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/BokX1/InfiniteYieldWithAI/refs/heads/main/InfiniteYieldWithAI_Dev.Lua"))()
```

---

## Usage Guide

### The Interface

The main interface consists of three primary elements:

| Element | Function |
|---------|----------|
| **Input Box** | Type your command or natural language request |
| **Mode Button** | Toggle between CMD (orange) and CHAT (blue) modes |
| **Minimize (-)** | Collapse to floating icon |

### CMD Mode (Orange)

CMD Mode translates natural language into Infinite Yield commands and executes them.

**Example 1: Player Targeting**
> **You:** "Fling that bacon hair guy"
> **SIY:** Scans players → Finds "BaconHairUser_99" → Executes `;fling BaconHairUser_99`

**Example 2: Direct Commands**
> **You:** "Fly at speed 50"
> **SIY:** Matches movement database → Executes `;fly 50`

**Example 3: Fuzzy Matching**
> **You:** "kill valk"
> **SIY:** Fuzzy matches "valk" to "Valkorym" → Executes `;kill Valkorym`

### CHAT Mode (Blue)

CHAT Mode provides game-specific advice and information without executing commands.

**Example:**
> **You:** "Where is the safe spot?"
> **SIY:** Detects game is "Tower of Hell" → Returns: *"Stay on the center platforms to avoid the rotating lasers."*

### Mobile Quick Actions

Mobile users can tap the ⚡ button to reveal a 3x3 grid of common commands:

| Row 1 | Row 2 | Row 3 |
|-------|-------|-------|
| Fly | Speed | ESP |
| Noclip | God | Teleport |
| Kill | Reset | Anti-Lag |

---

## Configuration

Customize SIY by modifying the `CONFIG` table at the top of the script:

```lua
local CONFIG = {
    -- API Settings
    ApiKey = "Null",                    -- Your API key (if required)
    Endpoint = "https://...",           -- AI endpoint URL
    Model = "openai",                   -- AI model to use
    MaxRetries = 2,                     -- Retry attempts for failed requests
    
    -- Cache Settings (NEW in v1.2.1)
    CacheEnabled = true,                -- Enable intelligent caching
    CacheFile = "SIY_CommandCache.json", -- Local cache filename
    MaxCacheEntries = 100,              -- Maximum cached commands
}
```

### Cache System

The intelligent caching system learns your frequently used phrases:

| Setting | Default | Description |
|---------|---------|-------------|
| `CacheEnabled` | `true` | Toggle the learning cache on/off |
| `CacheFile` | `SIY_CommandCache.json` | Filename for persistent cache |
| `MaxCacheEntries` | `100` | Maximum phrases to remember |

When you use a phrase like "make me fast" and the AI translates it to `;speed 50`, that mapping is cached. Next time you type the same phrase, it executes instantly without an API call.

---

## Architecture

### Hybrid Dual-Path Engine

SmartInfiniteYield V1.2.1 uses a sophisticated routing system that combines local speed with AI intelligence.

**Path A: Fast Path (Local Execution)**

When you type a known command like `fly` or `speed 50`, the script checks its internal FastMap dictionary containing 200+ regex patterns. If a match is found, execution is instant with zero latency and no API calls.

**Path B: Neuro-Symbolic Bridge (AI Execution)**

For natural language like "kill the guy in red", the script captures the server state (player list, game context) and sends it to the AI. The AI analyzes the request and returns the appropriate command.

### Validation-Retry Loop

The anti-hallucination system prevents errors through recursive validation:

1. AI suggests a command (e.g., `;goto Volcano`)
2. Script validates the target exists
3. If invalid, script sends feedback: `[ERROR: Target 'Volcano' not found. Did you mean 'VolQ5'?]`
4. AI retries with corrected command
5. Valid command executes

### Event-Based Bridge System

Version 1.2.1 introduced an event-based bridge using BindableEvents, replacing the previous polling system. This provides instant bridge connection and eliminates "Bridge not connected" errors.

---

## What's New in V1.2.1

### Features Added

| Feature | Description |
|---------|-------------|
| **Event-Based Bridge** | Instant connection using BindableEvents instead of polling |
| **Intelligent Caching** | Learns phrases and executes without API calls |
| **Fuzzy Targeting** | Levenshtein distance matching for player names |
| **Processing Glow** | Animated visual indicator during AI processing |
| **Command Preview** | See commands before execution |
| **Quick Actions** | Mobile-optimized one-tap command grid |
| **Interactive Tutorial** | 8-step onboarding that teaches all features before unlocking GUI |

### Code Quality Improvements

The codebase was refactored for efficiency and maintainability:

| Improvement | Description |
|-------------|-------------|
| **Reorganized Structure** | 18 clearly defined sections with numbered headers |
| **Helper Functions** | Reusable `createInstance()` reduces code duplication |
| **Optimized Patterns** | Improved pcall handling and iterator usage |
| **Standard Formatting** | Consistent style following Lua/Roblox conventions |

---

## Roadmap

### Coming in V1.3.0 (Major Update)

| Feature | Description |
|---------|-------------|
| **Multi-Model Support** | Switch between OpenAI, Gemini, Claude, or Local LLMs |
| **Plugin System** | Community-created extensions and custom commands |
| **Theme Customization** | Multiple color themes and custom accent colors |
| **Command Macros** | Record and replay command sequences |
| **Settings Panel** | In-game configuration without editing code |
| **Conversation Memory** | Context-aware follow-up commands |

See the full [Roadmap](RoadMap.md) for detailed plans.

---

## Changelog

See [Changelog.md](Changelog.md) for the complete version history.

### Recent Updates

**V1.2.1** - Event-based bridge, intelligent caching with management commands, fuzzy targeting, visual feedback, mobile quick actions, interactive 8-step tutorial, code optimization

**V1.2.0** - Split-context strategy, predictive dropdown, smart keybinds, complete command database

**V1.1.0** - Cloudflare security, logic engine improvements, responsive UI

**V1.0.0** - Initial release with AI translation and dual-mode interface

---

## License

Licensed under the **Apache License, Version 2.0**. You may obtain a copy of the License at:

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

---

## Credits

| Role | Credit |
|------|--------|
| **Original Idea & Concept** | VolQ5 |
| **AI Integration** | Pollinations.AI |
| **Backend Framework** | Infinite Yield (EdgeIY) |

---

## Support

For issues, feature requests, or contributions:

- **GitHub Issues:** [Report a Bug](https://github.com/BokX1/InfiniteYieldWithAI/issues)
- **Discord:** Join the support server via `;discord` command in-game
