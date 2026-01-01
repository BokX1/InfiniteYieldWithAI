--[[ 
    SMART INFINITE YIELD - V1.1 FINAL
    - Architecture: Context Awareness
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
        Task: Translate text to Infinite Yield syntax.

        ### RULES ###
        1. STOP/REMOVE: Critical. Find 'un'/'no' variant (e.g. stop fly -> ;unfly).
        2. INFER: Fast->;speed 100. Privacy->;serverhop. Lag->;nocals. Crash->;crash.
        3. SYNTAX: Stats->add [num]. Actions->add [player]. "Everyone"->"all".

        ### COMMANDS ###
        ;fly/unfly ;noclip/clip ;vfly/unvfly ;cfly/uncfly ;float/unfloat ;swim/unswim ;tpwalk/untpwalk
        ;esp/noesp ;chams/nochams ;xray/unxray ;spectate/unspectate ;freecam/unfreecam ;fullbright/unloopfullbright
        ;kill ;loopkill ;fling/unfling ;invisfling ;walkfling ;loopoof/unloopoof ;god ;invisible/visible
        ;speed ;jumppower ;sit/unnosit ;infjump/uninfjump ;autojump/unautojump ;stun/unstun ;platform
        ;goto ;bring ;to ;spawnpoint ;flashback ;serverhop ;rejoin ;jobid ;gametp ;tppos
        ;btools ;f3x ;delete ;partpath ;rterrain ;destroyheight ;tools ;equiptools ;grabtools
        ;crash ;lagswitch ;hkill ;cni ;touchinterests ;firecd ;cleanhats ;ip ;getip
        ;spam/unspam ;pmspam/unpmspam ;logs ;chatlogs ;console ;explorer ;remotespy
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

-- 4. GUI CONSTRUCTION (WITH SMART STATUS BAR)
if CoreGui:FindFirstChild("SmartInfiniteYieldGUI") then CoreGui.SmartInfiniteYieldGUI:Destroy() end

local SIY_Screen = Instance.new("ScreenGui")
SIY_Screen.Name = "SmartInfiniteYieldGUI"
SIY_Screen.Parent = CoreGui 
SIY_Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SIY_Screen.ResetOnSpawn = false

-- [A] Services & Utils
local UIS = game:GetService("UserInputService")
local IsMobile = UIS.TouchEnabled and not UIS.MouseEnabled

local Colors = {
    Background = Color3.fromRGB(20, 20, 20),
    InputBg    = Color3.fromRGB(30, 30, 30),
    Border     = Color3.fromRGB(60, 60, 60),
    Orange     = Color3.fromRGB(255, 145, 40), 
    Blue       = Color3.fromRGB(50, 180, 255), 
    Green      = Color3.fromRGB(40, 230, 130),
    Text       = Color3.fromRGB(240, 240, 240),
    TextDim    = Color3.fromRGB(150, 150, 150),
    Status     = Color3.fromRGB(200, 200, 200) -- New Status Color
}

local function addCorner(obj, radius)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius); c.Parent = obj; return c
end

local function addStroke(obj, color, thickness)
    local s = Instance.new("UIStroke"); s.Color = color; s.Thickness = thickness; s.Parent = obj; return s
end

-- [B] UNIVERSAL DRAG SYSTEM
local function enableDrag(frame)
    local dragToggle, dragStart, startPos
    local dragInput
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(frame, TweenInfo.new(0.08), {Position = position}):Play()
    end
    
    frame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragToggle = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then dragInput = input end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then updateInput(input) end
    end)
end

-- [C] MAIN UI COMPONENTS

