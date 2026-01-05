# SmartInfiniteYield (SIY) - V1.3.0 Headless Engine

**Original Idea by [VolQ5](https://github.com/BokX1/RbxLuauLLM) | Powered by Pollinations.AI (LLM Model)**

---

## Overview

**SmartInfiniteYield (SIY)** is an open-source, AI-powered wrapper for [Infinite Yield](https://github.com/EdgeIY/infiniteyield), the popular Roblox admin script. It bridges the gap between natural human language and precise command execution, allowing users to control the game using everyday phrases instead of memorizing syntax.

At its core, SIY features a **Hybrid Dual-Path Execution Engine** that intelligently routes requests through either instant local processing (for 200+ known commands) or AI-powered translation (for complex natural language). The system includes a **Self-Correcting Logic Engine** that validates commands before execution—if the AI targets a non-existent player or generates invalid syntax, the script automatically detects the error, provides context, and forces the AI to correct itself.

**New in V1.3.0:** The **Headless Engine** architecture allows running SIY without IY GUI rendering, perfect for automation and integration. The unified **BridgeAPI** provides programmatic control with `Execute()`, `GetOutput()`, and `HotSwap()` functions.

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
| **Hybrid Execution Engine** | Zero-latency local execution for 200+ commands, with AI fallback for complex natural language |
| **Intelligent Caching** | Learns your phrases and executes them instantly without API calls |
| **Token Cache Optimization** | Optimized API structure enables OpenAI token caching for reduced costs |
| **Cache Management** | Use `clearcache` to reset learned commands, `cacheinfo` to view cache status |
| **Fuzzy Player Targeting** | Type partial names like "kill valk" and it resolves to "Valkorym" automatically |
| **Natural Chain Detection** | Understands requests like "fly and goto random" and splits them correctly |
| **Smart Waypoint System** | Save locations with `swp`, teleport with `gotowp` - dropdown shows saved waypoints |

### Headless Engine (V1.3.0)

| Feature | Description |
|---------|-------------|
| **Headless Mode** | Run SIY without rendering the Infinite Yield GUI, using a virtualization shim |
| **BridgeAPI** | Unified API contract for programmatic execution and output monitoring |
| **Feedback Loop** | Real-time monitoring of IY notifications and command output |
| **Hot-Swap Support** | Update `IYsource.lua` independently without restarting the main script |
| **Crash Protection** | All command executions are wrapped in `pcall` with automatic error reporting |
| **Dynamic Loading** | Fetches the latest IY source from the repository with 24-hour caching |

### Smart Interface

| Feature | Description |
|---------|-------------|
| **Compact Mode Dropdown** | Space-efficient dropdown selector (55px) to switch between CMD and CHAT modes |
| **Predictive Dropdown** | Google-style suggestions with priority ranking as you type |
| **Waypoint Suggestions** | Type `gotowp ` to see saved waypoints, `goto ` to see players |
| **Command Preview** | Tooltip-style preview shows exactly what will execute before it runs |
| **Visual Processing Indicator** | Animated glow effect shows when AI is thinking |
| **Temporary Status Display** | Status messages appear briefly (2.5s) then auto-hide for minimal UI clutter |
| **Mobile Quick Actions** | One-tap grid with 9 common commands for mobile users |

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

## BridgeAPI Reference (V1.3.0)

The `BridgeAPI` is exposed via the `SmartInfiniteYield` namespace in `getgenv()` or `_G`.

### Methods

| Method | Description |
|--------|-------------|
| `Execute(cmd: string)` | Executes a command through the bridge. Returns `(success, errorMsg)`. |
| `GetOutput()` | Returns the latest output entry: `{Title, Text, Timestamp, Index}`. |
| `GetAllOutput()` | Returns an array of all output entries in the buffer. |
| `ClearOutput()` | Clears the output buffer and resets the index. |
| `GetStatus()` | Returns bridge status: `{connected, attempts, interface, headless, outputCount}`. |
| `HotSwap()` | Reloads `IYsource.lua` from the repository without restarting SIY. |

### Example Usage

```lua
local SIY = getgenv().SmartInfiniteYield
if SIY and SIY.Ready then
    local success, err = SIY.BridgeAPI.Execute(";fly")
    if not success then warn("Failed: " .. err) end
    
    local output = SIY.BridgeAPI.GetOutput()
    if output then print("IY Says: " .. output.Text) end
end
```

---

## Configuration

Customize SIY by modifying the `CONFIG` table at the top of the script:

```lua
local CONFIG = {
    -- V1.3 Headless Engine Settings
    HeadlessMode = false,               -- Enable headless mode (suppresses IY GUI)
    EnableHotSwap = true,               -- Allow updating IYsource independently
    OutputBufferSize = 50,              -- Maximum entries in output buffer
    
    -- API Settings
    ApiKey = "Null",                    -- Authorization: Bearer <key>
    Endpoint = "https://...",           -- AI endpoint URL
    MaxRetries = 2,                     -- Retry attempts for failed requests
    RequestTimeout = 10,                -- Seconds to wait for API response
    
    -- Cache Settings
    CacheEnabled = true,                -- Enable intelligent caching
    MaxCacheEntries = 100,              -- Maximum cached commands
}
```

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
- **Discord:** Join the support server via `;discord` command in-game.
