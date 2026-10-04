--[[
    FABLE HUB • RIDE A PET v1.0.0
    Egg ESP / Speed / Fly / Binds
    - Egg ESP (Highlight + Billboard с дистанцией)
    - Фильтр яиц по редкости (Общий → Эфирный)
    - Speed Hack (16-300)
    - Fly (WASD + Space/Shift + Ctrl boost)
    - Anti-AFK / Fullbright / Noclip / InfJump
    - Перетаскивание окна + плавающая кнопка FH
    - Настройка биндов
    - Telegram канал
--]]

if game.PlaceId ~= 124216119978534 then
    warn("[FableHub] This script is for Ride A Pet only!")
    return
end

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")
local CoreGui           = game:GetService("CoreGui")
local GuiService        = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

local CFG = {
    Version     = "v1.0.0",
    Game        = "RIDE A PET",
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
    SpeedValue  = 48,
    FlySpeed    = 50,
    SpeedKey    = Enum.KeyCode.X,
    FlyKey      = Enum.KeyCode.F,
    UIKey       = Enum.KeyCode.RightControl,
    TelegramURL    = "https://t.me/Fable_Hub",
    TelegramHandle = "@Fable_Hub",
}

-- ═══════════════════ БАЗА ЯИЦ ═══════════════════
local RarityRanks = {
    ["Общий"]        = 1,
    ["Редкий"]       = 2,
    ["Эпический"]    = 3,
    ["Легендарный"]  = 4,
    ["Мифический"]   = 5,
    ["Божественный"] = 6,
    ["Эфирный"]      = 7,
    ["Unknown"]      = 99
}

local EggConfig = {
    ["Белое яйцо"]           = { Rarity = "Общий",        Color = Color3.fromRGB(220, 220, 220), Cost = "1",             Enabled = true, Aliases = {"White Egg", "Common Egg"} },
    ["Коричневое яйцо"]      = { Rarity = "Общий",        Color = Color3.fromRGB(150, 100, 60),  Cost = "5",             Enabled = true, Aliases = {"Brown Egg"} },
    ["Треснувшее яйцо"]      = { Rarity = "Редкий",       Color = Color3.fromRGB(120, 180, 220), Cost = "30",            Enabled = true, Aliases = {"Cracked Egg"} },
    ["Пасхальное яйцо"]      = { Rarity = "Редкий",       Color = Color3.fromRGB(100, 220, 170), Cost = "50",            Enabled = true, Aliases = {"Easter Egg"} },
    ["Каменное яйцо"]        = { Rarity = "Редкий",       Color = Color3.fromRGB(140, 140, 140), Cost = "100",           Enabled = true, Aliases = {"Stone Egg", "Rock Egg"} },
    ["Листовое яйцо"]        = { Rarity = "Редкий",       Color = Color3.fromRGB(60, 200, 80),   Cost = "200",           Enabled = true, Aliases = {"Leaf Egg"} },
    ["Грибное яйцо"]         = { Rarity = "Эпический",    Color = Color3.fromRGB(180, 70, 190),  Cost = "500",           Enabled = true, Aliases = {"Mushroom Egg"} },
    ["Цветочное яйцо"]       = { Rarity = "Эпический",    Color = Color3.fromRGB(255, 120, 180), Cost = "750",           Enabled = true, Aliases = {"Flower Egg", "Bloom Egg"} },
    ["Яйцо-слизь"]           = { Rarity = "Эпический",    Color = Color3.fromRGB(80, 230, 90),   Cost = "1 000",         Enabled = true, Aliases = {"Slime Egg"} },
    ["Ледяное яйцо"]         = { Rarity = "Эпический",    Color = Color3.fromRGB(150, 230, 255), Cost = "3 000",         Enabled = true, Aliases = {"Ice Egg", "Frozen Egg"} },
    ["Стеклянное яйцо"]      = { Rarity = "Легендарный",  Color = Color3.fromRGB(180, 240, 240), Cost = "10 000",        Enabled = true, Aliases = {"Glass Egg"} },
    ["Золотое яйцо"]         = { Rarity = "Легендарный",  Color = Color3.fromRGB(255, 200, 0),   Cost = "30 000",        Enabled = true, Aliases = {"Golden Egg", "Gold Egg"} },
    ["Алмазное яйцо"]        = { Rarity = "Мифический",   Color = Color3.fromRGB(70, 190, 255),  Cost = "90 000",        Enabled = true, Aliases = {"Diamond Egg"} },
    ["Хрустальное яйцо"]     = { Rarity = "Мифический",   Color = Color3.fromRGB(180, 140, 255), Cost = "150 000",       Enabled = true, Aliases = {"Crystal Egg"} },
    ["Яйцо-череп"]           = { Rarity = "Мифический",   Color = Color3.fromRGB(210, 210, 200), Cost = "250 000",       Enabled = true, Aliases = {"Skull Egg"} },
    ["Яйцо астероида"]       = { Rarity = "Мифический",   Color = Color3.fromRGB(255, 110, 30),  Cost = "500 000",       Enabled = true, Aliases = {"Asteroid Egg"} },
    ["Яйцо Доминуса"]        = { Rarity = "Мифический",   Color = Color3.fromRGB(200, 40, 40),   Cost = "700 000",       Enabled = true, Aliases = {"Dominus Egg"} },
    ["Пылающее яйцо"]        = { Rarity = "Мифический",   Color = Color3.fromRGB(255, 75, 0),    Cost = "1 000 000",     Enabled = true, Aliases = {"Blazing Egg", "Flame Egg"} },
    ["Зловещее яйцо"]        = { Rarity = "Мифический",   Color = Color3.fromRGB(110, 30, 160),  Cost = "3 000 000",     Enabled = true, Aliases = {"Sinister Egg", "Ominous Egg"} },
    ["Яйцо Души"]            = { Rarity = "Мифический",   Color = Color3.fromRGB(0, 230, 200),   Cost = "7 000 000",     Enabled = true, Aliases = {"Soul Egg"} },
    ["Приливное яйцо"]       = { Rarity = "Мифический",   Color = Color3.fromRGB(0, 130, 255),   Cost = "8 000 000",     Enabled = true, Aliases = {"Tidal Egg", "Ocean Egg"} },
    ["Яйцо Авроры"]          = { Rarity = "Божественный", Color = Color3.fromRGB(0, 255, 180),   Cost = "300 000 000",   Enabled = true, Aliases = {"Aurora Egg"} },
    ["Галактическое яйцо"]   = { Rarity = "Божественный", Color = Color3.fromRGB(160, 60, 255),  Cost = "1.5 млрд",      Enabled = true, Aliases = {"Galaxy Egg", "Galactic Egg"} },
    ["Яйцо Блум"]            = { Rarity = "Божественный", Color = Color3.fromRGB(255, 130, 200), Cost = "2 млрд",        Enabled = true, Aliases = {"Bloom Egg"} },
    ["Яйцо чёрной дыры"]     = { Rarity = "Эфирный",      Color = Color3.fromRGB(90, 0, 190),    Cost = "100 млрд",      Enabled = true, Aliases = {"Black Hole Egg", "Blackhole Egg"} },
    ["Яйцо Солярис"]         = { Rarity = "Эфирный",      Color = Color3.fromRGB(255, 230, 60),  Cost = "300 млрд",      Enabled = true, Aliases = {"Solaris Egg", "Solar Egg"} },
    ["Яйцо херувима"]        = { Rarity = "Эфирный",      Color = Color3.fromRGB(255, 215, 140), Cost = "1 трлн",        Enabled = true, Aliases = {"Cherub Egg"} },
    ["Вулканическое яйцо"]   = { Rarity = "Эфирный",      Color = Color3.fromRGB(230, 30, 0),    Cost = "2.5 трлн",      Enabled = true, Aliases = {"Volcanic Egg", "Volcano Egg"} }
}

