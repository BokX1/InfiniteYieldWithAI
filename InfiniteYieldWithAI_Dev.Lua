--!nonstrict
--[[ 
    SMART INFINITE YIELD - V1.3.3 STABLE
    - Architecture: Context Awareness + Event-Based Bridge
    - Logic: VolQ5 & Pollinations.AI (LLM Model)
    - Status: Stable 
    - v1.3.3: Added comprehensive LuaU type annotations, UIFactory improvements, connection leak prevention
]]

--// ============================================
--// 1. SERVICES (Cached for Performance)
--// ============================================
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Namespace for global variable isolation
local NAMESPACE = "SmartInfiniteYield" --: string

--[=[
    @type NamespaceTable {[string]: any}
    Safe global access helpers with type annotations
]=]

--- Returns the namespace table, creating it if needed
--- @return table<string, any>
local function getNamespace()
    if getgenv then
        getgenv()[NAMESPACE] = getgenv()[NAMESPACE] or {}
        return getgenv()[NAMESPACE]
    elseif _G then
        _G[NAMESPACE] = _G[NAMESPACE] or {}
        return _G[NAMESPACE]
    end
    return {}
end

--- Sets a value in the namespace
--- @param key string -- The key to set
--- @param value any -- The value to store
local function setNamespaceValue(key, value)
    local ns = getNamespace()
    ns[key] = value
end

--- Gets a value from the namespace
--- @param key string -- The key to retrieve
--- @return any -- The stored value or nil
local function getNamespaceValue(key)
    local ns = getNamespace()
    return ns[key]
end

--[=[
    Centralized connection management
    Tracks all RBXScriptConnections for proper cleanup on script unload
]=]
local Connections = {} --: {RBXScriptConnection}
local PersistentTasks = {} --: {thread}

--- Registers a connection for cleanup tracking
--- @param connection RBXScriptConnection
--- @return RBXScriptConnection
local function registerConnection(connection)
    table.insert(Connections, connection)
    return connection
end

--- Connects a signal and registers it for cleanup
--- @param signalOrConnection RBXScriptSignal|RBXScriptConnection
--- @param callback function? -- Optional callback if first arg is a signal
--- @return RBXScriptConnection?
local function ConnectPersistent(signalOrConnection, callback)
    local connection = callback and signalOrConnection:Connect(callback) or signalOrConnection
    if connection then
        registerConnection(connection)
    end
    return connection
end

--- Removes a connection from tracking (call after manual disconnect)
--- @param target RBXScriptConnection
local function removeConnection(target)
    for index = #Connections, 1, -1 do
        if Connections[index] == target then
            table.remove(Connections, index)
            break
        end
    end
end

--- Registers a task thread for cleanup tracking
--- @param thread thread? -- The coroutine to track
--- @return thread?
local function registerTask(thread)
    if thread then
        table.insert(PersistentTasks, thread)
    end
    return thread
end

--- Cancels a task and removes it from tracking
--- @param thread thread? -- The coroutine to cancel
local function cancelTask(thread)
    if not thread then return end
    local success, err = pcall(task.cancel, thread)
    if not success then
        warn("[SIY] Failed to cancel task:", tostring(err))
    end
    for index = #PersistentTasks, 1, -1 do
        if PersistentTasks[index] == thread then
            table.remove(PersistentTasks, index)
            break
        end
    end
end

--- Cancels all tracked persistent tasks
local function cancelPersistentTasks()
    for index = #PersistentTasks, 1, -1 do
        cancelTask(PersistentTasks[index])
        PersistentTasks[index] = nil
    end
end


--// ============================================
--// 1B. EVENT BUS SYSTEM (v1.3.0)
--// ============================================
-- Decoupled communication between UI, Logic, and Services
local EventBus = {}
type EventCallback = (...any) -> ()
local _eventListeners = {}

--- Subscribe to an event
--- @param eventName string
--- @param callback function
--- @return function -- Disconnect function
function EventBus:on(eventName: string, callback: EventCallback)
    _eventListeners[eventName] = _eventListeners[eventName] or {}
    table.insert(_eventListeners[eventName], callback)
    return function()
        local listeners = _eventListeners[eventName]
        if listeners then
            for i, cb in ipairs(listeners) do
                if cb == callback then
                    table.remove(listeners, i)
                    break
                end
            end
        end
    end
end

--- Emit an event to all listeners
--- @param eventName string
--- @param ... any
function EventBus:emit(eventName: string, ...: any)
    local listeners = _eventListeners[eventName]
    if listeners then
        for _, callback in ipairs(listeners) do
            task.spawn(callback, ...)
        end
    end
end

--- Clear all event listeners
function EventBus:clear()
    _eventListeners = {}
end


--// ============================================
--// 1C. LIFECYCLE MANAGER (v1.3.0)
--// ============================================
-- Clean startup and shutdown for re-execution support
local LifecycleManager = {}
local _isInitialized = false

--- Startup sequence
function LifecycleManager:startup()
    if _isInitialized then
        self:shutdown() -- Clean previous instance
    end
    EventBus:clear()
    _isInitialized = true
    EventBus:emit("STARTUP_COMPLETE")
end

--- Shutdown sequence
function LifecycleManager:shutdown()
    if not _isInitialized then return end
    EventBus:emit("SHUTDOWN_START")
    
    -- Cancel all tasks
    cancelPersistentTasks()
    
    -- Disconnect all connections
    for i = #Connections, 1, -1 do
        local conn = Connections[i]
        if conn and conn.Connected then
            pcall(function() conn:Disconnect() end)
        end
        Connections[i] = nil
    end
    
    EventBus:clear()
    _isInitialized = false
end

--- Check if initialized
function LifecycleManager:isInitialized()
    return _isInitialized
end


--// ============================================
--// 1D. ERROR HANDLER (v1.3.0)
--// ============================================
-- Centralized error reporting with graceful degradation
local ErrorHandler = {}

--- Report an error
--- @param source string -- Where the error came from
--- @param message string -- Error description
--- @param severity string? -- "warning" | "error" | "fatal"
function ErrorHandler:report(source: string, message: string, severity: string?)
    local sev = severity or "error"
    local logMsg = string.format("[SIY %s] %s: %s", sev:upper(), source, message)
    warn(logMsg)
    EventBus:emit("ERROR_OCCURRED", {source = source, message = message, severity = sev})
end

--- Wrap a function with error handling
--- @param fn function -- Function to wrap
--- @param source string -- Source name for error reporting
--- @return function
function ErrorHandler:wrap(fn: (...any) -> ...any, source: string)
    return function(...)
        local results = {pcall(fn, ...)}
        local success = table.remove(results, 1)
        if not success then
            self:report(source, tostring(results[1]))
            return nil
        end
        return table.unpack(results)
    end
end


--// ============================================
--// 1E. IY INTEGRATION (v1.3.0)
--// ============================================
-- Scrapes IY's aliases and keybinds at runtime
local IYIntegration = {}

--- Scrape IY's custom aliases
--- @return table<string, string>
function IYIntegration:scrapeAliases()
    local aliases = _G.Aliases or (getgenv and getgenv().Aliases) or {}
    local result = {}
    for alias, command in pairs(aliases) do
        if type(alias) == "string" and type(command) == "string" then
            result[alias] = command
        end
    end
    return result
end

--- Scrape IY's keybinds
--- @return table<string, string>
function IYIntegration:scrapeKeybinds()
    local binds = _G.binds or (getgenv and getgenv().binds) or {}
    local result = {}
    for key, command in pairs(binds) do
        result[tostring(key)] = tostring(command)
    end
    return result
end

--- Build enhanced context string for AI
--- @return string
function IYIntegration:buildContext()
    local aliases = self:scrapeAliases()
    local parts = {}
    local count = 0
    for _ in pairs(aliases) do count = count + 1 end
    if count > 0 then
        table.insert(parts, "User aliases:")
        for alias, cmd in pairs(aliases) do
            table.insert(parts, string.format("  %s -> %s", alias, cmd))
        end
    end
    return table.concat(parts, "\n")
end


--// ============================================
--// 1F. THEME MANAGER (v1.3.0)
--// ============================================
-- Inherits IY's theme colors for consistent styling
local ThemeManager = {}

--- Get IY's theme colors
--- @return table
function ThemeManager:getIYTheme()
    local shade = _G.shade or (getgenv and getgenv().shade) or {}
    local text = _G.text or (getgenv and getgenv().text) or {}
    return {shade = shade, text = text}
end

--- Apply IY theme to an element
--- @param element GuiObject
--- @param themeType string -- "shade1" | "shade2" | "text"
function ThemeManager:applyToElement(element, themeType)
    local theme = self:getIYTheme()
    if themeType == "shade1" and theme.shade[1] then
        if theme.shade[1].BackgroundColor3 then
            element.BackgroundColor3 = theme.shade[1].BackgroundColor3
        end
    elseif themeType == "shade2" and theme.shade[2] then
        if theme.shade[2].BackgroundColor3 then
            element.BackgroundColor3 = theme.shade[2].BackgroundColor3
        end
    elseif themeType == "text" and theme.text[1] then
        if theme.text[1].TextColor3 then
            element.TextColor3 = theme.text[1].TextColor3
        end
    end
end

--- Get fallback colors
function ThemeManager:getFallbackColors()
    return {
        shade1 = Color3.fromRGB(36, 36, 37),
        shade2 = Color3.fromRGB(46, 46, 47),
        text = Color3.fromRGB(255, 255, 255)
    }
end


--// ============================================
--// 1G. ANIMATION MANAGER (v1.3.0)
--// ============================================
-- Smooth animations for UI elements
local AnimationManager = {}

--- Animate dropdown show/hide
--- @param frame Frame
--- @param visible boolean
--- @param duration number?
function AnimationManager:animateDropdown(frame, visible, duration)
    local dur = duration or 0.2
    local targetProps = {}
    
    if visible then
        targetProps.BackgroundTransparency = 0
        frame.Visible = true
    else
        targetProps.BackgroundTransparency = 1
    end
    
    local tween = TweenService:Create(frame, TweenInfo.new(dur, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), targetProps)
    tween:Play()
    
    if not visible then
        local conn
        conn = tween.Completed:Connect(function()
            if conn then
                conn:Disconnect()
                removeConnection(conn)
            end
            frame.Visible = false
        end)
        registerConnection(conn)
    end
    return tween
end

--- Create pulsating glow effect
--- @param element GuiObject
--- @param color Color3?
--- @return function -- Cleanup function
function AnimationManager:createPulsingGlow(element, color)
    local glowColor = color or Color3.fromRGB(100, 200, 255)
    
    local glow = Instance.new("UIStroke")
    glow.Name = "SIY_Highlight"
    glow.Color = glowColor
    glow.Thickness = 2
    glow.Parent = element
    
    local alpha = 0
    local conn = RunService.Heartbeat:Connect(function(dt)
        alpha = alpha + dt * 3
        glow.Transparency = 0.3 + math.sin(alpha) * 0.3
    end)
    registerConnection(conn)
    
    return function()
        conn:Disconnect()
        removeConnection(conn)
        if glow.Parent then glow:Destroy() end
    end
end


--// ============================================
--// 1H. TOUR MANAGER (v1.3.0)
--// ============================================
-- First-run onboarding tour
local TourManager = {}
local _tourActive = false
local _tourStep = 0
local _tourElements = {}
local _activeHighlights = {}

local _tourSteps = {
    {target = "InputBox", title = "Welcome! 🎉", message = "Type natural language here"},
    {target = "ModeToggle", title = "AI Mode", message = "Toggle AI (🤖) / Manual (⌨️)"},
    {target = "QuickActions", title = "Quick Actions", message = "Tap for instant commands"}
}

--- Register element for tour
function TourManager:registerElement(id, element)
    _tourElements[id] = element
end

--- Check if first run
function TourManager:isFirstRun()
    local ns = getNamespace()
    return not ns.hasCompletedTour and CONFIG.EnableTour
end

--- Start tour
function TourManager:start()
    if not self:isFirstRun() or _tourActive then return end
    _tourActive = true
    _tourStep = 0
    EventBus:emit("TOUR_START")
    self:showStep(1)
end

