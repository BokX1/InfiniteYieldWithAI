--[[ 
    SMART INFINITE YIELD - V1.0 STABLE
    Original Idea by VolQ5
    Powered by Pollinations.AI (Grok Model)
    
    RELEASE NOTES:
    - [STABLE]: Finalized V1.0.1 ModelHotfix Release.
    - [UX]: Added "Thinking..." indicator in the text box.
    - [VISUAL]: Persistent quality updates from V0.3.
]]

-- 1. CONFIGURATION
local CONFIG = {
    -- !!! REPLACE THIS WITH YOUR KEY !!!
    ApiKey = "sk_KOF9Cw14T3l8nJ1RtTOE5wgxVI3QZAFY", 
    
    Endpoint = "https://gen.pollinations.ai/v1/chat/completions",
    Model = "grok",
    
    CommandPrompt = [[
        You are a Roblox Command Translator.
        1. Output ONLY the valid Infinite Yield command.
        2. NO chat, NO explanations.
        3. Example: "fly" -> "fly"
    ]],
}

-- 2. CONTEXT ENGINE
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local User = Players.LocalPlayer or Players.PlayerAdded:Wait()
local GameName = "Unknown Game"

task.spawn(function()
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        GameName = info.Name
        print(">> SIY V1.0: Connected to " .. GameName)
    end)
end)

-- 3. SERVICES
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if not httpRequest then warn("Executor incompatible.") end

-- 4. THE BRIDGE (Stable)
local IY_Interface = nil
task.spawn(function()
    if getgenv().PseudoBridge then IY_Interface = getgenv().PseudoBridge; return end
    if not game.CoreGui:FindFirstChild("InfiniteYield") then
        local Success, IY_Source = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source") end)
        if Success then
            local BridgeCode = [[ getgenv().PseudoBridge = { Exec = function(cmd) if execCmd then execCmd(cmd) end end } ]]
            loadstring(IY_Source .. "\n" .. BridgeCode)()
        end
    end
    repeat task.wait(0.5) until getgenv().PseudoBridge
    IY_Interface = getgenv().PseudoBridge
end)

-- 5. GUI CONSTRUCTION
if CoreGui:FindFirstChild("SmartInfiniteYieldGUI") then CoreGui.SmartInfiniteYieldGUI:Destroy() end
local SIY_Screen = Instance.new("ScreenGui")
SIY_Screen.Name = "SmartInfiniteYieldGUI"
SIY_Screen.Parent = CoreGui 

-- [[ STYLES ]] --
local Colors = {
    Background = Color3.fromRGB(20, 20, 25),
    InputBg = Color3.fromRGB(30, 30, 35),
    Orange = Color3.fromRGB(255, 140, 0),
    Blue = Color3.fromRGB(0, 190, 255),
    Green = Color3.fromRGB(0, 255, 160),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(150, 150, 160)
}

local function addCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
    return c
end

local function animateButton(btn)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play() end)
end

-- [[ FLOATING ICON (SUBTLE LOGO) ]]
local OpenButton = Instance.new("ImageButton")
OpenButton.Size = UDim2.new(0, 45, 0, 45)
OpenButton.Position = UDim2.new(0, 20, 0.5, -22)
OpenButton.BackgroundColor3 = Colors.Background
OpenButton.Image = "rbxassetid://6035193498" 
OpenButton.ImageColor3 = Colors.Green
OpenButton.Visible = false
OpenButton.Parent = SIY_Screen
addCorner(OpenButton, 12)

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Colors.Green; OpenStroke.Thickness = 1.5; OpenStroke.Parent = OpenButton

-- [[ MAIN BAR ]]
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 55)
MainFrame.Position = UDim2.new(0.5, -250, 0.15, 0)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = SIY_Screen
addCorner(MainFrame, 10)

-- Soft Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 2)
Shadow.Size = UDim2.new(1, 15, 1, 15)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6015897843"
Shadow.ImageColor3 = Color3.new(0,0,0)
Shadow.ImageTransparency = 0.6 
Shadow.ZIndex = 0
Shadow.Parent = MainFrame

-- Main Glow Border
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Colors.Orange 
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0 
MainStroke.Parent = MainFrame