local State = {
    eggESP     = true,
    speedHack  = false,
    fly        = false,
    antiAfk    = false,
    fullbright = false,
    noclip     = false,
    infJump    = false,
}

-- ═══════════════════ ХЕЛПЕРЫ UI ═══════════════════
local function New(cls, props, kids)
    local i = Instance.new(cls)
    for k, v in pairs(props or {}) do i[k] = v end
    for _, c in ipairs(kids or {}) do c.Parent = i end
    return i
end

local function Corner(p, r)
    return New("UICorner", { CornerRadius = r or UDim.new(0, 10), Parent = p })
end

local function Stroke(p, c, t, tr)
    return New("UIStroke", {
        Color = c or CFG.Accent1,
        Thickness = t or 1.2,
        Transparency = tr or 0.4,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = p,
    })
end

local function Gradient(p, c1, c2, rot)
    return New("UIGradient", {
        Color = ColorSequence.new(c1 or CFG.Accent3, c2 or CFG.Accent2),
        Rotation = rot or 45,
        Parent = p,
    })
end

local function Tw(o, t, p, style)
    if not o or not o.Parent then return end
    TweenService:Create(o, TweenInfo.new(t or 0.22, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), p):Play()
end

local parentGui = LocalPlayer:WaitForChild("PlayerGui", 5) or CoreGui

