 -- V7 Xeno/Delta + Ручной баланс
-- Вы сами вводите текущий баланс, скрипт считает остаток
-- ROCKET версия 7.0 (Manual Balance)

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Parent = player.PlayerGui
gui.ResetOnSpawn = false

-- ===== УНИВЕРСАЛЬНЫЙ WAIT =====
local function waitTime(t)
    if task and task.wait then
        return task.wait(t)
    else
        return wait(t)
    end
end

waitTime(0.3)

-- ===== ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ =====
local selectedPlayer = nil
local stopFlag = false
local isRunning = false

-- ===== ОСНОВНАЯ ПАНЕЛЬ =====
local main = Instance.new("Frame")
main.Size = UDim2.new(0.85, 0, 0.82, 0)
main.Position = UDim2.new(0.075, 0, 0.09, 0)
main.BackgroundColor3 = Color3.fromRGB(18, 8, 28)
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(120, 50, 200)
main.ClipsDescendants = true
main.Parent = gui
main.Visible = false

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = main

-- ===== ЗАГОЛОВОК =====
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.08, 0)
title.Text = "⚡ ROCKET · РЕСЕТЫ ⚡"
title.TextColor3 = Color3.fromRGB(200, 100, 255)
title.TextScaled = true
title.BackgroundColor3 = Color3.fromRGB(40, 15, 70)
title.BackgroundTransparency = 0.3
title.Font = Enum.Font.GothamBold
title.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 20)
titleCorner.Parent = title

-- ===== КНОПКА ЗАКРЫТИЯ =====
local close = Instance.new("TextButton")
close.Size = UDim2.new(0.07, 0, 0.75, 0)
close.Position = UDim2.new(0.92, 0, 0.125, 0)
close.Text = "✕"
close.TextScaled = true
close.BackgroundColor3 = Color3.fromRGB(80, 10, 30)
close.TextColor3 = Color3.fromRGB(255, 100, 100)
close.Font = Enum.Font.GothamBold
close.BorderSizePixel = 0
close.Parent = title

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 12)
closeCorner.Parent = close

close.MouseButton1Click = function()
    main.Visible = false
end

-- ===== БЛОК БАЛАНСА =====
local balanceFrame = Instance.new("Frame")
balanceFrame.Size = UDim2.new(1, -10, 0.07, 0)
balanceFrame.Position = UDim2.new(0, 5, 0.09, 0)
balanceFrame.BackgroundColor3 = Color3.fromRGB(25, 12, 40)
balanceFrame.BackgroundTransparency = 0.2
balanceFrame.BorderSizePixel = 2
balanceFrame.BorderColor3 = Color3.fromRGB(100, 40, 180)
balanceFrame.Parent = main

local balanceCorner = Instance.new("UICorner")
balanceCorner.CornerRadius = UDim.new(0, 12)
balanceCorner.Parent = balanceFrame

local balanceLabel = Instance.new("TextLabel")
balanceLabel.Size = UDim2.new(0.3, 0, 1, 0)
balanceLabel.Position = UDim2.new(0.02, 0, 0, 0)
balanceLabel.Text = "💰 БАЛАНС:"
balanceLabel.TextScaled = true
balanceLabel.BackgroundTransparency = 1
balanceLabel.TextColor3 = Color3.fromRGB(150, 100, 255)
balanceLabel.Font = Enum.Font.GothamBold
balanceLabel.Parent = balanceFrame

local balanceInput = Instance.new("TextBox")
balanceInput.Size = UDim2.new(0.25, 0, 0.85, 0)
balanceInput.Position = UDim2.new(0.32, 0, 0.075, 0)
balanceInput.Text = "10000"
balanceInput.TextScaled = true
balanceInput.BackgroundColor3 = Color3.fromRGB(10, 5, 20)
balanceInput.TextColor3 = Color3.fromRGB(220, 180, 255)
balanceInput.BorderSizePixel = 2
balanceInput.BorderColor3 = Color3.fromRGB(100, 40, 180)
balanceInput.ClearTextOnFocus = false
balanceInput.Font = Enum.Font.GothamBold
balanceInput.Parent = balanceFrame

local balanceInputCorner = Instance.new("UICorner")
balanceInputCorner.CornerRadius = UDim.new(0, 8)
balanceInputCorner.Parent = balanceInput

