--[[
    FABLE HUB DOORS v1.5.5
    - УБРАН логгер
    - ESP: Rush, Eyes, Screech, Wardrobe, Key, Knobs, Gold, FakeDoor, Bandage, LiveHintBook, LeverForGate
    - Подписи без эмодзи: "Rush", "Eyes", "Screech", "Шкаф", "Ключ", "Монеты", "Золото", "ФЕЙК", "Пластырь", "Книга", "Рычаг"
    - Auto Key (TP), Auto Closet (ТП в шкаф)
    - Bypass: Seek Obstructions, Snare, Giggle, Dupe, Vacuum, SeekWall, Jeff, Killbricks
    - Speed, Noclip, Fullbright, InfJump, Infinite Revives, Instant Prompts, Prompt Reach
    - Transparent Hide, Third Person, Anti-AFK
--]]

if game.PlaceId ~= 6839171747 and game.PlaceId ~= 2440500124 then
    warn("[FableHub] This script is for DOORS only!")
    return
end

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")
local CoreGui           = game:GetService("CoreGui")
local GuiService        = game:GetService("GuiService")
local VirtualUser       = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

-- ═══════════════════════ НАСТРОЙКИ ═══════════════════════
local CFG = {
    Version     = "v1.5.5",
    Accent1     = Color3.fromRGB(139, 92, 246),
    Accent2     = Color3.fromRGB(217, 70, 239),
    Accent3     = Color3.fromRGB(99, 102, 241),
    BgDark      = Color3.fromRGB(13, 13, 22),
    BgPanel     = Color3.fromRGB(24, 24, 40),
    BgHover     = Color3.fromRGB(35, 35, 58),
    Text        = Color3.fromRGB(245, 245, 250),
    TextSub     = Color3.fromRGB(150, 150, 185),
    Success     = Color3.fromRGB(52, 211, 153),
    Danger      = Color3.fromRGB(248, 113, 113),
    Warn        = Color3.fromRGB(250, 204, 21),

    ColorRush      = Color3.fromRGB(255, 40, 40),
    ColorEyes      = Color3.fromRGB(200, 50, 200),
    ColorScreech   = Color3.fromRGB(255, 140, 0),
    ColorWardrobe  = Color3.fromRGB(80, 255, 120),
    ColorKey       = Color3.fromRGB(255, 215, 0),
    ColorKnob      = Color3.fromRGB(255, 200, 100),
    ColorGold      = Color3.fromRGB(255, 180, 40),
    ColorFakeDoor  = Color3.fromRGB(255, 0, 0),
    ColorBandage   = Color3.fromRGB(240, 240, 220),
    ColorHintBook  = Color3.fromRGB(255, 220, 80),
    ColorLever     = Color3.fromRGB(255, 150, 0),

    SpeedValue    = 45,
    KeyRange      = 300,
    AutoClosetRange = 100,
    NotifyCooldown = 5,
    TelegramURL   = "https://t.me/Fable_Hub",
    TelegramHandle = "@Fable_Hub",
}

-- ═══════════════════════ СОСТОЯНИЕ ═══════════════════════
local State = {
    autoKey      = false,
    autoCloset   = false,
    antiAfk      = false,
    fullbright   = false,
    infJump      = false,
    noclip       = false,
    speedHack    = false,
    instantPrompts = false,
    promptReach  = false,
    infiniteRevives = false,
    transparentHide = false,
    thirdPerson  = false,

    espRush      = false,
    espEyes      = false,
    espScreech   = false,
    espWardrobe  = false,
    espKey       = false,
    espKnobs     = false,
    espGold      = false,
    espFakeDoor  = false,
    espBandage   = false,
    espHintBook  = false,
    espLever     = false,

    bypassSeekObstructions = false,
    bypassSnare  = false,
    bypassGiggle = false,
    bypassDupe   = false,
    bypassVacuum = false,
    bypassSeekWall = false,
    bypassJeff   = false,
    bypassKillbricks = false,
}

local espObjects = {}
local espBillboards = {}
local seenESP = {}
local thirdPersonOffset = Vector3.new(1.5, 1, 5)

local activeEntities = { Rush = false, Ambush = false, Screech = false }
local lastNotifyTime = { Rush = 0, Ambush = 0, Screech = 0 }

-- ═══════════════════════ УТИЛЫ ═══════════════════════
local function New(cls, props, kids)
    local i = Instance.new(cls)
    for k, v in pairs(props or {}) do i[k] = v end
    for _, c in ipairs(kids or {}) do c.Parent = i end
    return i
end
local function Corner(p, r) return New("UICorner", { CornerRadius = r or UDim.new(0, 10), Parent = p }) end
local function Stroke(p, c, t, tr)
    return New("UIStroke", { Color = c or CFG.Accent1, Thickness = t or 1.2,
        Transparency = tr or 0.4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = p })
end
local function Gradient(p, c1, c2, rot)
    return New("UIGradient", { Color = ColorSequence.new(c1 or CFG.Accent3, c2 or CFG.Accent2),
        Rotation = rot or 45, Parent = p })
end
local function Tw(o, t, p, style)
    if not o or not o.Parent then return end
    TweenService:Create(o, TweenInfo.new(t or 0.22, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), p):Play()
end

local function CanNotify(kind)
    if tick() - lastNotifyTime[kind] >= CFG.NotifyCooldown then
        lastNotifyTime[kind] = tick()
        return true
    end
    return false
end

