-- ROCKET • V11.7 (Instant-Auto)
local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name, gui.ResetOnSpawn = "ROCKET_Pro", false

local C = { Loss = 5000, MaxResets = 100, Scale = 1.0 }
local State = { isRunning = false, stop = false, target = nil, totalDone = 0 }

local inBal, inRes, lblRemain, lblCounter, status

local function create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, child in ipairs(children or {}) do child.Parent = inst end
    return inst
end

-- ===== СОХРАНЕНИЕ И ЗАГРУЗКА =====
local function saveData()
    if not isfolder or not makefolder or not writefile then return end
    pcall(function()
        if not isfolder("ROCKET") then makefolder("ROCKET") end
        local data = {
            balance = tonumber(inBal and inBal.Text or 0),
            totalDone = State.totalDone or 0,
            scale = C.Scale,
        }
        writefile("ROCKET/ROCKET_Pro_Save.json", HttpService:JSONEncode(data))
    end)
end

local function loadData()
    if not isfolder or not isfile then return nil end
    if not isfile("ROCKET/ROCKET_Pro_Save.json") then return nil end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile("ROCKET/ROCKET_Pro_Save.json"))
    end)
    if ok and data then
        if data.totalDone then State.totalDone = data.totalDone end
        if data.scale then C.Scale = data.scale end
        return data.balance
    end
    return nil
end

-- ===== UI =====
local main = create("Frame", {
    Size = UDim2.new(0, 380, 0, 420), Position = UDim2.new(0.5, -190, 0.5, -210),
    BackgroundColor3 = Color3.fromRGB(18, 15, 28), BorderSizePixel = 0, Active = true, Parent = gui, Visible = false,
}, {
    create("UICorner", { CornerRadius = UDim.new(0, 14) }),
    create("UIStroke", { Color = Color3.fromRGB(120, 80, 220), Thickness = 1.5 })
})

local uiScale = Instance.new("UIScale", main)

local openBtn = create("TextButton", {
    Size = UDim2.new(0, 42, 0, 42), Position = UDim2.new(0, 12, 0.5, -21),
    BackgroundColor3 = Color3.fromRGB(18, 15, 28), Text = "🚀", TextSize = 20, Active = true, Parent = gui
}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
openBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        main.Visible = not main.Visible
    end
end)

local dragging, dragStart, startPos
main.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, startPos = true, i.Position, main.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function() dragging = false end)

