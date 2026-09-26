--[[
    FABLE HUB RIVALS v2.0.0
    Rivals Cheat Script — Universal Edition
    Визуал: Fable Hub (фиолетово-маджентовый премиум)
    Функционал: Universal Premium Hub v4.0 (адаптирован под Rivals)
--]]

local CoreGui           = game:GetService("CoreGui")
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")
local HttpService       = game:GetService("HttpService")
local GuiService        = game:GetService("GuiService")
local Workspace         = game:GetService("Workspace")
local MarketplaceService= game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

local PlaceName = "Rivals"
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    if info and info.Name then PlaceName = info.Name end
end)

local CFG = {
    Version     = "v2.0.0",
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
}

local Config = {
    Aimbot = {
        Enabled = false,
        SilentAim = false,
        SilentAimHitChance = 100,
        SilentAimFOV = 120,
        ShowSilentAimFOV = true,
        SilentAimFOVColor = {R = 0.92, G = 0.18, B = 0.18},
        Keybind = "MouseButton2",
        TargetPart = "Head",
        Smoothness = 5,
        FOV = 120,
        ShowFOV = true,
        FOVColor = {R = 0.85, G = 0.28, B = 0.94},
        TeamCheck = false,
        WallCheck = false,
        MaxDistance = 1500,
    },
    ESP = {
        Enabled = false,
        Boxes = true,
        HealthBar = true,
        Names = true,
        Distance = true,
        Tracers = true,
        HeadDot = true,
        TeamCheck = false,
        MaxDistance = 2000,
        EnemyColor = {R = 1, G = 0.25, B = 0.33},
        TeamColor = {R = 0, G = 0.9, B = 0.46},
        TracerColor = {R = 0.54, G = 0.17, B = 0.88},
    },
    Chams = {
        Enabled = false,
        AlwaysOnTop = true,
        FillColor = {R = 0.6, G = 0.2, B = 1},
        OutlineColor = {R = 1, G = 1, B = 1},
        FillTransparency = 0.4,
        OutlineTransparency = 0,
        TeamCheck = false,
    },
    World = {
        EnableSky = false,
        SkyPreset = "Purple Galaxy",
        EnableCameraFOV = false,
        CameraFOV = 90,
        EnableGlass = false,
        GlassStyle = "Glossy Glass",
        EnableFullbright = false,
    },
    Movement = {
        EnableSpeed = false,
        WalkSpeed = 32,
        EnableJump = false,
        JumpPower = 60,
        EnableInfiniteJump = false,
        EnableNoclip = false,
        EnableBoost = true,
        BoostKey = "E",
        BoostPower = 80,
        EnableAutoStrafe = false,
        EnableAntiAfk = false,
    },
    UI = {
        AccentColor = {R = 0.54, G = 0.36, B = 0.96},
    },
}

local State = {}

-- ═══════════════════════ УТИЛИТЫ ═══════════════════════
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

local function ColorToTable(c3) return {R = c3.R, G = c3.G, B = c3.B} end
local function TableToColor(tbl, default)
    if type(tbl) == "table" and tbl.R and tbl.G and tbl.B then
        return Color3.new(tbl.R, tbl.G, tbl.B)
    end
    return default or Color3.fromRGB(255, 255, 255)
end

