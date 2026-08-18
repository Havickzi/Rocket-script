-- ROCKET • РЕСЕТЫ (V9.7)
-- San Diego Border Roleplay
-- 🔒 LOSS = 5000 | 🔒 DELAY = 5.0 сек
-- ФИКС: КНОПКИ ВСЕГДА ВИДНЫ

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "ROCKET"
gui.Parent = player.PlayerGui
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local ViewportSize = workspace.CurrentCamera.ViewportSize

local function waitTime(t)
    return (task and task.wait or wait)(t)
end

-- ===== КОНФИГ =====
local C = {
    Loss = 5000,
    Delay = 5.0,
    MaxResets = 100,
    AutoNext = true,
    SaveFile = "ROCKET_Save.json",
    Scale = 1.0,
}

local State = {
    isRunning = false,
    selected = nil,
    stop = false,
    done = 0,
    remainingBalance = 0,
}

local History = {}
local Connections = {}

-- ===== УТИЛИТЫ =====
local function fmt(n)
    local s = tostring(math.floor(n))
    local k = 0
    while true do
        s, k = string.gsub(s, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return s
end

local function tween(obj, props, duration)
    duration = duration or 0.3
    TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function s(v) return v * C.Scale end

-- РАЗМЕРЫ ПОД ЭКРАН
local ScreenW, ScreenH = ViewportSize.X, ViewportSize.Y
local W = math.min(ScreenW * 0.92, s(480))
local H = math.min(ScreenH * 0.85, s(540)) -- ЧУТЬ МЕНЬШЕ, ЧТОБЫ ПОМЕСТИТЬСЯ
local FS = math.max(13, math.min(ScreenW / 30, ScreenH / 38)) * C.Scale
local isMobile = ScreenW < 700

-- ===== ЗАГРУЗКА/СОХРАНЕНИЕ =====
local function saveData(balance)
    if not isfolder or not makefolder or not writefile then return end
    pcall(function()
        if not isfolder("ROCKET") then makefolder("ROCKET") end
        local data = { balance = balance or 0, scale = C.Scale }
        writefile("ROCKET/" .. C.SaveFile, HttpService:JSONEncode(data))
    end)
end

local function loadData()
    if not isfolder or not isfile then return end
    if not isfile("ROCKET/" .. C.SaveFile) then return end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile("ROCKET/" .. C.SaveFile))
    end)
    if ok and data then
        if data.scale then C.Scale = data.scale end
        return data.balance
    end
    return nil
end

-- ===== GUI ПЕРЕМЕННЫЕ =====
local main, balanceInput, resetInput, status, list
local startD, lossD, totalD, remainD
local execBtn, cancelBtn, refreshBtn, calcBtn
local sizeBtn

-- ===== ПОСТРОЕНИЕ GUI =====
main = Instance.new("Frame")
main.Size = UDim2.new(0, W, 0, H)
main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
main.BackgroundColor3 = Color3.fromRGB(12, 10, 22)
main.BackgroundTransparency = 0.08
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui
main.Visible = false
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, s(18))

local glow = Instance.new("Frame")
glow.Size = UDim2.new(1, 4, 1, 4)
glow.Position = UDim2.new(0, -2, 0, -2)
glow.BackgroundColor3 = Color3.fromRGB(200, 170, 0)
glow.BackgroundTransparency = 0.85
glow.BorderSizePixel = 0
glow.ZIndex = 0
glow.Parent = main
Instance.new("UICorner", glow).CornerRadius = UDim.new(0, s(20))

-- ===== ЗАГОЛОВОК =====
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, s(40))
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
header.BackgroundTransparency = 0.3
header.BorderSizePixel = 0
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, s(18))

local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, -40, 0, 2)
headerLine.Position = UDim2.new(0.5, -20, 1, -6)
headerLine.BackgroundColor3 = Color3.fromRGB(200, 170, 0)
headerLine.BackgroundTransparency = 0.5
headerLine.BorderSizePixel = 0
headerLine.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, s(12), 0, 0)
title.BackgroundTransparency = 1
title.Text = "🔥 ROCKET • РЕСЕТЫ 💀"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, s(28), 0, s(28))
closeBtn.Position = UDim2.new(1, -s(34), 0.5, -s(14))
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 20)
closeBtn.BackgroundTransparency = 0.5
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
end)