-- ═══════════════════════ ИКОНКИ ═══════════════════════
local function MakeIcon(parent, name, size, color)
    local holder = New("Frame", {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Parent = parent,
    })
    local th = math.max(1, math.floor(size / 10))
    local function shape(w, h, x, y, rot, radius)
        local f = New("Frame", {
            Size = UDim2.new(w, 0, h, 0),
            Position = UDim2.new(x, 0, y, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Rotation = rot or 0,
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Parent = holder,
        })
        if radius then Corner(f, radius) end
        return f
    end
    local function ring(scale, thickness)
        local f = New("Frame", {
            Size = UDim2.new(scale, 0, scale, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Parent = holder,
        })
        Corner(f, UDim.new(1, 0))
        Stroke(f, color, thickness or th, 0)
        return f
    end
    local function squareOutline(scale, radius, thickness)
        local f = New("Frame", {
            Size = UDim2.new(scale, 0, scale, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Parent = holder,
        })
        Corner(f, radius or UDim.new(0, 3))
        Stroke(f, color, thickness or th, 0)
        return f
    end

    if name == "knife" then
        shape(0.2, 0.62, 0.6, 0.38, -45, UDim.new(0, 2))
        shape(0.13, 0.28, 0.32, 0.68, -45)
    elseif name == "eye" then
        shape(0.7, 0.4, 0.5, 0.5, 0, UDim.new(1, 0))
        shape(0.18, 0.18, 0.5, 0.5, 0, UDim.new(1, 0))
    elseif name == "wardrobe" then
        squareOutline(0.85, UDim.new(0, 2))
        shape(0.05, 0.7, 0.5, 0.5, 0)
        shape(0.08, 0.08, 0.32, 0.5, 0, UDim.new(1, 0))
        shape(0.08, 0.08, 0.68, 0.5, 0, UDim.new(1, 0))
    elseif name == "key" then
        ring(0.4); shape(0.5, 0.12, 0.65, 0.65, -45, UDim.new(0, 1))
        shape(0.1, 0.18, 0.85, 0.85, -45)
        shape(0.1, 0.12, 0.75, 0.78, -45)
    elseif name == "coin" then
        ring(0.95); shape(0.38, 0.38, 0.5, 0.5, 0, UDim.new(1, 0))
    elseif name == "sun" then
        shape(0.42, 0.42, 0.5, 0.5, 0, UDim.new(1, 0))
        shape(0.09, 0.22, 0.5, 0.09, 0); shape(0.09, 0.22, 0.5, 0.91, 0)
        shape(0.22, 0.09, 0.09, 0.5, 0); shape(0.22, 0.09, 0.91, 0.5, 0)
    elseif name == "clock" then
        ring(0.95); shape(0.1, 0.3, 0.5, 0.37, 0); shape(0.24, 0.1, 0.61, 0.5, 0)
    elseif name == "bolt" then
        shape(0.28, 0.45, 0.42, 0.28, -15, UDim.new(0, 1))
        shape(0.28, 0.45, 0.58, 0.72, -15, UDim.new(0, 1))
        shape(0.35, 0.1, 0.5, 0.5, -15)
    elseif name == "target" then
        ring(0.95); shape(0.26, 0.26, 0.5, 0.5, 0, UDim.new(1, 0))
        shape(0.09, 0.18, 0.5, 0.05, 0); shape(0.09, 0.18, 0.5, 0.95, 0)
        shape(0.18, 0.09, 0.05, 0.5, 0); shape(0.18, 0.09, 0.95, 0.5, 0)
    elseif name == "sliders" then
        shape(0.85, 0.09, 0.5, 0.2, 0, UDim.new(1, 0))
        shape(0.85, 0.09, 0.5, 0.5, 0, UDim.new(1, 0))
        shape(0.85, 0.09, 0.5, 0.8, 0, UDim.new(1, 0))
        shape(0.18, 0.18, 0.3, 0.2, 0, UDim.new(1, 0))
        shape(0.18, 0.18, 0.68, 0.5, 0, UDim.new(1, 0))
        shape(0.18, 0.18, 0.42, 0.8, 0, UDim.new(1, 0))
    elseif name == "person" then
        shape(0.36, 0.36, 0.5, 0.24, 0, UDim.new(1, 0))
        shape(0.62, 0.34, 0.5, 0.76, 0, UDim.new(0.5, 0))
    elseif name == "trash" then
        shape(0.62, 0.09, 0.5, 0.12, 0, UDim.new(1, 0))
        shape(0.68, 0.55, 0.5, 0.62, 0, UDim.new(0, 2))
    elseif name == "slider" then
        shape(0.85, 0.09, 0.5, 0.5, 0, UDim.new(1, 0))
        shape(0.22, 0.22, 0.65, 0.5, 0, UDim.new(1, 0))
    elseif name == "x" then
        shape(0.85, 0.11, 0.5, 0.5, 45, UDim.new(1, 0))
        shape(0.85, 0.11, 0.5, 0.5, -45, UDim.new(1, 0))
    elseif name == "shield" then
        squareOutline(0.7, UDim.new(0, 3))
        shape(0.3, 0.3, 0.5, 0.4, 45, UDim.new(0, 1))
    end
    return holder
end

-- ═══════════════════════ УВЕДОМЛЕНИЯ ═══════════════════════
local NotifBox
local function Notify(title, text, dur, kind)
    if not NotifBox or not NotifBox.Parent then return end
    dur = dur or 2.5
    local accent = kind == "error" and CFG.Danger or (kind == "success" and CFG.Success or (kind == "warn" and CFG.Warn or CFG.Accent1))

    local t = New("Frame", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = CFG.BgPanel,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0, Parent = NotifBox, ZIndex = 50,
    })
    Corner(t, UDim.new(0, 12))
    Stroke(t, accent, 1, 0.35)

    local b = New("Frame", {
        Size = UDim2.new(0, 3, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0, Parent = t, ZIndex = 51,
    })
    Corner(b, UDim.new(1, 0))
    Gradient(b)

    New("TextLabel", {
        Text = title, Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = accent, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 18),
        Position = UDim2.new(0, 18, 0, 7), Parent = t, ZIndex = 51,
    })
    New("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = CFG.TextSub, TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true, BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 26),
        Position = UDim2.new(0, 18, 0, 25), Parent = t, ZIndex = 51,
    })

    local progBg = New("Frame", {
        Size = UDim2.new(1, -16, 0, 2),
        Position = UDim2.new(0, 8, 1, -6),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0, Parent = t, ZIndex = 51,
    })
    Corner(progBg, UDim.new(1, 0))
    local prog = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0, Parent = progBg, ZIndex = 52,
    })
    Corner(prog, UDim.new(1, 0))
    TweenService:Create(prog, TweenInfo.new(dur, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) }):Play()

    t.Position = UDim2.new(1.1, 0, 0, 0)
    Tw(t, 0.35, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back)
    task.delay(dur, function()
        Tw(t, 0.25, { Position = UDim2.new(1.1, 0, 0, 0) })
        task.wait(0.3)
        pcall(function() t:Destroy() end)
    end)
end

-- ═══════════════════════ ПЕРСОНАЖ ═══════════════════════
local character, humanoid, rootPart

local function SetupChar(ch)
    character = ch
    humanoid = ch:WaitForChild("Humanoid", 10)
    rootPart = ch:WaitForChild("HumanoidRootPart", 10)
    task.wait(0.1)
end

if LocalPlayer.Character then task.spawn(SetupChar, LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(ch) task.spawn(SetupChar, ch) end)

-- ═══════════════════════ GUI ═══════════════════════
local parentGui = LocalPlayer:WaitForChild("PlayerGui", 5) or CoreGui

local ScreenGui = New("ScreenGui", {
    Name = "FableHubDoors",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    Parent = parentGui,
})

local vp = Camera and Camera.ViewportSize or Vector2.new(800, 600)
local W = math.clamp(vp.X * 0.85, 460, 620)
local H = math.clamp(vp.Y * 0.72, 360, 480)

local Shadow = New("ImageLabel", {
    Size = UDim2.new(1, 70, 1, 70),
    Position = UDim2.new(0, -35, 0, -30),
    BackgroundTransparency = 1,
    Image = "rbxassetid://6014261993",
    ImageColor3 = Color3.fromRGB(0, 0, 0),
    ImageTransparency = 0.45,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(49, 49, 450, 450),
    Parent = ScreenGui, ZIndex = 1,
})

local Main = New("Frame", {
    Size = UDim2.new(0, W, 0, H),
    Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
    BackgroundColor3 = CFG.BgDark,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = ScreenGui, ZIndex = 2,
})
Corner(Main, UDim.new(0, 16))
Stroke(Main, CFG.Accent1, 1.5, 0.3)

local Glow = New("Frame", {
    Size = UDim2.new(1, 0, 0, 120),
    BackgroundColor3 = CFG.Accent1,
    BackgroundTransparency = 0.93,
    BorderSizePixel = 0, Parent = Main, ZIndex = 2,
})
Gradient(Glow, CFG.Accent1, CFG.Accent2, 90)

local TopBar = New("Frame", {
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundTransparency = 1,
    BorderSizePixel = 0, Parent = Main, ZIndex = 3,
})
New("Frame", {
    Size = UDim2.new(1, -24, 0, 1),
    Position = UDim2.new(0, 12, 0, 49),
    BackgroundColor3 = CFG.Accent1,
    BackgroundTransparency = 0.8,
    BorderSizePixel = 0, Parent = TopBar, ZIndex = 3,
})

local LogoBadge = New("Frame", {
    Size = UDim2.new(0, 34, 0, 34),
    Position = UDim2.new(0, 12, 0, 8),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BorderSizePixel = 0, Parent = TopBar, ZIndex = 4,
})
Corner(LogoBadge, UDim.new(0, 10))
local LogoGrad = Gradient(LogoBadge)

task.spawn(function()
    while LogoGrad and LogoGrad.Parent do
        TweenService:Create(LogoGrad, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Rotation = LogoGrad.Rotation + 180,
        }):Play()
        task.wait(3)
    end
end)

New("TextLabel", {
    Text = "FH", Font = Enum.Font.GothamBold, TextSize = 13,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
    Parent = LogoBadge, ZIndex = 5,
})

