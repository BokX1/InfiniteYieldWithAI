# Changelog

All notable changes to **SmartInfiniteYield** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.3.1] - 2026-01-06

### Fixed

| Fix | Description |
|-----|-------------|
| **Headless GUI Visibility** | Ensures the headless virtualization shim runs IYsource inside a sandboxed loader that mocks UI classes so the base Infinite Yield GUI stays hidden when headless mode is enabled. |
| **Hot-Swap Consistency** | Reuses the sandboxed loader during hot-swaps to prevent GUI elements from reappearing after refreshing IYsource. |

### Technical

| Improvement | Description |
|-------------|-------------|
| **Sandboxed IY Loader** | Centralized IYsource execution helper that injects mock `Instance.new` handling for UI classes while delegating non-UI instances to Roblox. |

---

## [1.3.0] - 2026-01-05

### 🚀 Headless Engine Release

This version deconstructs the monolithic script into a **Headless Engine** using a Client-Server model.

#### Part 1: The Injection Layer (The "Shim")
- [x] **Dynamic Loading**: `fetchIYSource()` fetches `IYsource.lua` from repo with memory and file caching.
- [x] **Virtualization Shim**: `buildVirtualizationShim()` creates injection code to mock the GUI.
- [x] **Mock GUI**: Dummy tables for `Holder`, `Title`, `Description`, `ScaledHolder`, `Notification`, `Cmdbar`.
- [x] **Metatable Protection**: `protectedInstanceNew()` redirects `Instance.new` calls for UI elements to dummy objects.
- [x] **IO Redirection**: `redirectedNotify()` overwrites `notify()` to write `{Title, Text}` to `_G.IY_Output`.
- [x] **Input Mocking**: `mockInputListeners()` disables or mocks `Chatted` and `UserInputService` listeners.

#### Part 2: Logic Hardening (The "Feedback Loop")
- [x] **Closed-Loop Feedback**: `startFeedbackLoop()` implements Write → Read → Report loop with `RunService.Heartbeat`.
- [x] **Syntax Sanitization**: `sanitizeCommand()` helper for command formatting and prefix consistency.
- [x] **Crash Protection**: `safeExecute()` wraps execution in `pcall` to catch and report backend errors.
- [x] **Concurrency Management**: `cleanupExistingInstances()` provides automatic cleanup on load.

#### Part 3: Standardization (The "Service Architecture")
- [x] **Service Pattern Separation**: Code organized into `[CONFIG]`, `[SERVICES]`, and `[CONTROLLER]` sections.
- [x] **Unified API Contract**: `BridgeAPI.Execute(cmd)` and `BridgeAPI.GetOutput()` defined.
- [x] **Type Checking**: Luau `--!strict` directive with type annotations throughout.
- [x] **Hot-Swap Support**: `BridgeAPI.HotSwap()` allows updating `IYsource.lua` independently.

### Added

| Feature | Description |
|---------|-------------|
| **BridgeAPI** | Unified API contract with `Execute()`, `GetOutput()`, `GetAllOutput()`, `ClearOutput()`, `GetStatus()`, `StartFeedbackLoop()`, `StopFeedbackLoop()`, `HotSwap()` |
| **Headless Mode** | New `CONFIG.HeadlessMode` option to run without IY GUI rendering |
| **Dynamic IY Loading** | Fetches `IYsource.lua` from repository with 24-hour caching |
| **Output Buffer** | Configurable buffer (`OutputBufferSize`) for capturing IY notifications |
| **Feedback Loop** | Real-time output monitoring via `RunService.Heartbeat` with callback support |
| **Hot-Swap** | Reload `IYsource.lua` without restarting the script |
| **Crash Protection** | All executions wrapped in `pcall` with error reporting |
| **Concurrency Cleanup** | Automatic cleanup of existing instances on script load |

### Changed

| Change | Description |
|--------|-------------|
| **IYSourceURL** | Now points to `BokX1/InfiniteYieldWithAI` repo instead of external EdgeIY source |
| **Bridge Execution** | Enhanced with `BridgeAPI.Execute()` integration for headless mode |
| **Code Organization** | Restructured into `[CONFIG]`, `[SERVICES]`, `[CONTROLLER]` sections |
| **Type Safety** | Added Luau `--!strict` directive and type annotations |

### Fixed

| Fix | Description |
|-----|-------------|
| **GUI Initialization** | Fixed `HeadlessMode` defaulting to true which suppressed the main UI; now defaults to false |
| **Hot-Swap Logic** | Fixed `BridgeAPI.HotSwap()` to properly re-execute the source after fetching updates |
| **Feedback Tracking** | Improved feedback loop to use global index tracking, preventing missed entries during buffer trimming |
| **Bridge Execution** | Enabled `BridgeAPI.Execute()` for both GUI and Headless modes to provide consistent crash protection |
| **Shim Consistency** | Added `Index` field to shim output entries and fixed `execCmd` type checking across all execution paths |
| **Tutorial Visibility** | Added explicit visibility setting for `TutorialFrame` to ensure it shows on startup |