-- Кнопка размера
sizeBtn = Instance.new("TextButton")
sizeBtn.Size = UDim2.new(0, s(28), 0, s(28))
sizeBtn.Position = UDim2.new(1, -s(66), 0.5, -s(14))
sizeBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 60)
sizeBtn.BackgroundTransparency = 0.2
sizeBtn.Text = "🔍"
sizeBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
sizeBtn.TextSize = FS * 0.7
sizeBtn.Font = Enum.Font.GothamBold
sizeBtn.BorderSizePixel = 2
sizeBtn.BorderColor3 = Color3.fromRGB(200, 170, 0)
sizeBtn.Parent = header
Instance.new("UICorner", sizeBtn).CornerRadius = UDim.new(1, 0)

-- ===== ФАБРИКИ ЭЛЕМЕНТОВ =====
local function makeLabel(text, y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.35, 0, 0, s(20))
    l.Position = UDim2.new(0.04, 0, 0, y)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(180, 170, 210)
    l.TextSize = FS * 0.8
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = main
    return l
end

local function makeInput(placeholder, y, color)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.35, 0, 0, s(28))
    box.Position = UDim2.new(0.42, 0, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(8, 6, 16)
    box.BackgroundTransparency = 0.2
    box.BorderSizePixel = 2
    box.BorderColor3 = color or Color3.fromRGB(60, 50, 120)
    box.Text = placeholder
    box.TextColor3 = Color3.fromRGB(150, 150, 170)
    box.TextSize = FS * 0.8
    box.Font = Enum.Font.GothamBold
    box.ClearTextOnFocus = true
    box.Parent = main
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, s(8))
    
    box.FocusLost:Connect(function()
        if box.Text == "" then
            box.Text = placeholder
            box.TextColor3 = Color3.fromRGB(150, 150, 170)
        end
    end)
    
    box:GetPropertyChangedSignal("Text"):Connect(function()
        if box.Text == placeholder then
            box.TextColor3 = Color3.fromRGB(150, 150, 170)
            box.BorderColor3 = Color3.fromRGB(60, 50, 120)
        else
            box.TextColor3 = Color3.fromRGB(200, 200, 255)
            box.BorderColor3 = Color3.fromRGB(0, 200, 0)
        end
    end)
    
    return box
end

local function makeButton(text, x, bg, border, txtCol)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.28, 0, 0, s(32))
    btn.Position = UDim2.new(x, 0, 0, 0)
    btn.BackgroundColor3 = bg or Color3.fromRGB(40, 30, 80)
    btn.BackgroundTransparency = 0.15
    btn.BorderSizePixel = 2
    btn.BorderColor3 = border or Color3.fromRGB(100, 80, 180)
    btn.Text = text
    btn.TextColor3 = txtCol or Color3.fromRGB(220, 210, 255)
    btn.TextSize = FS * 0.75
    btn.Font = Enum.Font.GothamBold
    btn.Parent = main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, s(10))
    
    btn.MouseEnter:Connect(function()
        tween(btn, { BackgroundTransparency = 0.05 }, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, { BackgroundTransparency = 0.15 }, 0.15)
    end)
    
    return btn
end

-- ===== ПОСТРОЕНИЕ UI (КОМПАКТНОЕ) =====
local iy1, iy2 = s(50), s(84)
makeLabel("💰 БАЛАНС:", iy1 - 4)
balanceInput = makeInput("Введите баланс", iy1 - 2)

makeLabel("🔄 РЕСЕТОВ:", iy2 - 4)
resetInput = makeInput("1", iy2 - 2, Color3.fromRGB(200, 170, 0))

calcBtn = makeButton("🧮 РАССЧ.", 0.78, Color3.fromRGB(0, 60, 130), Color3.fromRGB(0, 150, 255), Color3.fromRGB(200, 220, 255))
calcBtn.Size = UDim2.new(0.18, 0, 0, s(28))
calcBtn.Position = UDim2.new(0.78, 0, 0, iy1 - 2)

