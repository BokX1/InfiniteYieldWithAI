--[[ 
    SMART INFINITE YIELD - V1.1 STABLE+HOTFIX
    - Architecture: Context Awareness + Logic Engine (Brain)
    - Logic: VolQ5 & Pollinations.AI (Grok Model)
    - Status: Stable 
]]

-- 1. CONFIGURATION
local CONFIG = {
    -- !!! REPLACE THIS WITH YOUR KEY !!!
    ApiKey = "Null", 
    
    Endpoint = "https://infiniteyieldai.ahazihak03.workers.dev/v1/chat/completions",
    Model = "grok",
    MaxRetries = 2, 
    
    CommandPrompt = [[
        You are the Kernel Interface for "Infinite Yield", a Roblox administration suite.
        YOUR OBJECTIVE: Translate natural language user requests into precise Infinite Yield command strings.

        ### OPERATIONAL PROTOCOL ###
        1. **Intent Analysis**: Analyze the user's request. Match it to the most logical command in the [KNOWLEDGE BASE].
        2. **Negative Handling**: If the user says "stop", "remove", "disable", or "don't", look for the "un-" or "no-" variant of the command (e.g., "stop flying" -> ;unfly).
        3. **Logic Parsing**: If the user implies a value without specifying one (e.g., "make me fast", "jump high"), infer a reasonable integer (e.g., "fast" -> 100, "high" -> 100).
        4. **Target Inference**: Smartly infer arguments. If the user says "kill him" and the [SYSTEM DATA] lists a player "BaconHair123", output ";kill BaconHair123".
        5. **Strict Output**: Output ONLY the command string (e.g., ";fly"). NO markdown, NO explanations.

        ### KNOWLEDGE BASE ###
        
        [MOVEMENT]
        - "fly (Makes you fly) -> ;fly [speed]"
        - "unfly (Stops flying) -> ;unfly"
        - "noclip (Walk through walls) -> ;noclip"
        - "unnoclip (Enable collisions) -> ;unnoclip"
        - "speed (Change walkspeed) -> ;speed [num]"
        - "jumppower (Change jump height) -> ;jumppower [num]"
        - "tpwalk (Teleport forward) -> ;tpwalk [num]"
        - "float (Spawn platform) -> ;float"
        - "unfloat (Remove platform) -> ;unfloat"
        - "swim (Swim in air) -> ;swim"
        - "unswim (Stop swimming) -> ;unswim"
        - "vehiclefly (Fly in vehicle) -> ;vehiclefly [speed]"
        - "unvehiclefly (Stop vehicle fly) -> ;unvehiclefly"
        - "cframefly (Bypass fly) -> ;cframefly [speed]"
        - "uncframefly (Stop cframe fly) -> ;uncframefly"

        [TELEPORT]
        - "goto (Teleport to player) -> ;goto [player]"
        - "tppos (Teleport to coordinates) -> ;tpposition [X Y Z]"
        - "spawnpoint (Set spawn) -> ;spawnpoint"
        - "nospawnpoint (Remove spawn) -> ;nospawnpoint"
        - "flashback (TP to last death) -> ;flashback"
        - "serverhop (Join different server) -> ;serverhop"
        - "rejoin (Rejoin current server) -> ;rejoin"

        [VISUALS]
        - "esp (See players through walls) -> ;esp"
        - "noesp (Remove ESP) -> ;noesp"
        - "chams (ESP without text) -> ;chams"
        - "nochams (Remove chams) -> ;nochams"
        - "xray (See through blocks) -> ;xray"
        - "unxray (Disable xray) -> ;unxray"
        - "fullbright (Max brightness) -> ;fullbright"
        - "spectate (View player) -> ;spectate [player]"
        - "unspectate (Stop viewing) -> ;unspectate"
        - "freecam (Move camera freely) -> ;freecam"
        - "unfreecam (Stop freecam) -> ;unfreecam"
        - "nofog (Remove fog) -> ;nofog"
        - "day (Set time to day) -> ;day"
        - "night (Set time to night) -> ;night"

        [PLAYER INTERACTION]
        - "kill (Kill player) -> ;kill [player]"
        - "loopkill (Kill repeatedly) -> ;loopkill [player]"
        - "unloopkill (Stop loopkill) -> ;unloopkill [player]"
        - "fling (Fling player) -> ;fling [player]"
        - "unfling (Stop fling) -> ;unfling"
        - "bring (Bring player to you) -> ;bring [player]"
        - "freeze (Freeze player) -> ;freeze [player]"
        - "thaw (Unfreeze player) -> ;thaw [player]"
        - "bang (Animation) -> ;bang [player]"
        - "unbang (Stop animation) -> ;unbang"
        - "view (Watch player) -> ;view [player]"
        - "unview (Stop watching) -> ;unview"

        [WORKSPACE & TOOLS]
        - "btools (Give building tools) -> ;btools"
        - "f3x (Give F3X tools) -> ;f3x"
        - "delete (Delete part) -> ;delete [name]"
        - "destroyheight (Set void height) -> ;destroyheight [num]"
        - "removeterrain (Delete all terrain) -> ;removeterrain"
        - "tools (Get tools from ReplicatedStorage) -> ;tools"
        - "notools (Remove tools) -> ;notools"
        - "equiptools (Equip all tools) -> ;equiptools"
        - "droptools (Drop all tools) -> ;droptools"

        [DANGEROUS / OP]
        - "fling (High-torque rotation to launch players) -> ;fling"
        - "invisfling (Invisible collision destruction) -> ;invisfling"
        - "walkfling (Kill aura without spinning) -> ;walkfling"
        - "loopoof (Spam 'oof' sound to server) -> ;loopoof"
        - "tpunanchored (Bring all unanchored parts to player) -> ;tpunanchored [player]"
        - "freezeunanchored (Freeze all unanchored parts) -> ;freezeunanchored"
        - "handlekill (Instant kill using tool handle) -> ;handlekill [player]"
        - "clearnilinstances (Destroy hidden/nil instances) -> ;clearnilinstances"
        - "firetouchinterests (Trigger all touch events/traps) -> ;firetouchinterests"
        - "fireclickdetectors (Trigger all buttons/clicks) -> ;fireclickdetectors"
        - "crash (Attempt to crash server via overload) -> ;crash"
        - "clientantikick (Prevent being kicked) -> ;clientantikick"
        - "clientantiteleport (Prevent being teleported) -> ;clientantiteleport"
        - "clearhats (Remove all hats in workspace) -> ;clearhats"
        - "lagswitch (Freeze traffic) -> ;lagswitch [on/off]"
        
        ### DYNAMIC INSTRUCTIONS ###
        - Use [SYSTEM DATA] to match player names.
        - If [FEEDBACK ERROR] occurs, correct the username and retry.
        - If the user implies "all" or "everyone" (e.g., "kill everyone"), use the argument "all".
        - Priority: If a request matches a [DANGEROUS / OP] command, execute it ONLY if the intent is clear (e.g. "destroy the server", "crash", "fling him").
    ]],
}