local remainLabel = Instance.new("TextLabel")
remainLabel.Size = UDim2.new(0.35, 0, 1, 0)
remainLabel.Position = UDim2.new(0.62, 0, 0, 0)
remainLabel.Text = "📉 ОСТАНЕТСЯ: $0"
remainLabel.TextScaled = true
remainLabel.BackgroundTransparency = 1
remainLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
remainLabel.Font = Enum.Font.GothamBold
remainLabel.Parent = balanceFrame

-- ===== СПИСОК ИГРОКОВ =====
local listBg = Instance.new("Frame")
listBg.Size = UDim2.new(1, -10, 0.30, 0)
listBg.Position = UDim2.new(0, 5, 0.17, 0)
listBg.BackgroundColor3 = Color3.fromRGB(25, 12, 40)
listBg.BackgroundTransparency = 0.2
listBg.BorderSizePixel = 2
listBg.BorderColor3 = Color3.fromRGB(100, 40, 180)
listBg.Parent = main

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 12)
listCorner.Parent = listBg

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -10, 1, -10)
list.Position = UDim2.new(0, 5, 0, 5)
list.BackgroundTransparency = 1
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ScrollBarThickness = 6
list.Parent = listBg

-- ===== ПОЛЕ ВВОДА =====
local inputFrame = Instance.new("Frame")
inputFrame.Size = UDim2.new(1, -10, 0.07, 0)
inputFrame.Position = UDim2.new(0, 5, 0.49, 0)
inputFrame.BackgroundColor3 = Color3.fromRGB(25, 12, 40)
inputFrame.BackgroundTransparency = 0.2
inputFrame.BorderSizePixel = 2
inputFrame.BorderColor3 = Color3.fromRGB(100, 40, 180)
inputFrame.Parent = main

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 12)
inputCorner.Parent = inputFrame

local inputLabel = Instance.new("TextLabel")
inputLabel.Size = UDim2.new(0.3, 0, 1, 0)
inputLabel.Position = UDim2.new(0.02, 0, 0, 0)
inputLabel.Text = "🔢 КОЛ-ВО:"
inputLabel.TextScaled = true
inputLabel.BackgroundTransparency = 1
inputLabel.TextColor3 = Color3.fromRGB(150, 100, 255)
inputLabel.Font = Enum.Font.GothamBold
inputLabel.Parent = inputFrame

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0.6, 0, 0.85, 0)
inputBox.Position = UDim2.new(0.35, 0, 0.075, 0)
inputBox.Text = "1"
inputBox.TextScaled = true
inputBox.BackgroundColor3 = Color3.fromRGB(10, 5, 20)
inputBox.TextColor3 = Color3.fromRGB(220, 180, 255)
inputBox.BorderSizePixel = 2
inputBox.BorderColor3 = Color3.fromRGB(100, 40, 180)
inputBox.ClearTextOnFocus = false
inputBox.Font = Enum.Font.GothamBold
inputBox.Parent = inputFrame

local inputCorner2 = Instance.new("UICorner")
inputCorner2.CornerRadius = UDim.new(0, 8)
inputCorner2.Parent = inputBox

-- ===== СЧЁТЧИК =====
local counterFrame = Instance.new("Frame")
counterFrame.Size = UDim2.new(1, -10, 0.06, 0)
counterFrame.Position = UDim2.new(0, 5, 0.57, 0)
counterFrame.BackgroundColor3 = Color3.fromRGB(25, 12, 40)
counterFrame.BackgroundTransparency = 0.2
counterFrame.BorderSizePixel = 1
counterFrame.BorderColor3 = Color3.fromRGB(80, 30, 150)
counterFrame.Parent = main

local counterCorner = Instance.new("UICorner")
counterCorner.CornerRadius = UDim.new(0, 10)
counterCorner.Parent = counterFrame

local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(1, 0, 1, 0)
counterLabel.Text = "⚡ ВЫПОЛНЕНО: 0 / 0"
counterLabel.TextScaled = true
counterLabel.BackgroundTransparency = 1
counterLabel.TextColor3 = Color3.fromRGB(150, 100, 255)
counterLabel.Font = Enum.Font.GothamBold
counterLabel.Parent = counterFrame

-- ===== КНОПКИ =====
local btnFrame = Instance.new("Frame")
btnFrame.Size = UDim2.new(1, -10, 0.09, 0)
btnFrame.Position = UDim2.new(0, 5, 0.65, 0)
btnFrame.BackgroundTransparency = 1
btnFrame.Parent = main