-- ═══════════════════ ИКОНКИ ═══════════════════
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

    if name == "coin" then
        ring(0.95); shape(0.38, 0.38, 0.5, 0.5, 0, UDim.new(1, 0))
    elseif name == "clock" then
        ring(0.95); shape(0.1, 0.3, 0.5, 0.37, 0); shape(0.24, 0.1, 0.61, 0.5, 0)
    elseif name == "sun" then
        shape(0.42, 0.42, 0.5, 0.5, 0, UDim.new(1, 0))
        shape(0.09, 0.22, 0.5, 0.09, 0); shape(0.09, 0.22, 0.5, 0.91, 0)
        shape(0.22, 0.09, 0.09, 0.5, 0); shape(0.22, 0.09, 0.91, 0.5, 0)
    elseif name == "jump" then
        shape(0.55, 0.12, 0.31, 0.36, 45); shape(0.55, 0.12, 0.69, 0.36, -45)
        shape(0.11, 0.5, 0.5, 0.68, 0)
    elseif name == "ghost" then
        squareOutline(0.88, UDim.new(0, 3)); shape(0.95, 0.09, 0.5, 0.5, 45)
    elseif name == "knife" then
        shape(0.2, 0.62, 0.6, 0.38, -45, UDim.new(0, 2))
        shape(0.13, 0.28, 0.32, 0.68, -45)
    elseif name == "gun" then
        shape(0.75, 0.16, 0.56, 0.3, 0, UDim.new(0, 2))
        shape(0.15, 0.45, 0.36, 0.62, 0, UDim.new(0, 2))
    elseif name == "box" then
        squareOutline(0.9, UDim.new(0, 3))
        shape(0.5, 0.09, 0.5, 0.28, 0); shape(0.09, 0.4, 0.5, 0.62, 0)
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
    elseif name == "bolt" then
        shape(0.28, 0.45, 0.42, 0.28, -15, UDim.new(0, 1))
        shape(0.28, 0.45, 0.58, 0.72, -15, UDim.new(0, 1))
        shape(0.35, 0.1, 0.5, 0.5, -15)
    elseif name == "bird" then
        shape(0.55, 0.1, 0.32, 0.42, -20, UDim.new(1, 0))
        shape(0.55, 0.1, 0.68, 0.42, 20, UDim.new(1, 0))
        shape(0.22, 0.1, 0.5, 0.62, 0, UDim.new(1, 0))
    elseif name == "slider" then
        shape(0.85, 0.09, 0.5, 0.5, 0, UDim.new(1, 0))
        shape(0.22, 0.22, 0.65, 0.5, 0, UDim.new(1, 0))
    elseif name == "x" then
        shape(0.85, 0.11, 0.5, 0.5, 45, UDim.new(1, 0))
        shape(0.85, 0.11, 0.5, 0.5, -45, UDim.new(1, 0))
    end
    return holder
end

-- ═══════════════════ УВЕДОМЛЕНИЯ ═══════════════════
local NotifBox
local function Notify(title, text, dur, kind)
    if not NotifBox or not NotifBox.Parent then return end
    dur = dur or 2.5
    local accent = kind == "error" and CFG.Danger or (kind == "success" and CFG.Success or CFG.Accent1)

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

-- ═══════════════════ ПЕРСОНАЖ ═══════════════════
local character, humanoid, rootPart

local function SetupChar(ch)
    character = ch
    humanoid = ch:WaitForChild("Humanoid", 10)
    rootPart = ch:WaitForChild("HumanoidRootPart", 10)
    task.wait(0.1)
end

if LocalPlayer.Character then task.spawn(SetupChar, LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(ch) task.spawn(SetupChar, ch) end)

-- ═══════════════════ GUI ═══════════════════
if CoreGui:FindFirstChild("FableHubRideAPet") then CoreGui.FableHubRideAPet:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild("FableHubRideAPet") then LocalPlayer.PlayerGui.FableHubRideAPet:Destroy() end

local ScreenGui = New("ScreenGui", {
    Name = "FableHubRideAPet",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    Parent = parentGui,
})

local vp = Camera and Camera.ViewportSize or Vector2.new(800, 600)
local W = math.clamp(vp.X * 0.85, 460, 600)
local H = math.clamp(vp.Y * 0.72, 360, 460)

local Shadow = New("ImageLabel", {
    Name = "Shadow",
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
    Name = "Main",
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
    Text = "HUB", Font = Enum.Font.GothamBold, TextSize = 15,
    TextColor3 = CFG.Accent2,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 112, 0, 0), Parent = TopBar, ZIndex = 4,
})

