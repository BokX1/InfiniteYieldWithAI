# InfiniteYieldWithAI - Manual Testing Procedures

## Quick Verification Checklist

### 1. Script Load Test

- [ ] Script loads without errors in Roblox executor
- [ ] UI appears and is interactive
- [ ] Status bar displays "Ready" or tip message

### 2. Basic Commands

| Test | Input | Expected Result |
|------|-------|-----------------|
| Speed | "make me fast" | Executes `speed` command |
| Fly | "let me fly" | Executes `fly` command |
| Direct | "speed 100" | FastMap match, immediate exec |
| Help | "help" | Status bar shows bind syntax |

### 3. Cache System

| Test | Steps | Expected |
|------|-------|----------|
| Cache Hit | Run same prompt twice | Second run shows "CacheHit" |
| Clear | Type "clearcache" | "Cache Cleared" message |
| Info | Type "cacheinfo" | Shows cache count |

### 4. Fuzzy Player Matching

| Test | Input | Expected |
|------|-------|----------|
| Partial Name | "goto joh" (when "John123" exists) | Resolves to "John123" |
| DisplayName | "goto @display" | Matches display name |
| Exact | "goto John123" | Direct match, no fuzzy |

### 5. Chat Mode

| Test | Steps | Expected |
|------|-------|----------|
| Toggle | Press RShift | "Chat Mode" indicator |
| Response | Ask a question | AI responds conversationally |
| History | Follow-up question | Contextual response |

---

## Edge Case Test Matrix

### Input Validation

| Input | Expected Behavior |
|-------|-------------------|
| Empty string | Ignored |
| Only spaces | Ignored |
| Very long (>500 chars) | Rate limited / truncated |
| Special chars `<>&` | Sanitized |

### Player Targeting

| Input | Expected |
|-------|----------|
| "goto all" | Rejected with error |
| "goto me" | Resolves to local player |
| "goto random" | Picks random other player |
| "goto nonexistent" | No match, passed as-is |

### Chain Commands

| Input | Expected |
|-------|----------|
| "fly; speed 100" | Both execute sequentially |
| "fly;speed" | Works (no space) |
| ";;;;" | Ignored (empty commands) |

---

## Performance Benchmarks

| Metric | Target | Method |
|--------|--------|--------|
| FastMap lookup | <5ms | Time first-char index hit |
| Levenshtein (short) | <1ms | fuzzyMatchPlayer with 3-char input |
| Levenshtein (long) | <10ms | fuzzyMatchPlayer with 20-char input |
| UI responsiveness | <16ms | No frame drops during input |