-- 2. SERVICES & CONTEXT
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local User = Players.LocalPlayer or Players.PlayerAdded:Wait()
local GameName = "Loading..." 

-- Async Game Name Fetcher
task.spawn(function()
    local success, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
    if success and info then
        GameName = info.Name
    else
        GameName = "Unknown Game"
    end
end)

local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if not httpRequest then warn("SIY: Executor incompatible.") end

-- 3. THE BRIDGE (PRESERVED & STABLE)
local IY_Interface = nil

task.spawn(function()
    if getgenv().PseudoBridge then 
        IY_Interface = getgenv().PseudoBridge
        return 
    end

    if not game.CoreGui:FindFirstChild("InfiniteYield") then
        local Success, IY_Source = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source") end)
        if Success then
            local BridgeCode = [[ getgenv().PseudoBridge = { Exec = function(cmd) if execCmd then execCmd(cmd) end end } ]]
            loadstring(IY_Source .. "\n" .. BridgeCode)()
        end
    end
    
    local timeout = 0
    repeat task.wait(0.2); timeout = timeout + 0.2 until getgenv().PseudoBridge or timeout > 10
    IY_Interface = getgenv().PseudoBridge
end)

-- 4. GUI CONSTRUCTION
if CoreGui:FindFirstChild("SmartInfiniteYieldGUI") then CoreGui.SmartInfiniteYieldGUI:Destroy() end
local SIY_Screen = Instance.new("ScreenGui")
SIY_Screen.Name = "SmartInfiniteYieldGUI"
SIY_Screen.Parent = CoreGui 
SIY_Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Colors = {
    Background = Color3.fromRGB(20, 20, 25),
    InputBg    = Color3.fromRGB(30, 30, 35),
    Orange     = Color3.fromRGB(255, 140, 0), -- CMD
    Blue       = Color3.fromRGB(0, 190, 255), -- Chat
    Green      = Color3.fromRGB(0, 255, 160), -- Success/Thinking
    Red        = Color3.fromRGB(255, 80, 80), -- Error
    Text       = Color3.fromRGB(240, 240, 240),
    TextDim    = Color3.fromRGB(150, 150, 160)
}