-- 1. Floating Icon
local OpenButton = Instance.new("ImageButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 45, 0, 45)
OpenButton.Position = UDim2.new(0, 15, 0.4, 0)
OpenButton.BackgroundColor3 = Colors.Background
OpenButton.Image = "rbxassetid://6035193498" 
OpenButton.ImageColor3 = Colors.Green
OpenButton.Visible = false
OpenButton.Parent = SIY_Screen
addCorner(OpenButton, 100) 
addStroke(OpenButton, Colors.Border, 1)
enableDrag(OpenButton)

-- 2. Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0) 
-- Adjusted Height for Status Bar (+15px)
local MainSize = IsMobile and UDim2.new(0.8, 0, 0, 60) or UDim2.new(0, 500, 0, 65)
MainFrame.Size = MainSize
MainFrame.Position = UDim2.new(0.5, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = SIY_Screen
addCorner(MainFrame, 8)
enableDrag(MainFrame)

local MainStroke = addStroke(MainFrame, Colors.Orange, 1)

-- 3. Controls
local BtnWidth = IsMobile and 55 or 80
local FontSize = IsMobile and 11 or 14

-- Mode Toggle
local ModeBtn = Instance.new("TextButton")
ModeBtn.Size = UDim2.new(0, BtnWidth, 0, 30) -- Fixed Height
ModeBtn.Position = UDim2.new(0, 8, 0, 8)
ModeBtn.BackgroundColor3 = Colors.Orange
ModeBtn.Text = "CMD"
ModeBtn.TextColor3 = Color3.new(0,0,0)
ModeBtn.Font = Enum.Font.GothamBold
ModeBtn.TextSize = FontSize
ModeBtn.Parent = MainFrame
addCorner(ModeBtn, 6)

-- Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.AnchorPoint = Vector2.new(1, 0)
MinBtn.Position = UDim2.new(1, -8, 0, 8)
MinBtn.BackgroundColor3 = Colors.InputBg
MinBtn.Text = "-"
MinBtn.TextColor3 = Colors.TextDim
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
MinBtn.Parent = MainFrame
addCorner(MinBtn, 6)

-- Input Area
local InputContainer = Instance.new("Frame")
local LeftPad = 8 + BtnWidth + 8
local RightPad = 8 + 30 + 8
InputContainer.Size = UDim2.new(1, -(LeftPad+RightPad), 0, 30)
InputContainer.Position = UDim2.new(0, LeftPad, 0, 8)
InputContainer.BackgroundColor3 = Colors.InputBg
InputContainer.Parent = MainFrame
addCorner(InputContainer, 6)

local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1, -12, 1, 0)
InputBox.Position = UDim2.new(0, 6, 0, 0)
InputBox.BackgroundTransparency = 1
InputBox.Text = ""
InputBox.PlaceholderText = IsMobile and "Tap to type..." or "Enter command..."
InputBox.TextColor3 = Colors.Text
InputBox.PlaceholderColor3 = Colors.TextDim
InputBox.Font = Enum.Font.GothamMedium
InputBox.TextSize = 14
InputBox.TextXAlignment = Enum.TextXAlignment.Left
InputBox.ClearTextOnFocus = false
InputBox.Parent = InputContainer

-- [[ NEW: STATUS BAR ]]
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Size = UDim2.new(1, -20, 0, 15)
StatusLabel.Position = UDim2.new(0, 10, 0, 42) -- Below buttons
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ">> Ready"
StatusLabel.TextColor3 = Colors.TextDim
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextTransparency = 0.5
StatusLabel.Parent = MainFrame

-- 4. Minimal Tutorial
local TutSize = IsMobile and UDim2.new(0.8, 0, 0, 200) or UDim2.new(0, 400, 0, 200)
local TutorialFrame = Instance.new("Frame")
TutorialFrame.Name = "Tutorial"
TutorialFrame.AnchorPoint = Vector2.new(0.5, 0.5)
TutorialFrame.Size = TutSize
TutorialFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
TutorialFrame.BackgroundColor3 = Colors.Background
TutorialFrame.ZIndex = 10 
TutorialFrame.Parent = SIY_Screen
addCorner(TutorialFrame, 12)
addStroke(TutorialFrame, Colors.Border, 1)

local TutTitle = Instance.new("TextLabel")
TutTitle.Size = UDim2.new(1, 0, 0, 30)
TutTitle.Position = UDim2.new(0, 0, 0, 10)
TutTitle.BackgroundTransparency = 1
TutTitle.Text = "Smart IY"
TutTitle.TextColor3 = Colors.Text
TutTitle.Font = Enum.Font.GothamBold
TutTitle.TextSize = 18
TutTitle.Parent = TutorialFrame