local parentGui = LocalPlayer:WaitForChild("PlayerGui", 5) or CoreGui

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
            BackgroundColor3 = color, BorderSizePixel = 0, Parent = holder,
        })
        if radius then Corner(f, radius) end
        return f
    end
    local function ring(scale, thickness)
        local f = New("Frame", {
            Size = UDim2.new(scale, 0, scale, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1, Parent = holder,
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
            BackgroundTransparency = 1, Parent = holder,
        })
        Corner(f, radius or UDim.new(0, 3))
        Stroke(f, color, thickness or th, 0)
        return f
    end

    if name == "coin" then ring(0.95); shape(0.38, 0.38, 0.5, 0.5, 0, UDim.new(1, 0))
    elseif name == "clock" then ring(0.95); shape(0.1, 0.3, 0.5, 0.37, 0); shape(0.24, 0.1, 0.61, 0.5, 0)
    elseif name == "sun" then
        shape(0.42, 0.42, 0.5, 0.5, 0, UDim.new(1, 0))
        shape(0.09, 0.22, 0.5, 0.09, 0); shape(0.09, 0.22, 0.5, 0.91, 0)
        shape(0.22, 0.09, 0.09, 0.5, 0); shape(0.22, 0.09, 0.91, 0.5, 0)
    elseif name == "jump" then
        shape(0.55, 0.12, 0.31, 0.36, 45); shape(0.55, 0.12, 0.69, 0.36, -45)
        shape(0.11, 0.5, 0.5, 0.68, 0)
    elseif name == "ghost" then squareOutline(0.88, UDim.new(0, 3)); shape(0.95, 0.09, 0.5, 0.5, 45)
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
    elseif name == "x" then
        shape(0.85, 0.11, 0.5, 0.5, 45, UDim.new(1, 0))
        shape(0.85, 0.11, 0.5, 0.5, -45, UDim.new(1, 0))
    elseif name == "eye" then
        ring(0.85); shape(0.32, 0.32, 0.5, 0.5, 0, UDim.new(1, 0))
    elseif name == "sparkle" then
        shape(0.14, 0.7, 0.5, 0.5, 0, UDim.new(1, 0))
        shape(0.7, 0.14, 0.5, 0.5, 0, UDim.new(1, 0))
    elseif name == "world" then
        ring(0.95)
        shape(0.85, 0.08, 0.5, 0.5, 0, UDim.new(1, 0))
        shape(0.35, 0.08, 0.5, 0.28, 0, UDim.new(1, 0))
        shape(0.35, 0.08, 0.5, 0.72, 0, UDim.new(1, 0))
    end
    return holder
end

-- ═══════════════════════ УВЕДОМЛЕНИЯ ═══════════════════════
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

-- ═══════════════════════ UNIVERSAL CHARACTER RESOLVER ═══════════════════════
local CharCache = {}

local function GetCharacter(player)
    if not player then return nil end
    if player.Character and player.Character.Parent then return player.Character end
    local playerName = player.Name
    local displayName = player.DisplayName
    local containers = {
        Workspace:FindFirstChild("Players"),
        Workspace:FindFirstChild("Characters"),
        Workspace:FindFirstChild("Entities"),
        Workspace:FindFirstChild("Units"),
        Workspace:FindFirstChild("Living"),
        Workspace:FindFirstChild("Alive"),
        Workspace:FindFirstChild("Mobs"),
        Workspace:FindFirstChild("Fighters"),
    }
    pcall(function()
        if Workspace:FindFirstChild("Map") then
            table.insert(containers, Workspace.Map:FindFirstChild("Players"))
            table.insert(containers, Workspace.Map:FindFirstChild("Characters"))
        end
    end)
    for _, c in ipairs(containers) do
        if c then
            local found = c:FindFirstChild(playerName) or (displayName and c:FindFirstChild(displayName))
            if found and found:IsA("Model") then return found end
        end
    end
    local direct = Workspace:FindFirstChild(playerName) or (displayName and Workspace:FindFirstChild(displayName))
    if direct and direct:IsA("Model") then return direct end
    return nil
end

local function GetCharParts(player)
    local char = GetCharacter(player)
    if not char then return nil end
    local cached = CharCache[player]
    if cached and cached.Character == char and cached.HumanoidRootPart and cached.HumanoidRootPart.Parent == char then
        return cached
    end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
        or char:FindFirstChild("UpperTorso") or char:FindFirstChild("LowerTorso") or char.PrimaryPart
    if not hrp then
        for _, c in ipairs(char:GetChildren()) do
            if c:IsA("BasePart") then hrp = c break end
        end
    end
    local head = char:FindFirstChild("Head")
    if not head then
        for _, c in ipairs(char:GetChildren()) do
            if c:IsA("BasePart") and string.find(string.lower(c.Name), "head") then
                head = c break
            end
        end
    end
    head = head or hrp
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("LowerTorso") or hrp
    if hrp and head then
        cached = { Character = char, HumanoidRootPart = hrp, Head = head, Torso = torso, Humanoid = humanoid }
        CharCache[player] = cached
        return cached
    end
    return nil
end

local function GetHealth(parts)
    if not parts then return 0, 100 end
    if parts.Humanoid then return parts.Humanoid.Health, parts.Humanoid.MaxHealth end
    local char = parts.Character
    if char then
        local hpAttr = char:GetAttribute("Health") or char:GetAttribute("HP")
        local maxHpAttr = char:GetAttribute("MaxHealth") or char:GetAttribute("MaxHP") or 100
        if hpAttr and type(hpAttr) == "number" then return hpAttr, maxHpAttr end
    end
    return 100, 100
end

local function IsAlive(player)
    local parts = GetCharParts(player)
    if not parts then return false end
    local hp = GetHealth(parts)
    return hp > 0 and parts.HumanoidRootPart ~= nil
end

local function IsEnemy(player)
    if player == LocalPlayer then return false end
    if not Config.Aimbot.TeamCheck then return true end
    if player.Team ~= nil and LocalPlayer.Team ~= nil then
        return player.Team ~= LocalPlayer.Team
    end
    if player.TeamColor ~= nil and LocalPlayer.TeamColor ~= nil and player.TeamColor.Name ~= "White" then
        return player.TeamColor ~= LocalPlayer.TeamColor
    end
    local pTeamAttr = player:GetAttribute("Team")
    local lTeamAttr = LocalPlayer:GetAttribute("Team")
    if pTeamAttr and lTeamAttr then return pTeamAttr ~= lTeamAttr end
    return true
end

local function ResolveTargetPart(parts, choice)
    if not parts then return nil end
    if choice == "Head" then return parts.Head or parts.HumanoidRootPart
    elseif choice == "HumanoidRootPart" or choice == "Root" then return parts.HumanoidRootPart
    elseif choice == "Torso" or choice == "UpperTorso" then return parts.Torso or parts.HumanoidRootPart
    elseif choice == "Random" then
        local c = {parts.Head, parts.Torso, parts.HumanoidRootPart}
        return c[math.random(1, #c)] or parts.HumanoidRootPart
    end
    return parts.Character:FindFirstChild(choice) or parts.Head or parts.HumanoidRootPart
end

-- ═══════════════════════ INPUT METHODS ═══════════════════════
local getgenv_ = getgenv or function() return _G end
local genv = getgenv_()
local native_mousemoverel = genv.mousemoverel or genv.mousemove_relative or (syn and syn.mousemoverel)
local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)

local function mousemoverel(x, y)
    if typeof(native_mousemoverel) == "function" then native_mousemoverel(x, y)
    elseif VirtualInputManager then
        pcall(function() VirtualInputManager:SendMouseMoveEvent(x, y, Workspace) end)
    end
end

local HasDrawing = typeof(Drawing) == "table" and typeof(Drawing.new) == "function"

-- ═══════════════════════ CONFIG SAVE ═══════════════════════
local ConfigFile = "FableHubRivals_Config.json"
local SavePending = false
local function SaveConfig()
    if writefile then
        pcall(function() writefile(ConfigFile, HttpService:JSONEncode(Config)) end)
    end
end
local function QueueSave()
    if not SavePending then
        SavePending = true
        task.delay(0.5, function() SaveConfig() SavePending = false end)
    end
end
local function LoadConfig()
    if isfile and readfile and isfile(ConfigFile) then
        pcall(function()
            local data = HttpService:JSONDecode(readfile(ConfigFile))
            if data then
                for cat, settings in pairs(data) do
                    if Config[cat] then
                        for k, v in pairs(settings) do Config[cat][k] = v end
                    end
                end
            end
        end)
    end
end
LoadConfig()

-- ═══════════════════════ ПЕРСОНАЖ ИГРОКА ═══════════════════════
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
local ScreenGui = New("ScreenGui", {
    Name = "FableHubRivals",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    Parent = parentGui,
})

local vp = Camera and Camera.ViewportSize or Vector2.new(800, 600)
local W = math.clamp(vp.X * 0.85, 500, 640)
local H = math.clamp(vp.Y * 0.78, 380, 500)

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
    Text = "RIVALS", Font = Enum.Font.GothamBold, TextSize = 15,
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
    if not btnDragActive then Tw(ToggleBtn, 0.15, { Size = UDim2.new(0, 54, 0, 54) }) end
end)
task.spawn(function()
    local glowStroke = ToggleBtn:FindFirstChildOfClass("UIStroke")
    while ToggleBtn.Parent do
        if ToggleBtn.Visible and glowStroke then
            Tw(glowStroke, 1, { Transparency = 0.1 }); task.wait(1)
            Tw(glowStroke, 1, { Transparency = 0.6 }); task.wait(1)
        else task.wait(0.5) end
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
    for cat, t in pairs(Config) do
        if type(t) == "table" then
            for k, v in pairs(t) do
                if k:sub(1, 7) == "Enabled" and v == true then activeCount += 1 end
            end
        end
    end
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
        QueueSave()
    end)
end

local function Slider(parent, iconName, text, min, max, def, cb)
    local f = New("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = CFG.BgPanel,
        BackgroundTransparency = 0.15, BorderSizePixel = 0, Parent = parent,
    })
    Corner(f, UDim.new(0, 12))
    Stroke(f, CFG.Accent1, 1, 0.75)
    local iconBg = New("Frame", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 8, 0, 6),
        BackgroundColor3 = CFG.Accent1,
        BackgroundTransparency = 0.82, BorderSizePixel = 0, Parent = f,
    })
    Corner(iconBg, UDim.new(0, 8))
    MakeIcon(iconBg, iconName, 14, CFG.Accent2)
    New("TextLabel", {
        Text = text, Font = Enum.Font.GothamMedium, TextSize = 12,
        TextColor3 = CFG.Text, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 0, 28),
        Position = UDim2.new(0, 44, 0, 6), Parent = f,
    })
    local valLabel = New("TextLabel", {
        Text = tostring(def), Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = CFG.Accent2, TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundTransparency = 1, Size = UDim2.new(0.3, 0, 0, 28),
        Position = UDim2.new(0.7, -8, 0, 6), Parent = f,
    })
    local barBg = New("TextButton", {
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 1, -12),
        BackgroundColor3 = Color3.fromRGB(40, 40, 60),
        Text = "", AutoButtonColor = false,
        BorderSizePixel = 0, Parent = f,
    })
    Corner(barBg, UDim.new(1, 0))
    local fill = New("Frame", {
        Size = UDim2.new(math.clamp((def - min) / (max - min), 0, 1), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0, Parent = barBg,
    })
    Corner(fill, UDim.new(1, 0))
    Gradient(fill)
    local sliding = false
    local function upd(input)
        local pos = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        valLabel.Text = tostring(val)
        if cb then pcall(cb, val) end
        QueueSave()
    end
    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true; upd(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            upd(input)
        end
    end)
end

local function Dropdown(parent, iconName, text, options, def, cb)
    local f = New("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = CFG.BgPanel,
        BackgroundTransparency = 0.15, BorderSizePixel = 0, Parent = parent,
    })
    Corner(f, UDim.new(0, 12))
    Stroke(f, CFG.Accent1, 1, 0.75)
    local iconBg = New("Frame", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 8, 0.5, -14),
        BackgroundColor3 = CFG.Accent1,
        BackgroundTransparency = 0.82, BorderSizePixel = 0, Parent = f,
    })
    Corner(iconBg, UDim.new(0, 8))
    MakeIcon(iconBg, iconName, 14, CFG.Accent2)
    New("TextLabel", {
        Text = text, Font = Enum.Font.GothamMedium, TextSize = 12,
        TextColor3 = CFG.Text, TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 44, 0, 0), Parent = f,
    })
    local btn = New("TextButton", {
        Size = UDim2.new(0, 130, 0, 26),
        Position = UDim2.new(1, -142, 0.5, -13),
        BackgroundColor3 = CFG.BgHover,
        Text = tostring(def), Font = Enum.Font.GothamBold,
        TextColor3 = CFG.Text, TextSize = 11,
        AutoButtonColor = false, BorderSizePixel = 0, Parent = f,
    })
    Corner(btn, UDim.new(0, 8))
    local idx = 1
    for i, v in ipairs(options) do if v == def then idx = i break end end
    btn.MouseButton1Click:Connect(function()
        idx = (idx % #options) + 1
        local sel = options[idx]
        btn.Text = tostring(sel)
        if cb then pcall(cb, sel) end
        QueueSave()
    end)
end

local Tabs = {}
local function MakeTab(name, iconName)
    local b = New("TextButton", {
        Name = name, Text = "", Font = Enum.Font.GothamMedium, TextSize = 12,
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

local CombatTab   = MakeTab("Combat", "target")
local VisualTab   = MakeTab("2D ESP", "eye")
local ChamsTab    = MakeTab("Chams", "sparkle")
local MovementTab = MakeTab("Movement", "jump")
local WorldTab    = MakeTab("World", "world")
local SettingsTab = MakeTab("Settings", "sliders")

Tabs["Combat"].Btn.BackgroundTransparency = 0.15
Tabs["Combat"].Ind.Size = UDim2.new(0, 3, 0, 18)
Tabs["Combat"].Stroke.Transparency = 0.5
Tabs["Combat"].Page.Visible = true

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
    Text = "FABLE HUB © 2026  •  " .. string.sub(PlaceName, 1, 20),
    Font = Enum.Font.Code, TextSize = 9,
    TextColor3 = CFG.TextSub, TextTransparency = 0.4,
    TextXAlignment = Enum.TextXAlignment.Right,
    BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0),
    Position = UDim2.new(0.5, 0, 0, 0), Parent = StatusBar, ZIndex = 4,
})

