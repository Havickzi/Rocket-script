--[[
    FABLE HUB ARSENAL v1.2.0
    Original Visual + Arsenal Logic
    - Aimbot (с выбором части тела: голова / тело / ноги)
    - FOV Circle
    - Team Check (не целится в союзников)
    - Wall Check (не целится сквозь стены)
    - ESP
    - Infinite Jump
    - Noclip
    - Speed Hack
    - Anti-AFK / Fullbright
--]]

if game.PlaceId ~= 286090429 then
    warn("[FableHub] This script is for Arsenal only!")
    return
end

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")
local GuiService        = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

local CFG = {
    Version     = "v1.2.0-AR",
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
    TelegramURL    = "https://t.me/Fable_Hub",
    TelegramHandle = "@Fable_Hub",

    -- Часть тела для аимбота
    AimPart        = "Тело",
    AimParts       = {
        ["Голова"] = { "Head" },
        ["Тело"]   = { "HumanoidRootPart", "UpperTorso", "Torso" },
        ["Ноги"]   = { "LeftFoot", "RightFoot", "Left Leg", "Right Leg", "LowerTorso" },
    },

    FOVRadius      = 200,
    FOVColor       = Color3.fromRGB(217, 70, 239),
    ESPColor       = Color3.fromRGB(255, 60, 60),
    SpeedValue     = 45,
    AimSmoothness  = 1,
}

local State = {
    aimbot      = false,
    esp         = false,
    infJump     = false,
    noclip      = false,
    speedHack   = false,
    fullbright  = false,
    antiAfk     = false,
    teamCheck   = false,
    wallCheck   = false,
}

-- ═══════════════════ УТИЛИТЫ ═══════════════════
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

local parentGui = LocalPlayer:WaitForChild("PlayerGui", 5)

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
end

if LocalPlayer.Character then task.spawn(SetupChar, LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(ch) task.spawn(SetupChar, ch) end)

-- ═══════════════════ GUI ═══════════════════
local ScreenGui = New("ScreenGui", {
    Name = "FableHubArsenal",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    Parent = parentGui,
})

local vp = Camera and Camera.ViewportSize or Vector2.new(800, 600)
local W = math.clamp(vp.X * 0.85, 440, 580)
local H = math.clamp(vp.Y * 0.72, 340, 440)

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
    if not btnDragActive then
        Tw(ToggleBtn, 0.15, { Size = UDim2.new(0, 54, 0, 54) })
    end
end)

