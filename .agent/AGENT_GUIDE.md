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

### 2. EventBus (Lines 131-174)

Decoupled pub/sub system for internal communication.

### 3. ErrorHandler (Lines 221-264)

Centralized error reporting.

### 4. Cache System (Lines 271-400)

LRU cache for AI prompt→command mappings.

### 5. FastMap (Lines 3104-3560)

Pre-defined regex patterns for instant command matching.

- `FastMapIndex` - Groups by first character for O(1) lookup
- `FastMapMisc` - Patterns without anchors

### 6. Bridge System (Lines 1200-1420)

Connection to Infinite Yield's internal API.

### 7. AI Query (Lines 4092-4400)

HTTP requests to LLM endpoint.

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

---

## Important Line Ranges

| Component | Lines |
|-----------|-------|
| Services | 10-20 |
| EventBus | 131-174 |
| ErrorHandler | 221-264 |
| Cache | 271-400 |
| Bridge | 1200-1420 |
| FastMap | 3104-3560 |
| Levenshtein | 3740-3814 |
| executeBridge | 3954-4077 |
| queryAI | 4092-4400 |

---

## Testing

See `docs/TESTING.md` for verification procedures.
