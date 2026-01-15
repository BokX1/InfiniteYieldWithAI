---
description: Workflow for bug fixing and code improvement in InfiniteYieldWithAI
---

# Bug Fix & Code Improvement Workflow

> **Target:** `InfiniteYieldWithAI_Dev.Lua` (4800+ lines, Lua/LuaU)

## Before You Start

1. Read `.agent/AGENT_GUIDE.md` for architecture and component line ranges
2. Check `docs/CHANGELOG.md` for recent fixes (avoid duplicating work)

---

## Phase 1: Analysis

### 1.1 Bug Pattern Scans

Use the grep_search tool to find common issues:

| Pattern | What to Search | Why |
|---------|----------------|-----|
| Duplicate tables | `local \w+ = {}` | Find shadowed declarations |
| Unregistered connections | `Connect(function` then verify `registerConnection` nearby | Memory leaks |
| Missing type annotations | `local function \w+\(` without `: type` | Code quality |
| Duplicate FastMap | Same command pattern twice | Redundant entries |

### 1.2 Key Sections to Audit

Use view_file to examine these high-risk areas:

| Section | Lines | Common Issues |
|---------|-------|---------------|
| Connection Management | 62-128 | Untracked connections |
| EventBus | 131-176 | Duplicate declarations |
| AnimationManager | 346-409 | Tween connection leaks |
| Drag System | 1670-1750 | InputChanged leaks |
| Cache System | 1115-1220 | Invalid entries |
| Bridge System | 1224-1410 | Retry logic bugs |
| FastMap | 3104-3600 | Duplicate patterns |
| AI Query | 4082-4370 | HTTP error handling |
| Suggestion System | 4372-4550 | Player matching bugs |

### 1.3 Section Numbering Check

Verify section headers follow sequential order:

- 1A → 1B → 1C → 1D → 1E → 1F → 1G → 1H
- 2 → 3 → 4 → ... → 17

---

## Phase 2: Classification

Categorize bugs by severity before fixing:

| Severity | Examples | Priority |
|----------|----------|----------|
| **Critical** | Script won't load, runtime errors | Fix first |
| **High** | Memory leaks, wrong behavior | Fix before release |
| **Medium** | Performance, dead code | Fix when convenient |
| **Low** | Missing types, style issues | Batch fix |

---

## Phase 3: Implementation

### 3.1 Code Conventions (MUST FOLLOW)

```lua
-- ✅ Register ALL signal connections
local conn = signal:Connect(function() ... end)
registerConnection(conn)

-- ✅ Use type annotations
local function foo(bar: string): number

-- ✅ Clean up one-shot connections
conn = event:Connect(function()
    conn:Disconnect()
    removeConnection(conn)
    -- do work
end)
registerConnection(conn)

-- ✅ Wrap critical functions
local safeFn = ErrorHandler:wrap(riskyFn, "SourceName")

-- ✅ Use EventBus for cross-component communication
EventBus:emit("EVENT_NAME", data)
```

### 3.2 Edit Workflow

1. **Edit ONLY** `InfiniteYieldWithAI_Dev.Lua`
2. Make targeted edits using replace_file_content or multi_replace_file_content
3. Keep changes minimal - avoid refactoring unrelated code

### 3.3 Section Header Format

```lua
--// ============================================
--// NX. COMPONENT NAME (vX.X.X)
--// ============================================
-- Brief description
```

---

## Phase 4: Verification

### 4.1 Syntax Validation

Verify balanced constructs by counting:

- `function` should roughly equal `end` count
- `if` + `for` + `while` should have corresponding `end`

### 4.2 Test Matrix (from TESTING.md)

| Category | Test Cases |
|----------|------------|
| Script Load | Loads without errors, UI appears |
| Basic Commands | `speed`, `fly`, `goto`, `help` |
| Cache System | `clearcache`, `cacheinfo`, cache hit |
| Fuzzy Match | Partial names, `@display`, `me`, `random` |
| Chain Commands | `fly; speed 100`, `noclip; fly; goto me` |

---

## Phase 5: Finalization

### 5.1 Mirror to Production

// turbo

```powershell
Copy-Item InfiniteYieldWithAI_Dev.Lua InfiniteYieldWithAI.Lua -Force
```

### 5.2 Update CHANGELOG.md

Add to the current version's `### Fixed` section:

```markdown
| **Bug Name** | Brief description of what was fixed |
```

### 5.3 Update AGENT_GUIDE.md (if needed)

Update line numbers in the component table if sections shifted.

### 5.4 Commit and Push

```powershell
git add InfiniteYieldWithAI_Dev.Lua InfiniteYieldWithAI.Lua docs/CHANGELOG.md .agent/AGENT_GUIDE.md
git commit -m "fix: brief description"
git push
```

---

## Quick Reference

### File Map

| File | Role |
|------|------|
| `InfiniteYieldWithAI_Dev.Lua` | Development (EDIT THIS) |
| `InfiniteYieldWithAI.Lua` | Production (mirror only) |
| `IYsource.lua` | Reference for IY commands (read-only) |
| `.agent/AGENT_GUIDE.md` | Architecture docs |
| `docs/CHANGELOG.md` | Version history |
| `docs/TESTING.md` | Test procedures |

### Common Bug Patterns

| Bug | Fix Pattern |
|-----|-------------|
| Unregistered connection | Add `registerConnection(conn)` after `:Connect()` |
| One-shot connection leak | Add `removeConnection(conn)` inside callback before disconnect |
| Duplicate section number | Renumber downstream sections (1D, 1E, 1F...) |
| Tween completion leak | Register the `tween.Completed:Connect()` connection |
| Missing type annotation | Add `: TypeName` to function parameters and return |

### Session Checklist

```
[ ] Read AGENT_GUIDE.md
[ ] Scan for bug patterns
[ ] Classify by severity
[ ] Fix in Dev file only
[ ] Mirror to production
[ ] Update CHANGELOG.md
[ ] Update AGENT_GUIDE.md (if lines changed)
[ ] Commit and push
```