New("TextLabel", {
    Text = "FABLE ", Font = Enum.Font.GothamBold, TextSize = 15,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 56, 0, 0), Parent = TopBar, ZIndex = 4,
})
New("TextLabel", {
    Text = "DOORS", Font = Enum.Font.GothamBold, TextSize = 15,
    TextColor3 = CFG.Accent2,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 112, 0, 0), Parent = TopBar, ZIndex = 4,
})

New("TextLabel", {
    Text = CFG.Version, Font = Enum.Font.Code, TextSize = 11,
    TextColor3 = CFG.TextSub, TextXAlignment = Enum.TextXAlignment.Right,
    BackgroundTransparency = 1, Size = UDim2.new(0, 80, 1, 0),
    Position = UDim2.new(1, -128, 0, 0), Parent = TopBar, ZIndex = 4,
})

local FpsLabel = New("TextLabel", {
    Text = "FPS: --", Font = Enum.Font.Code, TextSize = 11,
    TextColor3 = CFG.Success, TextXAlignment = Enum.TextXAlignment.Right,
    BackgroundTransparency = 1, Size = UDim2.new(0, 60, 1, 0),
    Position = UDim2.new(1, -90, 0, 0), Parent = TopBar, ZIndex = 4,
})

do
    local frames, last = 0, tick()
    RunService.RenderStepped:Connect(function()
        frames += 1
        if tick() - last >= 1 then
            FpsLabel.Text = "FPS: " .. frames
            FpsLabel.TextColor3 = frames >= 50 and CFG.Success or (frames >= 30 and CFG.Warn or CFG.Danger)
            frames, last = 0, tick()
        end
    end)
end

local CloseBtn = New("TextButton", {
    Text = "", BackgroundColor3 = CFG.BgPanel,
    BackgroundTransparency = 0.4, BorderSizePixel = 0,
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -38, 0, 11), Parent = TopBar, ZIndex = 5,
    AutoButtonColor = false,
})
Corner(CloseBtn, UDim.new(0, 8))
MakeIcon(CloseBtn, "x", 11, CFG.TextSub)
CloseBtn.MouseEnter:Connect(function()
    Tw(CloseBtn, 0.15, { BackgroundTransparency = 0, BackgroundColor3 = CFG.Danger })
end)
CloseBtn.MouseLeave:Connect(function()
    Tw(CloseBtn, 0.15, { BackgroundTransparency = 0.4, BackgroundColor3 = CFG.BgPanel })
end)

local TabBar = New("Frame", {
    Size = UDim2.new(0, 136, 1, -50),
    Position = UDim2.new(0, 0, 0, 50),
    BackgroundTransparency = 1,
    BorderSizePixel = 0, Parent = Main, ZIndex = 3,
})
New("UIListLayout", {
    Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = TabBar,
})
New("UIPadding", { PaddingTop = UDim.new(0, 10), Parent = TabBar })

local Content = New("Frame", {
    Size = UDim2.new(1, -150, 1, -80),
    Position = UDim2.new(0, 142, 0, 56),
    BackgroundTransparency = 1, ClipsDescendants = true,
    Parent = Main, ZIndex = 3,
})

local Scroll = New("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = CFG.Accent1,
    ScrollBarImageTransparency = 0.3,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = Content,
})
New("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Scroll })
New("UIPadding", { PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = Scroll })

local ToggleBtn = New("TextButton", {
    Name = "FloatingBtn",
    Size = UDim2.new(0, 54, 0, 54),
    Position = UDim2.new(0, 16, 0.5, -27),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BorderSizePixel = 0, Text = "FH",
    Font = Enum.Font.GothamBold, TextSize = 17,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Visible = false, ZIndex = 100,
    Parent = ScreenGui, AutoButtonColor = false,
})
Corner(ToggleBtn, UDim.new(0, 14))
Gradient(ToggleBtn)
Stroke(ToggleBtn, Color3.fromRGB(255, 255, 255), 1.5, 0.5)

local btnDragActive = false
ToggleBtn.MouseEnter:Connect(function() Tw(ToggleBtn, 0.15, { Size = UDim2.new(0, 60, 0, 60) }, Enum.EasingStyle.Back) end)
ToggleBtn.MouseLeave:Connect(function()
    if not btnDragActive then Tw(ToggleBtn, 0.15, { Size = UDim2.new(0, 54, 0, 54) }) end
end)

local NotifWrap = New("Frame", {
    Size = UDim2.new(0, 270, 0, 400),
    Position = UDim2.new(1, -280, 0, 12),
    BackgroundTransparency = 1, ClipsDescendants = true,
    Parent = ScreenGui, ZIndex = 90,
})
NotifBox = New("Frame", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = NotifWrap,
})
New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = NotifBox })

-- ═══════════════════════ UI КОМПОНЕНТЫ ═══════════════════════
local function Section(parent, title)
    local f = New("Frame", { Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Parent = parent })
    local line = New("Frame", {
        Size = UDim2.new(0, 14, 0, 2),
        Position = UDim2.new(0, 4, 0.5, 0),
        BackgroundColor3 = CFG.Accent2, BorderSizePixel = 0, Parent = f,
    })
    Corner(line, UDim.new(1, 0))
    New("TextLabel", {
        Text = string.upper(title), Font = Enum.Font.GothamBold, TextSize = 10,
        TextColor3 = CFG.TextSub, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 24, 0, 0), Parent = f,
    })
end

local StatusDot, StatusLabel
local function RefreshStatus()
    local cnt = 0
    for k, v in pairs(State) do
        if type(v) == "boolean" and v then cnt += 1 end
    end
    if StatusLabel then
        StatusLabel.Text = cnt > 0 and ("Активно: " .. cnt) or "Все функции выключены"
        Tw(StatusDot, 0.2, { BackgroundColor3 = cnt > 0 and CFG.Success or CFG.TextSub })
        StatusLabel.TextColor3 = cnt > 0 and CFG.Success or CFG.TextSub
    end
end

local function Toggle(parent, iconName, text, def, cb)
    local s = def or false
    local f = New("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = CFG.BgPanel,
        BackgroundTransparency = 0.15, BorderSizePixel = 0, Parent = parent,
    })
    Corner(f, UDim.new(0, 12))
    local fStroke = Stroke(f, CFG.Accent1, 1, 0.75)

    local iconBg = New("Frame", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 8, 0.5, -14),
        BackgroundColor3 = CFG.Accent1,
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0, Parent = f,
    })
    Corner(iconBg, UDim.new(0, 8))
    MakeIcon(iconBg, iconName, 14, CFG.Accent2)

    New("TextLabel", {
        Text = text, Font = Enum.Font.GothamMedium, TextSize = 12,
        TextColor3 = CFG.Text, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1, Size = UDim2.new(0.65, 0, 1, 0),
        Position = UDim2.new(0, 44, 0, 0), Parent = f,
    })

    local sw = New("Frame", {
        Size = UDim2.new(0, 42, 0, 23),
        Position = UDim2.new(1, -50, 0.5, -11.5),
        BackgroundColor3 = s and CFG.Accent1 or Color3.fromRGB(40, 40, 60),
        BackgroundTransparency = 0.1, BorderSizePixel = 0, Parent = f,
    })
    Corner(sw, UDim.new(1, 0))
    if s then Gradient(sw) end

    local knob = New("Frame", {
        Size = UDim2.new(0, 17, 0, 17),
        Position = s and UDim2.new(1, -20, 0.5, -8.5) or UDim2.new(0, 3, 0.5, -8.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0, Parent = sw,
    })
    Corner(knob, UDim.new(1, 0))

    f.MouseEnter:Connect(function()
        Tw(f, 0.15, { BackgroundColor3 = CFG.BgHover })
        Tw(fStroke, 0.15, { Transparency = 0.45 })
    end)
    f.MouseLeave:Connect(function()
        Tw(f, 0.15, { BackgroundColor3 = CFG.BgPanel })
        Tw(fStroke, 0.15, { Transparency = 0.75 })
    end)

    local hit = New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = f })
    hit.MouseButton1Click:Connect(function()
        s = not s
        if s then
            Tw(sw, 0.25, { BackgroundColor3 = CFG.Accent1 })
            Tw(knob, 0.25, { Position = UDim2.new(1, -20, 0.5, -8.5) }, Enum.EasingStyle.Back)
            if not sw:FindFirstChildOfClass("UIGradient") then Gradient(sw) end
        else
            Tw(sw, 0.25, { BackgroundColor3 = Color3.fromRGB(40, 40, 60) })
            Tw(knob, 0.25, { Position = UDim2.new(0, 3, 0.5, -8.5) }, Enum.EasingStyle.Back)
            local g = sw:FindFirstChildOfClass("UIGradient")
            if g then g:Destroy() end
        end
        Tw(iconBg, 0.2, { BackgroundTransparency = s and 0.4 or 0.82 })
        if cb then pcall(cb, s) end
        RefreshStatus()
    end)
    return s