--- Show step
function TourManager:showStep(index)
    self:clearHighlights()
    local step = _tourSteps[index]
    if not step then self:complete() return end
    
    _tourStep = index
    local element = _tourElements[step.target]
    if element then
        local cleanup = AnimationManager:createPulsingGlow(element)
        table.insert(_activeHighlights, cleanup)
    end
    EventBus:emit("TOUR_STEP", {index = index, total = #_tourSteps, title = step.title, message = step.message})
end

--- Next step
function TourManager:nextStep()
    self:showStep(_tourStep + 1)
end

--- Complete tour
function TourManager:complete()
    self:clearHighlights()
    _tourActive = false
    setNamespaceValue("hasCompletedTour", true)
    EventBus:emit("TOUR_COMPLETE")
end

--- Clear highlights
function TourManager:clearHighlights()
    for _, cleanup in ipairs(_activeHighlights) do
        pcall(cleanup)
    end
    _activeHighlights = {}
end


--// ============================================
--// 2. CONFIGURATION
--// ============================================

--[=[
    @type ConfigType
    Centralized configuration with full LuaU type annotations
]=]
type ConfigType = {
    -- API Settings
    ApiKey: string,
    Endpoint: string,
    Model: string,
    MaxRetries: number,
    RequestTimeout: number,
    -- Cache Settings
    CacheEnabled: boolean,
    CacheFile: string,
    MaxCacheEntries: number,
    -- Rate Limiting
    AIRequestCooldown: number,
    -- Input Validation
    MaxInputLength: number,
    -- UI Timing Constants
    PreviewDelay: number,
    ErrorDisplayTime: number,
    StatusFadeTime: number,
    -- Fuzzy Matching
    FuzzyMatchMinThreshold: number,
    FuzzyMatchRatio: number,
    FuzzyMatchMinInputLength: number,
    -- Bridge Connection
    BridgeMaxRetries: number,
    BridgeRetryDelay: number,
    BridgeTimeout: number,
    -- Mobile UI Scaling
    MobileQuickActionScale: number,
    MobileMinCellSize: number,
    -- Dropdown Focus Management
    DropdownFocusDelay: number,
    DropdownMaxItems: number,
    -- Sound Feedback Settings
    EnableSounds: boolean,
    SoundVolume: number,
    -- First-Run Tour Settings
    EnableTour: boolean,
    -- System Prompt
    CommandPrompt: string,
    -- Chat Mode Prompt (optional)
    ChatPrompt: string?,
}

local CONFIG: ConfigType = {
    -- API Settings
    ApiKey = "Null",
    Endpoint = "https://infiniteyieldai.ahazihak03.workers.dev/v1/chat/completions",
    Model = "openai",
    MaxRetries = 2,
    RequestTimeout = 10, -- Seconds to wait for API response
    
    -- Cache Settings
    CacheEnabled = true,
    CacheFile = "SIY_CommandCache.json",
    MaxCacheEntries = 100,
    
    -- Rate Limiting
    AIRequestCooldown = 0.5, -- Minimum seconds between AI requests
    
    -- Input Validation
    MaxInputLength = 500, -- Maximum characters allowed in input
    
    -- UI Timing Constants
    PreviewDelay = 0.3, -- Seconds to show preview before execution
    ErrorDisplayTime = 2, -- Seconds to display error messages
    StatusFadeTime = 3, -- Seconds before status text fades
    
    -- Fuzzy Matching
    FuzzyMatchMinThreshold = 2, -- Minimum Levenshtein distance threshold
    FuzzyMatchRatio = 0.5, -- Ratio of input length for threshold calculation
    FuzzyMatchMinInputLength = 3, -- Minimum input length for fuzzy matching to prevent short name false positives
    
    -- Bridge Connection
    BridgeMaxRetries = 5, -- Maximum number of bridge connection retries
    BridgeRetryDelay = 0.5, -- Delay between bridge connection retries
    BridgeTimeout = 15, -- Total timeout for bridge connection
    
    -- Mobile UI Scaling
    MobileQuickActionScale = 1.0, -- Scale factor for mobile quick actions
    MobileMinCellSize = 44, -- Minimum cell size for quick actions (iOS/Android standard touch target)
    
    -- Dropdown Focus Management
    DropdownFocusDelay = 0.15, -- Delay before hiding dropdown after focus loss
    DropdownMaxItems = 6, -- Maximum items to show in dropdown
    
    -- v1.3.0: Sound Feedback Settings
    EnableSounds = false, -- Enable/disable sound effects
    SoundVolume = 0.5, -- Volume for sound effects (0-1)
    
    -- v1.3.0: First-Run Tour Settings  
    EnableTour = true, -- Enable first-run onboarding tour
    
    -- System Prompt (~3500 Tokens)
    CommandPrompt = [[
[SYSTEM MANIFESTO: SMART INFINITE YIELD]
ROLE: You are a Roblox Command Compiler. Convert Natural Language -> Infinite Yield Syntax.

### SECTION 1: LOGIC KERNEL (CRITICAL) ###
1. INVERSION & NEGATION (The "Stop" Rule):
   - If user says "stop", "don't", "quit", "remove", or "end":
     > Find the base command and prefix it with 'un' or 'no'.
     > Examples: "stop flying" -> ;unfly | "remove esp" -> ;noesp | "don't noclip" -> ;clip

2. STATE RESETS (The "Normal" Rule):
   - "slow down", "walk normal", "reset speed" -> ;speed 16
   - "normal jump", "reset jump" -> ;jumppower 50
   - "fix camera", "reset view" -> ;fixcam
   - "unfreeze", "thaw" -> ;unfreeze

3. CHAINING:
   - Separate multiple actions with semicolons (;). 
   - Example: "fly and fling him" -> ;fly ;fling
   
4. TARGETING:
   - "me" -> Output "me" (e.g., ;fling)
   - "random" -> Output "random" (e.g., ;goto random)
   - "all" / "everyone" -> INVALID. Ignore or ask for clarification.

### SECTION 2: COMPLETE COMMAND DATABASE ###

[UTILITY]
;discord               : Invite to support server.
;guiscale [0.4-2]      : Changes GUI size.
;console / ;oldconsole : Loads developer console.
;explorer / ;olddex    : Opens DEX explorer.
;remotespy / ;rspy     : Opens Remote Spy V3.
;audiologger           : Opens audio logger.
;antiidle              : Prevents AFK kick.
;datalimit [num]       : Set outgoing KBPS limit.
;replicationlag [num]  : Set incoming replication lag.
;creatorid             : Notifies creator ID.
;noprompts             : Prevents purchase prompts.
;showprompts           : Allows purchase prompts.
;enable [type]         : Toggles coregui (inventory/playerlist/chat).
;disable [type]        : Hides coregui items.
;showguis / ;hideguis  : Toggles PlayerGui visibility.
;guidelete             : Enables backspace to delete GUIs.
;hideiy / ;showiy      : Toggles Infinite Yield UI.
;keepiy                : Auto-execute IY on teleport.
;savegame              : Saves the game (saveinstance).
;clientantikick        : Prevents localscript kicks.
;clientantiteleport    : Prevents localscript teleports.
;volume [0-10]         : Adjusts game volume.
;antilag               : Lowers graphics to boost FPS.
;setfpscap [num]       : Sets FPS limit.
;notify [text]         : Sends a notification.

[MOVEMENT]
;noclip                : Walk through walls.
;unnoclip / ;clip      : Enable collision.
;fly [speed]           : Toggle flight.
;unfly                 : Disable flight.
;flyspeed [num]        : Set flight speed.
;vehiclefly [speed]    : Flight for vehicles.
;unvehiclefly          : Disable vehicle flight.
;cframefly [speed]     : CFrame-based flight (Bypass).
;uncframefly           : Disable CFrame flight.
;vehiclenoclip         : Disable vehicle collision.
;float / ;unfloat      : Spawns/removes platform under player.
;swim / ;unswim        : Toggle swimming in air.
;tpwalk [num]          : Teleport-based walking (Bypass).
;untpwalk              : Disable tpwalk.
;wallwalk              : Walk on walls.

[TELEPORT & WAYPOINTS]
;setwaypoint [name]    : Save position.
;waypoint [name]       : TP to waypoint.
;waypoints             : List waypoints.
;clearwaypoints        : Delete all waypoints.
;goto [plr]            : TP to player.
;tweengoto [plr]       : Smooth TP to player.
;vehiclegoto [plr]     : Car TP to player.
;loopgoto [plr]        : Constant TP to player.
;unloopgoto            : Stop loop TP.
;clientbring [plr]     : Bring player (Client-side).
;loopbring [plr]       : Loop bring player.
;spawnpoint            : Set custom spawn.
;nospawnpoint          : Remove custom spawn.
;flashback             : TP to last death point.
;walltp                : TP forward through wall.
;teleporttool          : Click to teleport tool.

[VISUALS]
;esp                   : Player ESP (Box).
;noesp                 : Remove ESP.
;espteam               : Team colored ESP.
;chams                 : Player Chams (Solid).
;nochams               : Remove Chams.
;xray / ;noxray        : Toggle wall transparency.
;spectate [plr]        : View player.
;unspectate            : Stop viewing.
;freecam               : Detach camera.
;unfreecam             : Reset camera.
;firstp / ;thirdp      : Force camera perspective.
;maxzoom [num]         : Set max zoom distance.
;fov [num]             : Set Field of View.
;fixcam                : Fix camera glitches.
;fullbright            : Max brightness.
;nofullbright          : Restore brightness.
;day / ;night          : Set time of day.
;nofog                 : Remove fog.
;globalshadows         : Enable shadows.
;noglobalshadows       : Disable shadows.

[PLAYER]
;age [plr]             : Account age.
;userid [plr]          : Player ID.
;copyname [plr]        : Copy username.
;bang [plr] [speed]    : Rude animation.
;unbang                : Stop animation.
;friend [plr]          : Send friend request.
;unfriend [plr]        : Remove friend.
;headsit [plr]         : Sit on player's head.
;walkto [plr]          : Follow player.
;unwalkto              : Stop following.
;fling                 : Spin fling attack.
;unfling               : Stop fling.
;invisfling            : Invisible fling.
;handlekill [plr]      : Kill player with tool (requires tool equipped).
;hkill [plr]           : Alias for handlekill.
;loopoof               : Spam death sound.
;unloopoof             : Stop sound spam.
;reset / ;respawn      : Respawn character.
;god                   : God mode (Client).
;invisible / ;visible  : Toggle character visibility.
;speed [num]           : Set WalkSpeed.
;jumppower [num]       : Set JumpPower.
;sit / ;jump           : Force sit/jump.
;infjump               : Infinite jump.
;uninfjump             : Disable infinite jump.
;noclickdetectorlimits : Remove click range limit.
;fireclickdetectors    : Activate all buttons.

[CHAT & LOGS]
;logs                  : Open chat logs.
;chatlogs              : Print logs to console.
;chat [text]           : Force chat message.
;spam [text]           : Spam chat.
;unspam                : Stop spam.
;whisper [plr] [msg]   : Private message.
;pmspam [plr] [msg]    : Spam PMs.
;unpmspam              : Stop PM spam.

[WORKSPACE]
;btools / ;f3x         : Give building tools.
;delete [name]         : Delete part (Client).
;partpath              : Copy part path.
;lockworkspace         : Lock all parts.
;unlockworkspace       : Unlock all parts.
;gotopart [name]       : TP to part.
;bringpart [name]      : Bring part to you.
;removeterrain         : Delete terrain.
;antivoid              : Prevent falling in void.

[ANIMATION]
;animation [id]        : Play animation ID.
;dance / ;undance      : Toggle dance.
;spasm / ;unspasm      : Toggle spasm.
;noanim / ;reanim      : Disable/Enable animations.
;copyanimation [plr]   : Copy player animation.

[TOOLS]
;autoclick [delay]     : Auto mouse clicker.
;unautoclick           : Stop clicker.
;tools                 : Get tools from ReplicatedStorage.
;notools               : Remove tools.
;grabtools             : Pick up all dropped tools.
;equiptools            : Equip all items.
;droptools             : Drop all items.
;reach [num]           : Extend tool reach.
;unreach               : Reset reach.

[SERVER]
;serverinfo            : Show server details.
;jobid                 : Copy JobId.
;rejoin                : Rejoin server.
;serverhop             : Join different server.
;gametp [id]           : Join different game.
;exit                  : Close Roblox.

### SECTION 3: WAYPOINT & TELEPORT SYSTEM ###
[IMPORTANT: SEPARATE COMMANDS FOR PLAYERS VS WAYPOINTS]

1. SAVE LOCATION (Waypoint):
   - If user wants to save/mark/remember a location/position/spot:
     > Output: ;swp [name]
     > Example: "save this spot as base" -> ;swp base
     > Example: "mark this location as farm" -> ;swp farm
     > Example: "remember here as coffee" -> ;swp coffee

2. GO TO WAYPOINT (Saved Location):
   - If user wants to go to a SAVED WAYPOINT/LOCATION:
     > Output: ;waypoint [name] or ;wp [name]
     > Example: "go to my base waypoint" -> ;waypoint base
     > Example: "teleport to coffee spot" -> ;wp coffee
   - Use ;waypoint ONLY for saved locations, NOT for players.

3. GO TO PLAYER:
   - If user wants to go to a PLAYER:
     > Output: ;goto [player]
     > Example: "go to John" -> ;goto john
     > Example: "teleport to that guy" -> ;goto [player]
     > Example: "tp to Bob" -> ;goto bob
   - Use goto ONLY for players.

4. LIST WAYPOINTS:
   - "show waypoints", "list my saved spots" -> ;waypoints

5. DELETE WAYPOINT:
   - "delete waypoint base" -> ;deletewaypoint base or ;dwp base

6. CLEAR ALL WAYPOINTS:
   - "clear all waypoints" -> ;clearwaypoints or ;cwp

### SECTION 4: FEW-SHOT TRAINING ###
User: "Stop flying immediately"
AI: ;unfly

User: "Make me walk slow"
AI: ;speed 16

User: "I want to fling him and leave"
AI: ;fling ;serverhop

User: "Remove the lag"
AI: ;antilag ;noesp ;nochams

User: "Don't let me fall in the void"
AI: ;antivoid

User: "Save this spot as my base"
AI: ;swp base

User: "Go to my base waypoint"
AI: ;waypoint base

User: "Remember this location as coffee"
AI: ;swp coffee

User: "Goto coffee waypoint"
AI: ;waypoint coffee

User: "Take me to the farm spot I saved"
AI: ;waypoint farm

User: "Show my saved waypoints"
AI: ;waypoints

User: "Delete the base waypoint"
AI: ;deletewaypoint base

User: "Go to John"
AI: ;goto john

User: "Teleport me to that player"
AI: ;goto [player]

User: "tp to Bob"
AI: ;goto bob

### SECTION 5: ADVANCED CHAINING & FALLBACKS ###
[CHAIN TEMPLATES]
- Sequential Actions: Join actions with semicolons in execution order.
  > "fly then goto john" -> ;fly ;goto john
  > "turn on esp and speed 50" -> ;esp ;speed 50
- Defensive Recovery: Add safety resets when the user asks to undo risky states.
  > "disable noclip and reset view" -> ;clip ;fixcam
- Timed Escapes: Pair hostile actions with exits.
  > "fling him and server hop" -> ;fling ;serverhop
- Contextual Defaults: If a numeric value is missing, apply safe defaults (speed 16, jumppower 50).

[ERROR HANDLING]
- If target is invalid or missing, respond with a precise error and avoid placeholder execution.
- If the intent is vague, prefer the safest interpretation (use ;fixcam, ;clip, ;reset for stabilizing).
- Never invent player names; request clarification instead.

### SECTION 6: TARGETING RESOLUTION RULES ###
1. PRIORITY ORDER
   - Exact username match > DisplayName match > Fuzzy match.
   - Reject ambiguous matches unless only one candidate exists.
2. TOKEN TRIGGERS
   - Actions requiring targets: kill, fling, goto/tp, spectate/view/watch, bring/attach, bang, freeze, follow/walkto, headsit.
   - Pronouns: me → the local player | random → choose a random non-local player | all/everyone → INVALID.
3. FUZZY SAFEGUARDS
   - Require minimum similarity threshold; announce the chosen match (e.g., "Fuzzy Match: valk → Valkorym").
   - Do not downgrade an exact prefix match in favor of fuzzy.
4. FALLBACK RESPONSES
   - If no valid target is found: return a short error ("Target not found. Name a player.") without executing anything.
5. CHAINED TARGETS
   - If multiple target commands appear, resolve each independently.
   - Preserve user-provided ordering when building command chains.

### SECTION 7: PROMPT ENGINEERING NOTES ###
- Keep the total static prompt above 1024 tokens to benefit from model caching.
- Maintain existing manifesto sections verbatim; append new exemplars instead of replacing prior context.
- Responses should stay under 2 sentences unless the user explicitly requests detailed help.

[END OF STATIC CONTEXT]
]],
}

--// ============================================
--// 2B. SOUND MANAGER (v1.3.0)
--// ============================================
-- Acoustic feedback for AI states
local SoundManager = {}
local _activeSounds = {}
local _soundIds = {
    Success = "rbxassetid://18913929246",
    Error = "rbxassetid://9063125154",
    Processing = "rbxassetid://6073491164"
}

--- Play a sound effect
--- @param soundType string -- "Success" | "Error" | "Processing"
function SoundManager:play(soundType)
    if not CONFIG.EnableSounds then return end
    
    local soundId = _soundIds[soundType]
    if not soundId then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = CONFIG.SoundVolume or 0.5
    sound.Parent = game:GetService("SoundService")
    _activeSounds[soundType] = sound
    sound:Play()
    
    local conn
    conn = sound.Ended:Connect(function()
        if conn then conn:Disconnect() end
        _activeSounds[soundType] = nil
        sound:Destroy()
    end)
end

--- Stop a sound
--- @param soundType string
function SoundManager:stop(soundType)
    local sound = _activeSounds[soundType]
    if sound then
        sound:Stop()
        sound:Destroy()
        _activeSounds[soundType] = nil
    end
end

-- Connect to EventBus for automatic sound feedback
EventBus:on("AI_REQUEST_START", function()
    SoundManager:play("Processing")
end)

EventBus:on("AI_REQUEST_COMPLETE", function()
    SoundManager:stop("Processing")
    SoundManager:play("Success")
end)

EventBus:on("AI_REQUEST_ERROR", function()
    SoundManager:stop("Processing")
    SoundManager:play("Error")
end)


--// ============================================
--// 3. LOCAL PLAYER & ENVIRONMENT (with Auto-Context Injection)
--// ============================================
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local GameName = "Loading..."
local GameCreatorId = nil
local GameGenre = nil
local PlayerTeam = nil

-- HTTP Request Handler (Multi-Executor Support)
local httpRequest = (syn and syn.request) 
    or (http and http.request) 
    or http_request 
    or (fluxus and fluxus.request) 
    or request

if not httpRequest then 
    warn("SIY: Executor incompatible - HTTP requests unavailable.") 
end

-- Async Game Info Fetcher (Auto-Context Injection)
task.spawn(function()
    local success, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, game.PlaceId)
    if success and info then
        GameName = info.Name or "Unknown Game"
        GameCreatorId = info.Creator and info.Creator.Id
        -- Try to determine game genre from description or name
        local desc = (info.Description or ""):lower()
        local name = (info.Name or ""):lower()
        if desc:find("obby") or name:find("obby") then
            GameGenre = "Obby/Platformer"
        elseif desc:find("tycoon") or name:find("tycoon") then
            GameGenre = "Tycoon"
        elseif desc:find("simulator") or name:find("simulator") then
            GameGenre = "Simulator"
        elseif desc:find("roleplay") or name:find("roleplay") or desc:find("rp") then
            GameGenre = "Roleplay"
        elseif desc:find("pvp") or desc:find("battle") or desc:find("fight") then
            GameGenre = "PvP/Combat"
        elseif desc:find("horror") or name:find("horror") then
            GameGenre = "Horror"
        else
            GameGenre = "General"
        end
    else
        GameName = "Unknown Game"
    end
end)

-- Track player team changes for context
task.spawn(function()
    local function updateTeam()
        if LocalPlayer.Team then
            PlayerTeam = LocalPlayer.Team.Name
        else
            PlayerTeam = nil
        end
    end
    
    updateTeam()
    ConnectPersistent(LocalPlayer:GetPropertyChangedSignal("Team"), updateTeam)
end)

-- Auto-context injection helper
local function getGameContext()
    local context = {
        gameName = GameName,
        gameGenre = GameGenre,
        playerName = LocalPlayer.Name,
        playerDisplayName = LocalPlayer.DisplayName,
        playerTeam = PlayerTeam,
        playerCount = #Players:GetPlayers(),
        placeId = game.PlaceId
    }
    return context
end

-- Format context for AI injection
local function formatContextForAI()
    local ctx = getGameContext()
    local parts = {}
    
    table.insert(parts, string.format("Game: %s", ctx.gameName))
    if ctx.gameGenre and ctx.gameGenre ~= "General" then
        table.insert(parts, string.format("Genre: %s", ctx.gameGenre))
    end
    table.insert(parts, string.format("Player: %s", ctx.playerDisplayName))
    if ctx.playerTeam then
        table.insert(parts, string.format("Team: %s", ctx.playerTeam))
    end
    table.insert(parts, string.format("Players Online: %d", ctx.playerCount))
    
    return table.concat(parts, " | ")
end

--// ============================================
--// 4. UTILITY FUNCTIONS
--// ============================================
--- Trims leading and trailing whitespace from string
--- @param str string -- String to trim
--- @return string -- Trimmed string
local function trim(str: string): string
    return str:gsub("^%s+", ""):gsub("%s+$", "")
end

--- Normalizes input text for cache key lookup
--- @param text string -- Text to normalize
--- @return string -- Normalized lowercase text
local function normalizeInput(text: string): string
    return text:lower():gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
end

local DangerousTokens = {
    loadstring = true,
    require = true,
    getfenv = true,
    setfenv = true,
    rawget = true,
    rawset = true,
    debug = true
}

--- Sanitizes user input for security
--- @param text string? -- Text to sanitize
--- @return string -- Sanitized text
local function sanitizeInput(text: string?): string
    if not text or type(text) ~= "string" then return "" end
    
    -- Remove control characters (except newline and tab)
    text = text:gsub("[%c]", function(c)
        if c == "\n" or c == "\t" then return " " end
        return ""
    end)
    
    -- Limit input length to prevent abuse
    if #text > CONFIG.MaxInputLength then
        text = text:sub(1, CONFIG.MaxInputLength)
    end
    
    -- Remove potentially dangerous Lua patterns (security) using whole-word, case-insensitive checks
    text = text:gsub("(%f[%w]%w+[%.:]?)", function(token)
        local trimmedToken = token
        local lastChar = trimmedToken:sub(-1)
        if lastChar == "." or lastChar == ":" then
            trimmedToken = trimmedToken:sub(1, -2)
        end

        local lowered = trimmedToken:lower()
        if DangerousTokens[lowered] then
            return ""
        end

        return token
    end)
    
    -- Normalize whitespace
    text = text:gsub("%s+", " ")
    text = trim(text)
    
    return text
end

--// ============================================
--// 5. COMMAND CACHE SYSTEM
--// ============================================

--[=[
    @type CacheEntry
    Structure for cached command entries with timestamp for LRU eviction
]=]
type CacheEntry = {
    command: string,
    timestamp: number
}

type CommandCacheType = {[string]: CacheEntry}

local CommandCache: CommandCacheType = {}

--- Loads cache from file system
--- @return nil
local function loadCache(): nil
    if not CONFIG.CacheEnabled then return end
    
    local success, content = pcall(function()
        return readfile and readfile(CONFIG.CacheFile) or nil
    end)
    
    if success and content then
        local parseSuccess, parsed = pcall(HttpService.JSONDecode, HttpService, content)
        if parseSuccess and parsed then
            CommandCache = parsed :: CommandCacheType
        end
    end
    return nil
end

--- Saves cache to file system
--- @return nil
local function saveCache(): nil
    if not CONFIG.CacheEnabled then return end
    
    pcall(function()
        if writefile then
            writefile(CONFIG.CacheFile, HttpService:JSONEncode(CommandCache))
        end
    end)
    return nil
end

--- Gets a cached command by input key
--- @param input string -- The user input to look up
--- @return CacheEntry? -- The cached entry or nil
local function getCachedCommand(input: string): CacheEntry?
    local key = normalizeInput(input)
    return CommandCache[key]
end

--- Caches a command translation for future lookups
--- @param input string -- The original user input
--- @param output string -- The translated command
--- @return nil
local function cacheCommand(input: string, output: string): nil
    if not CONFIG.CacheEnabled then return end
    if not output or output == "" or output:lower():find("sure") then return end
    
    local key = normalizeInput(input)
    
    -- Enforce max cache entries (LRU-style cleanup)
    local count = 0
    for _ in pairs(CommandCache) do count = count + 1 end
    
    if count >= CONFIG.MaxCacheEntries then
        local oldestKey: string? = nil
        local oldestTime: number = math.huge
        for k, v in pairs(CommandCache) do
            if v.timestamp and v.timestamp < oldestTime then
                oldestTime = v.timestamp
                oldestKey = k
            end
        end
        if oldestKey then CommandCache[oldestKey] = nil end
    end
    
    CommandCache[key] = {
        command = output,
        timestamp = os.time()
    }
    saveCache()
    return nil
end

--- Clears all cached commands
--- @return boolean -- Always returns true
local function clearCache(): boolean
    CommandCache = {}
    saveCache()
    return true
end

--- Gets cache statistics
--- @return (number, number) -- Current count and max entries
local function getCacheInfo(): (number, number)
    local count = 0
    for _ in pairs(CommandCache) do count = count + 1 end
    return count, CONFIG.MaxCacheEntries
end

-- Initialize cache
loadCache()

--// ============================================
--// 6. BRIDGE SYSTEM (Event-Based with Configurable Retries)
--// ============================================

--[=[
    @type BridgeStatus
    Status information for the IY bridge connection
]=]
type BridgeStatus = {
    connected: boolean,
    attempts: number,
    interface: boolean
}

local IY_Interface = nil
local BridgeReady = Instance.new("BindableEvent")
local BridgeConnected: boolean = false
local BridgeConnectionAttempts: number = 0

--- Waits for bridge connection with configurable retries
--- @param timeout number? -- Maximum wait time in seconds
--- @param retryCount number? -- Number of retry attempts
--- @return boolean -- True if bridge connected
local function waitForBridge(timeout: number?, retryCount: number?): boolean
    if BridgeConnected then return true end
    
    local maxRetries = retryCount or CONFIG.BridgeMaxRetries
    local maxWait = timeout or CONFIG.BridgeTimeout
    local retryDelay = CONFIG.BridgeRetryDelay
    
    for attempt = 1, maxRetries do
        BridgeConnectionAttempts = attempt
        
        local connection
        local result = false
        
        connection = BridgeReady.Event:Connect(function()
            result = true
        end)
        
        local waited = 0
        local attemptTimeout = maxWait / maxRetries
        while not result and waited < attemptTimeout do
            task.wait(0.1)
            waited = waited + 0.1
        end
        
        connection:Disconnect()
        removeConnection(connection)
        
        if BridgeConnected then
            return true
        end
        
        -- Try to reconnect on failure
        if attempt < maxRetries then
            warn(string.format("[SIY] Bridge connection attempt %d/%d failed, retrying...", attempt, maxRetries))
            task.wait(retryDelay)
            
            -- Attempt to re-initialize bridge
            local bridge = getNamespaceValue("PseudoBridge") or (getgenv and getgenv().PseudoBridge)
            if bridge then
                IY_Interface = bridge
                BridgeConnected = true
                BridgeReady:Fire()
                return true
            end
        end
    end
    
    return BridgeConnected
end

--- Gets bridge connection status for debugging
--- @return BridgeStatus -- Current bridge status
local function getBridgeStatus(): BridgeStatus
    return {
        connected = BridgeConnected,
        attempts = BridgeConnectionAttempts,
        interface = IY_Interface ~= nil
    }
end

-- Initialize Bridge with retry logic
task.spawn(function()
    -- Check for existing bridge in namespace or legacy location
    local existingBridge = getNamespaceValue("PseudoBridge") or (getgenv and getgenv().PseudoBridge)
    if existingBridge then
        IY_Interface = existingBridge
        BridgeConnected = true
        BridgeReady:Fire()
        return
    end

    local function attemptBridgeConnection()
        if not CoreGui:FindFirstChild("InfiniteYield") then
            local success, source = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
            if success then
                -- Enhanced bridge code exposes cmds table, execCmd, and notify with output capture
                local bridgeCode = string.format([[
                    local ns = getgenv()["%s"] or {}
                    getgenv()["%s"] = ns
                    
                    -- Capture last notification for feedback loop
                    ns.LastNotification = nil
                    local originalNotify = notify
                    if originalNotify then
                        notify = function(title, text, duration)
                            ns.LastNotification = {
                                title = title,
                                text = text,
                                timestamp = os.time()
                            }
                            return originalNotify(title, text, duration)
                        end
                    end
                    
                    ns.PseudoBridge = {
                        Exec = function(cmd) 
                            if execCmd then 
                                ns.LastNotification = nil -- Clear before execution
                                execCmd(cmd) 
                                return true
                            end 
                            return false
                        end,
                        GetCommands = function()
                            -- Return reference to cmds table for dynamic command extraction
                            return cmds or {}
                        end,
                        GetNotify = function()
                            return ns.LastNotification
                        end,
                        ClearNotify = function()
                            ns.LastNotification = nil
                        end,
                        Ready = true,
                        Version = "2.0"
                    }
                ]], NAMESPACE, NAMESPACE)
                local loadSuccess, loadErr = pcall(function()
                    loadstring(source .. "\n" .. bridgeCode)()
                end)
                if not loadSuccess then
                    warn("[SIY] Failed to load IY source: " .. tostring(loadErr))
                    return false
                end
            else
                warn("[SIY] Failed to fetch IY source")
                return false
            end
        end
        return true
    end
    
    -- Initial connection attempt
    attemptBridgeConnection()

    local timeout, interval = 0, 0.1
    local maxTimeout = CONFIG.BridgeTimeout
    while not getNamespaceValue("PseudoBridge") and timeout < maxTimeout do
        task.wait(interval)
        timeout = timeout + interval
        
        -- Retry connection at intervals
        if timeout % 3 < interval and timeout > 0 then
            attemptBridgeConnection()
        end
    end

    local bridge = getNamespaceValue("PseudoBridge")
    if bridge then
        IY_Interface = bridge
        BridgeConnected = true
        BridgeReady:Fire()
    else
        warn("[SIY] Bridge connection timeout after " .. tostring(maxTimeout) .. " seconds")
        -- Notify user of bridge failure (prevents confusion)
        EventBus:emit("SHOW_NOTIFICATION", {
            title = "Connection Failed",
            message = "Unable to connect to Infinite Yield. Some features may not work. Try reloading the script.",
            duration = 8
        })
    end
end)

--// ============================================
--// 6.5 DYNAMIC COMMAND MAP BUILDER
--// ============================================
local DynamicCommandMap = {}  -- Will be populated from IY's cmds table
local DynamicCommandList = {} -- Ordered list for suggestions
local DynamicMapBuilt = false

--- Builds a command map by extracting commands from IY's internal cmds table
--- @return boolean -- True if successfully built
local function buildDynamicCommandMap()
    if not IY_Interface or not IY_Interface.GetCommands then
        return false
    end
    
    local success, cmds = pcall(IY_Interface.GetCommands)
    if not success or not cmds or type(cmds) ~= "table" then
        warn("[SIY] Failed to get commands from IY bridge")
        return false
    end
    
    -- Clear existing maps
    DynamicCommandMap = {}
    DynamicCommandList = {}
    
    local count = 0
    for _, cmd in pairs(cmds) do
        if cmd and type(cmd) == "table" and cmd.NAME then
            local cmdName = cmd.NAME:lower()
            -- Add main command name
            DynamicCommandMap[cmdName] = {
                name = cmd.NAME,
                aliases = cmd.ALIAS or {},
                args = cmd.ARGS or {},
                desc = cmd.DESC or ""
            }
            table.insert(DynamicCommandList, {
                name = cmd.NAME,
                pattern = "^" .. cmdName .. "$",
                command = cmdName
            })
            
            -- Add all aliases
            if cmd.ALIAS and type(cmd.ALIAS) == "table" then
                for _, alias in ipairs(cmd.ALIAS) do
                    local aliasLower = alias:lower()
                    DynamicCommandMap[aliasLower] = DynamicCommandMap[cmdName]
                    table.insert(DynamicCommandList, {
                        name = alias,
                        pattern = "^" .. aliasLower .. "$",
                        command = cmdName
                    })
                end
            end
            count = count + 1
        end
    end
    
    DynamicMapBuilt = count > 0
    if DynamicMapBuilt then
        print("[SIY] Loaded " .. count .. " commands from IY dynamically")
    end
    return DynamicMapBuilt
end

--- Gets command info from the dynamic map
--- @param cmdName string -- Command name or alias
--- @return table? -- Command info or nil
local function getDynamicCommand(cmdName)
    if not DynamicMapBuilt then
        buildDynamicCommandMap()
    end
    return DynamicCommandMap[cmdName:lower()]
end


-- Build dynamic map after bridge connects
task.spawn(function()
    waitForBridge(CONFIG.BridgeTimeout)
    if BridgeConnected then
        task.wait(0.5) -- Small delay to ensure cmds is populated
        buildDynamicCommandMap()
    end
end)

--// ============================================
--// 7. UI CONFIGURATION
--// ============================================
local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- Mode state (forward declaration for UI elements that reference it)
local IS_CHAT_MODE = false

-- Detect high-density displays for mobile scaling
local ScreenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
local IsHighDensity = IsMobile and (ScreenSize.X > 1200 or ScreenSize.Y > 2400)
local MobileScaleFactor = IsHighDensity and 1.2 or CONFIG.MobileQuickActionScale

--[=[
    @type ColorPalette
    Centralized color scheme with full LuaU type annotations
]=]
type ColorPalette = {
    -- Base colors
    Background: Color3,
    InputBg: Color3,
    DropdownBg: Color3,
    Border: Color3,
    -- Accent colors
    Orange: Color3,
    Blue: Color3,
    Green: Color3,
    Red: Color3,
    Purple: Color3,
    -- Text colors
    Text: Color3,
    TextDim: Color3,
    Status: Color3,
    -- Chat mode colors
    ChatUserBubble: Color3,
    ChatAIBubble: Color3,
    ChatUserText: Color3,
    ChatAIText: Color3,
    ChatBorder: Color3,
    ChatTimestamp: Color3,
}

local Colors: ColorPalette = {
    Background = Color3.fromRGB(20, 20, 20),
    InputBg    = Color3.fromRGB(30, 30, 30),
    DropdownBg = Color3.fromRGB(25, 25, 25),
    Border     = Color3.fromRGB(60, 60, 60),
    Orange     = Color3.fromRGB(255, 145, 40),
    Blue       = Color3.fromRGB(50, 180, 255),
    Green      = Color3.fromRGB(40, 230, 130),
    Red        = Color3.fromRGB(255, 80, 80),
    Purple     = Color3.fromRGB(180, 100, 255),
    Text       = Color3.fromRGB(240, 240, 240),
    TextDim    = Color3.fromRGB(150, 150, 150),
    Status     = Color3.fromRGB(200, 200, 200),
    
    -- ChatGPT-like colors for CHAT mode
    ChatUserBubble = Color3.fromRGB(52, 53, 65),
    ChatAIBubble = Color3.fromRGB(68, 70, 84),
    ChatUserText = Color3.fromRGB(236, 236, 241),
    ChatAIText = Color3.fromRGB(209, 213, 219),
    ChatBorder = Color3.fromRGB(86, 88, 105),
    ChatTimestamp = Color3.fromRGB(142, 142, 160)
}

-- Optimized frame sizes: reduced base height, consistent chat expansion
local BaseMainSize = IsMobile and UDim2.new(0.9, 0, 0, 65) or UDim2.new(0, 420, 0, 65)
local ChatMainSize = IsMobile and UDim2.new(0.9, 0, 0, 280) or UDim2.new(0, 420, 0, 300)

-- UI Helper Functions

--- Adds rounded corners to a GUI object
--- @param obj GuiObject -- The GUI object to modify
--- @param radius number -- Corner radius in pixels
--- @return UICorner
local function addCorner(obj: GuiObject, radius: number): UICorner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = obj
    return corner
end

--- Adds a stroke border to a GUI object
--- @param obj GuiObject -- The GUI object to modify
--- @param color Color3 -- Stroke color
--- @param thickness number -- Stroke thickness in pixels
--- @return UIStroke
local function addStroke(obj: GuiObject, color: Color3, thickness: number): UIStroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Parent = obj
    return stroke
end

--- Creates a new Instance with properties, with error handling
--- @param className string -- The class name to create
--- @param properties table<string, any> -- Properties to assign
--- @return Instance
local function createInstance(className: string, properties: {[string]: any}): Instance
    local success, instance = pcall(Instance.new, className)
    if not success or not instance then
        warn("[SIY] Failed to create instance:", className)
        return Instance.new("Frame") -- Fallback to Frame
    end
    
    for prop, value in pairs(properties) do
        local propSuccess, propErr = pcall(function()
            instance[prop] = value
        end)
        if not propSuccess then
            warn(string.format("[SIY] Failed to set property '%s' on %s: %s", prop, className, tostring(propErr)))
        end
    end
    return instance
end

--- Creates a styled button with common defaults
--- @param text string -- Button text
--- @param props table<string, any>? -- Additional properties
--- @return TextButton
local function createButton(text: string, props: {[string]: any}?): TextButton
    local defaults: {[string]: any} = {
        BackgroundColor3 = Colors.InputBg,
        Text = text,
        TextColor3 = Colors.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false
    }
    if props then
        for k, v in pairs(props) do defaults[k] = v end
    end
    local btn = createInstance("TextButton", defaults) :: TextButton
    addCorner(btn, 4)
    return btn
end

--- Creates a styled text label with common defaults
--- @param text string -- Label text
--- @param props table<string, any>? -- Additional properties
--- @return TextLabel
local function createLabel(text: string, props: {[string]: any}?): TextLabel
    local defaults: {[string]: any} = {
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Colors.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    }
    if props then
        for k, v in pairs(props) do defaults[k] = v end
    end
    return createInstance("TextLabel", defaults) :: TextLabel
end

--- Creates a styled frame with optional corner and stroke
--- @param props table<string, any> -- Frame properties
--- @param cornerRadius number? -- Optional corner radius
--- @param strokeColor Color3? -- Optional stroke color
--- @return Frame
local function createFrame(props: {[string]: any}, cornerRadius: number?, strokeColor: Color3?): Frame
    local frame = createInstance("Frame", props) :: Frame
    if cornerRadius and cornerRadius > 0 then
        addCorner(frame, cornerRadius)
    end
    if strokeColor then
        addStroke(frame, strokeColor, 1)
    end
    return frame
end

--// ============================================
--// 8. DRAG SYSTEM
--// ============================================
local DragRegistrations = setmetatable({}, {__mode = "k"})

local function disconnectDragConnections(frame)
    local tracked = DragRegistrations[frame]
    if not tracked or not tracked.connections then return end

    for _, connection in pairs(tracked.connections) do
        if connection then
            pcall(function()
                connection:Disconnect()
            end)
            removeConnection(connection)
        end
    end
    DragRegistrations[frame] = nil
end

local function enableDrag(frame)
    if not frame then return end

    local tracked = DragRegistrations[frame]
    if tracked and tracked.connections then
        local allConnected = true
        for _, connection in pairs(tracked.connections) do
            if not (connection and connection.Connected) then
                allConnected = false
                break
            end
        end
        if allConnected then
            return
        end
        disconnectDragConnections(frame)
    end

    local dragToggle, dragStart, startPos, dragInput
    local connections = {}
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        TweenService:Create(frame, TweenInfo.new(0.08), {Position = position}):Play()
    end
    
    connections.frameInputBeganConnection = ConnectPersistent(frame.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            
            local inputChangedConn = nil
            inputChangedConn = registerConnection(input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                    if inputChangedConn then
                        inputChangedConn:Disconnect()
                        removeConnection(inputChangedConn)
                    end
                end
            end))
        end
    end)
    
    connections.frameInputChangedConnection = ConnectPersistent(frame.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    connections.inputChangedConnection = ConnectPersistent(UserInputService.InputChanged, function(input)
        if input == dragInput and dragToggle then
            updateInput(input)
        end
    end)

    DragRegistrations[frame] = {
        connections = connections
    }
    
    -- v1.3.3: Auto-cleanup when frame is destroyed to prevent memory leaks
    local destroyCleanup
    destroyCleanup = frame.Destroying:Connect(function()
        disconnectDragConnections(frame)
        if destroyCleanup then
            destroyCleanup:Disconnect()
        end
    end)
    registerConnection(destroyCleanup)
end

--// ============================================
--// 9. GUI CONSTRUCTION
--// ============================================
-- Cleanup existing GUI
local existingGui = CoreGui:FindFirstChild("SmartInfiniteYieldGUI")
if existingGui then existingGui:Destroy() end

-- Screen GUI
local SIY_Screen = createInstance("ScreenGui", {
    Name = "SmartInfiniteYieldGUI",
    Parent = CoreGui,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false
})

-- Floating Open Button
local OpenButton = createInstance("ImageButton", {
    Name = "OpenButton",
    Size = UDim2.new(0, 45, 0, 45),
    Position = UDim2.new(0, 15, 0.4, 0),
    BackgroundColor3 = Colors.Background,
    Image = "rbxassetid://6035193498",
    ImageColor3 = Colors.Green,
    Visible = false,
    Parent = SIY_Screen
})
addCorner(OpenButton, 100)
local OpenButtonStroke = addStroke(OpenButton, Colors.Green, 2)
enableDrag(OpenButton)

-- Pulse animation for open button
local openButtonPulse = nil
local function startOpenButtonPulse()
    if openButtonPulse then return end
    openButtonPulse = registerTask(task.spawn(function()
        while OpenButton.Visible do
            TweenService:Create(OpenButtonStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.7
            }):Play()
            task.wait(0.8)
            TweenService:Create(OpenButtonStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0
            }):Play()
            task.wait(0.8)
        end
    end))