-- ═══════════════════════ FOV CIRCLES ═══════════════════════
local FOVCircle, SilentAimFOVCircle
if HasDrawing then
    pcall(function()
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 1.5
        FOVCircle.NumSides = 64
        FOVCircle.Filled = false
        FOVCircle.Transparency = 0.8
        FOVCircle.Color = TableToColor(Config.Aimbot.FOVColor)
    end)
    pcall(function()
        SilentAimFOVCircle = Drawing.new("Circle")
        SilentAimFOVCircle.Thickness = 1.5
        SilentAimFOVCircle.NumSides = 64
        SilentAimFOVCircle.Filled = false
        SilentAimFOVCircle.Transparency = 0.8
        SilentAimFOVCircle.Color = TableToColor(Config.Aimbot.SilentAimFOVColor)
    end)
end

-- ═══════════════════════ TARGET ACQUISITION ═══════════════════════
local function IsVisible(part)
    if not Config.Aimbot.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local lc = GetCharacter(LocalPlayer)
    rp.FilterDescendantsInstances = lc and {lc, Camera} or {Camera}
    local res = Workspace:Raycast(origin, direction, rp)
    if res and res.Instance then return res.Instance:IsDescendantOf(part.Parent) end
    return true
end

local LastTargetUpdate, CachedTarget, CachedFOV = 0, nil, nil