end

local function Slider(parent, iconName, text, minVal, maxVal, default, suffix, cb)
    local value = default or minVal
    suffix = suffix or ""

    local f = New("Frame", {
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = CFG.BgPanel,
        BackgroundTransparency = 0.15, BorderSizePixel = 0, Parent = parent,
    })
    Corner(f, UDim.new(0, 12))
    local fStroke = Stroke(f, CFG.Accent1, 1, 0.75)

    local iconBg = New("Frame", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = CFG.Accent1,
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0, Parent = f,
    })
    Corner(iconBg, UDim.new(0, 8))
    MakeIcon(iconBg, iconName, 14, CFG.Accent2)

    New("TextLabel", {
        Text = text, Font = Enum.Font.GothamMedium, TextSize = 12,
        TextColor3 = CFG.Text, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 0, 20),
        Position = UDim2.new(0, 44, 0, 8), Parent = f,
    })

    local valLabel = New("TextLabel", {
        Text = tostring(value) .. suffix, Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = CFG.Accent2, TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundTransparency = 1, Size = UDim2.new(0, 80, 0, 20),
        Position = UDim2.new(1, -88, 0, 8), Parent = f,
    })

    local track = New("Frame", {
        Size = UDim2.new(1, -88, 0, 5),
        Position = UDim2.new(0, 44, 0, 36),
        BackgroundColor3 = Color3.fromRGB(40, 40, 60),
        BorderSizePixel = 0, Parent = f,
    })
    Corner(track, UDim.new(1, 0))

    local fill = New("Frame", {
        Size = UDim2.new((value - minVal) / (maxVal - minVal), 0, 1, 0),
        BackgroundColor3 = CFG.Accent1,
        BorderSizePixel = 0, Parent = track,
    })
    Corner(fill, UDim.new(1, 0))
    Gradient(fill, CFG.Accent3, CFG.Accent2)

    local knob = New("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((value - minVal) / (maxVal - minVal), 0, 0.5, -7),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0, Parent = track,
    })
    Corner(knob, UDim.new(1, 0))

    local hit = New("TextButton", {
        Text = "", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Parent = f,
    })

    local dragging = false
    local function SetFromX(mouseX)
        local absPos = track.AbsolutePosition
        local absSize = track.AbsoluteSize
        local alpha = math.clamp((mouseX - absPos.X) / absSize.X, 0, 1)
        value = math.floor(minVal + alpha * (maxVal - minVal) + 0.5)
        Tw(fill, 0.08, { Size = UDim2.new(alpha, 0, 1, 0) })
        Tw(knob, 0.08, { Position = UDim2.new(alpha, 0, 0.5, -7) })
        valLabel.Text = tostring(value) .. suffix
        if cb then pcall(cb, value) end
    end

    hit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            SetFromX(i.Position.X)
        end
    end)
    hit.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            SetFromX(i.Position.X)
        end
    end)

    f.MouseEnter:Connect(function()
        Tw(f, 0.15, { BackgroundColor3 = CFG.BgHover })
        Tw(fStroke, 0.15, { Transparency = 0.45 })
    end)
    f.MouseLeave:Connect(function()
        Tw(f, 0.15, { BackgroundColor3 = CFG.BgPanel })
        Tw(fStroke, 0.15, { Transparency = 0.75 })
    end)
end

-- ═══════════════════════ ВКЛАДКИ ═══════════════════════
local Tabs = {}
local function MakeTab(name, iconName)
    local b = New("TextButton", {
        Name = name,
        Text = "", Font = Enum.Font.GothamMedium, TextSize = 12,
        BackgroundColor3 = CFG.BgPanel,
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.new(1, -12, 0, 36), Parent = TabBar,
        AutoButtonColor = false,
    })
    Corner(b, UDim.new(0, 10))
    local bStroke = Stroke(b, CFG.Accent1, 1, 1)

    local ind = New("Frame", {
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = CFG.Accent2, BorderSizePixel = 0, Parent = b,
    })
    Corner(ind, UDim.new(1, 0))

    MakeIcon(b, iconName, 14, CFG.Accent2).Position = UDim2.new(0, 16, 0.5, 0)

    New("TextLabel", {
        Text = name, Font = Enum.Font.GothamMedium, TextSize = 12,
        TextColor3 = CFG.TextSub, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 34, 0, 0), Parent = b,
    })

    local page = New("Frame", {
        Name = name .. "Page", Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Visible = false, Parent = Scroll,
    })
    New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
    Tabs[name] = { Btn = b, Ind = ind, Page = page, Stroke = bStroke }

    b.MouseEnter:Connect(function()
        if not page.Visible then Tw(b, 0.15, { BackgroundTransparency = 0.6 }) end
    end)
    b.MouseLeave:Connect(function()
        if not page.Visible then Tw(b, 0.15, { BackgroundTransparency = 1 }) end
    end)

    b.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Page.Visible = false
            Tw(t.Btn, 0.18, { BackgroundTransparency = 1 })
            Tw(t.Ind, 0.18, { Size = UDim2.new(0, 3, 0, 0) })
            Tw(t.Stroke, 0.18, { Transparency = 1 })
        end
        page.Visible = true
        Tw(b, 0.18, { BackgroundTransparency = 0.15, BackgroundColor3 = CFG.BgPanel })
        Tw(ind, 0.25, { Size = UDim2.new(0, 3, 0, 18) }, Enum.EasingStyle.Back)
        Tw(bStroke, 0.18, { Transparency = 0.5 })
    end)
    return page
end

local MainTab   = MakeTab("Main", "key")
local EspTab    = MakeTab("ESP", "target")
local BypassTab = MakeTab("Bypass", "shield")
local PlayerTab = MakeTab("Игрок", "person")
local SettingsTab = MakeTab("Настройки", "sliders")

Tabs["Main"].Btn.BackgroundTransparency = 0.15
Tabs["Main"].Ind.Size = UDim2.new(0, 3, 0, 18)
Tabs["Main"].Stroke.Transparency = 0.5
Tabs["Main"].Page.Visible = true

local StatusBar = New("Frame", {
    Size = UDim2.new(1, -24, 0, 22),
    Position = UDim2.new(0, 12, 1, -30),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Parent = Main, ZIndex = 3,
})
StatusDot = New("Frame", {
    Size = UDim2.new(0, 7, 0, 7),
    Position = UDim2.new(0, 0, 0.5, -3.5),
    BackgroundColor3 = CFG.TextSub, BorderSizePixel = 0, Parent = StatusBar, ZIndex = 4,
})
Corner(StatusDot, UDim.new(1, 0))
StatusLabel = New("TextLabel", {
    Text = "Все функции выключены", Font = Enum.Font.Gotham, TextSize = 10,
    TextColor3 = CFG.TextSub, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0),
    Position = UDim2.new(0, 14, 0, 0), Parent = StatusBar, ZIndex = 4,
})
New("TextLabel", {
    Text = "FABLE HUB DOORS © 2026", Font = Enum.Font.Code, TextSize = 9,
    TextColor3 = CFG.TextSub, TextTransparency = 0.4,
    TextXAlignment = Enum.TextXAlignment.Right,
    BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0),
    Position = UDim2.new(0.5, 0, 0, 0), Parent = StatusBar, ZIndex = 4,
})