-- ===== БЛОК РЕЗУЛЬТАТОВ =====
local ry = iy2 + s(28) + s(10)
local rh = s(80)

local resFrame = Instance.new("Frame")
resFrame.Size = UDim2.new(0.92, 0, 0, rh)
resFrame.Position = UDim2.new(0.04, 0, 0, ry)
resFrame.BackgroundColor3 = Color3.fromRGB(6, 4, 14)
resFrame.BackgroundTransparency = 0.3
resFrame.BorderSizePixel = 2
resFrame.BorderColor3 = Color3.fromRGB(40, 30, 80)
resFrame.Parent = main
Instance.new("UICorner", resFrame).CornerRadius = UDim.new(0, s(12))

local resGlow = Instance.new("Frame")
resGlow.Size = UDim2.new(1, 4, 1, 4)
resGlow.Position = UDim2.new(0, -2, 0, -2)
resGlow.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
resGlow.BackgroundTransparency = 0.9
resGlow.BorderSizePixel = 0
resGlow.ZIndex = 0
resGlow.Parent = resFrame
Instance.new("UICorner", resGlow).CornerRadius = UDim.new(0, s(14))

local function makeResLine(text, y, col)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.48, 0, 0, s(20))
    l.Position = UDim2.new(0.04, 0, 0, y)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = col or Color3.fromRGB(180, 180, 220)
    l.TextSize = FS * 0.7
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = resFrame
    return l
end

startD = makeResLine("💰 СТАРТ: 0 $", s(2), Color3.fromRGB(100, 255, 100))
lossD = makeResLine("📉 ПОТЕРЯ: 5,000 $", s(24), Color3.fromRGB(255, 150, 100))
totalD = makeResLine("📊 ОБЩАЯ ПОТЕРЯ: 0 $", s(46), Color3.fromRGB(255, 200, 50))

remainD = Instance.new("TextLabel")
remainD.Size = UDim2.new(0.44, 0, 0.85, 0)
remainD.Position = UDim2.new(0.52, 0, 0.05, 0)
remainD.BackgroundTransparency = 1
remainD.Text = "💵 ОСТАТОК: 0 $"
remainD.TextColor3 = Color3.fromRGB(0, 255, 200)
remainD.TextSize = FS * 1.1
remainD.Font = Enum.Font.GothamBold
remainD.TextXAlignment = Enum.TextXAlignment.Center
remainD.Parent = resFrame

-- ===== СПИСОК ИГРОКОВ =====
local ly = ry + rh + s(6)
makeLabel("🎯 ВЫБЕРИ ЦЕЛЬ:", ly - 2)

list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(0.92, 0, 0, s(80))
list.Position = UDim2.new(0.04, 0, 0, ly + s(16))
list.BackgroundColor3 = Color3.fromRGB(8, 6, 16)
list.BackgroundTransparency = 0.3
list.BorderSizePixel = 2
list.BorderColor3 = Color3.fromRGB(60, 40, 120)
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ScrollBarThickness = isMobile and 3 or 5
list.Parent = main
Instance.new("UICorner", list).CornerRadius = UDim.new(0, s(10))

-- ===== КНОПКИ УПРАВЛЕНИЯ =====
local by = ly + s(80) + s(14)

execBtn = makeButton("▶ ЗАПУСТИТЬ", 0.04, Color3.fromRGB(80, 60, 0), Color3.fromRGB(255, 200, 0))
execBtn.Position = UDim2.new(0.04, 0, 0, by)

cancelBtn = makeButton("✖ ОТМЕНА", 0.36, Color3.fromRGB(60, 15, 25), Color3.fromRGB(180, 50, 80))
cancelBtn.Position = UDim2.new(0.36, 0, 0, by)

refreshBtn = makeButton("🔄 ОБН.", 0.68, Color3.fromRGB(30, 20, 60), Color3.fromRGB(120, 100, 200))
refreshBtn.Position = UDim2.new(0.68, 0, 0, by)

