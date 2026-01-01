# Changelog

All notable changes to the **SmartInfiniteYield** project will be documented in this file.

## [1.2.1] - 2026-01-02
### Added
- **Enhanced Bridge Reliability:** Implemented event-based system using BindableEvents for instant bridge connection, eliminating "Bridge not connected" errors.
- **Intelligent Command Caching:** Local cache system using writefile/readfile to store successful AI translations, enabling instant execution of learned phrases without API calls.
- **Advanced Fuzzy Target Resolution:** Implemented Levenshtein distance-based fuzzy matching for player names (e.g., "kill valk" → "Valkorym").
- **Visual AI Processing Indicator:** Added animated glowing aura effect that pulses while AI processes requests.
- **Command Preview Bar:** Displays AI-generated command preview in status bar before execution for user verification.
- **Mobile Quick Actions Grid:** Added one-tap command grid for mobile users with 9 common AI prompts (Fly, Speed, ESP, Noclip, God, Teleport, Kill, Reset, Anti-Lag).

### Improved
- **Bridge System:** Replaced polling-based bridge detection with event-driven architecture for faster startup.
- **Cache Optimization:** Automatic cache management with LRU-style cleanup when max entries reached.
- **Target Resolution:** Enhanced player targeting with prefix matching, contains matching, and fuzzy matching fallback.
- **UI Polish:** Updated tutorial modal with v1.2.1 feature highlights.

### Technical
- **New Dependencies:** Added RunService for animation handling.
- **Config Expansion:** Added CacheEnabled, CacheFile, and MaxCacheEntries configuration options.

## [1.2.0] - 2026-01-01
### Added
- **Split-Context Strategy:** Implemented static/dynamic context separation, reducing token costs by ~90%.
- **Natural Chain Detection:** Support for multi-part requests (e.g., "fly and goto") with smarter processing.
- **Predictive UI:** Added a dynamic dropdown system replacing traditional ghost text.
- **Master Toggle:** Added `Right Shift` as the master keybind for the GUI.
- **Smart Bind System:** Automated toggling for binds (e.g., `bind f fly` now handles both fly and unfly).
- **Complete Command Database:** Integrated the full Infinite Yield command list for instant local execution.

### Fixed
- **Model Upgrade:** Switched to OpenAI (GPT-5 Mini) for superior reasoning and stability.
- **Regex Improvements:** Fixed "Greedy" regex bugs where commands like 'fly' would break text arguments.
- **Chat Mode Polish:** Removed unnecessary `;chat` prefixes to prevent "Prompt Pollution."
- **UI Fixes:** Resolved Z-Index issues and general UI polish.

## [1.1.0] - 2025-12-28
### Added
- **Security:** Integrated Cloudflare API to block abusive activity and bad actors.
- **Logic Engine:** Significant improvements to the reasoning engine for faster and more accurate translations.

### Fixed
- **Responsive UI:** Improved the GUI for both PC and Mobile users, making it cleaner and more responsive.
- **Bug Fixes:** Resolved several logic bugs and updated the core engine.

## [1.0.0] - 2025-11-25
### Added
- **Initial Release:** First stable version of SmartInfiniteYield.
- **AI Integration:** Basic natural language to command translation.
- **Thinking Bar:** Visual feedback for AI processing.
- **AI Responses:** Initial implementation of the assistant's conversational abilities.

---
*Note: Dates are estimated based on repository activity and script documentation.*