-- ═══════════════════════ ФИЛЬТРЫ ═══════════════════════
local BLACKLIST = {
    ["Books"] = true, ["Book"] = true, ["Darker"] = true,
    ["Bookshelf"] = true, ["Bookcase"] = true,
    ["Ceiling"] = true, ["Ceiling_Detail"] = true,
    ["Wall"] = true, ["Walls"] = true, ["WallPart"] = true,
    ["Floor"] = true, ["Curtain"] = true, ["Curtains"] = true,
    ["Drape"] = true, ["Drapes"] = true, ["Window"] = true,
    ["Doorframe"] = true, ["Start_DoorFrame"] = true,
    ["Asphalt"] = true,
    ["Lamp"] = true, ["Light"] = true, ["Chair"] = true,
    ["Carpet"] = true, ["Rug"] = true, ["Plant"] = true,
    ["Vase"] = true, ["Trash"] = true, ["Debris"] = true,
    ["Camera"] = true, ["Terrain"] = true, ["Baseplate"] = true,
    ["Knob"] = true,
}

local function isRushEntity(obj)
    if BLACKLIST[obj.Name] then return false end
    return (obj.Name == "RushMoving" or obj.Name == "RushNew")
        and (obj:IsA("Model") or obj:IsA("BasePart"))
end
local function isEyesEntity(obj)
    if BLACKLIST[obj.Name] then return false end
    if obj:IsA("BasePart") and (obj.Name == "Eyes_Happy" or obj.Name == "Eyes_Open") then return true end
    if obj:IsA("Model") and obj.Name == "Eyes" then return true end
    return false
end
local function isScreechEntity(obj)
    if BLACKLIST[obj.Name] then return false end
    return obj.Name == "Screech" and obj:IsA("Model")
end
local function isAmbushEntity(obj)
    if BLACKLIST[obj.Name] then return false end
    return (obj.Name == "AmbushMoving" or obj.Name == "AmbushNew")
        and (obj:IsA("Model") or obj:IsA("BasePart"))
end
local function isWardrobeEntity(obj)
    if BLACKLIST[obj.Name] then return false end
    if obj.Name ~= "Wardrobe" then return false end
    if not obj:IsA("Model") then return false end
    local pp = obj:FindFirstChildWhichIsA("ProximityPrompt", false)
    if not pp then return false end
    local action = (pp.ActionText or ""):lower()
    local object = (pp.ObjectText or ""):lower()
    return action == "hide" and object == "wardrobe"
end
local function isWardrobeCandidate(obj)
    if BLACKLIST[obj.Name] then return false end
    return obj.Name == "Wardrobe" and obj:IsA("Model")
end
local function isKeyEntity(obj)
    if BLACKLIST[obj.Name] then return false end
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then return false end
    return obj.Name == "KeyObtain" or obj.Name == "SallyToyObtain"
end
local function isFakeDoorEntity(obj)
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then return false end
    if BLACKLIST[obj.Name] then return false end
    local n = obj.Name
    local ln = n:lower()
    if n == "dupeDoor" or n == "BlockedDoor" or n == "FakeDoor" or n == "TrapDoor" or n == "TrickDoor" then return true end
    if ln:find("fake") or ln:find("trap") or ln:find("trick") or ln:find("dupe") or ln:find("blocked") then return true end
    if n == "0" then
        local pp = obj:FindFirstChildWhichIsA("ProximityPrompt", false)
        if pp and (pp.ObjectText or ""):lower() == "key" then return true end
    end
    return false
end
local function isKnobEntity(obj)
    if obj.Name ~= "Knobs" then return false end
    if not (obj:IsA("MeshPart") or obj:IsA("BasePart") or obj:IsA("Model")) then return false end
    local p = obj.Parent
    if p and (p.Name == "DrawerContainer" or p.Name == "Table" or p.Name == "Dresser") then
        return true
    end
    return false
end
local function isGoldEntity(obj)
    if obj.Name ~= "GoldPile" then return false end
    if not obj:IsA("Model") then return false end
    if not obj:FindFirstChild("LootPrompt") then return false end
    return true
end
local function isBandageEntity(obj)
    return obj.Name == "Bandage" and obj:IsA("Model")
end
local function isHintBookEntity(obj)
    return obj.Name == "LiveHintBook" and obj:IsA("Model")
end
local function isLeverEntity(obj)
    return obj.Name == "LeverForGate" and obj:IsA("Model")
end

-- ═══════════════════════ ESP С ПОДПИСЯМИ ═══════════════════════
local function ClearESP()
    for _, h in ipairs(espObjects) do pcall(function() h:Destroy() end) end
    espObjects = {}
    for _, b in ipairs(espBillboards) do pcall(function() b:Destroy() end) end
    espBillboards = {}
    seenESP = {}
end

local function CreateBillboard(target, text, color)
    if not target or not target.Parent then return end
    local part = target:IsA("BasePart") and target or target:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "FH_ESP_Label"
    bb.Adornee = part
    bb.Size = UDim2.new(0, 120, 0, 22)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.MaxDistance = 500
    bb.Parent = ScreenGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Parent = bb

    table.insert(espBillboards, bb)
end

local function CreateHighlight(target, color, transparency)
    local h = Instance.new("Highlight")
    h.Name = "FH_ESP"
    h.Adornee = target
    h.FillColor = color
    h.OutlineColor = Color3.fromRGB(255, 255, 255)
    h.FillTransparency = transparency or 0.5
    h.OutlineTransparency = 0.1
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = ScreenGui
    table.insert(espObjects, h)
    return h
end

local function UpdateESP()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if not obj or not obj.Parent then continue end
        local id = obj:GetFullName()
        if seenESP[id] then continue end

        if State.espRush and isRushEntity(obj) then
            seenESP[id] = true
            CreateHighlight(obj, CFG.ColorRush, 0.3)
            CreateBillboard(obj, "Rush", CFG.ColorRush)
        elseif State.espEyes and isEyesEntity(obj) then
            seenESP[id] = true
            CreateHighlight(obj, CFG.ColorEyes, 0.4)
            CreateBillboard(obj, "Eyes", CFG.ColorEyes)
        elseif State.espScreech and isScreechEntity(obj) then
            seenESP[id] = true
            CreateHighlight(obj, CFG.ColorScreech, 0.35)
            CreateBillboard(obj, "Screech", CFG.ColorScreech)
        elseif State.espWardrobe and isWardrobeEntity(obj) then
            seenESP[id] = true
            CreateHighlight(obj, CFG.ColorWardrobe, 0.55)
            CreateBillboard(obj, "Шкаф", CFG.ColorWardrobe)
        elseif State.espKey and isKeyEntity(obj) then
            seenESP[id] = true
            CreateHighlight(obj, CFG.ColorKey, 0.35)
            CreateBillboard(obj, "Ключ", CFG.ColorKey)
        elseif State.espFakeDoor and isFakeDoorEntity(obj) then
            seenESP[id] = true
            CreateHighlight(obj, CFG.ColorFakeDoor, 0.2)
            CreateBillboard(obj, "ФЕЙК", CFG.ColorFakeDoor)
        elseif State.espKnobs and isKnobEntity(obj) then
            seenESP[id] = true
            CreateHighlight(obj, CFG.ColorKnob, 0.5)
            CreateBillboard(obj, "Монеты", CFG.ColorKnob)
        elseif State.espGold and isGoldEntity(obj) then
            seenESP[id] = true
            CreateHighlight(obj, CFG.ColorGold, 0.5)
            CreateBillboard(obj, "Золото", CFG.ColorGold)
        elseif State.espBandage and isBandageEntity(obj) then
            seenESP[id] = true
            CreateHighlight(obj, CFG.ColorBandage, 0.4)
            CreateBillboard(obj, "Пластырь", CFG.ColorBandage)
        elseif State.espHintBook and isHintBookEntity(obj) then
            seenESP[id] = true
            CreateHighlight(obj, CFG.ColorHintBook, 0.3)
            CreateBillboard(obj, "Книга", CFG.ColorHintBook)
        elseif State.espLever and isLeverEntity(obj) then
            seenESP[id] = true
            CreateHighlight(obj, CFG.ColorLever, 0.3)
            CreateBillboard(obj, "Рычаг", CFG.ColorLever)
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        UpdateESP()
    end