local function GetClosestTargetRaw(customFOV)
    local closest = nil
    local shortest = customFOV or Config.Aimbot.FOV
    local mousePos = UserInputService:GetMouseLocation()
    for _, p in ipairs(Players:GetPlayers()) do
        local allowed = not Config.Aimbot.TeamCheck or IsEnemy(p)
        if p ~= LocalPlayer and IsAlive(p) and allowed then
            local parts = GetCharParts(p)
            if parts then
                local tp = ResolveTargetPart(parts, Config.Aimbot.TargetPart)
                if tp then
                    local sp, onScreen = Camera:WorldToViewportPoint(tp.Position)
                    if onScreen then
                        local mag = (parts.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
                        if mag <= Config.Aimbot.MaxDistance then
                            local v = Vector2.new(sp.X, sp.Y)
                            local d = (v - mousePos).Magnitude
                            if d < shortest and IsVisible(tp) then
                                shortest = d
                                closest = p
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function GetClosestTarget(customFOV)
    local now = os.clock()
    local fovLimit = customFOV or Config.Aimbot.FOV
    if now - LastTargetUpdate < 0.015 and CachedFOV == fovLimit then return CachedTarget end
    LastTargetUpdate = now
    CachedFOV = fovLimit
    CachedTarget = GetClosestTargetRaw(fovLimit)
    return CachedTarget
end

-- ═══════════════════════ SILENT AIM HOOK ═══════════════════════
local Mouse = LocalPlayer:GetMouse()
local Hooked, HookRunning = false, false

local function HookSilentAim()
    if Hooked then return end
    local newcclosure = newcclosure or function(f) return f end
    local checkcaller = checkcaller or function() return false end

    local function GetSATarget()
        if not Config.Aimbot.Enabled or not Config.Aimbot.SilentAim then return nil end
        return GetClosestTarget(Config.Aimbot.SilentAimFOV)
    end
    local function ShouldRedirect()
        local hc = Config.Aimbot.SilentAimHitChance or 100
        if hc == 100 then return true end
        return math.random(1, 100) <= hc
    end

    if hookmetamethod then
        pcall(function()
            local old_index
            old_index = hookmetamethod(game, "__index", newcclosure(function(self, index)
                if HookRunning then return old_index(self, index) end
                if not checkcaller() and Config.Aimbot.Enabled and Config.Aimbot.SilentAim then
                    if self == Mouse and (index == "Hit" or index == "Target") then
                        HookRunning = true
                        local rr = nil
                        pcall(function()
                            if ShouldRedirect() then
                                local tgt = GetSATarget()
                                local parts = tgt and GetCharParts(tgt)
                                if parts then
                                    local tp = ResolveTargetPart(parts, Config.Aimbot.TargetPart)
                                    if tp then
                                        if index == "Hit" then rr = tp.CFrame
                                        else rr = tp end
                                    end
                                end
                            end
                        end)
                        HookRunning = false
                        if rr then return rr end
                    end
                end
                return old_index(self, index)
            end))
        end)
        pcall(function()
            local old_namecall
            old_namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                if HookRunning then return old_namecall(self, ...) end
                local method = getnamecallmethod()
                local args = {...}
                if not checkcaller() and Config.Aimbot.Enabled and Config.Aimbot.SilentAim then
                    if tostring(method) == "Raycast" and self == Workspace then
                        HookRunning = true
                        pcall(function()
                            if ShouldRedirect() then
                                local tgt = GetSATarget()
                                local parts = tgt and GetCharParts(tgt)
                                if parts then
                                    local tp = ResolveTargetPart(parts, Config.Aimbot.TargetPart)
                                    if tp then
                                        local origin = args[1]
                                        local dir = args[2]
                                        args[2] = (tp.Position - origin).Unit * dir.Magnitude
                                    end
                                end
                            end
                        end)
                        HookRunning = false
                        return old_namecall(self, unpack(args))
                    end
                end
                return old_namecall(self, ...)
            end))
        end)
        Hooked = true
    elseif getrawmetatable then
        pcall(function()
            local mt = getrawmetatable(game)
            local old_index = mt.__index
            local old_namecall = mt.__namecall
            setreadonly(mt, false)
            mt.__index = newcclosure(function(self, index)
                if HookRunning then return old_index(self, index) end
                if not checkcaller() and Config.Aimbot.Enabled and Config.Aimbot.SilentAim then
                    if self == Mouse and (index == "Hit" or index == "Target") then
                        HookRunning = true
                        local rr = nil
                        pcall(function()
                            if ShouldRedirect() then
                                local tgt = GetSATarget()
                                local parts = tgt and GetCharParts(tgt)
                                if parts then
                                    local tp = ResolveTargetPart(parts, Config.Aimbot.TargetPart)
                                    if tp then
                                        if index == "Hit" then rr = tp.CFrame else rr = tp end
                                    end
                                end
                            end
                        end)
                        HookRunning = false
                        if rr then return rr end
                    end
                end
                return old_index(self, index)
            end)
            mt.__namecall = newcclosure(function(self, ...)
                if HookRunning then return old_namecall(self, ...) end
                local method = getnamecallmethod()
                local args = {...}
                if not checkcaller() and Config.Aimbot.Enabled and Config.Aimbot.SilentAim then
                    if tostring(method) == "Raycast" and self == Workspace then
                        HookRunning = true
                        pcall(function()
                            if ShouldRedirect() then
                                local tgt = GetSATarget()
                                local parts = tgt and GetCharParts(tgt)
                                if parts then
                                    local tp = ResolveTargetPart(parts, Config.Aimbot.TargetPart)
                                    if tp then
                                        local origin = args[1]
                                        local dir = args[2]
                                        args[2] = (tp.Position - origin).Unit * dir.Magnitude
                                    end
                                end
                            end
                        end)
                        HookRunning = false
                        return old_namecall(self, unpack(args))
                    end
                end
                return old_namecall(self, ...)
            end)
            setreadonly(mt, true)
            Hooked = true
        end)
    end
end
pcall(HookSilentAim)

-- ═══════════════════════ AIM KEYBIND ═══════════════════════
local AimingActive = false
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local k = Config.Aimbot.Keybind
    if (input.UserInputType == Enum.UserInputType.MouseButton2 and k == "MouseButton2") or input.KeyCode.Name == k then
        AimingActive = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    local k = Config.Aimbot.Keybind
    if (input.UserInputType == Enum.UserInputType.MouseButton2 and k == "MouseButton2") or input.KeyCode.Name == k then
        AimingActive = false
    end
end)
local function IsAimActive()
    local k = Config.Aimbot.Keybind
    if k == "MouseButton2" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or AimingActive
    elseif k == "E" then return UserInputService:IsKeyDown(Enum.KeyCode.E) or AimingActive
    elseif k == "Q" then return UserInputService:IsKeyDown(Enum.KeyCode.Q) or AimingActive
    elseif k == "LeftAlt" then return UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or AimingActive end
    return AimingActive
end

local function UniversalAimAt(targetPart, smoothness)
    if not targetPart then return end
    local sp, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    if onScreen then
        local mp = UserInputService:GetMouseLocation()
        local dx = (sp.X - mp.X) / math.max(1, smoothness)
        local dy = (sp.Y - mp.Y) / math.max(1, smoothness)
        if typeof(native_mousemoverel) == "function" or VirtualInputManager then
            mousemoverel(dx, dy)
        else
            local cf = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
            Camera.CFrame = Camera.CFrame:Lerp(cf, 1 / math.max(1, smoothness))
        end
    end
end

