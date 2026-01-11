# SmartInfiniteYield (SIY) - V1.3.1 Stable

**Original Idea by [VolQ5](https://github.com/BokX1/RbxLuauLLM) | Powered by Pollinations.AI (LLM Model)**

---

## Overview

**SmartInfiniteYield (SIY)** is an open-source, AI-powered wrapper for [Infinite Yield](https://github.com/EdgeIY/infiniteyield), bridging the gap between natural language and precise command execution.

It features a **Hybrid Dual-Path Engine** that intelligently routes requests:

1. **Fast Path**: Instant local execution for 400+ known commands (e.g., "fly", "speed 50").
2. **AI Path**: Neural processing for complex natural language (e.g., "teleport to the red player").

SIY adapts to you with **Intelligent Caching** (learning your phrases), **Fuzzy Player Targeting**, and a **Mobile-First Design**.

---

## Key Features

### 🧠 Intelligent Core

| Feature | Description |
|---------|-------------|
| **Hybrid Engine** | Zero-latency local execution + AI fallback for complex queries. |
| **Intelligent Caching** | Learns your phrases ("make me fast" -> `;speed 50`) and caches them for instant future use. |
| **Fuzzy Targeting** | Type "goto valk" and it automatically resolves to "Valkorym". |
| **Anti-Hallucination** | Validates AI commands before execution to prevent errors. |

### 📱 Smart Interface

| Feature | Description |
|---------|-------------|
| **Compact Mode** | Minimalist 65px height (CMD mode) to keep your screen clear. |
| **Mobile Quick Actions** | One-tap touch grid for common commands (Fly, Noclip, ESP, etc.). |
| **Predictive Dropdown** | Google-style suggestions with priority ranking as you type. |
| **Waypoint System** | Save locations (`swp`) and teleport back (`gotowp`, `game`). |

### ✨ User Experience (New in v1.3)

| Feature | Description |
|---------|-------------|
| **Sound Feedback** 🎵 | Acoustic cues for success (chime), error (buzz), and processing. |
| **Onboarding Tour** 🔦 | Interactive first-run guide teaching you how to use the AI. |
| **Theme Inheritance** 🎨 | Automatically adopts your Infinite Yield theme colors. |
| **Smooth Animations** | Polished UI transitions and pulsating processing effects. |

---

## Installation

### Prerequisites

You need a Roblox Executor that supports `request`, `http_request`, or `fluxus.request`.

### Quick Start

Copy and execute this script:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/BokX1/InfiniteYieldWithAI/refs/heads/main/InfiniteYieldWithAI.Lua"))()
```

*(For the bleeding-edge development version, replace `InfiniteYieldWithAI.Lua` with `InfiniteYieldWithAI_Dev.Lua`)*

---

## Usage Guide

### The Interface

- **CMD Mode (Orange)**: For executing commands. Type "fly" or "bring me the player in red".
- **CHAT Mode (Blue)**: For asking questions. Type "Where is the safe spot in this game?".
- **Quick Actions (⚡)**: Mobile-optimized 3x3 grid for instant command toggles.

### Waypoint System

- `swp [name]`: Save current location (e.g., `swp base`).
- `gotowp [name]`: Teleport to saved location.
- Dropdown: Type `gotowp` to see a list of your saved spots.

---

## Configuration

You can customize SIY by modifying the `CONFIG` table at the top of the script:

```lua
local CONFIG = {
    -- API Settings
    ApiKey = "Null",                    -- Optional Bearer key
    Model = "openai",                   -- AI Model
    
    -- Experience (New in v1.3)
    EnableSounds = false,               -- Toggle sound effects
    SoundVolume = 0.5,                  -- Volume (0-1)
    EnableTour = true,                  -- Enable first-run tutorial
    
    -- Cache & Rate Limiting
    CacheEnabled = true,                -- Enable phrase learning
    AIRequestCooldown = 0.5,            -- Anti-spam delay
    
    -- Fuzzy Matching
    FuzzyMatchMinThreshold = 2,         -- Sensitivity for name matching
}
```

---

## Architecture & Stability

V1.3.1 introduces a robust enterprise-grade architecture:

- **Event Bus**: Decoupled communication between UI and Logic.
- **Lifecycle Manager**: Ensures clean startups and shutdowns (no memory leaks on re-execution).
- **Error Handler**: Centralized reporting that prevents script crashes.
- **Plugin Bridge**: Exposes `_G.SmartInfiniteYield` for external scripts to request AI commands.

---

## Contributing

See [ROADMAP.md](docs/ROADMAP.md) for future plans and [CHANGELOG.md](docs/CHANGELOG.md) for version history.

**Credits**:

- **VolQ5**: Original Idea & Logic
- **Pollinations.AI**: AI Integration
- **EdgeIY**: Infinite Yield Backend

Licensed under **Apache License 2.0**.