end)

-- ═══════════════════════ AUTO CLOSET ═══════════════════════
local function FindNearestWardrobe(maxRange)
    if not rootPart then return nil, math.huge end
    local myPos = rootPart.Position
    local best, bestDist = nil, math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj and obj.Parent and isWardrobeCandidate(obj) then
            local pp = obj:FindFirstChildWhichIsA("ProximityPrompt", false)
            if pp and ((pp.ActionText or ""):lower() == "hide") then
                local p = obj:FindFirstChildWhichIsA("BasePart")
                if p then
                    local d = (p.Position - myPos).Magnitude
                    if d < bestDist and (not maxRange or d <= maxRange) then
                        bestDist = d
                        best = { Wardrobe = obj, Prompt = pp, Part = p }
                    end
                end
            end
        end
    end
    return best, bestDist
end

local function FirePrompt(pp)
    if not pp then return end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(pp)
        else
            pp:InputHoldBegin()
            task.wait(0.1)
            pp:InputHoldEnd()
        end
    end)
end

local autoClosetActive = false

task.spawn(function()
    while true do
        task.wait(0.3)
        if not State.autoCloset then autoClosetActive = false; continue end
        if autoClosetActive then continue end
        if not rootPart or not humanoid or humanoid.Health <= 0 then continue end

        local hasEntity = false
        for _, obj in ipairs(workspace:GetDescendants()) do
            if isRushEntity(obj) or isAmbushEntity(obj) then
                hasEntity = true
                break
            end
        end

        if not hasEntity then continue end

        autoClosetActive = true
        local spot, dist = FindNearestWardrobe(CFG.AutoClosetRange)
        if spot then
            Notify("Auto Closet", string.format("ТП в шкаф (%.0f studs)", dist or 0), 2, "success")

            if spot.Part and rootPart then
                pcall(function()
                    rootPart.CFrame = CFrame.new(spot.Part.Position + Vector3.new(0, 2, 0))
                    rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end)
                task.wait(0.2)
            end

            FirePrompt(spot.Prompt)
            task.wait(0.15)
            FirePrompt(spot.Prompt)
            task.wait(0.3)

            if character:GetAttribute("Hiding") == true then
                Notify("Auto Closet", "Спрятан!", 1.5, "success")
            end
        else
            Notify("Auto Closet", "Шкаф не найден", 2, "error")
        end
        task.wait(3)
        autoClosetActive = false
    end
end)

-- ═══════════════════════ INFINITE REVIVES ═══════════════════════
local remotesFolder = ReplicatedStorage:FindFirstChild("RemotesFolder")
if not remotesFolder then remotesFolder = ReplicatedStorage:FindFirstChild("EntityInfo") end
if not remotesFolder then remotesFolder = ReplicatedStorage:FindFirstChild("Bricks") end

local reviveRemote = remotesFolder and remotesFolder:FindFirstChild("Revive")

task.spawn(function()
    while true do
        task.wait(1)
        if not State.infiniteRevives then continue end
        if not reviveRemote then continue end
        if LocalPlayer:GetAttribute("Alive") == false then
            pcall(function() reviveRemote:FireServer() end)
            task.wait(2)
        end
    end
end)

-- ═══════════════════════ INSTANT PROMPTS ═══════════════════════
task.spawn(function()
    while true do
        task.wait(2)
        if not State.instantPrompts and not State.promptReach then continue end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                pcall(function()
                    if State.instantPrompts then obj.HoldDuration = 0 end
                    if State.promptReach then obj.MaxActivationDistance = math.max(obj.MaxActivationDistance, 20) end
                end)
            end
        end
    end
end)

-- ═══════════════════════ TRANSPARENT HIDING ═══════════════════════
task.spawn(function()
    while true do
        task.wait(0.5)
        if not State.transparentHide or not character then continue end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "Wardrobe" and obj:IsA("Model") then
                local hidden = obj:FindFirstChild("HiddenPlayer")
                local isMe = hidden and hidden:IsA("ObjectValue") and hidden.Value == character
                for _, p in ipairs(obj:GetDescendants()) do
                    if p:IsA("BasePart") then
                        pcall(function()
                            p.LocalTransparencyModifier = isMe and 0.5 or 0
                        end)
                    end
                end
            end
        end
    end
end)

-- ═══════════════════════ BYPASS ═══════════════════════
task.spawn(function()
    while true do
        task.wait(1)
        if not (State.bypassSeekObstructions or State.bypassSnare or State.bypassGiggle
            or State.bypassDupe or State.bypassVacuum or State.bypassSeekWall
            or State.bypassJeff or State.bypassKillbricks) then
            continue
        end

        for _, obj in ipairs(workspace:GetDescendants()) do
            local n = obj.Name

            if State.bypassSeekObstructions and (n == "Seek_Arm" or n == "ChandelierObstruction") then
                for _, p in ipairs(obj:GetDescendants()) do
                    if p:IsA("BasePart") then pcall(function() p.CanTouch = false end) end
                end
            end

            if State.bypassSeekObstructions and n == "SeekFloodline" then
                pcall(function() obj.CanCollide = false end)
            end

            if State.bypassSnare and n == "Snare" then
                for _, p in ipairs(obj:GetDescendants()) do
                    if p:IsA("BasePart") then pcall(function() p.CanTouch = false end) end
                end
            end

            if State.bypassGiggle and n == "GiggleCeiling" then
                local hb = obj:FindFirstChild("Hitbox")
                if hb then pcall(function() hb.CanTouch = false end) end
            end

            if State.bypassDupe and (n == "DupeDoor" or n == "FakeDoor" or n == "DoorFake") then
                local hidden = obj:FindFirstChild("Hidden")
                if hidden then pcall(function() hidden.CanTouch = false end) end
            end

            if State.bypassVacuum and n == "SideroomSpace" then
                local c = obj:FindFirstChild("Collision")
                if c then pcall(function() c.CanCollide = false; c.CanTouch = false end) end
            end

            if State.bypassKillbricks and n == "Lava" then
                pcall(function() obj.CanTouch = false end)
            end

            if State.bypassSeekWall and n == "ScaryWall" then
                for _, p in ipairs(obj:GetDescendants()) do
                    if p:IsA("BasePart") then
                        pcall(function() p.CanTouch = false; p.CanCollide = false end)
                    end
                end
            end

            if State.bypassJeff and n == "JeffTheKiller" then
                for _, p in ipairs(obj:GetDescendants()) do
                    if p:IsA("BasePart") then
                        pcall(function() p.CanCollide = false; p.CanTouch = false end)
                    end
                end
            end
        end
    end
end)

-- ═══════════════════════ THIRD PERSON ═══════════════════════
RunService.RenderStepped:Connect(function()
    if not State.thirdPerson or not Camera then return end
    local offset = CFrame.new(thirdPersonOffset)
    local newPos = Camera.CFrame * offset
    Camera.CFrame = CFrame.new(newPos.Position, Camera.CFrame.Position + Camera.CFrame.LookVector * 100)
end)

