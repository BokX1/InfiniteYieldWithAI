--[[ 
    SMART INFINITE YIELD - V1.2.1 STABLE
    - Architecture: Context Awareness + Event-Based Bridge
    - Logic: VolQ5 & Pollinations.AI (LLM Model)
    - Status: Stable 
    - New: Enhanced Bridge, Command Caching, Fuzzy Targeting, Visual Feedback, Command Preview, Mobile Quick Actions
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

--// ============================================
--// 2. CONFIGURATION
--// ============================================
local CONFIG = {
    ApiKey = "Null",
    Endpoint = "https://infiniteyieldai.ahazihak03.workers.dev/v1/chat/completions",
    Model = "openai",
    MaxRetries = 2,
    
    -- Cache Settings
    CacheEnabled = true,
    CacheFile = "SIY_CommandCache.json",
    MaxCacheEntries = 100,
    
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
   - Example: "fly and kill him" -> ;fly ;kill [target]
   
4. TARGETING:
   - "me" -> Output "me" (e.g., ;kill me)
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
;fling                 : Spin fling (Touch to kill).
;unfling               : Stop fling.
;invisfling            : Invisible fling.
;kill [plr]            : Kill player (Tool/Collision).
;loopkill [plr]        : Loop kill player.
;unloopkill            : Stop loop kill.
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
     > Output: ;gotowp [name]
     > Example: "go to my base waypoint" -> ;gotowp base
     > Example: "teleport to coffee waypoint" -> ;gotowp coffee
     > Example: "take me to the farm spot" -> ;gotowp farm
   - Use gotowp ONLY for saved waypoints/locations.

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
   - "delete waypoint base" -> ;deletewaypoint base

6. CLEAR ALL WAYPOINTS:
   - "clear all waypoints" -> ;clearwaypoints

### SECTION 4: FEW-SHOT TRAINING ###
User: "Stop flying immediately"
AI: ;unfly

User: "Make me walk slow"
AI: ;speed 16

User: "I want to kill him and leave"
AI: ;kill [player] ;serverhop

User: "Remove the lag"
AI: ;antilag ;noesp ;nochams

User: "Don't let me fall in the void"
AI: ;antivoid

User: "Save this spot as my base"
AI: ;swp base

User: "Go to my base waypoint"
AI: ;gotowp base

User: "Remember this location as coffee"
AI: ;swp coffee

User: "Goto coffee waypoint"
AI: ;gotowp coffee

User: "Take me to the farm spot I saved"
AI: ;gotowp farm

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

[END OF STATIC CONTEXT]
]],
}

--// ============================================
--// 3. LOCAL PLAYER & ENVIRONMENT
--// ============================================
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local GameName = "Loading..."

-- HTTP Request Handler (Multi-Executor Support)
local httpRequest = (syn and syn.request) 
    or (http and http.request) 
    or http_request 
    or (fluxus and fluxus.request) 
    or request

if not httpRequest then 
    warn("SIY: Executor incompatible - HTTP requests unavailable.") 
end

-- Async Game Name Fetcher
task.spawn(function()
    local success, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, game.PlaceId)
    GameName = (success and info and info.Name) or "Unknown Game"
end)

--// ============================================
--// 4. UTILITY FUNCTIONS
--// ============================================
local function trim(str)
    return str:gsub("^%s+", ""):gsub("%s+$", "")
end

local function normalizeInput(text)
    return text:lower():gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
end

--// ============================================
--// 5. COMMAND CACHE SYSTEM
--// ============================================
local CommandCache = {}

local function loadCache()
    if not CONFIG.CacheEnabled then return end
    
    local success, content = pcall(function()
        return readfile and readfile(CONFIG.CacheFile) or nil
    end)
    
    if success and content then
        local parseSuccess, parsed = pcall(HttpService.JSONDecode, HttpService, content)
        if parseSuccess and parsed then
            CommandCache = parsed
        end
    end
end

local function saveCache()
    if not CONFIG.CacheEnabled then return end
    
    pcall(function()
        if writefile then
            writefile(CONFIG.CacheFile, HttpService:JSONEncode(CommandCache))
        end
    end)
end

local function getCachedCommand(input)
    local key = normalizeInput(input)
    return CommandCache[key]
end

local function cacheCommand(input, output)
    if not CONFIG.CacheEnabled then return end
    if not output or output == "" or output:lower():find("sure") then return end
    
    local key = normalizeInput(input)
    
    -- Enforce max cache entries (LRU-style cleanup)
    local count = 0
    for _ in pairs(CommandCache) do count = count + 1 end
    
    if count >= CONFIG.MaxCacheEntries then
        local oldestKey, oldestTime = nil, math.huge
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
end

local function clearCache()
    CommandCache = {}
    saveCache()
    return true
end

local function getCacheInfo()
    local count = 0
    for _ in pairs(CommandCache) do count = count + 1 end
    return count, CONFIG.MaxCacheEntries
end

-- Initialize cache
loadCache()

--// ============================================
--// 6. BRIDGE SYSTEM (Event-Based)
--// ============================================
local IY_Interface = nil
local BridgeReady = Instance.new("BindableEvent")
local BridgeConnected = false

local function waitForBridge(timeout)
    if BridgeConnected then return true end
    
    local connection
    local result = false
    
    connection = BridgeReady.Event:Connect(function()
        result = true
    end)
    
    local waited = 0
    local maxWait = timeout or 5
    while not result and waited < maxWait do
        task.wait(0.1)
        waited = waited + 0.1
    end
    
    connection:Disconnect()
    return BridgeConnected
end

