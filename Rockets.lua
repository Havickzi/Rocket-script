-- ROCKET • V14.4

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Http = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")
local Run = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ===== АНТИЧИТ-ЗАЩИТА =====
pcall(function()
    local gmt = getrawmetatable and getrawmetatable(game)
    if gmt and setreadonly then
        setreadonly(gmt, false)
        local old = gmt.__namecall
        gmt.__namecall = newcclosure(function(self, ...)
            local m = getnamecallmethod and getnamecallmethod() or ""
            if m:lower() == "kick" or (m == "FireServer" or m == "InvokeServer") and string.match(self.Name:lower(), "cheat|ban|detect|log|flag|check") then
                return nil
            end
            return old(self, ...)
        end)
        setreadonly(gmt, true)
    end
end)

-- ===== КОНФИГУРАЦИЯ И СОСТОЯНИЕ =====
local C = { Loss = 5000, MaxResets = 1000, Mode = "Resets" }
local XP = { Enabled = true, CheckType = "Secondary", MoveToTarget = true, StopDist = 6, MaxDist = 90, Sprint = true, Noclip = true, Delay = 0.5, BlacklistTime = 60 }
local State = { isRunning = false, stop = false, target = nil, totalDone = 0, totalXP = 0 }

local BorderAuth, Client
pcall(function()
    BorderAuth = require(RS.SharedModules.BorderAuthorisationUtil)
    Client = require(RS.SharedModules.Pronghorn.Remotes).Client
end)

local processed, isSprinting = {}, false

-- ===== UI ХЕЛПЕР =====
local function create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    return inst
end

local gui = Instance.new("ScreenGui", (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui"))
gui.Name, gui.ResetOnSpawn = "ROCKET_Opt", false

-- ===== СОХРАНЕНИЕ / ЗАГРУЗКА =====
local path = "ROCKET/ROCKET_Opt.json"
local function save()
    if not writefile then return end
    pcall(function()
        if not isfolder("ROCKET") then makefolder("ROCKET") end
        writefile(path, Http:JSONEncode({bal = tonumber(balBox and balBox.Text or 0), totalDone = State.totalDone, totalXP = State.totalXP, mode = C.Mode, xp = XP}))
    end)
end

local function loadData()
    if not isfile or not isfile(path) then return nil end
    local ok, data = pcall(function() return Http:JSONDecode(readfile(path)) end)
    if ok and data then
        State.totalDone, State.totalXP, C.Mode = data.totalDone or 0, data.totalXP or 0, data.mode or "Resets"
        if data.xp then for k,v in pairs(data.xp) do XP[k] = v end end
        return data.bal
    end
end

-- ===== ГЛАВНОЕ ОКНО =====
local main = create("Frame", {
    Size = UDim2.new(0, 350, 0, 340), Position = UDim2.new(0.5, -175, 0.5, -170),
    BackgroundColor3 = Color3.fromRGB(18, 15, 28), Visible = false, Parent = gui
}, {
    create("UICorner", { CornerRadius = UDim.new(0, 12) }),
    create("UIStroke", { Color = Color3.fromRGB(120, 80, 220), Thickness = 1.5 })
})

local openBtn = create("TextButton", {
    Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 10, 0.5, -20),
    BackgroundColor3 = Color3.fromRGB(18, 15, 28), Text = "🚀", TextSize = 18, Parent = gui
}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
openBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)
UIS.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.RightShift then main.Visible = not main.Visible end end)

-- Перетаскивание
local dragging, dragStart, startPos
main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dragStart, startPos = true, i.Position, main.Position end end)
UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
UIS.InputEnded:Connect(function() dragging = false end)