New("TextLabel", {
    Text = "• " .. CFG.Game, Font = Enum.Font.GothamMedium, TextSize = 11,
    TextColor3 = CFG.TextSub,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, Size = UDim2.new(0, 160, 1, 0),
    Position = UDim2.new(0, 155, 0, 0), Parent = TopBar, ZIndex = 4,
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
            FpsLabel.TextColor3 = frames >= 50 and CFG.Success or (frames >= 30 and Color3.fromRGB(250, 204, 21) or CFG.Danger)
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
    for _, f in ipairs(CloseBtn:GetDescendants()) do
        if f:IsA("Frame") then Tw(f, 0.15, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }) end
    end
end)
CloseBtn.MouseLeave:Connect(function()
    Tw(CloseBtn, 0.15, { BackgroundTransparency = 0.4, BackgroundColor3 = CFG.BgPanel })
    for _, f in ipairs(CloseBtn:GetDescendants()) do
        if f:IsA("Frame") then Tw(f, 0.15, { BackgroundColor3 = CFG.TextSub }) end
    end
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
ToggleBtn.MouseEnter:Connect(function()
    Tw(ToggleBtn, 0.15, { Size = UDim2.new(0, 60, 0, 60) }, Enum.EasingStyle.Back)
end)
ToggleBtn.MouseLeave:Connect(function()
    if not btnDragActive then Tw(ToggleBtn, 0.15, { Size = UDim2.new(0, 54, 0, 54) }) end
end)

task.spawn(function()
    local glowStroke = ToggleBtn:FindFirstChildOfClass("UIStroke")
    while ToggleBtn.Parent do
        if ToggleBtn.Visible and glowStroke then
            Tw(glowStroke, 1, { Transparency = 0.1 }); task.wait(1)
            Tw(glowStroke, 1, { Transparency = 0.6 }); task.wait(1)
        else
            task.wait(0.5)
        end
    end
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

local activeCount = 0
local StatusDot, StatusLabel

local function RefreshStatus()
    activeCount = 0
    for _, v in pairs(State) do if v then activeCount += 1 end end
    if StatusLabel then
        StatusLabel.Text = activeCount > 0 and ("Активно: " .. activeCount) or "Все функции выключены"
        Tw(StatusDot, 0.2, { BackgroundColor3 = activeCount > 0 and CFG.Success or CFG.TextSub })
        StatusLabel.TextColor3 = activeCount > 0 and CFG.Success or CFG.TextSub
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
    return { Set = function(v)
        if s ~= v then hit:FireButton1Click() end
    end }
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

    return { SetValue = function(v)
        value = math.clamp(v, minVal, maxVal)
        local alpha = (value - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, -7)
        valLabel.Text = tostring(value) .. suffix
        if cb then pcall(cb, value) end
    end }
end

local Tabs = {}
local function MakeTab(name, iconName)
    local b = New("TextButton", {
        Name = name,
        Text = "", Font = Enum.Font.GothamMedium, TextSize = 12,
        BackgroundColor3 = CFG.BgPanel,
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.new(1, -12, 0, 38), Parent = TabBar,
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

local EggsTab     = MakeTab("Яйца", "coin")
local PlayerTab   = MakeTab("Игрок", "person")
local BindsTab    = MakeTab("Настройки", "sliders")

Tabs["Яйца"].Btn.BackgroundTransparency = 0.15
Tabs["Яйца"].Ind.Size = UDim2.new(0, 3, 0, 18)
Tabs["Яйца"].Stroke.Transparency = 0.5
Tabs["Яйца"].Page.Visible = true

local StatusBar = New("Frame", {
    Size = UDim2.new(1, -24, 0, 22),
    Position = UDim2.new(0, 12, 1, -30),
    BackgroundTransparency = 1,
    BorderSizePixel = 0, Parent = Main, ZIndex = 3,
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
    Text = "FABLE HUB © 2026", Font = Enum.Font.Code, TextSize = 9,
    TextColor3 = CFG.TextSub, TextTransparency = 0.4,
    TextXAlignment = Enum.TextXAlignment.Right,
    BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0),
    Position = UDim2.new(0.5, 0, 0, 0), Parent = StatusBar, ZIndex = 4,
})

-- ═══════════════════ ESP СИСТЕМА ═══════════════════
local trackedEggs = {}

local function getEggInfo(name)
    if EggConfig[name] then
        return EggConfig[name].Color, EggConfig[name].Rarity, name
    end
    local cleanName = string.lower(name):gsub("[%s%-_]", "")
    for configName, data in pairs(EggConfig) do
        local checkConfigName = string.lower(configName):gsub("[%s%-_]", "")
        if checkConfigName == cleanName then
            return data.Color, data.Rarity, configName
        end
        if data.Aliases then
            for _, alias in ipairs(data.Aliases) do
                local checkAlias = string.lower(alias):gsub("[%s%-_]", "")
                if checkAlias == cleanName then
                    return data.Color, data.Rarity, configName
                end
            end
        end
    end
    local hash = 0
    for i = 1, #name do
        hash = (hash * 31 + string.byte(name, i)) % 360
    end
    return Color3.fromHSV(hash / 360, 0.8, 1), "Unknown", name
end

local function getEggRoot(inst)
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Model") then
        return inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end

local function applyESP(egg)
    if trackedEggs[egg] then return end
    local root = getEggRoot(egg)
    if not root then return end

    local color, rarity, matchedConfigName = getEggInfo(egg.Name)

    local highlight = Instance.new("Highlight")
    highlight.Name = "FH_ESP_Highlight"
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = egg
    highlight.Parent = egg

    local bill = Instance.new("BillboardGui")
    bill.Name = "FH_ESP_Tag"
    bill.Adornee = root
    bill.Size = UDim2.new(0, 180, 0, 55)
    bill.StudsOffset = Vector3.new(0, 3, 0)
    bill.AlwaysOnTop = true
    bill.MaxDistance = 5000

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.2
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Text = string.format("%s\n[%s]\n[0 м]", matchedConfigName, rarity)
    label.Parent = bill
    bill.Parent = egg

    local isEnabled = EggConfig[matchedConfigName] == nil or EggConfig[matchedConfigName].Enabled
    local visible = State.eggESP and isEnabled
    highlight.Enabled = visible
    bill.Enabled = visible

    trackedEggs[egg] = {
        Highlight = highlight,
        Billboard = bill,
        Label = label,
        ConfigName = matchedConfigName,
        Rarity = rarity,
        Root = root
    }

    egg.AncestryChanged:Connect(function(_, parent)
        if not parent then trackedEggs[egg] = nil end
    end)
end

local function refreshESPVisibility()
    for egg, item in pairs(trackedEggs) do
        if egg and egg.Parent then
            local isEnabled = EggConfig[item.ConfigName] == nil or EggConfig[item.ConfigName].Enabled
            local visible = State.eggESP and isEnabled
            item.Highlight.Enabled = visible
            item.Billboard.Enabled = visible
        else
            trackedEggs[egg] = nil
        end
    end
end

local function scanForEggs()
    local eggsFolder = workspace:FindFirstChild("RenderedEggs", true)
    if eggsFolder then
        for _, egg in ipairs(eggsFolder:GetChildren()) do
            applyESP(egg)
        end
        eggsFolder.ChildAdded:Connect(function(child)
            task.wait(0.1)
            applyESP(child)
            refreshESPVisibility()
        end)
    end
end

scanForEggs()

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    for egg, item in pairs(trackedEggs) do
        if item.Billboard.Enabled and hrp and item.Root then
            local meters = math.floor((item.Root.Position - hrp.Position).Magnitude * 0.28)
            item.Label.Text = string.format("%s\n[%s]\n[%d м]", item.ConfigName, item.Rarity, meters)
        end
    end
end)

-- ═══════════════════ SPEED / FLY ═══════════════════
local DEFAULT_WALKSPEED = 16
local flyBV, flyBG

local function startFly()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = hrp

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBG.CFrame = hrp.CFrame
    flyBG.P = 10000
    flyBG.Parent = hrp
end

local function stopFly()
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
end

LocalPlayer.CharacterAdded:Connect(function()
    stopFly()
    if State.fly then
        task.wait(0.5)
        startFly()
    end
end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildWhichIsA("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if hum then
        hum.WalkSpeed = State.speedHack and CFG.SpeedValue or DEFAULT_WALKSPEED
    end

    if State.fly and hrp and flyBV and flyBG then
        local moveDir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end

        local speed = CFG.FlySpeed
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then speed = speed * 2 end

        flyBV.Velocity = moveDir.Magnitude > 0 and moveDir.Unit * speed or Vector3.zero
        flyBG.CFrame = Camera.CFrame
    end
end)

-- ═══════════════════ NOCLIP (НАДЁЖНЫЙ) ═══════════════════
local NOCLIP_PARTS = {
    HumanoidRootPart = true,
    UpperTorso = true,
    LowerTorso = true,
    Torso = true,
    Head = true,
}

local noclipConn = nil

local function ApplyNoclipOnce()
    local char = LocalPlayer.Character
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and NOCLIP_PARTS[p.Name] then
            if p.CanCollide then
                pcall(function() p.CanCollide = false end)
            end
        end
    end
end

local function restoreCollision()
    local char = LocalPlayer.Character
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and NOCLIP_PARTS[p.Name] then
            pcall(function() p.CanCollide = true end)
        end
    end
end

local function StartNoclip()
    if noclipConn then return end
    ApplyNoclipOnce()
    noclipConn = RunService.Stepped:Connect(function()
        if not State.noclip then return end
        ApplyNoclipOnce()
    end)
end

local function StopNoclip()
    if noclipConn then
        pcall(function() noclipConn:Disconnect() end)
        noclipConn = nil
    end
    restoreCollision()
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if State.noclip then
        ApplyNoclipOnce()
    end
end)

-- ═══════════════════ ANTIAFK ═══════════════════
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

-- ═══════════════════ ВКЛАДКА ЯЙЦА ═══════════════════
Section(EggsTab, "Управление ESP")
Toggle(EggsTab, "target", "ESP яиц", true, function(s)
    State.eggESP = s
    refreshESPVisibility()
    Notify("Egg ESP", s and "Включен" or "Выключен", 2, s and "success" or nil)
end)

Section(EggsTab, "Фильтр по редкости")

local sortedEggList = {}
for name, data in pairs(EggConfig) do
    table.insert(sortedEggList, {
        Name = name,
        Rarity = data.Rarity,
        Color = data.Color,
        Cost = data.Cost,
        Rank = RarityRanks[data.Rarity] or 99
    })
end
table.sort(sortedEggList, function(a, b)
    if a.Rank == b.Rank then return a.Name < b.Name end
    return a.Rank < b.Rank
end)

local eggButtonRefs = {}

-- Кнопка ВСЕ ВКЛ / ВЫКЛ ВСЕ
local allRow = New("Frame", {
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = CFG.BgPanel,
    BackgroundTransparency = 0.15, BorderSizePixel = 0, Parent = EggsTab,
})
Corner(allRow, UDim.new(0, 12))
Stroke(allRow, CFG.Accent2, 1, 0.4)

MakeIcon(allRow, "box", 14, CFG.Accent2).Position = UDim2.new(0, 22, 0.5, 0)

New("TextLabel", {
    Text = "Переключить все яйца", Font = Enum.Font.GothamMedium, TextSize = 12,
    TextColor3 = CFG.Text, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0),
    Position = UDim2.new(0, 44, 0, 0), Parent = allRow,
})

local allBtn = New("TextButton", {
    Text = "ВЫКЛ ВСЕ", Font = Enum.Font.GothamBold, TextSize = 10,
    BackgroundColor3 = CFG.Accent1, BackgroundTransparency = 0.2,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    BorderSizePixel = 0,
    Size = UDim2.new(0, 96, 0, 24),
    Position = UDim2.new(1, -104, 0.5, -12),
    Parent = allRow, AutoButtonColor = false,
})
Corner(allBtn, UDim.new(0, 8))
Gradient(allBtn)

local allState = true
allBtn.MouseButton1Click:Connect(function()
    allState = not allState
    allBtn.Text = allState and "ВЫКЛ ВСЕ" or "ВКЛ ВСЕ"
    for _, item in ipairs(sortedEggList) do
        EggConfig[item.Name].Enabled = allState
        if eggButtonRefs[item.Name] then eggButtonRefs[item.Name].Set(allState) end
    end
    refreshESPVisibility()
    Notify("Фильтр яиц", allState and "Все включены" or "Все выключены", 1.8, "success")
end)

local currentHeaderRank = nil
for _, item in ipairs(sortedEggList) do
    if currentHeaderRank ~= item.Rank then
        currentHeaderRank = item.Rank
        local header = New("Frame", {
            Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Parent = EggsTab,
        })
        local line = New("Frame", {
            Size = UDim2.new(0, 10, 0, 2),
            Position = UDim2.new(0, 4, 0.5, 0),
            BackgroundColor3 = item.Color, BorderSizePixel = 0, Parent = header,
        })
        Corner(line, UDim.new(1, 0))
        New("TextLabel", {
            Text = string.upper(item.Rarity), Font = Enum.Font.GothamBold, TextSize = 10,
            TextColor3 = item.Color, TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 20, 0, 0), Parent = header,
        })
    end

    local row = New("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = CFG.BgPanel,
        BackgroundTransparency = 0.2, BorderSizePixel = 0, Parent = EggsTab,
    })
    Corner(row, UDim.new(0, 10))
    local rowStroke = Stroke(row, item.Color, 1, 0.7)

    local clrTag = New("Frame", {
        Size = UDim2.new(0, 4, 1, -14),
        Position = UDim2.new(0, 6, 0, 7),
        BackgroundColor3 = item.Color, BorderSizePixel = 0, Parent = row,
    })
    Corner(clrTag, UDim.new(1, 0))

    New("TextLabel", {
        Text = item.Name, Font = Enum.Font.GothamMedium, TextSize = 12,
        TextColor3 = CFG.Text, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1, Size = UDim2.new(0.65, 0, 0, 16),
        Position = UDim2.new(0, 18, 0, 5), Parent = row,
    })
    New("TextLabel", {
        Text = "Цена: " .. item.Cost, Font = Enum.Font.Code, TextSize = 10,
        TextColor3 = CFG.TextSub, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1, Size = UDim2.new(0.65, 0, 0, 14),
        Position = UDim2.new(0, 18, 0, 21), Parent = row,
    })

    local sw = New("Frame", {
        Size = UDim2.new(0, 42, 0, 23),
        Position = UDim2.new(1, -50, 0.5, -11.5),
        BackgroundColor3 = EggConfig[item.Name].Enabled and CFG.Accent1 or Color3.fromRGB(40, 40, 60),
        BackgroundTransparency = 0.1, BorderSizePixel = 0, Parent = row,
    })
    Corner(sw, UDim.new(1, 0))
    if EggConfig[item.Name].Enabled then Gradient(sw) end

    local knob = New("Frame", {
        Size = UDim2.new(0, 17, 0, 17),
        Position = EggConfig[item.Name].Enabled and UDim2.new(1, -20, 0.5, -8.5) or UDim2.new(0, 3, 0.5, -8.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0, Parent = sw,
    })
    Corner(knob, UDim.new(1, 0))

    local hit = New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = row })

    local function setSwitch(v)
        EggConfig[item.Name].Enabled = v
        if v then
            Tw(sw, 0.2, { BackgroundColor3 = CFG.Accent1 })
            Tw(knob, 0.2, { Position = UDim2.new(1, -20, 0.5, -8.5) }, Enum.EasingStyle.Back)
            if not sw:FindFirstChildOfClass("UIGradient") then Gradient(sw) end
        else
            Tw(sw, 0.2, { BackgroundColor3 = Color3.fromRGB(40, 40, 60) })
            Tw(knob, 0.2, { Position = UDim2.new(0, 3, 0.5, -8.5) }, Enum.EasingStyle.Back)
            local g = sw:FindFirstChildOfClass("UIGradient")
            if g then g:Destroy() end
        end
        refreshESPVisibility()
    end

    hit.MouseButton1Click:Connect(function()
        setSwitch(not EggConfig[item.Name].Enabled)
    end)

    row.MouseEnter:Connect(function()
        Tw(row, 0.15, { BackgroundColor3 = CFG.BgHover })
        Tw(rowStroke, 0.15, { Transparency = 0.4 })
    end)
    row.MouseLeave:Connect(function()
        Tw(row, 0.15, { BackgroundColor3 = CFG.BgPanel })
        Tw(rowStroke, 0.15, { Transparency = 0.7 })
    end)

    eggButtonRefs[item.Name] = { Set = setSwitch }