-- Initialize Bridge
task.spawn(function()
    if getgenv().PseudoBridge then
        IY_Interface = getgenv().PseudoBridge
        BridgeConnected = true
        BridgeReady:Fire()
        return
    end

    if not CoreGui:FindFirstChild("InfiniteYield") then
        local success, source = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
        if success then
            local bridgeCode = [[
                getgenv().PseudoBridge = {
                    Exec = function(cmd) if execCmd then execCmd(cmd) end end,
                    Ready = true
                }
            ]]
            loadstring(source .. "\n" .. bridgeCode)()
        end
    end

    local timeout, interval = 0, 0.1
    while not getgenv().PseudoBridge and timeout < 10 do
        task.wait(interval)
        timeout = timeout + interval
    end

    if getgenv().PseudoBridge then
        IY_Interface = getgenv().PseudoBridge
        BridgeConnected = true
        BridgeReady:Fire()
    else
        warn("SIY: Bridge connection timeout")
    end
end)

--// ============================================
--// 7. UI CONFIGURATION
--// ============================================
local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

local Colors = {
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
    Status     = Color3.fromRGB(200, 200, 200)
}

-- UI Helper Functions
local function addCorner(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = obj
    return corner
end

local function addStroke(obj, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Parent = obj
    return stroke
end

local function createInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

--// ============================================
--// 8. DRAG SYSTEM
--// ============================================
local function enableDrag(frame)
    local dragToggle, dragStart, startPos, dragInput
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        TweenService:Create(frame, TweenInfo.new(0.08), {Position = position}):Play()
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            updateInput(input)
        end
    end)
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
    openButtonPulse = task.spawn(function()
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
    end)
end

OpenButton:GetPropertyChangedSignal("Visible"):Connect(function()
    if OpenButton.Visible then
        startOpenButtonPulse()
    else
        if openButtonPulse then
            task.cancel(openButtonPulse)
            openButtonPulse = nil
        end
    end
end)

-- Main Container
local MainSize = IsMobile and UDim2.new(0.9, 0, 0, 60) or UDim2.new(0, 500, 0, 65)
local MainFrame = createInstance("Frame", {
    Name = "MainFrame",
    AnchorPoint = Vector2.new(0.5, 0),
    Size = MainSize,
    Position = UDim2.new(0.5, 0, 0.15, 0),
    BackgroundColor3 = Colors.Background,
    BorderSizePixel = 0,
    Parent = SIY_Screen
})
addCorner(MainFrame, 8)
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
    if glowConnection then return end
    GlowStroke.Transparency = 0
    local rotation = 0
    glowConnection = RunService.Heartbeat:Connect(function(dt)
        rotation = (rotation + dt * 100) % 360
        GlowGradient.Rotation = rotation
        GlowStroke.Transparency = math.sin(tick() * 3) * 0.3 + 0.5
    end)
end

local function stopGlowAnimation()
    if glowConnection then
        glowConnection:Disconnect()
        glowConnection = nil
    end
    GlowStroke.Transparency = 1
end

--// Control Buttons
local BtnWidth = IsMobile and 55 or 80
local FontSize = IsMobile and 11 or 14

local ModeBtn = createInstance("TextButton", {
    Size = UDim2.new(0, BtnWidth, 0, 30),
    Position = UDim2.new(0, 8, 0, 8),
    BackgroundColor3 = Colors.Orange,
    Text = "CMD",
    TextColor3 = Color3.new(0, 0, 0),
    Font = Enum.Font.GothamBold,
    TextSize = FontSize,
    Parent = MainFrame
})
addCorner(ModeBtn, 6)

local HelpBtn = createInstance("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -46, 0, 8),
    BackgroundColor3 = Colors.InputBg,
    Text = "?",
    TextColor3 = Colors.Blue,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    Parent = MainFrame
})
addCorner(HelpBtn, 6)

-- Help button hover effect
HelpBtn.MouseEnter:Connect(function()
    TweenService:Create(HelpBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Colors.Blue,
        TextColor3 = Color3.new(1, 1, 1)
    }):Play()
end)
HelpBtn.MouseLeave:Connect(function()
    TweenService:Create(HelpBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Colors.InputBg,
        TextColor3 = Colors.Blue
    }):Play()
end)

local MinBtn = createInstance("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -8, 0, 8),
    BackgroundColor3 = Colors.InputBg,
    Text = "-",
    TextColor3 = Colors.TextDim,
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    Parent = MainFrame
})
addCorner(MinBtn, 6)

-- Minimize button hover effect
MinBtn.MouseEnter:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Colors.Orange,
        TextColor3 = Color3.new(0, 0, 0)
    }):Play()
end)
MinBtn.MouseLeave:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Colors.InputBg,
        TextColor3 = Colors.TextDim
    }):Play()
end)

--// Input Area
local LeftPad = 8 + BtnWidth + 8
local RightPad = 8 + 30 + 8 + 30 + 8  -- Mode + Help + Minimize buttons

local InputContainer = createInstance("Frame", {
    Size = UDim2.new(1, -(LeftPad + RightPad), 0, 30),
    Position = UDim2.new(0, LeftPad, 0, 8),
    BackgroundColor3 = Colors.InputBg,
    ZIndex = 2,
    Parent = MainFrame
})
addCorner(InputContainer, 6)