-- ═══════════════════════ WATCHER СУЩНОСТЕЙ ═══════════════════════
task.spawn(function()
    while true do
        task.wait(0.5)
        local hasRush, hasAmbush, hasScreech = false, false, false

        for _, obj in ipairs(workspace:GetDescendants()) do
            if not obj or not obj.Parent then continue end
            if not hasRush and isRushEntity(obj) then hasRush = true end
            if not hasAmbush and isAmbushEntity(obj) then hasAmbush = true end
            if not hasScreech and isScreechEntity(obj) then hasScreech = true end
        end

        if hasRush and not activeEntities.Rush then
            activeEntities.Rush = true
            if CanNotify("Rush") then Notify("RUSH!", "В шкаф!", 2.5, "warn") end
        elseif not hasRush and activeEntities.Rush then
            activeEntities.Rush = false
        end

        if hasAmbush and not activeEntities.Ambush then
            activeEntities.Ambush = true
            if CanNotify("Ambush") then Notify("AMBUSH!", "Много волн!", 3, "error") end
        elseif not hasAmbush and activeEntities.Ambush then
            activeEntities.Ambush = false
        end

        if hasScreech and not activeEntities.Screech then
            activeEntities.Screech = true
            if CanNotify("Screech") then Notify("SCREECH!", "Не двигайся!", 2, "warn") end
        elseif not hasScreech and activeEntities.Screech then
            activeEntities.Screech = false
        end
    end
end)

-- ═══════════════════════ AUTO KEY ═══════════════════════
local autoKeyActive = false
local autoKeyRoutine = nil

local function FindNearestKeyObtain(maxRange)
    if not rootPart then return nil, math.huge end
    local myPos = rootPart.Position
    local best, bestDist = nil, math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj and obj.Parent and isKeyEntity(obj) then
            local p = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if p then
                local d = (p.Position - myPos).Magnitude
                if d < bestDist and (not maxRange or d <= maxRange) then bestDist = d; best = obj end
            end
        end
    end
    return best, bestDist
end

local function ActivateAllPromptsIn(obj)
    if not obj then return end
    for _, pp in ipairs(obj:GetDescendants()) do
        if pp:IsA("ProximityPrompt") then FirePrompt(pp) end
    end
end
    local function StartAutoKey()
    if autoKeyActive then return end
    autoKeyActive = true
    autoKeyRoutine = task.spawn(function()
        while State.autoKey do
            task.wait(0.5)
            if not rootPart or not humanoid or humanoid.Health <= 0 then continue end
            if character:FindFirstChild("Key") then continue end
            local key, dist = FindNearestKeyObtain(CFG.KeyRange)
            if not key or not dist then continue end
            Notify("Auto Key", string.format("Ключ: %.0f studs", dist), 1.5, "success")
            local p = key:IsA("BasePart") and key or key:FindFirstChildWhichIsA("BasePart")
            if p and rootPart then
                pcall(function()
                    rootPart.CFrame = CFrame.new(p.Position + Vector3.new(0, 3, 0))
                    rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end)
                task.wait(0.2)
                ActivateAllPromptsIn(key)
                task.wait(0.3)
            end
        end
    end)
end

local function StopAutoKey()
    autoKeyActive = false
    if autoKeyRoutine then pcall(task.cancel, autoKeyRoutine); autoKeyRoutine = nil end
end

-- ═══════════════════════ MAIN TAB ═══════════════════════
Section(MainTab, "Автоматизация")

Toggle(MainTab, "key", "Auto Key (TP)", false, function(s)
    State.autoKey = s
    if s then StartAutoKey(); Notify("Auto Key", "Включен", 2, "success")
    else StopAutoKey(); Notify("Auto Key", "Выключен", 2) end
end)

Toggle(MainTab, "wardrobe", "Auto Closet (ТП в шкаф)", false, function(s)
    State.autoCloset = s
    if s then Notify("Auto Closet", "Включён (радиус " .. CFG.AutoClosetRange .. ")", 2, "success")
    else Notify("Auto Closet", "Выключен", 2) end
end)

Slider(MainTab, "slider", "Auto Closet радиус", 30, 300, CFG.AutoClosetRange, "", function(v)
    CFG.AutoClosetRange = v
end)

Toggle(MainTab, "clock", "Anti-AFK", false, function(s) State.antiAfk = s end)

Toggle(MainTab, "sun", "Fullbright", false, function(s)
    State.fullbright = s
    if s then
        Lighting.Brightness = 3
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.ClockTime = 14
        Notify("Fullbright", "Включен", 2, "success")
    else
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        Notify("Fullbright", "Выключен", 2)
    end
end)

Section(MainTab, "Промпты")
Toggle(MainTab, "sliders", "Instant Prompts", false, function(s)
    State.instantPrompts = s
    if s then Notify("Instant Prompts", "Включены", 2, "success") end
end)

Toggle(MainTab, "sliders", "Prompt Reach", false, function(s)
    State.promptReach = s
    if s then Notify("Prompt Reach", "Включён", 2, "success") end
end)

Section(MainTab, "Реванш")
Toggle(MainTab, "person", "Infinite Revives", false, function(s)
    State.infiniteRevives = s
    if s then
        if reviveRemote then Notify("Revives", "Включены", 2, "success")
        else Notify("Revives", "Remote не найден", 2, "error") end
    else Notify("Revives", "Выключены", 2) end
end)

Toggle(MainTab, "wardrobe", "Transparent Hiding Spots", false, function(s)
    State.transparentHide = s
    if s then Notify("Прозрачные шкафы", "Включено", 2, "success") end
end)