end

-- ═══════════════════ ВКЛАДКА ИГРОК ═══════════════════
Section(PlayerTab, "Движение")

local speedToggleRef
speedToggleRef = Toggle(PlayerTab, "bolt", "Speed Hack", false, function(s)
    State.speedHack = s
    Notify("Speed Hack", s and ("Скорость: " .. CFG.SpeedValue) or "Выключен", 2, s and "success" or nil)
end)

Slider(PlayerTab, "slider", "Скорость ходьбы", 16, 300, CFG.SpeedValue, "", function(v)
    CFG.SpeedValue = v
end)

Toggle(PlayerTab, "bird", "Fly (WASD + Space/Shift)", false, function(s)
    State.fly = s
    if s then
        startFly()
        Notify("Fly", "Space — вверх | Shift — вниз | Ctrl — буст", 3.5, "success")
    else
        stopFly()
        Notify("Fly", "Выключен", 2)
    end
end)

Slider(PlayerTab, "slider", "Скорость полёта", 20, 150, CFG.FlySpeed, "", function(v)
    CFG.FlySpeed = v
end)

Toggle(PlayerTab, "jump", "Infinite Jump", false, function(s) State.infJump = s end)
UserInputService.JumpRequest:Connect(function()
    if State.infJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

Toggle(PlayerTab, "ghost", "Noclip (Safe)", false, function(s)
    State.noclip = s
    if s then
        StartNoclip()
        Notify("Noclip", "Включен", 2, "success")
    else
        StopNoclip()
        Notify("Noclip", "Выключен", 2)
    end
end)

Section(PlayerTab, "Утилиты")
Toggle(PlayerTab, "clock", "Anti-AFK", false, function(s) State.antiAfk = s end)
Toggle(PlayerTab, "sun", "Fullbright", false, function(s)
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

-- ═══════════════════ ВКЛАДКА НАСТРОЙКИ ═══════════════════
Section(BindsTab, "Информация")
local infoCard = New("Frame", {
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundColor3 = CFG.Accent1,
    BackgroundTransparency = 0.85,
    BorderSizePixel = 0, Parent = BindsTab,
})
Corner(infoCard, UDim.new(0, 12))
Gradient(infoCard, CFG.BgPanel, CFG.Accent1, 90)
New("TextLabel", {
    Text = "FABLE HUB • " .. CFG.Game, Font = Enum.Font.GothamBold, TextSize = 15,
    TextColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.new(0, 12, 0, 8), Parent = infoCard,
})
New("TextLabel", {
    Text = CFG.Version, Font = Enum.Font.Code, TextSize = 11,
    TextColor3 = CFG.TextSub, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 16),
    Position = UDim2.new(0, 12, 0, 30), Parent = infoCard,
})

Section(BindsTab, "Бинды")

local listeningAction = nil

local function BindRow(actionName, defaultKey, onSet)
    local row = New("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = CFG.BgPanel,
        BackgroundTransparency = 0.2, BorderSizePixel = 0, Parent = BindsTab,
    })
    Corner(row, UDim.new(0, 10))
    local rowStroke = Stroke(row, CFG.Accent1, 1, 0.7)

    MakeIcon(row, "sliders", 12, CFG.Accent2).Position = UDim2.new(0, 22, 0.5, 0)

    New("TextLabel", {
        Text = actionName, Font = Enum.Font.GothamMedium, TextSize = 12,
        TextColor3 = CFG.Text, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 44, 0, 0), Parent = row,
    })

    local btn = New("TextButton", {
        Text = defaultKey.Name, Font = Enum.Font.GothamBold, TextSize = 11,
        BackgroundColor3 = CFG.Accent1, BackgroundTransparency = 0.15,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 88, 0, 24),
        Position = UDim2.new(1, -96, 0.5, -12),
        Parent = row, AutoButtonColor = false,
    })
    Corner(btn, UDim.new(0, 8))
    Gradient(btn)

    btn.MouseButton1Click:Connect(function()
        btn.Text = "..."
        listeningAction = { Button = btn, Setter = onSet }
    end)

    row.MouseEnter:Connect(function()
        Tw(row, 0.15, { BackgroundColor3 = CFG.BgHover })
        Tw(rowStroke, 0.15, { Transparency = 0.4 })
    end)
    row.MouseLeave:Connect(function()
        Tw(row, 0.15, { BackgroundColor3 = CFG.BgPanel })
        Tw(rowStroke, 0.15, { Transparency = 0.7 })
    end)