end

ConnectPersistent(OpenButton:GetPropertyChangedSignal("Visible"), function()
    if OpenButton.Visible then
        startOpenButtonPulse()
    else
        if openButtonPulse then
            cancelTask(openButtonPulse)
            openButtonPulse = nil
        end
    end
end)

-- Main Container
local MainFrame = createInstance("Frame", {
    Name = "MainFrame",
    AnchorPoint = Vector2.new(0.5, 0),
    Size = BaseMainSize,
    Position = UDim2.new(0.5, 0, 0.15, 0),
    BackgroundColor3 = Colors.Background,
    BorderSizePixel = 0,
    Parent = SIY_Screen
})
addCorner(MainFrame, 10)
enableDrag(MainFrame)
local MainStroke = addStroke(MainFrame, Colors.Orange, 1)

--// Processing Glow Effect
local ProcessingGlow = createInstance("Frame", {
    Name = "ProcessingGlow",
    Size = UDim2.new(1, 10, 1, 10),
    Position = UDim2.new(0, -5, 0, -5),
    BackgroundTransparency = 1,
    ZIndex = 0,
    Parent = MainFrame
})

local GlowGradient = createInstance("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Orange),
        ColorSequenceKeypoint.new(0.5, Colors.Purple),
        ColorSequenceKeypoint.new(1, Colors.Blue)
    }),
    Rotation = 0,
    Parent = ProcessingGlow
})

addCorner(ProcessingGlow, 12)

local GlowStroke = createInstance("UIStroke", {
    Color = Colors.Orange,
    Thickness = 3,
    Transparency = 1,
    Parent = ProcessingGlow
})

-- Glow Animation
local glowConnection = nil

local function startGlowAnimation()
    if glowConnection and glowConnection.Connected then return end
    if glowConnection and not glowConnection.Connected then
        removeConnection(glowConnection)
        glowConnection = nil
    end
    GlowStroke.Transparency = 0
    local rotation = 0
    glowConnection = ConnectPersistent(RunService.Heartbeat, function(dt)
        rotation = (rotation + dt * 100) % 360
        GlowGradient.Rotation = rotation
        GlowStroke.Transparency = math.sin(tick() * 3) * 0.3 + 0.5
    end)
end

local function stopGlowAnimation()
    if glowConnection then
        pcall(function()
            glowConnection:Disconnect()
        end)
        removeConnection(glowConnection)
        glowConnection = nil
    end
    GlowStroke.Transparency = 1
end

--// Control Buttons - Compact Mode Dropdown
local ModeDropdownWidth = IsMobile and 50 or 55
local ModeFontSize = IsMobile and 10 or 11

-- Mode dropdown container
local ModeDropdownContainer = createInstance("Frame", {
    Name = "ModeDropdownContainer",
    Size = UDim2.new(0, ModeDropdownWidth, 0, 26),
    Position = UDim2.new(0, 8, 0, 10),
    BackgroundTransparency = 1,
    ClipsDescendants = false,
    ZIndex = 10,
    Parent = MainFrame
})

-- Current mode indicator button (compact)
local ModeBtn = createInstance("TextButton", {
    Name = "ModeIndicator",
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Colors.Orange,
    Text = "CMD ▾",
    TextColor3 = Color3.new(0, 0, 0),
    Font = Enum.Font.GothamBold,
    TextSize = ModeFontSize,
    ZIndex = 11,
    Parent = ModeDropdownContainer
})
addCorner(ModeBtn, 4)

-- Mode dropdown options frame (hidden by default)
local ModeDropdownFrame = createInstance("Frame", {
    Name = "ModeDropdownOptions",
    Size = UDim2.new(1, 0, 0, 52),
    Position = UDim2.new(0, 0, 1, 2),
    BackgroundColor3 = Colors.DropdownBg,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 12,
    Parent = ModeDropdownContainer
})
addCorner(ModeDropdownFrame, 4)
addStroke(ModeDropdownFrame, Colors.Border, 1)

-- CMD option in dropdown
local CmdOption = createInstance("TextButton", {
    Name = "CmdOption",
    Size = UDim2.new(1, 0, 0, 24),
    Position = UDim2.new(0, 0, 0, 2),
    BackgroundColor3 = Colors.DropdownBg,
    BackgroundTransparency = 0,
    Text = "CMD",
    TextColor3 = Colors.Orange,
    Font = Enum.Font.GothamBold,
    TextSize = ModeFontSize,
    ZIndex = 13,
    Parent = ModeDropdownFrame
})

-- CHAT option in dropdown
local ChatOption = createInstance("TextButton", {
    Name = "ChatOption",
    Size = UDim2.new(1, 0, 0, 24),
    Position = UDim2.new(0, 0, 0, 26),
    BackgroundColor3 = Colors.DropdownBg,
    BackgroundTransparency = 0,
    Text = "CHAT",
    TextColor3 = Colors.Blue,
    Font = Enum.Font.GothamBold,
    TextSize = ModeFontSize,
    ZIndex = 13,
    Parent = ModeDropdownFrame
})

-- Dropdown state
local modeDropdownOpen = false

-- Hover effects for dropdown options
ConnectPersistent(CmdOption.MouseEnter, function()
    TweenService:Create(CmdOption, TweenInfo.new(0.1), {
        BackgroundColor3 = Colors.InputBg,
        TextColor3 = Colors.Text
    }):Play()
end)
ConnectPersistent(CmdOption.MouseLeave, function()
    TweenService:Create(CmdOption, TweenInfo.new(0.1), {
        BackgroundColor3 = Colors.DropdownBg,
        TextColor3 = Colors.Orange
    }):Play()
end)

ConnectPersistent(ChatOption.MouseEnter, function()
    TweenService:Create(ChatOption, TweenInfo.new(0.1), {
        BackgroundColor3 = Colors.InputBg,
        TextColor3 = Colors.Text
    }):Play()
end)
ConnectPersistent(ChatOption.MouseLeave, function()
    TweenService:Create(ChatOption, TweenInfo.new(0.1), {
        BackgroundColor3 = Colors.DropdownBg,
        TextColor3 = Colors.Blue
    }):Play()
end)

-- Function to close dropdown
local function closeModeDropdown()
    if modeDropdownOpen then
        modeDropdownOpen = false
        TweenService:Create(ModeDropdownFrame, TweenInfo.new(0.15), {
            Size = UDim2.new(1, 0, 0, 0)
        }):Play()
        task.delay(0.15, function()
            if not modeDropdownOpen then
                ModeDropdownFrame.Visible = false
            end
        end)
    end
end

-- Function to toggle dropdown
local function toggleModeDropdown()
    modeDropdownOpen = not modeDropdownOpen
    if modeDropdownOpen then
        ModeDropdownFrame.Visible = true
        ModeDropdownFrame.Size = UDim2.new(1, 0, 0, 0)
        TweenService:Create(ModeDropdownFrame, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 52)
        }):Play()
    else
        closeModeDropdown()
    end
end

-- Legacy variable for backward compatibility with BtnWidth references
local BtnWidth = ModeDropdownWidth
local FontSize = ModeFontSize

local HelpBtn = createInstance("TextButton", {
    Size = UDim2.new(0, 26, 0, 26),
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -38, 0, 10),
    BackgroundColor3 = Colors.InputBg,
    Text = "?",
    TextColor3 = Colors.Blue,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    Parent = MainFrame
})
addCorner(HelpBtn, 4)

-- Help button hover effect
ConnectPersistent(HelpBtn.MouseEnter, function()
    TweenService:Create(HelpBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Colors.Blue,
        TextColor3 = Color3.new(1, 1, 1)
    }):Play()
end)
ConnectPersistent(HelpBtn.MouseLeave, function()
    TweenService:Create(HelpBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Colors.InputBg,
        TextColor3 = Colors.Blue
    }):Play()
end)

local MinBtn = createInstance("TextButton", {
    Size = UDim2.new(0, 26, 0, 26),
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -8, 0, 10),
    BackgroundColor3 = Colors.InputBg,
    Text = "-",
    TextColor3 = Colors.TextDim,
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    Parent = MainFrame
})
addCorner(MinBtn, 4)

-- Minimize button hover effect
ConnectPersistent(MinBtn.MouseEnter, function()
    TweenService:Create(MinBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Colors.Orange,
        TextColor3 = Color3.new(0, 0, 0)
    }):Play()
end)
ConnectPersistent(MinBtn.MouseLeave, function()
    TweenService:Create(MinBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Colors.InputBg,
        TextColor3 = Colors.TextDim
    }):Play()
end)

--// Input Area (optimized spacing for compact layout)
local QuickActionWidth = IsMobile and 44 or 28
local LeftPad = 8 + BtnWidth + 6 + (IsMobile and (QuickActionWidth + 6) or 0) -- Add space for QuickAction button on mobile
local RightPad = 8 + 26 + 4 + 26 + 8  -- Help + Minimize buttons

local InputContainer = createInstance("Frame", {
    Size = UDim2.new(1, -(LeftPad + RightPad), 0, 26),
    Position = UDim2.new(0, LeftPad, 0, 10),
    BackgroundColor3 = Colors.InputBg,
    ZIndex = 2,
    Parent = MainFrame
})
addCorner(InputContainer, 4)

local InputBox = createInstance("TextBox", {
    Size = UDim2.new(1, -10, 1, 0),
    Position = UDim2.new(0, 5, 0, 0),
    BackgroundTransparency = 1,
    Text = "",
    PlaceholderText = IsMobile and "What do you want to do?" or "Tell me what to do...",
    TextColor3 = Colors.Text,
    PlaceholderColor3 = Colors.TextDim,
    Font = Enum.Font.GothamMedium,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    ClearTextOnFocus = false,
    Parent = InputContainer
})

--// Suggestion Dropdown
local SuggestionFrame = createInstance("Frame", {
    Name = "Dropdown",
    Size = UDim2.new(1, 0, 0, 0),
    Position = UDim2.new(0, 0, 1, 5),
    BackgroundColor3 = Colors.DropdownBg,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 5,
    Parent = InputContainer
})
addCorner(SuggestionFrame, 6)
addStroke(SuggestionFrame, Colors.Border, 1)

createInstance("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = SuggestionFrame
})

--// Preview Bar (tooltip-style, appears below input)
local PreviewBar = createInstance("Frame", {
    Name = "PreviewBar",
    Size = UDim2.new(1, -16, 0, 18),
    Position = UDim2.new(0, 8, 0, 40),
    BackgroundColor3 = Colors.InputBg,
    BackgroundTransparency = 0.3,
    Visible = false,
    ZIndex = 8,
    Parent = MainFrame
})
addCorner(PreviewBar, 3)

local PreviewLabel = createInstance("TextLabel", {
    Name = "PreviewText",
    Size = UDim2.new(1, -8, 1, 0),
    Position = UDim2.new(0, 4, 0, 0),
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = Colors.Green,
    Font = Enum.Font.Code,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    Parent = PreviewBar
})

local function showPreview(command)
    PreviewLabel.Text = "→ " .. command
    PreviewBar.Visible = true
    task.delay(3, function()
        if PreviewLabel.Text == "→ " .. command then
            PreviewBar.Visible = false
        end
    end)
end

local function hidePreview()
    PreviewBar.Visible = false
end

--// Status Bar (hidden in compact mode, shown during processing)
local StatusLabel = createInstance("TextLabel", {
    Name = "Status",
    Size = UDim2.new(1, -20, 0, 14),
    Position = UDim2.new(0, 10, 0, 42),
    BackgroundTransparency = 1,
    Text = ">> Ready",
    TextColor3 = Colors.TextDim,
    Font = Enum.Font.Code,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTransparency = 0.4,
    TextTruncate = Enum.TextTruncate.AtEnd,
    Visible = false, -- Hidden by default in compact CMD mode
    Parent = MainFrame
})

-- Chat mode container (only visible in CHAT mode)
local ChatModeContainer = createInstance("Frame", {
    Name = "ChatModeContainer",
    Size = UDim2.new(1, 0, 1, -46),
    Position = UDim2.new(0, 0, 0, 46),
    BackgroundTransparency = 1,
    Visible = false, -- Hidden by default, shown only in CHAT mode
    Parent = MainFrame
})

local ChatLogHeader = createInstance("TextLabel", {
    Name = "ChatLogHeader",
    Size = UDim2.new(1, -20, 0, 18),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "💬 Conversation",
    TextColor3 = Colors.Blue,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTransparency = 0,
    Parent = ChatModeContainer
})

-- Memory indicator showing conversation context
local MemoryIndicator = createInstance("TextLabel", {
    Name = "MemoryIndicator",
    Size = UDim2.new(0, 100, 0, 18),
    Position = UDim2.new(1, -110, 0, 0),
    BackgroundTransparency = 1,
    Text = "Memory: 0/6",
    TextColor3 = Colors.ChatTimestamp,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Right,
    Parent = ChatModeContainer
})

local ChatLogFrame = createInstance("ScrollingFrame", {
    Name = "ChatLogFrame",
    Size = UDim2.new(1, -20, 1, IsMobile and -30 or -35),
    Position = UDim2.new(0, 10, 0, 22),
    BackgroundColor3 = Colors.ChatAIBubble,
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 6,
    ScrollBarImageColor3 = Colors.ChatBorder,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ZIndex = 2,
    Parent = ChatModeContainer
})
addCorner(ChatLogFrame, 10)
addStroke(ChatLogFrame, Colors.ChatBorder, 1)

createInstance("UIPadding", {
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10),
    PaddingTop = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 8),
    Parent = ChatLogFrame
})

local ChatLogLayout = createInstance("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 10),
    Parent = ChatLogFrame
})

-- Placeholder for empty chat
local ChatPlaceholder = createInstance("TextLabel", {
    Name = "ChatPlaceholder",
    Size = UDim2.new(1, 0, 0, 60),
    BackgroundTransparency = 1,
    Text = "Start a conversation...\nAsk questions about the game or get help with commands.",
    TextColor3 = Colors.ChatTimestamp,
    Font = Enum.Font.Gotham,
    TextSize = 13,
    TextWrapped = true,
    TextYAlignment = Enum.TextYAlignment.Center,
    Parent = ChatLogFrame
})