-- Шапка
local header = create("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Parent = main })
create("TextLabel", { Size = UDim2.new(1, -110, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = "🚀 ROCKET • V14.4", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = header })
local modeBtn = create("TextButton", { Size = UDim2.new(0, 95, 0, 24), Position = UDim2.new(1, -105, 0, 4), BackgroundColor3 = Color3.fromRGB(60, 40, 120), Text = "🔄 РЕЖИМ", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 9, Parent = header }, { create("UICorner", { CornerRadius = UDim.new(0, 5) }) })

-- Контейнеры режимов
local resHolder = create("Frame", { Size = UDim2.new(1, 0, 0, 200), Position = UDim2.new(0, 0, 0, 35), BackgroundTransparency = 1, Parent = main })
local xpHolder = create("Frame", { Size = UDim2.new(1, 0, 0, 200), Position = UDim2.new(0, 0, 0, 35), BackgroundTransparency = 1, Visible = false, Parent = main })

-- Универсальные конструкторы полей
local function makeInput(parent, y, label, val, color)
    create("TextLabel", { Size = UDim2.new(0.35, 0, 0, 22), Position = UDim2.new(0.05, 0, 0, y), BackgroundTransparency = 1, Text = label, TextColor3 = Color3.fromRGB(180,180,210), Font = Enum.Font.GothamMedium, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = parent })
    return create("TextBox", { Size = UDim2.new(0.55, 0, 0, 22), Position = UDim2.new(0.4, 0, 0, y), BackgroundColor3 = Color3.fromRGB(26,22,42), Text = val, TextColor3 = color, Font = Enum.Font.GothamBold, TextSize = 11, Parent = parent }, { create("UICorner", { CornerRadius = UDim.new(0, 5) }) })
end

-- Ресеты элементы
local balBox = makeInput(resHolder, 0, "Баланс ($):", "100000", Color3.fromRGB(0, 255, 170))
local resBox = makeInput(resHolder, 26, "Кол-во ресетов:", "5", Color3.fromRGB(255, 215, 0))
local remainLbl = create("TextLabel", { Size = UDim2.new(0.9, 0, 0, 22), Position = UDim2.new(0.05, 0, 0, 52), BackgroundColor3 = Color3.fromRGB(12,10,20), Text = "💵 ОСТАТОК: 0 $", TextColor3 = Color3.fromRGB(0, 240, 255), Font = Enum.Font.GothamBold, TextSize = 10, Parent = resHolder }, { create("UICorner", { CornerRadius = UDim.new(0, 5) }) })

local function calc()
    remainLbl.Text = "💵 ОСТАТОК: " .. math.max((tonumber(balBox.Text) or 0) - ((tonumber(resBox.Text) or 0) * C.Loss), 0) .. " $"
end
balBox:GetPropertyChangedSignal("Text"):Connect(calc)
resBox:GetPropertyChangedSignal("Text"):Connect(calc)

local listBg = create("Frame", { Size = UDim2.new(0.9, 0, 0, 110), Position = UDim2.new(0.05, 0, 0, 78), BackgroundColor3 = Color3.fromRGB(12,10,20), Parent = resHolder }, { create("UICorner", { CornerRadius = UDim.new(0, 5) }) })
local list = create("ScrollingFrame", { Size = UDim2.new(1, -6, 1, -6), Position = UDim2.new(0, 3, 0, 3), BackgroundTransparency = 1, CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 2, Parent = listBg })

local function refreshList()
    for _, v in pairs(list:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local y = 2
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local sel = State.target == p
            local b = create("TextButton", { Size = UDim2.new(1, -4, 0, 20), Position = UDim2.new(0, 2, 0, y), BackgroundColor3 = sel and Color3.fromRGB(80,40,140) or Color3.fromRGB(22,18,36), Text = (sel and "🎯 " or "👤 ") .. p.Name, TextColor3 = sel and Color3.new(1,1,1) or Color3.fromRGB(200,200,220), Font = Enum.Font.GothamMedium, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = list }, { create("UICorner", { CornerRadius = UDim.new(0, 4) }) })
            b.MouseButton1Click:Connect(function() State.target = p; refreshList() end)
            y = y + 22
        end
    end
    list.CanvasSize = UDim2.new(0,0,0,y)
end

-- XP элементы
local btnPrimary = create("TextButton", { Size = UDim2.new(0.44, 0, 0, 24), Position = UDim2.new(0.05, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(45,40,60), Text = "🟢 ПЕРВИЧНАЯ [R]", TextColor3 = Color3.fromRGB(160,160,180), Font = Enum.Font.GothamBold, TextSize = 9, Parent = xpHolder }, { create("UICorner", { CornerRadius = UDim.new(0, 5) }) })
local btnSecondary = create("TextButton", { Size = UDim2.new(0.44, 0, 0, 24), Position = UDim2.new(0.51, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(220,120,0), Text = "🟠 ВТОРИЧНАЯ [F]", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 9, Parent = xpHolder }, { create("UICorner", { CornerRadius = UDim.new(0, 5) }) })

local function setCheck(t)
    XP.CheckType = t
    local isSec = t == "Secondary"
    btnSecondary.BackgroundColor3 = isSec and Color3.fromRGB(220,120,0) or Color3.fromRGB(45,40,60)
    btnSecondary.TextColor3 = isSec and Color3.new(1,1,1) or Color3.fromRGB(160,160,180)
    btnPrimary.BackgroundColor3 = not isSec and Color3.fromRGB(0,170,100) or Color3.fromRGB(45,40,60)
    btnPrimary.TextColor3 = not isSec and Color3.new(1,1,1) or Color3.fromRGB(160,160,180)
    save()
end
btnPrimary.MouseButton1Click:Connect(function() setCheck("Primary") end)
btnSecondary.MouseButton1Click:Connect(function() setCheck("Secondary") end)

local xpStop = makeInput(xpHolder, 28, "Дистанция остановки:", "6", Color3.fromRGB(255,200,100))
local xpMax = makeInput(xpHolder, 54, "Макс. дистанция:", "90", Color3.fromRGB(255,200,100))
local xpDel = makeInput(xpHolder, 80, "Задержка (сек):", "0.5", Color3.fromRGB(255,200,100))

local function makeToggle(parent, y, label, key)
    create("TextLabel", { Size = UDim2.new(0.65, 0, 0, 22), Position = UDim2.new(0.05, 0, 0, y), BackgroundTransparency = 1, Text = label, TextColor3 = Color3.fromRGB(180,180,210), Font = Enum.Font.GothamMedium, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = parent })
    local b = create("TextButton", { Size = UDim2.new(0.25, 0, 0, 22), Position = UDim2.new(0.7, 0, 0, y), BackgroundColor3 = XP[key] and Color3.fromRGB(0,180,80) or Color3.fromRGB(180,40,40), Text = XP[key] and "✅ ВКЛ" or "❌ ВЫКЛ", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 10, Parent = parent }, { create("UICorner", { CornerRadius = UDim.new(0, 5) }) })
    b.MouseButton1Click:Connect(function()
        XP[key] = not XP[key]
        b.Text = XP[key] and "✅ ВКЛ" or "❌ ВЫКЛ"
        b.BackgroundColor3 = XP[key] and Color3.fromRGB(0,180,80) or Color3.fromRGB(180,40,40)
        save()
    end)
end
makeToggle(xpHolder, 108, "🏃 Спринт:", "Sprint")
makeToggle(xpHolder, 134, "🛡️ Ноклип:", "Noclip")

-- Нижняя панель управления
local function makeBtn(x, w, text, color)
    return create("TextButton", { Size = UDim2.new(w, 0, 0, 26), Position = UDim2.new(x, 0, 0, 245), BackgroundColor3 = color, Text = text, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 11, Parent = main }, { create("UICorner", { CornerRadius = UDim.new(0, 5) }) })
end

local btnRun = makeBtn(0.05, 0.28, "▶ СТАРТ", Color3.fromRGB(0,180,120))
local btnStop = makeBtn(0.36, 0.28, "✖ СТОП", Color3.fromRGB(200,40,70))
local btnRef = makeBtn(0.67, 0.28, "🔄 ОБН.", Color3.fromRGB(70,50,120))

local lblCounter = create("TextLabel", { Size = UDim2.new(0.9, 0, 0, 20), Position = UDim2.new(0.05, 0, 0, 276), BackgroundColor3 = Color3.fromRGB(12,10,20), Text = "📊 ВСЕГО: 0", TextColor3 = Color3.fromRGB(200,200,250), Font = Enum.Font.GothamMedium, TextSize = 10, Parent = main }, { create("UICorner", { CornerRadius = UDim.new(0, 4) }) })
local status = create("TextLabel", { Size = UDim2.new(0.9, 0, 0, 22), Position = UDim2.new(0.05, 0, 0, 298), BackgroundColor3 = Color3.fromRGB(12,10,20), Text = "ГОТОВ", TextColor3 = Color3.fromRGB(120,255,160), Font = Enum.Font.GothamMedium, TextSize = 10, Parent = main }, { create("UICorner", { CornerRadius = UDim.new(0, 4) }) })

-- Переключение режимов
local function switchMode(m)
    C.Mode = m
    local isXP = m == "XP"
    modeBtn.Text = isXP and "🔄 РЕЖИМ: XP" or "🔄 РЕЖИМ: РЕСЕТЫ"
    modeBtn.BackgroundColor3 = isXP and Color3.fromRGB(40,120,60) or Color3.fromRGB(60,40,120)
    resHolder.Visible, xpHolder.Visible, btnRef.Visible = not isXP, isXP, not isXP
    lblCounter.Text = isXP and ("📊 ВСЕГО XP: " .. State.totalXP) or ("📊 ВСЕГО: " .. State.totalDone)
    status.Text = isXP and "🎯 XP-ФАРМ ГОТОВ" or "ГОТОВ"
    save()
end
modeBtn.MouseButton1Click:Connect(function() switchMode(C.Mode == "Resets" and "XP" or "Resets") end)

-- Ноклип
Run.Stepped:Connect(function()
    if C.Mode == "XP" and XP.Noclip and LocalPlayer.Character then
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end
end)

-- XP логика штампа (с кулдауном 1 минута, туториалом и проверкой инспекции)
local function runXP()
    pcall(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local civTeam = game.Teams:FindFirstChild("Civilian")
        if not root or not civTeam then return end

        local now = os.clock()
        -- Очистка черного списка тех, у кого прошло больше 60 секунд (1 минута)
        for p, t in pairs(processed) do if now - t > XP.BlacklistTime then processed[p] = nil end end

        local target, minD = nil, tonumber(xpMax.Text) or 90
        for _, p in ipairs(civTeam:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and not processed[p] then
                local ok, hasAction = pcall(function() return BorderAuth and BorderAuth:HasStampAction(p) end)
                local last = p:GetAttribute("LastStamped")
                if (not ok or hasAction) and (type(last) ~= "number" or now - last >= 3) then
                    local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d <= minD then minD, target = d, p end
                end
            end
        end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if target then
            local tRoot = target.Character.HumanoidRootPart
            if XP.MoveToTarget and minD > (tonumber(xpStop.Text) or 6) then
                if XP.Sprint and not isSprinting then isSprinting = true; VIM:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game) end
                if hum then hum:MoveTo(tRoot.Position) end
                status.Text = "🏃 ИДУ К " .. target.Name
            else
                if isSprinting then isSprinting = false; VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game) end
                root.CFrame = CFrame.new(root.Position, Vector3.new(tRoot.Position.X, root.Position.Y, tRoot.Position.Z))
                
                pcall(function() target:SetAttribute("LastStamped", os.clock()) end)

                -- Определение типа проверки (с учетом туториала и переполненной инспекции)
                local isSec = XP.CheckType == "Secondary"
                if BorderAuth then
                    local okG, canG = pcall(function() return BorderAuth:CanGrantEntry(target) end)
                    local okI, canI = pcall(function() return BorderAuth:CanSendToInspection(target) end)
                    
                    if (okI and not canI) or (okG and canG and (not okI or not canI)) then
                        isSec = false 
                    end
                end

                local key = isSec and Enum.KeyCode.F or Enum.KeyCode.R
                VIM:SendKeyEvent(true, key, false, game); task.wait(0.03); VIM:SendKeyEvent(false, key, false, game)

                if Client and Client.BorderAuthorisationService then
                    pcall(function()
                        if isSec and Client.BorderAuthorisationService.SendToInspection then
                            Client.BorderAuthorisationService:SendToInspection(target)
                        elseif not isSec and Client.BorderAuthorisationService.GrantEntry then
                            Client.BorderAuthorisationService:GrantEntry(target)
                        end
                    end)
                end

                processed[target] = os.clock() -- Добавляем в черный список на 60 секунд
                State.totalXP = State.totalXP + (isSec and 25 or 20)
                lblCounter.Text = "📊 ВСЕГО XP: " .. State.totalXP
                save()
                status.Text = (isSec and "🟠 [F]: " or "🟢 [R]: ") .. target.Name
            end
        else
            if isSprinting then isSprinting = false; VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game) end
            status.Text = "🔍 ПОИСК..."
        end
    end)
end

-- Запуск / Стоп логика
btnRun.MouseButton1Click:Connect(function()
    if State.isRunning then return end
    State.isRunning, State.stop = true, false

    if C.Mode == "XP" then
        btnRun.Text = "⏳ XP..."
        status.Text = "🎯 XP ЗАПУЩЕН"
        task.spawn(function()
            while not State.stop do
                runXP()
                task.wait(tonumber(xpDel.Text) or 0.5)
            end
            State.isRunning = false
            btnRun.Text = "▶ СТАРТ"
            status.Text = "⛔ ОСТАНОВЛЕНО"
        end)
    else
        calc()
        local startBal = tonumber(balBox.Text) or 0
        local resets = math.min(tonumber(resBox.Text) or 1, C.MaxResets)
        btnRun.Text = "⏳ ..."

        task.spawn(function()
            local done = 0
            for i = 1, resets do
                if State.stop then break end
                local ok = pcall(function()
                    local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    local myRoot = myChar:WaitForChild("HumanoidRootPart", 5)
                    local t = State.target or (function() for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then return p end end end)()
                    local tRoot = t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")
                    if not myRoot or not tRoot or (myRoot.Position - tRoot.Position).Magnitude / 3.57 > 40 then error("ОШИБКА ЦЕЛИ") end
                    
                    myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 2, 1.5)
                    task.wait(0.03)
                    myChar:BreakJoints()
                    done = done + 1
                    State.totalDone = State.totalDone + 1
                    lblCounter.Text = "📊 ВСЕГО: " .. State.totalDone
                    status.Text = "⚡ " .. i .. "/" .. resets
                    if i < resets then LocalPlayer.CharacterAdded:Wait() end
                end)
                if not ok then task.wait(1) end
            end
            balBox.Text = tostring(math.max(startBal - (done * C.Loss), 0))
            calc()
            State.isRunning = false
            btnRun.Text = "▶ СТАРТ"
            status.Text = "✅ ГОТОВО"
            save()
        end)
    end
end)

btnStop.MouseButton1Click:Connect(function() State.stop = true; status.Text = "⛔ ОСТАНОВЛЕНО" end)
btnRef.MouseButton1Click:Connect(refreshList)

-- Инициализация при старте
local savedBal = loadData()
if savedBal then balBox.Text = tostring(savedBal) end
switchMode(C.Mode)
setCheck(XP.CheckType)
xpStop.Text, xpMax.Text, xpDel.Text = tostring(XP.StopDist), tostring(XP.MaxDist), tostring(XP.Delay)
calc()
refreshList()

print("🚀 ROCKET V14.4 загружен (кулдаун проверки игрока — 60 секунд)!")