-- ===== СТАТУС =====
status = Instance.new("TextLabel")
status.Size = UDim2.new(0.92, 0, 0, s(22))
status.Position = UDim2.new(0.04, 0, 0, by + s(36))
status.BackgroundColor3 = Color3.fromRGB(8, 6, 16)
status.BackgroundTransparency = 0.2
status.BorderSizePixel = 1
status.BorderColor3 = Color3.fromRGB(40, 30, 80)
status.Text = "ГОТОВ"
status.TextColor3 = Color3.fromRGB(100, 255, 100)
status.TextSize = FS * 0.7
status.Font = Enum.Font.GothamBold
status.Parent = main
Instance.new("UICorner", status).CornerRadius = UDim.new(0, s(8))

-- ===== КНОПКА ОТКРЫТИЯ =====
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, s(150), 0, s(34))
openBtn.Position = UDim2.new(0.01, 0, 0.01, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(20, 12, 45)
openBtn.BackgroundTransparency = 0.1
openBtn.BorderSizePixel = 2
openBtn.BorderColor3 = Color3.fromRGB(200, 170, 0)
openBtn.Text = "🔥 ROCKET"
openBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
openBtn.TextSize = FS * 0.75
openBtn.Font = Enum.Font.GothamBold
openBtn.Parent = gui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, s(12))

openBtn.MouseEnter:Connect(function()
    tween(openBtn, { BackgroundTransparency = 0.0 }, 0.15)
end)
openBtn.MouseLeave:Connect(function()
    tween(openBtn, { BackgroundTransparency = 0.1 }, 0.15)
end)

-- ===== РАЗМЕР МЕНЮ =====
local scales = {0.7, 0.85, 1.0, 1.15, 1.3, 1.5}
local scaleLabels = {"0.7x", "0.85x", "1.0x", "1.15x", "1.3x", "1.5x"}
local scaleIdx = 1

for i, v in ipairs(scales) do
    if v == C.Scale then
        scaleIdx = i
        sizeBtn.Text = scaleLabels[i]
        break
    end
end

sizeBtn.MouseButton1Click:Connect(function()
    scaleIdx = scaleIdx % #scales + 1
    C.Scale = scales[scaleIdx]
    sizeBtn.Text = scaleLabels[scaleIdx]
    saveData()
    
    local nw = math.min(ScreenW * 0.92, s(480))
    local nh = math.min(ScreenH * 0.85, s(540))
    main.Size = UDim2.new(0, nw, 0, nh)
    main.Position = UDim2.new(0.5, -nw/2, 0.5, -nh/2)
    
    status.Text = "⚙️ " .. scaleLabels[scaleIdx]
    status.TextColor3 = Color3.fromRGB(255, 215, 0)
    task.wait(1)
    if not State.isRunning then
        status.Text = "✅ ГОТОВ"
        status.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end)

-- ===== ФУНКЦИЯ КАЛЬКУЛЯТОРА =====
local function calculate()
    if not balanceInput or not resetInput then return end
    local text = balanceInput.Text
    if text == "Введите баланс" or text == "" then return end
    local start = tonumber(text) or 0
    local resets = tonumber(resetInput.Text) or 0
    if start < 0 then start = 0 end
    if resets < 0 then resets = 0 end
    if resets > C.MaxResets then resets = C.MaxResets end
    
    local loss = resets * C.Loss
    local remain = math.max(start - loss, 0)
    State.remainingBalance = remain
    
    if startD then startD.Text = "💰 СТАРТ: " .. fmt(start) .. " $" end
    if lossD then lossD.Text = "📉 ПОТЕРЯ: " .. fmt(C.Loss) .. " $" end
    if totalD then totalD.Text = "📊 ОБЩАЯ ПОТЕРЯ: " .. fmt(loss) .. " $" end
    if remainD then
        remainD.Text = "💵 ОСТАТОК: " .. fmt(remain) .. " $"
        if remain == 0 then
            remainD.TextColor3 = Color3.fromRGB(255, 50, 50)
        elseif remain < start * 0.3 then
            remainD.TextColor3 = Color3.fromRGB(255, 200, 50)
        else
            remainD.TextColor3 = Color3.fromRGB(0, 255, 200)
        end
    end
    if status then
        status.Text = "✅ РАССЧИТАНО: " .. resets .. " ресетов | Остаток: " .. fmt(remain) .. " $"
        status.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end

