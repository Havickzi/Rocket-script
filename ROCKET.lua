-- Delta Executor - San Diego Border Roleplay (Оптимизированная версия V7)
-- Задержка: 5 секунд, фиолетово-черный стиль
-- Полная оптимизация кода
-- ROCKET версия 7.0 (Optimized 5s)

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

-- ===== ЛОКАЛЬНЫЕ ПЕРЕМЕННЫЕ ДЛЯ ОПТИМИЗАЦИИ =====
local Color3, UDim2, UDim, Instance, task, print = Color3, UDim2, UDim, Instance, task, print
local plr = player
local mouse = plr:GetMouse()

local selectedPlayer = nil
local stopFlag = false
local isRunning = false

-- ===== ФУНКЦИЯ СОЗДАНИЯ GUI-ЭЛЕМЕНТОВ =====
local function createUI()
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0.92, 0, 0.88, 0)
    main.Position = UDim2.new(0.04, 0, 0.06, 0)
    main.BackgroundColor3 = Color3.fromRGB(18, 8, 28)
    main.BackgroundTransparency = 0.05
    main.BorderSizePixel = 2
    main.BorderColor3 = Color3.fromRGB(120, 50, 200)
    main.ClipsDescendants = true
    main.Parent = gui
    
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 20)
    
    -- Тень
    local shadow = Instance.new("Frame", main)
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.BackgroundColor3 = Color3.fromRGB(80, 20, 150)
    shadow.BackgroundTransparency = 0.7
    shadow.BorderSizePixel = 0
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 20)
    
    -- Заголовок
    local title = Instance.new("Frame", main)
    title.Size = UDim2.new(1, 0, 0.09, 0)
    title.BackgroundColor3 = Color3.fromRGB(40, 15, 70)
    title.BackgroundTransparency = 0.3
    title.BorderSizePixel = 0
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 20)
    
    local titleText = Instance.new("TextLabel", title)
    titleText.Size = UDim2.new(1, 0, 1, 0)
    titleText.Text = "⚡ ROCKET · РЕСЕТЫ ⚡"
    titleText.TextColor3 = Color3.fromRGB(200, 100, 255)
    titleText.TextScaled = true
    titleText.BackgroundTransparency = 1
    titleText.Font = Enum.Font.GothamBold
    titleText.TextStrokeColor3 = Color3.fromRGB(80, 0, 160)
    titleText.TextStrokeTransparency = 0.5
    
    -- Кнопка закрытия
    local close = Instance.new("TextButton", title)
    close.Size = UDim2.new(0.08, 0, 0.8, 0)
    close.Position = UDim2.new(0.91, 0, 0.1, 0)
    close.Text = "✕"
    close.TextScaled = true
    close.BackgroundColor3 = Color3.fromRGB(80, 10, 30)
    close.TextColor3 = Color3.fromRGB(255, 100, 100)
    close.Font = Enum.Font.GothamBold
    close.BorderSizePixel = 0
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 12)
    close.MouseButton1Click:Connect(function() main.Visible = false end)
    
    -- Список игроков
    local list = Instance.new("ScrollingFrame", main)
    list.Size = UDim2.new(1, -10, 0.38, 0)
    list.Position = UDim2.new(0, 5, 0.1, 0)
    list.BackgroundColor3 = Color3.fromRGB(25, 12, 40)
    list.BackgroundTransparency = 0.2
    list.BorderSizePixel = 1
    list.BorderColor3 = Color3.fromRGB(100, 40, 180)
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.ScrollBarThickness = 6
    list.ScrollBarImageColor3 = Color3.fromRGB(120, 50, 200)
    Instance.new("UICorner", list).CornerRadius = UDim.new(0, 12)
    
    -- Поле ввода
    local inputFrame = Instance.new("Frame", main)
    inputFrame.Size = UDim2.new(1, -10, 0.07, 0)
    inputFrame.Position = UDim2.new(0, 5, 0.5, 0)
    inputFrame.BackgroundColor3 = Color3.fromRGB(30, 12, 55)
    inputFrame.BackgroundTransparency = 0.3
    inputFrame.BorderSizePixel = 2
    inputFrame.BorderColor3 = Color3.fromRGB(100, 40, 180)
    Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 12)
    
    local inputLabel = Instance.new("TextLabel", inputFrame)
    inputLabel.Size = UDim2.new(0.3, 0, 1, 0)
    inputLabel.Position = UDim2.new(0, 5, 0, 0)
    inputLabel.Text = "КОЛ-ВО:"
    inputLabel.TextScaled = true
    inputLabel.BackgroundTransparency = 1
    inputLabel.TextColor3 = Color3.fromRGB(180, 120, 255)
    inputLabel.Font = Enum.Font.GothamBold
    
    local inputBox = Instance.new("TextBox", inputFrame)
    inputBox.Size = UDim2.new(0.6, 0, 1, 0)
    inputBox.Position = UDim2.new(0.35, 0, 0, 0)
    inputBox.Text = "1"
    inputBox.TextScaled = true
    inputBox.BackgroundColor3 = Color3.fromRGB(10, 5, 20)
    inputBox.TextColor3 = Color3.fromRGB(220, 180, 255)
    inputBox.BorderSizePixel = 0
    inputBox.ClearTextOnFocus = false
    inputBox.PlaceholderText = "Число"
    inputBox.Font = Enum.Font.GothamBold
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 8)
    
    -- Счётчик
    local counterFrame = Instance.new("Frame", main)
    counterFrame.Size = UDim2.new(1, -10, 0.06, 0)
    counterFrame.Position = UDim2.new(0, 5, 0.58, 0)
    counterFrame.BackgroundColor3 = Color3.fromRGB(25, 10, 45)
    counterFrame.BackgroundTransparency = 0.2
    counterFrame.BorderSizePixel = 1
    counterFrame.BorderColor3 = Color3.fromRGB(80, 30, 150)
    Instance.new("UICorner", counterFrame).CornerRadius = UDim.new(0, 10)
    
    local counterLabel = Instance.new("TextLabel", counterFrame)
    counterLabel.Size = UDim2.new(1, 0, 1, 0)
    counterLabel.Text = "ВЫПОЛНЕНО: 0 / 0"
    counterLabel.TextScaled = true
    counterLabel.BackgroundTransparency = 1
    counterLabel.TextColor3 = Color3.fromRGB(150, 100, 255)
    counterLabel.Font = Enum.Font.GothamBold
    
    -- Кнопки
    local exec = Instance.new("TextButton", main)
    exec.Size = UDim2.new(0.45, 0, 0.09, 0)
    exec.Position = UDim2.new(0.03, 0, 0.66, 0)
    exec.Text = "▶ ВЫПОЛНИТЬ"
    exec.TextScaled = true
    exec.BackgroundColor3 = Color3.fromRGB(80, 20, 160)
    exec.TextColor3 = Color3.fromRGB(220, 180, 255)
    exec.Font = Enum.Font.GothamBold
    exec.BorderSizePixel = 2
    exec.BorderColor3 = Color3.fromRGB(150, 60, 220)
    Instance.new("UICorner", exec).CornerRadius = UDim.new(0, 14)
    
    local cancel = Instance.new("TextButton", main)
    cancel.Size = UDim2.new(0.45, 0, 0.09, 0)
    cancel.Position = UDim2.new(0.52, 0, 0.66, 0)
    cancel.Text = "✖ ОТМЕНА"
    cancel.TextScaled = true
    cancel.BackgroundColor3 = Color3.fromRGB(100, 20, 40)
    cancel.TextColor3 = Color3.fromRGB(255, 150, 150)
    cancel.Font = Enum.Font.GothamBold
    cancel.BorderSizePixel = 2
    cancel.BorderColor3 = Color3.fromRGB(180, 50, 80)
    Instance.new("UICorner", cancel).CornerRadius = UDim.new(0, 14)
    
    local refresh = Instance.new("TextButton", main)
    refresh.Size = UDim2.new(0.4, 0, 0.07, 0)
    refresh.Position = UDim2.new(0.3, 0, 0.78, 0)
    refresh.Text = "🔄 ОБНОВИТЬ"
    refresh.TextScaled = true
    refresh.BackgroundColor3 = Color3.fromRGB(40, 15, 90)
    refresh.TextColor3 = Color3.fromRGB(180, 140, 255)
    refresh.Font = Enum.Font.GothamBold
    refresh.BorderSizePixel = 1
    refresh.BorderColor3 = Color3.fromRGB(100, 40, 180)
    Instance.new("UICorner", refresh).CornerRadius = UDim.new(0, 12)
    
    -- Кнопка открытия
    local open = Instance.new("TextButton", gui)
    open.Size = UDim2.new(0.15, 0, 0.07, 0)
    open.Position = UDim2.new(0.01, 0, 0.01, 0)
    open.Text = "🚀 ROCKET"
    open.TextScaled = true
    open.BackgroundColor3 = Color3.fromRGB(40, 10, 80)
    open.TextColor3 = Color3.fromRGB(200, 150, 255)
    open.Font = Enum.Font.GothamBold
    open.BorderSizePixel = 2
    open.BorderColor3 = Color3.fromRGB(120, 50, 200)
    Instance.new("UICorner", open).CornerRadius = UDim.new(0, 14)
    
    return {
        main = main,
        list = list,
        inputBox = inputBox,
        counterLabel = counterLabel,
        exec = exec,
        cancel = cancel,
        refresh = refresh,
        open = open,
        selectedPlayer = selectedPlayer,
        stopFlag = stopFlag,
        isRunning = isRunning
    }