end

BindRow("Скрыть/Показать GUI", CFG.UIKey, function(key) CFG.UIKey = key end)
BindRow("Бинд Speed Hack", CFG.SpeedKey, function(key) CFG.SpeedKey = key end)
BindRow("Бинд Fly", CFG.FlyKey, function(key) CFG.FlyKey = key end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if listeningAction and input.UserInputType == Enum.UserInputType.Keyboard then
        listeningAction.Setter(input.KeyCode)
        listeningAction.Button.Text = input.KeyCode.Name
        listeningAction = nil
        return
    end

    if gpe then return end

    if input.KeyCode == CFG.UIKey then
        if Main.Visible then
            SetMenuOpen(false)
        else
            SetMenuOpen(true)
        end
    elseif input.KeyCode == CFG.SpeedKey then
        if speedToggleRef then speedToggleRef.Set(not State.speedHack) end
    elseif input.KeyCode == CFG.FlyKey then
        State.fly = not State.fly
        if State.fly then startFly() else stopFly() end
        Notify("Fly", State.fly and "Включен (биндер)" or "Выключен", 1.5, State.fly and "success" or nil)
    end
end)

Section(BindsTab, "Сообщество")
local tgBtn = New("TextButton", {
    Text = "", BackgroundColor3 = CFG.BgPanel,
    BackgroundTransparency = 0.2, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 40), AutoButtonColor = false,
    Parent = BindsTab,
})
Corner(tgBtn, UDim.new(0, 12))
local tgStroke = Stroke(tgBtn, CFG.Accent2, 1, 0.6)

