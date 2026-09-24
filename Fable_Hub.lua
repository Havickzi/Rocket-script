--[[
    FABLE HUB AUTO-LOADER v1.0
    Автоматически определяет игру и загружает нужный скрипт
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

-- ═══════════════════════ БАЗА ИГР ═══════════════════════
-- PlaceId — ID конкретной карты (game.PlaceId)
-- GameId — ID всего опыта (game.GameId, одинаковый для всех карт MM2)
local GAMES = {
    -- Murder Mystery 2 (основная карта)
    [142823291] = {
        name = "Murder Mystery 2",
        desc = "Auto Farm, ESP, Silent Aim, Anti-Kick",
        version = "v1.9.3",
        url = "https://raw.githubusercontent.com/Havickzi/Rocket-script/refs/heads/main/FableHub_mm2.lua",
    },
    -- Arsenal
    [286090429] = {
        name = "Arsenal",
        desc = "Aimbot, ESP, Auto-Farm",
        version = "v1.0.0",
        url = "https://gist.githubusercontent.com/.../fablehub-arsenal.lua",
    },
    -- Blox Fruits
    [2753915549] = {
        name = "Blox Fruits",
        desc = "Auto Farm, Auto Raid",
        version = "v1.0.0",
        url = "https://gist.githubusercontent.com/.../fablehub-bloxfruits.lua",
    },
    -- Jailbreak
    [606849621] = {
        name = "Jailbreak",
        desc = "Auto Rob, ESP",
        version = "v1.0.0",
        url = "https://gist.githubusercontent.com/.../fablehub-jailbreak.lua",
    },
    -- Da Hood
    [2788229376] = {
        name = "Da Hood",
        desc = "Aimbot, Silent Aim, Cash Farm",
        version = "v1.0.0",
        url = "https://gist.githubusercontent.com/.../fablehub-dahood.lua",
    },
    -- Pet Simulator 99
    [3317778282] = {
        name = "Pet Simulator 99",
        desc = "Auto Farm, Auto Hatch",
        version = "v1.0.0",
        url = "https://gist.githubusercontent.com/.../fablehub-ps99.lua",
    },
    -- Tower of Hell
    [1962086868] = {
        name = "Tower of Hell",
        desc = "Skip Stage, Fly",
        version = "v1.0.0",
        url = "https://gist.githubusercontent.com/.../fablehub-toh.lua",
    },
}

-- ═══════════════════════ ОПРЕДЕЛЕНИЕ ИГРЫ ═══════════════════════
local function DetectGame()
    local placeId = game.PlaceId
    local gameId = game.GameId

    -- 1. Проверка по PlaceId (точное совпадение)
    if GAMES[placeId] then
        return GAMES[placeId], "place"
    end

    -- 2. Проверка по GameId (для игр с множеством карт, например MM2, Arsenal)
    -- Если в таблице есть ключ, равный GameId — тоже сработает
    if GAMES[gameId] then
        return GAMES[gameId], "game"
    end

    return nil, nil
end

-- ═══════════════════════ БЫСТРАЯ ЗАГРУЗКА ═══════════════════════
local function LoadScript(scriptData)
    print("[FableHub] Загружаю: " .. scriptData.name .. " " .. scriptData.version)
    local success, err = pcall(function()
        loadstring(game:HttpGet(scriptData.url))()
    end)
    if success then
        print("[FableHub] " .. scriptData.name .. " загружен ✓")
    else
        warn("[FableHub] Ошибка загрузки: " .. tostring(err))
    end
    return success
end

-- ═══════════════════════ ГЛАВНАЯ ЛОГИКА ═══════════════════════
local detected, mode = DetectGame()

if detected then
    -- Игра найдена — загружаем сразу
    print("[FableHub] Обнаружена игра: " .. detected.name .. " (" .. mode .. ")")
    LoadScript(detected)
    return
end

-- ═══════════════════════ GUI ДЛЯ НЕИЗВЕСТНОЙ ИГРЫ ═══════════════════════
print("[FableHub] Игра не найдена в базе. Открываю меню выбора...")

local CFG = {
    Accent1 = Color3.fromRGB(139, 92, 246),
    Accent2 = Color3.fromRGB(217, 70, 239),
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

local ScreenGui = New("ScreenGui", {
    Name = "FableHubAutoLoader",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = LP:WaitForChild("PlayerGui") or CoreGui,
})

local Main = New("Frame", {
    Size = UDim2.new(0, 520, 0, 420),
    Position = UDim2.new(0.5, -260, 0.5, -210),
    BackgroundColor3 = CFG.BgDark,
    BorderSizePixel = 0,
    Parent = ScreenGui,
})
local c = Instance.new("UICorner", Main); c.CornerRadius = UDim.new(0, 16)
local s = Instance.new("UIStroke", Main); s.Color = CFG.Accent1; s.Thickness = 1.5

-- Заголовок
New("TextLabel", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundTransparency = 1,
    Text = "FABLE HUB",
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    TextColor3 = CFG.Text,
    Parent = Main,
})

New("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 40),
    BackgroundTransparency = 1,
    Text = "Игра не определена. Выбери скрипт вручную:",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = CFG.TextSub,
    Parent = Main,
})

-- Информация об игре
local infoText = "PlaceId: " .. tostring(game.PlaceId) .. "  •  GameId: " .. tostring(game.GameId)
New("TextLabel", {
    Size = UDim2.new(1, 0, 0, 16),
    Position = UDim2.new(0, 0, 0, 62),
    BackgroundTransparency = 1,
    Text = infoText,
    Font = Enum.Font.Code,
    TextSize = 10,
    TextColor3 = CFG.TextSub,
    Parent = Main,
})

-- Скролл
local Scroll = New("ScrollingFrame", {
    Size = UDim2.new(1, -20, 1, -110),
    Position = UDim2.new(0, 10, 0, 90),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = CFG.Accent1,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = Main,
})
local List = Instance.new("UIListLayout", Scroll)
List.Padding = UDim.new(0, 6)
List.SortOrder = Enum.SortOrder.LayoutOrder

-- Добавление кнопки
local function AddButton(key, scriptData)
    local btn = New("TextButton", {
        Size = UDim2.new(1, -8, 0, 56),
        BackgroundColor3 = CFG.BgPanel,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = Scroll,
    })
    local bc = Instance.new("UICorner", btn); bc.CornerRadius = UDim.new(0, 10)

    local nameLbl = New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 22),
        Position = UDim2.new(0, 12, 0, 6),
        BackgroundTransparency = 1,
        Text = scriptData.name .. "  " .. scriptData.version,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = CFG.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn,
    })

    New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 18),
        Position = UDim2.new(0, 12, 0, 28),
        BackgroundTransparency = 1,
        Text = scriptData.desc .. "  (ID: " .. tostring(key) .. ")",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = CFG.TextSub,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn,
    })

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = CFG.BgHover }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = CFG.BgPanel }):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        nameLbl.Text = scriptData.name .. " — загрузка..."
        btn.BackgroundColor3 = CFG.Accent1

        task.spawn(function()
            local success = LoadScript(scriptData)
            if success then
                nameLbl.Text = scriptData.name .. " ✓"
                btn.BackgroundColor3 = CFG.Success
                task.wait(0.5)
                ScreenGui:Destroy()
            else
                nameLbl.Text = scriptData.name .. " ✗ ошибка"
                btn.BackgroundColor3 = CFG.Danger
            end
        end)
    end)
end

-- Заполняем список
for key, scriptData in pairs(GAMES) do
    AddButton(key, scriptData)
end

-- Кнопка закрытия
local Close = New("TextButton", {
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(1, -34, 0, 12),
    BackgroundColor3 = CFG.BgPanel,
    BorderSizePixel = 0,
    Text = "×",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = CFG.TextSub,
    AutoButtonColor = false,
    Parent = Main,
})
local cc = Instance.new("UICorner", Close); cc.CornerRadius = UDim.new(0, 6)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

print("[FableHub Auto-Loader] Меню открыто")