local TutDesc = Instance.new("TextLabel")
TutDesc.Size = UDim2.new(1, -30, 1, -80)
TutDesc.Position = UDim2.new(0, 15, 0, 40)
TutDesc.BackgroundTransparency = 1
TutDesc.Text = "<b>CMD MODE:</b> Translates logic to IY commands.\n<i>(e.g., 'Fly me' -> ';fly')</i>\n\n<b>CHAT MODE:</b> Ask questions about the game.\n<i>(e.g., 'How do I play?')</i>"
TutDesc.TextColor3 = Colors.TextDim
TutDesc.Font = Enum.Font.Gotham
TutDesc.TextSize = 14
TutDesc.RichText = true
TutDesc.TextWrapped = true
TutDesc.Parent = TutorialFrame

local Trademark = Instance.new("TextLabel")
Trademark.Size = UDim2.new(1, 0, 0, 15)
Trademark.Position = UDim2.new(0, 0, 1, -10) 
Trademark.BackgroundTransparency = 1
Trademark.Text = "VolQ5"
Trademark.TextColor3 = Color3.fromRGB(80, 80, 80)
Trademark.Font = Enum.Font.Gotham
Trademark.TextSize = 9
Trademark.Parent = TutorialFrame

local TutBtn = Instance.new("TextButton")
TutBtn.Size = UDim2.new(0, 100, 0, 32)
TutBtn.Position = UDim2.new(0.5, -50, 1, -45)
TutBtn.BackgroundColor3 = Colors.Green
TutBtn.Text = "Start"
TutBtn.TextColor3 = Color3.new(0,0,0)
TutBtn.Font = Enum.Font.GothamBold
TutBtn.TextSize = 13
TutBtn.Parent = TutorialFrame
addCorner(TutBtn, 6)

TutBtn.MouseButton1Click:Connect(function()
    TweenService:Create(TutorialFrame, TweenInfo.new(0.2), {BackgroundTransparency=1}):Play()
    for _,c in pairs(TutorialFrame:GetDescendants()) do
        if c:IsA("GuiObject") then TweenService:Create(c, TweenInfo.new(0.2), {Transparency=1}):Play() end
    end
    task.wait(0.2)
    TutorialFrame.Visible = false
end)

-- 5. LOGIC ENGINE (OPTIMIZED - SEMICOLON SUPPORT ADDED)
local IS_CHAT_MODE = false