New("TextLabel", {
    Text = "Telegram канал", Font = Enum.Font.GothamMedium, TextSize = 12,
    TextColor3 = CFG.Accent2, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, Size = UDim2.new(1, -110, 1, 0),
    Position = UDim2.new(0, 44, 0, 0), Parent = tgBtn,
})
New("TextLabel", {
    Text = CFG.TelegramHandle, Font = Enum.Font.Code, TextSize = 11,
    TextColor3 = CFG.TextSub, TextXAlignment = Enum.TextXAlignment.Right,
    BackgroundTransparency = 1, Size = UDim2.new(0, 100, 1, 0),
    Position = UDim2.new(1, -108, 0, 0), Parent = tgBtn,
})

tgBtn.MouseEnter:Connect(function()
    Tw(tgBtn, 0.15, { BackgroundColor3 = CFG.Accent2, BackgroundTransparency = 0.15 })
    Tw(tgStroke, 0.15, { Transparency = 0.1 })
end)
tgBtn.MouseLeave:Connect(function()
    Tw(tgBtn, 0.15, { BackgroundColor3 = CFG.BgPanel, BackgroundTransparency = 0.2 })
    Tw(tgStroke, 0.15, { Transparency = 0.6 })
end)
tgBtn.MouseButton1Click:Connect(function()
    local opened = false
    pcall(function() GuiService:OpenBrowserWindow(CFG.TelegramURL); opened = true end)
    if not opened then
        pcall(function() if setclipboard then setclipboard(CFG.TelegramURL) end end)
        Notify("Telegram", "Ссылка скопирована", 2.5, "success")
    else
        Notify("Telegram", "Открываю " .. CFG.TelegramHandle, 2, "success")
    end
end)