### Technical

| Improvement | Description |
|-------------|-------------|
| **Lines Added** | 614 new lines of code for Headless Engine implementation |
| **New Functions** | 15+ new functions for headless operation |
| **New Config Options** | 8 new configuration options for headless mode |
| **Mock GUI System** | Complete metatable-based GUI mocking for headless operation |
| **Type Definitions** | Added `BridgeAPIType`, `BridgeStatusType`, `OutputEntryType` type definitions |

---

## [1.2.2] - 2026-01-03

### Added
| Feature | Description |
|---------|-------------|
| **ChatGPT-like CHAT Mode UI** | Complete redesign of CHAT mode with modern message bubbles, role indicators (👤 You / 🤖 Assistant), and timestamps |
| **Memory Indicator** | Visual indicator showing conversation context usage (Memory: X/6) with color-coded status |
| **Chat Placeholder** | Helpful placeholder text when chat is empty, guiding users to start conversations |
| **Auto-Context Injection** | Automatic game-state context injection including Game Name, Genre, Player Team, and Player Count |
| **Game Genre Detection** | Automatic detection of game type (Obby, Tycoon, Simulator, Roleplay, PvP, Horror) from game metadata |
| **Team Awareness** | Tracks player team changes and includes team context in AI prompts |
| **Enhanced Bridge System** | Configurable retry logic with `BridgeMaxRetries`, `BridgeRetryDelay`, and `BridgeTimeout` settings |
| **Bridge Status Function** | New `getBridgeStatus()` function for debugging connection issues |
| **Dropdown Focus Management** | Configurable delay-based focus check (`DropdownFocusDelay`) to prevent UI flickering |
| **Clear Chat Function** | New `clearChatLog()` function exposed via namespace for programmatic chat clearing |
| **Mobile UI Scaling** | Dynamic scaling for high-density displays with `MobileQuickActionScale` and `MobileMinCellSize` config |
| **Chat Mode Container** | Dedicated container for CHAT mode components with proper visibility toggling |
| **Input Sanitization** | Security layer removes control characters and dangerous Lua patterns from user input |
| **Namespace Isolation** | Global variables now use `SmartInfiniteYield` namespace to prevent conflicts |
| **Cleanup Handlers** | Proper cleanup on player leaving or game closing, saves cache and disconnects events |
| **Configurable Constants** | All timing values, thresholds, and limits now use CONFIG table |
| **Rate Limiting** | Prevents rapid successive AI requests with configurable cooldown |
| **JSON Error Handling** | Safe parsing of AI responses prevents crashes from malformed data |
| **Smart Waypoint System** | New `gotowp` command for teleporting to saved waypoints |
| **Waypoint Dropdown** | Type `gotowp ` to see all saved waypoints in dropdown suggestions |
| **Player Dropdown** | Type `goto ` to see all players in dropdown suggestions |
| **Waypoint Tutorial** | New tutorial step explaining waypoint commands (swp, gotowp, goto) |
| **Command Aliases** | Added `gwp` and `wpgoto` as aliases for `gotowp` |
| **Event-Based Bridge** | BindableEvents system for instant bridge connection, eliminating "Bridge not connected" errors |
| **Intelligent Caching** | Local cache using writefile/readfile stores AI translations for instant execution |
| **Fuzzy Targeting** | Levenshtein distance matching for player names (e.g., "valk" → "Valkorym") |
| **Processing Indicator** | Animated glowing aura pulses while AI processes requests |
| **Command Preview** | Status bar shows AI-generated command before execution |
| **Quick Actions** | Mobile one-tap grid: Fly, Speed, ESP, noclip, Jump, Teleport, Invisible, Reset, Anti-Lag |
| **Cache Management** | `clearcache` wipes learned commands; `cacheinfo` shows statistics |
| **Interactive Tutorial** | 8-step onboarding covering all features before GUI unlock |
| **Help Button** | Reopen tutorial anytime via "?" button in main GUI |
| **Fun Messages System** | Varied status messages with personality (Ready, Thinking, Success, etc.) |
| **Random Tips** | Helpful tips displayed after 25% of successful executions |
| **Button Animations** | Hover effects on Help/Minimize buttons, bounce on Mode switch |
| **Open Button Pulse** | Glowing pulse animation when floating button is visible |
| **Quick Action Effects** | Hover and press animations for mobile command grid |
| **Token Cache Optimization** | Optimized API calls to enable OpenAI token caching for reduced costs |
| **Target-Smart Context** | Player list is only injected into API payloads when target cues are detected |

