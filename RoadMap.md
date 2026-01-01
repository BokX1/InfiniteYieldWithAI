# Project Roadmap: SmartInfiniteYield (SIY)

This document outlines the planned technical and user experience improvements for the SmartInfiniteYield project.

## Technical Optimizations

### 1. Enhanced Bridge Reliability
Currently, the bridge relies on polling `getgenv().PseudoBridge`.
- **Goal:** Implement an event-based system using `BindableEvents`.
- **Benefit:** Faster startup and elimination of "Bridge not connected" errors by ensuring the bridge is ready the instant Infinite Yield loads.

### 2. Intelligent Command Caching
The `FastMap` is currently static and requires manual updates.
- **Goal:** Implement a local cache using `writefile` and `readfile` to store successful AI translations.
- **Benefit:** The script will "learn" common user phrases (e.g., "Make me fast" -> `;speed 50`), executing them instantly from local storage without needing AI calls or incurring token costs.

### 3. Advanced Target Resolution
Current targeting relies on strict regex matching.
- **Goal:** Implement fuzzy-matching for player names.
- **Benefit:** Allows for more natural targeting (e.g., "kill valk" resolving to "Valkorym"), significantly improving the user experience in games with complex usernames.

## AI & Prompt Engineering

### 1. Optimized System Prompting
The current system prompt is large (~3500 tokens).
- **Goal:** Refactor the command database and logic rules to be as concise as possible while maintaining high reasoning quality.
- **Note:** While dynamic chunking was considered, we will prioritize maintaining a consistent prompt structure above the 1.2k token threshold to leverage provider-side prompt caching for better performance and cost efficiency.

## UI/UX Enhancements

### 1. Visual Feedback for AI Processing
- **Goal:** Add a subtle visual indicator, such as a glowing aura or a progress bar, that pulses while the AI is processing a request.
- **Benefit:** Provides clear feedback to the user that the system is working, making the wait time feel more interactive.

### 2. Command Preview
- **Goal:** Display a brief preview of the AI-generated command in the status bar before execution.
- **Benefit:** Increases user trust and allows for a split-second verification of the AI's intent before the command is applied.

### 3. Mobile-Specific UI
- **Goal:** Create a "Quick Actions" grid for mobile users with common AI prompts.
- **Benefit:** Reduces the need for slow mobile typing, allowing for one-tap AI interactions.