local function addCorner(obj, radius)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius); c.Parent = obj; return c
end

-- Floating Icon
local OpenButton = Instance.new("ImageButton")
OpenButton.Size = UDim2.new(0, 45, 0, 45)
OpenButton.Position = UDim2.new(0, 20, 0.5, -22)
OpenButton.BackgroundColor3 = Colors.Background
OpenButton.Image = "rbxassetid://6035193498"
OpenButton.ImageColor3 = Colors.Green
OpenButton.Visible = false
OpenButton.Parent = SIY_Screen
addCorner(OpenButton, 12)

-- Main Bar
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 55) 
MainFrame.Position = UDim2.new(0.5, -250, 0.15, 0)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = SIY_Screen
addCorner(MainFrame, 10)

-- Glow/Stroke (Animated)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Colors.Orange 
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 2)
Shadow.Size = UDim2.new(1, 15, 1, 15)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6015897843"
Shadow.ImageColor3 = Color3.new(0,0,0)
Shadow.ImageTransparency = 0.5 
Shadow.ZIndex = -1
Shadow.Parent = MainFrame

-- Controls
local ModeBtn = Instance.new("TextButton")
ModeBtn.Size = UDim2.new(0, 80, 0, 32)
ModeBtn.Position = UDim2.new(0, 12, 0.5, -16)
ModeBtn.BackgroundColor3 = Colors.Orange
ModeBtn.Text = "CMD"
ModeBtn.TextColor3 = Color3.new(0,0,0)
ModeBtn.Font = Enum.Font.GothamBold
ModeBtn.TextSize = 13
ModeBtn.Parent = MainFrame
addCorner(ModeBtn, 6)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -44, 0.5, -16)
MinBtn.BackgroundColor3 = Colors.InputBg
MinBtn.Text = "-"
MinBtn.TextColor3 = Colors.TextDim
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
MinBtn.Parent = MainFrame
addCorner(MinBtn, 6)

-- Input Field
local InputContainer = Instance.new("Frame")
InputContainer.Size = UDim2.new(1, -150, 0, 32)
InputContainer.Position = UDim2.new(0, 102, 0.5, -16)
InputContainer.BackgroundColor3 = Colors.InputBg
InputContainer.Parent = MainFrame
addCorner(InputContainer, 6)

local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1, -20, 1, 0)
InputBox.Position = UDim2.new(0, 10, 0, 0)
InputBox.BackgroundTransparency = 1
InputBox.Text = ""
InputBox.PlaceholderText = "Enter command..."
InputBox.TextColor3 = Colors.Text
InputBox.PlaceholderColor3 = Colors.TextDim
InputBox.Font = Enum.Font.GothamMedium
InputBox.TextSize = 14
InputBox.TextXAlignment = Enum.TextXAlignment.Left
InputBox.ClearTextOnFocus = false
InputBox.Parent = InputContainer