--// ============================================
--// 10. MOBILE QUICK ACTIONS (with Dynamic Scaling)
--// ============================================
-- Calculate scaled cell size for high-density displays
local baseCellHeight = 35
local scaledCellHeight = math.max(CONFIG.MobileMinCellSize, math.floor(baseCellHeight * MobileScaleFactor))
local scaledFontSize = math.floor(11 * MobileScaleFactor)

local QuickActionsFrame = createInstance("Frame", {
    Name = "QuickActions",
    Size = UDim2.new(1, -16, 0, 0),
    Position = UDim2.new(0, 8, 1, 5),
    BackgroundColor3 = Colors.Background,
    BackgroundTransparency = 0.1,
    Visible = false,
    ClipsDescendants = true,
    Parent = MainFrame
})
addCorner(QuickActionsFrame, 8)
addStroke(QuickActionsFrame, Colors.Border, 1)

local QuickActionsGrid = createInstance("UIGridLayout", {
    CellSize = UDim2.new(0.33, -4, 0, scaledCellHeight),
    CellPadding = UDim2.new(0, 4, 0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = QuickActionsFrame
})

createInstance("UIPadding", {
    PaddingTop = UDim.new(0, 6),
    PaddingBottom = UDim.new(0, 6),
    PaddingLeft = UDim.new(0, 6),
    PaddingRight = UDim.new(0, 6),
    Parent = QuickActionsFrame
})

-- Quick Actions with toggle state tracking
local QuickActionStates = {}
local QuickActions = {
    {text = "Fly", onCmd = "fly", offCmd = "unfly", color = Colors.Blue, toggleable = true},
    {text = "Speed", onCmd = "speed 100", offCmd = "speed 16", color = Colors.Green, toggleable = true},
    {text = "ESP", onCmd = "esp", offCmd = "noesp", color = Colors.Purple, toggleable = true},
    {text = "Noclip", onCmd = "noclip", offCmd = "clip", color = Colors.Orange, toggleable = true},
    {text = "Jump", onCmd = "infjump", offCmd = "uninfjump", color = Colors.Green, toggleable = true},
    {text = "Teleport", onCmd = "goto random", offCmd = nil, color = Colors.Blue, toggleable = false},
    {text = "Invisible", onCmd = "invisible", offCmd = "visible", color = Colors.Purple, toggleable = true},
    {text = "Reset", onCmd = "reset", offCmd = nil, color = Colors.TextDim, toggleable = false},
    {text = "Anti-Lag", onCmd = "antilag", offCmd = nil, color = Colors.Orange, toggleable = false},
}

for i, action in ipairs(QuickActions) do
    local btn = createInstance("TextButton", {
        Name = "QuickAction_" .. action.text,
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = action.color,
        BackgroundTransparency = 0.7,
        Text = action.text,
        TextColor3 = Colors.Text,
        Font = Enum.Font.GothamBold,
        TextSize = scaledFontSize,
        LayoutOrder = i,
        Parent = QuickActionsFrame
    })
    addCorner(btn, 4)
    
    -- Initialize state before setting up events
    QuickActionStates[action.text] = false
    
    -- Helper function to update button visual based on toggle state
    local function updateButtonVisual()
        local isActive = action.toggleable and QuickActionStates[action.text]
        if isActive then
            -- Active toggle state - show highlighted
            btn.BackgroundTransparency = 0.2
            btn.TextColor3 = Color3.new(1, 1, 1)
        else
            -- Default/inactive state
            btn.BackgroundTransparency = 0.7
            btn.TextColor3 = Colors.Text
        end
    end
    
    -- Desktop hover effects (only apply on non-mobile)
    if not IsMobile then
        ConnectPersistent(btn.MouseEnter, function()
            local isActive = QuickActionStates[action.text]
            TweenService:Create(btn, TweenInfo.new(0.1), {
                BackgroundTransparency = isActive and 0.1 or 0.3,
                TextColor3 = Color3.new(1, 1, 1)
            }):Play()
        end)
        
        ConnectPersistent(btn.MouseLeave, function()
            -- Respect toggle state when leaving
            local isActive = QuickActionStates[action.text]
            local targetTransparency = isActive and 0.2 or 0.7
            local targetColor = isActive and Color3.new(1, 1, 1) or Colors.Text
            TweenService:Create(btn, TweenInfo.new(0.1), {
                BackgroundTransparency = targetTransparency,
                TextColor3 = targetColor
            }):Play()
        end)
    end
    
    -- Press effect (works on both mobile and desktop)
    ConnectPersistent(btn.MouseButton1Down, function()
        TweenService:Create(btn, TweenInfo.new(0.05), {
            BackgroundTransparency = 0
        }):Play()
    end)
    
    ConnectPersistent(btn.MouseButton1Up, function()
        -- Return to appropriate state after press
        local isActive = QuickActionStates[action.text]
        local targetTransparency = isActive and 0.2 or 0.7
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundTransparency = targetTransparency
        }):Play()
    end)
    
    -- Click/Tap handler (works on both mobile and desktop)
    ConnectPersistent(btn.MouseButton1Click, function()
        if action.toggleable then
            -- Toggle state
            local wasActive = QuickActionStates[action.text]
            QuickActionStates[action.text] = not wasActive
            local isNowActive = QuickActionStates[action.text]
            
            -- Execute appropriate command
            local cmd = wasActive and action.offCmd or action.onCmd
            if cmd then
                InputBox.Text = cmd
                InputBox:CaptureFocus()
                task.wait(0.1)
                InputBox:ReleaseFocus(true)
            end
            
            -- Visual feedback for toggle state (immediate update)
            local targetTransparency = isNowActive and 0.2 or 0.7
            local targetColor = isNowActive and Color3.new(1, 1, 1) or Colors.Text
            btn.BackgroundTransparency = targetTransparency
            btn.TextColor3 = targetColor
        else
            -- Non-toggleable actions (one-time execution)
            InputBox.Text = action.onCmd
            InputBox:CaptureFocus()
            task.wait(0.1)
            InputBox:ReleaseFocus(true)
        end
    end)
end

local rows = math.ceil(#QuickActions / 3)
local gridHeight = (rows * scaledCellHeight) + ((rows - 1) * 4) + 12

-- Quick Actions Toggle moved to left of input box for mobile (to avoid minimizing obstruction)
local QuickActionsToggle = createInstance("TextButton", {
    Name = "QuickActionsToggle",
    Size = UDim2.new(0, QuickActionWidth, 0, QuickActionWidth),
    AnchorPoint = Vector2.new(0, 0), -- Top-Left alignment
    Position = UDim2.new(0, 8 + BtnWidth + 6, 0, 10), -- Placed after Mode Dropdown
    BackgroundColor3 = Colors.Purple,
    BackgroundTransparency = 0.5,
    Text = "⚡",
    TextColor3 = Colors.Text,
    Font = Enum.Font.GothamBold,
    TextSize = IsMobile and 16 or 12,
    Visible = IsMobile and not IS_CHAT_MODE,
    ZIndex = 5,
    Parent = MainFrame
})
addCorner(QuickActionsToggle, 4)

local quickActionsOpen = false
ConnectPersistent(QuickActionsToggle.MouseButton1Click, function()
    quickActionsOpen = not quickActionsOpen
    if quickActionsOpen then
        QuickActionsFrame.Visible = true
        TweenService:Create(QuickActionsFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -16, 0, gridHeight)}):Play()
    else
        TweenService:Create(QuickActionsFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -16, 0, 0)}):Play()
        task.delay(0.2, function()
            if not quickActionsOpen then QuickActionsFrame.Visible = false end
        end)
    end
end)


--// ============================================
--// 10B. TOUR REGISTRATION (v1.3.0)
--// ============================================
if TourManager then
    TourManager:registerElement("InputBox", InputContainer)
    TourManager:registerElement("ModeToggle", ModeDropdownContainer)
    if IsMobile then
        TourManager:registerElement("QuickActions", QuickActionsToggle)
    end
    
    -- Auto-start tour on first load (short delay to ensure UI ready)
    task.delay(1.5, function()
        TourManager:start()
    end)
end

--// Chat Log Helpers (ChatGPT-like Message Bubbles)
local ChatLogOrder = 0
local ChatMessageCount = 0
local ChatHistoryLimit = 12 -- Forward declaration for use in trimChatLogEntries

local function trimChatLogEntries()
    if not ChatLogFrame then return end
    local entries = {}
    for _, child in ipairs(ChatLogFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "ChatPlaceholder" then
            table.insert(entries, child)
        end
    end

    if #entries > ChatHistoryLimit then
        table.sort(entries, function(a, b)
            return (a.LayoutOrder or 0) < (b.LayoutOrder or 0)
        end)

        local overflow = #entries - ChatHistoryLimit
        for i = 1, overflow do
            entries[i]:Destroy()
        end
    end
end

-- Update memory indicator
local function updateMemoryIndicator()
    local exchangeCount = math.floor(ChatMessageCount / 2)
    if MemoryIndicator then
        MemoryIndicator.Text = string.format("Memory: %d/6", math.min(exchangeCount, 6))
        -- Color code based on memory usage
        if exchangeCount >= 5 then
            MemoryIndicator.TextColor3 = Colors.Orange
        elseif exchangeCount >= 3 then
            MemoryIndicator.TextColor3 = Colors.Green
        else
            MemoryIndicator.TextColor3 = Colors.ChatTimestamp
        end
    end
end

-- ChatGPT-like message bubble creation
local function appendChatLog(role, text)
    if not ChatLogFrame or not text or text == "" then return end
    
    -- Hide placeholder when first message is added
    if ChatPlaceholder and ChatPlaceholder.Visible ~= false then
        ChatPlaceholder.Visible = false
    end
    
    ChatLogOrder = ChatLogOrder + 1
    ChatMessageCount = ChatMessageCount + 1
    local isUser = role == "user"
    
    -- Get current timestamp
    local timestamp = os.date("%H:%M")

    -- Create message container with ChatGPT-like styling
    local messageContainer = createInstance("Frame", {
        Name = isUser and "UserMessage" or "AIMessage",
        LayoutOrder = ChatLogOrder,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = ChatLogFrame
    })
    
    -- Role indicator (You / Assistant)
    local roleLabel = createInstance("TextLabel", {
        Name = "RoleLabel",
        Size = UDim2.new(1, -50, 0, 16),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = isUser and "👤 You" or "🤖 Assistant",
        TextColor3 = isUser and Colors.Orange or Colors.Blue,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = messageContainer
    })
    
    -- Timestamp
    local timestampLabel = createInstance("TextLabel", {
        Name = "Timestamp",
        Size = UDim2.new(0, 45, 0, 16),
        Position = UDim2.new(1, -45, 0, 0),
        BackgroundTransparency = 1,
        Text = timestamp,
        TextColor3 = Colors.ChatTimestamp,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = messageContainer
    })

    -- Message bubble with distinct styling
    local bubble = createInstance("Frame", {
        Name = "Bubble",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 18),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = isUser and Colors.ChatUserBubble or Colors.ChatAIBubble,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Parent = messageContainer
    })
    addCorner(bubble, 12)
    
    -- Subtle border for user messages
    if isUser then
        addStroke(bubble, Colors.Orange, 1).Transparency = 0.7
    end
    
    -- Message padding
    createInstance("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = bubble
    })

    -- Message text
    local messageText = createInstance("TextLabel", {
        Name = "MessageText",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = isUser and Colors.ChatUserText or Colors.ChatAIText,
        Font = Enum.Font.Gotham,
        TextSize = IsMobile and 13 or 14,
        RichText = false,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        LineHeight = 1.3,
        Parent = bubble
    })

    trimChatLogEntries()
    updateMemoryIndicator()

    -- Auto-scroll to bottom with smooth animation
    task.defer(function()
        local targetY = math.max(0, ChatLogFrame.AbsoluteCanvasSize.Y - ChatLogFrame.AbsoluteSize.Y)
        TweenService:Create(ChatLogFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            CanvasPosition = Vector2.new(0, targetY)
        }):Play()
    end)
end

-- Clear chat log function
local function clearChatLog()
    if not ChatLogFrame then return end
    
    for _, child in ipairs(ChatLogFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "ChatPlaceholder" then
            pcall(function() child:Destroy() end)
        end
    end
    ChatLogOrder = 0
    ChatMessageCount = 0
    if ChatPlaceholder then
        ChatPlaceholder.Visible = true
    end
    updateMemoryIndicator()
    
    -- Also clear the internal chat history
    if ChatHistory then
        for i = #ChatHistory, 1, -1 do
            table.remove(ChatHistory, i)
        end
    end
end

--// ============================================
--// 11. TUTORIAL SYSTEM (Multi-Step Onboarding)
--// ============================================
local TutorialCompleted = false
local CurrentStep = 1

-- Tutorial content for each step
local TutorialSteps = {
    {
        title = "Welcome to Smart IY",
        icon = "👋",
        content = "<b>Smart Infinite Yield</b> is an AI-powered admin script that understands <font color='#40e682'>natural language</font>.\n\nInstead of memorizing commands, just tell it what you want in plain English!\n\n<font color='#969696'>Example: Type \"make me fly\" instead of \"fly\"</font>",
        button = "Next →"
    },
    {
        title = "What It Does",
        icon = "🧠",
        content = "<b>Smart IY translates your words into commands:</b>\n\n<font color='#ff9128'>\"Make me fly\"</font> → <font color='#40e682'>;fly</font>\n\n<font color='#ff9128'>\"Make me super fast\"</font> → <font color='#40e682'>;speed 100</font>\n\n<font color='#ff9128'>\"Teleport to that player\"</font> → <font color='#40e682'>;goto PlayerName</font>\n\nIt even figures out <b>which player</b> you mean!",
        button = "Next →"
    },
    {
        title = "Two Modes",
        icon = "🔄",
        content = "<b><font color='#ff9128'>CMD Mode (Orange)</font></b>\nExecutes commands. Say what you want done.\n<font color='#969696'>\"Fly me\" → Executes ;fly</font>\n\n<b><font color='#32b4ff'>CHAT Mode (Blue)</font></b>\nAsk questions, get advice. No execution.\n<font color='#969696'>\"How do I win this game?\" → AI gives tips</font>\n\nClick the <b>mode button</b> to switch!",
        button = "Next →"
    },
    {
        title = "How To Use",
        icon = "⌨️",
        content = "<b>Step 1:</b> Type your request in the input box\n<font color='#969696'>\"give me god mode\"</font>\n\n<b>Step 2:</b> Press <font color='#40e682'>Enter</font> or click <font color='#40e682'>Send</font>\n\n<b>Step 3:</b> Watch the status bar for feedback\n<font color='#40e682'>[FAST]</font> = Instant local execution\n<font color='#b464ff'>[AI]</font> = AI processed your request\n<font color='#ff5050'>[ERROR]</font> = Something went wrong",
        button = "Next →"
    },
    {
        title = "Smart Features",
        icon = "✨",
        content = "<b><font color='#b464ff'>Intelligent Caching</font></b>\nSmart IY <b>learns</b> your phrases! After using \"make me fast\" once, it executes instantly next time.\n\n<b><font color='#b464ff'>Fuzzy Targeting</font></b>\nType partial names: <font color='#ff9128'>\"goto valk\"</font> finds \"Valkorym\"\n\n<b><font color='#b464ff'>Predictions</font></b>\nAs you type, suggestions appear below the input box.",
        button = "Next →"
    },
    {
        title = "Waypoints & Teleporting",
        icon = "📍",
        content = "<b>Save & Teleport to Locations:</b>\n\n<font color='#40e682'>swp [name]</font> - Save current spot\n<font color='#969696'>\"swp base\" saves your position as \"base\"</font>\n\n<font color='#40e682'>waypoint [name]</font> - Teleport to waypoint\n<font color='#969696'>\"waypoint base\" takes you back there</font>\n\n<font color='#40e682'>goto [player]</font> - Teleport to player\n<font color='#969696'>\"goto john\" teleports to player John</font>\n\n<font color='#ff9128'>Tip:</font> Type \"waypoint \" to see saved waypoints!",
        button = "Next →"
    },
    {
        title = "Cache Management",
        icon = "🗑️",
        content = "<b>If the AI learns something wrong:</b>\n\n<font color='#40e682'>clearcache</font>\nWipes all learned commands. Fresh start!\n\n<font color='#40e682'>cacheinfo</font>\nShows how many commands are cached.\n<font color='#969696'>\"Cache: 15/100 commands stored\"</font>\n\n<font color='#ff9128'>Tip:</font> Use clearcache if commands behave unexpectedly.",
        button = "Next →"
    },
    {
        title = "Controls & Keybinds",
        icon = "🎮",
        content = "<b><font color='#40e682'>Right Shift</font></b> - Toggle menu visibility\n\n<b><font color='#40e682'>bind [key] [cmd]</font></b> - Create keybinds\n<font color='#969696'>\"bind f fly\" → F toggles fly on/off</font>\n\n<b><font color='#40e682'>Mobile Users:</font></b>\nTap the <font color='#ff9128'>⚡</font> button for Quick Actions - one-tap commands without typing!\n\n<b><font color='#40e682'>Minimize:</font></b> Click <b>−</b> to collapse",
        button = "Next →"
    },
    {
        title = "You're Ready!",
        icon = "🚀",
        content = "<b>You now know everything to get started!</b>\n\n<font color='#b464ff'>Quick Reference:</font>\n• Type naturally - AI understands you\n• <font color='#ff9128'>CMD</font> = Execute | <font color='#32b4ff'>CHAT</font> = Ask\n• <font color='#40e682'>Right Shift</font> = Toggle menu\n• <font color='#40e682'>clearcache</font> = Reset learned commands\n\n<font color='#969696'>Made with ❤️ by VolQ5</font>",
        button = "Let's Go!"
    }
}

local TotalSteps = #TutorialSteps

-- Tutorial Frame
local TutSize = IsMobile and UDim2.new(0.9, 0, 0, 320) or UDim2.new(0, 450, 0, 340)

local TutorialFrame = createInstance("Frame", {
    Name = "Tutorial",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = TutSize,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = Colors.Background,
    ZIndex = 100,
    Parent = SIY_Screen
})
addCorner(TutorialFrame, 12)
addStroke(TutorialFrame, Colors.Orange, 2)

-- Progress Bar Background
local ProgressBg = createInstance("Frame", {
    Size = UDim2.new(1, -40, 0, 4),
    Position = UDim2.new(0, 20, 0, 12),
    BackgroundColor3 = Colors.InputBg,
    ZIndex = 101,
    Parent = TutorialFrame
})
addCorner(ProgressBg, 2)

-- Progress Bar Fill
local ProgressFill = createInstance("Frame", {
    Size = UDim2.new(1 / TotalSteps, 0, 1, 0),
    BackgroundColor3 = Colors.Orange,
    ZIndex = 102,
    Parent = ProgressBg
})
addCorner(ProgressFill, 2)

-- Step Counter
local StepCounter = createInstance("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "Step 1 of " .. TotalSteps,
    TextColor3 = Colors.TextDim,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    ZIndex = 101,
    Parent = TutorialFrame
})

-- Icon
local TutorialIcon = createInstance("TextLabel", {
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 45),
    BackgroundTransparency = 1,
    Text = TutorialSteps[1].icon,
    TextColor3 = Colors.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 32,
    ZIndex = 101,
    Parent = TutorialFrame
})

-- Title
local TutorialTitle = createInstance("TextLabel", {
    Size = UDim2.new(1, 0, 0, 30),
    Position = UDim2.new(0, 0, 0, 85),
    BackgroundTransparency = 1,
    Text = TutorialSteps[1].title,
    TextColor3 = Colors.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    ZIndex = 101,
    Parent = TutorialFrame
})

-- Content
local TutorialContent = createInstance("TextLabel", {
    Size = UDim2.new(1, -40, 0, 150),
    Position = UDim2.new(0, 20, 0, 120),
    BackgroundTransparency = 1,
    Text = TutorialSteps[1].content,
    TextColor3 = Colors.TextDim,
    Font = Enum.Font.Gotham,
    TextSize = IsMobile and 12 or 13,
    RichText = true,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 101,
    Parent = TutorialFrame
})

-- Back Button
local BackBtn = createInstance("TextButton", {
    Size = UDim2.new(0, 80, 0, 36),
    Position = UDim2.new(0, 20, 1, -55),
    BackgroundColor3 = Colors.InputBg,
    Text = "← Back",
    TextColor3 = Colors.TextDim,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    Visible = false,
    ZIndex = 101,
    Parent = TutorialFrame
})
addCorner(BackBtn, 8)
addStroke(BackBtn, Colors.Border, 1)

-- Next/Start Button
local NextBtn = createInstance("TextButton", {
    Size = UDim2.new(0, 120, 0, 36),
    Position = UDim2.new(1, -140, 1, -55),
    BackgroundColor3 = Colors.Orange,
    Text = TutorialSteps[1].button,
    TextColor3 = Color3.new(0, 0, 0),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    ZIndex = 101,
    Parent = TutorialFrame
})
addCorner(NextBtn, 8)

-- Skip Button
local SkipBtn = createInstance("TextButton", {
    Size = UDim2.new(0, 60, 0, 25),
    Position = UDim2.new(1, -70, 0, 8),
    BackgroundTransparency = 1,
    Text = "Skip",
    TextColor3 = Colors.TextDim,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    ZIndex = 101,
    Parent = TutorialFrame
})