-- [[ INNER ELEMENTS ]]
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
animateButton(ModeBtn)

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
animateButton(MinBtn)

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

-- [[ TUTORIAL MODAL ]]
local TutorialFrame = Instance.new("Frame")
TutorialFrame.Name = "Tutorial"
TutorialFrame.Size = UDim2.new(0, 420, 0, 240)
TutorialFrame.Position = UDim2.new(0.5, -210, 0.5, -120)
TutorialFrame.BackgroundColor3 = Colors.Background
TutorialFrame.Parent = SIY_Screen
TutorialFrame.Visible = false 
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

local Trademark = Instance.new("TextLabel")
Trademark.Size = UDim2.new(1, 0, 0, 20)
Trademark.Position = UDim2.new(0, 0, 1, -15) 
Trademark.BackgroundTransparency = 1
Trademark.Text = "Original idea by VolQ5"
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

-- 6. LOGIC & INTELLIGENCE
local IS_CHAT_MODE = false

-- Draggable Logic
local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(MainFrame); makeDraggable(OpenButton)

local function getChatPrompt()
    return string.format([[
        You are a helpful Infinite Yield Assistant for the player '%s'.
        They are currently playing the Roblox game: '%s'.
        RULES: Give advice specific to '%s' (max 20 words). No markdown.
    ]], User.Name, GameName, GameName)
end

local function executeBridge(text)
    if not IY_Interface then return end
    if IS_CHAT_MODE then
        local clean = text:gsub("'", ""):gsub('"', '')
        IY_Interface.Exec("notify Gemini " .. clean)
    else
        IY_Interface.Exec(text)
    end
end

local function queryAI(promptText)
    -- VISUAL: Thinking State
    local oldPlaceholder = InputBox.PlaceholderText
    InputBox.PlaceholderText = "Thinking..."
    InputBox.PlaceholderColor3 = Colors.Green
    InputBox.TextEditable = false -- Lock input
    
    local pulse = TweenService:Create(MainStroke, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.6})
    pulse:Play()
    
    local activeSystemPrompt = IS_CHAT_MODE and getChatPrompt() or CONFIG.CommandPrompt
    
    local body = HttpService:JSONEncode({
        model = CONFIG.Model,
        messages = { {role = "system", content = activeSystemPrompt}, {role = "user", content = promptText} },
        temperature = 0.3
    })

    task.spawn(function()
        local success, response = pcall(function()
            return httpRequest({
                Url = CONFIG.Endpoint, Method = "POST",
                Headers = { ["Content-Type"]="application/json", ["Authorization"]="Bearer "..CONFIG.ApiKey },
                Body = body
            })
        end)

        if success and response and response.StatusCode == 200 then
            local data = HttpService:JSONDecode(response.Body)
            executeBridge(data.choices[1].message.content)
        end
        
        -- VISUAL: Reset State
        pulse:Cancel()
        MainStroke.Transparency = 0
        InputBox.TextEditable = true
        InputBox.PlaceholderColor3 = Colors.TextDim
        if IS_CHAT_MODE then
            InputBox.PlaceholderText = "Ask about " .. GameName .. "..."
        else
            InputBox.PlaceholderText = "Enter command..."
        end
    end)
end

-- 7. EVENTS
InputBox.FocusLost:Connect(function(enter)
    if enter and InputBox.Text ~= "" then
        local t = InputBox.Text; InputBox.Text = ""; queryAI(t)
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false; OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    OpenButton.Visible = false; MainFrame.Visible = true
end)

ModeBtn.MouseButton1Click:Connect(function()
    IS_CHAT_MODE = not IS_CHAT_MODE
    if IS_CHAT_MODE then
        ModeBtn.Text = "CHAT"
        ModeBtn.BackgroundColor3 = Colors.Blue
        MainStroke.Color = Colors.Blue 
        InputBox.PlaceholderText = "Ask about " .. GameName .. "..."
    else
        ModeBtn.Text = "CMD"
        ModeBtn.BackgroundColor3 = Colors.Orange
        MainStroke.Color = Colors.Orange 
        InputBox.PlaceholderText = "Enter command..."
    end
end)


TutorialFrame.Visible = true
