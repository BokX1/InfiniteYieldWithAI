---
description: Workflow for bug fixing and code improvement in InfiniteYieldWithAI
---

# Bug Fix & Code Improvement Workflow

## Prerequisites

- Read `.agent/AGENT_GUIDE.md` for architecture overview and line ranges
- Review `docs/CHANGELOG.md` for recent changes and known fixes
- Review `docs/TESTING.md` for verification procedures

---

## Phase 1: Analysis (Read-Only)

### 1.1 Scan for Common Bug Patterns

Search the dev file for these known issues:

```powershell
# Duplicate declarations
rg "local\s+\w+\s*=\s*\{\}" InfiniteYieldWithAI_Dev.Lua --line-number
```

// turbo

```powershell
# Unregistered connections (potential memory leaks)
rg ":Connect\(function" InfiniteYieldWithAI_Dev.Lua --line-number | findstr /V "registerConnection"
```

// turbo

```powershell
# Missing type annotations on functions
rg "^local function \w+\([^)]*\)$" InfiniteYieldWithAI_Dev.Lua --line-number
```

### 1.2 Check for Unused Variables

```powershell
# List all local variables and check for usage
rg "^local (\w+)" InfiniteYieldWithAI_Dev.Lua --only-matching --line-number
```

### 1.3 Verify FastMap Consistency

Check for duplicate FastMap entries:

```powershell
rg '^\s*\{.*",' InfiniteYieldWithAI_Dev.Lua | Sort-Object | Get-Unique -AsString
```

---

## Phase 2: Bug Classification

Categorize discovered issues by severity:

| Severity | Description | Action Required |
|----------|-------------|-----------------|
| **Critical** | Runtime errors, script crashes | Fix immediately |
| **High** | Memory leaks, incorrect behavior | Fix before release |
| **Medium** | Performance issues, dead code | Fix when time permits |
| **Low** | Style inconsistencies, missing types | Batch fix |

---

## Phase 3: Implementation

### 3.1 Create a Fix Branch (If Using Git)

```powershell
git checkout -b fix/issue-description
```

### 3.2 Make Changes to Dev File ONLY

- **Edit** `InfiniteYieldWithAI_Dev.Lua`
- **Follow** code conventions from `AGENT_GUIDE.md`:
  - Use `registerConnection()` for all signal connections
  - Use LuaU type annotations for functions
  - Use `ErrorHandler:wrap()` for critical functions
  - Use `EventBus` for cross-component communication

### 3.3 Update Section Comments

If modifying a section, verify the header comment line range:

```
--// ============ SECTION N: Name ============
```

---

## Phase 4: Verification

### 4.1 Syntax Check

Verify the script has no syntax errors:

```powershell
# Quick syntax validation (look for unbalanced brackets/keywords)
rg "function|end|if|then|else|for|while|do|repeat|until" InfiniteYieldWithAI_Dev.Lua --count
```

### 4.2 Run Manual Tests

Follow the test matrix in `docs/TESTING.md`:

1. **Script Load Test** - Verify script loads without errors
2. **Basic Commands** - Test speed, fly, direct commands
3. **Cache System** - Verify cache hit, clear, info
4. **Fuzzy Matching** - Test partial player names

### 4.3 Performance Validation

Ensure changes don't regress performance:

| Metric | Target |
|--------|--------|
| FastMap lookup | <5ms |
| Fuzzy match (short) | <1ms |
| UI responsiveness | <16ms |

---

## Phase 5: Finalization

### 5.1 Mirror to Production

// turbo

```powershell
Copy-Item InfiniteYieldWithAI_Dev.Lua InfiniteYieldWithAI.Lua -Force
```

### 5.2 Update Changelog

Add entry to `docs/CHANGELOG.md` following the existing table format:

```markdown
### Fixed

| Fix | Description |
|-----|-------------|
| **Issue Name** | Brief description of fix |
```

### 5.3 Update Documentation

If line ranges changed, update `.agent/AGENT_GUIDE.md`:

```markdown
| Component | Lines | Description |
|-----------|-------|-------------|
| ComponentName | XXX-YYY | Description |
```

### 5.4 Commit Changes

```powershell
git add .
git commit -m "fix: description of fix"
```

---

## Quick Reference: Key Files

| File | Purpose |
|------|---------|
| `InfiniteYieldWithAI_Dev.Lua` | Development file (EDIT THIS) |
| `InfiniteYieldWithAI.Lua` | Production mirror |
| `.agent/AGENT_GUIDE.md` | Architecture reference |
| `docs/CHANGELOG.md` | Version history |
| `docs/TESTING.md` | Test procedures |
| `docs/ROADMAP.md` | Future plans |

---

## Quick Reference: Core Components

| Component | Lines | Common Bugs |
|-----------|-------|-------------|
| Connection Mgmt | 62-128 | Unregistered connections |
| EventBus | 131-174 | Duplicate declarations |
| Cache System | 1115-1200 | Invalid cache entries |
| FastMap | 3102-3600 | Duplicate patterns |
| AI Query | 4079-4367 | HTTP error handling |

---

## Checklist Template

Copy this checklist for each bug fix session:

```markdown
- [ ] Read AGENT_GUIDE.md for context
- [ ] Identify bug pattern and severity
- [ ] Make fix in InfiniteYieldWithAI_Dev.Lua
- [ ] Verify fix with manual testing
- [ ] Mirror to InfiniteYieldWithAI.Lua
- [ ] Update CHANGELOG.md
- [ ] Update AGENT_GUIDE.md if line ranges changed
- [ ] Commit changes
```
