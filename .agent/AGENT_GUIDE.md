# InfiniteYieldWithAI - Agent Development Guide

> **Version:** 1.3.3 | **Updated:** 2026-01-16 | **Lines:** ~4837

## Quick Reference

| File | Purpose |
|------|---------|
| `InfiniteYieldWithAI_Dev.Lua` | **Edit this** - Development version |
| `InfiniteYieldWithAI.Lua` | Production mirror (copy from Dev) |
| `IYsource.lua` | Infinite Yield source (read-only reference) |
| `docs/CHANGELOG.md` | Version history |
| `docs/TESTING.md` | Test procedures |

---

## Architecture

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

## Component Map

### Section 1: Core Infrastructure

| # | Component | Lines | Key Functions |
|---|-----------|-------|---------------|
| 1A | Services | 10-20 | Cached `Players`, `HttpService`, `TweenService`, etc. |
| 1B | Connection Mgmt | 62-128 | `registerConnection()`, `ConnectPersistent()`, `removeConnection()` |
| 1C | EventBus | 131-176 | `:on()`, `:emit()`, `:clear()` |
| 1D | LifecycleManager | 179-218 | `:startup()`, `:shutdown()`, `:isInitialized()` |
| 1E | ErrorHandler | 221-252 | `:report()`, `:wrap()` |
| 1F | IYIntegration | 255-299 | `:scrapeAliases()`, `:scrapeKeybinds()`, `:buildContext()` |
| 1G | ThemeManager | 302-343 | `:getIYTheme()`, `:applyToElement()` |
| 1H | AnimationManager | 346-409 | `:animateDropdown()`, `:createPulsingGlow()` |
| 1I | TourManager | 412-482 | `:registerElement()`, `:start()`, `:nextStep()` |

### Section 2-7: Configuration & Systems

| Section | Lines | Purpose |
|---------|-------|---------|
| 2. Configuration | 485-850 | `CONFIG` table with types |
| 3. Utility Functions | 1050-1113 | `trim()`, `normalizeInput()`, `sanitizeInput()` |
| 4. Command Cache | 1115-1222 | LRU cache with file persistence |
| 5. Bridge System | 1224-1410 | IY connection with retries |
| 6. Dynamic Commands | 1412-1492 | Runtime command scraping |
| 7. UI Configuration | 1494-1665 | Colors, sizes, helper functions |

### Section 8-17: UI & Logic

| Section | Lines | Purpose |
|---------|-------|---------|
| 8. Drag System | 1668-1780 | Draggable UI with cleanup |
| 9-12. UI Construction | 1782-3000 | MainFrame, InputBox, Dropdowns |
| 13. ToggleMap | 3046-3100 | Command state pairs (`fly`↔`unfly`) |
| 14. FastMap | 3104-3920 | 400+ regex patterns |
| 15. OrderedFastMap | 3922-4050 | Sorted by pattern length |
| 16. Bridge Execution | 3952-4080 | `executeBridge()` with targeting |
| 17. AI Query | 4082-4370 | HTTP requests to LLM |
| 18. Suggestions | 4372-4550 | Dropdown autocomplete |
| 19. Event Handlers | 4552-4750 | Input, keyboard, lifecycle |

---

## Code Patterns

### Connection Registration (CRITICAL)

```lua
-- ✅ CORRECT: Register all connections for cleanup
local conn = signal:Connect(function()
    -- handler
end)
registerConnection(conn)

-- ✅ CORRECT: One-shot connection with proper cleanup
local conn
conn = event:Connect(function()
    if conn then
        conn:Disconnect()
        removeConnection(conn)
    end
    -- do work
end)
registerConnection(conn)

-- ❌ WRONG: Unregistered connection = memory leak
signal:Connect(function()
    -- leaked!
end)
```

### Type Annotations

```lua
-- Function with full LuaU types
--- @param input string -- The user input
--- @return string -- Normalized result
local function normalizeInput(input: string): string
    return input:lower():gsub("^%s+", "")
end
```

### Error Handling

```lua
-- Wrap risky functions
local safeFn = ErrorHandler:wrap(function()
    -- risky code
end, "ComponentName")

-- Or report explicitly  
ErrorHandler:report("Source", "Error message", "error")
```

### EventBus Usage

```lua
-- Subscribe
local disconnect = EventBus:on("EVENT_NAME", function(data)
    -- handle event
end)

-- Emit
EventBus:emit("AI_REQUEST_COMPLETE", {prompt = input, response = output})

-- Available events:
-- STARTUP_COMPLETE, SHUTDOWN_START, ERROR_OCCURRED
-- TOUR_START, TOUR_STEP, TOUR_COMPLETE
-- AI_REQUEST_COMPLETE, AI_REQUEST_ERROR, SHOW_NOTIFICATION
```

### Section Headers

```lua
--// ============================================
--// NX. COMPONENT NAME (vX.X.X)
--// ============================================
-- Brief description of what this section does
```

---

## Common Edits

### Adding a New Command Pattern

In FastMap (~line 3104):

```lua
["^newcmd (.+)"] = "newcmd %1",
["^nc (.+)"] = "newcmd %1",  -- alias
```

### Adding a Toggle Pair

In ToggleMap (~line 3046):

```lua
newcmd = "unnewcmd", unnewcmd = "newcmd",
```

### Adding a New EventBus Event

1. Emit: `EventBus:emit("NEW_EVENT", data)`
2. Subscribe: `EventBus:on("NEW_EVENT", handler)`

### Adding a New CONFIG Option

In ConfigType (~line 489) and CONFIG (~line 533):

```lua
-- Type definition
type ConfigType = {
    NewOption: number,
    ...
}

-- Actual value
local CONFIG: ConfigType = {
    NewOption = 42,
    ...
}
```

---

## Workflow Commands

### Mirror Dev to Production

```powershell
Copy-Item InfiniteYieldWithAI_Dev.Lua InfiniteYieldWithAI.Lua -Force
```

### Commit Changes

```powershell
git add InfiniteYieldWithAI_Dev.Lua InfiniteYieldWithAI.Lua docs/CHANGELOG.md
git commit -m "fix: description"
git push
```

---

## Known Bug Patterns

| Pattern | Location | Fix |
|---------|----------|-----|
| Unregistered `:Connect()` | Any section | Add `registerConnection()` |
| Duplicate section number | Section headers | Renumber sequentially |
| Tween completion leak | AnimationManager | Register `tween.Completed` connection |
| Missing type annotation | Function definitions | Add `: type` syntax |
| Orphaned drag connection | Drag System | Use `DragRegistrations` table |

---

## Testing

See [docs/TESTING.md](../docs/TESTING.md) for:

- Script load tests
- Basic command tests
- Cache system tests  
- Fuzzy matching tests
- Mobile-specific tests
- Performance benchmarks
