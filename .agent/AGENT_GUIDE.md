# InfiniteYieldWithAI - Agent Development Guide

## Overview

Smart Infinite Yield (SIY) is a Roblox script that integrates AI (LLM) with the Infinite Yield admin command system. It translates natural language prompts into IY commands.

**Key Files:**

- `InfiniteYieldWithAI_Dev.Lua` - Development version (edit this)
- `InfiniteYieldWithAI.Lua` - Production mirror (copy from Dev after changes)
- `docs/CHANGELOG.md` - Version history
- `docs/TESTING.md` - Test procedures

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    USER INPUT                           │
└─────────────────────┬───────────────────────────────────┘
                      │
        ┌─────────────▼─────────────┐
        │      INPUT PROCESSING     │
        │  (sanitize, normalize)    │
        └─────────────┬─────────────┘
                      │
    ┌─────────────────┼─────────────────┐
    │                 │                 │
    ▼                 ▼                 ▼
┌────────┐     ┌───────────┐     ┌───────────┐
│ CACHE  │     │ FASTMAP   │     │    AI     │
│ LOOKUP │     │  LOOKUP   │     │  QUERY    │
└────┬───┘     └─────┬─────┘     └─────┬─────┘
    │               │                 │
    └───────────────┴─────────────────┘
                      │
        ┌─────────────▼─────────────┐
        │     BRIDGE EXECUTION      │
        │  (IY_Interface.Exec)      │
        └───────────────────────────┘
```

---

## Core Components

### 1. Services (Lines 10-20)

Cached Roblox services: `Players`, `HttpService`, `TweenService`, `CoreGui`, `RunService`

### 2. Connection Management (Lines 62-128)

- `registerConnection()` - Tracks RBXScriptConnections for cleanup
- `ConnectPersistent()` - Connect signals with automatic registration
- `cancelPersistentTasks()` - Clean shutdown for re-execution

### 3. EventBus (Lines 131-174)

Decoupled pub/sub system for internal communication.

### 4. LifecycleManager (Lines 177-218)

Handles clean startup/shutdown for re-execution support.

### 5. ErrorHandler (Lines 221-252)

Centralized error reporting with `report()` and `wrap()` methods.

### 6. IYIntegration (Lines 255-299)

Scrapes IY's aliases and keybinds at runtime for enhanced AI context.

### 7. ThemeManager (Lines 302-343)

Inherits IY's theme colors for consistent styling.

### 8. AnimationManager (Lines 346-405)

Smooth animations for UI elements, including pulsing glow effects.

### 9. TourManager (Lines 408-478)

First-run onboarding tour system with step highlighting.

### 10. Configuration (Lines 481-831)

Typed configuration with API settings, cache, rate limiting, and system prompts.

### 11. Cache System (Lines 1115-1200)

LRU cache for AI prompt→command mappings with file persistence.

### 12. FastMap (Lines 3102-3600)

Pre-defined regex patterns for instant command matching. Extracted from IYsource.lua with 400+ commands.

### 13. AI Query System (Lines 4079-4367)

HTTP requests to LLM endpoint with retry logic and response parsing.

### 14. Suggestion System (Lines 4369-4500)

Builds dropdown suggestions from FastMap for command autocomplete.

---

## Development Workflow

1. **Edit** `InfiniteYieldWithAI_Dev.Lua`
2. **Test** in Roblox executor
3. **Mirror** to `InfiniteYieldWithAI.Lua`:

   ```powershell
   Copy-Item InfiniteYieldWithAI_Dev.Lua InfiniteYieldWithAI.Lua -Force
   ```

4. **Update** `docs/CHANGELOG.md`
5. **Commit** with semantic version message

---

## Code Conventions

- **Type Annotations**: Use LuaU style (`function foo(x: string): number`)
- **Connections**: Use `registerConnection()` for cleanup tracking
- **Events**: Use `EventBus` for cross-component communication
- **Comments**: Section headers use `--// ============` format
- **Error Handling**: Wrap critical functions with `ErrorHandler:wrap()`

---

## Important Line Ranges

| Component | Lines | Description |
|-----------|-------|-------------|
| Services | 10-20 | Cached Roblox services |
| Connection Mgmt | 62-128 | Connection cleanup tracking |
| EventBus | 131-174 | Pub/sub messaging |
| LifecycleManager | 177-218 | Startup/shutdown |
| ErrorHandler | 221-252 | Error reporting |
| IYIntegration | 255-299 | Alias/keybind scraping |
| ThemeManager | 302-343 | Theme inheritance |
| AnimationManager | 346-405 | UI animations |
| TourManager | 408-478 | Onboarding tour |
| Configuration | 481-831 | CONFIG table |
| Cache System | 1115-1200 | Command caching |
| FastMap | 3102-3600 | Regex patterns |
| AI Query | 4079-4367 | LLM requests |
| Suggestions | 4369-4500 | Dropdown autocomplete |

---

## Testing

See `docs/TESTING.md` for verification procedures.