local header = create("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Parent = main })
create("TextLabel", {
    Size = UDim2.new(1, -40, 0, 40), Position = UDim2.new(0, 14, 0, 0),
    BackgroundTransparency = 1, Text = "🚀 ROCKET • PRO V11.7",
    TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = 0, Parent = header
})

local function makeInput(y, labelText, defaultVal, textColor)
    create("TextLabel", {
        Size = UDim2.new(0.3, 0, 0, 28), Position = UDim2.new(0.05, 0, 0, y),
        BackgroundTransparency = 1, Text = labelText, TextColor3 = Color3.fromRGB(180, 180, 210),
        Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = 0, Parent = main
    })
    return create("TextBox", {
        Size = UDim2.new(0.6, 0, 0, 28), Position = UDim2.new(0.35, 0, 0, y),
        BackgroundColor3 = Color3.fromRGB(26, 22, 42), Text = defaultVal,
        TextColor3 = textColor, Font = Enum.Font.GothamBold, TextSize = 13, Parent = main
    }, { create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
end

inBal = makeInput(46, "Баланс ($):", "100000", Color3.fromRGB(0, 255, 170))
inRes = makeInput(78, "Кол-во ресетов:", "5", Color3.fromRGB(255, 215, 0))

lblRemain = create("TextLabel", {
    Size = UDim2.new(0.6, 0, 0, 28), Position = UDim2.new(0.05, 0, 0, 112),
    BackgroundColor3 = Color3.fromRGB(12, 10, 20), Text = "💵 ОСТАТОК: 0 $",
    TextColor3 = Color3.fromRGB(0, 240, 255), Font = Enum.Font.GothamBold, TextSize = 11, Parent = main
}, { create("UICorner", { CornerRadius = UDim.new(0, 6) }) })

local function calculate()
    local bal = tonumber(inBal.Text) or 0
    local resets = tonumber(inRes.Text) or 0
    lblRemain.Text = "💵 ОСТАТОК: " .. math.max(bal - (resets * C.Loss), 0) .. " $"
end
inBal:GetPropertyChangedSignal("Text"):Connect(calculate)
inRes:GetPropertyChangedSignal("Text"):Connect(calculate)

local list = create("ScrollingFrame", {
    Size = UDim2.new(0.9, 0, 0, 110), Position = UDim2.new(0.05, 0, 0, 148),
    BackgroundColor3 = Color3.fromRGB(12, 10, 20), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 3, Parent = main
}, { create("UICorner", { CornerRadius = UDim.new(0, 6) }) })

local function refreshList()
    for _, v in pairs(list:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local y = 4
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player then
            local isSel = (State.target == p)
            local btn = create("TextButton", {
                Size = UDim2.new(1, -8, 0, 22), Position = UDim2.new(0, 4, 0, y),
                BackgroundColor3 = isSel and Color3.fromRGB(80, 40, 140) or Color3.fromRGB(22, 18, 36),
                Text = (isSel and "🎯 " or "👤 ") .. p.Name,
                TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 220),
                Font = Enum.Font.GothamMedium, TextSize = 11, TextXAlignment = 0, Parent = list
            }, { create("UICorner", { CornerRadius = UDim.new(0, 4) }) })
            btn.MouseButton1Click:Connect(function() State.target = p; refreshList() end)
            y = y + 25
        end
    end
    list.CanvasSize = UDim2.new(0, 0, 0, y)
end

local function makeBtn(x, w, text, bgColor)
    return create("TextButton", {
        Size = UDim2.new(w, 0, 0, 30), Position = UDim2.new(x, 0, 0, 268),
        BackgroundColor3 = bgColor, Text = text, TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.GothamBold, TextSize = 11, Parent = main
    }, { create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
end

local btnRun = makeBtn(0.05, 0.28, "▶ СТАРТ", Color3.fromRGB(0, 180, 120))
local btnStop = makeBtn(0.36, 0.28, "✖ СТОП", Color3.fromRGB(200, 40, 70))
local btnRef = makeBtn(0.67, 0.28, "🔄 ОБН.", Color3.fromRGB(70, 50, 120))

lblCounter = create("TextLabel", {
    Size = UDim2.new(0.9, 0, 0, 306), Position = UDim2.new(0.05, 0, 0, 306),
    BackgroundColor3 = Color3.fromRGB(12, 10, 20), Text = "📊 ВСЕГО: 0",
    TextColor3 = Color3.fromRGB(200, 200, 250), Font = Enum.Font.GothamMedium, TextSize = 11, Parent = main
}, { create("UICorner", { CornerRadius = UDim.new(0, 5) }) })

status = create("TextLabel", {
    Size = UDim2.new(0.9, 0, 0, 24), Position = UDim2.new(0.05, 0, 0, 334),
    BackgroundColor3 = Color3.fromRGB(12, 10, 20), Text = "ГОТОВ",
    TextColor3 = Color3.fromRGB(120, 255, 160), Font = Enum.Font.GothamMedium, TextSize = 11, Parent = main
}, { create("UICorner", { CornerRadius = UDim.new(0, 6) }) })

-- ===== ФУНКЦИЯ УБИЙСТВА =====
local function killCharacter(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Dead)
    end
    char:BreakJoints()
end

local function getValidTarget()
    if State.target and State.target.Character and State.target.Character:FindFirstChild("HumanoidRootPart") then
        return State.target
    end
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            return p
        end
    end
end

-- ===== МГНОВЕННАЯ ЛОГИКА ТЕЛЕПОРТА И СМЕРТИ =====
btnRun.MouseButton1Click:Connect(function()
    if State.isRunning then return end
    calculate()
    local bal = tonumber(inBal.Text) or 0
    local resets = math.min(tonumber(inRes.Text) or 1, C.MaxResets)
    
    State.isRunning, State.stop = true, false
    btnRun.Text = "⏳ ..."

    task.spawn(function()
        for i = 1, resets do
            if State.stop then break end
            
            local success, err = pcall(function()
                -- 1. Ждем появления тела после респавна
                local myChar = player.Character or player.CharacterAdded:Wait()
                local myRoot = myChar:WaitForChild("HumanoidRootPart", 5)
                
                local target = getValidTarget()
                if not target then error("НЕТ ЦЕЛЕЙ") end
                
                local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                if not myRoot or not targetRoot then error("НЕТ СПАВНА") end
                
                -- 2. МГНОВЕННЫЙ ТЕЛЕПОРТ
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 2, 1.5)
                
                -- 3. МИНУТНАЯ ПАУЗА ДЛЯ РЕГИСТРАЦИИ ПОЗИЦИИ СЕРВЕРОМ И МГНОВЕННАЯ СМЕРТЬ
                task.wait(0.05)
                killCharacter(myChar)
                
                -- 4. ОБНОВЛЕНИЕ ДАННЫХ
                bal = math.max(bal - C.Loss, 0)
                State.totalDone = State.totalDone + 1
                
                inBal.Text = tostring(bal)
                lblCounter.Text = "📊 ВСЕГО: " .. State.totalDone
                status.Text = "⚡ " .. i .. "/" .. resets .. " | " .. target.Name
                saveData()
                
                -- 5. ОЖИДАНИЕ СЛЕДУЮЩЕГО СЕССИОННОГО СПАВНА
                player.CharacterAdded:Wait()
            end)

            if not success then
                status.Text = "⚠️ " .. tostring(err)
                task.wait(1)
            end
        end
        
        State.isRunning = false
        btnRun.Text = "▶ СТАРТ"
        status.Text = State.stop and "⛔ ОСТАНОВЛЕНО" or "✅ ГОТОВО"
        saveData()
    end)
end)

btnStop.MouseButton1Click:Connect(function() State.stop = true end)
btnRef.MouseButton1Click:Connect(refreshList)

-- Инициализация
local savedBal = loadData()
if savedBal then inBal.Text = tostring(savedBal) end
uiScale.Scale = C.Scale
lblCounter.Text = "📊 ВСЕГО: " .. State.totalDone
calculate()
refreshList()
