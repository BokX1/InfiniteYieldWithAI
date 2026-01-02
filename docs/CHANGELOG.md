# Changelog

All notable changes to **SmartInfiniteYield** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

Features currently in development for the next release.

### Planned

- Additional game genre detection patterns
- Voice command integration exploration
- Plugin system for custom command handlers

---

## [1.2.1] - 2026-01-03

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
| **Safety Compliance** | Removed potentially triggering terms from CHAT mode prompt to prevent AI refusals |
| **Command Reference** | CHAT mode now includes curated command reference for better question answering |

### Fixed

| Fix | Description |
|-----|-------------|
| **ChatHistoryLimit Declaration** | Fixed forward declaration to prevent nil reference errors |
| **Duplicate Variable Declaration** | Removed duplicate `ChatHistoryLimit` declaration |
| **Bridge Validation** | Added proper nil checks for bridge interface and Exec function |
| **Input Validation** | Enhanced `executeBridge` with input type and empty string validation |
| **Chat Log Cleanup** | Added pcall protection when destroying chat entries |
| **Memory Leak Prevention** | `clearChatLog` now properly clears both UI and internal ChatHistory |
| **Dropdown Persistence** | Fixed issue where suggestions would persist after input focus loss |
| **Focus Race Condition** | Added focus check ID system to prevent stale hide operations |
| **CHAT Mode Refusals** | Resolved issue where AI would refuse to answer questions about commands like "how do I fly?" |
| **Context Framing** | Added legitimate gaming context to prevent safety guardrail triggers |

### Technical

| Improvement | Description |
|-------------|-------------|
| **Config Expansion** | Added 8 new configuration options for bridge, mobile, dropdown, and fuzzy matching |
| **Color Palette** | Extended Colors table with ChatGPT-like colors for CHAT mode UI |
| **Namespace Exports** | Added `ClearChat` and `GetBridgeStatus` to namespace for external access |
| **Code Structure** | 19 numbered sections with clear headers |
| **Helper Functions** | Reusable `createInstance()`, `sanitizeInput()`, namespace helpers reduce duplication |
| **Variable Naming** | Standardized to Roblox conventions |
| **Error Handling** | Improved pcall usage throughout bridge and UI operations |
| **Iterators** | ipairs() for arrays, pairs() for dictionaries |
| **Dynamic Context** | Minimized variable content in API calls; player list only sent when targeting needed |
| **FastMap Completeness** | Added 11 missing commands (swp, nofullbright, exit, partpath, copyanimation, etc.) |
| **Fuzzy Match Optimization** | Levenshtein distance calculated once per player instead of multiple times |
| **Global Isolation** | All globals use SmartInfiniteYield namespace to prevent pollution |

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

[Unreleased]: https://github.com/BokX1/InfiniteYieldWithAI/compare/v1.2.1...HEAD
[1.2.1]: https://github.com/BokX1/InfiniteYieldWithAI/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/BokX1/InfiniteYieldWithAI/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/BokX1/InfiniteYieldWithAI/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/BokX1/InfiniteYieldWithAI/releases/tag/v1.0.0