-- [A] FAST MAP
local FastMap = {
    -- [[ 1. UTILITY & GUI ]]
    ["^console$"] = "console", ["^logs$"] = "logs", ["^chatlogs$"] = "chatlogs",
    ["^explorer$"] = "explorer", ["^dex$"] = "explorer", ["^odex$"] = "olddex",
    ["^remotespy$"] = "remotespy", ["^rspy$"] = "remotespy",
    ["^guiscale (%d+)"] = "guiscale %1",
    ["^rejoin$"] = "rejoin", ["^rj$"] = "rejoin",
    ["^serverhop$"] = "serverhop", ["^shop$"] = "serverhop",
    ["^jobid$"] = "jobid", ["^copyjobid$"] = "jobid",
    ["^volume (%d+)"] = "volume %1", ["^vol (%d+)"] = "volume %1",
    ["^antilag$"] = "antilag", ["^lowgfx$"] = "antilag",
    ["^fpscap (%d+)"] = "setfpscap %1", ["^maxfps (%d+)"] = "setfpscap %1",
    ["^savegame$"] = "savegame", ["^saveinstance$"] = "savegame",

    -- [[ 2. MOVEMENT (UPDATED FOR SPEED ARGS) ]]
    ["^fly$"] = "fly", ["^fly (.+)"] = "fly %1",
    ["^unfly$"] = "unfly", ["^nofly$"] = "unfly", ["^stop fly"] = "unfly",
    ["^flyspeed (%d+)"] = "flyspeed %1",
    ["^vfly$"] = "vehiclefly", ["^vfly (.+)"] = "vehiclefly %1", 
    ["^vehiclefly$"] = "vehiclefly", ["^vehiclefly (.+)"] = "vehiclefly %1",
    ["^unvfly$"] = "unvehiclefly",
    ["^cfly$"] = "cframefly", ["^cfly (.+)"] = "cframefly %1",
    ["^cframefly$"] = "cframefly", ["^cframefly (.+)"] = "cframefly %1",
    ["^uncfly$"] = "uncframefly",
    ["^noclip$"] = "noclip", ["^clip$"] = "clip", ["^unnoclip$"] = "unnoclip", ["^wall$"] = "noclip",
    ["^vnoclip$"] = "vehiclenoclip", ["^vclip$"] = "vehicleclip",
    ["^speed (%d+)"] = "speed %1", ["^ws (%d+)"] = "speed %1", ["^fast$"] = "speed 100",
    ["^jumppower (%d+)"] = "jumppower %1", ["^jp (%d+)"] = "jumppower %1", ["^jump (%d+)"] = "jumppower %1",
    ["^infjump$"] = "infjump", ["^uninfjump$"] = "uninfjump",
    ["^highjump$"] = "jumppower 100",
    ["^float$"] = "float", ["^unfloat$"] = "unfloat", ["^platform$"] = "float",
    ["^swim$"] = "swim", ["^unswim$"] = "unswim",
    ["^tpwalk (%d+)"] = "tpwalk %1", ["^untpwalk$"] = "untpwalk",
    ["^sit$"] = "sit", ["^unsit$"] = "nosit",

    -- [[ 3. TELEPORT ]]
    ["^goto (.+)"] = "goto %1", ["^to (.+)"] = "goto %1",
    ["^bring (.+)"] = "bring %1",
    ["^tp (.+)"] = "tp %1", ["^tppos (.+)"] = "tppos %1",
    ["^spawnpoint$"] = "spawnpoint", ["^nospawnpoint$"] = "nospawnpoint",
    ["^flashback$"] = "flashback", ["^diedtp$"] = "flashback",
    ["^walltp$"] = "walltp", ["^nowalltp$"] = "nowalltp",

    -- [[ 4. VISUALS & CAMERA ]]
    ["^esp$"] = "esp", ["^noesp$"] = "noesp", ["^unesp$"] = "noesp", ["^stop esp"] = "noesp",
    ["^chams$"] = "chams", ["^nochams$"] = "nochams",
    ["^xray$"] = "xray", ["^noxray$"] = "noxray",
    ["^fullbright$"] = "fullbright", ["^fb$"] = "fullbright", ["^light$"] = "fullbright",
    ["^nofullbright$"] = "unloopfullbright", ["^day$"] = "day", ["^night$"] = "night",
    ["^nofog$"] = "nofog", ["^shadows$"] = "globalshadows", ["^noshadows$"] = "noglobalshadows",
    ["^spectate (.+)"] = "spectate %1", ["^view (.+)"] = "view %1", ["^watch (.+)"] = "view %1",
    ["^unspectate$"] = "unspectate", ["^unview$"] = "unspectate",
    ["^freecam$"] = "freecam", ["^fc$"] = "freecam", ["^unfreecam$"] = "unfreecam", ["^unfc$"] = "unfreecam",
    ["^fcspeed (%d+)"] = "freecamspeed %1",
    ["^fixcam$"] = "fixcam", ["^maxzoom (%d+)"] = "maxzoom %1", ["^fov (%d+)"] = "fov %1",

    -- [[ 5. PLAYER INTERACTIONS ]]
    ["^kill (.+)"] = "kill %1", ["^loopkill (.+)"] = "loopkill %1", ["^unloopkill$"] = "unloopkill",
    ["^fling$"] = "fling", ["^fling (.+)"] = "fling %1",
    ["^unfling$"] = "unfling", ["^loopfling (.+)"] = "loopfling %1",
    ["^invisfling$"] = "invisfling", ["^walkfling$"] = "walkfling",
    ["^bang (.+)"] = "bang %1", ["^unbang$"] = "unbang",
    ["^attach (.+)"] = "attach %1", ["^unattach$"] = "unattach",
    ["^freeze (.+)"] = "freeze %1", ["^thaw (.+)"] = "thaw %1", ["^unfreeze (.+)"] = "thaw %1",
    ["^fire$"] = "fire", ["^unfire$"] = "unfire", ["^smoke$"] = "smoke", ["^unsmoke$"] = "unsmoke",
    ["^inspect (.+)"] = "inspect %1", ["^age (.+)"] = "age %1",

    -- [[ 6. AVATAR & CHARACTER ]]
    ["^reset$"] = "reset", ["^respawn$"] = "respawn", ["^re$"] = "refresh",
    ["^god$"] = "god", ["^ungod$"] = "ungod",
    ["^invisible$"] = "invisible", ["^invis$"] = "invisible",
    ["^visible$"] = "visible", ["^vis$"] = "visible",
    ["^noarms$"] = "noarms", ["^nolegs$"] = "nolegs", ["^nolimbs$"] = "nolimbs", ["^naked$"] = "naked",
    ["^blockhead$"] = "blockhead", ["^blockhats$"] = "blockhats",
    ["^creeper$"] = "creeper",
    ["^drophats$"] = "drophats", ["^nohats$"] = "deletehats",
    ["^spin$"] = "spin", ["^unspin$"] = "unspin",
    ["^animation (.+)"] = "animation %1", ["^dance$"] = "dance", ["^undance$"] = "undance",

    -- [[ 7. WORKSPACE & TOOLS ]]
    ["^btools$"] = "btools", ["^f3x$"] = "f3x",
    ["^delete (.+)"] = "delete %1", ["^remove (.+)"] = "delete %1",
    ["^destroyheight (%d+)"] = "destroyheight %1",
    ["^clickdetectors$"] = "fireclickdetectors", ["^firecd$"] = "fireclickdetectors",
    ["^tools$"] = "tools", ["^notools$"] = "notools", ["^rtools$"] = "notools",
    ["^equiptools$"] = "equiptools", ["^droptools$"] = "droptools",
    ["^reach (%d+)"] = "reach %1", ["^boxreach (%d+)"] = "boxreach %1", ["^noreach$"] = "unreach",
    ["^antivoid$"] = "antivoid", ["^noantivoid$"] = "unantivoid"
}