local exec = Instance.new("TextButton")
exec.Size = UDim2.new(0.45, 0, 1, 0)
exec.Position = UDim2.new(0, 0, 0, 0)
exec.Text = "▶ ВЫПОЛНИТЬ"
exec.TextScaled = true
exec.BackgroundColor3 = Color3.fromRGB(80, 20, 160)
exec.TextColor3 = Color3.fromRGB(220, 180, 255)
exec.Font = Enum.Font.GothamBold
exec.BorderSizePixel = 2
exec.BorderColor3 = Color3.fromRGB(150, 60, 220)
exec.Parent = btnFrame

local execCorner = Instance.new("UICorner")
execCorner.CornerRadius = UDim.new(0, 14)
execCorner.Parent = exec

local cancel = Instance.new("TextButton")
cancel.Size = UDim2.new(0.45, 0, 1, 0)
cancel.Position = UDim2.new(0.55, 0, 0, 0)
cancel.Text = "✖ ОТМЕНА"
cancel.TextScaled = true
cancel.BackgroundColor3 = Color3.fromRGB(100, 20, 40)
cancel.TextColor3 = Color3.fromRGB(255, 150, 150)
cancel.Font = Enum.Font.GothamBold
cancel.BorderSizePixel = 2
cancel.BorderColor3 = Color3.fromRGB(180, 50, 80)
cancel.Parent = btnFrame

local cancelCorner = Instance.new("UICorner")
cancelCorner.CornerRadius = UDim.new(0, 14)
cancelCorner.Parent = cancel

local refresh = Instance.new("TextButton")
refresh.Size = UDim2.new(0.4, 0, 0.065, 0)
refresh.Position = UDim2.new(0.3, 0, 0.76, 0)
refresh.Text = "🔄 ОБНОВИТЬ"
refresh.TextScaled = true
refresh.BackgroundColor3 = Color3.fromRGB(40, 15, 90)
refresh.TextColor3 = Color3.fromRGB(180, 140, 255)
refresh.Font = Enum.Font.GothamBold
refresh.BorderSizePixel = 1
refresh.BorderColor3 = Color3.fromRGB(100, 40, 180)
refresh.Parent = main

local refreshCorner = Instance.new("UICorner")
refreshCorner.CornerRadius = UDim.new(0, 12)
refreshCorner.Parent = refresh

-- ===== КНОПКА ОТКРЫТИЯ =====
local open = Instance.new("TextButton")
open.Size = UDim2.new(0.14, 0, 0.065, 0)
open.Position = UDim2.new(0.01, 0, 0.01, 0)
open.Text = "🚀 ROCKET"
open.TextScaled = true
open.BackgroundColor3 = Color3.fromRGB(40, 10, 80)
open.TextColor3 = Color3.fromRGB(200, 150, 255)
open.Font = Enum.Font.GothamBold
open.BorderSizePixel = 2
open.BorderColor3 = Color3.fromRGB(120, 50, 200)
open.Parent = gui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 14)
openCorner.Parent = open

open.MouseButton1Click = function()
    main.Visible = true
    updateBalance()
end

-- ===== ФУНКЦИЯ ОБНОВЛЕНИЯ БАЛАНСА =====
local function updateBalance()
    local balance = tonumber(balanceInput.Text) or 0
    local count = tonumber(inputBox.Text) or 0
    local remain = balance - (count * 5000)
    if remain < 0 then remain = 0 end
    remainLabel.Text = "📉 ОСТАНЕТСЯ: $" .. remain
end

balanceInput:GetPropertyChangedSignal("Text"):Connect(updateBalance)
inputBox:GetPropertyChangedSignal("Text"):Connect(updateBalance)

-- ===== ФУНКЦИЯ ОБНОВЛЕНИЯ СПИСКА =====
local function refreshList()
    for _, c in ipairs(list:GetChildren()) do
        if c:IsA("TextButton") then
            c:Destroy()
        end
    end
    
    local y = 5
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -10, 0, 50)
            b.Position = UDim2.new(0, 5, 0, y)
            b.Text = "👤 " .. p.Name
            b.TextScaled = true
            b.BackgroundColor3 = Color3.fromRGB(40, 15, 70)
            b.BackgroundTransparency = 0.3
            b.TextColor3 = Color3.fromRGB(200, 150, 255)
            b.Font = Enum.Font.GothamBold
            b.BorderSizePixel = 2
            b.BorderColor3 = Color3.fromRGB(80, 30, 150)
            b.Parent = list
            
            local bCorner = Instance.new("UICorner")
            bCorner.CornerRadius = UDim.new(0, 10)
            bCorner.Parent = b
            
            b.MouseButton1Click = function()
                selectedPlayer = p
                for _, c in ipairs(list:GetChildren()) do
                    if c:IsA("TextButton") then
                        c.BackgroundColor3 = Color3.fromRGB(40, 15, 70)
                        c.BorderColor3 = Color3.fromRGB(80, 30, 150)
                    end
                end
                b.BackgroundColor3 = Color3.fromRGB(60, 20, 120)
                b.BorderColor3 = Color3.fromRGB(180, 80, 255)
            end
            
            y = y + 55
        end
    end
    
    list.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