-- [[ COMPONENT: TUTORIAL & TRADEMARK ]]
local TutorialFrame = Instance.new("Frame")
TutorialFrame.Name = "Tutorial"
TutorialFrame.Size = UDim2.new(0, 420, 0, 240)
TutorialFrame.Position = UDim2.new(0.5, -210, 0.5, -120)
TutorialFrame.BackgroundColor3 = Colors.Background
TutorialFrame.Parent = SIY_Screen
TutorialFrame.Visible = true 
addCorner(TutorialFrame, 16)

local TutStroke = Instance.new("UIStroke")
TutStroke.Color = Colors.Green
TutStroke.Thickness = 1
TutStroke.Transparency = 0.5
TutStroke.Parent = TutorialFrame

local TutTitle = Instance.new("TextLabel")
TutTitle.Size = UDim2.new(1, 0, 0, 40)
TutTitle.Position = UDim2.new(0, 0, 0, 15)
TutTitle.BackgroundTransparency = 1
TutTitle.Text = "Welcome to Smart IY"
TutTitle.TextColor3 = Colors.Text
TutTitle.Font = Enum.Font.GothamBold
TutTitle.TextSize = 20
TutTitle.Parent = TutorialFrame

local TutDesc = Instance.new("TextLabel")
TutDesc.Size = UDim2.new(1, -40, 0, 110)
TutDesc.Position = UDim2.new(0, 20, 0, 55)
TutDesc.BackgroundTransparency = 1
TutDesc.Text = "This AI Assistant allows natural language control.\n\n<font color='#ff8c00'><b>CMD MODE</b></font> : Translates requests to commands.\n<i>'Fly me' -> ';fly'</i>\n\n<font color='#00beff'><b>CHAT MODE</b></font> : Ask the AI for game help.\n<i>'How do I win?' -> Notification</i>"
TutDesc.TextColor3 = Colors.TextDim
TutDesc.Font = Enum.Font.Gotham
TutDesc.TextSize = 14
TutDesc.RichText = true
TutDesc.TextWrapped = true
TutDesc.Parent = TutorialFrame

-- [[ TRADEMARK ]]
local Trademark = Instance.new("TextLabel")
Trademark.Size = UDim2.new(1, 0, 0, 20)
Trademark.Position = UDim2.new(0, 0, 1, -15) 
Trademark.BackgroundTransparency = 1
Trademark.Text = "Created by VolQ5"
Trademark.TextColor3 = Color3.fromRGB(100, 100, 100)
Trademark.Font = Enum.Font.Gotham
Trademark.TextSize = 10
Trademark.Parent = TutorialFrame

local TutBtn = Instance.new("TextButton")
TutBtn.Size = UDim2.new(0, 120, 0, 36)
TutBtn.Position = UDim2.new(0.5, -60, 1, -55)
TutBtn.BackgroundColor3 = Colors.Green
TutBtn.Text = "Launch"
TutBtn.TextColor3 = Color3.new(0,0,0)
TutBtn.Font = Enum.Font.GothamBold
TutBtn.TextSize = 14
TutBtn.Parent = TutorialFrame
addCorner(TutBtn, 8)

TutBtn.MouseButton1Click:Connect(function()
    TweenService:Create(TutorialFrame, TweenInfo.new(0.3), {BackgroundTransparency=1}):Play()
    for _,c in pairs(TutorialFrame:GetDescendants()) do
        if c:IsA("TextLabel") or c:IsA("TextButton") then
            TweenService:Create(c, TweenInfo.new(0.3), {TextTransparency=1, BackgroundTransparency=1}):Play()
        end
    end
    task.wait(0.3)
    TutorialFrame.Visible = false
end)


-- 5. LOGIC ENGINE
local IS_CHAT_MODE = false

-- Draggable Logic
local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging=true; dragStart=input.Position; startPos=frame.Position 
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(frame, TweenInfo.new(0.05), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
        end
    end)
    frame.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
end
makeDraggable(MainFrame); makeDraggable(OpenButton)

-- Logic Helpers
local function getChatPrompt()
    -- [[ FIX: ENSURE GAME NAME IS UPDATED ]]
    local displayName = (GameName ~= "Loading...") and GameName or "this game"
    return string.format([[
        You are a helpful Infinite Yield Assistant for the player '%s'.
        Playing: '%s'. RULES: Give advice specific to '%s' (max 20 words). No markdown.
    ]], User.Name, displayName, displayName)
