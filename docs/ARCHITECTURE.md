# Architecture Overview

> Technical deep-dive into SmartInfiniteYield's internal design.

---

## Processing Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER INPUT                               │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  NORMALIZE & SANITIZE (trim, lowercase, remove dangerous tokens) │
└─────────────────────────────┬───────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   │                   │
    ┌───────────┐             │                   │
    │ FASTMAP   │─── HIT ────►│                   │
    │ (Regex)   │             │                   │
    └─────┬─────┘             │                   │
          │ MISS              ▼                   │
          │            ┌───────────┐              │
          └───────────►│  CACHE    │─── HIT ────►│
                       │  (LRU)    │              │
                       └─────┬─────┘              │
                             │ MISS              ▼
                             │            ┌────────────┐
                             └───────────►│  AI QUERY  │
                                          │  (LLM API) │
                                          └──────┬─────┘
                                                 │
┌────────────────────────────────────────────────┼────────────────┐
│                         BRIDGE EXECUTION                         │
│  IY_Interface.Exec(command) → Infinite Yield → Roblox Action    │
└─────────────────────────────────────────────────────────────────┘
```

**Processing Order:** FastMap (instant) → Cache (fast) → AI (slow)

---

## Core Systems

```
┌─────────────────────────────────────────────────────────────────┐
│                         SIY Core                                 │
├─────────────────────────────────────────────────────────────────┤
│  EventBus          │  Decoupled pub/sub communication           │
│  LifecycleManager  │  Startup/shutdown, memory cleanup          │
│  ErrorHandler      │  Centralized reporting, safe wrappers      │
├─────────────────────────────────────────────────────────────────┤
│                      Integrations                                │
├─────────────────────────────────────────────────────────────────┤
│  IYIntegration     │  Scrape aliases, keybinds, commands        │
│  ThemeManager      │  Inherit IY theme colors                   │
│  SoundManager      │  Play processing/success/error sounds      │
├─────────────────────────────────────────────────────────────────┤
│                      UI Managers                                 │
├─────────────────────────────────────────────────────────────────┤
│  AnimationManager  │  Smooth tweens, pulsating effects          │
│  TourManager       │  First-run onboarding flow                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Component Map

### Section 1: Core Infrastructure

| # | Component | Lines | Key Functions |
|---|-----------|-------|---------------|
| 1A | Services | 10-20 | Cached `Players`, `HttpService`, `TweenService` |
| 1B | Connection Mgmt | 62-128 | `registerConnection()`, `ConnectPersistent()` |
| 1C | EventBus | 131-176 | `:on()`, `:emit()`, `:clear()` |
| 1D | LifecycleManager | 179-218 | `:startup()`, `:shutdown()` |
| 1E | ErrorHandler | 221-252 | `:report()`, `:wrap()` |
| 1F | IYIntegration | 255-299 | `:scrapeAliases()`, `:buildContext()` |
| 1G | ThemeManager | 302-343 | `:getIYTheme()`, `:applyToElement()` |
| 1H | AnimationManager | 346-409 | `:animateDropdown()`, `:createPulsingGlow()` |
| 1I | TourManager | 412-482 | `:registerElement()`, `:start()` |

### Section 2-17: Systems & UI

| Section | Lines | Purpose |
|---------|-------|---------|
| 2. Configuration | 485-850 | `CONFIG` table with types |
| 3. Utility Functions | 1050-1113 | `trim()`, `normalizeInput()` |
| 4. Command Cache | 1115-1222 | LRU cache with file persistence |
| 5. Bridge System | 1224-1410 | IY connection with retries |
| 6. Dynamic Commands | 1412-1492 | Runtime command scraping |
| 7. UI Configuration | 1494-1665 | Colors, sizes, helpers |
| 8. Drag System | 1668-1780 | Draggable UI with cleanup |
| 13. ToggleMap | 3046-3100 | Command state pairs |
| 14. FastMap | 3104-3920 | 400+ regex patterns |
| 16. AI Query | 4082-4370 | HTTP requests to LLM |
| 17. Suggestions | 4372-4550 | Dropdown autocomplete |

---

## Design Patterns

### Connection Registry

All RBXScriptConnections are tracked for cleanup:

```lua
local conn = signal:Connect(handler)
registerConnection(conn)  -- Track for cleanup

-- One-shot pattern
conn = event:Connect(function()
    conn:Disconnect()
    removeConnection(conn)
    -- do work
end)
registerConnection(conn)
```

### Namespace Isolation

Globals use `SmartInfiniteYield` namespace:

```lua
setNamespaceValue("Ready", true)
local isReady = getNamespaceValue("Ready")
```

### Event-Driven Communication

```lua
-- Subscribe
EventBus:on("AI_REQUEST_COMPLETE", handler)

-- Emit
EventBus:emit("AI_REQUEST_COMPLETE", {prompt = input, response = output})
```

### Error Wrapping

```lua
local safeFn = ErrorHandler:wrap(function()
    -- risky code
end, "ComponentName")
```

---

## For Developers

See [AGENT_GUIDE.md](../.agent/AGENT_GUIDE.md) for detailed development documentation.