task.spawn(function()
    local glowStroke = ToggleBtn:FindFirstChildOfClass("UIStroke")
    while ToggleBtn.Parent do
        if ToggleBtn.Visible and glowStroke then
            Tw(glowStroke, 1, { Transparency = 0.1 })
            task.wait(1)
            Tw(glowStroke, 1, { Transparency = 0.6 })
            task.wait(1)
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
end

-- ═══════════════════ SLIDER ═══════════════════
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

-- ═══════════════════ SELECTOR (выбор части тела) ═══════════════════
local function Selector(parent, iconName, text, options, default, cb)
    local current = default or options[1]

    local f = New("Frame", {
        Size = UDim2.new(1, 0, 0, 76),
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

    local row = New("Frame", {
        Size = UDim2.new(1, -52, 0, 30),
        Position = UDim2.new(0, 44, 0, 36),
        BackgroundTransparency = 1, Parent = f,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = row,
    })

    local buttons = {}
    local function refresh()
        for name, btn in pairs(buttons) do
            local active = (name == current)
            Tw(btn, 0.15, {
                BackgroundColor3 = active and CFG.Accent1 or Color3.fromRGB(40, 40, 60),
                BackgroundTransparency = active and 0.05 or 0.1,
            })
            local lbl = btn:FindFirstChildOfClass("TextLabel")
            if lbl then
                Tw(lbl, 0.15, { TextColor3 = active and Color3.fromRGB(255, 255, 255) or CFG.TextSub })
            end
            if active and not btn:FindFirstChildOfClass("UIGradient") then
                Gradient(btn, CFG.Accent3, CFG.Accent2)
            elseif not active then
                local g = btn:FindFirstChildOfClass("UIGradient")
                if g then g:Destroy() end
            end
        end
    end

    for i, name in ipairs(options) do
        local btn = New("TextButton", {
            Text = "", BackgroundColor3 = Color3.fromRGB(40, 40, 60),
            BackgroundTransparency = 0.1, BorderSizePixel = 0,
            Size = UDim2.new(1 / #options, -4, 1, 0),
            LayoutOrder = i, AutoButtonColor = false, Parent = row,
        })
        Corner(btn, UDim.new(0, 8))
        New("TextLabel", {
            Text = name, Font = Enum.Font.GothamMedium, TextSize = 11,
            TextColor3 = CFG.TextSub, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), Parent = btn,
        })
        buttons[name] = btn

        btn.MouseButton1Click:Connect(function()
            current = name
            refresh()
            if cb then pcall(cb, name) end
        end)
        btn.MouseEnter:Connect(function()
            if name ~= current then Tw(btn, 0.12, { BackgroundTransparency = 0 }) end
        end)
        btn.MouseLeave:Connect(function()
            if name ~= current then Tw(btn, 0.12, { BackgroundTransparency = 0.1 }) end
        end)
    end
    refresh()

    f.MouseEnter:Connect(function()
        Tw(f, 0.15, { BackgroundColor3 = CFG.BgHover })
        Tw(fStroke, 0.15, { Transparency = 0.45 })
    end)
    f.MouseLeave:Connect(function()
        Tw(f, 0.15, { BackgroundColor3 = CFG.BgPanel })
        Tw(fStroke, 0.15, { Transparency = 0.75 })
    end)
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

local MainTab     = MakeTab("Main", "coin")
local PlayerTab   = MakeTab("Игрок", "person")
local EspTab      = MakeTab("ЭСП", "target")
local SettingsTab = MakeTab("Настройки", "sliders")

Tabs["Main"].Btn.BackgroundTransparency = 0.15
Tabs["Main"].Ind.Size = UDim2.new(0, 3, 0, 18)
Tabs["Main"].Stroke.Transparency = 0.5
Tabs["Main"].Page.Visible = true

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

-- ═══════════════════ AIMBOT + TEAM/WALL CHECK ═══════════════════
local fovCircle = nil
local aimConn = nil

local function IsVisible(targetPart)
    local origin = Camera.CFrame.Position
    local dir = (targetPart.Position - origin)
    local distance = dir.Magnitude
    if distance < 0.1 then return true end

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    local result = workspace:Raycast(origin, dir.Unit * distance, rayParams)
    if not result then return true end
    return result.Instance:IsDescendantOf(targetPart.Parent)
end

local function GetTargetPart(char)
    local parts = CFG.AimParts[CFG.AimPart]
    if not parts then return nil end
    for _, name in ipairs(parts) do
        local p = char:FindFirstChild(name)
        if p then return p end
    end
    return nil
end

local function GetClosestTarget()
    local center = Camera.ViewportSize / 2
    local closest, closestDist = nil, CFG.FOVRadius

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if State.teamCheck and p.Team == LocalPlayer.Team then continue end

            local part = GetTargetPart(p.Character)
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health > 0 then
                if State.wallCheck and not IsVisible(part) then continue end

                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen and screenPos.Z > 0 then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = part
                    end
                end
            end
        end
    end
    return closest
end

local function CreateFOVCircle()
    if fovCircle then return end
    if not Drawing then
        warn("[FableHub] Drawing API не поддерживается, кружок FOV отключён")
        return
    end
    fovCircle = Drawing.new("Circle")
    fovCircle.Color = CFG.FOVColor
    fovCircle.Thickness = 2
    fovCircle.NumSides = 64
    fovCircle.Filled = false
    fovCircle.Transparency = 0.8
    fovCircle.Radius = CFG.FOVRadius
    fovCircle.Visible = false
end

local function StartAimbot()
    if aimConn then return end
    CreateFOVCircle()

    aimConn = RunService.RenderStepped:Connect(function()
        if fovCircle then
            fovCircle.Visible = State.aimbot
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            fovCircle.Radius = CFG.FOVRadius
        end
        if not State.aimbot then return end

        local target = GetClosestTarget()
        if not target then return end

        local camPos = Camera.CFrame.Position
        local goalCF = CFrame.new(camPos, target.Position)

        if CFG.AimSmoothness <= 1 then
            Camera.CFrame = goalCF
        else
            Camera.CFrame = Camera.CFrame:Lerp(goalCF, 1 / CFG.AimSmoothness)
        end
    end)
end

local function StopAimbot()
    if aimConn then
        aimConn:Disconnect()
        aimConn = nil
    end
    if fovCircle then
        fovCircle.Visible = false
    end
end

-- ═══════════════════ ESP ═══════════════════
local espHighlights = {}
local function ClearESP()
    for _, h in ipairs(espHighlights) do pcall(function() h:Destroy() end) end
    espHighlights = {}
end

local function UpdateESP()
    ClearESP()
    if not State.esp then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local h = Instance.new("Highlight")
                h.Adornee = p.Character
                if State.teamCheck and p.Team == LocalPlayer.Team then
                    h.FillColor = Color3.fromRGB(80, 255, 120)
                else
                    h.FillColor = CFG.ESPColor
                end
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.FillTransparency = 0.5
                h.OutlineTransparency = 0.1
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = ScreenGui
                table.insert(espHighlights, h)
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        if State.esp then UpdateESP() end
    end
end)

-- ═══════════════════ INFINITE JUMP ═══════════════════
UserInputService.JumpRequest:Connect(function()
    if State.infJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ═══════════════════ NOCLIP ═══════════════════
local NOCLIP_PARTS = { HumanoidRootPart = true, UpperTorso = true, LowerTorso = true, Torso = true, Head = true }

local function ApplyNoclip()
    if not State.noclip or not character then return end
    for _, p in ipairs(character:GetChildren()) do
        if p:IsA("BasePart") and NOCLIP_PARTS[p.Name] then p.CanCollide = false end
    end
end

local function RestoreCollision()
    if not character then return end
    for _, p in ipairs(character:GetDescendants()) do
        if p:IsA("BasePart") and not p.CanCollide then
            pcall(function() p.CanCollide = true end)
        end
    end
end

RunService.Stepped:Connect(ApplyNoclip)

-- ═══════════════════ SPEED ═══════════════════
local DEFAULT_WALKSPEED = 16
task.spawn(function()
    while true do
        task.wait(0.1)
        if State.speedHack and humanoid and humanoid.Health > 0 then
            humanoid.WalkSpeed = CFG.SpeedValue
        end
    end
end)

-- ═══════════════════ MAIN TAB ═══════════════════
Section(MainTab, "Combat")
Toggle(MainTab, "target", "Aimbot", false, function(s)
    State.aimbot = s
    if s then
        StartAimbot()
        Notify("Aimbot", "Включен → " .. CFG.AimPart, 2.5, "success")
    else
        StopAimbot()
        Notify("Aimbot", "Выключен", 2)
    end
end)

Selector(MainTab, "target", "Часть тела", {"Голова", "Тело", "Ноги"}, CFG.AimPart, function(name)
    CFG.AimPart = name
    Notify("Aimbot", "Цель: " .. name, 1.8, "success")
end)

Slider(MainTab, "target", "FOV радиус", 50, 400, CFG.FOVRadius, "", function(v)
    CFG.FOVRadius = v
end)

Slider(MainTab, "slider", "Плавность аима", 1, 20, CFG.AimSmoothness, "", function(v)
    CFG.AimSmoothness = v
end)

Toggle(MainTab, "person", "Team Check (не бить своих)", false, function(s)
    State.teamCheck = s
    if State.esp then UpdateESP() end
end)

Toggle(MainTab, "target", "Wall Check (только видимые)", false, function(s)
    State.wallCheck = s
end)

Section(MainTab, "Утилиты")
Toggle(MainTab, "clock", "Anti-AFK", false, function(s) State.antiAfk = s end)
Toggle(MainTab, "sun", "Fullbright", false, function(s)
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

-- ═══════════════════ PLAYER TAB ═══════════════════
Section(PlayerTab, "Передвижение")
Toggle(PlayerTab, "bolt", "Speed Hack", false, function(s)
    State.speedHack = s
    if s then
        Notify("Speed Hack", "Скорость: " .. CFG.SpeedValue, 2, "success")
    else
        if humanoid then humanoid.WalkSpeed = DEFAULT_WALKSPEED end
        Notify("Speed Hack", "Выключен", 2)
    end
end)

Slider(PlayerTab, "slider", "Скорость ходьбы", 16, 60, CFG.SpeedValue, "", function(v)
    CFG.SpeedValue = v
    if State.speedHack and humanoid then humanoid.WalkSpeed = v end
end)

Toggle(PlayerTab, "jump", "Infinite Jump", false, function(s) State.infJump = s end)

Toggle(PlayerTab, "ghost", "Noclip (Safe)", false, function(s)
    State.noclip = s
    if s then ApplyNoclip() else RestoreCollision() end
end)

-- ═══════════════════ ESP TAB ═══════════════════
Section(EspTab, "Подсветка")
Toggle(EspTab, "person", "ESP всех игроков", false, function(s)
    State.esp = s
    if s then
        UpdateESP()
        Notify("ESP", "Включен", 2, "success")
    else
        ClearESP()
        Notify("ESP", "Выключен", 2)
    end
end)

-- ═══════════════════ SETTINGS TAB ═══════════════════
Section(SettingsTab, "Информация")
local infoCard = New("Frame", {
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundColor3 = CFG.Accent1,
    BackgroundTransparency = 0.85,
    BorderSizePixel = 0, Parent = SettingsTab,
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
    Text = "ARSENAL  •  " .. CFG.Version, Font = Enum.Font.Code, TextSize = 11,
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
    Position = UDim2.new(0, 44, 0, 0), Parent = tgBtn,
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
        Notify("Telegram", "Открываю " .. CFG.TelegramHandle, 2, "success")
    end
end)

-- ═══════════════════ UNLOADER ═══════════════════
Section(SettingsTab, "Управление")
local unloader = New("TextButton", {
    Text = "", BackgroundColor3 = CFG.BgPanel,
    BackgroundTransparency = 0.2, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 40), AutoButtonColor = false, Parent = SettingsTab,
})
Corner(unloader, UDim.new(0, 12))
Stroke(unloader, CFG.Danger, 1, 0.6)
MakeIcon(unloader, "trash", 14, CFG.Danger).Position = UDim2.new(0, 26, 0.5, 0)
New("TextLabel", {
    Text = "Закрыть и выгрузить скрипт", Font = Enum.Font.GothamMedium, TextSize = 12,
    TextColor3 = CFG.Danger, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0),
    Position = UDim2.new(0, 44, 0, 0), Parent = unloader,
})

unloader.MouseButton1Click:Connect(function()
    StopAimbot()
    ClearESP()
    RestoreCollision()
    if humanoid then pcall(function() humanoid.WalkSpeed = 16 end) end
    Tw(Main, 0.2, { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0) })
    task.wait(0.2)
    pcall(function() ScreenGui:Destroy() end)
end)

-- ═══════════════════ MENU OPEN / DRAG ═══════════════════
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
    Notify("Fable Hub Arsenal", "v1.2.0 загружен", 3, "success")
end)
print("[FableHub Arsenal] loaded OK")
