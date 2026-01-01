--[[ 
    SMART INFINITE YIELD - V1.2 STABLE
    - Architecture: Context Awareness
    - Logic: VolQ5 & Pollinations.AI (LLM Model)
    - Status: Stable 
]]
    
-- 1. CONFIGURATION
local CONFIG = {
    -- !!! YOUR POLLINATIONS API KEY !!!
    ApiKey = "Null", 
    
    Endpoint = "https://infiniteyieldai.ahazihak03.workers.dev/v1/chat/completions",
    Model = "openai",
    MaxRetries = 2, 
    
    -- [CACHE OPTIMIZATION: ~3500 Tokens] 
    -- This prompt includes the FULL Infinite Yield command database and advanced logic rules.
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

        ### SECTION 3: FEW-SHOT TRAINING ###
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

        [END OF STATIC CONTEXT]
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

-- 4. GUI CONSTRUCTION (WITH GOOGLE-STYLE DROPDOWN)
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
    DropdownBg = Color3.fromRGB(25, 25, 25), -- Slightly distinct
    Border     = Color3.fromRGB(60, 60, 60),
    Orange     = Color3.fromRGB(255, 145, 40), 
    Blue       = Color3.fromRGB(50, 180, 255), 
    Green      = Color3.fromRGB(40, 230, 130),
    Text       = Color3.fromRGB(240, 240, 240),
    TextDim    = Color3.fromRGB(150, 150, 150),
    Status     = Color3.fromRGB(200, 200, 200)
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
ModeBtn.Size = UDim2.new(0, BtnWidth, 0, 30)
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
InputContainer.ZIndex = 2 -- [[ FIX: Prioritize Input over Status ]]
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

-- [[ NEW: SEARCH SUGGESTION DROPDOWN ]]
local SuggestionFrame = Instance.new("Frame")
SuggestionFrame.Name = "Dropdown"
SuggestionFrame.Size = UDim2.new(1, 0, 0, 0) -- Height handled dynamically
SuggestionFrame.Position = UDim2.new(0, 0, 1, 5) -- Hangs below input
SuggestionFrame.BackgroundColor3 = Colors.DropdownBg
SuggestionFrame.BorderSizePixel = 0
SuggestionFrame.Visible = false
SuggestionFrame.ZIndex = 5
SuggestionFrame.Parent = InputContainer
addCorner(SuggestionFrame, 6)
addStroke(SuggestionFrame, Colors.Border, 1)

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = SuggestionFrame

-- Status Bar
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Size = UDim2.new(1, -20, 0, 15)
StatusLabel.Position = UDim2.new(0, 10, 0, 42)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ">> Ready"
StatusLabel.TextColor3 = Colors.TextDim
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextTransparency = 0.5
StatusLabel.Parent = MainFrame

-- 4. Tutorial Modal (UPDATED)
local TutSize = IsMobile and UDim2.new(0.8, 0, 0, 200) or UDim2.new(0, 400, 0, 220)
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
TutTitle.Text = "Smart IY v1.2 Latest"
TutTitle.TextColor3 = Colors.Text
TutTitle.Font = Enum.Font.GothamBold
TutTitle.TextSize = 18
TutTitle.Parent = TutorialFrame

local TutDesc = Instance.new("TextLabel")
TutDesc.Size = UDim2.new(1, -30, 1, -80)
TutDesc.Position = UDim2.new(0, 15, 0, 40)
TutDesc.BackgroundTransparency = 1
TutDesc.Text = "<b>CONTROLS:</b>\n• Toggle Menu: <font color='#40e682'><b>Right Shift</b></font>\n• Autocomplete: <font color='#40e682'><b>Click Suggestion</b></font>\n\n<b>MODES:</b>\n• <b>CMD:</b> 'Fly me' -> ';fly'\n• <b>CHAT:</b> 'How do I win?' -> AI Advice"
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
addCorner(TutBtn, 8)

TutBtn.MouseButton1Click:Connect(function()
    TweenService:Create(TutorialFrame, TweenInfo.new(0.2), {BackgroundTransparency=1}):Play()
    for _,c in pairs(TutorialFrame:GetDescendants()) do
        if c:IsA("GuiObject") then TweenService:Create(c, TweenInfo.new(0.2), {Transparency=1}):Play() end
    end
    task.wait(0.2)
    TutorialFrame.Visible = false
end)

-- 5. LOGIC ENGINE (COMPLETE FAST MAP & TOGGLES)
local IS_CHAT_MODE = false
local BindSystem = {} -- Format: {Key = {Current="fly", Next="unfly"}}

-- [A] TOGGLE DICTIONARY (Automatic Inverses)
local ToggleMap = {
    -- Movement
    ["fly"] = "unfly",       ["unfly"] = "fly",
    ["noclip"] = "clip",     ["clip"] = "noclip", ["noclip"] = "unnoclip", ["unnoclip"] = "noclip",
    ["float"] = "unfloat",   ["unfloat"] = "float",
    ["swim"] = "unswim",     ["unswim"] = "swim",
    ["sit"] = "unsit",       ["unsit"] = "sit",
    ["platform"] = "unplatform", ["unplatform"] = "platform",
    ["vehiclefly"] = "unvehiclefly", ["unvehiclefly"] = "vehiclefly",
    ["cframefly"] = "uncframefly", ["uncframefly"] = "cframefly",
    ["spam"] = "unspam",     ["unspam"] = "spam",
    ["pmspam"] = "unpmspam", ["unpmspam"] = "pmspam",
    
    -- Visuals
    ["esp"] = "noesp",       ["noesp"] = "esp",
    ["chams"] = "nochams",   ["nochams"] = "chams",
    ["xray"] = "noxray",     ["noxray"] = "xray",
    ["fullbright"] = "nofullbright", ["nofullbright"] = "fullbright",
    ["shadows"] = "noshadows", ["noshadows"] = "shadows",
    ["fog"] = "nofog",       ["nofog"] = "fog",
    ["light"] = "nolight",   ["nolight"] = "light",
    
    -- Camera
    ["spectate"] = "unspectate", ["unspectate"] = "spectate",
    ["freecam"] = "unfreecam",   ["unfreecam"] = "freecam",
    ["fc"] = "unfc",             ["unfc"] = "fc",
    ["shiftlock"] = "unshiftlock",
    
    -- Character & Actions
    ["god"] = "ungod",       ["ungod"] = "god",
    ["invisible"] = "visible", ["visible"] = "invisible",
    ["invis"] = "vis",       ["vis"] = "invis",
    ["mute"] = "unmute",     ["unmute"] = "mute",
    ["dance"] = "undance",   ["undance"] = "dance",
    ["spin"] = "unspin",     ["unspin"] = "spin",
    ["tools"] = "notools",   ["notools"] = "tools",
    ["grabtools"] = "ungrabtools", ["ungrabtools"] = "grabtools",
    ["autoclick"] = "unautoclick", ["unautoclick"] = "autoclick",
    ["reach"] = "unreach",   ["unreach"] = "reach",
    ["anim"] = "noanim",     ["noanim"] = "anim"
}

-- [B] FAST MAP (COMPLETE IY DICTIONARY)
local FastMap = {
    -- [[ 0. SYSTEM & ALIASES (NEW) ]]
    ["^help$"] = "help", ["^cmds$"] = "help", ["^commands$"] = "help",
    ["^bind (%w+) (.+)"] = "bind %1 %2", ["^unbind (%w+)"] = "unbind %1",
    ["^addalias (.+) (.+)"] = "addalias %1 %2", ["^removealias (.+)"] = "removealias %1", ["^clraliases$"] = "clraliases",
    ["^addplugin (.+)"] = "addplugin %1", ["^removeplugin (.+)"] = "removeplugin %1", 
    ["^reloadplugin (.+)"] = "reloadplugin %1", ["^addallplugins$"] = "addallplugins",
    ["^breakloops$"] = "breakloops", ["^removecmd (.+)"] = "removecmd %1",

    -- [[ 1. UTILITY ]]
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

    -- [[ 2. MOVEMENT (STRICT NUMBERS FIXED) ]]
    ["^noclip$"] = "noclip", ["^unnoclip$"] = "unnoclip", ["^clip$"] = "clip",
    
    -- CHANGE: (.+) -> (%d+) ensures fly only accepts numbers. 
    -- If text is typed (e.g. "fly goto"), it fails this check and goes to AI.
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

    -- [[ 3. TELEPORT ]]
    ["^setwaypoint (.+)"] = "setwaypoint %1", ["^waypoints$"] = "waypoints", ["^showwaypoints$"] = "showwaypoints", ["^hidewaypoints$"] = "hidewaypoints",
    ["^waypoint (.+)"] = "waypoint %1", ["^tweenwaypoint (.+)"] = "tweenwaypoint %1", ["^walktowaypoint (.+)"] = "walktowaypoint %1",
    ["^deletewaypoint (.+)"] = "deletewaypoint %1", ["^clearwaypoints$"] = "clearwaypoints",
    ["^goto (.+)"] = "goto %1", ["^tweengoto (.+)"] = "tweengoto %1", ["^tweenspeed (%d+)"] = "tweenspeed %1",
    ["^vehiclegoto (.+)"] = "vehiclegoto %1", ["^loopgoto (.+)"] = "loopgoto %1", ["^unloopgoto$"] = "unloopgoto",
    ["^clientbring (.+)"] = "clientbring %1", ["^loopbring (.+)"] = "loopbring %1", ["^unloopbring$"] = "unloopbring",
    ["^spawnpoint$"] = "spawnpoint", ["^nospawnpoint$"] = "nospawnpoint", ["^flashback$"] = "flashback",
    ["^walltp$"] = "walltp", ["^nowalltp$"] = "nowalltp", ["^teleporttool$"] = "teleporttool",

    -- [[ 4. VISUALS ]]
    ["^esp$"] = "esp", ["^noesp$"] = "noesp", ["^espteam$"] = "espteam", ["^esptransparency (%d+)"] = "esptransparency %1",
    ["^partesp (.+)"] = "partesp %1", ["^unpartesp (.+)"] = "unpartesp %1", -- [ADDED]
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

    -- [[ 5. PLAYER ]]
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

    -- [[ 6. CHAT ]]
    ["^logs$"] = "logs", ["^chatlogs$"] = "chatlogs", ["^chat (.+)"] = "chat %1",
    ["^spam (.+)"] = "spam %1", ["^unspam$"] = "unspam",
    ["^whisper (.+)"] = "whisper %1", ["^pmspam (.+)"] = "pmspam %1", ["^unpmspam$"] = "unpmspam",
    ["^bubblechat$"] = "bubblechat", ["^unbubblechat$"] = "unbubblechat",

    -- [[ 7. WORKSPACE ]]
    ["^btools$"] = "btools", ["^f3x$"] = "f3x", ["^delete (.+)"] = "delete %1",
    ["^lockworkspace$"] = "lockworkspace", ["^unlockworkspace$"] = "unlockworkspace",
    ["^gotopart (.+)"] = "gotopart %1", ["^bringpart (.+)"] = "bringpart %1",
    ["^fireclickdetectors$"] = "fireclickdetectors", ["^firetouchinterests$"] = "firetouchinterests",
    ["^removeterrain$"] = "removeterrain", ["^destroyheight (%d+)"] = "destroyheight %1",
    ["^antivoid$"] = "antivoid", ["^unantivoid$"] = "unantivoid",

    -- [[ 8. ANIMATION ]]
    ["^animation (.+)"] = "animation %1", ["^emote (.+)"] = "emote %1", ["^dance$"] = "dance", ["^undance$"] = "undance",
    ["^spasm$"] = "spasm", ["^unspasm$"] = "unspasm", ["^noanim$"] = "noanim", ["^reanim$"] = "reanim",
    ["^stopanimations$"] = "stopanimations",

    -- [[ 9. MOUSE & TOOLS ]]
    ["^autoclick$"] = "autoclick", ["^unautoclick$"] = "unautoclick", ["^mousesensitivity$"] = "mousesensitivity",
    ["^tools$"] = "tools", ["^notools$"] = "notools", ["^grabtools$"] = "grabtools", ["^ungrabtools$"] = "ungrabtools",
    ["^equiptools$"] = "equiptools", ["^unequiptools$"] = "unequiptools", ["^reach (%d+)"] = "reach %1", ["^unreach$"] = "unreach",
    ["^dupetools (%d+)"] = "dupetools %1", ["^droppabletools$"] = "droppabletools", ["^droptools$"] = "droptools", -- [ADDED]

    -- [[ 10. SERVER ]]
    ["^serverinfo$"] = "serverinfo", ["^jobid$"] = "jobid", ["^rejoin$"] = "rejoin", ["^autorejoin$"] = "autorejoin",
    ["^serverhop$"] = "serverhop", ["^gametp (.+)"] = "gametp %1"
}

-- [C] UTILITIES
local function updateStatus(text, color)
    StatusLabel.Text = ">> " .. text
    StatusLabel.TextColor3 = color or Colors.Status
    StatusLabel.TextTransparency = 0
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

-- [D] ADVANCED TARGET RESOLVER
local function resolveTarget(cmdString)
    -- 1. Handle "all" / "everyone" rejection (Safety)
    if cmdString:match("%sall$") or cmdString:match("%severyone$") then
        return nil, "Target 'all' is invalid. Please specify a player."
    end

    -- 2. Handle "me" -> LocalPlayer Name
    if cmdString:match("%sme$") or cmdString:match("%sme%s") then
        local myName = User.Name
        cmdString = cmdString:gsub("%sme$", " " .. myName):gsub("%sme%s", " " .. myName .. " ")
    end

    -- 3. Handle "random" -> Random Player Name
    if cmdString:match("%srandom$") or cmdString:match("%srandom%s") then
        local otherPlayers = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= User then table.insert(otherPlayers, p.Name) end
        end
        
        if #otherPlayers > 0 then
            local randomName = otherPlayers[math.random(1, #otherPlayers)]
            cmdString = cmdString:gsub("%srandom$", " " .. randomName):gsub("%srandom%s", " " .. randomName .. " ")
            updateStatus("Targeting Random: " .. randomName, Colors.Orange)
        else
            return nil, "No other players to target."
        end
    end

    return cmdString, nil
end

-- [E] BRIDGE EXECUTION (CHAIN-AWARE)
local function executeBridge(text, source)
    if not IY_Interface then 
        warn("SIY: Bridge not connected.")
        updateStatus("Error: Bridge Failed", Colors.Red)
        return 
    end
    
    local cleanText = text:gsub("^%s*", ""):gsub("%s*$", "")
    
    if IS_CHAT_MODE then
        -- Chat mode: Just notify the text
        local safeText = cleanText:gsub("'", ""):gsub('"', '')
        IY_Interface.Exec("notify " .. safeText) 
        updateStatus("[AI] Response Sent", Colors.Blue)
    else
        -- CMD Mode: Handle Chains & Binds
        
        -- 1. Remove initial semicolon if present
        if cleanText:sub(1,1) == ";" then cleanText = cleanText:sub(2) end
        
        -- 2. INTERCEPT: Help Command
        if cleanText == "help" then
            IY_Interface.Exec("notify Check Status Bar for help.")
            updateStatus("CMD: ;bind [key] [cmd], RightShift=Toggle", Colors.Green)
            return
        end

        -- 3. INTERCEPT: Binds
        local bindKey, bindCmd = cleanText:match("^bind (%w+) (.+)")
        if bindKey and bindCmd then
            local keyLower = bindKey:lower()
            local opposite = ToggleMap[bindCmd]
            if opposite then
                BindSystem[keyLower] = {Current = bindCmd, Next = opposite}
                updateStatus("Bound '"..bindKey.."' to Toggle ("..bindCmd.."/"..opposite..")", Colors.Green)
            else
                BindSystem[keyLower] = {Current = bindCmd, Next = nil}
                updateStatus("Bound '"..bindKey.."' to '"..bindCmd.."'", Colors.Green)
            end
            return
        end
        
        if cleanText:match("^unbind (%w+)") then
            local unbindKey = cleanText:match("^unbind (%w+)")
            BindSystem[unbindKey:lower()] = nil
            updateStatus("Unbound '"..unbindKey.."'", Colors.Green)
            return
        end
        
        -- 4. CHAIN SPLITTER & EXECUTION
        -- Infinite Yield doesn't support ";cmd1 ;cmd2", so we split manually
        local commands = cleanText:split(";")
        
        task.spawn(function()
            for _, rawCmd in ipairs(commands) do
                -- Clean whitespace
                local cmd = rawCmd:gsub("^%s*", ""):gsub("%s*$", "")
                if cmd ~= "" then
                    -- 5. RESOLVE TARGETS ("me", "random", "all")
                    local finalCmd, err = resolveTarget(cmd)
                    
                    if finalCmd then
                        local prefix = source and ("["..source.."] ") or ""
                        
                        -- Update status
                        if #commands > 1 then
                            updateStatus("Chain: " .. finalCmd, Colors.Green)
                        else
                            updateStatus(prefix .. "Exec: " .. finalCmd, Colors.Green)
                        end
                        
                        IY_Interface.Exec(finalCmd)
                        
                        -- Small delay between chain links
                        if #commands > 1 then task.wait(0.1) end 
                    else
                        updateStatus("Error: " .. (err or "Invalid Cmd"), Colors.Red)
                    end
                end
            end
        end)
    end
end

-- [F] VISUAL STATE
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

-- [G] CORE QUERY LOGIC
function queryAI(promptText, retryContext, attemptCount)
    if promptText == "" then return end
    
    -- [[ 1. MANUAL CHAIN & FAST CHECK ]]
    if not IS_CHAT_MODE and not retryContext then
        -- A. Token Saver: If input contains ';', execute immediately (Skip AI)
        if promptText:find(";") then
            executeBridge(promptText, "MANUAL")
            resetVisuals()
            InputBox.Text = ""
            return
        end

        local cleanPrompt = promptText:lower():gsub("^%s*", ""):gsub("%s*$", ""):gsub("^;", "")

        -- [[ B. CHAIN BREAKER ]] 
        -- If natural chaining (" and ", " & ") is detected, FORCE AI.
        -- This prevents FastMap patterns like '^fly (.+)' from eating the second command.
        local isChain = cleanPrompt:find(" and ") or cleanPrompt:find(" & ") or cleanPrompt:find(" then ")
        
        if not isChain then
            -- C. Fast Map: Only run if NO chain words are present
            for pattern, cmd in pairs(FastMap) do
                local matchStart, matchEnd, capture, capture2 = string.find(cleanPrompt, pattern)
                if matchStart then
                    local finalCmd = cmd
                    if capture then finalCmd = finalCmd:gsub("%%1", capture) end
                    if capture2 then finalCmd = finalCmd:gsub("%%2", capture2) end
                    
                    executeBridge(finalCmd, "FAST")
                    resetVisuals()
                    InputBox.Text = "" 
                    return 
                end
            end
        end
    end

    -- [[ 2. AI EXECUTION ]]
    setThinkingState(false)
    updateStatus("Thinking...", Colors.Orange)

    -- Dynamic Context Construction
    local staticSystem = CONFIG.CommandPrompt
    local dynamicContext = ""
    
    if IS_CHAT_MODE then
        local displayName = (GameName ~= "Loading...") and GameName or "this game"
        
        -- [[ IMPROVED CHAT CONTEXT ]]
        dynamicContext = string.format([[
            [SYSTEM OVERRIDE: CHAT MODE]
            IGNORE "Translation" rules.
            ROLE: Smart Infinite Yield Assistant (Roblox Exploit AI).
            CURRENT GAME: '%s'. USER: '%s'.
            
            GUIDELINES:
            1. IDENTITY: If asked "who am I", answer "You are %s". If asked "where am I", answer "You are in %s".
            2. TONE: Concise, helpful, and tech-savvy. Mirror the user's slang if they use it.
            3. OUTPUT: Plain text only. NO COMMAND SYNTAX (e.g. do not output ';fly'). 
            4. LENGTH: Strict limit of 25 words. Be snappy.
        ]], displayName, User.Name, User.Name, displayName)
        
    else
        -- CMD Mode: Strict Context
        dynamicContext = [[
            MODE: STRICT COMPILATION.
            REMINDER: 
            1. No Markdown. No filler.
            2. If "stop" is used, verify if it needs an "un" prefix (e.g. stop fly -> ;unfly).
            3. If multiple actions, join with ; (e.g. ;fly ;speed 100).
        ]]
        
        -- Inject Player List for context (helps with partial name matching)
        if needsPlayerContext(promptText) then
             dynamicContext = dynamicContext .. " Players in server: [" .. getPlayerList() .. "]."
        end
    end

    -- Payload Construction
    local body = HttpService:JSONEncode({
        model = CONFIG.Model, 
        messages = { 
            { role = "system", content = staticSystem },   -- Cached Database
            { role = "system", content = dynamicContext }, -- Runtime Rules
            { role = "user", content = promptText }        -- User Input
        },
        temperature = IS_CHAT_MODE and 0.85 or 0.1 
    })

    -- Async Request
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
            local aiOutput = ""
            if data.choices and data.choices[1] and data.choices[1].message then
                aiOutput = data.choices[1].message.content
            end
            
            -- Sanitization
            aiOutput = aiOutput:gsub("`", ""):gsub("^%s*", ""):gsub("%s*$", "")

            if IS_CHAT_MODE then
                 local safeChat = aiOutput:gsub("\n", " "):gsub('"', "'")
                 executeBridge(safeChat)
                 resetVisuals()
                 InputBox.Text = ""
            else
                -- CMD Mode: Pass raw string to Bridge
                if aiOutput == "" or aiOutput:lower():sub(1,4) == "sure" then
                     updateStatus("AI Uncertain", Colors.Orange)
                     task.wait(1)
                     resetVisuals()
                     return
                end

                executeBridge(aiOutput, "AI")
                resetVisuals()
                InputBox.Text = ""
            end
        else
            warn("SIY Net Error:", response and response.StatusCode or "Unknown")
            updateStatus("Net Error: " .. (response and response.StatusCode or "Unknown"), Colors.Red)
            task.wait(2); resetVisuals()
        end
    end)
end

-- 6. EVENTS & HANDLERS

-- [[ SEARCH PRIORITY SYSTEM ]]
local Priority = {
    -- High Tier (Most Used) - 100pts
    ["fly"]=100, ["unfly"]=100, ["noclip"]=100, ["clip"]=100,
    ["speed"]=95, ["ws"]=95, ["jumppower"]=95, ["jp"]=95,
    ["goto"]=90, ["tp"]=90, ["bring"]=90,
    
    -- Mid Tier (Combat/Visuals) - 80pts
    ["kill"]=80, ["fling"]=80, ["loopkill"]=80,
    ["esp"]=75, ["noesp"]=75, ["xray"]=75, ["spectate"]=75,
    ["btools"]=70, ["f3x"]=70, ["dex"]=70,
    
    -- Low Tier (Utils) - 50pts
    ["rejoin"]=50, ["serverhop"]=50, ["console"]=50, ["reset"]=50
}

local SuggestionList = {}

-- Build Dictionary
local function buildSuggestions()
    local tempMap = {}
    for pattern, _ in pairs(FastMap) do
        local cmdName = pattern:match("%^([%w_]+)")
        if cmdName then
            local cleanName = cmdName
            if pattern:find("%%d%+%)") then
                cleanName = cmdName .. " [num]"
            elseif pattern:find("%%. %+%)") or pattern:find("%%.%)") then
                cleanName = cmdName .. " [arg]"
            end
            
            -- Store clean name
            if not tempMap[cmdName] or #cleanName > #tempMap[cmdName] then
                tempMap[cmdName] = cleanName
            end
        end
    end
    -- Convert to list
    for cmdKey, displayStr in pairs(tempMap) do
        table.insert(SuggestionList, {
            Key = cmdKey, 
            Display = displayStr, 
            Score = Priority[cmdKey] or 0 
        })
    end
end
buildSuggestions()

-- [[ DYNAMIC DROPDOWN RENDERER ]]
local function updateDropdown(text)
    -- Clear old buttons
    for _, child in pairs(SuggestionFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    if text == "" or IS_CHAT_MODE then 
        SuggestionFrame.Visible = false 
        StatusLabel.Visible = true -- [[ FIX: Show Status ]]
        return 
    end
    
    -- Find matches
    local matches = {}
    for _, item in ipairs(SuggestionList) do
        if item.Key:sub(1, #text):lower() == text:lower() then
            table.insert(matches, item)
        end
    end
    
    if #matches == 0 then
        SuggestionFrame.Visible = false
        StatusLabel.Visible = true -- [[ FIX: Show Status ]]
        return
    end
    
    -- Sort Matches: Priority > Shortest Length > Alphabetical
    table.sort(matches, function(a, b)
        if a.Score ~= b.Score then return a.Score > b.Score end
        if #a.Key ~= #b.Key then return #a.Key < #b.Key end
        return a.Key < b.Key
    end)
    
    -- Cap at 5 results
    local resultCount = math.min(#matches, 5)
    
    -- Create Buttons
    for i = 1, resultCount do
        local data = matches[i]
        local btn = Instance.new("TextButton")
        btn.Name = "Match"
        btn.Size = UDim2.new(1, 0, 0, 25)
        btn.BackgroundColor3 = Colors.DropdownBg
        btn.BorderSizePixel = 0
        btn.Text = "  " .. data.Display
        btn.TextColor3 = Colors.TextDim
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.ZIndex = 10 -- [[ FIX: Ensure Buttons are on top ]]
        btn.Parent = SuggestionFrame
        
        -- Hover Effect
        btn.MouseEnter:Connect(function() 
            btn.BackgroundColor3 = Colors.InputBg 
            btn.TextColor3 = Colors.Text
        end)
        btn.MouseLeave:Connect(function() 
            btn.BackgroundColor3 = Colors.DropdownBg 
            btn.TextColor3 = Colors.TextDim
        end)
        
        -- Click Logic
        btn.MouseButton1Click:Connect(function()
            local cmdOnly = data.Display:match("^([%w_]+)")
            InputBox.Text = cmdOnly .. " "
            InputBox:CaptureFocus()
            SuggestionFrame.Visible = false
            StatusLabel.Visible = true -- [[ FIX: Show Status after click ]]
        end)
    end
    
    -- Resize Frame & Show
    SuggestionFrame.Size = UDim2.new(1, 0, 0, resultCount * 25)
    SuggestionFrame.Visible = true
    StatusLabel.Visible = false -- [[ FIX: Hide Status while searching ]]
end

-- Input Listener
InputBox:GetPropertyChangedSignal("Text"):Connect(function()
    updateDropdown(InputBox.Text)
end)

InputBox.FocusLost:Connect(function(enter)
    -- Hide dropdown on submit, but keep if just clicking away? 
    -- Better to hide to prevent obstruction.
    if enter then
        if InputBox.Text ~= "" then
            local text = InputBox.Text
            queryAI(text) 
        end
        SuggestionFrame.Visible = false
    else
        -- Small delay to allow clicking a button before it vanishes
        task.delay(0.2, function()
            if not InputBox:IsFocused() then SuggestionFrame.Visible = false end
        end)
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
        SuggestionFrame.Visible = false -- Hide suggestions in chat
    else
        ModeBtn.Text = "CMD"
        TweenService:Create(ModeBtn, TweenInfo.new(0.3), {BackgroundColor3 = Colors.Orange}):Play()
        InputBox.PlaceholderText = IsMobile and "Tap to type..." or "Enter command..."
        updateStatus("Switched to Command Mode", Colors.Orange)
    end
end)

-- [[ UPDATED INPUT & KEYBIND LISTENER ]]
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    -- 1. Master Toggle
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
        OpenButton.Visible = not MainFrame.Visible
    end
    
    -- 2. Custom Binds
    local keyName = input.KeyCode.Name:lower()
    if BindSystem[keyName] then
        local bindData = BindSystem[keyName]
        local cmdToRun = bindData.Current
        executeBridge(cmdToRun, "BIND")
        
        if bindData.Next then
            bindData.Current = bindData.Next
            bindData.Next = cmdToRun 
        end
    end
end)