Section(BindsTab, "Управление")
local unloader = New("TextButton", {
    Text = "", BackgroundColor3 = CFG.BgPanel,
    BackgroundTransparency = 0.2, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 40), AutoButtonColor = false, Parent = BindsTab,
})
Corner(unloader, UDim.new(0, 12))
local unloaderStroke = Stroke(unloader, CFG.Danger, 1, 0.6)
MakeIcon(unloader, "trash", 14, CFG.Danger).Position = UDim2.new(0, 26, 0.5, 0)
New("TextLabel", {
    Text = "Закрыть и выгрузить скрипт", Font = Enum.Font.GothamMedium, TextSize = 12,
    TextColor3 = CFG.Danger, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0),
    Position = UDim2.new(0, 44, 0, 0), Parent = unloader,
})
unloader.MouseEnter:Connect(function()
    Tw(unloader, 0.15, { BackgroundColor3 = CFG.Danger })
    Tw(unloaderStroke, 0.15, { Transparency = 0.2 })
end)
unloader.MouseLeave:Connect(function()
    Tw(unloader, 0.15, { BackgroundColor3 = CFG.BgPanel })
    Tw(unloaderStroke, 0.15, { Transparency = 0.6 })
end)
unloader.MouseButton1Click:Connect(function()
    stopFly()
    StopNoclip()
    for egg, item in pairs(trackedEggs) do
        pcall(function() item.Highlight:Destroy() end)
        pcall(function() item.Billboard:Destroy() end)
    end
    trackedEggs = {}
    Tw(Main, 0.2, { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0) })
    task.wait(0.2)
    pcall(function() ScreenGui:Destroy() end)
end)

-- ═══════════════════ ОТКРЫТИЕ / DRAG ═══════════════════
function SetMenuOpen(open)
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
        mainDrag = true
        mStart = i.Position
        mPos = Main.Position
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
        btnDrag = true; moved = false
        bStart = i.Position; bPos = ToggleBtn.Position
    end
end)
ToggleBtn.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        btnDrag = false
        btnDragActive = false
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
                moved = true
                btnDragActive = true
            end
            ToggleBtn.Position = UDim2.new(bPos.X.Scale, bPos.X.Offset + d.X, bPos.Y.Scale, bPos.Y.Offset + d.Y)
        end
    end
end)

task.wait(0.3)
SetMenuOpen(true)
task.delay(0.4, function()
    Notify("Fable Hub • Ride a Pet", "v1.0.0 загружен", 3, "success")
end)
print("[FableHub RideAPet] v1.0.0 loaded OK")