-- ===== ОСНОВНЫЕ ФУНКЦИИ =====
local function findBalanceObject()
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        for _, v in pairs(ls:GetChildren()) do
            if (v:IsA("NumberValue") or v:IsA("IntValue")) and 
               (v.Name:lower():find("cash") or v.Name:lower():find("money") or v.Name:lower():find("balance")) then
                return v
            end
        end
        for _, v in pairs(ls:GetChildren()) do
            if v:IsA("NumberValue") or v:IsA("IntValue") then return v end
        end
    end
    return nil
end
local balObj = findBalanceObject()

local function transferToGame(amount)
    if not balObj then
        status.Text = "⚠️ БАЛАНС НЕ НАЙДЕН!"
        status.TextColor3 = Color3.fromRGB(255, 200, 50)
        return false
    end
    local ok = pcall(function()
        balObj.Value = math.floor(amount)
    end)
    if not ok then
        status.Text = "❌ ОШИБКА!"
        status.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
    return ok
end

local function updateBalance(amount)
    balanceInput.Text = tostring(math.floor(amount))
    balanceInput.TextColor3 = Color3.fromRGB(0, 255, 100)
    balanceInput.BorderColor3 = Color3.fromRGB(0, 200, 0)
    calculate()
    status.Text = "✅ БАЛАНС: " .. fmt(amount) .. " $"
    status.TextColor3 = Color3.fromRGB(0, 255, 150)
end

local function isAlive(plr)
    if not plr then return false end
    local c = plr.Character
    if not c then return false end
    local h = c:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

local function findTarget()
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= player and isAlive(p) then return p end
    end
    return nil
end

local function teleport(target)
    if not target then return end
    local tc = target.Character
    local mc = player.Character
    if not tc or not mc then return end
    local tr = tc:FindFirstChild("HumanoidRootPart")
    local mr = mc:FindFirstChild("HumanoidRootPart")
    if tr and mr then
        mr.CFrame = tr.CFrame * CFrame.new(0, 2, 1.5)
    end
end

local function resetChar()
    local c = player.Character
    if not c then return end
    local h = c:FindFirstChild("Humanoid")
    if h and h.Health > 0 then
        h.Health = 0
    else
        c:BreakJoints()
    end
end

function refreshList()
    if not list then return end
    for _, c in ipairs(list:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local y, bh = 2, s(26)
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -8, 0, bh)
            b.Position = UDim2.new(0, 4, 0, y)
            b.BackgroundColor3 = Color3.fromRGB(20, 15, 40)
            b.BackgroundTransparency = 0.3
            b.BorderSizePixel = 1
            b.BorderColor3 = Color3.fromRGB(60, 40, 120)
            b.Text = "👤 " .. p.Name
            b.TextColor3 = Color3.fromRGB(220, 210, 255)
            b.TextSize = FS * 0.6
            b.Font = Enum.Font.GothamBold
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Parent = list
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, s(6))
            
            b.MouseButton1Click:Connect(function()
                State.selected = p
                for _, c in ipairs(list:GetChildren()) do
                    if c:IsA("TextButton") then
                        c.BackgroundColor3 = Color3.fromRGB(20, 15, 40)
                        c.BorderColor3 = Color3.fromRGB(60, 40, 120)
                    end
                end
                b.BackgroundColor3 = Color3.fromRGB(60, 40, 20)
                b.BorderColor3 = Color3.fromRGB(255, 200, 0)
                status.Text = "🎯 ВЫБРАН: " .. p.Name
            end)
            
            y = y + bh + 2
        end
    end
    list.CanvasSize = UDim2.new(0, 0, 0, y + 4)
end

local function resetState()
    State.isRunning = false
    State.stop = false
    execBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 0)
    execBtn.Text = "▶ ЗАПУСТИТЬ"
    status.Text = "✅ ГОТОВ"
    status.TextColor3 = Color3.fromRGB(100, 255, 100)
