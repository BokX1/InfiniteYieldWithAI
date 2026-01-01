# Project Roadmap: SmartInfiniteYield (SIY)

This document outlines the planned technical and user experience improvements for the SmartInfiniteYield project.

## Technical Optimizations

### 1. Enhanced Bridge Reliability ✅ COMPLETED (v1.3.0)
Currently, the bridge relies on polling `getgenv().PseudoBridge`.
- **Goal:** Implement an event-based system using `BindableEvents`.
- **Benefit:** Faster startup and elimination of "Bridge not connected" errors by ensuring the bridge is ready the instant Infinite Yield loads.
- **Implementation:** Added `BridgeReady` BindableEvent with `waitForBridge()` helper function for event-driven bridge detection.

### 2. Intelligent Command Caching ✅ COMPLETED (v1.3.0)
The `FastMap` is currently static and requires manual updates.
- **Goal:** Implement a local cache using `writefile` and `readfile` to store successful AI translations.
- **Benefit:** The script will "learn" common user phrases (e.g., "Make me fast" -> `;speed 50`), executing them instantly from local storage without needing AI calls or incurring token costs.
- **Implementation:** Added `CommandCache` system with `loadCache()`, `saveCache()`, `getCachedCommand()`, and `cacheCommand()` functions. Configurable via `CONFIG.CacheEnabled`, `CONFIG.CacheFile`, and `CONFIG.MaxCacheEntries`.

### 3. Advanced Target Resolution ✅ COMPLETED (v1.3.0)
Current targeting relies on strict regex matching.
- **Goal:** Implement fuzzy-matching for player names.
- **Benefit:** Allows for more natural targeting (e.g., "kill valk" resolving to "Valkorym"), significantly improving the user experience in games with complex usernames.
- **Implementation:** Added `levenshteinDistance()` and `fuzzyMatchPlayer()` functions with prefix matching, contains matching, and Levenshtein distance-based fuzzy matching.

## AI & Prompt Engineering

### 1. Optimized System Prompting 🔄 IN PROGRESS
The current system prompt is large (~3500 tokens).
- **Goal:** Refactor the command database and logic rules to be as concise as possible while maintaining high reasoning quality.
- **Note:** While dynamic chunking was considered, we will prioritize maintaining a consistent prompt structure above the 1.2k token threshold to leverage provider-side prompt caching for better performance and cost efficiency.
- **Status:** Deferred to future release. Current caching system reduces API calls significantly, mitigating token costs.

## UI/UX Enhancements

### 1. Visual Feedback for AI Processing ✅ COMPLETED (v1.3.0)
- **Goal:** Add a subtle visual indicator, such as a glowing aura or a progress bar, that pulses while the AI is processing a request.
- **Benefit:** Provides clear feedback to the user that the system is working, making the wait time feel more interactive.
- **Implementation:** Added `ProcessingGlow` frame with animated `UIGradient` and `UIStroke` that rotates and pulses during AI processing via `startGlowAnimation()` and `stopGlowAnimation()`.

### 2. Command Preview ✅ COMPLETED (v1.3.0)
- **Goal:** Display a brief preview of the AI-generated command in the status bar before execution.
- **Benefit:** Increases user trust and allows for a split-second verification of the AI's intent before the command is applied.
- **Implementation:** Added `PreviewBar` with `showPreview()` and `hidePreview()` functions. Preview displays for 3 seconds or until next action.

### 3. Mobile-Specific UI ✅ COMPLETED (v1.3.0)
- **Goal:** Create a "Quick Actions" grid for mobile users with common AI prompts.
- **Benefit:** Reduces the need for slow mobile typing, allowing for one-tap AI interactions.
- **Implementation:** Added `QuickActionsFrame` with 9 pre-configured actions (Fly, Speed, ESP, Noclip, God, Teleport, Kill, Reset, Anti-Lag) in a 3-column grid layout, toggled via ⚡ button.

---

## Future Considerations

### Performance Monitoring
- **Goal:** Add optional telemetry for cache hit rates and AI response times.
- **Status:** Planned for v1.4.0

### Custom Quick Actions
- **Goal:** Allow users to customize the Quick Actions grid with their own prompts.
- **Status:** Planned for v1.4.0

### Offline Mode
- **Goal:** Enhanced offline functionality using expanded local FastMap.
- **Status:** Under consideration