end

local function getPlayerList()
    local names = {}; for _, p in pairs(Players:GetPlayers()) do table.insert(names, p.Name) end
    return table.concat(names, ", ")
end

local TargetTriggers = {"kill", "fling", "goto", "tp", "spectate", "view", "watch", "bring", "to", "attach", "loopkill"}
local function needsPlayerContext(text)
    local lowerText = text:lower()
    for _, trigger in ipairs(TargetTriggers) do if string.find(lowerText, trigger) then return true end end
    return false
end

-- [[ CRITICAL FIX: EXECUTION BRIDGE ]]
local function executeBridge(text)
    if not IY_Interface then 
        warn("SIY: Bridge not connected.")
        InputBox.PlaceholderText = "Error: Bridge Failed"
        InputBox.PlaceholderColor3 = Colors.Red
        return 
    end
    
    local cleanText = text:gsub("^%s*", ""):gsub("%s*$", "")
    
    if IS_CHAT_MODE then
        -- [[ CLEAN CHAT FIX: NO PREFIX ]]
        local safeText = cleanText:gsub("'", ""):gsub('"', '')
        -- Just send the AI text directly, no "Gemini " prefix
        IY_Interface.Exec("notify " .. safeText) 
    else
        -- [[ CMD FIX: STRIP PREFIX ]]
        if cleanText:sub(1,1) == ";" then
            local rawCommand = cleanText:sub(2) 
            IY_Interface.Exec(rawCommand) 
        else
            warn("AI Output Error: " .. cleanText)
            IY_Interface.Exec("notify Error Invalid AI Syntax.")
        end
    end
end

-- [[ 5.1 LOGIC ENGINE: THE BRAIN (INTEGRATED) ]]
-- This section handles Reflexes (Auto-Events) and Guardrails (Safety)
local SIY_Brain = {
    -- [REFLEXES: AUTO-TRIGGERS]
    Reflexes = {
        ['CharacterAdded'] = {
            'esp',          -- Keep visuals active on death
            'chams',        -- Keep visuals active on death
            'fly',          -- Re-enable flight on respawn
            'loopspeed',    -- Maintain speed advantage
            'loopjumppower',-- Maintain jump advantage
            'autojump',     -- Keep bunnyhopping
            'infinitejump'  -- Keep air-jump
        },
        ['PlayerAdded'] = {
            'notify New Player Joined', -- Proactive awareness
            'staffwatch'    -- Check if they are an admin
        },
        ['ChildAdded'] = {
            'partesp',      -- Highlight new objectives instantly
            'grabtools'     -- Auto-steal new tools
        }
    },

    -- [GUARDRAILS: SAFETY PROTOCOLS]
    Guardrails = {
        ['speed'] = { 
            Limit = 150, 
            Warning = "High Risk > 150. Consider ';spoofspeed' instead.",
            RiskLevel = "Medium"
        },
        ['jumppower'] = { 
            Limit = 100, 
            Warning = "Physics Check Risk. Use ';spoofjumppower'.",
            RiskLevel = "Medium"
        },
        ['fly'] = { 
            Recommended = "vehiclefly",
            Warning = "Standard fly is detectable in newer games."
        },
        ['cframefly'] = { 
            Note = "Safest option for anti-cheat games."
        },
        ['noclip'] = { 
            Warning = "May fail on thick walls (MeshParts)."
        },
        ['invisfling'] = { 
            Requirement = "Use ';god' first to prevent self-death.",
            RiskLevel = "High"
        }
    }
}

local ActiveStates = {} -- Tracks what the user has turned on
local OriginalExec = nil -- Storage for the real IY execution function