-- ═══════════════════════ ESP 2D DRAWING ═══════════════════════
local ESPObjects = {}
local function CreatePlayerESP(player)
    if ESPObjects[player] or not HasDrawing then return end
    local o = {
        BoxOutline = Drawing.new("Square"),
        Box = Drawing.new("Square"),
        HealthBarBG = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        HeadDot = Drawing.new("Circle"),
    }
    pcall(function()
        o.BoxOutline.Thickness = 3
        o.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
        o.BoxOutline.Filled = false
        o.BoxOutline.Visible = false
        o.Box.Thickness = 1
        o.Box.Filled = false
        o.Box.Visible = false
        o.HealthBarBG.Thickness = 1
        o.HealthBarBG.Color = Color3.fromRGB(0, 0, 0)
        o.HealthBarBG.Filled = true
        o.HealthBarBG.Visible = false
        o.HealthBar.Thickness = 1
        o.HealthBar.Filled = true        o.HealthBar.Visible = false
        o.Name.Size = 14
        o.Name.Center = true
        o.Name.Outline = true
        o.Name.Color = Color3.fromRGB(255, 255, 255)
        o.Name.Visible = false
        o.Distance.Size = 12
        o.Distance.Center = true
        o.Distance.Outline = true
        o.Distance.Color = Color3.fromRGB(200, 200, 200)
        o.Distance.Visible = false
        o.Tracer.Thickness = 1.5
        o.Tracer.Visible = false
        o.HeadDot.Radius = 4
        o.HeadDot.Filled = true
        o.HeadDot.Color = Color3.fromRGB(255, 255, 255)
        o.HeadDot.Visible = false
    end)
    ESPObjects[player] = o
end

local function RemovePlayerESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if obj and typeof(obj.Remove) == "function" then pcall(function() obj:Remove() end) end
        end
        ESPObjects[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreatePlayerESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then CreatePlayerESP(p) end end)
Players.PlayerRemoving:Connect(function(p) RemovePlayerESP(p) CharCache[p] = nil end)

-- ═══════════════════════ CHAMS ═══════════════════════
local ChamsFolder = New("Folder", { Name = "FableHubChams" })
pcall(function() ChamsFolder.Parent = CoreGui end)
if not ChamsFolder.Parent then ChamsFolder.Parent = Workspace end

local HighlightStorage = {}
local function ApplyChamsForPlayer(player)
    if player == LocalPlayer then return end
    pcall(function()
        local hostile = IsEnemy(player)
        local allowed = not Config.Chams.TeamCheck or hostile
        local char = GetCharacter(player)
        local parts = GetCharParts(player)
        local hp = GetHealth(parts)
        local show = Config.Chams.Enabled and allowed and char and hp > 0
        local hl = HighlightStorage[player]
        if show then
            if not hl or hl.Parent == nil then
                hl = Instance.new("Highlight")
                hl.Name = "Chams_" .. player.Name
                hl.Parent = ChamsFolder
                HighlightStorage[player] = hl
            end
            hl.Adornee = char
            hl.FillColor = hostile and TableToColor(Config.Chams.FillColor) or TableToColor(Config.ESP.TeamColor)
            hl.OutlineColor = TableToColor(Config.Chams.OutlineColor)
            hl.FillTransparency = Config.Chams.FillTransparency
            hl.OutlineTransparency = Config.Chams.OutlineTransparency
            hl.DepthMode = Config.Chams.AlwaysOnTop and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
            hl.Enabled = true
        else
            if hl then hl.Enabled = false end
        end
    end)
end
local function RefreshAllChams()
    for _, p in ipairs(Players:GetPlayers()) do ApplyChamsForPlayer(p) end
end
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function() task.wait(0.2) ApplyChamsForPlayer(p) end)
    end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.2) ApplyChamsForPlayer(p) end)
end)
task.spawn(function()
    while true do task.wait(1) pcall(RefreshAllChams) end
end)

-- ═══════════════════════ SKYBOX PRESETS ═══════════════════════
local SkyAssetIdMap = {
    ["Purple Galaxy"] = "159454299",
    ["Blood Red"] = "405416706",
    ["Sky 4607457995"] = "4607457995",
    ["Sky 10256505900"] = "10256505900",
    ["Sky 90988519"] = "90988519",
    ["Sky 15983996673"] = "15983996673",
    ["Sky 138907351102721"] = "138907351102721",
    ["Sky 8202961731"] = "8202961731",
}
local LoadedSkyCache = {}
local function FetchSkyTextures(presetName)
    if LoadedSkyCache[presetName] then return LoadedSkyCache[presetName] end
    local assetId = SkyAssetIdMap[presetName] or presetName
    local tex = nil
    pcall(function()
        local objs = game:GetObjects("rbxassetid://" .. tostring(assetId))
        if objs and #objs > 0 then
            local main = objs[1]
            local s = main:IsA("Sky") and main or main:FindFirstChildOfClass("Sky")
            if s then
                tex = { Bk = s.SkyboxBk, Dn = s.SkyboxDn, Ft = s.SkyboxFt, Lf = s.SkyboxLf, Rt = s.SkyboxRt, Up = s.SkyboxUp }
            end
        end
    end)
    if not tex then
        local raw = "rbxassetid://" .. tostring(assetId)
        tex = { Bk = raw, Dn = raw, Ft = raw, Lf = raw, Rt = raw, Up = raw }
    end
    LoadedSkyCache[presetName] = tex
    return tex
end

local originalSkyProperties, originalAtmosphereDensities = nil, {}
local function ApplyCustomSkybox()
    pcall(function()
        local activeSky = Lighting:FindFirstChildOfClass("Sky")
        if Config.World.EnableSky then
            if not activeSky then
                activeSky = Instance.new("Sky")
                activeSky.Name = "FHCustomSky"
                activeSky.CelestialBodiesShown = true
                activeSky.Parent = Lighting
            end
            if not originalSkyProperties then
                originalSkyProperties = {
                    Bk = activeSky.SkyboxBk, Dn = activeSky.SkyboxDn, Ft = activeSky.SkyboxFt,
                    Lf = activeSky.SkyboxLf, Rt = activeSky.SkyboxRt, Up = activeSky.SkyboxUp,
                    Sun = activeSky.SunTextureId, Moon = activeSky.MoonTextureId,
                }
            end
            for _, atm in ipairs(Lighting:GetChildren()) do
                if atm:IsA("Atmosphere") then
                    if originalAtmosphereDensities[atm] == nil then originalAtmosphereDensities[atm] = atm.Density end
                    atm.Density = 0
                end
            end
            local tex = FetchSkyTextures(Config.World.SkyPreset)
            if tex and activeSky then
                activeSky.SkyboxBk = tex.Bk; activeSky.SkyboxDn = tex.Dn
                activeSky.SkyboxFt = tex.Ft; activeSky.SkyboxLf = tex.Lf
                activeSky.SkyboxRt = tex.Rt; activeSky.SkyboxUp = tex.Up
            end
        else
            if activeSky and originalSkyProperties then
                activeSky.SkyboxBk = originalSkyProperties.Bk; activeSky.SkyboxDn = originalSkyProperties.Dn
                activeSky.SkyboxFt = originalSkyProperties.Ft; activeSky.SkyboxLf = originalSkyProperties.Lf
                activeSky.SkyboxRt = originalSkyProperties.Rt; activeSky.SkyboxUp = originalSkyProperties.Up
                activeSky.SunTextureId = originalSkyProperties.Sun
                activeSky.MoonTextureId = originalSkyProperties.Moon
            end
            for atm, d in pairs(originalAtmosphereDensities) do
                if atm and atm.Parent then atm.Density = d end
            end
            table.clear(originalAtmosphereDensities)
        end
    end)
