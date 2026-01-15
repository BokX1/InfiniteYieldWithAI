# InfiniteYieldWithAI - Manual Testing Procedures

## Quick Verification Checklist

### 1. Script Load Test

- [ ] Script loads without errors in Roblox executor
- [ ] UI appears and is interactive
- [ ] Status bar displays "Ready" or tip message
- [ ] First-run tour shows (if not completed)

### 2. Basic Commands

| Test | Input | Expected Result |
|------|-------|-----------------|
| Speed | "make me fast" | Executes `speed` command |
| Fly | "let me fly" | Executes `fly` command |
| Direct | "speed 100" | FastMap match, immediate exec |
| Help | "help" | Status bar shows bind syntax |
| Stop | "stop flying" | Executes `unfly` command |

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
| Me | "goto me" | Resolves to local player |
| Random | "goto random" | Picks random other player |

### 5. Chat Mode

| Test | Steps | Expected |
|------|-------|----------|
| Toggle | Press RShift | "Chat Mode" indicator |
| Response | Ask a question | AI responds conversationally |
| History | Follow-up question | Contextual response |
| Toggle Off | Press RShift again | Returns to Command Mode |

### 6. Waypoint System

| Test | Input | Expected |
|------|-------|----------|
| Save | "swp base" or "save this spot as base" | Waypoint saved |
| Go To | "wp base" or "go to my base waypoint" | Teleports to waypoint |
| List | "waypoints" | Shows saved waypoints |
| Delete | "dwp base" | Removes waypoint |

---

## Edge Case Test Matrix

### Input Validation

| Input | Expected Behavior |
|-------|-------------------|
| Empty string | Ignored |
| Only spaces | Ignored |
| Very long (>500 chars) | Truncated to limit |
| Special chars `<>&` | Sanitized |
| Dangerous tokens (`loadstring`) | Removed |

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
| "noclip; fly; speed 50" | All three execute |

### State Toggle Commands

| Input | Expected |
|-------|----------|
| "stop flying" | Executes `unfly` |
| "remove esp" | Executes `noesp` |
| "reset speed" | Executes `speed 16` |
| "fix camera" | Executes `fixcam` |

---

## Performance Benchmarks

| Metric | Target | Method |
|--------|--------|--------|
| FastMap lookup | <5ms | Time first-char index hit |
| Fuzzy match (short) | <1ms | fuzzyMatchPlayer with 3-char input |
| Fuzzy match (long) | <10ms | fuzzyMatchPlayer with 20-char input |
| UI responsiveness | <16ms | No frame drops during input |
| Cache lookup | <1ms | Normalized key lookup |

---

## Mobile-Specific Tests

### Quick Actions

| Test | Expected |
|------|----------|
| Quick Action visible | Button appears on mobile |
| Tap response | Action grid opens |
| Touch targets | Minimum 44px cell size |

### Input Handling

| Test | Expected |
|------|----------|
| Virtual keyboard | Opens on input focus |
| Soft keyboard dismiss | Closes dropdown properly |

---

## Bridge Connection

| Test | Expected |
|------|----------|
| IY not loaded | Retries with timeout, shows error |
| IY loaded | Bridge connects, executes commands |
| Command execution | Feedback in status bar |