end

-- ===== ОБРАБОТЧИКИ =====
openBtn.MouseButton1Click:Connect(function()
    main.Visible = true
    refreshList()
    local saved = loadData()
    if saved and saved > 0 then
        balanceInput.Text = tostring(saved)
        balanceInput.TextColor3 = Color3.fromRGB(0, 255, 100)
        balanceInput.BorderColor3 = Color3.fromRGB(0, 200, 0)
    end
    if balanceInput.Text ~= "Введите баланс" and tonumber(balanceInput.Text) then
        calculate()
    end
end)

calcBtn.MouseButton1Click:Connect(function()
    if balanceInput.Text == "Введите баланс" or balanceInput.Text == "" then
        status.Text = "❌ ВВЕДИТЕ БАЛАНС!"
        status.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end
    calculate()
    saveData(tonumber(balanceInput.Text) or 0)
end)

cancelBtn.MouseButton1Click:Connect(function()
    State.stop = true
    status.Text = "⛔ ОСТАНОВЛЕНО!"
    status.TextColor3 = Color3.fromRGB(255, 100, 100)
end)

refreshBtn.MouseButton1Click:Connect(function()
    refreshList()
    if balanceInput.Text ~= "Введите баланс" and tonumber(balanceInput.Text) then
        calculate()
    end
    status.Text = "🔄 ОБНОВЛЕНО"
    status.TextColor3 = Color3.fromRGB(255, 215, 0)
    waitTime(0.7)
    if not State.isRunning then
        status.Text = "✅ ГОТОВ"
        status.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end)

balanceInput:GetPropertyChangedSignal("Text"):Connect(function()
    if balanceInput.Text ~= "Введите баланс" and tonumber(balanceInput.Text) then
        saveData(tonumber(balanceInput.Text))
    end
end)