end

local glassEffect, bloomEffect
local function UpdateWorldVisuals()
    pcall(function()
        if Config.World.EnableCameraFOV and Camera then Camera.FieldOfView = Config.World.CameraFOV end
        if Config.World.EnableFullbright then
            Lighting.Brightness = 3
            Lighting.Ambient = Color3.fromRGB(200, 200, 200)
            Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
            Lighting.ClockTime = 14
        end
        if Config.World.EnableGlass then
            if not glassEffect or glassEffect.Parent == nil then
                glassEffect = Lighting:FindFirstChild("FHGlassEffect") or Instance.new("ColorCorrectionEffect")
                glassEffect.Name = "FHGlassEffect"
                glassEffect.Parent = Lighting
            end
            if not bloomEffect or bloomEffect.Parent == nil then
                bloomEffect = Lighting:FindFirstChild("FHBloomEffect") or Instance.new("BloomEffect")
                bloomEffect.Name = "FHBloomEffect"
                bloomEffect.Parent = Lighting
            end
            if Config.World.GlassStyle == "Glossy Glass" then
                glassEffect.Contrast = 0.18; glassEffect.Saturation = 0.35; glassEffect.Brightness = 0.03
                bloomEffect.Intensity = 0.45; bloomEffect.Size = 24; bloomEffect.Threshold = 0.8
            elseif Config.World.GlassStyle == "Vibrant RTX" then
                glassEffect.Contrast = 0.25; glassEffect.Saturation = 0.55; glassEffect.Brightness = 0.02
                bloomEffect.Intensity = 0.65; bloomEffect.Size = 32; bloomEffect.Threshold = 0.65
            elseif Config.World.GlassStyle == "Cyber Neon" then
                glassEffect.Contrast = 0.35; glassEffect.Saturation = 0.7; glassEffect.Brightness = 0.06
                bloomEffect.Intensity = 0.85; bloomEffect.Size = 36; bloomEffect.Threshold = 0.5
            end
        else
            if glassEffect then glassEffect:Destroy() glassEffect = nil end
            if bloomEffect then bloomEffect:Destroy() bloomEffect = nil end
        end
    end)
end

-- ═══════════════════════ MOVEMENT ═══════════════════════
local function PerformForwardBoost()
    if not Config.Movement.EnableBoost then return end
    pcall(function()
        local char = GetCharacter(LocalPlayer)
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hrp and hum and hum.Health > 0 then
            hrp.AssemblyLinearVelocity = Camera.CFrame.LookVector * Config.Movement.BoostPower
        end
    end)
end
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode.Name == Config.Movement.BoostKey then PerformForwardBoost() end
end)

RunService.Stepped:Connect(function()
    if Config.Movement.EnableNoclip then
        pcall(function()
            local char = GetCharacter(LocalPlayer)
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end)
    end
end)

RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = GetCharacter(LocalPlayer)
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if Config.Movement.EnableSpeed then hum.WalkSpeed = Config.Movement.WalkSpeed end
                if Config.Movement.EnableJump then
                    if hum.UseJumpPower then hum.JumpPower = Config.Movement.JumpPower
                    else hum.JumpHeight = Config.Movement.JumpPower / 7 end
                end
            end
        end
    end)
end)