end

local UI = createUI()

-- ===== ФУНКЦИЯ ОБНОВЛЕНИЯ СПИСКА (ОПТИМИЗИРОВАНА) =====
local function refreshPlayerList()
    local list = UI.list
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local players = game.Players:GetPlayers()
    local yOffset = 5
    local height = 50
    
    for _, plr in ipairs(players) do
        if plr ~= player then
            local btn = Instance.new("TextButton", list)
            btn.Size = UDim2.new(1, -10, 0, height)
            btn.Position = UDim2.new(0, 5, 0, yOffset)
            btn.Text = "👤 " .. plr.Name
            btn.TextScaled = true
            btn.BackgroundColor3 = Color3.fromRGB(40, 15, 70)
            btn.BackgroundTransparency = 0.3
            btn.TextColor3 = Color3.fromRGB(200, 150, 255)
            btn.Font = Enum.Font.GothamBold
            btn.BorderSizePixel = 2
            btn.BorderColor3 = Color3.fromRGB(80, 30, 150)
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
            
            btn.MouseButton1Click:Connect(function()
                selectedPlayer = plr
                for _, child in ipairs(list:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.BackgroundColor3 = Color3.fromRGB(40, 15, 70)
                        child.BorderColor3 = Color3.fromRGB(80, 30, 150)
                    end
                end
                btn.BackgroundColor3 = Color3.fromRGB(60, 20, 120)
                btn.BorderColor3 = Color3.fromRGB(180, 80, 255)
            end)
            
            yOffset = yOffset + height + 5
        end
    end
    
    list.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
end

refreshPlayerList()

-- ===== ИГРОВЫЕ ФУНКЦИИ (ОПТИМИЗИРОВАНЫ) =====
local function forceReset()
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    if hum and hum.Health > 0 then
        hum.Health = 0
    else
        char:BreakJoints()
    end
    return true
end

local function teleportToPlayer(target)
    if not target then return end
    local tChar = target.Character
    local mChar = player.Character
    if not tChar or not mChar then return end
    local tRoot = tChar:FindFirstChild("HumanoidRootPart")
    local mRoot = mChar:FindFirstChild("HumanoidRootPart")
    if tRoot and mRoot then
        mRoot.CFrame = tRoot.CFrame * CFrame.new(0, 2, 1)
    end
end

-- ===== АВТО-РЕСЕТ =====
local function onCharacterAdded(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Died:Connect(function()
        task.wait(0.3)
        player:LoadCharacter()
    end)
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then onCharacterAdded(player.Character) end

-- ===== ОБРАБОТЧИКИ СОБЫТИЙ =====
-- Отмена
UI.cancel.MouseButton1Click:Connect(function()
    stopFlag = true
    UI.counterLabel.Text = "⛔ ОСТАНОВЛЕНО!"
    UI.counterLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
end)

-- Обновление списка
UI.refresh.MouseButton1Click:Connect(function()
    refreshPlayerList()
    UI.counterLabel.Text = "🔄 ОБНОВЛЕНО"
    UI.counterLabel.TextColor3 = Color3.fromRGB(200, 150, 255)
    task.wait(0.7)
    if not isRunning then
        UI.counterLabel.Text = "ВЫПОЛНЕНО: 0 / 0"
        UI.counterLabel.TextColor3 = Color3.fromRGB(150, 100, 255)
    end
end)

-- Открытие меню
UI.open.MouseButton1Click:Connect(function()
    UI.main.Visible = true
end)

-- ===== ОСНОВНАЯ ЛОГИКА (5 СЕКУНД) =====
UI.exec.MouseButton1Click:Connect(function()
    if isRunning then return end
    
    local count = tonumber(UI.inputBox.Text) or 1
    if count < 1 then count = 1 end
    if count > 100 then count = 100 end
    UI.inputBox.Text = tostring(count)
    
    stopFlag = false
    isRunning = true
    UI.exec.BackgroundColor3 = Color3.fromRGB(60, 10, 120)
    UI.exec.Text = "⏳ ВЫПОЛНЯЕТСЯ..."
    UI.counterLabel.TextColor3 = Color3.fromRGB(200, 150, 255)
    
    local completed = 0
    
    for i = 1, count do
        if stopFlag then
            UI.counterLabel.Text = "⛔ ОСТАНОВЛЕНО: " .. completed .. "/" .. count
            UI.counterLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            break
        end
        
        if selectedPlayer then
            teleportToPlayer(selectedPlayer)
            task.wait(0.3)
        end
        
        forceReset()
        completed = completed + 1
        UI.counterLabel.Text = "⚡ ВЫПОЛНЕНО: " .. completed .. " / " .. count
        
        -- ЗАДЕРЖКА 5 СЕКУНД
        task.wait(5.0)
        
        if selectedPlayer then
            local newChar = player.Character
            if newChar then
                local newRoot = newChar:FindFirstChild("HumanoidRootPart")
                local targetChar = selectedPlayer.Character
                if targetChar then
                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    if newRoot and targetRoot then
                        newRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 2, 1)
                    end
                end
            end
        end
        
        task.wait(0.3)
    end
    
    if not stopFlag then
        UI.counterLabel.Text = "✅ ГОТОВО! " .. completed .. "/" .. count
        UI.counterLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
    
    isRunning = false
    UI.exec.BackgroundColor3 = Color3.fromRGB(80, 20, 160)
    UI.exec.Text = "▶ ВЫПОЛНИТЬ"
end)

print("🚀 ROCKET V7 (Optimized 5s) загружен. Код оптимизирован, КД 5 секунд.")