-- Function to update tutorial step
local function updateTutorialStep(step)
    CurrentStep = step
    local data = TutorialSteps[step]
    
    -- Update progress
    TweenService:Create(ProgressFill, TweenInfo.new(0.3), {
        Size = UDim2.new(step / TotalSteps, 0, 1, 0)
    }):Play()
    
    StepCounter.Text = "Step " .. step .. " of " .. TotalSteps
    
    -- Fade out current content
    TweenService:Create(TutorialIcon, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
    TweenService:Create(TutorialTitle, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
    TweenService:Create(TutorialContent, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
    
    task.wait(0.15)
    
    -- Update content
    TutorialIcon.Text = data.icon
    TutorialTitle.Text = data.title
    TutorialContent.Text = data.content
    NextBtn.Text = data.button
    
    -- Show/hide back button
    BackBtn.Visible = step > 1
    
    -- Change button color on last step
    if step == TotalSteps then
        NextBtn.BackgroundColor3 = Colors.Green
        NextBtn.Size = UDim2.new(0, 140, 0, 36)
        NextBtn.Position = UDim2.new(1, -160, 1, -55)
    else
        NextBtn.BackgroundColor3 = Colors.Orange
        NextBtn.Size = UDim2.new(0, 120, 0, 36)
        NextBtn.Position = UDim2.new(1, -140, 1, -55)
    end
    
    -- Fade in new content
    TweenService:Create(TutorialIcon, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
    TweenService:Create(TutorialTitle, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
    TweenService:Create(TutorialContent, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
end

-- Function to close tutorial and unlock GUI
local function completeTutorial()
    TutorialCompleted = true
    
    -- Fade out tutorial
    TweenService:Create(TutorialFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    for _, child in ipairs(TutorialFrame:GetDescendants()) do
        if child:IsA("GuiObject") then
            local prop = (child:IsA("TextLabel") or child:IsA("TextButton")) and "TextTransparency" or "BackgroundTransparency"
            pcall(function()
                TweenService:Create(child, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            end)
        end
    end
    
    task.wait(0.3)
    TutorialFrame.Visible = false
    
    -- Unlock and show main GUI with animation
    MainFrame.Visible = true
    MainFrame.Position = UDim2.new(0.5, 0, -0.2, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.15, 0)
    }):Play()
    
    -- Welcome message after tutorial
    task.delay(0.5, function()
        StatusLabel.Text = ">> Welcome! Type anything to get started"
        StatusLabel.TextColor3 = Colors.Green
        StatusLabel.TextTransparency = 0
        TweenService:Create(StatusLabel, TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 0.6}):Play()
    end)
end

-- Button connections
ConnectPersistent(NextBtn.MouseButton1Click, function()
    if CurrentStep < TotalSteps then
        updateTutorialStep(CurrentStep + 1)
    else
        completeTutorial()
    end
end)

ConnectPersistent(BackBtn.MouseButton1Click, function()
    if CurrentStep > 1 then
        updateTutorialStep(CurrentStep - 1)
    end
end)

ConnectPersistent(SkipBtn.MouseButton1Click, function()
    completeTutorial()
end)

-- Function to show tutorial (for help button)
local function showTutorial()
    CurrentStep = 1
    TutorialCompleted = false
    
    -- Reset tutorial UI
    local data = TutorialSteps[1]
    TutorialIcon.Text = data.icon
    TutorialTitle.Text = data.title
    TutorialContent.Text = data.content
    NextBtn.Text = data.button
    NextBtn.BackgroundColor3 = Colors.Orange
    NextBtn.Size = UDim2.new(0, 120, 0, 36)
    NextBtn.Position = UDim2.new(1, -140, 1, -55)
    BackBtn.Visible = false
    StepCounter.Text = "Step 1 of " .. TotalSteps
    ProgressFill.Size = UDim2.new(1 / TotalSteps, 0, 1, 0)
    
    -- Reset transparency
    TutorialFrame.BackgroundTransparency = 0
    TutorialIcon.TextTransparency = 0
    TutorialTitle.TextTransparency = 0
    TutorialContent.TextTransparency = 0
    
    for _, child in ipairs(TutorialFrame:GetDescendants()) do
        if child:IsA("Frame") then
            child.BackgroundTransparency = child.Name == "ProcessingGlow" and 1 or 0
        elseif child:IsA("TextButton") then
            child.BackgroundTransparency = 0
            child.TextTransparency = 0
        elseif child:IsA("TextLabel") then
            child.TextTransparency = 0
        end
    end
    
    TutorialFrame.Visible = true
end

-- Help button shows tutorial
ConnectPersistent(HelpBtn.MouseButton1Click, function()
    showTutorial()
end)

-- Initially hide main GUI until tutorial is complete
MainFrame.Visible = false

--// ============================================
--// 12. LOGIC ENGINE - DATA TABLES
--// ============================================
-- IS_CHAT_MODE is declared earlier in UI Configuration section
local BindSystem = {}

-- Rolling chat memory (last 6 exchanges = 12 messages)
-- Note: ChatHistoryLimit is declared earlier in the Chat Log Helpers section
local ChatHistory = {}

local function trimChatHistory()
    while #ChatHistory > ChatHistoryLimit do
        table.remove(ChatHistory, 1)
    end
end

local function recordChatMessage(role, content)
    if not role or not content then return end
    table.insert(ChatHistory, {
        role = role,
        content = content
    })
    trimChatHistory()
end

local function getChatHistorySnapshot()
    local copy = {}
    for _, msg in ipairs(ChatHistory) do
        table.insert(copy, {
            role = msg.role,
            content = msg.content
        })
    end
    return copy
end

-- ToggleMap: Maps commands to their opposite toggle state
-- Only includes commands that actually exist in IYsource.lua
local ToggleMap = {
    -- Movement
    fly = "unfly", unfly = "fly",
    noclip = "clip", clip = "noclip", unnoclip = "noclip",
    float = "unfloat", unfloat = "float",
    platform = "unplatform", unplatform = "platform",
    swim = "unswim", unswim = "swim",
    vehiclefly = "unvehiclefly", unvehiclefly = "vehiclefly",
    vfly = "unvfly", unvfly = "vfly",
    cframefly = "uncframefly", uncframefly = "cframefly",
    cfly = "uncfly", uncfly = "cfly",
    
    -- Visuals
    esp = "noesp", noesp = "esp",
    chams = "nochams", nochams = "chams",
    xray = "unxray", unxray = "xray",
    fullbright = "restorelighting",
    globalshadows = "unglobalshadows", gshadows = "nogshadows",
    light = "unlight", unlight = "light",
    
    -- Camera
    view = "unview", unview = "view",
    spectate = "unspectate", unspectate = "spectate",
    freecam = "unfreecam", unfreecam = "freecam",
    fc = "unfc", unfc = "fc",
    
    -- Player
    invisible = "visible", visible = "invisible",
    invis = "vis", vis = "invis",
    god = "respawn",
    
    -- Chat
    spam = "unspam", unspam = "spam",
    pmspam = "unpmspam", unpmspam = "pmspam",
    bubblechat = "unbubblechat", unbubblechat = "bubblechat",
    
    -- Animation
    dance = "undance", undance = "dance",
    spin = "unspin", unspin = "spin",
    spasm = "unspasm", unspasm = "spasm",
    hatspin = "unhatspin", unhatspin = "hatspin",
    
    -- Tools
    tools = "notools", notools = "tools",
    grabtools = "ungrabtools", ungrabtools = "grabtools",
    reach = "unreach", unreach = "reach",
    
    -- Misc
    autoclick = "unautoclick", unautoclick = "autoclick",
    noanim = "reanim", reanim = "noanim",
    stun = "unstun", unstun = "stun",
    platformstand = "unplatformstand", unplatformstand = "platformstand",
    anchor = "unanchor", unanchor = "anchor",
    fling = "unfling", unfling = "fling",
    walkfling = "unwalkfling", unwalkfling = "walkfling",
    antifling = "unantifling", unantifling = "antifling",
    antivoid = "unantivoid", unantivoid = "antivoid",
    infjump = "uninfjump", uninfjump = "infjump",
    autojump = "unautojump", unautojump = "autojump",
    edgejump = "unedgejump", unedgejump = "edgejump"
}

-- FastMap: Comprehensive command mapping with all IY commands and aliases
-- Updated: v1.2.2 - Extracted from IYsource.lua with 400+ commands
local FastMap = {
    -- System & Aliases (only valid IY commands)
    ["^addalias (.+)"] = "addalias %1", ["^removealias (.+)"] = "removealias %1", ["^clraliases$"] = "clraliases",
    ["^addplugin (.+)"] = "addplugin %1", ["^plugin (.+)"] = "addplugin %1",
    ["^removeplugin (.+)"] = "removeplugin %1", ["^deleteplugin (.+)"] = "removeplugin %1",
    ["^reloadplugin (.+)"] = "reloadplugin %1",
    ["^addallplugins$"] = "addallplugins", ["^loadallplugins$"] = "addallplugins",
    ["^breakloops$"] = "breakloops", ["^break$"] = "breakloops",
    ["^removecmd (.+)"] = "removecmd %1", ["^deletecmd (.+)"] = "removecmd %1",

    -- Waypoint Commands (using correct IY command names)
    ["^waypoint (.+)"] = "waypoint %1", ["^wp (.+)"] = "waypoint %1",
    ["^swp (.+)"] = "setwaypoint %1", ["^savewp (.+)"] = "setwaypoint %1", ["^setwp (.+)"] = "setwaypoint %1",
    ["^spos (.+)"] = "setwaypoint %1", ["^savepos (.+)"] = "setwaypoint %1", ["^saveposition (.+)"] = "setwaypoint %1",
    ["^waypoints$"] = "waypoints", ["^positions$"] = "waypoints",
    ["^showwaypoints$"] = "showwaypoints", ["^showwp$"] = "showwaypoints", ["^showwps$"] = "showwaypoints",
    ["^hidewaypoints$"] = "hidewaypoints", ["^hidewp$"] = "hidewaypoints", ["^hidewps$"] = "hidewaypoints",
    ["^lpos (.+)"] = "waypoint %1", ["^loadpos (.+)"] = "waypoint %1", ["^loadposition (.+)"] = "waypoint %1",
    ["^tweenwaypoint (.+)"] = "tweenwaypoint %1", ["^twp (.+)"] = "tweenwaypoint %1",
    ["^walktowaypoint (.+)"] = "walktowaypoint %1", ["^wtwp (.+)"] = "walktowaypoint %1",
    ["^deletewaypoint (.+)"] = "deletewaypoint %1", ["^dwp (.+)"] = "deletewaypoint %1",
    ["^deletepos (.+)"] = "deletewaypoint %1", ["^deleteposition (.+)"] = "deletewaypoint %1", ["^dpos (.+)"] = "deletewaypoint %1",
    ["^clearwaypoints$"] = "clearwaypoints", ["^cwp$"] = "clearwaypoints", ["^clearpos$"] = "clearwaypoints",
    ["^clearpositions$"] = "clearwaypoints", ["^cpos$"] = "clearwaypoints",
    ["^waypointpos (.+)"] = "waypointpos %1", ["^wpp (.+)"] = "waypointpos %1",
    ["^cleargamewaypoints$"] = "cleargamewaypoints", ["^cgamewp$"] = "cleargamewaypoints",

    -- Utility
    ["^discord$"] = "discord", ["^support$"] = "discord",
    ["^guiscale (.+)"] = "guiscale %1",
    ["^console$"] = "console", ["^oldconsole$"] = "oldconsole",
    ["^explorer$"] = "explorer", ["^dex$"] = "explorer", ["^olddex$"] = "olddex", ["^odex$"] = "olddex",
    ["^remotespy$"] = "remotespy", ["^rspy$"] = "remotespy",
    ["^audiologger$"] = "audiologger", ["^alogger$"] = "audiologger",
    ["^antiidle$"] = "antiidle", ["^antiafk$"] = "antiidle",
    ["^datalimit (%d+)"] = "datalimit %1",
    ["^replicationlag (%d+)"] = "replicationlag %1", ["^backtrack (%d+)"] = "replicationlag %1",
    ["^creatorid$"] = "creatorid", ["^creator$"] = "creatorid",
    ["^copycreatorid$"] = "copycreatorid", ["^copycreator$"] = "copycreatorid",
    ["^setcreatorid$"] = "setcreatorid", ["^setcreator$"] = "setcreatorid",
    ["^noprompts$"] = "noprompts", ["^nopurchaseprompts$"] = "noprompts",
    ["^showprompts$"] = "showprompts", ["^showpurchaseprompts$"] = "showprompts",
    ["^promptr6$"] = "promptr6", ["^promptr15$"] = "promptr15",
    ["^enable (.+)"] = "enable %1", ["^disable (.+)"] = "disable %1",
    ["^showguis$"] = "showguis", ["^unshowguis$"] = "unshowguis",
    ["^hideguis$"] = "hideguis", ["^unhideguis$"] = "unhideguis",
    ["^guidelete$"] = "guidelete", ["^unguidelete$"] = "unguidelete", ["^noguidelete$"] = "unguidelete",
    ["^hideiy$"] = "hideiy", ["^showiy$"] = "showiy", ["^unhideiy$"] = "showiy",
    ["^keepiy$"] = "keepiy", ["^unkeepiy$"] = "unkeepiy", ["^togglekeepiy$"] = "togglekeepiy",
    ["^savegame$"] = "savegame", ["^saveplace$"] = "savegame",
    ["^clearerror$"] = "clearerror", ["^clearerrors$"] = "clearerror",
    ["^clientantikick$"] = "clientantikick", ["^antikick$"] = "clientantikick",
    ["^clientantiteleport$"] = "clientantiteleport", ["^antiteleport$"] = "clientantiteleport",
    ["^allowrejoin$"] = "allowrejoin", ["^allowrj$"] = "allowrejoin",
    ["^cancelteleport$"] = "cancelteleport", ["^canceltp$"] = "cancelteleport",
    ["^volume (%d+)"] = "volume %1", ["^vol (%d+)"] = "volume %1",
    ["^antilag$"] = "antilag", ["^boostfps$"] = "antilag", ["^lowgraphics$"] = "antilag",
    ["^record$"] = "record", ["^rec$"] = "record",
    ["^screenshot$"] = "screenshot", ["^scrnshot$"] = "screenshot",
    ["^togglefullscreen$"] = "togglefullscreen", ["^togglefs$"] = "togglefullscreen",
    ["^notify (.+)"] = "notify %1",
    ["^lastcommand$"] = "lastcommand", ["^lastcmd$"] = "lastcommand",
    ["^setfpscap (%d+)"] = "setfpscap %1", ["^fpscap (%d+)"] = "setfpscap %1", ["^maxfps (%d+)"] = "setfpscap %1",
    ["^executor$"] = "executor",
    ["^inspect (.+)"] = "inspect %1", ["^examine (.+)"] = "inspect %1",
    ["^partpath$"] = "partpath", ["^partname$"] = "partpath",
    ["^wallwalk$"] = "wallwalk", ["^walkonwalls$"] = "wallwalk",

    -- Movement
    ["^noclip$"] = "noclip", ["^unnoclip$"] = "noclip", ["^clip$"] = "clip", ["^togglenoclip$"] = "togglenoclip",
    ["^fly$"] = "fly", ["^fly (%d+)$"] = "fly %1", ["^unfly$"] = "unfly", ["^nofly$"] = "unfly", ["^togglefly$"] = "togglefly",
    ["^flyspeed (%d+)$"] = "flyspeed %1", ["^flysp (%d+)$"] = "flyspeed %1",
    ["^vfly$"] = "vehiclefly", ["^vfly (%d+)$"] = "vehiclefly %1",
    ["^vehiclefly$"] = "vehiclefly", ["^vehiclefly (%d+)$"] = "vehiclefly %1",
    ["^unvfly$"] = "unvehiclefly", ["^unvehiclefly$"] = "unvehiclefly", ["^novfly$"] = "unvehiclefly", ["^novehiclefly$"] = "unvehiclefly",
    ["^togglevfly$"] = "togglevfly",
    ["^vehicleflyspeed (%d+)$"] = "vehicleflyspeed %1", ["^vflyspeed (%d+)$"] = "vehicleflyspeed %1",
    ["^vflysp (%d+)$"] = "vehicleflyspeed %1", ["^vehicleflysp (%d+)$"] = "vehicleflyspeed %1",
    ["^cfly$"] = "cframefly", ["^cfly (%d+)$"] = "cframefly %1",
    ["^cframefly$"] = "cframefly", ["^cframefly (%d+)$"] = "cframefly %1",
    ["^uncfly$"] = "uncframefly", ["^uncframefly$"] = "uncframefly",
    ["^cframeflyspeed (%d+)$"] = "cframeflyspeed %1", ["^cflyspeed (%d+)$"] = "cframeflyspeed %1",
    ["^qefly$"] = "qefly", ["^flyqe$"] = "qefly",
    ["^vehiclenoclip$"] = "vehiclenoclip", ["^vnoclip$"] = "vehiclenoclip",
    ["^vehicleclip$"] = "vehicleclip", ["^vclip$"] = "vehicleclip",
    ["^unvnoclip$"] = "vehicleclip", ["^unvehiclenoclip$"] = "vehicleclip",
    ["^togglevnoclip$"] = "togglevnoclip",
    ["^float$"] = "float", ["^platform$"] = "float",
    ["^unfloat$"] = "unfloat", ["^nofloat$"] = "unfloat", ["^unplatform$"] = "unfloat", ["^noplatform$"] = "unfloat",
    ["^togglefloat$"] = "togglefloat",
    ["^swim$"] = "swim", ["^unswim$"] = "unswim", ["^noswim$"] = "unswim", ["^toggleswim$"] = "toggleswim",
    ["^tpwalk (%d+)$"] = "tpwalk %1", ["^teleportwalk (%d+)$"] = "tpwalk %1",
    ["^untpwalk$"] = "untpwalk", ["^unteleportwalk$"] = "untpwalk",

    -- Teleport
    ["^goto (.+)"] = "goto %1", ["^to (.+)"] = "goto %1",
    ["^tweengoto (.+)"] = "tweengoto %1", ["^tgoto (.+)"] = "tweengoto %1", ["^tto (.+)"] = "tweengoto %1", ["^tweento (.+)"] = "tweengoto %1",
    ["^tweenspeed (%d+)"] = "tweenspeed %1", ["^tspeed (%d+)"] = "tweenspeed %1",
    ["^vehiclegoto (.+)"] = "vehiclegoto %1", ["^vgoto (.+)"] = "vehiclegoto %1", ["^vtp (.+)"] = "vehiclegoto %1", ["^vehicletp (.+)"] = "vehiclegoto %1",
    ["^pulsetp (.+)"] = "pulsetp %1", ["^ptp (.+)"] = "pulsetp %1",
    ["^loopgoto (.+)"] = "loopgoto %1", ["^unloopgoto$"] = "unloopgoto", ["^noloopgoto$"] = "unloopgoto",
    ["^clientbring (.+)"] = "clientbring %1", ["^cbring (.+)"] = "clientbring %1",
    ["^loopbring (.+)"] = "loopbring %1", ["^unloopbring$"] = "unloopbring", ["^noloopbring$"] = "unloopbring",
    ["^spawnpoint$"] = "spawnpoint", ["^spawn$"] = "spawnpoint",
    ["^nospawnpoint$"] = "nospawnpoint", ["^nospawn$"] = "nospawnpoint", ["^removespawnpoint$"] = "nospawnpoint",
    ["^flashback$"] = "flashback", ["^diedtp$"] = "flashback",
    ["^walltp$"] = "walltp", ["^nowalltp$"] = "nowalltp", ["^unwalltp$"] = "nowalltp",
    ["^teleporttool$"] = "teleporttool", ["^tptool$"] = "teleporttool",
    ["^clickteleport$"] = "clickteleport",
    ["^clickdelete$"] = "clickdelete",
    ["^mouseteleport$"] = "mouseteleport", ["^mousetp$"] = "mouseteleport",
    ["^tpposition (.+)"] = "tpposition %1", ["^tppos (.+)"] = "tpposition %1",
    ["^tweentpposition (.+)"] = "tweentpposition %1", ["^ttppos (.+)"] = "tweentpposition %1",
    ["^offset (.+)"] = "offset %1", ["^tweenoffset (.+)"] = "tweenoffset %1", ["^toffset (.+)"] = "tweenoffset %1",
    ["^walktopos (.+)"] = "walktopos %1", ["^walktoposition (.+)"] = "walktopos %1",
    ["^getposition$"] = "getposition", ["^getpos$"] = "getposition", ["^notifypos$"] = "getposition", ["^notifyposition$"] = "getposition",
    ["^copyposition$"] = "copyposition", ["^copypos$"] = "copyposition",

    -- Visuals
    ["^esp$"] = "esp", ["^noesp$"] = "noesp", ["^unesp$"] = "noesp",
    ["^espteam$"] = "espteam", ["^unespteam$"] = "noesp",
    ["^esptransparency (%d+)"] = "esptransparency %1",
    ["^partesp (.+)"] = "partesp %1", ["^unpartesp (.+)"] = "unpartesp %1", ["^nopartesp (.+)"] = "unpartesp %1",
    ["^chams$"] = "chams", ["^nochams$"] = "nochams", ["^unchams$"] = "nochams",
    ["^xray$"] = "xray", ["^noxray$"] = "noxray", ["^unxray$"] = "noxray",
    ["^togglexray$"] = "togglexray", ["^loopxray$"] = "loopxray", ["^unloopxray$"] = "unloopxray",
    ["^locate (.+)"] = "locate %1", ["^nolocate$"] = "nolocate", ["^unlocate$"] = "nolocate",
    ["^spectate (.+)"] = "spectate %1", ["^view (.+)"] = "spectate %1",
    ["^unspectate$"] = "unspectate", ["^unview$"] = "unspectate",
    ["^viewpart (.+)"] = "viewpart %1", ["^viewp (.+)"] = "viewpart %1",
    ["^freecam$"] = "freecam", ["^fc$"] = "freecam",
    ["^unfreecam$"] = "unfreecam", ["^nofreecam$"] = "unfreecam", ["^unfc$"] = "unfreecam", ["^nofc$"] = "unfreecam",
    ["^freecamspeed (%d+)"] = "freecamspeed %1", ["^fcspeed (%d+)"] = "freecamspeed %1",
    ["^freecampos (.+)"] = "freecampos %1", ["^fcpos (.+)"] = "freecampos %1", ["^fcp (.+)"] = "freecampos %1",
    ["^freecamposition (.+)"] = "freecampos %1", ["^fcposition (.+)"] = "freecampos %1",
    ["^freecamwaypoint (.+)"] = "freecamwaypoint %1", ["^fcwp (.+)"] = "freecamwaypoint %1",
    ["^freecamgoto (.+)"] = "freecamgoto %1", ["^fcgoto (.+)"] = "freecamgoto %1",
    ["^freecamtp (.+)"] = "freecamgoto %1", ["^fctp (.+)"] = "freecamgoto %1",
    ["^notifyfreecamposition$"] = "notifyfreecamposition", ["^notifyfcpos$"] = "notifyfreecamposition",
    ["^copyfreecamposition$"] = "copyfreecamposition", ["^copyfcpos$"] = "copyfreecamposition",
    ["^gotocamera$"] = "gotocamera", ["^gotocam$"] = "gotocamera", ["^tocam$"] = "gotocamera",
    ["^tweengotocamera$"] = "tweengotocamera", ["^tweengotocam$"] = "tweengotocamera",
    ["^tgotocam$"] = "tweengotocamera", ["^ttocam$"] = "tweengotocamera",
    ["^firstp$"] = "firstp", ["^thirdp$"] = "thirdp",
    ["^noclipcam$"] = "noclipcam", ["^nccam$"] = "noclipcam",
    ["^maxzoom (%d+)"] = "maxzoom %1", ["^minzoom (%d+)"] = "minzoom %1",
    ["^camdistance (%d+)"] = "camdistance %1",
    ["^fov (%d+)"] = "fov %1", ["^fixcam$"] = "fixcam", ["^restorecam$"] = "fixcam",
    ["^enableshiftlock$"] = "enableshiftlock", ["^enablesl$"] = "enableshiftlock", ["^shiftlock$"] = "enableshiftlock",
    ["^lookat (.+)"] = "lookat %1",
    ["^fullbright$"] = "fullbright", ["^fb$"] = "fullbright", ["^fullbrightness$"] = "fullbright",
    ["^loopfullbright$"] = "loopfullbright", ["^loopfb$"] = "loopfullbright",
    ["^unloopfullbright$"] = "unloopfullbright", ["^unloopfb$"] = "unloopfullbright",
    ["^day$"] = "day", ["^night$"] = "night", ["^nofog$"] = "nofog",
    ["^ambient (.+)"] = "ambient %1", ["^brightness (.+)"] = "brightness %1",
    ["^globalshadows$"] = "globalshadows", ["^gshadows$"] = "globalshadows",
    ["^noglobalshadows$"] = "noglobalshadows", ["^unglobalshadows$"] = "noglobalshadows",
    ["^nogshadows$"] = "noglobalshadows", ["^ungshadows$"] = "noglobalshadows",
    ["^restorelighting$"] = "restorelighting", ["^rlighting$"] = "restorelighting",
    ["^light$"] = "light", ["^nolight$"] = "nolight", ["^unlight$"] = "nolight",
    ["^hovername$"] = "hovername", ["^unhovername$"] = "unhovername", ["^nohovername$"] = "unhovername",

    -- Player
    ["^age (.+)"] = "age %1", ["^chatage (.+)"] = "chatage %1",
    ["^joindate (.+)"] = "joindate %1", ["^jd (.+)"] = "joindate %1",
    ["^chatjoindate (.+)"] = "chatjoindate %1", ["^cjd (.+)"] = "chatjoindate %1",
    ["^copyname (.+)"] = "copyname %1", ["^copyuser (.+)"] = "copyname %1",
    ["^userid (.+)"] = "userid %1", ["^id (.+)"] = "userid %1",
    ["^copyuserid (.+)"] = "copyuserid %1", ["^copyid (.+)"] = "copyuserid %1",
    ["^copyplaceid$"] = "copyplaceid", ["^placeid$"] = "copyplaceid",
    ["^copygameid$"] = "copygameid", ["^gameid$"] = "copygameid",
    ["^appearanceid (.+)"] = "appearanceid %1", ["^aid (.+)"] = "appearanceid %1",
    ["^copyappearanceid (.+)"] = "copyappearanceid %1", ["^caid (.+)"] = "copyappearanceid %1",
    ["^bang (.+)"] = "bang %1", ["^rape (.+)"] = "bang %1",
    ["^unbang$"] = "unbang", ["^unrape$"] = "unbang",
    ["^carpet (.+)"] = "carpet %1", ["^uncarpet$"] = "uncarpet", ["^nocarpet$"] = "uncarpet",
    ["^friend (.+)"] = "friend %1", ["^unfriend (.+)"] = "unfriend %1",
    ["^headsit (.+)"] = "headsit %1",
    ["^walkto (.+)"] = "walkto %1", ["^follow (.+)"] = "walkto %1",
    ["^unwalkto$"] = "unwalkto", ["^nowalkto$"] = "unwalkto", ["^unfollow$"] = "unwalkto", ["^nofollow$"] = "unwalkto",
    ["^pathfindwalkto (.+)"] = "pathfindwalkto %1", ["^pathfindfollow (.+)"] = "pathfindwalkto %1",
    ["^pathfindwalktowaypoint (.+)"] = "pathfindwalktowaypoint %1", ["^pathfindwalktowp (.+)"] = "pathfindwalktowaypoint %1",
    ["^orbit (.+)"] = "orbit %1", ["^unorbit$"] = "unorbit",
    ["^stareat (.+)"] = "stareat %1", ["^stare (.+)"] = "stareat %1",
    ["^unstareat$"] = "unstareat", ["^unstare$"] = "unstareat", ["^nostare$"] = "unstareat", ["^nostareat$"] = "unstareat",
    ["^fling$"] = "fling", ["^unfling$"] = "unfling", ["^nofling$"] = "unfling", ["^togglefling$"] = "togglefling",
    ["^flyfling$"] = "flyfling", ["^unflyfling$"] = "unflyfling", ["^toggleflyfling$"] = "toggleflyfling",
    ["^walkfling$"] = "walkfling", ["^unwalkfling$"] = "unwalkfling", ["^nowalkfling$"] = "unwalkfling", ["^togglewalkfling$"] = "togglewalkfling",
    ["^invisfling$"] = "invisfling",
    ["^antifling$"] = "antifling", ["^unantifling$"] = "unantifling", ["^toggleantifling$"] = "toggleantifling",
    ["^handlekill (.+)"] = "handlekill %1", ["^hkill (.+)"] = "handlekill %1",
    ["^loopoof$"] = "loopoof", ["^unloopoof$"] = "unloopoof",
    ["^muteboombox$"] = "muteboombox", ["^unmuteboombox$"] = "unmuteboombox",
    ["^hitbox (.+)"] = "hitbox %1", ["^headsize (.+)"] = "headsize %1",
    ["^reset$"] = "reset",
    ["^freezeanims$"] = "freezeanims", ["^unfreezeanims$"] = "unfreezeanims",
    ["^respawn$"] = "respawn", ["^refresh$"] = "refresh", ["^re$"] = "refresh",
    ["^god$"] = "god", ["^permadeath$"] = "permadeath",
    ["^invisible$"] = "invisible", ["^invis$"] = "invisible",
    ["^visible$"] = "visible", ["^vis$"] = "visible", ["^uninvisible$"] = "visible",
    ["^toggleinvis$"] = "toggleinvis",
    ["^toolinvisible$"] = "toolinvisible", ["^toolinvis$"] = "toolinvisible", ["^tinvis$"] = "toolinvisible",
    ["^strengthen$"] = "strengthen", ["^weaken$"] = "weaken",
    ["^unweaken$"] = "unweaken", ["^unstrengthen$"] = "unweaken",
    ["^breakvelocity$"] = "breakvelocity",
    ["^speed (%d+)$"] = "speed %1", ["^ws (%d+)$"] = "speed %1", ["^walkspeed (%d+)$"] = "speed %1",
    ["^spoofspeed (%d+)$"] = "spoofspeed %1", ["^spoofws (%d+)$"] = "spoofspeed %1", ["^spoofwalkspeed (%d+)$"] = "spoofspeed %1",
    ["^loopspeed (%d+)$"] = "loopspeed %1", ["^loopws (%d+)$"] = "loopspeed %1",
    ["^unloopspeed$"] = "unloopspeed", ["^unloopws$"] = "unloopspeed",
    ["^jumppower (%d+)$"] = "jumppower %1", ["^jpower (%d+)$"] = "jumppower %1", ["^jp (%d+)$"] = "jumppower %1",
    ["^spoofjumppower (%d+)$"] = "spoofjumppower %1", ["^spoofjp (%d+)$"] = "spoofjumppower %1",
    ["^loopjumppower (%d+)$"] = "loopjumppower %1", ["^loopjp (%d+)$"] = "loopjumppower %1", ["^loopjpower (%d+)$"] = "loopjumppower %1",
    ["^unloopjumppower$"] = "unloopjumppower", ["^unloopjp$"] = "unloopjumppower", ["^unloopjpower$"] = "unloopjumppower",
    ["^maxslopeangle (%d+)$"] = "maxslopeangle %1", ["^msa (%d+)$"] = "maxslopeangle %1",
    ["^gravity (%d+)$"] = "gravity %1", ["^grav (%d+)$"] = "gravity %1",
    ["^hipheight (%d+)$"] = "hipheight %1", ["^hheight (%d+)$"] = "hipheight %1",
    ["^sit$"] = "sit", ["^lay$"] = "lay", ["^laydown$"] = "lay",
    ["^sitwalk$"] = "sitwalk", ["^nosit$"] = "nosit", ["^unnosit$"] = "unnosit",
    ["^jump$"] = "jump",
    ["^infjump$"] = "infjump", ["^infinitejump$"] = "infjump",
    ["^uninfjump$"] = "uninfjump", ["^uninfinitejump$"] = "uninfjump",
    ["^noinfjump$"] = "uninfjump", ["^noinfinitejump$"] = "uninfjump",
    ["^flyjump$"] = "flyjump", ["^unflyjump$"] = "unflyjump", ["^noflyjump$"] = "unflyjump",
    ["^autojump$"] = "autojump", ["^ajump$"] = "autojump",
    ["^unautojump$"] = "unautojump", ["^noautojump$"] = "unautojump",
    ["^noajump$"] = "unautojump", ["^unajump$"] = "unautojump",
    ["^edgejump$"] = "edgejump", ["^ejump$"] = "edgejump",
    ["^unedgejump$"] = "unedgejump", ["^noedgejump$"] = "unedgejump",
    ["^noejump$"] = "unedgejump", ["^unejump$"] = "unedgejump",
    ["^stun$"] = "stun", ["^platformstand$"] = "stun",
    ["^unstun$"] = "unstun", ["^nostun$"] = "unstun",
    ["^unplatformstand$"] = "unstun", ["^noplatformstand$"] = "unstun",
    ["^norotate$"] = "norotate", ["^noautorotate$"] = "norotate",
    ["^unnorotate$"] = "unnorotate", ["^autorotate$"] = "unnorotate",
    ["^enablestate (.+)"] = "enablestate %1", ["^disablestate (.+)"] = "disablestate %1",
    ["^team (.+)"] = "team %1",
    ["^nobgui$"] = "nobgui", ["^unbgui$"] = "nobgui", ["^nobillboardgui$"] = "nobgui",
    ["^unbillboardgui$"] = "nobgui", ["^noname$"] = "nobgui", ["^rohg$"] = "nobgui",
    ["^loopnobgui$"] = "loopnobgui", ["^loopunbgui$"] = "loopnobgui",
    ["^loopnobillboardgui$"] = "loopnobgui", ["^loopunbillboardgui$"] = "loopnobgui",
    ["^loopnoname$"] = "loopnobgui", ["^looprohg$"] = "loopnobgui",
    ["^unloopnobgui$"] = "unloopnobgui", ["^unloopunbgui$"] = "unloopnobgui",
    ["^unloopnobillboardgui$"] = "unloopnobgui", ["^unloopunbillboardgui$"] = "unloopnobgui",
    ["^unloopnoname$"] = "unloopnobgui", ["^unlooprohg$"] = "unloopnobgui",
    ["^noarms$"] = "noarms", ["^rarms$"] = "noarms",
    ["^nolegs$"] = "nolegs", ["^rlegs$"] = "nolegs",
    ["^nolimbs$"] = "nolimbs", ["^rlimbs$"] = "nolimbs",
    ["^naked$"] = "naked", ["^noface$"] = "noface", ["^removeface$"] = "noface",
    ["^blockhead$"] = "blockhead", ["^blockhats$"] = "blockhats", ["^blocktool$"] = "blocktool",
    ["^creeper$"] = "creeper",
    ["^drophats$"] = "drophats", ["^drophat$"] = "drophats",
    ["^deletehats$"] = "deletehats", ["^nohats$"] = "deletehats", ["^rhats$"] = "deletehats",
    ["^hatspin$"] = "hatspin", ["^spinhats$"] = "hatspin",
    ["^unhatspin$"] = "unhatspin", ["^unspinhats$"] = "unhatspin",
    ["^clearhats$"] = "clearhats", ["^cleanhats$"] = "clearhats",
    ["^spin$"] = "spin", ["^unspin$"] = "unspin",
    ["^split$"] = "split", ["^trip$"] = "trip", ["^jerk$"] = "jerk",
    ["^nilchar$"] = "nilchar", ["^unnilchar$"] = "unnilchar", ["^nonilchar$"] = "unnilchar",
    ["^noroot$"] = "noroot", ["^removeroot$"] = "noroot", ["^rroot$"] = "noroot",
    ["^replaceroot$"] = "replaceroot", ["^replacerootpart$"] = "replaceroot",
    ["^clearcharappearance$"] = "clearcharappearance", ["^clearchar$"] = "clearcharappearance", ["^clrchar$"] = "clearcharappearance",
    ["^norender$"] = "norender", ["^render$"] = "render",
    ["^2022materials$"] = "2022materials", ["^use2022materials$"] = "2022materials",
    ["^un2022materials$"] = "un2022materials", ["^unuse2022materials$"] = "un2022materials",
    ["^dance$"] = "dance", ["^undance$"] = "undance", ["^nodance$"] = "undance",
    ["^spasm$"] = "spasm", ["^unspasm$"] = "unspasm", ["^nospasm$"] = "unspasm",
    ["^headthrow$"] = "headthrow",

    -- Chat
    ["^logs$"] = "logs", ["^chatlogs$"] = "chatlogs", ["^clogs$"] = "chatlogs",
    ["^joinlogs$"] = "joinlogs", ["^jlogs$"] = "joinlogs",
    ["^chatlogswebhook (.+)"] = "chatlogswebhook %1", ["^logswebhook (.+)"] = "chatlogswebhook %1",
    ["^antichatlogs$"] = "antichatlogs", ["^antichatlogger$"] = "antichatlogs",
    ["^chat (.+)"] = "chat %1", ["^say (.+)"] = "chat %1",
    ["^spam (.+)"] = "spam %1", ["^nospam$"] = "nospam", ["^unspam$"] = "nospam",
    ["^whisper (.+)"] = "whisper %1", ["^pm (.+)"] = "whisper %1",
    ["^pmspam (.+)"] = "pmspam %1", ["^nopmspam$"] = "nopmspam", ["^unpmspam$"] = "nopmspam",
    ["^spamspeed (%d+)"] = "spamspeed %1",
    ["^bubblechat$"] = "bubblechat", ["^unbubblechat$"] = "unbubblechat", ["^nobubblechat$"] = "unbubblechat",
    ["^chatwindow$"] = "chatwindow", ["^unchatwindow$"] = "unchatwindow", ["^nochatwindow$"] = "unchatwindow",

    -- Workspace
    ["^btools$"] = "btools", ["^f3x$"] = "f3x", ["^fex$"] = "f3x",
    ["^delete (.+)"] = "delete %1", ["^remove (.+)"] = "delete %1",
    ["^deleteclass (.+)"] = "deleteclass %1", ["^removeclass (.+)"] = "deleteclass %1",
    ["^deleteclassname (.+)"] = "deleteclass %1", ["^removeclassname (.+)"] = "deleteclass %1", ["^dc (.+)"] = "deleteclass %1",
    ["^chardelete (.+)"] = "chardelete %1", ["^charremove (.+)"] = "chardelete %1", ["^cd (.+)"] = "chardelete %1",
    ["^chardeleteclass (.+)"] = "chardeleteclass %1", ["^charremoveclass (.+)"] = "chardeleteclass %1",
    ["^chardeleteclassname (.+)"] = "chardeleteclass %1", ["^charremoveclassname (.+)"] = "chardeleteclass %1", ["^cdc (.+)"] = "chardeleteclass %1",
    ["^deletevelocity$"] = "deletevelocity", ["^dv$"] = "deletevelocity",
    ["^removevelocity$"] = "deletevelocity", ["^removeforces$"] = "deletevelocity",
    ["^deleteinvisparts$"] = "deleteinvisparts", ["^deleteinvisibleparts$"] = "deleteinvisparts", ["^dip$"] = "deleteinvisparts",
    ["^invisibleparts$"] = "invisibleparts", ["^invisparts$"] = "invisibleparts",
    ["^uninvisibleparts$"] = "uninvisibleparts", ["^uninvisparts$"] = "uninvisibleparts",
    ["^lockworkspace$"] = "lockworkspace", ["^lockws$"] = "lockworkspace",
    ["^unlockworkspace$"] = "unlockworkspace", ["^unlockws$"] = "unlockworkspace",
    ["^gotopart (.+)"] = "gotopart %1", ["^topart (.+)"] = "gotopart %1",
    ["^tweengotopart (.+)"] = "tweengotopart %1", ["^tgotopart (.+)"] = "tweengotopart %1", ["^ttopart (.+)"] = "tweengotopart %1",
    ["^bringpart (.+)"] = "bringpart %1",
    ["^bringpartclass (.+)"] = "bringpartclass %1", ["^bpc (.+)"] = "bringpartclass %1",
    ["^gotopartclass (.+)"] = "gotopartclass %1", ["^gpc (.+)"] = "gotopartclass %1",
    ["^tweengotopartclass (.+)"] = "tweengotopartclass %1", ["^tgpc (.+)"] = "tweengotopartclass %1",
    ["^gotomodel (.+)"] = "gotomodel %1", ["^tomodel (.+)"] = "gotomodel %1",
    ["^tweengotomodel (.+)"] = "tweengotomodel %1", ["^tgotomodel (.+)"] = "tweengotomodel %1", ["^ttomodel (.+)"] = "tweengotomodel %1",
    ["^gotopartdelay (%d+)"] = "gotopartdelay %1",
    ["^fireclickdetectors$"] = "fireclickdetectors", ["^firecd$"] = "fireclickdetectors", ["^firecds$"] = "fireclickdetectors",
    ["^noclickdetectorlimits$"] = "noclickdetectorlimits", ["^nocdlimits$"] = "noclickdetectorlimits", ["^removecdlimits$"] = "noclickdetectorlimits",
    ["^fireproximityprompts$"] = "fireproximityprompts", ["^firepp$"] = "fireproximityprompts",
    ["^noproximitypromptlimits$"] = "noproximitypromptlimits", ["^nopplimits$"] = "noproximitypromptlimits", ["^removepplimits$"] = "noproximitypromptlimits",
    ["^instantproximityprompts$"] = "instantproximityprompts", ["^instantpp$"] = "instantproximityprompts",
    ["^uninstantproximityprompts$"] = "uninstantproximityprompts", ["^uninstantpp$"] = "uninstantproximityprompts",
    ["^firetouchinterests$"] = "firetouchinterests", ["^touchinterests$"] = "firetouchinterests",
    ["^touchinterest$"] = "firetouchinterests", ["^firetouchinterest$"] = "firetouchinterests",
    ["^removeterrain$"] = "removeterrain", ["^rterrain$"] = "removeterrain", ["^noterrain$"] = "removeterrain",
    ["^destroyheight (%d+)"] = "destroyheight %1", ["^dh (%d+)"] = "destroyheight %1",
    ["^antivoid$"] = "antivoid", ["^unantivoid$"] = "unantivoid", ["^noantivoid$"] = "unantivoid",
    ["^clearnilinstances$"] = "clearnilinstances", ["^nonilinstances$"] = "clearnilinstances", ["^cni$"] = "clearnilinstances",
    ["^freeze (.+)"] = "freeze %1", ["^fr (.+)"] = "freeze %1",
    ["^thaw (.+)"] = "thaw %1", ["^unfreeze (.+)"] = "thaw %1", ["^unfr (.+)"] = "thaw %1",
    ["^anchor$"] = "anchor", ["^unanchor$"] = "unanchor",
    ["^freezeunanchored$"] = "freezeunanchored", ["^freezeua$"] = "freezeunanchored",
    ["^thawunanchored$"] = "thawunanchored", ["^thawua$"] = "thawunanchored",
    ["^unfreezeunanchored$"] = "thawunanchored", ["^unfreezeua$"] = "thawunanchored",
    ["^tpunanchored$"] = "tpunanchored", ["^tpua$"] = "tpunanchored",

    -- Animation
    ["^animation (.+)"] = "animation %1", ["^anim (.+)"] = "animation %1",
    ["^emote (.+)"] = "emote %1", ["^em (.+)"] = "emote %1",
    ["^noanim$"] = "noanim", ["^reanim$"] = "reanim",
    ["^animspeed (%d+)"] = "animspeed %1",
    ["^copyanimation (.+)"] = "copyanimation %1", ["^copyanim (.+)"] = "copyanimation %1", ["^copyemote (.+)"] = "copyanimation %1",
    ["^copyanimationid (.+)"] = "copyanimationid %1", ["^copyanimid (.+)"] = "copyanimationid %1", ["^copyemoteid (.+)"] = "copyanimationid %1",
    ["^stopanimations$"] = "stopanimations", ["^stopanims$"] = "stopanimations", ["^stopanim$"] = "stopanimations",
    ["^refreshanimations$"] = "refreshanimations", ["^refreshanimation$"] = "refreshanimations",
    ["^refreshanims$"] = "refreshanimations", ["^refreshanim$"] = "refreshanimations",
    ["^allowcustomanim$"] = "allowcustomanim", ["^allowcustomanimations$"] = "allowcustomanim",
    ["^unallowcustomanim$"] = "unallowcustomanim", ["^unallowcustomanimations$"] = "unallowcustomanim",
    ["^loopanimation (.+)"] = "loopanimation %1", ["^loopanim (.+)"] = "loopanimation %1",

    -- Tools
    ["^autoclick$"] = "autoclick", ["^unautoclick$"] = "unautoclick", ["^noautoclick$"] = "unautoclick",
    ["^mousesensitivity (%d+)"] = "mousesensitivity %1", ["^ms (%d+)"] = "mousesensitivity %1",
    ["^tools$"] = "tools", ["^gears$"] = "tools",
    ["^notools$"] = "notools", ["^rtools$"] = "notools", ["^clrtools$"] = "notools",
    ["^removetools$"] = "notools", ["^deletetools$"] = "notools", ["^dtools$"] = "notools",
    ["^deleteselectedtool$"] = "deleteselectedtool", ["^dst$"] = "deleteselectedtool",
    ["^grabtools$"] = "grabtools", ["^nograbtools$"] = "nograbtools", ["^ungrabtools$"] = "nograbtools",
    ["^equiptools$"] = "equiptools", ["^unequiptools$"] = "unequiptools",
    ["^reach (%d+)"] = "reach %1", ["^boxreach (%d+)"] = "boxreach %1",
    ["^unreach$"] = "unreach", ["^noreach$"] = "unreach", ["^unboxreach$"] = "unreach",
    ["^dupetools (%d+)"] = "dupetools %1", ["^clonetools (%d+)"] = "dupetools %1",
    ["^droppabletools$"] = "droppabletools",
    ["^droptools$"] = "droptools", ["^droptool$"] = "droptools",
    ["^removespecifictool (.+)"] = "removespecifictool %1",
    ["^unremovespecifictool$"] = "unremovespecifictool",
    ["^clearremovespecifictool$"] = "clearremovespecifictool",
    ["^copytools$"] = "copytools", ["^usetools$"] = "usetools",
    ["^grippos (.+)"] = "grippos %1",

    -- Server
    ["^serverinfo$"] = "serverinfo", ["^info$"] = "serverinfo", ["^sinfo$"] = "serverinfo",
    ["^jobid$"] = "jobid", ["^notifyjobid$"] = "notifyjobid",
    ["^rejoin$"] = "rejoin", ["^rj$"] = "rejoin",
    ["^autorejoin$"] = "autorejoin", ["^autorj$"] = "autorejoin",
    ["^serverhop$"] = "serverhop", ["^shop$"] = "serverhop",
    ["^gametp (.+)"] = "gametp %1", ["^gameteleport (.+)"] = "gametp %1",
    ["^exit$"] = "exit",
    ["^notifyping$"] = "notifyping", ["^ping$"] = "notifyping",

    -- Advanced
    ["^fakeout$"] = "fakeout", ["^scare$"] = "scare", ["^spook$"] = "scare",
    ["^alignmentkeys$"] = "alignmentkeys",
    ["^unalignmentkeys$"] = "unalignmentkeys", ["^noalignmentkeys$"] = "unalignmentkeys",
    ["^ctrllock$"] = "ctrllock", ["^unctrllock$"] = "unctrllock",
    ["^listento (.+)"] = "listento %1", ["^unlistento$"] = "unlistento",
    ["^muteallvoices$"] = "muteallvoices", ["^muteallvcs$"] = "muteallvoices",
    ["^unmuteallvoices$"] = "unmuteallvoices", ["^unmuteallvcs$"] = "unmuteallvoices",
    ["^mutevc (.+)"] = "mutevc %1", ["^unmutevc (.+)"] = "unmutevc %1",
    ["^phonebook$"] = "phonebook", ["^call$"] = "phonebook",
    ["^autokeypress (.+)"] = "autokeypress %1", ["^keypress (.+)"] = "autokeypress %1",
    ["^unautokeypress$"] = "unautokeypress", ["^noautokeypress$"] = "unautokeypress",
    ["^unkeypress$"] = "unautokeypress", ["^nokeypress$"] = "unautokeypress",
    ["^rolewatch (.+)"] = "rolewatch %1", ["^rolewatchstop$"] = "rolewatchstop",
    ["^rolewatchleave$"] = "rolewatchleave", ["^unrolewatch$"] = "rolewatchleave",
    ["^staffwatch$"] = "staffwatch", ["^unstaffwatch$"] = "unstaffwatch",
    ["^removeads$"] = "removeads", ["^adblock$"] = "removeads",
    
    -- Additional missing commands
    ["^antiafk$"] = "antiafk", ["^antiidle$"] = "antiafk",
    ["^rec$"] = "rec", ["^record$"] = "rec",
    ["^teleportwalk (%d+)$"] = "teleportwalk %1", ["^tpwalk (%d+)$"] = "teleportwalk %1",
    ["^unteleportwalk$"] = "unteleportwalk", ["^untpwalk$"] = "unteleportwalk",
    ["^togglefs$"] = "togglefs", ["^togglefullscreen$"] = "togglefs",
    ["^tptool$"] = "tptool", ["^teleporttool$"] = "tptool",
    ["^unglobalshadows$"] = "unglobalshadows", ["^nogshadows$"] = "unglobalshadows",
    ["^ungshadows$"] = "unglobalshadows", ["^noglobalshadows$"] = "unglobalshadows",
    ["^unlight$"] = "unlight", ["^nolight$"] = "unlight",
    ["^view (.+)$"] = "view %1", ["^spectate (.+)$"] = "view %1",
    ["^unview$"] = "unview", ["^unspectate$"] = "unview",
    ["^unwalltp$"] = "unwalltp", ["^nowalltp$"] = "unwalltp",
    ["^unxray$"] = "unxray", ["^noxray$"] = "unxray",
    ["^vfly$"] = "vfly", ["^vehiclefly$"] = "vfly",
    ["^vflyspeed (%d+)$"] = "vflyspeed %1", ["^vflysp (%d+)$"] = "vflyspeed %1",
    ["^vehicleflyspeed (%d+)$"] = "vflyspeed %1", ["^vehicleflysp (%d+)$"] = "vflyspeed %1",
    ["^copyid (.+)$"] = "copyid %1", ["^copyuserid (.+)$"] = "copyid %1"
}

-- Convert FastMap to OrderedFastMap for deterministic matching
-- Sorted by pattern length (descending) so specific patterns match before generic ones
-- v1.3.3: Optimized FastMap with Indexing
-- Groups patterns by their starting character for O(1) group lookup
local OrderedFastMap = {}
local FastMapIndex = {}
local FastMapMisc = {} -- Fallback for patterns not starting with ^

do
    for pattern, command in pairs(FastMap) do
        local entry = { Pattern = pattern, Command = command }
        
        -- Categorize by first character if anchor is present
        if pattern:sub(1,1) == "^" then
            local firstChar = pattern:sub(2,2):lower()
            if not FastMapIndex[firstChar] then
                FastMapIndex[firstChar] = {}
            end
            table.insert(FastMapIndex[firstChar], entry)
        else
            table.insert(FastMapMisc, entry)
        end
        
        -- Keep master list for fallback/iterating
        table.insert(OrderedFastMap, entry)
    end

    -- Helper to sort entries by length descending (specificity)
    local function sortEntries(t)
        table.sort(t, function(a, b) return #a.Pattern > #b.Pattern end)
    end

    -- Sort all lists
    sortEntries(OrderedFastMap)
    sortEntries(FastMapMisc)
    for _, list in pairs(FastMapIndex) do
        sortEntries(list)
    end
end

local Priority = {
    fly = 100, unfly = 100, noclip = 100, clip = 100,
    speed = 95, ws = 95, jpower = 95, jumppower = 95, jp = 95,
    ["goto"] = 90, tp = 90, bring = 90,
    handlekill = 80, hkill = 80, fling = 80,
    esp = 75, noesp = 75, xray = 75, view = 75, spectate = 75,
    btools = 70, f3x = 70, dex = 70, explorer = 70,
    rejoin = 50, serverhop = 50, console = 50, reset = 50
}

local TargetTriggers = {
    "handlekill", "hkill", "fling", "goto", "tp", "view", "spectate",
    "bring", "clientbring", "cbring", "bang", "freeze", "thaw",
    "follow", "walkto", "headsit", "loopgoto", "loopbring"
}

--// ============================================
--// 13. FUN MESSAGES & PERSONALITY
--// ============================================
local FunMessages = {
    Ready = {
        "Ready to roll!",
        "Awaiting orders...",
        "What's the play?",
        "Standing by...",
        "At your service!",
        "Ready when you are!",
        "Locked and loaded!",
        "What shall we do?",
        "Your wish is my command",
        "Let's make magic happen"
    },
    Thinking = {
        "Thinking...",
        "Processing...",
        "Consulting the AI...",
        "Working on it...",
        "Brain loading...",
        "Computing...",
        "Analyzing request...",
        "One moment..."
    },
    Success = {
        "Done!",
        "Executed!",
        "Got it!",
        "Success!",
        "Nailed it!",
        "Easy peasy!",
        "Mission complete!",
        "There you go!"
    },
    CacheHit = {
        "Instant! Remembered this one",
        "From memory - lightning fast!",
        "Cache hit! No AI needed",
        "Already knew that one!",
        "Instant recall!",
        "Memory served!"
    },
    FastExec = {
        "Instant execution!",
        "Lightning fast!",
        "No AI needed!",
        "Direct hit!",
        "Speed demon!"
    },
    Error = {
        "Oops! Something went wrong",
        "Hmm, that didn't work",
        "Error encountered",
        "Let's try that again",
        "Hit a snag there"
    },
    Tips = {
        "Tip: Use 'clearcache' to reset learned commands",
        "Tip: Right Shift toggles the menu",
        "Tip: Try 'bind f fly' for quick toggles",
        "Tip: Partial names work! 'goto jo' finds John",
        "Tip: Switch to CHAT mode for game advice",
        "Tip: Type naturally - I understand you!",
        "Tip: Quick Actions (⚡) for one-tap commands"
    }
}

local function getRandomMessage(category)
    local messages = FunMessages[category]
    if messages then
        return messages[math.random(1, #messages)]
    end
    return category
end

--// ============================================
--// 14. LOGIC ENGINE - FUNCTIONS
--// ============================================
local function updateStatus(text, color, useRandom)
    local displayText = text
    if useRandom and FunMessages[text] then
        displayText = getRandomMessage(text)
    end
    StatusLabel.Text = ">> " .. displayText
    StatusLabel.TextColor3 = color or Colors.Status
    StatusLabel.TextTransparency = 0
    
    -- In compact CMD mode, show status temporarily then hide
    if not IS_CHAT_MODE then
        StatusLabel.Visible = true
        -- Expand frame temporarily to show status
        TweenService:Create(MainFrame, TweenInfo.new(0.15), {
            Size = IsMobile and UDim2.new(0.9, 0, 0, 80) or UDim2.new(0, 420, 0, 80)
        }):Play()
        
        task.delay(2.5, function()
            if not IS_CHAT_MODE then
                TweenService:Create(StatusLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                TweenService:Create(MainFrame, TweenInfo.new(0.2), {
                    Size = BaseMainSize
                }):Play()
                task.delay(0.3, function()
                    if not IS_CHAT_MODE then
                        StatusLabel.Visible = false
                    end
                end)
            end
        end)
    else
        TweenService:Create(StatusLabel, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 0.6}):Play()
    end
end

-- EventBus listener for SHOW_NOTIFICATION (used for bridge failures and other system messages)
EventBus:on("SHOW_NOTIFICATION", function(data)
    if data and data.title and data.message then
        updateStatus(data.title .. ": " .. data.message, Colors.Red, false)
    end
end)

--- Gets comma-separated list of all player names
--- @return string -- Player names joined by commas
local function getPlayerList()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(names, player.Name)
    end
    return table.concat(names, ", ")
end

--- Checks if text references a player target requiring context injection
--- @param text string -- Text to check for player references
--- @return boolean -- True if player context should be injected
local function needsPlayerContext(text)
    local lowerText = text:lower()
    for _, trigger in ipairs(TargetTriggers) do
        if lowerText:find("%f[%w]" .. trigger .. "%f[%W]") then return true end
    end

    if lowerText:find("%f[%w]me%f[%W]") or lowerText:find("%f[%w]random%f[%W]") then
        return true
    end

    for _, player in ipairs(Players:GetPlayers()) do
        local name = player.Name:lower()
        local displayName = player.DisplayName:lower()

        if lowerText:find("%f[%w]" .. name .. "%f[%W]") or lowerText:find("%f[%w]" .. displayName .. "%f[%W]") then
            return true
        end
    end
    return false
end

--// Levenshtein Distance for Fuzzy Matching
local levRowA: {number} = {}
local levRowB: {number} = {}

--- Ensures row array has at least 'size' elements
--- @param row {number} -- Row array to resize
--- @param size number -- Required minimum size
local function ensureRowSize(row: {number}, size: number): nil
    if #row < size then
        for i = #row + 1, size do
            row[i] = 0
        end
    end
    return nil
end

--- Calculates Levenshtein edit distance between two strings with optimization
--- @param s1 string -- First string
--- @param s2 string -- Second string
--- @param maxDist number? -- Optional: max distance to check before giving up (optimization)
--- @return number -- Edit distance (or maxDist + 1 if exceeded)
local function levenshteinDistance(s1: string, s2: string, maxDist: number?): number
    local len1, len2 = #s1, #s2
    if len1 == 0 then return len2 end
    if len2 == 0 then return len1 end
    
    -- Optimization: Length difference check
    if math.abs(len1 - len2) > (maxDist or math.huge) then
        return (maxDist or 0) + 1
    end

    -- Ensure s2 is the longer string to minimize memory
    if len1 > len2 then
        s1, s2 = s2, s1
        len1, len2 = len2, len1
    end
    local lower1, lower2 = s1:lower(), s2:lower()

    table.clear(levRowA)
    table.clear(levRowB)
    ensureRowSize(levRowA, len2 + 1)
    ensureRowSize(levRowB, len2 + 1)

    local previous = levRowA
    local current = levRowB

    for j = 0, len2 do
        previous[j + 1] = j
    end

    for i = 1, len1 do
        current[1] = i
        local c1 = lower1:byte(i)
        
        -- Optimization: Track minimum distance in current row
        local minRowDist = maxDist and current[1] or 0

        for j = 1, len2 do
            local cost = (c1 == lower2:byte(j)) and 0 or 1
            local insertion = current[j] + 1
            local deletion = previous[j + 1] + 1
            local substitution = previous[j] + cost
            local dist = math.min(insertion, deletion, substitution)
            current[j + 1] = dist
            
            if maxDist and dist < minRowDist then
                minRowDist = dist
            end
        end
        
        -- Optimization: Early exit if entire row exceeds max distance
        if maxDist and minRowDist > maxDist then
            return maxDist + 1
        end

        previous, current = current, previous
    end

    return previous[len2 + 1]
end

--- Fuzzy matches a partial name to a player in the server
--- @param partial string? -- Partial player name to match
--- @return string? -- Matched player name or nil
local function fuzzyMatchPlayer(partial: string?): string?
    if not partial or partial == "" then return nil end
    
    local partialLower = partial:lower()
    local partialLength = #partial
    
    -- Prevent false positives with very short inputs
    -- Short names (1-2 chars) require exact prefix match only
    local requireExactPrefix = partialLength < CONFIG.FuzzyMatchMinInputLength
    
    local bestMatch, bestScore = nil, math.huge
    local exactPrefixMatch = nil
    
    -- Dynamic threshold based on input length
    -- Shorter inputs get stricter thresholds to prevent false positives
    local threshold
    if partialLength <= 2 then
        threshold = 0 -- Exact match only for very short inputs
    elseif partialLength <= 4 then
        threshold = 1 -- Allow 1 edit for short inputs
    else
        threshold = math.max(CONFIG.FuzzyMatchMinThreshold, math.floor(partialLength * CONFIG.FuzzyMatchRatio))
    end
    
    -- Cache player list once for efficiency
    local players = Players:GetPlayers()
    
    for _, player in ipairs(players) do
        local name = player.Name:lower()
        local displayName = player.DisplayName:lower()
        
        -- Exact prefix match (highest priority) - always check this first
        if name:sub(1, partialLength) == partialLower then
            -- For short inputs, prefer exact prefix matches
            if requireExactPrefix or not exactPrefixMatch then
                exactPrefixMatch = player.Name
            end
            -- If exact match on full name, return immediately
            if name == partialLower then return player.Name end
        end
        if displayName:sub(1, partialLength) == partialLower then
            if requireExactPrefix or not exactPrefixMatch then
                exactPrefixMatch = player.Name
            end
            if displayName == partialLower then return player.Name end
        end
        
        -- Skip fuzzy matching for very short inputs
        if requireExactPrefix then
            -- Only allow contains match for short inputs
            if name:find(partialLower, 1, true) then
                exactPrefixMatch = exactPrefixMatch or player.Name
            end
            if displayName:find(partialLower, 1, true) then
                exactPrefixMatch = exactPrefixMatch or player.Name
            end
        else
            -- Calculate Levenshtein distances with optimization (maxDist = threshold)
            local nameScore = levenshteinDistance(partialLower, name, threshold)
            local displayScore = levenshteinDistance(partialLower, displayName, threshold)
            
            -- Contains match with pre-calculated score
            if name:find(partialLower, 1, true) and nameScore < bestScore then
                bestScore = nameScore
                bestMatch = player.Name
            end
            
            if displayName:find(partialLower, 1, true) and displayScore < bestScore then
                bestScore = displayScore
                bestMatch = player.Name
            end
            
            -- Fuzzy match using pre-calculated scores
            local minScore = math.min(nameScore, displayScore)
            if minScore <= threshold and minScore < bestScore then
                bestScore = minScore
                bestMatch = player.Name
            end
        end
    end
    
    -- Prefer exact prefix match over fuzzy match
    return exactPrefixMatch or bestMatch
end

local function resolveTarget(cmdString)
    -- Reject "all" / "everyone"
    if cmdString:match("%sall$") or cmdString:match("%severyone$") then
        return nil, "Target 'all' is invalid. Please specify a player."
    end

    -- Handle "me"
    if cmdString:match("%sme$") or cmdString:match("%sme%s") then
        local myName = LocalPlayer.Name
        cmdString = cmdString:gsub("%sme$", " " .. myName):gsub("%sme%s", " " .. myName .. " ")
    end

    -- Handle "random"
    if cmdString:match("%srandom$") or cmdString:match("%srandom%s") then
        local otherPlayers = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(otherPlayers, p.Name) end
        end
        
        if #otherPlayers > 0 then
            local randomName = otherPlayers[math.random(1, #otherPlayers)]
            cmdString = cmdString:gsub("%srandom$", " " .. randomName):gsub("%srandom%s", " " .. randomName .. " ")
            updateStatus("Targeting Random: " .. randomName, Colors.Orange)
        else
            return nil, "No other players to target."
        end
    end
    
    -- Fuzzy Player Name Resolution
    local cmdParts = cmdString:split(" ")
    if #cmdParts >= 2 then
        local potentialTarget = cmdParts[#cmdParts]
        
        if not tonumber(potentialTarget) and potentialTarget ~= "me" and potentialTarget ~= "random" then
            local fuzzyMatch = fuzzyMatchPlayer(potentialTarget)
            
            if fuzzyMatch and fuzzyMatch:lower() ~= potentialTarget:lower() then
                cmdParts[#cmdParts] = fuzzyMatch
                cmdString = table.concat(cmdParts, " ")
                updateStatus("Fuzzy Match: " .. potentialTarget .. " → " .. fuzzyMatch, Colors.Purple)
            end
        end
    end

    return cmdString, nil
end

--// ============================================
--// 14. BRIDGE EXECUTION
--// ============================================
local function executeBridge(text, source)
    -- Validate input
    if not text or type(text) ~= "string" or text == "" then
        warn("SIY: Invalid command text")
        return
    end
    
    -- Ensure bridge is connected
    if not IY_Interface then
        if not waitForBridge(CONFIG.BridgeTimeout, CONFIG.BridgeMaxRetries) then
            warn("SIY: Bridge not connected after retries.")
            updateStatus("Error: Bridge Failed - Retrying...", Colors.Red)
            return
        end
    end
    
    -- Verify bridge interface has Exec function
    if not IY_Interface or not IY_Interface.Exec then
        warn("SIY: Bridge interface invalid")
        updateStatus("Error: Bridge Interface Invalid", Colors.Red)
        return
    end
    
    local cleanText = trim(text)
    
    if IS_CHAT_MODE then
        local safeText = cleanText:gsub("'", ""):gsub('"', '')
        IY_Interface.Exec("notify " .. safeText)
        updateStatus("[AI] Response Sent", Colors.Blue)
    else
        -- Remove initial semicolon
        if cleanText:sub(1, 1) == ";" then cleanText = cleanText:sub(2) end
        
        -- Help Command
        if cleanText == "help" then
            IY_Interface.Exec("notify Check Status Bar for help.")
            updateStatus("CMD: ;bind [key] [cmd], RightShift=Toggle", Colors.Green)
            return
        end

        -- Cache Management Commands
        if cleanText == "clearcache" then
            clearCache()
            IY_Interface.Exec("notify Cache cleared successfully!")
            updateStatus("Cache Cleared - All learned commands removed", Colors.Green)
            return
        end
        
        if cleanText == "cacheinfo" then
            local count, max = getCacheInfo()
            local message = string.format("Cache: %d/%d commands stored", count, max)
            IY_Interface.Exec("notify " .. message)
            updateStatus(message, Colors.Purple)
            return
        end



        -- Bind Commands
        local bindKey, bindCmd = cleanText:match("^bind (%w+) (.+)")
        if bindKey and bindCmd then
            local keyLower = bindKey:lower()
            local opposite = ToggleMap[bindCmd]
            if opposite then
                BindSystem[keyLower] = {Current = bindCmd, Next = opposite}
                updateStatus("Bound '" .. bindKey .. "' to Toggle (" .. bindCmd .. "/" .. opposite .. ")", Colors.Green)
            else
                BindSystem[keyLower] = {Current = bindCmd, Next = nil}
                updateStatus("Bound '" .. bindKey .. "' to '" .. bindCmd .. "'", Colors.Green)
            end
            return
        end
        
        local unbindKey = cleanText:match("^unbind (%w+)")
        if unbindKey then
            BindSystem[unbindKey:lower()] = nil
            updateStatus("Unbound '" .. unbindKey .. "'", Colors.Green)
            return
        end
        
        -- Chain Execution
        local commands = cleanText:split(";")
        
        task.spawn(function()
            for _, rawCmd in ipairs(commands) do
                local cmd = trim(rawCmd)
                if cmd ~= "" then
                    local finalCmd, err = resolveTarget(cmd)
                    
                    if finalCmd then
                        local prefix = source and ("[" .. source .. "] ") or ""
                        showPreview(finalCmd)
                        
                        if #commands > 1 then
                            updateStatus("Chain: " .. finalCmd, Colors.Green)
                        else
                            updateStatus(prefix .. "Exec: " .. finalCmd, Colors.Green)
                        end
                        
                        IY_Interface.Exec(finalCmd)
                        if #commands > 1 then task.wait(0.1) end
                    else
                        updateStatus("Error: " .. (err or "Invalid Cmd"), Colors.Red)
                    end
                end
            end
        end)
    end
end

--// ============================================
--// 15. VISUAL STATE MANAGEMENT
--// ============================================
local function resetVisuals(showTip)
    stopGlowAnimation()
    TweenService:Create(MainStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
    InputBox.TextEditable = true
    InputBox.PlaceholderColor3 = Colors.TextDim
    InputBox.PlaceholderText = IS_CHAT_MODE and "Chat mode (history on) - ask or chain follow-ups..." or (IsMobile and "What do you want to do?" or "Tell me what to do...")
    hidePreview()
    
    -- Show random tip or ready message occasionally
    if showTip and math.random(1, 4) == 1 then
        task.delay(0.5, function()
            updateStatus("Tips", Colors.TextDim, true)
        end)
    end
end

local function setThinkingState(retry)
    startGlowAnimation()
    InputBox.TextEditable = false
    InputBox.PlaceholderText = retry and "Retrying transcript..." or (IS_CHAT_MODE and "Thinking with history..." or "Thinking...")
    InputBox.PlaceholderColor3 = retry and Colors.Orange or Colors.Green
    TweenService:Create(MainStroke, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0}):Play()
end

--// ============================================
--// 16. AI QUERY SYSTEM
--// ============================================
local lastAIRequestTime = 0

local function queryAI(promptText, retryContext, attemptCount)
    -- Sanitize input for security
    promptText = sanitizeInput(promptText)
    if promptText == "" then return end

    -- Rate limiting for AI requests
    local currentTime = tick()
    if not retryContext and (currentTime - lastAIRequestTime) < CONFIG.AIRequestCooldown then
        updateStatus("Please wait...", Colors.Orange)
        return
    end

    -- Log chat requests after passing rate limits (CHAT mode only)
    if IS_CHAT_MODE and not retryContext then
        appendChatLog("user", promptText)
    end
    
    -- Fast Path (Non-AI)
    if not IS_CHAT_MODE and not retryContext then
        -- v1.3.3: Direct utility commands - intercept before any AI processing
        local cleanedPrompt = normalizeInput(promptText):gsub("^;", "")
        if cleanedPrompt == "clearcache" then
            clearCache()
            updateStatus("Cache Cleared - All learned commands removed", Colors.Green)
            resetVisuals()
            InputBox.Text = ""
            return
        end
        if cleanedPrompt == "cacheinfo" then
            local count, max = getCacheInfo()
            updateStatus(string.format("Cache: %d/%d commands stored", count, max), Colors.Purple)
            resetVisuals()
            InputBox.Text = ""
            return
        end
        
        -- Manual chain execution
        if promptText:find(";") then
            executeBridge(promptText, "MANUAL")
            resetVisuals()
            InputBox.Text = ""
            return
        end

        local cleanPrompt = normalizeInput(promptText):gsub("^;", "")

        -- Cache lookup
        local cached = getCachedCommand(cleanPrompt)
        if cached then
            updateStatus("CacheHit", Colors.Purple, true)
            showPreview(cached.command)
            executeBridge(cached.command, "CACHE")
            resetVisuals(true)
            InputBox.Text = ""
            return
        end

        -- Chain detection
        local isChain = cleanPrompt:find(" and ") or cleanPrompt:find(" & ") or cleanPrompt:find(" then ")
        
        if not isChain then
            -- First try: Dynamic command lookup (from IY's actual cmds table)
            if DynamicMapBuilt then
                local parts = cleanPrompt:split(" ")
                local baseCmdName = parts[1]:lower()
                local cmdInfo = getDynamicCommand(baseCmdName)
                if cmdInfo then
                    -- Command exists in IY's dynamic map - execute directly
                    showPreview(cleanPrompt)
                    executeBridge(cleanPrompt, "DYNAMIC")
                    resetVisuals(true)
                    InputBox.Text = ""
                    return
                end
            end
            
            -- Second try: Optimized FastMap lookup
            -- v1.3.3: Use index for performance (check matching char group first)
            local firstChar = cleanPrompt:sub(1,1):lower()
            local targetList = FastMapIndex[firstChar] or FastMapMisc
            
            -- If we have a specific list, check it. If no match found (or list empty),
            -- we might need to check Misc (though logic suggests if it starts with 'x' it must be in 'x' or Misc)
            
            local function checkList(list)
                for _, entry in ipairs(list) do
                    -- Clean prompt match
                    local _, _, capture, capture2 = cleanPrompt:find(entry.Pattern)
                    if _ then
                        local finalCmd = entry.Command
                        if capture then finalCmd = finalCmd:gsub("%%1", capture) end
                        if capture2 then finalCmd = finalCmd:gsub("%%2", capture2) end
                        
                        showPreview(finalCmd)
                        executeBridge(finalCmd, "FAST")
                        resetVisuals(true)
                        InputBox.Text = ""
                        return true
                    end
                end
                return false
            end
            
            -- Checks: 1. Indexed Group, 2. Misc Group
            if checkList(targetList) then return end
            if targetList ~= FastMapMisc and checkList(FastMapMisc) then return end
        end
    end

    if not httpRequest then
        warn("SIY: HTTP requests unavailable - cannot reach AI endpoint.")
        updateStatus("HTTP not supported by executor", Colors.Red)
        return
    end

    -- AI Path
    lastAIRequestTime = tick() -- Update rate limit timestamp
    setThinkingState(false)
    updateStatus("Thinking", Colors.Orange, true)
    
    -- v1.3.0: Emit event for acoustic feedback
    EventBus:emit("AI_REQUEST_START")

    local messagesPayload = {}
    -- Only include volatile player context when targeting is detected to keep cache keys stable
    local targetDetected = needsPlayerContext(promptText)
    
    if IS_CHAT_MODE then
        -- Get auto-injected game context
        local gameContext = formatContextForAI()
        local displayName = (GameName ~= "Loading...") and GameName or "Unknown Game"
        local genreHint = GameGenre and GameGenre ~= "General" and string.format(" (%s game)", GameGenre) or ""
        
        -- SANITIZED PROMPT with enhanced auto-context injection
        local dynamicContext = string.format([[
[SYSTEM CONFIGURATION]
You are a friendly and engaging gaming companion.
You are currently playing "%s" with your friend "%s".

Mirror the user's personality or be enthusiastic.
Keep responses short, casual, and fun.
DO NOT act like a robot or an assistant. Act like a real player in the game.

If asked about yourself: You are a fellow player just chilling.
If asked about the game: Use the provided game name to sound contextual.
]], displayName, LocalPlayer.DisplayName)
        
        table.insert(messagesPayload, {role = "system", content = dynamicContext})
        -- Rolling transcript (last 6 exchanges) for continuity
        for _, historyMsg in ipairs(getChatHistorySnapshot()) do
            table.insert(messagesPayload, {
                role = historyMsg.role,
                content = historyMsg.content
            })
        end
    else
        -- Static prompt first (for token caching - needs 1024+ tokens)
        table.insert(messagesPayload, {role = "system", content = CONFIG.CommandPrompt})
        
        -- Target-smart context: only add player list when targeting cues are detected
        if targetDetected then
            table.insert(messagesPayload, {role = "system", content = "Players: " .. getPlayerList()})
        end
        
        -- Add minimal game context for better command understanding
        local minimalContext = string.format("[Context: %s]", formatContextForAI())
        table.insert(messagesPayload, {role = "system", content = minimalContext})
    end

    table.insert(messagesPayload, {role = "user", content = promptText})
    if IS_CHAT_MODE and not retryContext then
        recordChatMessage("user", promptText)
    end

    local body = HttpService:JSONEncode({
        model = CONFIG.Model,
        messages = messagesPayload,
        temperature = IS_CHAT_MODE and 0.95 or 0.1
    })

    local headers = {
        ["Content-Type"] = "application/json"
    }

    local apiKey = CONFIG.ApiKey
    if apiKey and type(apiKey) == "string" then
        local trimmedKey = trim(apiKey)
        if trimmedKey ~= "" and trimmedKey:lower() ~= "null" then
            headers["Authorization"] = "Bearer " .. trimmedKey
        end
    end

    local requestOptions = {
        Url = CONFIG.Endpoint,
        Method = "POST",
        Headers = headers,
        Body = body
    }

    if CONFIG.RequestTimeout and CONFIG.RequestTimeout > 0 then
        requestOptions.Timeout = CONFIG.RequestTimeout
    end

    task.spawn(function()
        local finalResponse = nil
        local maxAttempts = math.max(1, CONFIG.MaxRetries or 1)

        for attempt = 1, maxAttempts do
            local success, response = pcall(httpRequest, requestOptions)
            if success then
                finalResponse = response
                if response.StatusCode == 200 then
                    break
                end
            else
                warn("SIY: HTTP request failed: " .. tostring(response))
            end

            if attempt < maxAttempts then
                task.wait(CONFIG.BridgeRetryDelay)
            end
        end

        if finalResponse and finalResponse.StatusCode == 200 then
            local decodeSuccess, data = pcall(HttpService.JSONDecode, HttpService, finalResponse.Body)
            if not decodeSuccess or not data then
                warn("SIY: Failed to parse AI response")
                updateStatus("Error: Invalid Response", Colors.Red)
                EventBus:emit("AI_REQUEST_ERROR", {source = "AI", message = "Parse failure"})
                task.wait(CONFIG.ErrorDisplayTime)
                resetVisuals()
                return
            end
            local aiOutput = ""
            
            if data.choices and data.choices[1] and data.choices[1].message then
                aiOutput = data.choices[1].message.content
            end
            
            aiOutput = aiOutput:gsub("`", ""):gsub("^%s+", ""):gsub("%s+$", "")

            if IS_CHAT_MODE then
                local safeChat = aiOutput:gsub("^;chat%s+", ""):gsub("^;", ""):gsub('"', ""):gsub("\n", " ")
                appendChatLog("assistant", safeChat)
                recordChatMessage("assistant", safeChat)
                
                -- v1.3.0: Emit success event
                EventBus:emit("AI_REQUEST_COMPLETE", {prompt = promptText, response = safeChat})
                
                executeBridge(safeChat)
                resetVisuals()
                InputBox.Text = ""
            else
                if aiOutput == "" or aiOutput:lower():sub(1, 4) == "sure" then
                    updateStatus("AI Uncertain", Colors.Orange)
                    task.wait(CONFIG.ErrorDisplayTime / 2)
                    resetVisuals()
                    return
                end

                cacheCommand(promptText, aiOutput)
                showPreview(aiOutput)
                task.wait(CONFIG.PreviewDelay)
                
                -- v1.3.0: Emit success event
                EventBus:emit("AI_REQUEST_COMPLETE", {prompt = promptText, response = aiOutput})
                
                executeBridge(aiOutput, "AI")
                resetVisuals(true)
                InputBox.Text = ""
            end
        else
            warn("SIY Net Error:", finalResponse and finalResponse.StatusCode or "Unknown")
            if finalResponse and finalResponse.StatusCode == 401 then
                updateStatus("Error: Invalid API key", Colors.Red, true)
            else
                updateStatus("Error", Colors.Red, true)
            end
            EventBus:emit("AI_REQUEST_ERROR", {source = "AI", message = "Network error"})
            task.wait(CONFIG.ErrorDisplayTime)
            resetVisuals()
        end
    end)
end

--// ============================================
--// 17. SUGGESTION SYSTEM
--// ============================================
local SuggestionList = {}

local function buildSuggestions()
    local tempMap = {}
    for _, entry in ipairs(OrderedFastMap) do
        local pattern = entry.Pattern
        local cmdName = pattern:match("%^([%w_]+)")
        if cmdName then
            local cleanName = cmdName
            if pattern:find("%%d%+%)") then
                cleanName = cmdName .. " [num]"
            elseif pattern:find("%%.%+%)") or pattern:find("%%.%)") then
                cleanName = cmdName .. " [arg]"
            end
            
            if not tempMap[cmdName] or #cleanName > #tempMap[cmdName] then
                tempMap[cmdName] = cleanName
            end
        end
    end
    
    for cmdKey, displayStr in pairs(tempMap) do
        table.insert(SuggestionList, {
            Key = cmdKey,
            Display = displayStr,
            Score = Priority[cmdKey] or 0
        })
    end
end
buildSuggestions()





-- Debounce state for dropdown updates
local dropdownDebounceId = 0
local DROPDOWN_DEBOUNCE_MS = 75 -- milliseconds

local function updateDropdownInternal(text)
    for _, child in ipairs(SuggestionFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    if text == "" or IS_CHAT_MODE then
        SuggestionFrame.Visible = false
        -- Don't show status in compact CMD mode
        return
    end
    
    local matches = {}
    local textLower = text:lower()
    

    
    -- Check if user is typing goto/tp commands (player-only)
    local playerCmd, playerPartial = text:match("^(goto)%s+(.*)")
    if not playerCmd then playerCmd, playerPartial = text:match("^(go)%s+(.*)" ) end
    if not playerCmd then playerCmd, playerPartial = text:match("^(tp)%s+(.*)" ) end
    if not playerCmd then playerCmd, playerPartial = text:match("^(teleport)%s+(.*)" ) end
    
    if playerCmd then
        -- GOTO/TP: Show player suggestions only
        local partialLower = (playerPartial or ""):lower()
        
        for _, player in ipairs(Players:GetPlayers()) do
            local playerName = player.Name
            local playerLower = playerName:lower()
            if partialLower == "" or playerLower:sub(1, #partialLower) == partialLower or playerLower:find(partialLower, 1, true) then
                table.insert(matches, {
                    Key = playerCmd .. " " .. playerName,
                    Display = playerCmd .. " " .. playerName .. " [player]",
                    Score = 100,
                    IsWaypoint = false,
                    PlayerName = playerName
                })
            end
        end
    else
        -- Standard command suggestions
        for _, item in ipairs(SuggestionList) do
            if item.Key:sub(1, #text):lower() == textLower then
                table.insert(matches, item)
            end
        end
    end
    
    if #matches == 0 then
        SuggestionFrame.Visible = false
        -- Don't show status in compact CMD mode
        return
    end
    
    table.sort(matches, function(a, b)
        if a.Score ~= b.Score then return a.Score > b.Score end
        if #a.Key ~= #b.Key then return #a.Key < #b.Key end
        return a.Key < b.Key
    end)
    
    local resultCount = math.min(#matches, 6)
    
    for i = 1, resultCount do
        local data = matches[i]
        local displayColor = data.PlayerName and Colors.Blue or Colors.TextDim
        local btn = createInstance("TextButton", {
            Name = "Match",
            Size = UDim2.new(1, 0, 0, 25),
            BackgroundColor3 = Colors.DropdownBg,
            BorderSizePixel = 0,
            Text = "  " .. data.Display,
            TextColor3 = displayColor,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 10,
            Parent = SuggestionFrame
        })
        
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Colors.InputBg
            btn.TextColor3 = Colors.Text
        end)
        
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Colors.DropdownBg
            btn.TextColor3 = displayColor
        end)
        
        btn.MouseButton1Click:Connect(function()
            if data.PlayerName then
                -- For waypoint/player suggestions, use the full command
                InputBox.Text = data.Key
            else
                local cmdOnly = data.Display:match("^([%w_]+)")
                InputBox.Text = cmdOnly .. " "
            end
            InputBox:CaptureFocus()
            SuggestionFrame.Visible = false
        end)
    end
    
    SuggestionFrame.Size = UDim2.new(1, 0, 0, resultCount * 25)
    SuggestionFrame.Visible = true
end

-- Debounced wrapper for updateDropdownInternal
-- Waits DROPDOWN_DEBOUNCE_MS after last keystroke before updating
local function updateDropdown(text)
    dropdownDebounceId = dropdownDebounceId + 1
    local currentId = dropdownDebounceId
    
    task.delay(DROPDOWN_DEBOUNCE_MS / 1000, function()
        -- Only execute if this is still the latest request
        if currentId == dropdownDebounceId then
            updateDropdownInternal(text)
        end
    end)
end
--// ============================================
--// 18. EVENT HANDLERS
--// ============================================

-- Dropdown focus management state
local dropdownFocusCheckId = 0

local function hideDropdownWithDelay()
    dropdownFocusCheckId = dropdownFocusCheckId + 1
    local currentCheckId = dropdownFocusCheckId
    
    task.delay(CONFIG.DropdownFocusDelay, function()
        -- Only hide if this is still the latest check and input is not focused
        if currentCheckId == dropdownFocusCheckId and not InputBox:IsFocused() then
            SuggestionFrame.Visible = false
            -- Don't show status in compact CMD mode
        end
    end)
end

ConnectPersistent(InputBox:GetPropertyChangedSignal("Text"), function()
    updateDropdown(InputBox.Text)
end)

ConnectPersistent(InputBox.FocusLost, function(enterPressed)
    if enterPressed then
        if InputBox.Text ~= "" then
            queryAI(InputBox.Text)
        end
        SuggestionFrame.Visible = false
        -- Don't show status in compact CMD mode
    else
        -- Use configurable delay-based check to ensure UI cleanliness
        hideDropdownWithDelay()
    end
end)

-- Additional focus management: hide dropdown when clicking elsewhere
ConnectPersistent(InputBox.Focused, function()
    -- Cancel any pending hide operations when input regains focus
    dropdownFocusCheckId = dropdownFocusCheckId + 1
    if InputBox.Text ~= "" and not IS_CHAT_MODE then
        updateDropdown(InputBox.Text)
    end
end)

ConnectPersistent(MinBtn.MouseButton1Click, function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

ConnectPersistent(OpenButton.MouseButton1Click, function()
    OpenButton.Visible = false
    MainFrame.Visible = true
end)

-- Function to switch mode (shared by dropdown options)
local function switchMode(toChatMode)
    local uiName = (GameName ~= "Loading...") and GameName or "game"
    
    -- Only switch if actually changing mode
    if IS_CHAT_MODE == toChatMode then
        closeModeDropdown()
        return
    end
    
    IS_CHAT_MODE = toChatMode
    
    -- Close dropdown first
    closeModeDropdown()
    
    if IS_CHAT_MODE then
        -- CHAT Mode activated
        ModeBtn.Text = "CHAT ▾"
        TweenService:Create(ModeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Blue}):Play()
        InputBox.PlaceholderText = "Ask about " .. uiName .. "..."
        
        -- Show CHAT mode container with animation
        ChatModeContainer.Visible = true
        TweenService:Create(ChatModeContainer, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        
        -- Update header for CHAT mode
        ChatLogHeader.Text = "💬 Conversation"
        ChatLogHeader.TextColor3 = Colors.Blue
        
        -- Hide CMD-specific elements
        SuggestionFrame.Visible = false
        StatusLabel.Visible = false
        if IsMobile then QuickActionsToggle.Visible = false end
        
        -- Update memory indicator
        updateMemoryIndicator()
    else
        -- CMD Mode activated
        ModeBtn.Text = "CMD ▾"
        TweenService:Create(ModeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Orange}):Play()
        InputBox.PlaceholderText = IsMobile and "What do you want to do?" or "Tell me what to do..."
        
        -- Hide CHAT mode container
        ChatModeContainer.Visible = false
        
        -- In compact CMD mode, status is hidden by default
        StatusLabel.Visible = false
        if IsMobile then QuickActionsToggle.Visible = true end
    end
    
    -- Animate main frame size change
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Size = IS_CHAT_MODE and ChatMainSize or BaseMainSize
    }):Play()
end

-- Mode button click toggles dropdown
ConnectPersistent(ModeBtn.MouseButton1Click, function()
    toggleModeDropdown()
end)

-- Dropdown option click handlers
ConnectPersistent(CmdOption.MouseButton1Click, function()
    switchMode(false) -- Switch to CMD mode
end)

ConnectPersistent(ChatOption.MouseButton1Click, function()
    switchMode(true) -- Switch to CHAT mode
end)

-- Close dropdown when clicking elsewhere on MainFrame
ConnectPersistent(MainFrame.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        -- Check if click is outside dropdown area
        task.defer(function()
            if modeDropdownOpen then
                local mousePos = UserInputService:GetMouseLocation()
                local dropdownAbsPos = ModeDropdownContainer.AbsolutePosition
                local dropdownAbsSize = ModeDropdownContainer.AbsoluteSize
                local expandedHeight = dropdownAbsSize.Y + 54 -- Account for dropdown options
                
                if mousePos.X < dropdownAbsPos.X or mousePos.X > dropdownAbsPos.X + dropdownAbsSize.X or
                   mousePos.Y < dropdownAbsPos.Y or mousePos.Y > dropdownAbsPos.Y + expandedHeight then
                    closeModeDropdown()
                end
            end
        end)
    end
end)

-- Helper to determine if a point is inside a frame (used for global dropdown dismiss)
local function isPointInsideFrame(frame, point)
    if not frame or not frame:IsDescendantOf(SIY_Screen) then return false end
    local pos = frame.AbsolutePosition
    local size = frame.AbsoluteSize
    return point.X >= pos.X and point.X <= pos.X + size.X and point.Y >= pos.Y and point.Y <= pos.Y + size.Y
end

ConnectPersistent(UserInputService.InputBegan, function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if modeDropdownOpen then
            local mousePos = UserInputService:GetMouseLocation()
            if not isPointInsideFrame(ModeDropdownContainer, mousePos) and not isPointInsideFrame(ModeDropdownFrame, mousePos) then
                closeModeDropdown()
            end
        end
    end

    if gameProcessed then return end
    
    -- Master Toggle
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
        OpenButton.Visible = not MainFrame.Visible
    end
    
    -- Custom Binds
    local keyName = input.KeyCode.Name:lower()
    local bindData = BindSystem[keyName]
    if bindData then
        executeBridge(bindData.Current, "BIND")
        
        if bindData.Next then
            bindData.Current, bindData.Next = bindData.Next, bindData.Current
        end
    end
end)

-- Bridge Ready Notification
ConnectPersistent(BridgeReady.Event, function()
    updateStatus("Connected! Ready to roll", Colors.Green)
end)

-- Cleanup function to disconnect all connections and save state
local function cleanup()
    -- Save cache before cleanup
    pcall(saveCache)
    
    -- Stop animations and persistent tasks
    stopGlowAnimation()
    cancelPersistentTasks()
    openButtonPulse = nil

    for frame in pairs(DragRegistrations) do
        disconnectDragConnections(frame)
    end
    
    -- Disconnect all registered connections
    for index = #Connections, 1, -1 do
        local connection = Connections[index]
        if connection then
            pcall(function()
                connection:Disconnect()
            end)
        end
        Connections[index] = nil
    end
    table.clear(Connections)
    
    -- Destroy UI elements
    pcall(function()
        if SIY_Screen and SIY_Screen.Parent then
            SIY_Screen:Destroy()
        end
    end)
    
    -- Destroy BindableEvent
    pcall(function()
        if BridgeReady then
            BridgeReady:Destroy()
        end
    end)

    BridgeConnected = false
    IY_Interface = nil
    modeDropdownOpen = false
    quickActionsOpen = false
    IS_CHAT_MODE = false
    ChatHistory = {}
    ChatLogOrder = 0
    ChatMessageCount = 0
    dropdownFocusCheckId = 0
    setNamespaceValue("Ready", false)
end

-- Handle player leaving
ConnectPersistent(Players.PlayerRemoving, function(player)
    if player == LocalPlayer then
        cleanup()
    end
end)

-- Handle game closing
game:BindToClose(function()
    cleanup()
end)

-- Expose cleanup for external use (e.g., script reload)
setNamespaceValue("Cleanup", cleanup)
setNamespaceValue("ClearChat", clearChatLog)
setNamespaceValue("GetBridgeStatus", getBridgeStatus)
setNamespaceValue("Version", "1.3.3")
setNamespaceValue("Ready", true)


--// ============================================
--// PLUGIN BRIDGE API (v1.3.0)
--// ============================================
-- Exposes SIY AI capabilities to IY plugins via _G.SIY
local PluginBridge = {
    -- Ask AI to convert natural language to command
    askAI = function(prompt)
        -- Uses the existing processAIRequest if available
        local ns = getNamespace()
        if ns.processAIRequest then
            return ns.processAIRequest(prompt)
        end
        ErrorHandler:report("PluginBridge", "AI not ready", "warning")
        return nil
    end,
    
    -- Execute a command through the bridge
    executeCommand = function(command)
        if IY_Interface and IY_Interface.Exec then
            IY_Interface.Exec(command)
            EventBus:emit("COMMAND_EXECUTED", {source = "PluginBridge", command = command})
            return true
        end
        return false
    end,
    
    -- Get bridge status
    getStatus = function()
        return {
            ready = getNamespaceValue("Ready") or false,
            version = getNamespaceValue("Version") or "unknown"
        }
    end
}

-- Register globally for plugin access
if getgenv then
    getgenv().SIY = PluginBridge
elseif _G then
    _G.SIY = PluginBridge
end
setNamespaceValue("PluginBridge", PluginBridge)