local InputBox = createInstance("TextBox", {
    Size = UDim2.new(1, -12, 1, 0),
    Position = UDim2.new(0, 6, 0, 0),
    BackgroundTransparency = 1,
    Text = "",
    PlaceholderText = IsMobile and "What do you want to do?" or "Tell me what to do...",
    TextColor3 = Colors.Text,
    PlaceholderColor3 = Colors.TextDim,
    Font = Enum.Font.GothamMedium,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
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

--// Preview Bar
local PreviewBar = createInstance("Frame", {
    Name = "PreviewBar",
    Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.new(0, 10, 1, -25),
    BackgroundColor3 = Colors.InputBg,
    BackgroundTransparency = 0.5,
    Visible = false,
    ZIndex = 3,
    Parent = MainFrame
})
addCorner(PreviewBar, 4)

local PreviewLabel = createInstance("TextLabel", {
    Name = "PreviewText",
    Size = UDim2.new(1, -10, 1, 0),
    Position = UDim2.new(0, 5, 0, 0),
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = Colors.Green,
    Font = Enum.Font.Code,
    TextSize = 11,
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

--// Status Bar
local StatusLabel = createInstance("TextLabel", {
    Name = "Status",
    Size = UDim2.new(1, -20, 0, 15),
    Position = UDim2.new(0, 10, 0, 42),
    BackgroundTransparency = 1,
    Text = ">> Ready",
    TextColor3 = Colors.TextDim,
    Font = Enum.Font.Code,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTransparency = 0.5,
    Parent = MainFrame
})

--// ============================================
--// 10. MOBILE QUICK ACTIONS
--// ============================================
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

createInstance("UIGridLayout", {
    CellSize = UDim2.new(0.33, -4, 0, 35),
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

local QuickActions = {
    {text = "Fly", prompt = "fly", color = Colors.Blue},
    {text = "Speed", prompt = "make me fast", color = Colors.Green},
    {text = "ESP", prompt = "esp", color = Colors.Purple},
    {text = "Noclip", prompt = "noclip", color = Colors.Orange},
    {text = "Jump", prompt = "infinite jump", color = Colors.Green},
    {text = "Teleport", prompt = "goto random", color = Colors.Blue},
    {text = "Invisible", prompt = "make me invisible", color = Colors.Purple},
    {text = "Reset", prompt = "reset", color = Colors.TextDim},
    {text = "Anti-Lag", prompt = "antilag", color = Colors.Orange},
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
        TextSize = 11,
        LayoutOrder = i,
        Parent = QuickActionsFrame
    })
    addCorner(btn, 4)
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.3,
            TextColor3 = Color3.new(1, 1, 1)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.7,
            TextColor3 = Colors.Text
        }):Play()
    end)
    
    -- Press effect with scale animation
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.05), {
            BackgroundTransparency = 0
        }):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.3
        }):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        InputBox.Text = action.prompt
        InputBox:CaptureFocus()
        task.wait(0.1)
        InputBox:ReleaseFocus(true)
    end)
end

