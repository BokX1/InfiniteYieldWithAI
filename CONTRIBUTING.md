# Contributing to SmartInfiniteYield

Thank you for your interest in contributing to SmartInfiniteYield! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)

---

## Code of Conduct

This project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior by opening an issue.

---

## How Can I Contribute?

### Reporting Bugs

Before creating a bug report, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title** describing the issue
- **Steps to reproduce** the behavior
- **Expected behavior** vs actual behavior
- **Executor information** (name, version)
- **Screenshots or videos** if applicable
- **Error messages** from the console

Use the [Bug Report Template](.github/ISSUE_TEMPLATE/bug_report.md).

### Suggesting Features

Feature suggestions are welcome! Please include:

- **Clear description** of the feature
- **Use case** explaining why it's needed
- **Possible implementation** if you have ideas
- **Alternatives considered**

Use the [Feature Request Template](.github/ISSUE_TEMPLATE/feature_request.md).

### Code Contributions

1. Check the [Roadmap](docs/ROADMAP.md) for planned features
2. Look for issues labeled `good first issue` or `help wanted`
3. Comment on an issue to claim it before starting work
4. Follow the development setup and coding standards below

---

## Development Setup

### Prerequisites

- A text editor (VS Code recommended with Lua extensions)
- Git for version control
- A Roblox executor for testing

### Getting Started

1. **Fork the repository**
   ```bash
   # Click "Fork" on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/InfiniteYieldWithAI.git
   cd InfiniteYieldWithAI
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Edit `InfiniteYieldWithAI_Dev.Lua` for development
   - Test thoroughly in multiple games
   - Test on both PC and mobile if possible

4. **Test your changes**
   - Ensure existing features still work
   - Test edge cases and error handling
   - Verify mobile compatibility

---

## Coding Standards

### Lua Style Guide

Follow these conventions for consistency:

#### Naming

```lua
-- Variables: camelCase
local playerName = "Example"
local isEnabled = true

-- Constants: UPPER_SNAKE_CASE
local MAX_RETRIES = 3
local DEFAULT_SPEED = 16

-- Functions: camelCase
local function calculateDistance(a, b)
    return (a - b).Magnitude
end

-- Private functions: prefixed with underscore
local function _internalHelper()
    -- ...
end
```

#### Formatting

```lua
-- Use 4 spaces for indentation (not tabs)
-- Add spaces around operators
local result = value1 + value2

-- Use explicit conditions
if isEnabled == true then  -- Preferred
if isEnabled then          -- Also acceptable

-- Group related code with section headers
--// ============================================
--// SECTION NAME
--// ============================================
```

#### Best Practices

```lua
-- Use local variables whenever possible
local myVar = "value"  -- Good
myVar = "value"        -- Avoid global

-- Use early returns to reduce nesting
local function process(input)
    if not input then return nil end
    if input == "" then return nil end
    -- Main logic here
end

-- Use ipairs for arrays, pairs for dictionaries
for i, v in ipairs(arrayTable) do end
for k, v in pairs(dictTable) do end

-- Wrap potentially failing code in pcall
local success, result = pcall(function()
    return riskyOperation()
end)
```

### Code Organization

The codebase is organized into numbered sections:

1. Services
2. Configuration
3. State Variables
4. Utility Functions
5. UI Components
6. Logic Engine
7. Event Handlers

Add new code to the appropriate section or create a new section if needed.

---

## Commit Guidelines

### Commit Message Format

Use conventional commits format:

```
type(scope): description

[optional body]

[optional footer]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation changes |
| `style` | Code style changes (formatting, etc.) |
| `refactor` | Code refactoring |
| `perf` | Performance improvements |
| `test` | Adding or updating tests |
| `chore` | Maintenance tasks |

### Examples

```
feat(cache): add LRU eviction for command cache

fix(ui): resolve tutorial not closing on mobile

docs(readme): update installation instructions

refactor(bridge): replace polling with event-based system
```

---

## Pull Request Process

### Before Submitting

1. **Update documentation** if your changes affect usage
2. **Update the changelog** with your changes
3. **Test thoroughly** on multiple executors if possible
4. **Ensure no console errors** during normal operation

### PR Requirements

- [ ] Code follows the style guide
- [ ] Changes are tested and working
- [ ] Documentation is updated (if applicable)
- [ ] Changelog is updated
- [ ] PR description explains the changes
- [ ] No merge conflicts with main branch

### Review Process

1. Submit your PR with a clear description
2. Maintainers will review within 1-3 days
3. Address any requested changes
4. Once approved, your PR will be merged

### After Merging

- Your contribution will be credited in the changelog
- The changes will be included in the next release
- Thank you for contributing!

---

## Questions?

If you have questions about contributing:

1. Check existing issues and discussions
2. Open a new issue with the `question` label
3. Join the Discord community via `;discord` in-game

---

Thank you for helping make SmartInfiniteYield better! 🎉