UserInputService.JumpRequest:Connect(function()
    if Config.Movement.EnableInfiniteJump then
        pcall(function()
            local char = GetCharacter(LocalPlayer)
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if Config.Movement.EnableAutoStrafe and humanoid and rootPart then
            local m = humanoid.MoveDirection
            if m.Magnitude > 0 then
                local v = rootPart.AssemblyLinearVelocity
                rootPart.AssemblyLinearVelocity = Vector3.new(
                    m.X * math.max(Config.Movement.WalkSpeed, 20),
                    v.Y,
                    m.Z * math.max(Config.Movement.WalkSpeed, 20)
                )
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(60)
        if Config.Movement.EnableAntiAfk then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- ═══════════════════════ COMBAT TAB ═══════════════════════
Section(CombatTab, "Aimbot")
Toggle(CombatTab, "target", "Aimbot (Camera + Mouse)", Config.Aimbot.Enabled, function(v)
    Config.Aimbot.Enabled = v
    Notify("Aimbot", v and "Включен" or "Выключен", 1.5, v and "success" or nil)
end)
Toggle(CombatTab, "box", "Show FOV Circle", Config.Aimbot.ShowFOV, function(v) Config.Aimbot.ShowFOV = v end)
Slider(CombatTab, "target", "FOV Radius", 30, 400, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end)
Slider(CombatTab, "sliders", "Smoothness", 1, 20, Config.Aimbot.Smoothness, function(v) Config.Aimbot.Smoothness = v end)
Dropdown(CombatTab, "target", "Target Bone", {"Head", "Torso", "HumanoidRootPart", "Random"}, Config.Aimbot.TargetPart, function(v) Config.Aimbot.TargetPart = v end)
Dropdown(CombatTab, "sliders", "Aim Keybind", {"MouseButton2", "Q", "E", "LeftAlt"}, Config.Aimbot.Keybind, function(v) Config.Aimbot.Keybind = v end)
Toggle(CombatTab, "person", "Team Check", Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end)
Toggle(CombatTab, "eye", "Wall Check (Raycast)", Config.Aimbot.WallCheck, function(v) Config.Aimbot.WallCheck = v end)
Slider(CombatTab, "sliders", "Max Distance", 100, 2000, Config.Aimbot.MaxDistance, function(v) Config.Aimbot.MaxDistance = v end)

Section(CombatTab, "Silent Aim")
Toggle(CombatTab, "target", "Enable Silent Aim", Config.Aimbot.SilentAim, function(v)
    Config.Aimbot.SilentAim = v
    Notify("Silent Aim", v and "Включен" or "Выключен", 1.5, v and "success" or nil)
end)
Toggle(CombatTab, "box", "Show Silent Aim FOV", Config.Aimbot.ShowSilentAimFOV, function(v) Config.Aimbot.ShowSilentAimFOV = v end)
Slider(CombatTab, "target", "Silent Aim FOV", 30, 400, Config.Aimbot.SilentAimFOV, function(v) Config.Aimbot.SilentAimFOV = v end)
Slider(CombatTab, "sliders", "Hit Chance (%)", 10, 100, Config.Aimbot.SilentAimHitChance, function(v) Config.Aimbot.SilentAimHitChance = v end)

-- ═══════════════════════ 2D ESP TAB ═══════════════════════
Section(VisualTab, "ESP 2D")
Toggle(VisualTab, "eye", "Enable 2D ESP", Config.ESP.Enabled, function(v)
    Config.ESP.Enabled = v
    Notify("2D ESP", v and "Включен" or "Выключен", 1.5, v and "success" or nil)
end)
Toggle(VisualTab, "box", "Bounding Boxes", Config.ESP.Boxes, function(v) Config.ESP.Boxes = v end)
Toggle(VisualTab, "coin", "Health Bars", Config.ESP.HealthBar, function(v) Config.ESP.HealthBar = v end)
Toggle(VisualTab, "person", "Player Names", Config.ESP.Names, function(v) Config.ESP.Names = v end)
Toggle(VisualTab, "target", "Distance", Config.ESP.Distance, function(v) Config.ESP.Distance = v end)
Toggle(VisualTab, "sliders", "Tracers", Config.ESP.Tracers, function(v) Config.ESP.Tracers = v end)
Toggle(VisualTab, "coin", "Head Dots", Config.ESP.HeadDot, function(v) Config.ESP.HeadDot = v end)
Toggle(VisualTab, "person", "Team Check", Config.ESP.TeamCheck, function(v) Config.ESP.TeamCheck = v end)
Slider(VisualTab, "sliders", "Max Distance", 100, 3000, Config.ESP.MaxDistance, function(v) Config.ESP.MaxDistance = v end)

-- ═══════════════════════ CHAMS TAB ═══════════════════════
Section(ChamsTab, "Chams ESP")
Toggle(ChamsTab, "sparkle", "Enable Wall Chams", Config.Chams.Enabled, function(v)
    Config.Chams.Enabled = v
    RefreshAllChams()
    Notify("Chams", v and "Включен" or "Выключен", 1.5, v and "success" or nil)
end)
Toggle(ChamsTab, "eye", "See Through Walls", Config.Chams.AlwaysOnTop, function(v)
    Config.Chams.AlwaysOnTop = v
    RefreshAllChams()
end)
Toggle(ChamsTab, "person", "Team Check", Config.Chams.TeamCheck, function(v)
    Config.Chams.TeamCheck = v
    RefreshAllChams()
end)
Slider(ChamsTab, "sliders", "Fill Transparency %", 0, 10, math.floor(Config.Chams.FillTransparency * 10), function(v)
    Config.Chams.FillTransparency = v / 10
    RefreshAllChams()
end)

-- ═══════════════════════ MOVEMENT TAB ═══════════════════════
Section(MovementTab, "Speed & Jump")
Toggle(MovementTab, "jump", "Speed Boost", Config.Movement.EnableSpeed, function(v)
    Config.Movement.EnableSpeed = v
    Notify("Speed", v and "Включен" or "Выключен", 1.5, v and "success" or nil)
end)
Slider(MovementTab, "sliders", "WalkSpeed", 16, 250, Config.Movement.WalkSpeed, function(v) Config.Movement.WalkSpeed = v end)
Toggle(MovementTab, "jump", "Jump Boost", Config.Movement.EnableJump, function(v)
    Config.Movement.EnableJump = v
    Notify("Jump", v and "Включен" or "Выключен", 1.5, v and "success" or nil)
end)
Slider(MovementTab, "sliders", "JumpPower", 50, 350, Config.Movement.JumpPower, function(v) Config.Movement.JumpPower = v end)
Toggle(MovementTab, "jump", "Infinite Jump", Config.Movement.EnableInfiniteJump, function(v) Config.Movement.EnableInfiniteJump = v end)
Toggle(MovementTab, "ghost", "Noclip", Config.Movement.EnableNoclip, function(v) Config.Movement.EnableNoclip = v end)

Section(MovementTab, "Extra")
Toggle(MovementTab, "gun", "Forward Dash Boost", Config.Movement.EnableBoost, function(v) Config.Movement.EnableBoost = v end)
Slider(MovementTab, "sliders", "Boost Power", 20, 250, Config.Movement.BoostPower, function(v) Config.Movement.BoostPower = v end)
Dropdown(MovementTab, "sliders", "Boost Keybind", {"E", "Q", "F", "V", "LeftShift"}, Config.Movement.BoostKey, function(v) Config.Movement.BoostKey = v end)
Toggle(MovementTab, "ghost", "Auto Strafe (Bhop)", Config.Movement.EnableAutoStrafe, function(v) Config.Movement.EnableAutoStrafe = v end)
Toggle(MovementTab, "clock", "Anti-AFK", Config.Movement.EnableAntiAfk, function(v) Config.Movement.EnableAntiAfk = v end)

-- ═══════════════════════ WORLD TAB ═══════════════════════
Section(WorldTab, "Camera")
Toggle(WorldTab, "sun", "Custom Camera FOV", Config.World.EnableCameraFOV, function(v) Config.World.EnableCameraFOV = v end)
Slider(WorldTab, "sliders", "Camera FOV", 70, 120, Config.World.CameraFOV, function(v) Config.World.CameraFOV = v end)
Toggle(WorldTab, "sun", "Fullbright", Config.World.EnableFullbright, function(v) Config.World.EnableFullbright = v end)

Section(WorldTab, "Skybox")
Toggle(WorldTab, "world", "Enable Custom Sky", Config.World.EnableSky, function(v)
    Config.World.EnableSky = v
    ApplyCustomSkybox()
end)
Dropdown(WorldTab, "world", "Sky Preset",
    {"Purple Galaxy", "Blood Red", "Sky 4607457995", "Sky 10256505900", "Sky 90988519", "Sky 15983996673", "Sky 138907351102721", "Sky 8202961731"},
    Config.World.SkyPreset,
    function(v) Config.World.SkyPreset = v ApplyCustomSkybox() end)

Section(WorldTab, "Shaders")
Toggle(WorldTab, "sparkle", "Enable Glass Shader", Config.World.EnableGlass, function(v) Config.World.EnableGlass = v end)
Dropdown(WorldTab, "sparkle", "Glass Style", {"Glossy Glass", "Vibrant RTX", "Cyber Neon"}, Config.World.GlassStyle, function(v) Config.World.GlassStyle = v end)

-- ═══════════════════════ SETTINGS TAB ═══════════════════════
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
    Text = "RIVALS  •  " .. CFG.Version, Font = Enum.Font.Code, TextSize = 11,
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
    end
end)

Section(SettingsTab, "Управление")
local unloader = New("TextButton", {
    Text = "", BackgroundColor3 = CFG.BgPanel,
    BackgroundTransparency = 0.2, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 40), AutoButtonColor = false, Parent = SettingsTab,
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
    Config.Aimbot.Enabled = false
    Config.ESP.Enabled = false
    Config.Chams.Enabled = false
    for p, _ in pairs(ESPObjects) do RemovePlayerESP(p) end
    if FOVCircle then pcall(function() FOVCircle:Remove() end) end
    if SilentAimFOVCircle then pcall(function() SilentAimFOVCircle:Remove() end) end
    ChamsFolder:Destroy()
    Config.World.EnableSky = false
    ApplyCustomSkybox()
    if glassEffect then glassEffect:Destroy() end
    if bloomEffect then bloomEffect:Destroy() end
    Tw(Main, 0.2, { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0) })
    task.wait(0.2)
    pcall(function() ScreenGui:Destroy() end)
end)

