--[[
    FABLE HUB MM2 v1.6.2 (Clean Modern UI & Batch 10 Nearest-Coin Auto Farm)
    Murder Mystery 2 Cheat Script
--]]

if game.PlaceId ~= 142823291 then
    warn("[FableHub] This script is for Murder Mystery 2 only!")
    return
end

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")
local CoreGui           = game:GetService("CoreGui")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

local CFG = {
    Version = "v1.6.2",
    Accent1 = Color3.fromRGB(147, 51, 234), -- Фиолетовый акцент
    Accent2 = Color3.fromRGB(168, 85, 247),
    BgDark  = Color3.fromRGB(15, 15, 24),
    BgPanel = Color3.fromRGB(24, 24, 38),
    Text    = Color3.fromRGB(245, 245, 250),
    TextSub = Color3.fromRGB(160, 160, 190),
}

local State = {
    autoFarm = false,
    antiAfk = false,
    fullbright = false,
    infJump = false,
    noclip = false,
    espMurderer = false,
    espSheriff = false,
    espGun = false,
}

local function New(cls, props, kids)
    local i = Instance.new(cls)
    for k, v in pairs(props or {}) do i[k] = v end
    for _, c in ipairs(kids or {}) do c.Parent = i end
    return i
end

local function Corner(p, r)
    return New("UICorner", { CornerRadius = r or UDim.new(0, 8), Parent = p })
end

local function Stroke(p, c, t, tr)
    return New("UIStroke", {
        Color = c or CFG.Accent1,
        Thickness = t or 1,
        Transparency = tr or 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = p,
    })
end

local function Tw(o, t, p)
    if not o or not o.Parent then return end
    TweenService:Create(o, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quint), p):Play()
end

local parentGui = LocalPlayer:WaitForChild("PlayerGui", 5) or CoreGui

-- Уведомления
local NotifBox
local function Notify(title, text, dur)
    if not NotifBox or not NotifBox.Parent then return end
    dur = dur or 2.5
    local t = New("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = CFG.BgPanel,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = NotifBox,
        ZIndex = 50,
    })
    Corner(t, UDim.new(0, 10))
    Stroke(t, CFG.Accent1, 1, 0.4)
    local b = New("Frame", {
        Size = UDim2.new(0, 3, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundColor3 = CFG.Accent1,
        BorderSizePixel = 0,
        Parent = t,
    })
    Corner(b, UDim.new(1, 0))
    New("TextLabel", {
        Text = title, Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = CFG.Accent2, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1, Size = UDim2.new(1, -14, 0, 18),
        Position = UDim2.new(0, 14, 0, 5), Parent = t,
    })
    New("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = CFG.TextSub, TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true, BackgroundTransparency = 1,
        Size = UDim2.new(1, -14, 0, 22),
        Position = UDim2.new(0, 14, 0, 23), Parent = t,
    })
    t.Position = UDim2.new(1, 30, 0, 0)
    Tw(t, 0.3, { Position = UDim2.new(0, 0, 0, 0) })
    task.delay(dur, function()
        Tw(t, 0.25, { Position = UDim2.new(1, 30, 0, 0) })
        task.wait(0.3)
        pcall(function() t:Destroy() end)
    end)
end

-- Персонаж
local character, humanoid, rootPart
local function SetupChar(ch)
    character = ch
    humanoid = ch:WaitForChild("Humanoid", 10)
    rootPart = ch:WaitForChild("HumanoidRootPart", 10)
    task.wait(0.1)
    if rootPart then
        pcall(function() rootPart:SetNetworkOwner(LocalPlayer) end)
    end
end
if LocalPlayer.Character then task.spawn(SetupChar, LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(ch) task.spawn(SetupChar, ch) end)

-- GUI
local ScreenGui = New("ScreenGui", {
    Name = "FableHubMM2",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = false,
    DisplayOrder = 999,
    Parent = parentGui,
})