-- ===== ОСНОВНАЯ ЛОГИКА =====
execBtn.MouseButton1Click:Connect(function()
    if State.isRunning then
        status.Text = "⚠️ УЖЕ ВЫПОЛНЯЕТСЯ!"
        status.TextColor3 = Color3.fromRGB(255, 200, 50)
        return
    end
    
    local text = balanceInput.Text
    if text == "Введите баланс" or text == "" then
        status.Text = "❌ ВВЕДИТЕ БАЛАНС!"
        status.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end
    
    local start = tonumber(text) or 0
    local resets = tonumber(resetInput.Text) or 0
    
    if start <= 0 then
        status.Text = "❌ КОРРЕКТНЫЙ БАЛАНС!"
        status.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end
    if resets <= 0 then
        status.Text = "❌ ВВЕДИТЕ РЕСЕТЫ!"
        status.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end
    if resets > C.MaxResets then
        status.Text = "⚠️ МАКСИМУМ " .. C.MaxResets .. "!"
        status.TextColor3 = Color3.fromRGB(255, 200, 50)
        return
    end
    
    if not State.selected or not isAlive(State.selected) then
        if C.AutoNext then
            local nt = findTarget()
            if nt then
                State.selected = nt
                status.Text = "🎯 АВТО: " .. nt.Name
                refreshList()
            else
                status.Text = "❌ НЕТ ЦЕЛЕЙ!"
                status.TextColor3 = Color3.fromRGB(255, 50, 50)
                return
            end
        else
            status.Text = "❌ ВЫБЕРИТЕ ЦЕЛЬ!"
            status.TextColor3 = Color3.fromRGB(255, 50, 50)
            return
        end
    end
    
    calculate()
    if State.remainingBalance <= 0 and start > 0 then
        status.Text = "⚠️ БАЛАНС ОБНУЛИТСЯ!"
        status.TextColor3 = Color3.fromRGB(255, 200, 50)
        waitTime(1.5)
    end
    
    State.isRunning = true
    State.stop = false
    execBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 0)
    execBtn.Text = "⏳ ВЫПОЛНЕНИЕ..."
    
    local done = 0
    local cur = start
    local target = State.selected
    
    spawn(function()
        local ok = pcall(function()
            for i = 1, resets do
                if State.stop then
                    status.Text = "⛔ ОСТАНОВЛЕНО: " .. done .. "/" .. resets
                    status.TextColor3 = Color3.fromRGB(255, 100, 100)
                    break
                end
                
                if not isAlive(target) then
                    if C.AutoNext then
                        target = findTarget()
                        if target then
                            State.selected = target
                            status.Text = "🔄 НОВАЯ: " .. target.Name
                        else
                            status.Text = "❌ ЦЕЛЬ УМЕРЛА!"
                            status.TextColor3 = Color3.fromRGB(255, 50, 50)
                            break
                        end
                    else
                        status.Text = "❌ ЦЕЛЬ УМЕРЛА!"
                        status.TextColor3 = Color3.fromRGB(255, 50, 50)
                        break
                    end
                end
                
                teleport(target)
                waitTime(0.3)
                resetChar()
                
                done = done + 1
                cur = math.max(cur - C.Loss, 0)
                
                status.Text = "⚡ " .. done .. "/" .. resets .. " | ОСТАТОК: " .. fmt(cur) .. " $"
                remainD.Text = "💵 ОСТАТОК: " .. fmt(cur) .. " $"
                totalD.Text = "📊 ОБЩАЯ ПОТЕРЯ: " .. fmt((start - cur)) .. " $"
                
                waitTime(C.Delay)
                
                local nc = player.Character
                if nc then
                    local nr = nc:FindFirstChild("HumanoidRootPart")
                    local tc = target.Character
                    if tc then
                        local tr = tc:FindFirstChild("HumanoidRootPart")
                        if nr and tr then
                            nr.CFrame = tr.CFrame * CFrame.new(0, 2, 1.5)
                        end
                    end
                end
                
                waitTime(0.3)
            end
        end)
        
        if not State.stop and ok and done > 0 then
            State.remainingBalance = cur
            table.insert(History, {
                player = target and target.Name or "Unknown",
                resets = done,
                balance = cur,
                time = os.date("%H:%M:%S")
            })
            if #History > 20 then table.remove(History, 1) end
            updateBalance(cur)
            waitTime(0.3)
            transferToGame(cur)
            status.Text = "✅ ГОТОВО! " .. done .. "/" .. resets .. " | Баланс: " .. fmt(cur) .. " $"
            status.TextColor3 = Color3.fromRGB(0, 255, 150)
        end
        
        resetState()
    end)
    
    spawn(function()
        waitTime(resets * (C.Delay + 1) + 5)
        if State.isRunning then
            status.Text = "⚠️ ТАЙМАУТ!"
            status.TextColor3 = Color3.fromRGB(255, 200, 50)
            resetState()
        end
    end)
end)

-- ===== АВТО-РЕСЕТ =====
table.insert(Connections, player.CharacterAdded:Connect(function(c)
    c:WaitForChild("Humanoid").Died:Connect(function()
        waitTime(0.3)
        player:LoadCharacter()
    end)
end))

-- ===== UNLOAD =====
local function unload()
    State.isRunning = false
    State.stop = true
    for _, c in ipairs(Connections) do
        pcall(c.Disconnect, c)
    end
    Connections = {}
    pcall(gui.Destroy, gui)
    getgenv().ROCKET = nil
    print("🧹 ROCKET выгружен")
end

-- ===== ИНИЦИАЛИЗАЦИЯ =====
local savedBalance = loadData()
if savedBalance and savedBalance > 0 then
    balanceInput.Text = tostring(savedBalance)
    balanceInput.TextColor3 = Color3.fromRGB(0, 255, 100)
    balanceInput.BorderColor3 = Color3.fromRGB(0, 200, 0)
end

refreshList()

if balObj then
    print("🚀 ROCKET: Баланс найден: " .. balObj.Name)
else
    print("⚠️ ROCKET: Баланс не найден!")
end

print("🔥 ROCKET V9.7 загружен")
print("🔒 Потеря: " .. C.Loss .. " $ | Задержка: " .. C.Delay .. " сек")
print("🔍 Нажми 🔍 для смены размера")

getgenv().ROCKET = {
    unload = unload,
    history = History,
}