-- ═══════════════════════ MENU OPEN / DRAG ═══════════════════════
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

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightShift then
        if Main.Visible then SetMenuOpen(false) else SetMenuOpen(true) end
    end
end)

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
        btnDrag = true; moved = false
        bStart = i.Position; bPos = ToggleBtn.Position
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
            if math.abs(d.X) > 6 or math.abs(d.Y) > 6 then moved = true; btnDragActive = true end
            ToggleBtn.Position = UDim2.new(bPos.X.Scale, bPos.X.Offset + d.X, bPos.Y.Scale, bPos.Y.Offset + d.Y)
        end
    end
end)

-- ═══════════════════════ MAIN LOOPS ═══════════════════════
RunService.RenderStepped:Connect(function()
    -- FOV circles
    if HasDrawing then
        local mp = UserInputService:GetMouseLocation()
        if FOVCircle then
            FOVCircle.Position = mp
            FOVCircle.Radius = Config.Aimbot.FOV
            FOVCircle.Color = TableToColor(Config.Aimbot.FOVColor)
            FOVCircle.Visible = Config.Aimbot.Enabled and Config.Aimbot.ShowFOV
        end
        if SilentAimFOVCircle then
            SilentAimFOVCircle.Position = mp
            SilentAimFOVCircle.Radius = Config.Aimbot.SilentAimFOV
            SilentAimFOVCircle.Color = TableToColor(Config.Aimbot.SilentAimFOVColor)
            SilentAimFOVCircle.Visible = Config.Aimbot.Enabled and Config.Aimbot.SilentAim and Config.Aimbot.ShowSilentAimFOV
        end
    end

    -- Camera aimbot
    if Config.Aimbot.Enabled and IsAimActive() then
        local tp = GetClosestTarget()
        local parts = tp and GetCharParts(tp)
        if parts then
            local targetPart = ResolveTargetPart(parts, Config.Aimbot.TargetPart)
            if targetPart then UniversalAimAt(targetPart, Config.Aimbot.Smoothness) end
        end
    end

    -- 2D ESP
    if HasDrawing then
        local enemyColor = TableToColor(Config.ESP.EnemyColor)
        local teamColor = TableToColor(Config.ESP.TeamColor)
        local tracerColor = TableToColor(Config.ESP.TracerColor)
        for player, esp in pairs(ESPObjects) do
            local parts = GetCharParts(player)
            local hostile = IsEnemy(player)
            local allowed = not Config.ESP.TeamCheck or hostile
            local hp, maxHp = GetHealth(parts)
            local show = Config.ESP.Enabled and allowed and parts and hp > 0
            if show then
                local hrp, head = parts.HumanoidRootPart, parts.Head
                local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local dist = (hrp.Position - Camera.CFrame.Position).Magnitude
                if onScreen and dist <= Config.ESP.MaxDistance then
                    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height / 1.6
                    local boxPos = Vector2.new(hrpPos.X - width / 2, headPos.Y)
                    local espColor = hostile and enemyColor or teamColor
                    if Config.ESP.Boxes then
                        esp.BoxOutline.Size = Vector2.new(width, height)
                        esp.BoxOutline.Position = boxPos
                        esp.BoxOutline.Visible = true
                        esp.Box.Size = Vector2.new(width, height)
                        esp.Box.Position = boxPos
                        esp.Box.Color = espColor
                        esp.Box.Visible = true
                    else
                        esp.BoxOutline.Visible = false
                        esp.Box.Visible = false
                    end
                    if Config.ESP.HealthBar then
                        local pct = math.clamp(hp / maxHp, 0, 1)
                        local bh = height * pct
                        esp.HealthBarBG.Size = Vector2.new(3, height)
                        esp.HealthBarBG.Position = Vector2.new(boxPos.X - 6, boxPos.Y)
                        esp.HealthBarBG.Visible = true
                        esp.HealthBar.Size = Vector2.new(3, bh)
                        esp.HealthBar.Position = Vector2.new(boxPos.X - 6, boxPos.Y + (height - bh))
                        esp.HealthBar.Color = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), pct)
                        esp.HealthBar.Visible = true
                    else
                        esp.HealthBarBG.Visible = false
                        esp.HealthBar.Visible = false
                    end
                    if Config.ESP.Names then
                        esp.Name.Text = player.DisplayName or player.Name
                        esp.Name.Position = Vector2.new(hrpPos.X, boxPos.Y - 16)
                        esp.Name.Visible = true
                    else esp.Name.Visible = false end
                    if Config.ESP.Distance then
                        esp.Distance.Text = string.format("[%d m]", math.floor(dist))
                        esp.Distance.Position = Vector2.new(hrpPos.X, boxPos.Y + height + 2)
                        esp.Distance.Visible = true
                    else esp.Distance.Visible = false end
                    if Config.ESP.Tracers then
                        local vs = Camera.ViewportSize
                        esp.Tracer.From = Vector2.new(vs.X / 2, vs.Y)
                        esp.Tracer.To = Vector2.new(hrpPos.X, hrpPos.Y)
                        esp.Tracer.Color = tracerColor
                        esp.Tracer.Visible = true
                    else esp.Tracer.Visible = false end
                    if Config.ESP.HeadDot then
                        local hs = Camera:WorldToViewportPoint(head.Position)
                        esp.HeadDot.Position = Vector2.new(hs.X, hs.Y)
                        esp.HeadDot.Color = espColor
                        esp.HeadDot.Visible = true
                    else esp.HeadDot.Visible = false end
                else
                    for _, obj in pairs(esp) do obj.Visible = false end
                end
            else
                for _, obj in pairs(esp) do obj.Visible = false end
            end
        end
    end
end)

RunService.RenderStepped:Connect(UpdateWorldVisuals)

task.spawn(function()
    task.wait(0.5)
    ApplyCustomSkybox()
end)

task.wait(0.3)
SetMenuOpen(true)
task.delay(0.4, function()
    Notify("Fable Hub Rivals", CFG.Version .. " • " .. PlaceName .. " загружен", 3, "success")
end)
print("[FableHub Rivals] " .. CFG.Version .. " loaded for " .. PlaceName)
