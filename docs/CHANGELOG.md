# Changelog

All notable changes to **SmartInfiniteYield** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.3.3] - 2026-01-16

### Added

| Feature | Description |
|---------|-------------|
| **ConfigType LuaU Type** | Full type definition for CONFIG with 25+ typed fields for IDE support |
| **ColorPalette LuaU Type** | Full type definition for Colors with 18 typed fields |
| **CacheEntry Type** | Type definition for cache entries with command and timestamp |
| **BridgeStatus Type** | Type definition for bridge connection status |
| **FastMap Indexing** | O(1) group lookup for commands based on first character (10x faster matching) |
| **Levenshtein Optimization** | Early exit strategy for fuzzy matching to prevent CPU spikes on long inputs |
| **Drag System Auto-Cleanup** | Frames now auto-cleanup drag connections when destroyed |
| **Testing Documentation** | Added `docs/TESTING.md` with manual verification procedures and edge case matrices |
| **Agent Development Guide** | Added `.agent/AGENT_GUIDE.md` with codebase architecture documentation |

### Changed

| Change | Description |
|--------|-------------|
| **AI Model Upgrade** | Updated AI model to DeepSeek (via Pollinations.AI) for improved reasoning and faster responses |
| **AGENT_GUIDE.md Overhaul** | Updated all line number references to match v1.3.3 codebase, added 7 missing component sections |
| **TESTING.md Expansion** | Added 5 new test sections: Waypoint System, State Toggle Commands, Mobile-Specific Tests, Bridge Connection, Performance Benchmarks |
| **UI Helper Functions** | Enhanced with explicit LuaU type annotations and type casts |
| **Cache System Functions** | All 6 cache functions now have full type annotations |
| **Bridge Functions** | `waitForBridge` and `getBridgeStatus` have full type annotations |
| **Fuzzy Matching System** | `levenshteinDistance` now supports max distance cutoff |
| **Utility Functions** | `trim`, `normalizeInput`, `sanitizeInput` have type signatures |

### Fixed

| Fix | Description |
|-----|-------------|
| **Cache Commands Not Executing** | `clearcache` and `cacheinfo` commands now intercept early in Fast Path before AI query |
| **Duplicate Section Numbering** | Fixed `1D` label used for both Error Handler and IY Integration - sections now correctly labeled 1D through 1H |
| **Tween Connection Memory Leak** | `animateDropdown` now registers `tween.Completed` connection for proper cleanup |

### Technical

| Improvement | Description |
|-------------|-------------|
| **Comprehensive Type Safety** | Added LuaU type annotations to 17+ core functions |
| **Memory Leak Prevention** | Added `Destroying` listener to `enableDrag()` for automatic connection cleanup |
| **IDE Support** | Type definitions provide autocomplete and error checking in supported editors |
| **Command Processing** | Optimized from O(N) linear scan to O(1) group lookup for command patterns |

---

## [1.3.2] - 2026-01-14

### Changed

| Change | Description |
|--------|-------------|
| **Chat Persona Revamp** | Updated Chat Mode prompt to be significantly more friendly, engaging, and "gamer-like", reducing technical jargon |

### Fixed

| Fix | Description |
|-----|-------------|
| **Duplicate EventBus Declaration** | Removed duplicate `local EventBus = {}` declaration that shadowed the first |
| **Drag System Memory Leak** | Fixed `InputChanged` connection not being registered/disconnected in `enableDrag` |
| **Version String Mismatch** | Synchronized namespace version string with header comment |
| **Section Numbering** | Fixed duplicate section numbering (1C was used twice) - Error Handler now correctly labeled as 1D |
| **IS_CHAT_MODE Declaration Order** | Added forward declaration of `IS_CHAT_MODE` in UI Configuration section before its first usage |
| **PluginBridge Method Name** | Fixed `executeCommand` function calling incorrect method `execCmd` instead of `Exec` |
| **FastMap Duplicates** | Removed 24 duplicate command patterns from FastMap that were already defined elsewhere |

### Technical

| Improvement | Description |
|-------------|-------------|
| **Type Safety** | Added `--!nonstrict` mode and Luau type annotations to core systems (`EventBus`, `LifecycleManager`) |
| **Error Handling** | Enhanced `ErrorHandler` with typed signatures |
| **Code Cleanup** | Consolidated duplicate entries and improved code organization |

## [1.3.1] - 2026-01-11

### Added

| Feature | Description |
|---------|-------------|
| **Bridge Failure Notification** | User-facing status message now displays when bridge connection fails, preventing confusion |

### Changed

