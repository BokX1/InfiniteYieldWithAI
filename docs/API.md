# Plugin API Reference

> External script integration with SmartInfiniteYield via `_G.SIY`.

---

## Quick Start

```lua
-- Check if SIY is ready
if _G.SIY and _G.SIY.getStatus().ready then
    -- Use SIY API
    _G.SIY.executeCommand(";fly")
end
```

---

## Methods

### askAI(prompt)

Sends a natural language prompt to the AI for translation.

```lua
_G.SIY.askAI("make me fly fast")
-- Returns: translated command string or nil
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `prompt` | string | Natural language request |

**Returns:** `string?` — The translated command or nil if AI unavailable.

---

### executeCommand(command)

Executes an Infinite Yield command through the bridge.

```lua
_G.SIY.executeCommand(";fly ;speed 100")
-- Returns: true if executed, false if bridge unavailable
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `command` | string | IY command(s) to execute |

**Returns:** `boolean` — Success status.

---

### getStatus()

Gets current SIY status information.

```lua
local status = _G.SIY.getStatus()
print(status.ready, status.version)
```

**Returns:** `table`

| Field | Type | Description |
|-------|------|-------------|
| `ready` | boolean | Whether SIY is fully initialized |
| `version` | string | Current SIY version |

---

## Events

Subscribe to internal events via the EventBus (requires access to internal API):

| Event | Payload | Description |
|-------|---------|-------------|
| `AI_REQUEST_START` | — | AI processing started |
| `AI_REQUEST_COMPLETE` | `{prompt, response}` | AI returned a command |
| `AI_REQUEST_ERROR` | `{source, message}` | AI request failed |
| `COMMAND_EXECUTED` | `{source, command}` | Command was executed |
| `SHOW_NOTIFICATION` | `{title, message, duration}` | Display notification |

---

## Examples

### Execute Command on Keybind

```lua
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        if _G.SIY then
            _G.SIY.executeCommand(";fly")
        end
    end
end)
```

### AI-Powered Macro

```lua
local function smartAction(description)
    if _G.SIY and _G.SIY.getStatus().ready then
        _G.SIY.askAI(description)
    else
        warn("SIY not ready")
    end
end

-- Usage
smartAction("make me invisible and fly")
```

---

## Namespace Access

For advanced integration, access the full namespace:

```lua
local SIY_NS = getgenv and getgenv().SmartInfiniteYield or _G.SmartInfiniteYield

-- Available functions
SIY_NS.Cleanup()           -- Clean shutdown
SIY_NS.ClearChat()         -- Clear chat history
SIY_NS.GetBridgeStatus()   -- Detailed bridge status
SIY_NS.PluginBridge        -- Full API reference
```

---

## Version Compatibility

| API Version | SIY Version | Breaking Changes |
|-------------|-------------|------------------|
| v2.0 | 1.3.0+ | Added `getStatus()` |
| v1.0 | 1.0.0-1.2.x | Initial release |