refreshList()

-- ===== ИГРОВЫЕ ФУНКЦИИ =====
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

local function teleport(target)
    if not target then return end
    local tc = target.Character
    local mc = player.Character
    if not tc or not mc then return end
    local tr = tc:FindFirstChild("HumanoidRootPart")
    local mr = mc:FindFirstChild("HumanoidRootPart")
    if tr and mr then
        mr.CFrame = tr.CFrame * CFrame.new(0, 2, 1)
    end
end

-- ===== АВТО-РЕСЕТ =====
player.CharacterAdded:Connect(function(c)
    local hum = c:WaitForChild("Humanoid")
    hum.Died:Connect(function()
        waitTime(0.3)
        player:LoadCharacter()
        updateBalance()
    end)
end)

-- ===== ОБРАБОТЧИКИ =====
cancel.MouseButton1Click = function()
    stopFlag = true
    counterLabel.Text = "⛔ ОСТАНОВЛЕНО!"
    counterLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
end

refresh.MouseButton1Click = function()
    refreshList()
    updateBalance()
    counterLabel.Text = "🔄 ОБНОВЛЕНО"
    counterLabel.TextColor3 = Color3.fromRGB(200, 150, 255)
    waitTime(0.7)
    if not isRunning then
        counterLabel.Text = "⚡ ВЫПОЛНЕНО: 0 / 0"
        counterLabel.TextColor3 = Color3.fromRGB(150, 100, 255)
    end
end

-- ===== ОСНОВНАЯ ЛОГИКА =====
exec.MouseButton1Click = function()
    if isRunning then return end
    
    local count = tonumber(inputBox.Text) or 1
    if count < 1 then count = 1 end
    if count > 100 then count = 100 end
    inputBox.Text = tostring(count)
    
    updateBalance()
    
    stopFlag = false
    isRunning = true
    exec.BackgroundColor3 = Color3.fromRGB(60, 10, 120)
    exec.Text = "⏳ ВЫПОЛНЯЕТСЯ..."
    counterLabel.TextColor3 = Color3.fromRGB(200, 150, 255)
    
    local done = 0
    
    for i = 1, count do
        if stopFlag then
            counterLabel.Text = "⛔ ОСТАНОВЛЕНО: " .. done .. "/" .. count
            counterLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            break
        end
        
        if selectedPlayer then
            teleport(selectedPlayer)
            waitTime(0.3)
        end
        
        resetChar()
        done = done + 1
        counterLabel.Text = "⚡ ВЫПОЛНЕНО: " .. done .. " / " .. count
        
        local remaining = count - done
        local balance = tonumber(balanceInput.Text) or 0
        local remain = balance - (remaining * 5000)
        if remain < 0 then remain = 0 end
        remainLabel.Text = "📉 ОСТАНЕТСЯ: $" .. remain
        
        waitTime(5.0)
        
        if selectedPlayer then
            local nc = player.Character
            if nc then
                local nr = nc:FindFirstChild("HumanoidRootPart")
                local tc = selectedPlayer.Character
                if tc then
                    local tr = tc:FindFirstChild("HumanoidRootPart")
                    if nr and tr then
                        nr.CFrame = tr.CFrame * CFrame.new(0, 2, 1)
                    end
                end
            end
        end
        
        waitTime(0.3)
    end
    
    if not stopFlag then
        counterLabel.Text = "✅ ГОТОВО! " .. done .. "/" .. count
        counterLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
        updateBalance()
    end
    
    isRunning = false
    exec.BackgroundColor3 = Color3.fromRGB(80, 20, 160)
    exec.Text = "▶ ВЫПОЛНИТЬ"
end

updateBalance()
print("🚀 ROCKET V7 + Manual Balance загружен. КД 5 сек.")