local vp = Camera and Camera.ViewportSize or Vector2.new(800, 600)
local W = math.clamp(vp.X * 0.8, 440, 520)
local H = math.clamp(vp.Y * 0.7, 300, 380)

local Main = New("Frame", {
    Name = "Main",
    Size = UDim2.new(0, W, 0, H),
    Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
    BackgroundColor3 = CFG.BgDark,
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = ScreenGui,
    ZIndex = 2,
})
Corner(Main, UDim.new(0, 12))
Stroke(Main, CFG.Accent1, 1.2, 0.3)

-- Верхняя панель
local TopBar = New("Frame", {
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = Main, ZIndex = 3,
})

local LogoBadge = New("Frame", {
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(0, 12, 0, 7),
    BackgroundColor3 = CFG.Accent1,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    Parent = TopBar, ZIndex = 4,
})
Corner(LogoBadge, UDim.new(0, 6))
New("TextLabel", {
    Text = "FH", Font = Enum.Font.GothamBold, TextSize = 12,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
    Parent = LogoBadge, ZIndex = 5,
})

New("TextLabel", {
    Text = "FABLE HUB MM2", Font = Enum.Font.GothamBold, TextSize = 14,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 48, 0, 0), Parent = TopBar, ZIndex = 4,
})

New("TextLabel", {
    Text = CFG.Version, Font = Enum.Font.Code, TextSize = 10,
    TextColor3 = CFG.TextSub, TextXAlignment = Enum.TextXAlignment.Right,
    BackgroundTransparency = 1, Size = UDim2.new(0, 60, 1, 0),
    Position = UDim2.new(1, -70, 0, 0), Parent = TopBar, ZIndex = 4,
})

local CloseBtn = New("TextButton", {
    Text = "✕", Font = Enum.Font.GothamBold, TextSize = 14,
    TextColor3 = Color3.fromRGB(220, 100, 100), BackgroundTransparency = 1,
    Size = UDim2.new(0, 32, 0, 32),
    Position = UDim2.new(1, -38, 0, 5), Parent = TopBar, ZIndex = 5,
})

-- Сайдбар (чистый текст без лишних значков)
local TabBar = New("Frame", {
    Size = UDim2.new(0, 120, 1, -42),
    Position = UDim2.new(0, 0, 0, 42),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = Main, ZIndex = 3,
})
New("UIListLayout", {
    Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = TabBar,
})
New("UIPadding", { PaddingTop = UDim.new(0, 8), Parent = TabBar })

-- Область контента
local Content = New("Frame", {
    Size = UDim2.new(1, -126, 1, -48),
    Position = UDim2.new(0, 124, 0, 44),
    BackgroundTransparency = 1, ClipsDescendants = true,
    Parent = Main, ZIndex = 3,
})

local Scroll = New("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = CFG.Accent1,
    ScrollBarImageTransparency = 0.4,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = Content,
})
New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Scroll })
New("UIPadding", { PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = Scroll })

-- Плавающая кнопка
local ToggleBtn = New("TextButton", {
    Name = "FloatingBtn",
    Size = UDim2.new(0, 48, 0, 48),
    Position = UDim2.new(0, 16, 0.5, -24),
    BackgroundColor3 = CFG.Accent1, BackgroundTransparency = 0.1,
    BorderSizePixel = 0, Text = "FH",
    Font = Enum.Font.GothamBold, TextSize = 15,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Visible = false, ZIndex = 100,
    Parent = ScreenGui,
})
Corner(ToggleBtn, UDim.new(1, 0))
Stroke(ToggleBtn, CFG.Accent2, 1.5, 0.2)

