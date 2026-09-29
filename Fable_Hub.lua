--[[
    FABLE HUB AUTO-LOADER v1.4 (Key System + Telegram + Auto-Detect)
    - Key-система с кодами FREE / FABLE
    - Кнопка перехода в Telegram-канал
    - Авто-определение игры по PlaceId / GameId
    - БЕЗ экрана выбора игр — только автозагрузка
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local LP = Players.LocalPlayer

-- ═══════════════════════ КОНФИГ ═══════════════════════
local VALID_KEYS = {
    ["FREE"] = true,
    ["FABLE"] = true,
}

local TELEGRAM_URL = "https://t.me/Fable_Hub"
local TELEGRAM_HANDLE = "@Fable_Hub"

-- ═══════════════════════ БАЗА ИГР ═══════════════════════
local GAMES = {
    [142823291] = {
        name = "Murder Mystery 2",
        desc = "Auto Farm, ESP, Silent Aim, Anti-Kick",
        version = "v1.9.3",
        url = "https://raw.githubusercontent.com/Havickzi/Rocket-script/refs/heads/main/FableHub_mm2.lua",
    },
    [286090429] = {
        name = "Arsenal",
        desc = "Aimbot, ESP, Team/Wall Check",
        version = "v1.1.0",
        url = "https://raw.githubusercontent.com/Havickzi/Rocket-script/refs/heads/main/Fable_Hub_arsenal.lua",
    },
    [2753915549] = {
        name = "Blox Fruits",
        desc = "Auto Farm, Auto Raid",
        version = "v1.0.0",
        url = "https://gist.githubusercontent.com/.../fablehub-bloxfruits.lua",
    },
    [606849621] = {
        name = "Jailbreak",
        desc = "Auto Rob, ESP",
        version = "v1.0.0",
        url = "https://gist.githubusercontent.com/.../fablehub-jailbreak.lua",
    },
    [2788229376] = {
        name = "Da Hood",
        desc = "Aimbot, Silent Aim, Cash Farm",
        version = "v1.0.0",
        url = "https://gist.githubusercontent.com/.../fablehub-dahood.lua",
    },
    [3317778282] = {
        name = "Pet Simulator 99",
        desc = "Auto Farm, Auto Hatch",
        version = "v1.0.0",
        url = "https://gist.githubusercontent.com/.../fablehub-ps99.lua",
    },
    [1962086868] = {
        name = "Tower of Hell",
        desc = "Skip Stage, Fly",
        version = "v1.0.0",
        url = "https://gist.githubusercontent.com/.../fablehub-toh.lua",
    },
    -- ═══ DOORS ═══
    [6516141723] = {
        name = "DOORS",
        desc = "ESP, Auto Closet, Bypass, Show Seek Path",
        version = "v1.5.5",
        url = "https://raw.githubusercontent.com/Havickzi/Rocket-script/refs/heads/main/Fable_hub_doors.lua",
    },
    [6839174341] = {
        name = "DOORS (Super Hard Mode)",
        desc = "ESP, Auto Closet, Bypass, Show Seek Path",
        version = "v1.5.5",
        url = "https://raw.githubusercontent.com/Havickzi/Rocket-script/refs/heads/main/Fable_hub_doors.lua",
    },
}

-- ═══════════════════════ ЦВЕТА ═══════════════════════
local CFG = {
    Accent1 = Color3.fromRGB(139, 92, 246),
    Accent2 = Color3.fromRGB(217, 70, 239),
    Accent3 = Color3.fromRGB(99, 102, 241),
    BgDark  = Color3.fromRGB(13, 13, 22),
    BgPanel = Color3.fromRGB(24, 24, 40),
    BgHover = Color3.fromRGB(35, 35, 58),
    Text    = Color3.fromRGB(245, 245, 250),
    TextSub = Color3.fromRGB(150, 150, 185),
    Success = Color3.fromRGB(52, 211, 153),
    Danger  = Color3.fromRGB(248, 113, 113),
}

local function New(cls, props)
    local i = Instance.new(cls)
    for k, v in pairs(props or {}) do i[k] = v end
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

-- ═══════════════════════ ОПРЕДЕЛЕНИЕ ИГРЫ ═══════════════════════
local function DetectGame()
    local placeId = game.PlaceId
    local gameId = game.GameId
    if GAMES[placeId] then return GAMES[placeId], "place" end
    if GAMES[gameId] then return GAMES[gameId], "game" end
    return nil, nil
end

-- ═══════════════════════ ЗАГРУЗКА СКРИПТА ═══════════════════════
local function LoadScript(scriptData)
    print("[FableHub] Загружаю: " .. scriptData.name .. " " .. scriptData.version)
    print("[FableHub] URL: " .. scriptData.url)

    local ok, response = pcall(function()
        return game:HttpGet(scriptData.url)
    end)

    if not ok then
        warn("[FableHub] Не скачал: " .. tostring(response))
        return false, "Не скачал: " .. tostring(response)
    end

    if not response or #response < 50 then
        warn("[FableHub] Пустой ответ, размер: " .. tostring(response and #response or 0))
        return false, "Пустой ответ с сервера"
    end

    print("[FableHub] Скачано байт: " .. #response)

    local fn, loadErr = loadstring(response)
    if not fn then
        warn("[FableHub] Ошибка компиляции: " .. tostring(loadErr))
        return false, "Компиляция: " .. tostring(loadErr)
    end

    local success, runErr = pcall(fn)
    if success then
        print("[FableHub] " .. scriptData.name .. " загружен ✓")
        return true
    else
        warn("[FableHub] Ошибка выполнения: " .. tostring(runErr))
        return false, "Выполнение: " .. tostring(runErr)
    end
end

-- ═══════════════════════ GUI ═══════════════════════
local ScreenGui = New("ScreenGui", {
    Name = "FableHubAutoLoader",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    Parent = LP:WaitForChild("PlayerGui") or CoreGui,
})

local Backdrop = New("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    ZIndex = 1,
    Parent = ScreenGui,
})

local Main = New("Frame", {
    Size = UDim2.new(0, 440, 0, 0),
    Position = UDim2.new(0.5, -220, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = CFG.BgDark,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 2,
    Parent = ScreenGui,
})
Corner(Main, UDim.new(0, 18))
Stroke(Main, CFG.Accent1, 1.5, 0.3)

local Glow = New("Frame", {
    Size = UDim2.new(1, 0, 0, 120),
    BackgroundColor3 = CFG.Accent1,
    BackgroundTransparency = 0.9,
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = Main,
})
Gradient(Glow, CFG.Accent1, CFG.Accent2, 90)

-- ═══════════════════════ KEY SYSTEM ═══════════════════════
local KeyScreen = New("Frame", {
    Size = UDim2.new(1, 0, 0, 340),
    BackgroundTransparency = 1,
    ZIndex = 3,
    Parent = Main,
})

local LogoBadge = New("Frame", {
    Size = UDim2.new(0, 56, 0, 56),
    Position = UDim2.new(0.5, -28, 0, 22),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BorderSizePixel = 0,
    ZIndex = 4,
    Parent = KeyScreen,
})
Corner(LogoBadge, UDim.new(0, 16))
Gradient(LogoBadge)
Stroke(LogoBadge, Color3.fromRGB(255, 255, 255), 1.5, 0.5)

New("TextLabel", {
    Text = "FH",
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    ZIndex = 5,
    Parent = LogoBadge,
})

New("TextLabel", {
    Text = "FABLE HUB",
    Font = Enum.Font.GothamBold,
    TextSize = 24,
    TextColor3 = CFG.Text,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 28),
    Position = UDim2.new(0, 0, 0, 90),
    ZIndex = 4,
    Parent = KeyScreen,
})

New("TextLabel", {
    Text = "Введи ключ для доступа",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = CFG.TextSub,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(0, 0, 0, 120),
    ZIndex = 4,
    Parent = KeyScreen,
})

local KeyInputFrame = New("Frame", {
    Size = UDim2.new(0, 320, 0, 46),
    Position = UDim2.new(0.5, -160, 0, 156),
    BackgroundColor3 = CFG.BgPanel,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    ZIndex = 4,
    Parent = KeyScreen,
})
Corner(KeyInputFrame, UDim.new(0, 12))
local keyStroke = Stroke(KeyInputFrame, CFG.Accent1, 1.2, 0.5)

local KeyInput = New("TextBox", {
    Size = UDim2.new(1, -20, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "",
    PlaceholderText = "Введите ключ...",
    PlaceholderColor3 = CFG.TextSub,
    Font = Enum.Font.GothamMedium,
    TextSize = 14,
    TextColor3 = CFG.Text,
    TextXAlignment = Enum.TextXAlignment.Center,
    ClearTextOnFocus = false,
    ZIndex = 5,
    Parent = KeyInputFrame,
})

local ActivateBtn = New("TextButton", {
    Size = UDim2.new(0, 320, 0, 44),
    Position = UDim2.new(0.5, -160, 0, 214),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BorderSizePixel = 0,
    Text = "АКТИВИРОВАТЬ",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    AutoButtonColor = false,
    ZIndex = 4,
    Parent = KeyScreen,
})
Corner(ActivateBtn, UDim.new(0, 12))
Gradient(ActivateBtn)
local activateStroke = Stroke(ActivateBtn, Color3.fromRGB(255, 255, 255), 1.2, 0.6)

local StatusLbl = New("TextLabel", {
    Size = UDim2.new(1, -40, 0, 18),
    Position = UDim2.new(0, 20, 0, 264),
    BackgroundTransparency = 1,
    Text = "",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = CFG.TextSub,
    ZIndex = 4,
    Parent = KeyScreen,
})

local TgBtn = New("TextButton", {
    Size = UDim2.new(0, 320, 0, 34),
    Position = UDim2.new(0.5, -160, 0, 290),
    BackgroundColor3 = CFG.BgPanel,
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 4,
    Parent = KeyScreen,
})
Corner(TgBtn, UDim.new(0, 10))
local tgStroke = Stroke(TgBtn, CFG.Accent2, 1, 0.55)

local tgIcon = New("Frame", {
    Size = UDim2.new(0, 20, 0, 20),
    Position = UDim2.new(0, 12, 0.5, -10),
    BackgroundTransparency = 1,
    ZIndex = 5,
    Parent = TgBtn,
})
local tgArrow = New("Frame", {
    Size = UDim2.new(0, 12, 0, 12),
    Position = UDim2.new(0.5, -6, 0.5, -6),
    BackgroundTransparency = 1,
    ZIndex = 5,
    Parent = tgIcon,
})
New("Frame", {
    Size = UDim2.new(0, 12, 0, 2),
    Position = UDim2.new(0, 0, 0.5, -1),
    BackgroundColor3 = CFG.Accent2,
    BorderSizePixel = 0,
    Rotation = -30,
    ZIndex = 5,
    Parent = tgArrow,
})
New("Frame", {
    Size = UDim2.new(0, 5, 0, 2),
    Position = UDim2.new(1, -5, 0.5, -6),
    BackgroundColor3 = CFG.Accent2,
    BorderSizePixel = 0,
    Rotation = 45,
    ZIndex = 5,
    Parent = tgArrow,
})
New("Frame", {
    Size = UDim2.new(0, 5, 0, 2),
    Position = UDim2.new(1, -5, 0.5, 1),
    BackgroundColor3 = CFG.Accent2,
    BorderSizePixel = 0,
    Rotation = -45,
    ZIndex = 5,
    Parent = tgArrow,
})

New("TextLabel", {
    Text = "Telegram канал",
    Font = Enum.Font.GothamMedium,
    TextSize = 12,
    TextColor3 = CFG.Accent2,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 150, 1, 0),
    Position = UDim2.new(0, 40, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5,
    Parent = TgBtn,
})
New("TextLabel", {
    Text = TELEGRAM_HANDLE,
    Font = Enum.Font.Code,
    TextSize = 11,
    TextColor3 = CFG.TextSub,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 130, 1, 0),
    Position = UDim2.new(1, -140, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Right,
    ZIndex = 5,
    Parent = TgBtn,
})

-- ═══════════════════════ ЛОГИКА ═══════════════════════
local function ShowGameScreen()
    local detected = DetectGame()
    if detected then
        print("[FableHub] Обнаружена игра: " .. detected.name)
        StatusLbl.Text = "Загружаю " .. detected.name .. "..."
        StatusLbl.TextColor3 = CFG.Accent2

        local ok, err = LoadScript(detected)
        if ok then
            task.wait(0.5)
            pcall(function() ScreenGui:Destroy() end)
        else
            StatusLbl.Text = "⚠ Ошибка: " .. tostring(err)
            StatusLbl.TextColor3 = CFG.Danger
        end
        return
    end

    -- Игра НЕ поддерживается — просто закрываем
    StatusLbl.Text = "⚠ Игра не поддерживается"
    StatusLbl.TextColor3 = CFG.Danger
    task.wait(2)
    pcall(function() ScreenGui:Destroy() end)
end

local function ValidateKey()
    local key = string.upper(string.gsub(KeyInput.Text, "%s", ""))
    if key == "" then
        StatusLbl.Text = "⚠ Введите ключ"
        StatusLbl.TextColor3 = CFG.Danger
        Tw(keyStroke, 0.15, { Color = CFG.Danger, Transparency = 0.1 })
        task.delay(0.5, function() Tw(keyStroke, 0.3, { Color = CFG.Accent1, Transparency = 0.5 }) end)
        return
    end

    if VALID_KEYS[key] then
        StatusLbl.Text = "✓ Ключ верный! Загрузка..."
        StatusLbl.TextColor3 = CFG.Success
        Tw(keyStroke, 0.15, { Color = CFG.Success, Transparency = 0.1 })
        Tw(ActivateBtn, 0.2, { BackgroundColor3 = CFG.Success })
        task.wait(0.4)
        ShowGameScreen()
    else
        StatusLbl.Text = "✗ Неверный ключ. Проверь Telegram-канал"
        StatusLbl.TextColor3 = CFG.Danger
        Tw(keyStroke, 0.15, { Color = CFG.Danger, Transparency = 0.1 })
        task.delay(0.8, function() Tw(keyStroke, 0.3, { Color = CFG.Accent1, Transparency = 0.5 }) end)
    end
end

ActivateBtn.MouseButton1Click:Connect(ValidateKey)
KeyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then ValidateKey() end
end)

ActivateBtn.MouseEnter:Connect(function()
    Tw(ActivateBtn, 0.15, { Size = UDim2.new(0, 326, 0, 46), Position = UDim2.new(0.5, -163, 0, 213) })
end)
ActivateBtn.MouseLeave:Connect(function()
    Tw(ActivateBtn, 0.15, { Size = UDim2.new(0, 320, 0, 44), Position = UDim2.new(0.5, -160, 0, 214) })
end)

TgBtn.MouseEnter:Connect(function()
    Tw(TgBtn, 0.15, { BackgroundColor3 = CFG.Accent2, BackgroundTransparency = 0.15 })
    Tw(tgStroke, 0.15, { Transparency = 0.1 })
    for _, f in ipairs(TgBtn:GetDescendants()) do
        if f:IsA("TextLabel") then
            Tw(f, 0.15, { TextColor3 = Color3.fromRGB(255, 255, 255) })
        elseif f:IsA("Frame") and f ~= tgIcon and f ~= tgArrow then
            Tw(f, 0.15, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
        end
    end
end)
TgBtn.MouseLeave:Connect(function()
    Tw(TgBtn, 0.15, { BackgroundColor3 = CFG.BgPanel, BackgroundTransparency = 0.3 })
    Tw(tgStroke, 0.15, { Transparency = 0.55 })
    for _, f in ipairs(TgBtn:GetDescendants()) do
        if f:IsA("TextLabel") then
            local isSub = f.Text == TELEGRAM_HANDLE
            Tw(f, 0.15, { TextColor3 = isSub and CFG.TextSub or CFG.Accent2 })
        elseif f:IsA("Frame") and f ~= tgIcon and f ~= tgArrow then
            Tw(f, 0.15, { BackgroundColor3 = CFG.Accent2 })
        end
    end
end)
TgBtn.MouseButton1Click:Connect(function()
    local opened = false
    pcall(function()
        GuiService:OpenBrowserWindow(TELEGRAM_URL)
        opened = true
    end)
    if not opened then
        pcall(function()
            if setclipboard then setclipboard(TELEGRAM_URL) end
        end)
        StatusLbl.Text = "Ссылка скопирована: " .. TELEGRAM_HANDLE
        StatusLbl.TextColor3 = CFG.Accent2
    else
        StatusLbl.Text = "Открываю Telegram..."
        StatusLbl.TextColor3 = CFG.Accent2
    end
end)

Main.Size = UDim2.new(0, 0, 0, 0)
Tw(Main, 0.4, { Size = UDim2.new(0, 440, 0, 340) }, Enum.EasingStyle.Back)

task.wait(0.5)
pcall(function() KeyInput:CaptureFocus() end)

print("[FableHub Auto-Loader v1.4] Ожидание ключа...")