task.spawn(function()
    while true do
        task.wait(60)
        if State.antiAfk then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- ═══════════════════════ ESP TAB ═══════════════════════
Section(EspTab, "Сущности")
Toggle(EspTab, "knife", "ESP Rush", false, function(s) State.espRush = s; if not s then ClearESP() end; UpdateESP() end)
Toggle(EspTab, "eye", "ESP Eyes", false, function(s) State.espEyes = s; if not s then ClearESP() end; UpdateESP() end)
Toggle(EspTab, "eye", "ESP Screech", false, function(s) State.espScreech = s; if not s then ClearESP() end; UpdateESP() end)

Section(EspTab, "Объекты (с подписями)")
Toggle(EspTab, "wardrobe", "ESP Wardrobe (Шкаф)", false, function(s) State.espWardrobe = s; if not s then ClearESP() end; UpdateESP() end)
Toggle(EspTab, "key", "ESP Key (Ключ)", false, function(s) State.espKey = s; if not s then ClearESP() end; UpdateESP() end)
Toggle(EspTab, "coin", "ESP Knobs (Монеты)", false, function(s) State.espKnobs = s; if not s then ClearESP() end; UpdateESP() end)
Toggle(EspTab, "coin", "ESP Gold (Золото)", false, function(s) State.espGold = s; if not s then ClearESP() end; UpdateESP() end)

Section(EspTab, "Предметы")
Toggle(EspTab, "person", "ESP Пластырь", false, function(s) State.espBandage = s; if not s then ClearESP() end; UpdateESP() end)
Toggle(EspTab, "key", "ESP Книга (LiveHintBook)", false, function(s) State.espHintBook = s; if not s then ClearESP() end; UpdateESP() end)
Toggle(EspTab, "sliders", "ESP Рычаг (LeverForGate)", false, function(s) State.espLever = s; if not s then ClearESP() end; UpdateESP() end)

Section(EspTab, "Опасность")
Toggle(EspTab, "knife", "ESP Фейковая дверь (ФЕЙК)", false, function(s) State.espFakeDoor = s; if not s then ClearESP() end; UpdateESP() end)

-- ═══════════════════════ BYPASS TAB ═══════════════════════
Section(BypassTab, "Seek препятствия")
Toggle(BypassTab, "shield", "Bypass Seek Obstructions", false, function(s)
    State.bypassSeekObstructions = s
    if s then Notify("Bypass Seek", "Включён — руки/люстры/вода не убьют", 3, "success") end
end)

Section(BypassTab, "Ловушки")
Toggle(BypassTab, "shield", "Bypass Snare", false, function(s) State.bypassSnare = s end)
Toggle(BypassTab, "shield", "Bypass Giggle", false, function(s) State.bypassGiggle = s end)
Toggle(BypassTab, "shield", "Bypass Dupe (фейк двери)", false, function(s) State.bypassDupe = s end)
Toggle(BypassTab, "shield", "Bypass Vacuum", false, function(s) State.bypassVacuum = s end)
Toggle(BypassTab, "shield", "Bypass Seek Wall", false, function(s) State.bypassSeekWall = s end)
Toggle(BypassTab, "shield", "Bypass Jeff", false, function(s) State.bypassJeff = s end)
Toggle(BypassTab, "shield", "Bypass Killbricks (лава)", false, function(s) State.bypassKillbricks = s end)

-- ═══════════════════════ PLAYER TAB ═══════════════════════
Section(PlayerTab, "Передвижение")

Toggle(PlayerTab, "bolt", "Speed Hack", false, function(s)
    State.speedHack = s
    if s then
        if humanoid then humanoid.WalkSpeed = CFG.SpeedValue end
        Notify("Speed Hack", "Скорость: " .. CFG.SpeedValue, 2, "success")
    else
        if humanoid then humanoid.WalkSpeed = 16 end
        Notify("Speed Hack", "Выключен", 2)
    end
end)

Slider(PlayerTab, "slider", "Скорость", 16, 60, CFG.SpeedValue, "", function(v)
    CFG.SpeedValue = v
    if State.speedHack and humanoid then humanoid.WalkSpeed = v end
end)

Toggle(PlayerTab, "sliders", "Infinite Jump", false, function(s) State.infJump = s end)
UserInputService.JumpRequest:Connect(function()
    if State.infJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

Toggle(PlayerTab, "wardrobe", "Noclip", false, function(s)
    State.noclip = s
    if s then Notify("Noclip", "Включен", 2, "success") else Notify("Noclip", "Выключен", 2) end
end)

RunService.Stepped:Connect(function()
    if not State.noclip or not character then return end
    for _, p in ipairs(character:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

Section(PlayerTab, "Камера")
Toggle(PlayerTab, "eye", "Third Person", false, function(s)
    State.thirdPerson = s
    if s then Notify("Third Person", "Включён", 2, "success") end
end)

-- ═══════════════════════ SETTINGS TAB ═══════════════════════
Section(SettingsTab, "Информация")
local infoCard = New("Frame", {
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundColor3 = CFG.Accent1,
    BackgroundTransparency = 0.85, BorderSizePixel = 0, Parent = SettingsTab,
})
Corner(infoCard, UDim.new(0, 12))
Gradient(infoCard, CFG.BgPanel, CFG.Accent1, 90)
New("TextLabel", {
    Text = "FABLE HUB", Font = Enum.Font.GothamBold, TextSize = 16,
    TextColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.new(0, 12, 0, 8), Parent = infoCard,
})
New("TextLabel", {
    Text = "DOORS • " .. CFG.Version, Font = Enum.Font.Code, TextSize = 11,
    TextColor3 = CFG.TextSub, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 16),
    Position = UDim2.new(0, 12, 0, 30), Parent = infoCard,
})

Section(SettingsTab, "Сообщество")
local tgBtn = New("TextButton", {
    Text = "", BackgroundColor3 = CFG.BgPanel,
    BackgroundTransparency = 0.2, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 40), AutoButtonColor = false,
    Parent = SettingsTab,
})
Corner(tgBtn, UDim.new(0, 12))
Stroke(tgBtn, CFG.Accent2, 1, 0.6)
New("TextLabel", {
    Text = "Telegram канал", Font = Enum.Font.GothamMedium, TextSize = 12,
    TextColor3 = CFG.Accent2, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, Size = UDim2.new(1, -110, 1, 0),
    Position = UDim2.new(0, 14, 0, 0), Parent = tgBtn,
})
New("TextLabel", {
    Text = CFG.TelegramHandle, Font = Enum.Font.Code, TextSize = 11,
    TextColor3 = CFG.TextSub, TextXAlignment = Enum.TextXAlignment.Right,
    BackgroundTransparency = 1, Size = UDim2.new(0, 100, 1, 0),
    Position = UDim2.new(1, -108, 0, 0), Parent = tgBtn,
})
tgBtn.MouseButton1Click:Connect(function()
    local opened = false
    pcall(function() GuiService:OpenBrowserWindow(CFG.TelegramURL); opened = true end)
    if not opened then
        pcall(function() if setclipboard then setclipboard(CFG.TelegramURL) end end)
        Notify("Telegram", "Ссылка скопирована", 2.5, "success")
    else
        Notify("Telegram", "Открываю...", 2, "success")
    end
end)

Section(SettingsTab, "Управление")
local unloader = New("TextButton", {
    Text = "", BackgroundColor3 = CFG.BgPanel,
    BackgroundTransparency = 0.2, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 40), AutoButtonColor = false, Parent = SettingsTab,
})
Corner(unloader, UDim.new(0, 12))
Stroke(unloader, CFG.Danger, 1, 0.6)
New("TextLabel", {
    Text = "🗑 Закрыть и выгрузить", Font = Enum.Font.GothamMedium, TextSize = 12,
    TextColor3 = CFG.Danger, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0),
    Position = UDim2.new(0, 14, 0, 0), Parent = unloader,
})
unloader.MouseButton1Click:Connect(function()
    StopAutoKey()
    ClearESP()
    if humanoid then humanoid.WalkSpeed = 16 end
    if character then
        for _, p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
    Tw(Main, 0.2, { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0) })
    task.wait(0.25)
    pcall(function() ScreenGui:Destroy() end)
end)

-- ═══════════════════════ OPEN / CLOSE ═══════════════════════
local function SetMenuOpen(open)
    if open then
        ToggleBtn.Visible = false
        Main.Visible = true
        Shadow.Visible = true
        Main.Size = UDim2.new(0, 0, 0, 0)
        Main.Position = UDim2.new(0.5, 0, 0.5, 0)
        Tw(Main, 0.35, { Size = UDim2.new(0, W, 0, H), Position = UDim2.new(0.5, -W/2, 0.5, -H/2) }, Enum.EasingStyle.Back)
    else
        Tw(Main, 0.25, { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0) })
        task.delay(0.25, function()
            if not Main.Visible then return end
            Main.Visible = false
            Shadow.Visible = false
            ToggleBtn.Visible = true
        end)
    end
end
CloseBtn.MouseButton1Click:Connect(function() SetMenuOpen(false) end)

local mainDrag, mStart, mPos = false, nil, nil
TopBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        mainDrag = true; mStart = i.Position; mPos = Main.Position
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        mainDrag = false
    end
end)

local btnDrag, bStart, bPos, moved = false, nil, nil, false
ToggleBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        btnDrag = true; moved = false; bStart = i.Position; bPos = ToggleBtn.Position
    end
end)
ToggleBtn.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        btnDrag = false; btnDragActive = false
        if not moved then SetMenuOpen(true) end
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        if mainDrag then
            local d = i.Position - mStart
            Main.Position = UDim2.new(mPos.X.Scale, mPos.X.Offset + d.X, mPos.Y.Scale, mPos.Y.Offset + d.Y)
            Shadow.Position = Main.Position + UDim2.new(0, -35, 0, -30)
        elseif btnDrag then
            local d = i.Position - bStart
            if math.abs(d.X) > 6 or math.abs(d.Y) > 6 then
                moved = true; btnDragActive = true
            end
            ToggleBtn.Position = UDim2.new(bPos.X.Scale, bPos.X.Offset + d.X, bPos.Y.Scale, bPos.Y.Offset + d.Y)
        end
    end
end)

-- ═══════════════════════ START ═══════════════════════
task.wait(0.3)
SetMenuOpen(true)
task.delay(0.4, function()
    Notify("Fable Hub DOORS", CFG.Version .. " загружен", 3, "success")
end)

print("[FableHub DOORS] " .. CFG.Version .. " loaded")