local rows = math.ceil(#QuickActions / 3)
local gridHeight = (rows * 35) + ((rows - 1) * 4) + 12

local QuickActionsToggle = createInstance("TextButton", {
    Name = "QuickActionsToggle",
    Size = UDim2.new(0, 25, 0, 25),
    Position = UDim2.new(1, -40, 0, 10),
    BackgroundColor3 = Colors.Purple,
    BackgroundTransparency = 0.5,
    Text = "⚡",
    TextColor3 = Colors.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    Visible = IsMobile,
    Parent = MainFrame
})
addCorner(QuickActionsToggle, 6)

local quickActionsOpen = false
QuickActionsToggle.MouseButton1Click:Connect(function()
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
        content = "<b><font color='#b464ff'>Intelligent Caching</font></b>\nSmart IY <b>learns</b> your phrases! After using \"make me fast\" once, it executes instantly next time.\n\n<b><font color='#b464ff'>Fuzzy Targeting</font></b>\nType partial names: <font color='#ff9128'>\"kill valk\"</font> finds \"Valkorym\"\n\n<b><font color='#b464ff'>Predictions</font></b>\nAs you type, suggestions appear below the input box.",
        button = "Next →"
    },
    {
        title = "Waypoints & Teleporting",
        icon = "📍",
        content = "<b>Save & Teleport to Locations:</b>\n\n<font color='#40e682'>swp [name]</font> - Save current spot\n<font color='#969696'>\"swp base\" saves your position as \"base\"</font>\n\n<font color='#40e682'>gotowp [name]</font> - Teleport to waypoint\n<font color='#969696'>\"gotowp base\" takes you back there</font>\n\n<font color='#40e682'>goto [player]</font> - Teleport to player\n<font color='#969696'>\"goto john\" teleports to player John</font>\n\n<font color='#ff9128'>Tip:</font> Type \"gotowp \" to see saved waypoints!",
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
            local prop = child:IsA("TextLabel") or child:IsA("TextButton") and "TextTransparency" or "BackgroundTransparency"
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
NextBtn.MouseButton1Click:Connect(function()
    if CurrentStep < TotalSteps then
        updateTutorialStep(CurrentStep + 1)
    else
        completeTutorial()
    end
end)

BackBtn.MouseButton1Click:Connect(function()
    if CurrentStep > 1 then
        updateTutorialStep(CurrentStep - 1)
    end
end)

SkipBtn.MouseButton1Click:Connect(function()
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
HelpBtn.MouseButton1Click:Connect(function()
    showTutorial()
end)

-- Initially hide main GUI until tutorial is complete
MainFrame.Visible = false

--// ============================================
--// 12. LOGIC ENGINE - DATA TABLES
--// ============================================
local IS_CHAT_MODE = false
local BindSystem = {}

local ToggleMap = {
    fly = "unfly", unfly = "fly",
    noclip = "clip", clip = "noclip", unnoclip = "noclip",
    float = "unfloat", unfloat = "float",
    swim = "unswim", unswim = "swim",
    sit = "unsit", unsit = "sit",
    platform = "unplatform", unplatform = "platform",
    vehiclefly = "unvehiclefly", unvehiclefly = "vehiclefly",
    cframefly = "uncframefly", uncframefly = "cframefly",
    spam = "unspam", unspam = "spam",
    pmspam = "unpmspam", unpmspam = "pmspam",
    esp = "noesp", noesp = "esp",
    chams = "nochams", nochams = "chams",
    xray = "noxray", noxray = "xray",
    fullbright = "nofullbright", nofullbright = "fullbright",
    shadows = "noshadows", noshadows = "shadows",
    fog = "nofog", nofog = "fog",
    light = "nolight", nolight = "light",
    spectate = "unspectate", unspectate = "spectate",
    freecam = "unfreecam", unfreecam = "freecam",
    fc = "unfc", unfc = "fc",
    shiftlock = "unshiftlock",
    god = "ungod", ungod = "god",
    invisible = "visible", visible = "invisible",
    invis = "vis", vis = "invis",
    mute = "unmute", unmute = "mute",
    dance = "undance", undance = "dance",
    spin = "unspin", unspin = "spin",
    tools = "notools", notools = "tools",
    grabtools = "ungrabtools", ungrabtools = "grabtools",
    autoclick = "unautoclick", unautoclick = "autoclick",
    reach = "unreach", unreach = "reach",
    anim = "noanim", noanim = "anim"
}

local FastMap = {
    -- System & Aliases
    ["^help$"] = "help", ["^cmds$"] = "help", ["^commands$"] = "help",
    ["^clearcache$"] = "clearcache", ["^cacheinfo$"] = "cacheinfo",
    
    -- Waypoint Teleport
    ["^gotowp (.+)"] = "gotowp %1", ["^gwp (.+)"] = "gotowp %1", ["^wpgoto (.+)"] = "gotowp %1",
    
    ["^bind (%w+) (.+)"] = "bind %1 %2", ["^unbind (%w+)"] = "unbind %1",
    ["^addalias (.+) (.+)"] = "addalias %1 %2", ["^removealias (.+)"] = "removealias %1", ["^clraliases$"] = "clraliases",
    ["^addplugin (.+)"] = "addplugin %1", ["^removeplugin (.+)"] = "removeplugin %1",
    ["^reloadplugin (.+)"] = "reloadplugin %1", ["^addallplugins$"] = "addallplugins",
    ["^breakloops$"] = "breakloops", ["^removecmd (.+)"] = "removecmd %1",

    -- Utility
    ["^discord$"] = "discord", ["^guiscale (%d+)"] = "guiscale %1",
    ["^console$"] = "console", ["^oldconsole$"] = "oldconsole",
    ["^explorer$"] = "explorer", ["^dex$"] = "explorer", ["^olddex$"] = "olddex",
    ["^remotespy$"] = "remotespy", ["^rspy$"] = "remotespy", ["^audiologger$"] = "audiologger",
    ["^antiidle$"] = "antiidle", ["^datalimit (%d+)"] = "datalimit %1", ["^replicationlag (%d+)"] = "replicationlag %1",
    ["^creatorid$"] = "creatorid", ["^copycreatorid$"] = "copycreatorid", ["^setcreatorid$"] = "setcreatorid",
    ["^noprompts$"] = "noprompts", ["^showprompts$"] = "showprompts",
    ["^enable (.+)"] = "enable %1", ["^disable (.+)"] = "disable %1",
    ["^showguis$"] = "showguis", ["^unshowguis$"] = "unshowguis", ["^hideguis$"] = "hideguis", ["^unhideguis$"] = "unhideguis",
    ["^guidelete$"] = "guidelete", ["^unguidelete$"] = "unguidelete",
    ["^hideiy$"] = "hideiy", ["^showiy$"] = "showiy", ["^keepiy$"] = "keepiy", ["^unkeepiy$"] = "unkeepiy", ["^togglekeepiy$"] = "togglekeepiy",
    ["^savegame$"] = "savegame", ["^clearerror$"] = "clearerror",
    ["^clientantikick$"] = "clientantikick", ["^clientantiteleport$"] = "clientantiteleport",
    ["^allowrejoin$"] = "allowrejoin", ["^cancelteleport$"] = "cancelteleport",
    ["^volume (%d+)"] = "volume %1", ["^antilag$"] = "antilag",
    ["^record$"] = "record", ["^screenshot$"] = "screenshot", ["^togglefullscreen$"] = "togglefullscreen",
    ["^notify (.+)"] = "notify %1", ["^lastcommand$"] = "lastcommand", ["^setfpscap (%d+)"] = "setfpscap %1",

    -- Movement
    ["^noclip$"] = "noclip", ["^unnoclip$"] = "unnoclip", ["^clip$"] = "clip",
    ["^fly$"] = "fly", ["^fly (%d+)$"] = "fly %1", ["^unfly$"] = "unfly",
    ["^flyspeed (%d+)$"] = "flyspeed %1",
    ["^vfly$"] = "vehiclefly", ["^vfly (%d+)$"] = "vehiclefly %1", ["^unvfly$"] = "unvehiclefly",
    ["^vehicleflyspeed (%d+)$"] = "vehicleflyspeed %1",
    ["^cfly$"] = "cframefly", ["^cfly (%d+)$"] = "cframefly %1", ["^uncfly$"] = "uncframefly",
    ["^cframeflyspeed (%d+)$"] = "cframeflyspeed %1",
    ["^qefly$"] = "qefly", ["^vehiclenoclip$"] = "vehiclenoclip", ["^vehicleclip$"] = "vehicleclip",
    ["^float$"] = "float", ["^unfloat$"] = "unfloat",
    ["^swim$"] = "swim", ["^unswim$"] = "unswim", ["^toggleswim$"] = "toggleswim",
    ["^tpwalk (%d+)$"] = "tpwalk %1", ["^untpwalk$"] = "untpwalk", ["^wallwalk$"] = "wallwalk",

    -- Teleport
    ["^setwaypoint (.+)"] = "setwaypoint %1", ["^waypoints$"] = "waypoints", ["^showwaypoints$"] = "showwaypoints", ["^hidewaypoints$"] = "hidewaypoints",
    ["^waypoint (.+)"] = "waypoint %1", ["^tweenwaypoint (.+)"] = "tweenwaypoint %1", ["^walktowaypoint (.+)"] = "walktowaypoint %1",
    ["^deletewaypoint (.+)"] = "deletewaypoint %1", ["^clearwaypoints$"] = "clearwaypoints",
    ["^goto (.+)"] = "goto %1", ["^tweengoto (.+)"] = "tweengoto %1", ["^tweenspeed (%d+)"] = "tweenspeed %1",
    ["^vehiclegoto (.+)"] = "vehiclegoto %1", ["^loopgoto (.+)"] = "loopgoto %1", ["^unloopgoto$"] = "unloopgoto",
    ["^clientbring (.+)"] = "clientbring %1", ["^loopbring (.+)"] = "loopbring %1", ["^unloopbring$"] = "unloopbring",
    ["^spawnpoint$"] = "spawnpoint", ["^nospawnpoint$"] = "nospawnpoint", ["^flashback$"] = "flashback",
    ["^walltp$"] = "walltp", ["^nowalltp$"] = "nowalltp", ["^teleporttool$"] = "teleporttool",

    -- Visuals
    ["^esp$"] = "esp", ["^noesp$"] = "noesp", ["^espteam$"] = "espteam", ["^esptransparency (%d+)"] = "esptransparency %1",
    ["^partesp (.+)"] = "partesp %1", ["^unpartesp (.+)"] = "unpartesp %1",
    ["^chams$"] = "chams", ["^nochams$"] = "nochams", ["^xray$"] = "xray", ["^noxray$"] = "noxray",
    ["^locate (.+)"] = "locate %1", ["^unlocate$"] = "unlocate",
    ["^spectate (.+)"] = "spectate %1", ["^view (.+)"] = "view %1", ["^unspectate$"] = "unspectate",
    ["^freecam$"] = "freecam", ["^unfreecam$"] = "unfreecam", ["^freecamspeed (%d+)"] = "freecamspeed %1",
    ["^firstp$"] = "firstp", ["^thirdp$"] = "thirdp", ["^noclipcam$"] = "noclipcam",
    ["^maxzoom (%d+)"] = "maxzoom %1", ["^minzoom (%d+)"] = "minzoom %1", ["^fov (%d+)"] = "fov %1", ["^fixcam$"] = "fixcam",
    ["^lookat (.+)"] = "lookat %1",
    ["^fullbright$"] = "fullbright", ["^loopfullbright$"] = "loopfullbright", ["^unloopfullbright$"] = "unloopfullbright",
    ["^day$"] = "day", ["^night$"] = "night", ["^nofog$"] = "nofog", ["^globalshadows$"] = "globalshadows", ["^noglobalshadows$"] = "noglobalshadows",
    ["^light$"] = "light", ["^nolight$"] = "nolight", ["^hovername$"] = "hovername", ["^unhovername$"] = "unhovername",

    -- Player
    ["^inspect (.+)"] = "inspect %1", ["^age (.+)"] = "age %1", ["^chatage (.+)"] = "chatage %1", ["^joindate (.+)"] = "joindate %1",
    ["^copyname (.+)"] = "copyname %1", ["^userid (.+)"] = "userid %1", ["^copyuserid (.+)"] = "copyuserid %1",
    ["^bang (.+)"] = "bang %1", ["^unbang$"] = "unbang", ["^carpet (.+)"] = "carpet %1", ["^uncarpet$"] = "uncarpet",
    ["^friend (.+)"] = "friend %1", ["^unfriend (.+)"] = "unfriend %1", ["^headsit (.+)"] = "headsit %1",
    ["^walkto (.+)"] = "walkto %1", ["^unwalkto$"] = "unwalkto", ["^orbit (.+)"] = "orbit %1", ["^unorbit$"] = "unorbit",
    ["^stareat (.+)"] = "stareat %1", ["^unstareat$"] = "unstareat",
    ["^fling$"] = "fling", ["^unfling$"] = "unfling", ["^flyfling$"] = "flyfling", ["^unflyfling$"] = "unflyfling",
    ["^walkfling$"] = "walkfling", ["^unwalkfling$"] = "unwalkfling", ["^invisfling$"] = "invisfling",
    ["^kill (.+)"] = "kill %1", ["^loopkill (.+)"] = "loopkill %1", ["^unloopkill$"] = "unloopkill",
    ["^loopoof$"] = "loopoof", ["^unloopoof$"] = "unloopoof",
    ["^hitbox (.+)"] = "hitbox %1", ["^headsize (.+)"] = "headsize %1",
    ["^reset$"] = "reset", ["^respawn$"] = "respawn", ["^refresh$"] = "refresh", ["^god$"] = "god", ["^permadeath$"] = "permadeath",
    ["^invisible$"] = "invisible", ["^visible$"] = "visible", ["^toolinvisible$"] = "toolinvisible",
    ["^speed (%d+)$"] = "speed %1", ["^ws (%d+)$"] = "speed %1", ["^loopspeed (%d+)$"] = "loopspeed %1", ["^unloopspeed$"] = "unloopspeed",
    ["^jumppower (%d+)$"] = "jumppower %1", ["^jp (%d+)$"] = "jumppower %1", ["^loopjumppower (%d+)$"] = "loopjumppower %1", ["^unloopjumppower$"] = "unloopjumppower",
    ["^sit$"] = "sit", ["^lay$"] = "lay", ["^jump$"] = "jump", ["^infjump$"] = "infjump", ["^uninfjump$"] = "uninfjump",
    ["^flyjump$"] = "flyjump", ["^unflyjump$"] = "unflyjump", ["^autojump$"] = "autojump", ["^unautojump$"] = "unautojump",
    ["^stun$"] = "stun", ["^unstun$"] = "unstun", ["^team (.+)"] = "team %1",
    ["^nobgui$"] = "nobgui", ["^noarms$"] = "noarms", ["^nolegs$"] = "nolegs", ["^nolimbs$"] = "nolimbs", ["^naked$"] = "naked", ["^noface$"] = "noface",
    ["^blockhead$"] = "blockhead", ["^blockhats$"] = "blockhats", ["^creeper$"] = "creeper",
    ["^drophats$"] = "drophats", ["^deletehats$"] = "deletehats", ["^hatspin$"] = "hatspin", ["^unhatspin$"] = "unhatspin", ["^clearhats$"] = "clearhats",
    ["^spin$"] = "spin", ["^unspin$"] = "unspin", ["^split$"] = "split", ["^trip$"] = "trip", ["^jerk$"] = "jerk",

    -- Chat
    ["^logs$"] = "logs", ["^chatlogs$"] = "chatlogs", ["^chat (.+)"] = "chat %1",
    ["^spam (.+)"] = "spam %1", ["^unspam$"] = "unspam",
    ["^whisper (.+)"] = "whisper %1", ["^pmspam (.+)"] = "pmspam %1", ["^unpmspam$"] = "unpmspam",
    ["^bubblechat$"] = "bubblechat", ["^unbubblechat$"] = "unbubblechat",

    -- Workspace
    ["^btools$"] = "btools", ["^f3x$"] = "f3x", ["^delete (.+)"] = "delete %1",
    ["^lockworkspace$"] = "lockworkspace", ["^unlockworkspace$"] = "unlockworkspace",
    ["^gotopart (.+)"] = "gotopart %1", ["^bringpart (.+)"] = "bringpart %1",
    ["^fireclickdetectors$"] = "fireclickdetectors", ["^firetouchinterests$"] = "firetouchinterests",
    ["^removeterrain$"] = "removeterrain", ["^destroyheight (%d+)"] = "destroyheight %1",
    ["^antivoid$"] = "antivoid", ["^unantivoid$"] = "unantivoid",

    -- Animation
    ["^animation (.+)"] = "animation %1", ["^emote (.+)"] = "emote %1", ["^dance$"] = "dance", ["^undance$"] = "undance",
    ["^spasm$"] = "spasm", ["^unspasm$"] = "unspasm", ["^noanim$"] = "noanim", ["^reanim$"] = "reanim",
    ["^stopanimations$"] = "stopanimations",

    -- Tools
    ["^autoclick$"] = "autoclick", ["^unautoclick$"] = "unautoclick", ["^mousesensitivity$"] = "mousesensitivity",
    ["^tools$"] = "tools", ["^notools$"] = "notools", ["^grabtools$"] = "grabtools", ["^ungrabtools$"] = "ungrabtools",
    ["^equiptools$"] = "equiptools", ["^unequiptools$"] = "unequiptools", ["^reach (%d+)"] = "reach %1", ["^unreach$"] = "unreach",
    ["^dupetools (%d+)"] = "dupetools %1", ["^droppabletools$"] = "droppabletools", ["^droptools$"] = "droptools",

    -- Server
    ["^serverinfo$"] = "serverinfo", ["^jobid$"] = "jobid", ["^rejoin$"] = "rejoin", ["^autorejoin$"] = "autorejoin",
    ["^serverhop$"] = "serverhop", ["^gametp (.+)"] = "gametp %1"
}

local Priority = {
    fly = 100, unfly = 100, noclip = 100, clip = 100,
    speed = 95, ws = 95, jumppower = 95, jp = 95,
    ["goto"] = 90, tp = 90, bring = 90,
    kill = 80, fling = 80, loopkill = 80,
    esp = 75, noesp = 75, xray = 75, spectate = 75,
    btools = 70, f3x = 70, dex = 70,
    rejoin = 50, serverhop = 50, console = 50, reset = 50
}

local TargetTriggers = {"kill", "fling", "goto", "tp", "spectate", "view", "watch", "bring", "to", "attach", "loopkill", "bang", "freeze"}

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
    TweenService:Create(StatusLabel, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 0.6}):Play()
end

local function getPlayerList()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(names, player.Name)
    end
    return table.concat(names, ", ")
end

local function needsPlayerContext(text)
    local lowerText = text:lower()
    for _, trigger in ipairs(TargetTriggers) do
        if lowerText:find(trigger) then return true end
    end
    return false
end

--// Levenshtein Distance for Fuzzy Matching
local function levenshteinDistance(s1, s2)
    local len1, len2 = #s1, #s2
    local matrix = {}
    
    for i = 0, len1 do matrix[i] = {[0] = i} end
    for j = 0, len2 do matrix[0][j] = j end
    
    for i = 1, len1 do
        for j = 1, len2 do
            local cost = (s1:sub(i, i):lower() == s2:sub(j, j):lower()) and 0 or 1
            matrix[i][j] = math.min(
                matrix[i-1][j] + 1,
                matrix[i][j-1] + 1,
                matrix[i-1][j-1] + cost
            )
        end
    end
    
    return matrix[len1][len2]
end

local function fuzzyMatchPlayer(partial)
    if not partial or partial == "" then return nil end
    
    local partialLower = partial:lower()
    local bestMatch, bestScore = nil, math.huge
    local threshold = math.max(2, math.floor(#partial * 0.5))
    
    for _, player in ipairs(Players:GetPlayers()) do
        local name = player.Name:lower()
        local displayName = player.DisplayName:lower()
        
        -- Exact prefix match (highest priority)
        if name:sub(1, #partialLower) == partialLower then return player.Name end
        if displayName:sub(1, #partialLower) == partialLower then return player.Name end
        
        -- Contains match
        if name:find(partialLower, 1, true) then
            local score = levenshteinDistance(partialLower, name)
            if score < bestScore then
                bestScore = score
                bestMatch = player.Name
            end
        end
        
        if displayName:find(partialLower, 1, true) then
            local score = levenshteinDistance(partialLower, displayName)
            if score < bestScore then
                bestScore = score
                bestMatch = player.Name
            end
        end
        
        -- Fuzzy match
        local nameScore = levenshteinDistance(partialLower, name)
        local displayScore = levenshteinDistance(partialLower, displayName)
        local minScore = math.min(nameScore, displayScore)
        
        if minScore <= threshold and minScore < bestScore then
            bestScore = minScore
            bestMatch = player.Name
        end
    end
    
    return bestMatch
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
    if not IY_Interface then
        if not waitForBridge(3) then
            warn("SIY: Bridge not connected.")
            updateStatus("Error: Bridge Failed", Colors.Red)
            return
        end
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

        --// ==========================================
        --// GOTOWP - Waypoint Teleport Command
        --// ==========================================
        -- gotowp [name] - Teleport to a saved waypoint
        local wpTarget = cleanText:match("^gotowp%s+(.+)")
        if wpTarget then
            -- Use IY's native waypoint command
            updateStatus("Waypoint: " .. wpTarget, Colors.Green)
            IY_Interface.Exec("waypoint " .. wpTarget)
            return
        end
        --// ==========================================

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
    InputBox.PlaceholderText = IS_CHAT_MODE and "Ask me anything..." or (IsMobile and "What do you want to do?" or "Tell me what to do...")
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
    InputBox.PlaceholderText = retry and "Retrying..." or "Thinking..."
    InputBox.PlaceholderColor3 = retry and Colors.Orange or Colors.Green
    TweenService:Create(MainStroke, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0}):Play()
end

--// ============================================
--// 16. AI QUERY SYSTEM
--// ============================================
local function queryAI(promptText, retryContext, attemptCount)
    if promptText == "" then return end
    
    -- Fast Path (Non-AI)
    if not IS_CHAT_MODE and not retryContext then
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
            -- FastMap lookup
            for pattern, cmd in pairs(FastMap) do
                local _, _, capture, capture2 = cleanPrompt:find(pattern)
                if _ then
                    local finalCmd = cmd
                    if capture then finalCmd = finalCmd:gsub("%%1", capture) end
                    if capture2 then finalCmd = finalCmd:gsub("%%2", capture2) end
                    
                    showPreview(finalCmd)
                    executeBridge(finalCmd, "FAST")
                    resetVisuals(true)
                    InputBox.Text = ""
                    return
                end
            end
        end
    end

    -- AI Path
    setThinkingState(false)
    updateStatus("Thinking", Colors.Orange, true)

    local messagesPayload = {}
    
    if IS_CHAT_MODE then
        local displayName = (GameName ~= "Loading...") and GameName or "this game"
        local dynamicContext = string.format([[
ROLE: Friendly Roblox Assistant.
CURRENT GAME: '%s'. USER: '%s'.
INSTRUCTION: Respond to the user's text naturally.
FORBIDDEN: DO NOT start your response with ";chat" or ";". Just speak.
LENGTH: Under 25 words.
]], displayName, LocalPlayer.Name)
        
        table.insert(messagesPayload, {role = "system", content = dynamicContext})
    else
        local dynamicContext = "MODE: STRICT COMPILATION.\nREMINDER: Output ONLY Infinite Yield commands (e.g. ;fly)."
        if needsPlayerContext(promptText) then
            dynamicContext = dynamicContext .. " Players: [" .. getPlayerList() .. "]."
        end
        
        table.insert(messagesPayload, {role = "system", content = CONFIG.CommandPrompt})
        table.insert(messagesPayload, {role = "system", content = dynamicContext})
    end

    table.insert(messagesPayload, {role = "user", content = promptText})

    local body = HttpService:JSONEncode({
        model = CONFIG.Model,
        messages = messagesPayload,
        temperature = IS_CHAT_MODE and 0.85 or 0.1
    })

    task.spawn(function()
        local success, response = pcall(httpRequest, {
            Url = CONFIG.Endpoint,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = body
        })

        if success and response.StatusCode == 200 then
            local data = HttpService:JSONDecode(response.Body)
            local aiOutput = ""
            
            if data.choices and data.choices[1] and data.choices[1].message then
                aiOutput = data.choices[1].message.content
            end
            
            aiOutput = aiOutput:gsub("`", ""):gsub("^%s+", ""):gsub("%s+$", "")

            if IS_CHAT_MODE then
                local safeChat = aiOutput:gsub("^;chat%s+", ""):gsub("^;", ""):gsub('"', ""):gsub("\n", " ")
                executeBridge(safeChat)
                resetVisuals()
                InputBox.Text = ""
            else
                if aiOutput == "" or aiOutput:lower():sub(1, 4) == "sure" then
                    updateStatus("AI Uncertain", Colors.Orange)
                    task.wait(1)
                    resetVisuals()
                    return
                end

                cacheCommand(promptText, aiOutput)
                showPreview(aiOutput)
                task.wait(0.3)
                
                executeBridge(aiOutput, "AI")
                resetVisuals(true)
                InputBox.Text = ""
            end
        else
            warn("SIY Net Error:", response and response.StatusCode or "Unknown")
            updateStatus("Error", Colors.Red, true)
            task.wait(2)
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
    for pattern, _ in pairs(FastMap) do
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

-- Helper: Get IY waypoints from the global IY waypoint list
local function getIYWaypoints()
    local waypoints = {}
    -- Try to access IY's waypoint storage (stored in IY's global)
    local success, result = pcall(function()
        if getgenv().IYwaypoints then
            return getgenv().IYwaypoints
        elseif _G.IYwaypoints then
            return _G.IYwaypoints
        end
        return nil
    end)
    
    if success and result then
        for name, _ in pairs(result) do
            table.insert(waypoints, tostring(name))
        end
    end
    return waypoints
end

local function updateDropdown(text)
    for _, child in ipairs(SuggestionFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    if text == "" or IS_CHAT_MODE then
        SuggestionFrame.Visible = false
        StatusLabel.Visible = true
        return
    end
    
    local matches = {}
    local textLower = text:lower()
    
    -- Check if user is typing gotowp (waypoint-only command)
    local wpCmd, wpPartial = text:match("^(gotowp)%s+(.*)")
    
    -- Check if user is typing goto/tp commands (player-only)
    local playerCmd, playerPartial = text:match("^(goto)%s+(.*)")
    if not playerCmd then playerCmd, playerPartial = text:match("^(go)%s+(.*)" ) end
    if not playerCmd then playerCmd, playerPartial = text:match("^(tp)%s+(.*)" ) end
    if not playerCmd then playerCmd, playerPartial = text:match("^(teleport)%s+(.*)" ) end
    
    if wpCmd then
        -- GOTOWP: Show waypoint suggestions only
        local waypoints = getIYWaypoints()
        local partialLower = (wpPartial or ""):lower()
        
        for _, wpName in ipairs(waypoints) do
            local wpLower = wpName:lower()
            if partialLower == "" or wpLower:sub(1, #partialLower) == partialLower or wpLower:find(partialLower, 1, true) then
                table.insert(matches, {
                    Key = "gotowp " .. wpName,
                    Display = "gotowp " .. wpName .. " [waypoint]",
                    Score = 100,
                    IsWaypoint = true,
                    WaypointName = wpName
                })
            end
        end
    elseif playerCmd then
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
        StatusLabel.Visible = true
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
        local displayColor = data.IsWaypoint and Colors.Green or (data.PlayerName and Colors.Blue or Colors.TextDim)
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
            if data.IsWaypoint or data.PlayerName then
                -- For waypoint/player suggestions, use the full command
                InputBox.Text = data.Key
            else
                local cmdOnly = data.Display:match("^([%w_]+)")
                InputBox.Text = cmdOnly .. " "
            end
            InputBox:CaptureFocus()
            SuggestionFrame.Visible = false
            StatusLabel.Visible = true
        end)
    end
    
    SuggestionFrame.Size = UDim2.new(1, 0, 0, resultCount * 25)
    SuggestionFrame.Visible = true
    StatusLabel.Visible = false
end

--// ============================================
--// 18. EVENT HANDLERS
--// ============================================
InputBox:GetPropertyChangedSignal("Text"):Connect(function()
    updateDropdown(InputBox.Text)
end)

InputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        if InputBox.Text ~= "" then
            queryAI(InputBox.Text)
        end
        SuggestionFrame.Visible = false
    else
        task.delay(0.2, function()
            if not InputBox:IsFocused() then
                SuggestionFrame.Visible = false
            end
        end)
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    OpenButton.Visible = false
    MainFrame.Visible = true
end)

ModeBtn.MouseButton1Click:Connect(function()
    IS_CHAT_MODE = not IS_CHAT_MODE
    local uiName = (GameName ~= "Loading...") and GameName or "game"
    
    -- Fun bounce animation on mode switch
    local originalSize = ModeBtn.Size
    TweenService:Create(ModeBtn, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, originalSize.X.Offset + 10, 0, originalSize.Y.Offset + 4)
    }):Play()
    task.delay(0.1, function()
        TweenService:Create(ModeBtn, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = originalSize
        }):Play()
    end)
    
    if IS_CHAT_MODE then
        ModeBtn.Text = "CHAT"
        TweenService:Create(ModeBtn, TweenInfo.new(0.3), {BackgroundColor3 = Colors.Blue}):Play()
        InputBox.PlaceholderText = "Ask about " .. uiName .. "..."
        updateStatus("Chat Mode - Ask me anything!", Colors.Blue)
        SuggestionFrame.Visible = false
    else
        ModeBtn.Text = "CMD"
        TweenService:Create(ModeBtn, TweenInfo.new(0.3), {BackgroundColor3 = Colors.Orange}):Play()
        InputBox.PlaceholderText = IsMobile and "What do you want to do?" or "Tell me what to do..."
        updateStatus("Command Mode - Let's do this!", Colors.Orange)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
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
BridgeReady.Event:Connect(function()
    updateStatus("Connected! Ready to roll", Colors.Green)
end)