| Change | Description |
|--------|-------------|
| **Mobile Touch Targets** | Quick Actions cells increased from 30px to 44px (iOS/Android standard) |
| **Mobile Quick Actions Toggle** | Button relocated to left of input box to prevent obstruction of minimize button |
| **Mobile Quick Actions Sizing** | Button size increased from 22x22 to 44x44 pixels, font from 12 to 16 |

### Fixed

| Fix | Description |
|-----|-------------|
| **Duplicate CHAT Mode Calls** | Removed duplicate `recordChatMessage`, `executeBridge`, and `resetVisuals` calls in AI response handler |
| **Duplicate CMD Mode Caching** | Removed duplicate `cacheCommand` and `showPreview` calls that caused double-caching |
| **SoundManager Connection Leak** | Fixed `sound.Ended` connection not being tracked, preventing memory leaks during extended usage |
| **AnimationManager Tween Leak** | Fixed `tween.Completed` connection in dropdown animations not being properly disconnected |
| **Duplicate FastMap Entries** | Removed redundant `waypoint` and `wp` pattern definitions |
| **Wrong Waypoint Command** | Fixed Section 3 prompt using `;gotowp` instead of correct `;waypoint` |

### Technical

| Improvement | Description |
|-------------|-------------|
| **Player List Caching** | `fuzzyMatchPlayer` now caches `Players:GetPlayers()` once per call for improved performance |
| **Connection Cleanup Pattern** | Established pattern for self-disconnecting one-shot connections to prevent leaks |
| **EventBus Notification System** | Added `SHOW_NOTIFICATION` event listener for extensible system notifications |

---

## [1.3.0] - 2026-01-11

### Added

| Feature | Description |
|---------|-------------|
| **Sound System** | Acoustic feedback for processing, success, and error events (configurable via `EnableSounds`) |
| **Onboarding Tour** | Interactive 8-step guide for new users highlighting key UI elements |
| **Theme Inheritance** | Automatically syncs with Infinite Yield's theme settings and colors |
| **Animations** | Smooth dropdown transitions, hover effects, and pulsating glow using TweenService |
| **Plugin Bridge API** | Global `SIY` table (v2.0) exposing `askAI`, `executeCommand`, and `getStatus` |
| **Lifecycle Manager** | Robust startup/shutdown handling to prevent memory leaks and ensure clean reloading |
| **Error Handler** | Centralized error reporting (`xpcall`) with safe function wrapping |
| **IY Integration** | Dynamic scraping of IY aliases and keybinds for enhanced AI context |

### Changed

| Change | Description |
|--------|-------------|
| **Event Architecture** | Migrated core communication to extensive `EventBus` system |
| **Configuration** | Added `EnableSounds`, `SoundVolume`, `EnableTour`, `AnimationSpeed`, `ThemeSync` to config |
| **Command Execution** | AI now emits `EventBus` signals for feedback sounds |

---

## [1.2.2.3] - 2026-01-11

### Added

| Feature | Description |
|---------|-------------|
| **Dynamic Command Map** | Commands are now extracted directly from IY's `cmds` table at runtime—no more hardcoded lists |
| **Enhanced Bridge v2.0** | Exposes `cmds`, `execCmd`, and `notify` for seamless integration |
| **Notification Hooking** | Captures command output (success/error messages) for AI feedback loop |
| **Auto-Updated Commands** | Any new IY commands are automatically supported without script updates |

### Fixed

| Fix | Description |
|-----|-------------|
| **Operator Precedence Bug** | Fixed logic error in `completeTutorial()` where property selection was incorrect due to `and`/`or` precedence |
| **Connection Cleanup** | Added `removeConnection()` call after bridge connection disconnect to prevent orphaned tracking entries |
| **BridgeReady Leak** | Added `BridgeReady:Destroy()` to cleanup function to properly dispose of BindableEvent |
| **Version Mismatch** | Synchronized exported version string (`1.2.2.3`) with header comment |

### Technical

| Improvement | Description |
|-------------|-------------|
| **Removed Unused Functions** | Cleaned up 4 unused utility functions (~45 lines): `getDynamicCommandSuggestions`, `isDynamicCommand`, `getLastNotification`, `clearLastNotification` |
| **Standardized Error Prefixes** | All `warn()` messages now use consistent `[SIY]` prefix format |
| **Bridge Version** | Bridge now reports version "2.0" for compatibility checking |
| **Priority Lookup** | Dynamic map checked before OrderedFastMap for faster resolution |

---

## [1.2.2.2] - 2026-01-09

### Fixed

| Fix | Description |
|-----|-------------|
| **Deterministic Command Matching** | Converted `FastMap` to `OrderedFastMap` sorted by pattern length (longest first) to ensure specific commands like `flyspeed` match before generic ones like `fly` |

### Technical