-- [B] UTILITIES
local function updateStatus(text, color)
    StatusLabel.Text = ">> " .. text
    StatusLabel.TextColor3 = color or Colors.Status
    StatusLabel.TextTransparency = 0
    -- Fade out effect
    TweenService:Create(StatusLabel, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 0.6}):Play()
end

local function getChatPrompt()
    local displayName = (GameName ~= "Loading...") and GameName or "this game"
    return string.format([[
        You are a helpful Infinite Yield Assistant.
        Game: '%s'. User: '%s'. 
        Task: Answer questions about the game mechanics or provide help.
        Constraint: Keep answer under 25 words. Be concise.
    ]], displayName, User.Name)
end

local function getPlayerList()
    local names = {}; for _, p in pairs(Players:GetPlayers()) do table.insert(names, p.Name) end
    return table.concat(names, ", ")
end

local TargetTriggers = {"kill", "fling", "goto", "tp", "spectate", "view", "watch", "bring", "to", "attach", "loopkill", "bang", "freeze"}
local function needsPlayerContext(text)
    local lowerText = text:lower()
    for _, trigger in ipairs(TargetTriggers) do if string.find(lowerText, trigger) then return true end end
    return false
end

-- [C] BRIDGE EXECUTION
local function executeBridge(text, source)
    if not IY_Interface then 
        warn("SIY: Bridge not connected.")
        updateStatus("Error: Bridge Failed", Colors.Red)
        return 
    end
    
    local cleanText = text:gsub("^%s*", ""):gsub("%s*$", "")
    
    if IS_CHAT_MODE then
        -- Chat Mode
        local safeText = cleanText:gsub("'", ""):gsub('"', '')
        IY_Interface.Exec("notify " .. safeText) 
        updateStatus("[AI] Response Sent", Colors.Blue)
    else
        -- CMD Mode
        if cleanText:sub(1,1) == ";" then cleanText = cleanText:sub(2) end
        
        -- VISUAL FEEDBACK
        local prefix = source and ("["..source.."] ") or ""
        updateStatus(prefix .. "Executing: " .. cleanText, Colors.Green)
        
        IY_Interface.Exec(cleanText) 
    end
end

-- [D] TARGET VALIDATION
local function validateCommandTarget(cmdString)
    local args = cmdString:split(" ")
    if #args < 2 then return true, "" end 

    local cmdName = args[1]:lower()
    local targetArg = args[2]

    local PlayerTargetCommands = {
        "kill", "loopkill", "fling", "unfling", "goto", "bring", "to", "tp",
        "spectate", "view", "freeze", "bang", "attach"
    }

    if not table.find(PlayerTargetCommands, cmdName) then return true, "" end
    if table.find({"me", "all", "others", "random"}, targetArg:lower()) then return true, "" end
    if Players:FindFirstChild(targetArg) then return true, "" end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #targetArg) == targetArg:lower() then return true, "" end
    end
    
    return false, "Target '"..targetArg.."' not found."
end