-- Уведомления
local NotifWrap = New("Frame", {
    Size = UDim2.new(0, 240, 0, 320),
    Position = UDim2.new(1, -250, 0, 12),
    BackgroundTransparency = 1, ClipsDescendants = true,
    Parent = ScreenGui, ZIndex = 90,
})
NotifBox = New("Frame", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = NotifWrap,
})
New("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = NotifBox })

-- Компоненты UI
local function Section(parent, title)
    local f = New("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Parent = parent })
    New("TextLabel", {
        Text = title, Font = Enum.Font.GothamBold, TextSize = 10,
        TextColor3 = CFG.Accent2, TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 0.1, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 4, 0, 0), Parent = f,
    })
end

local function Toggle(parent, text, def, cb)
    local s = def or false
    local f = New("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = CFG.BgPanel,
        BackgroundTransparency = 0.2, BorderSizePixel = 0, Parent = parent,
    })
    Corner(f, UDim.new(0, 8))
    Stroke(f, CFG.Accent1, 1, 0.6)

    New("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 12,
        TextColor3 = CFG.Text, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1, Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0), Parent = f,
    })

    local sw = New("Frame", {
        Size = UDim2.new(0, 38, 0, 20),
        Position = UDim2.new(1, -46, 0.5, -10),
        BackgroundColor3 = s and CFG.Accent1 or Color3.fromRGB(45, 45, 65),
        BackgroundTransparency = 0.1, BorderSizePixel = 0, Parent = f,
    })
    Corner(sw, UDim.new(1, 0))

    local knob = New("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = s and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0, Parent = sw,
    })
    Corner(knob, UDim.new(1, 0))

    local hit = New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = f })
    hit.MouseButton1Click:Connect(function()
        s = not s
        if s then
            Tw(sw, 0.18, { BackgroundColor3 = CFG.Accent1 })
            Tw(knob, 0.18, { Position = UDim2.new(1, -18, 0.5, -8) })
        else
            Tw(sw, 0.18, { BackgroundColor3 = Color3.fromRGB(45, 45, 65) })
            Tw(knob, 0.18, { Position = UDim2.new(0, 2, 0.5, -8) })
        end
        if cb then pcall(cb, s) end
    end)
end

-- Вкладки
local Tabs = {}
local function MakeTab(name)
    local b = New("TextButton", {
        Name = name, Text = "    " .. name, Font = Enum.Font.GothamMedium, TextSize = 12,
        TextColor3 = CFG.TextSub, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundColor3 = CFG.Accent1,
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.new(1, -10, 0, 34), Parent = TabBar,
    })
    Corner(b, UDim.new(0, 8))

    local page = New("Frame", {
        Name = name .. "Page", Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Visible = false, Parent = Scroll,
    })
    New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
    Tabs[name] = { Btn = b, Page = page }

    b.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Page.Visible = false
            Tw(t.Btn, 0.15, { BackgroundTransparency = 1, TextColor3 = CFG.TextSub })
        end
        page.Visible = true
        Tw(b, 0.15, { BackgroundTransparency = 0.2, TextColor3 = Color3.fromRGB(255, 255, 255) })
    end)
    return page
end

local MainTab     = MakeTab("Main")
local PlayerTab   = MakeTab("Игрок")
local EspTab      = MakeTab("ЭСП")
local SettingsTab = MakeTab("Настройки")

Tabs["Main"].Btn.BackgroundTransparency = 0.2
Tabs["Main"].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Tabs["Main"].Page.Visible = true

-- Main Tab
Section(MainTab, "AUTO FARM")
Toggle(MainTab, "Auto Farm монет", false, function(s)
    State.autoFarm = s
    if s then Notify("Auto Farm", "Включен (10 ближайших монет)", 2.5)
    else Notify("Auto Farm", "Выключен", 2) end
end)

Section(MainTab, "UTILITY")
Toggle(MainTab, "Anti-AFK", false, function(s) State.antiAfk = s end)
Toggle(MainTab, "Fullbright", false, function(s)
    State.fullbright = s
    if s then
        Lighting.Brightness = 3
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.ClockTime = 14
    else
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
    end
end)