| Improvement | Description |
|-------------|-------------|
| **Input Debouncing** | Added 75ms debounce to dropdown updates reducing CPU usage during rapid typing |
| **Ordered Pattern Iteration** | Updated `queryAI` and `buildSuggestions` to use `ipairs(OrderedFastMap)` for consistent, ordered iteration |
| **LuaU Type Annotations** | Added type annotations (`@param`, `@return`) to 12+ core functions for better documentation |
| **Enhanced Error Logging** | `createInstance` and `cancelTask` now log specific errors via `warn()` with `[SIY]` prefix |
| **UI Builder Helpers** | Added `createButton()`, `createLabel()`, `createFrame()` helper functions for cleaner UI construction |

---

## [1.2.2.1] - 2026-01-08

### Fixed

| Fix | Description |
|-----|-------------|
| **Connection Stability** | Improved bridge connection reliability and error handling to prevent connection failures |
| **FastMap Synchronization** | Removed invalid commands and synchronized FastMap with IYsource.lua for accurate local execution |
| **Quick Actions Toggle** | Fixed mobile-specific Quick Actions toggle behavior for proper state management |

### Technical

| Improvement | Description |
|-------------|-------------|
| **Code Optimization** | Refactored 142 lines for better performance and maintainability |
| **Error Handling** | Enhanced error handling in bridge connection system |
| **Command Validation** | Improved command validation against IYsource.lua database |

---

## [1.2.2] - 2026-01-05

### Added

| Feature | Description |
|---------|-------------|
| **Toggle Quick Actions** | Quick action buttons now work as keybinds—press once to activate, press again to deactivate (Fly, Noclip, ESP, Speed, Jump, Invisible) |
| **Visual State Feedback** | Active quick actions show highlighted state with brighter colors and reduced transparency |
| **Comprehensive FastMap** | Updated with 400+ commands and all aliases extracted from IYsource.lua for complete local execution coverage |
| **Command Accuracy** | Fixed incorrect command mappings and added missing aliases (support, creator, antiafk, etc.) |
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
| **Waypoint Dropdown** | Type `gotowp` to see all saved waypoints in dropdown suggestions |
| **Player Dropdown** | Type `goto` to see all players in dropdown suggestions |
| **Waypoint Tutorial** | New tutorial step explaining waypoint commands (swp, gotowp, goto) |
| **Command Aliases** | Added `gwp` and `wpgoto` as aliases for `gotowp` |
| **Event-Based Bridge** | BindableEvents system for instant bridge connection, eliminating "Bridge not connected" errors |
| **Intelligent Caching** | Local cache using writefile/readfile stores AI translations for instant execution |
| **Fuzzy Targeting** | Levenshtein distance matching for player names (e.g., "valk" → "Valkorym") |
| **Processing Indicator** | Animated glowing aura pulses while AI processes requests |
| **Command Preview** | Status bar shows AI-generated command before execution |
| **Quick Actions** | Mobile one-tap grid with toggle functionality: Fly, Speed, ESP, Noclip, Jump, Teleport, Invisible, Reset, Anti-Lag |
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

---

## [1.2.0] - 2026-01-01

### Added

| Feature | Description |
|---------|-------------|
| **Split-Context Strategy** | Static/dynamic context separation reduces token costs by ~90% |
| **Chain Detection** | Multi-part requests like "fly and goto" processed correctly |
| **Predictive Dropdown** | Dynamic suggestions replace ghost text |
| **Master Toggle** | Right Shift shows/hides interface |
| **Smart Binds** | Auto-toggling (e.g., `bind f fly` handles fly/unfly) |
| **Command Database** | Full Infinite Yield command list for instant local execution |

### Fixed

| Fix | Description |
|-----|-------------|
| **AI Model** | Upgraded to OpenAI GPT-5 Mini for better reasoning |
| **Regex Bugs** | Fixed greedy patterns breaking text arguments |
| **Chat Mode** | Removed unnecessary `;chat` prefixes |
| **UI Z-Index** | Resolved layering issues |

---

## [1.1.0] - 2025-12-28

### Added

| Feature | Description |
|---------|-------------|
| **Cloudflare Security** | API protection against abuse |
| **Logic Engine v2** | Faster, more accurate translations |

### Fixed

| Fix | Description |
|-----|-------------|
| **Responsive UI** | Improved PC and Mobile layouts |
| **Core Bugs** | Multiple logic engine fixes |

---

## [1.0.0] - 2025-11-25

### Added

| Feature | Description |
|---------|-------------|
| **Initial Release** | First stable version |
| **AI Translation** | Natural language to command conversion |
| **Thinking Bar** | Visual AI processing feedback |
| **Dual Modes** | CMD for execution, CHAT for advice |

---