-- Middleware: Intercepts commands to check Guardrails
local function checkGuardrails(cmdString)
    local cmd = cmdString:split(" ")[1]:sub(2) -- Remove ";"
    local args = cmdString:split(" ")
    local value = tonumber(args[2])

    local protocol = SIY_Brain.Guardrails[cmd]
    if protocol then
        -- Check Logic: Speed Limit
        if value and protocol.Limit and value > protocol.Limit then
            local msg = "notify [AI WARNING] " .. protocol.Warning
            if OriginalExec then OriginalExec(msg) else executeBridge(msg) end
            task.wait(0.1) 
        end
        -- Check Logic: Dependencies
        if protocol.Requirement then
             local msg = "notify [AI TIP] " .. protocol.Requirement
             if OriginalExec then OriginalExec(msg) else executeBridge(msg) end
        end
    end
    
    -- Track State (Remember that user turned this ON)
    if not cmdString:find("un") and not cmdString:find("no") then
        ActiveStates[cmd] = true
    elseif cmdString:find("un") or cmdString:find("no") then
        -- If user types ;unfly, remove 'fly' from active states
        local clean = cmd:gsub("un", ""):gsub("no", "")
        ActiveStates[clean] = nil
    end
end

-- Handler: Auto-Reflex System
local function activateReflexes()
    Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1) -- Wait for load
        -- Check what was active before death
        for cmd, isActive in pairs(ActiveStates) do
            if isActive and table.find(SIY_Brain.Reflexes['CharacterAdded'], cmd) then
                if OriginalExec then OriginalExec("notify [AI] Restoring " .. cmd .. "...") end
                executeBridge(";" .. cmd)
            end
        end
    end)

    Players.PlayerAdded:Connect(function(p)
        if ActiveStates['staffwatch'] then
            executeBridge(";staffwatch") -- Re-trigger checks
        end
    end)
end

-- Async Hook: Connects Brain to Bridge once loaded
task.spawn(function()
    -- Wait for Bridge to be ready
    local timeout = 0
    repeat task.wait(0.5); timeout = timeout + 0.5 until IY_Interface and IY_Interface.Exec or timeout > 15
    
    if IY_Interface and IY_Interface.Exec then
        OriginalExec = IY_Interface.Exec
        -- Activate Reflexes
        activateReflexes()
        -- Activate Guardrails Hook
        IY_Interface.Exec = function(cmd)
            checkGuardrails(cmd) -- Run checks
            OriginalExec(cmd)    -- Execute Command
        end
        print("SIY: Brain Connected & Logic Engine Online.")
    else
        warn("SIY: Failed to hook Brain Logic.")
    end
end)

-- [[ LOGIC FIX: ROBUST TARGET VALIDATION ]]
local function validateCommandTarget(cmdString)
    local args = cmdString:split(" ")
    if #args < 2 then return true, "" end -- No arguments? Safe to execute.

    -- Isolate the command name (remove ";" and lowercase)
    local cmdName = args[1]:sub(2):lower()
    local targetArg = args[2]

    -- LIST: Commands that strictly require a PLAYER target
    -- We ONLY check the database if the command is in this list.
    local PlayerTargetCommands = {
        "kill", "loopkill", "unloopkill",
        "fling", "unfling", "loopfling", "invisfling",
        "goto", "bring", "to", "tp",
        "spectate", "view", "watch",
        "freeze", "thaw",
        "bang", "attach", "handlekill",
        "firetouchinterests"
    }

    -- 1. BYPASS: If command is NOT in the list (e.g. speed, time, notify), allow it.
    if not table.find(PlayerTargetCommands, cmdName) then
        return true, "" 
    end

    -- 2. VALIDATION: If it IS in the list, strictly check for a valid player.
    -- Check special keywords first
    if table.find({"me", "all", "others", "random"}, targetArg:lower()) then 
        return true, "" 
    end
    
    -- Check exact match
    if Players:FindFirstChild(targetArg) then 
        return true, "" 
    end

    -- Check fuzzy match (e.g. "bac" -> "BaconHair123")
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #targetArg) == targetArg:lower() then 
            return true, "" 
        end
    end
    
    return false, "Target '"..targetArg.."' not found."
end

-- Logic: Visual Reset
local function resetVisuals()
    local pulse = TweenService:Create(MainStroke, TweenInfo.new(0.3), {Transparency = 0})
    pulse:Play()
    InputBox.TextEditable = true
    InputBox.Text = "" 
    InputBox.PlaceholderColor3 = Colors.TextDim
    -- [[ FIX: UI UPDATE ]]
    local uiName = (GameName ~= "Loading...") and GameName or "game"
    InputBox.PlaceholderText = IS_CHAT_MODE and ("Ask about " .. uiName .. "...") or "Enter command..."