task.spawn(function()
    while true do
        task.wait(60)
        if State.antiAfk then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- Auto Farm Engine (Top 10 Nearest Coins Batch, Speed 16)
local function GetCoinParts(obj)
    if obj:IsA("BasePart") then return { obj } end
    if obj:IsA("Model") then
        local pts = {}
        for _, p in ipairs(obj:GetDescendants()) do
            if p:IsA("BasePart") then table.insert(pts, p) end
        end
        return pts
    end
    return {}
end

local function TouchCoin(obj)
    for _, cp in ipairs(GetCoinParts(obj)) do
        pcall(function()
            firetouchinterest(rootPart, cp, 0)
            firetouchinterest(rootPart, cp, 1)
        end)
    end
end

local farmActive = false
local farmRoutine = nil

local function StopFarmEngine()
    farmActive = false
    if farmRoutine then
        task.cancel(farmRoutine)
        farmRoutine = nil
    end
    if character then
        for _, p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                p.CanCollide = true
            end
        end
    end
end

local function StartFarmEngine()
    if farmActive then return end
    if not rootPart or not humanoid then return end

    farmActive = true
    farmRoutine = task.spawn(function()
        while State.autoFarm do
            if not rootPart or not rootPart.Parent or humanoid.Health <= 0 then
                task.wait(0.5)
                continue
            end

            for _, p in ipairs(character:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then 
                    p.CanCollide = false 
                end
            end

            local availableCoins = {}
            local fromPos = rootPart.Position

            local function checkObj(obj)
                if not obj or not obj.Parent then return end
                local parts = GetCoinParts(obj)
                if #parts > 0 then
                    local part = parts[1]
                    local d = (part.Position - fromPos).Magnitude
                    if d < 500 then
                        table.insert(availableCoins, { obj = obj, part = part, dist = d })
                    end
                end
            end

            for _, obj in ipairs(CollectionService:GetTagged("Coin")) do checkObj(obj) end
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("coin") then checkObj(obj) end
            end

            if #availableCoins == 0 then
                task.wait(0.3)
                continue
            end

            table.sort(availableCoins, function(a, b) return a.dist < b.dist end)

            local batchCoins = {}
            for i = 1, math.min(10, #availableCoins) do
                table.insert(batchCoins, availableCoins[i])
            end

            for _, coinData in ipairs(batchCoins) do
                if not State.autoFarm or not rootPart or not rootPart.Parent then break end
                if not coinData.obj.Parent then continue end

                local targetPos = coinData.part.Position
                local dist = (targetPos - rootPart.Position).Magnitude
                local duration = dist / 16

                local targetCF = CFrame.new(targetPos + Vector3.new(0, 2, 0))
                local tween = TweenService:Create(rootPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = targetCF })
                tween:Play()

                while tween.PlaybackState == Enum.PlaybackState.Playing and State.autoFarm do
                    if not coinData.obj.Parent then
                        tween:Cancel()
                        break
                    end
                    RunService.Heartbeat:Wait()
                end

                TouchCoin(coinData.obj)
                task.wait(0.02)
            end

            task.wait(0.05)
        end
        
        if character then
            for _, p in ipairs(character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
        farmActive = false
    end)
end

task.spawn(function()
    while true do
        task.wait(0.15)
        if State.autoFarm then
            if not farmActive then StartFarmEngine() end
        else
            if farmActive then StopFarmEngine() end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(ch)
    task.wait(0.5)
    SetupChar(ch)
    if State.autoFarm then
        StopFarmEngine()
        task.wait(0.1)
        StartFarmEngine()
    end
end)

-- Player Tab
Section(PlayerTab, "ПЕРЕДВИЖЕНИЕ")
Toggle(PlayerTab, "Infinite Jump", false, function(s) State.infJump = s end)
UserInputService.JumpRequest:Connect(function()
    if State.infJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

Toggle(PlayerTab, "Noclip", false, function(s) State.noclip = s end)
RunService.Stepped:Connect(function()
    if State.noclip and character then
        for _, p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end
end)

-- ESP Tab
local espHighlights = {}
local function ClearESP()
    for _, h in ipairs(espHighlights) do pcall(function() h:Destroy() end) end
    espHighlights = {}
end

local function UpdateESP()
    ClearESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local role = nil
            if player.Character:FindFirstChild("Knife") or (player.Backpack and player.Backpack:FindFirstChild("Knife")) then
                role = "Murderer"
            elseif player.Character:FindFirstChild("Gun") or (player.Backpack and player.Backpack:FindFirstChild("Gun")) then
                role = "Sheriff"
            end

            if (role == "Murderer" and State.espMurderer) or (role == "Sheriff" and State.espSheriff) then
                local h = Instance.new("Highlight")
                h.Adornee = player.Character
                h.FillColor = role == "Murderer" and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(60, 160, 255)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.FillTransparency = 0.5
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = ScreenGui
                table.insert(espHighlights, h)
            end
        end
    end

    if State.espGun then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("gun") and obj:IsA("Tool") then
                local h = Instance.new("Highlight")
                h.Adornee = obj
                h.FillColor = Color3.fromRGB(255, 215, 0)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.FillTransparency = 0.4
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = ScreenGui
                table.insert(espHighlights, h)
            end
        end
    end
end

Section(EspTab, "ПОДСВЕТКА РОЛЕЙ")
Toggle(EspTab, "ESP Murderer", false, function(s) State.espMurderer = s; UpdateESP() end)
Toggle(EspTab, "ESP Sheriff", false, function(s) State.espSheriff = s; UpdateESP() end)
Toggle(EspTab, "ESP Gun", false, function(s) State.espGun = s; UpdateESP() end)

task.spawn(function()
    while true do
        task.wait(2)
        if State.espMurderer or State.espSheriff or State.espGun then UpdateESP() end
    end
end)

-- Settings Tab
Section(SettingsTab, "ИНФОРМАЦИЯ")
New("TextLabel", {
    Text = "Fable Hub MM2 " .. CFG.Version,
    Font = Enum.Font.GothamBold, TextSize = 13,
    TextColor3 = CFG.Accent2, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20),
    Parent = SettingsTab,
})

Section(SettingsTab, "УПРАВЛЕНИЕ")
local b = New("TextButton", {
    Text = "Закрыть и выгрузить скрипт", Font = Enum.Font.GothamMedium, TextSize = 12,
    TextColor3 = Color3.fromRGB(255, 100, 100), BackgroundColor3 = CFG.BgPanel,
    BackgroundTransparency = 0.2, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 34), AutoButtonColor = false, Parent = SettingsTab,
})
Corner(b, UDim.new(0, 8))
Stroke(b, Color3.fromRGB(255, 100, 100), 1, 0.6)
b.MouseButton1Click:Connect(function()
    StopFarmEngine()
    ClearESP()
    pcall(function() ScreenGui:Destroy() end)
end)

-- Open / Close & Drag
local function SetMenuOpen(open)
    Main.Visible = open
    ToggleBtn.Visible = not open
end
CloseBtn.MouseButton1Click:Connect(function() SetMenuOpen(false) end)

local drag, dStart, dPos, moved = false, nil, nil, false
ToggleBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = true; moved = false
        dStart = i.Position; dPos = ToggleBtn.Position
    end
end)
ToggleBtn.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = false
        if not moved then SetMenuOpen(true) end
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dStart
        if math.abs(d.X) > 6 or math.abs(d.Y) > 6 then moved = true end
        ToggleBtn.Position = UDim2.new(
            dPos.X.Scale, dPos.X.Offset + d.X,
            dPos.Y.Scale, dPos.Y.Offset + d.Y
        )
    end
end)

task.wait(0.3)
Notify("Fable Hub MM2", "Интерфейс исправлен (" .. CFG.Version .. ")", 2.5)
print("[FableHub MM2] Clean UI Loaded successfully!")