### Changed
| Change | Description |
|--------|-------------|
| **Compact Mode Dropdown** | Replaced oversized mode toggle button with a compact dropdown selector (55px vs 95px) |
| **Streamlined Header Layout** | Reduced button sizes (26px vs 30px) and optimized spacing for a cleaner header |
| **Compact CMD Mode Frame** | Reduced default CMD mode height from 220px to 65px for minimal footprint |
| **Optimized Chat Mode Frame** | Reduced chat mode width from 560px to 420px for better screen utilization |
| **Input Box Sizing** | Adjusted input box height (26px vs 30px) and font size (12px vs 14px) for compact layout |
| **Preview Bar Positioning** | Moved preview bar to tooltip-style position below input area |
| **Quick Actions Toggle** | Relocated mobile quick actions button to bottom-right corner |
| **API Request Authorization** | AI requests now include the configured `ApiKey` as a Bearer token when provided |
| **AI Request Resilience** | Endpoint calls honor `RequestTimeout`, retry up to `MaxRetries`, and surface clearer errors (e.g., invalid API keys) |

### Fixed

| Fix | Description |
|-----|-------------|
| **Text Collision** | Eliminated text overlap between mode button, input area, and status elements |
| **Oversized Mode Button** | Fixed the permanently large CMD/CHAT button that consumed excessive header space |
| **Status Bar Visibility** | Status now appears temporarily and auto-hides in compact CMD mode |
| **Frame Expansion** | Frame temporarily expands to show status messages, then returns to compact size |
| **Dropdown Arrow Indicator** | Added "▾" arrow to mode button to indicate dropdown functionality |
| **Mobile Quick Actions** | Fixed visibility toggle for quick actions button when switching modes |
| **HTTP Capability Guard** | Blocks only the AI request section when executor HTTP support is unavailable, preserving offline command chains and cache execution |
| **Waypoint Validation** | Trims and validates `gotowp` waypoint names before running waypoint teleports |
| **Safe Waypoint Discovery** | Falls back to `_G` waypoints when `getgenv` is missing or inaccessible instead of returning an empty list |
| **Connection Cleanup** | Centralized connection registry disconnects persistent UI, input, and RunService signals during cleanup to prevent leaks |
| **Drag Input Leak** | Registers the long-lived `UserInputService.InputChanged` drag listener so repeated GUI spawns no longer accumulate connections |
| **Input Sanitization Frontiers** | Frontier-pattern filtering removes dangerous functions without corrupting benign words containing similar substrings |
| **Levenshtein GC Optimization** | Two-row distance calculation avoids large matrices, reducing garbage collection overhead during fuzzy matching |
| **Glow Reset on Cleanup** | Cleanup now clears the glow animation handle after disconnecting it so future sessions can safely restart the effect |

### Technical

| Improvement | Description |
|-------------|-------------|
| **Mode Dropdown System** | New dropdown container with CMD/CHAT options and hover effects |
| **Click-Outside-to-Close** | Dropdown automatically closes when clicking outside its area |
| **Temporary Status Display** | Status messages expand frame, display for 2.5s, then collapse |
| **Consistent Sizing** | All header elements now use consistent 26px height and 4px corner radius |
| **Removed Status Persistence** | StatusLabel no longer persists in compact CMD mode, reducing visual clutter |

---

## [1.2.1] - 2026-01-03

### Changed

| Change | Description |
|--------|-------------|
| **Fuzzy Match Precision** | Dynamic threshold based on input length - shorter inputs require stricter matching to prevent false positives |
| **Minimum Input Length** | New `FuzzyMatchMinInputLength` config (default: 3) prevents 1-2 character inputs from fuzzy matching |
| **Chat Log Styling** | Increased padding, larger font sizes, and better color contrast for readability |
| **Mode Switch Animation** | Enhanced mode switch with proper container visibility toggling and status updates |
| **Bridge Initialization** | Added retry logic during initial connection with periodic reconnection attempts |
| **Context Injection** | CMD mode now includes minimal game context for better command understanding |
| **CHAT Mode Prompt** | Enhanced with genre hints and team awareness for more contextual responses |
| **Quick Action Grid** | Cell size and font now scale based on display density |
| **Bridge System** | Replaced polling with event-driven architecture |
| **Cache Cleanup** | LRU-style eviction when max entries reached |
| **Target Resolution** | Added prefix, contains, and fuzzy matching fallback |
| **Tutorial** | Multi-step walkthrough replaces single-screen modal |
| **Quick Actions** | Replaced God/Kill with Jump/Invisible for universal compatibility |
| **Placeholder Text** | More engaging prompts ("Tell me what to do..." instead of "Enter command...") |
| **Status Messages** | Friendlier, more varied feedback with personality |
| **CHAT Mode Context** | Enhanced dynamic context with proper framing for game script assistance |