end

-- Logic: Recursive Query
function queryAI(promptText, retryContext, attemptCount)
    attemptCount = attemptCount or 0
    
    local statusText = (attemptCount > 0) and "Fixing..." or "Thinking..."
    local statusColor = (attemptCount > 0) and Colors.Orange or Colors.Green
    InputBox.PlaceholderText = statusText
    InputBox.PlaceholderColor3 = statusColor
    InputBox.TextEditable = false
    
    local pulse = TweenService:Create(MainStroke, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.5})
    pulse:Play()
    
    if attemptCount > CONFIG.MaxRetries then 
        InputBox.PlaceholderText = "Failed: Target invalid."
        InputBox.PlaceholderColor3 = Colors.Red
        task.wait(2); resetVisuals(); return 
    end

    local systemPayload = IS_CHAT_MODE and getChatPrompt() or CONFIG.CommandPrompt
    local userPayload = promptText

    if not IS_CHAT_MODE and needsPlayerContext(promptText) then
        userPayload = userPayload .. "\n[SYSTEM DATA: Current Players: " .. getPlayerList() .. "]"
    end
    if retryContext then userPayload = userPayload .. "\n[FEEDBACK ERROR: " .. retryContext .. "]" end

    local body = HttpService:JSONEncode({
        model = CONFIG.Model,
        messages = { {role = "system", content = systemPayload}, {role = "user", content = userPayload} },
        temperature = 0.3
    })

    task.spawn(function()
        local success, response = pcall(function()
            return httpRequest({
                Url = CONFIG.Endpoint, Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body
            })
        end)

        pulse:Cancel() 

        if success and response.StatusCode == 200 then
            local data = HttpService:JSONDecode(response.Body)
            local aiOutput = data.choices[1].message.content
            
            if IS_CHAT_MODE then
                 executeBridge(aiOutput); resetVisuals()
            else
                local cleanCmd = aiOutput:gsub("^%s*", ""):gsub("%s*$", "")
                if cleanCmd:sub(1,1) == ";" then
                    local isValid, errorMsg = validateCommandTarget(cleanCmd)
                    if isValid then 
                        executeBridge(cleanCmd); resetVisuals()
                    else
                        queryAI(promptText, errorMsg, attemptCount + 1)
                    end
                else
                    executeBridge("notify Gemini Output Invalid"); resetVisuals()
                end
            end
        else
            InputBox.PlaceholderText = "Connection Error"
            InputBox.PlaceholderColor3 = Colors.Red
            task.wait(2); resetVisuals()
        end
    end)
end

-- 6. EVENTS & HANDLERS
InputBox.FocusLost:Connect(function(enter)
    if enter and InputBox.Text ~= "" then
        local text = InputBox.Text
        InputBox.Text = "" 
        queryAI(text) 
    end
end)

MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenButton.Visible = true end)
OpenButton.MouseButton1Click:Connect(function() OpenButton.Visible = false; MainFrame.Visible = true end)

ModeBtn.MouseButton1Click:Connect(function()
    IS_CHAT_MODE = not IS_CHAT_MODE
    local uiName = (GameName ~= "Loading...") and GameName or "game"
    if IS_CHAT_MODE then
        ModeBtn.Text = "CHAT"
        TweenService:Create(ModeBtn, TweenInfo.new(0.3), {BackgroundColor3 = Colors.Blue}):Play()
        TweenService:Create(MainStroke, TweenInfo.new(0.3), {Color = Colors.Blue}):Play()
        InputBox.PlaceholderText = "Ask about " .. uiName .. "..."
    else
        ModeBtn.Text = "CMD"
        TweenService:Create(ModeBtn, TweenInfo.new(0.3), {BackgroundColor3 = Colors.Orange}):Play()
        TweenService:Create(MainStroke, TweenInfo.new(0.3), {Color = Colors.Orange}):Play()
        InputBox.PlaceholderText = "Enter command..."
    end
end)