-- [E] VISUAL STATE
local function resetVisuals()
    local pulse = TweenService:Create(MainStroke, TweenInfo.new(0.3), {Transparency = 1})
    pulse:Play()
    InputBox.TextEditable = true
    InputBox.PlaceholderColor3 = Colors.TextDim
    InputBox.PlaceholderText = IS_CHAT_MODE and "Ask about game..." or (IsMobile and "Tap to type..." or "Enter command...")
end

local function setThinkingState(retry)
    InputBox.TextEditable = false
    InputBox.PlaceholderText = retry and "Retrying..." or "Thinking..."
    InputBox.PlaceholderColor3 = retry and Colors.Orange or Colors.Green
    local pulse = TweenService:Create(MainStroke, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0})
    pulse:Play()
end

-- [F] CORE QUERY LOGIC
function queryAI(promptText, retryContext, attemptCount)
    if promptText == "" then return end
    
    -- 1. FAST PATH CHECK (Now supports ;prefix)
    if not IS_CHAT_MODE and not retryContext then
        -- Clean input: Lowercase -> Trim whitespace -> Remove leading semicolon
        local cleanPrompt = promptText:lower():gsub("^%s*", ""):gsub("%s*$", ""):gsub("^;", "")
        
        for pattern, cmd in pairs(FastMap) do
            local matchStart, matchEnd, capture = string.find(cleanPrompt, pattern)
            if matchStart then
                local finalCmd = cmd
                if capture then finalCmd = finalCmd:gsub("%%1", capture) end
                
                local isValid, err = validateCommandTarget(finalCmd)
                if isValid then
                    executeBridge(finalCmd, "FAST") -- Tag as FAST execution
                    resetVisuals()
                    InputBox.Text = "" -- Clear input on success
                    return 
                end
            end
        end
    end

    -- 2. API FALLBACK
    attemptCount = attemptCount or 0
    if attemptCount > CONFIG.MaxRetries then 
        updateStatus("Failed: Invalid Target", Colors.Red)
        task.wait(2); resetVisuals(); return 
    end

    setThinkingState(attemptCount > 0)
    updateStatus("Thinking...", Colors.Orange) -- Update status immediately

    local systemPayload = IS_CHAT_MODE and getChatPrompt() or CONFIG.CommandPrompt
    local userPayload = promptText

    if not IS_CHAT_MODE and needsPlayerContext(promptText) then
        userPayload = userPayload .. "\n[CONTEXT: Players: " .. getPlayerList() .. "]"
    end
    if retryContext then userPayload = userPayload .. "\n[ERROR FIX: " .. retryContext .. "]" end

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

        if success and response.StatusCode == 200 then
            local data = HttpService:JSONDecode(response.Body)
            local aiOutput = data.choices[1].message.content
            
            if IS_CHAT_MODE then
                 executeBridge(aiOutput); resetVisuals()
                 InputBox.Text = ""
            else
                local cleanCmd = aiOutput:gsub("^%s*", ""):gsub("%s*$", "")
                if cleanCmd:sub(1,1) == ";" then cleanCmd = cleanCmd:sub(2) end
                
                local isValid, errorMsg = validateCommandTarget(cleanCmd)
                if isValid then 
                    executeBridge(cleanCmd, "AI") -- Tag as AI execution
                    resetVisuals()
                    InputBox.Text = ""
                else
                    queryAI(promptText, errorMsg, attemptCount + 1)
                end
            end
        else
            updateStatus("Net Error: " .. (response and response.StatusCode or "Unknown"), Colors.Red)
            task.wait(2); resetVisuals()
        end
    end)
end

-- 6. EVENTS & HANDLERS
InputBox.FocusLost:Connect(function(enter)
    if enter and InputBox.Text ~= "" then
        local text = InputBox.Text
        -- Keep text visible while processing, clear only on success
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
        InputBox.PlaceholderText = "Ask about " .. uiName .. "..."
        updateStatus("Switched to Chat Mode", Colors.Blue)
    else
        ModeBtn.Text = "CMD"
        TweenService:Create(ModeBtn, TweenInfo.new(0.3), {BackgroundColor3 = Colors.Orange}):Play()
        InputBox.PlaceholderText = IsMobile and "Tap to type..." or "Enter command..."
        updateStatus("Switched to Command Mode", Colors.Orange)
    end
end)
