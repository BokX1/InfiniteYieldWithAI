
# SmartInfiniteYield (SIY) - V1.3.0 Stable

**Original Idea by [VolQ5](https://github.com/BokX1/RbxLuauLLM) | Powered by Pollinations.AI (LLM Model)**

---

## Overview

**SmartInfiniteYield (SIY)** is an open-source, AI-powered wrapper for [Infinite Yield](https://github.com/EdgeIY/infiniteyield), the popular Roblox admin script. It bridges the gap between natural human language and precise command execution, allowing users to control the game using everyday phrases instead of memorizing syntax.

At its core, SIY features a **Hybrid Dual-Path Execution Engine** that intelligently routes requests through either instant local processing (for 200+ known commands) or AI-powered translation (for complex natural language). The system includes a **Self-Correcting Logic Engine** that validates commands before execution—if the AI targets a non-existent player or generates invalid syntax, the script automatically detects the error, provides context, and forces the AI to correct itself.

Key innovations include **Intelligent Caching** that learns your phrases over time for instant execution, **Fuzzy Player Targeting** using Levenshtein distance matching, and a **Mobile-First Design** with one-tap Quick Actions. Whether you're a power user seeking efficiency or a newcomer who doesn't want to memorize commands, SIY adapts to your workflow.

```
"Make me fly"              →  ;fly
"Teleport to that guy"     →  ;goto PlayerName  
"Go to my base waypoint"   →  ;gotowp base
"Make me super fast"       →  ;speed 100
```

---

## Key Features

### Intelligent Command Processing

| Feature | Description |
|---------|-------------|
| **Hybrid Execution Engine** | Zero-latency local execution for 400+ commands via dynamic command scraping, with AI fallback for complex natural language |
| **Intelligent Caching** | Learns your phrases and executes them instantly without API calls |
| **Token Cache Optimization** | Optimized API structure enables OpenAI token caching for reduced costs |
| **Cache Management** | Use `clearcache` to reset learned commands, `cacheinfo` to view cache status |
| **Fuzzy Player Targeting** | Type partial names like "goto valk" and it resolves to "Valkorym" automatically |
| **Natural Chain Detection** | Understands requests like "fly and goto random" and splits them correctly |
| **Smart Waypoint System** | Save locations with `swp`, teleport with `waypoints` - dropdown shows saved waypoints |

### Smart Interface

| Feature | Description |
|---------|-------------|
| **Compact Mode Dropdown** | Space-efficient dropdown selector (55px) to switch between CMD and CHAT modes |
| **Predictive Dropdown** | Google-style suggestions with priority ranking as you type |
| **Waypoint Suggestions** | Type `waypoints` to see saved waypoints, `goto` to see players |
| **Command Preview** | Tooltip-style preview shows exactly what will execute before it runs |
| **Visual Processing Indicator** | Animated glow effect shows when AI is thinking |
| **Temporary Status Display** | Status messages appear briefly (2.5s) then auto-hide for minimal UI clutter |
| **Mobile Quick Actions** | One-tap grid with 9 common commands for mobile users |

### Keybinds & Controls

| Feature | Description |
|---------|-------------|
| **Master Toggle** | Press `Right Shift` to instantly show/hide the interface |
| **Smart Binds** | Bind once, toggle automatically (e.g., `bind f fly` handles both fly and unfly) |
| **Adaptive UI** | Compact design: CMD mode (65px height), CHAT mode (300px height), optimized for all screens |

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
| **Mode Dropdown** | Click to select between CMD (orange) and CHAT (blue) modes |
| **Help (?)** | Reopen the interactive tutorial anytime |
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
> **You:** "goto valk"
> **SIY:** Fuzzy matches "valk" to "Valkorym" → Executes `;goto Valkorym`

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
| Noclip | Jump | Teleport |
| Invisible | Reset | Anti-Lag |

### Waypoint System

Save and teleport to locations using the waypoint system:

| Command | Description | Example |
|---------|-------------|----------|
| `swp [name]` | Save current position as waypoint | `swp base` |
| `waypoint [name]` | Teleport to saved waypoint | `waypoint base` |
| `goto [player]` | Teleport to a player | `goto john` |
| `waypoints` | List all saved waypoints | `waypoints` |
| `deletewaypoint [name]` | Delete a waypoint | `deletewaypoint base` |

**Dropdown Suggestions:**

- Type `waypoints` to see all your saved waypoints
- Type `goto` to see all players in the server

**Natural Language Examples:**
> **You:** "Save this spot as my farm"
> **SIY:** Executes `;swp farm`

> **You:** "Take me to the farm waypoint"
> **SIY:** Executes `;waypoint farm`

> **You:** "Go to John"
> **SIY:** Executes `;goto john`

---

## Configuration

Customize SIY by modifying the `CONFIG` table at the top of the script:

```lua
local CONFIG = {
    -- API Settings
    ApiKey = "Null",                    -- If set, sent as Authorization: Bearer <key> for AI requests
    Endpoint = "https://...",           -- AI endpoint URL
    Model = "openai",                   -- AI model to use
    MaxRetries = 2,                     -- Retry attempts for failed requests (HTTP 4xx/5xx or executor errors)
    RequestTimeout = 10,                -- Seconds to wait for API response before failing the request
    
    -- Cache Settings
    CacheEnabled = true,                -- Enable intelligent caching
    CacheFile = "SIY_CommandCache.json", -- Local cache filename
    MaxCacheEntries = 100,              -- Maximum cached commands
    
    -- Rate Limiting
    AIRequestCooldown = 0.5,            -- Minimum seconds between AI requests
    
    -- Input Validation
    MaxInputLength = 500,               -- Maximum characters allowed in input
    
    -- UI Timing Constants
    PreviewDelay = 0.3,                 -- Seconds to show preview before execution
    ErrorDisplayTime = 2,               -- Seconds to display error messages
    StatusFadeTime = 3,                 -- Seconds before status text fades
    
    -- Fuzzy Matching
    FuzzyMatchMinThreshold = 2,         -- Minimum Levenshtein distance threshold
    FuzzyMatchRatio = 0.5,              -- Ratio of input length for threshold
}
```

### Configuration Categories

#### Cache System

The intelligent caching system learns your frequently used phrases:

| Setting | Default | Description |
|---------|---------|-------------|
| `CacheEnabled` | `true` | Toggle the learning cache on/off |
| `CacheFile` | `SIY_CommandCache.json` | Filename for persistent cache |
| `MaxCacheEntries` | `100` | Maximum phrases to remember |

When you use a phrase like "make me fast" and the AI translates it to `;speed 50`, that mapping is cached. Next time you type the same phrase, it executes instantly without an API call.

#### Security & Rate Limiting

| Setting | Default | Description |
|---------|---------|-------------|
| `AIRequestCooldown` | `0.5` | Prevents spam by enforcing minimum delay between AI requests |
| `MaxInputLength` | `500` | Truncates excessively long inputs for security |
| `RequestTimeout` | `10` | Maximum seconds to wait for API response |

#### Fuzzy Matching

| Setting | Default | Description |
|---------|---------|-------------|
| `FuzzyMatchMinThreshold` | `2` | Minimum edit distance to consider a fuzzy match |
| `FuzzyMatchRatio` | `0.5` | Dynamic threshold = max(MinThreshold, inputLength × Ratio) |.

---

## Architecture

### Hybrid Dual-Path Engine

SmartInfiniteYield V1.2.2.3 uses a sophisticated routing system that combines local speed with AI intelligence, wrapped in a streamlined compact interface.

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

## What's New in V1.3.0

### Latest Update: V1.3.0 (January 11, 2026)

**Stabilization & Experience Update:**

| Feature | Description |
|---------|-------------|
| **Sound Feedback** 🎵 | Acoustic cues for success (chime), error (buzz), and processing (hum) states |
| **Onboarding Tour** 🔦 | Interactive first-run tour guiding users through key features |
| **Theme Inheritance** 🎨 | Automatically adopts Infinite Yield's custom theme/colors |
| **Smooth Animations** ✨ | Polished UI transitions and pulsating glow effects |
| **Plugin Bridge API** 🔌 | Exposes `_G.SIY.askAI()` for external plugins to use AI |
| **Core Stabilization** 🛡️ | New EventBus, LifecycleManager, and centralized ErrorHandler |

### Latest Update: V1.2.2.3 (January 10, 2026)

**Dynamic Command Scraping & Feedback Loop:**

| Feature | Description |
|---------|-------------|
| **Dynamic Command Map** | Commands are now extracted directly from IY's `cmds` table at runtime—no more hardcoded lists |
| **Enhanced Bridge v2.0** | Exposes `cmds`, `execCmd`, and `notify` for seamless integration |
| **Notification Hooking** | Captures command output (success/error messages) for AI feedback loop |
| **Auto-Updated Commands** | Any new IY commands are automatically supported without script updates |

### GUI Improvements

Version 1.2.2 focuses on streamlining the interface, fixing visual bugs, and improving command execution:

| Improvement | Description |
|-------------|-------------|
| **Compact Mode Dropdown** | Replaced oversized 95px mode button with space-efficient 55px dropdown selector |
| **Streamlined Header** | Reduced button sizes from 30px to 26px with consistent 4px corner radius |
| **Minimal CMD Mode** | Default CMD frame height reduced from 220px to 65px for minimal screen footprint |
| **Optimized CHAT Mode** | Chat mode width reduced from 560px to 420px for better screen utilization |
| **Text Collision Fixes** | Eliminated overlap between mode selector, input area, and status elements |
| **Temporary Status Display** | Status messages now appear briefly (2.5s) then auto-hide to reduce clutter |
| **Tooltip Preview** | Preview bar repositioned as tooltip-style element below input |
| **Mobile Quick Actions** | Quick actions toggle relocated to bottom-right corner for better accessibility |
| **Toggle Quick Actions** | Quick action buttons now work as keybinds—press once to activate, press again to deactivate (Fly, Noclip, ESP, etc.) |
| **Visual State Feedback** | Active quick actions show highlighted state with visual indicators |

### Technical Enhancements

| Enhancement | Description |
|-------------|-------------|
| **Mode Dropdown System** | New dropdown container with CMD/CHAT options and smooth hover effects |
| **Click-Outside-to-Close** | Dropdown automatically closes when clicking outside its area |
| **Dynamic Frame Expansion** | Frame temporarily expands to show status messages, then collapses back |
| **Consistent Sizing** | All header elements now use uniform 26px height for visual harmony |
| **Dropdown Arrow Indicator** | Added "▾" symbol to mode button to indicate dropdown functionality |
| **Comprehensive FastMap** | Updated with 400+ commands and all aliases extracted from IYsource.lua for complete coverage |
| **Toggle State Management** | Quick actions now track state for proper toggle behavior with visual feedback |
| **Command Accuracy** | Fixed incorrect command mappings and added missing aliases for better local execution |

### Previous Features (V1.2.1)

All features from V1.2.1 are retained:

| Feature | Description |
|---------|-------------|
| **Event-Based Bridge** | Instant connection using BindableEvents instead of polling |
| **Intelligent Caching** | Learns phrases and executes without API calls |
| **Fuzzy Targeting** | Levenshtein distance matching for player names |
| **Processing Glow** | Animated visual indicator during AI processing |
| **Quick Actions** | Mobile-optimized one-tap command grid |
| **Interactive Tutorial** | 8-step onboarding that teaches all features before unlocking GUI |
| **Input Sanitization** | Security layer removes dangerous patterns from user input |
| **Namespace Isolation** | Global variables use dedicated namespace to prevent conflicts |

### Code Quality Improvements

The codebase was refactored for efficiency, security, and maintainability:

| Improvement | Description |
|-------------|-------------|
| **Reorganized Structure** | 19 clearly defined sections with numbered headers |
| **Helper Functions** | Reusable `createInstance()`, `sanitizeInput()`, namespace helpers |
| **Optimized Patterns** | Improved pcall handling and iterator usage |
| **Standard Formatting** | Consistent style following Lua/Roblox conventions |
| **FastMap Completeness** | Added 11 missing commands for instant local execution |
| **Configurable Constants** | All timing values and thresholds use CONFIG table |
| **JSON Error Handling** | Safe parsing prevents crashes from malformed API responses |
| **Rate Limiting** | Prevents API abuse with configurable cooldown |

---

## Roadmap

### Coming in V1.3.0 (Major Update)

| Feature | Description |
|---------|-------------|
| **Plugin System** | Community-created extensions and custom commands (Foundation laid in v1.3.0) |
| **Command Macros** | Record and replay command sequences |
| **Settings Panel** | In-game configuration without editing code |
| **Conversation Memory** | Context-aware follow-up commands |

See the full [ROADMAP.md](docs/ROADMAP.md) for detailed plans.

---

## Changelog

See [CHANGELOG.md](docs/CHANGELOG.md) for the complete version history.

### Recent Updates

**V1.3.0** (January 11, 2026) - Major update focusing on "Stabilization & Experience": Sound system, onboarding tour, theme inheritance, animation system, plugin bridge API, and robust lifecycle management.

**V1.2.2.3** (January 10, 2026) - Code quality improvements: operator precedence bug fix, removed unused functions, connection cleanup enhancements, standardized error prefixes, dynamic command scraping

**V1.2.2.2** (January 9, 2026) - LuaU type annotations, deterministic command matching (OrderedFastMap), input debouncing, enhanced error logging

**V1.2.2.1** (January 8, 2026) - Connection stability improvements, FastMap synchronization with IYsource.lua, Quick Actions toggle fixes, code optimization

**V1.2.2** - Compact mode dropdown, streamlined header layout, text collision fixes, optimized frame sizing, temporary status display, toggle quick actions, comprehensive FastMap update (400+ commands)

**V1.2.1** - Smart Waypoint System, token cache optimization, event-based bridge, intelligent caching, fuzzy targeting, visual feedback, mobile quick actions, interactive tutorial, enhanced CHAT mode, input sanitization, namespace isolation

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
