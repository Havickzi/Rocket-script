-- ROCKET • V2 (Xeno & Pronghorn Native Edition)
local Players, UIS, RS, VIM, Run = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("ReplicatedStorage"), game:GetService("VirtualInputManager"), game:GetService("RunService")
local LP = Players.LocalPlayer

if getgenv().RocketGui and typeof(getgenv().RocketGui) == "Instance" then
    pcall(function() getgenv().RocketGui:Destroy() end)
end
if getgenv().RocketConns and type(getgenv().RocketConns) == "table" then
    for _, conn in ipairs(getgenv().RocketConns) do pcall(function() conn:Disconnect() end) end
end
getgenv().RocketConns = {}
local function addConn(conn) table.insert(getgenv().RocketConns, conn); return conn end

-- Подключаем сетевой клиент (если поддерживается инжектором)
local PronghornClient = nil
pcall(function()
    PronghornClient = require(ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Pronghorn"):WaitForChild("Remotes")).Client
end)

pcall(function()
    if hookmetamethod then
        local old; old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local m = getnamecallmethod and getnamecallmethod() or ""
            if not checkcaller() and (m:lower() == "kick" or (m == "FireServer" or m == "InvokeServer") and string.match(self.Name:lower(), "cheat|ban|detect|log|flag")) then
                return nil
            end
            return old(self, ...)
        end))
    end
end)

local C = { Loss = 5000, MaxResets = 1000, Mode = "Resets" }
local XP = { 
    Enabled = true, CheckType = "Secondary", MoveToTarget = true, StopDist = 6, MaxDist = 90, 
    Sprint = true, Noclip = true, AntiAFK = true, Delay = 0.5, BlacklistTime = 120, AutoReturn = true, 
    ReturnPos = CFrame.new(2825.07, 18.64, 109.55, -0.788, 0, -0.615, 0, 1, 0, 0.615, 0, -0.788) 
}
local State = { isRunning = false, stop = false, target = nil, totalDone = 0, totalXP = 0, lastStampTime = 0, startTime = 0 }

local processed, isSprinting = {}, false

local function pressKey(key, state) pcall(function() VIM:SendKeyEvent(state, key, false, game) end) end
local function releaseKeys()
    if isSprinting then isSprinting = false; pressKey(Enum.KeyCode.LeftShift, false) end
end

addConn(LP.Idled:Connect(function()
    if XP.AntiAFK then
        local vu = game:GetService("VirtualUser")
        pcall(function() vu:CaptureController(); vu:ClickButton2(Vector2.new()) end)
    end
end))

local function equipTool()
    local char, bp = LP.Character, LP:FindFirstChild("Backpack")
    if not char then return nil end
    local activeTool = char:FindFirstChildOfClass("Tool")
    if activeTool then return activeTool end
    if bp then
        local targetTool = bp:FindFirstChild("Stamp") or char:FindFirstChild("Stamp")
        if not targetTool then
            for _, item in ipairs(bp:GetChildren()) do if item:IsA("Tool") then targetTool = item; break end end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if targetTool and hum then
            pcall(function() hum:EquipTool(targetTool) end)
            task.wait(0.2)
            return char:FindFirstChildOfClass("Tool")
        end
    end
    return nil
end

local function safeTeleport(targetCF)
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    root.Anchored = true
    local start, dest = root.Position, targetCF.Position
    local dist = (dest - start).Magnitude
    if dist < 10 then root.CFrame, root.Anchored = targetCF, false; return end
    for i = 1, math.ceil(dist / 4) do
        if State.stop then break end
        root.CFrame = CFrame.new(start:Lerp(dest, i / math.ceil(dist / 4)))
        task.wait(0.03)
    end
    root.CFrame, root.Anchored = targetCF, false
end

addConn(LP.CharacterAdded:Connect(function() task.delay(1.2, equipTool) end))
if LP.Character then task.delay(0.5, equipTool) end

addConn(Run.Stepped:Connect(function()
    if C.Mode == "XP" and XP.Noclip then
        local char = LP.Character
        if char then
            for _, pName in ipairs({"HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "Head"}) do
                local p = char:FindFirstChild(pName)
                if p and p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end))

local function c(class, props, kids)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, kid in ipairs(kids or {}) do kid.Parent = inst end
    return inst
end

local guiParent = LP:WaitForChild("PlayerGui")
pcall(function() if gethui then local h = gethui(); if h then guiParent = h end end end)

local gui = c("ScreenGui", { Name = "ROCKET_Opt", ResetOnSpawn = false, Parent = guiParent })
getgenv().RocketGui = gui

local main = c("Frame", { Size = UDim2.new(0, 350, 0, 395), Position = UDim2.new(0.5, -175, 0.5, -197), BackgroundColor3 = Color3.fromRGB(18, 15, 28), Visible = false, Parent = gui }, {
    c("UICorner", { CornerRadius = UDim.new(0, 12) }), c("UIStroke", { Color = Color3.fromRGB(120, 80, 220), Thickness = 1.5 })
})

local openBtn = c("TextButton", { Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 10, 0.5, -20), BackgroundColor3 = Color3.fromRGB(18, 15, 28), Text = "🚀", TextSize = 18, Parent = gui }, { c("UICorner", { CornerRadius = UDim.new(1, 0) }) })
addConn(openBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end))
addConn(UIS.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.RightShift then main.Visible = not main.Visible end end))

local dragging, dragStart, startPos
addConn(main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dragStart, startPos = true, i.Position, main.Position end end))
addConn(UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end))
addConn(UIS.InputEnded:Connect(function() dragging = false end))

local header = c("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Parent = main })
c("TextLabel", { Size = UDim2.new(1, -110, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = "🚀 ROCKET • V2 (Xeno Fixed)", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = header })
local modeBtn = c("TextButton", { Size = UDim2.new(0, 95, 0, 24), Position = UDim2.new(1, -105, 0, 4), BackgroundColor3 = Color3.fromRGB(60, 40, 120), Text = "🔄 РЕЖИМ", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 9, Parent = header }, { c("UICorner", { CornerRadius = UDim.new(0, 5) }) })

local resHolder = c("Frame", { Size = UDim2.new(1, 0, 0, 255), Position = UDim2.new(0, 0, 0, 35), BackgroundTransparency = 1, Parent = main })
local xpHolder = c("Frame", { Size = UDim2.new(1, 0, 0, 255), Position = UDim2.new(0, 0, 0, 35), BackgroundTransparency = 1, Visible = false, Parent = main })

local function makeInput(parent, y, label, val, color)
    c("TextLabel", { Size = UDim2.new(0.35, 0, 0, 22), Position = UDim2.new(0.05, 0, 0, y), BackgroundTransparency = 1, Text = label, TextColor3 = Color3.fromRGB(180,180,210), Font = Enum.Font.GothamMedium, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = parent })
    return c("TextBox", { Size = UDim2.new(0.55, 0, 0, 22), Position = UDim2.new(0.4, 0, 0, y), BackgroundColor3 = Color3.fromRGB(26,22,42), Text = val, TextColor3 = color, Font = Enum.Font.GothamBold, TextSize = 11, Parent = parent }, { c("UICorner", { CornerRadius = UDim.new(0, 5) }) })
end

local balBox = makeInput(resHolder, 0, "Баланс ($):", "100000", Color3.fromRGB(0, 255, 170))
local resBox = makeInput(resHolder, 26, "Кол-во ресетов:", "5", Color3.fromRGB(255, 215, 0))
local remainLbl = c("TextLabel", { Size = UDim2.new(0.9, 0, 0, 22), Position = UDim2.new(0.05, 0, 0, 52), BackgroundColor3 = Color3.fromRGB(12,10,20), Text = "💵 ОСТАТОК: 0 $", TextColor3 = Color3.fromRGB(0, 240, 255), Font = Enum.Font.GothamBold, TextSize = 10, Parent = resHolder }, { c("UICorner", { CornerRadius = UDim.new(0, 5) }) })

local function calc() remainLbl.Text = "💵 ОСТАТОК: " .. math.max((tonumber(balBox.Text) or 0) - ((tonumber(resBox.Text) or 0) * C.Loss), 0) .. " $" end
addConn(balBox:GetPropertyChangedSignal("Text"):Connect(calc))
addConn(resBox:GetPropertyChangedSignal("Text"):Connect(calc))

local list = c("ScrollingFrame", { Size = UDim2.new(1, -6, 1, -6), Position = UDim2.new(0, 3, 0, 3), BackgroundTransparency = 1, CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 2, Parent = c("Frame", { Size = UDim2.new(0.9, 0, 0, 110), Position = UDim2.new(0.05, 0, 0, 78), BackgroundColor3 = Color3.fromRGB(12,10,20), Parent = resHolder }, { c("UICorner", { CornerRadius = UDim.new(0, 5) }) }) })

local function refreshList()
    for _, v in pairs(list:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local y = 2
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local sel = State.target == p
            local b = c("TextButton", { Size = UDim2.new(1, -4, 0, 20), Position = UDim2.new(0, 2, 0, y), BackgroundColor3 = sel and Color3.fromRGB(80,40,140) or Color3.fromRGB(22,18,36), Text = (sel and "🎯 " or "👤 ") .. p.Name, TextColor3 = sel and Color3.new(1,1,1) or Color3.fromRGB(200,200,220), Font = Enum.Font.GothamMedium, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = list }, { c("UICorner", { CornerRadius = UDim.new(0, 4) }) })
            b.MouseButton1Click:Connect(function() State.target = p; refreshList() end)
            y += 22
        end
    end
    list.CanvasSize = UDim2.new(0,0,0,y)
end

local btnPrimary = c("TextButton", { Size = UDim2.new(0.44, 0, 0, 24), Position = UDim2.new(0.05, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(45,40,60), Text = "🟢 GRANT [R]", TextColor3 = Color3.fromRGB(160,160,180), Font = Enum.Font.GothamBold, TextSize = 9, Parent = xpHolder }, { c("UICorner", { CornerRadius = UDim.new(0, 5) }) })
local btnSecondary = c("TextButton", { Size = UDim2.new(0.44, 0, 0, 24), Position = UDim2.new(0.51, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(220,120,0), Text = "🟠 INSPECT [F]", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 9, Parent = xpHolder }, { c("UICorner", { CornerRadius = UDim.new(0, 5) }) })

local function setCheck(t)
    XP.CheckType = t
    local isSec = t == "Secondary"
    btnSecondary.BackgroundColor3 = isSec and Color3.fromRGB(220,120,0) or Color3.fromRGB(45,40,60)
    btnPrimary.BackgroundColor3 = not isSec and Color3.fromRGB(0,170,100) or Color3.fromRGB(45,40,60)
end
btnPrimary.MouseButton1Click:Connect(function() setCheck("Primary") end)
btnSecondary.MouseButton1Click:Connect(function() setCheck("Secondary") end)

local xpStop = makeInput(xpHolder, 28, "Дистанция остановки:", "6", Color3.fromRGB(255,200,100))
local xpMax = makeInput(xpHolder, 54, "Макс. дистанция:", "90", Color3.fromRGB(255,200,100))
local xpDel = makeInput(xpHolder, 80, "Задержка (сек):", "0.5", Color3.fromRGB(255,200,100))

local function makeToggle(parent, y, label, key)
    c("TextLabel", { Size = UDim2.new(0.65, 0, 0, 22), Position = UDim2.new(0.05, 0, 0, y), BackgroundTransparency = 1, Text = label, TextColor3 = Color3.fromRGB(180,180,210), Font = Enum.Font.GothamMedium, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = parent })
    local b = c("TextButton", { Size = UDim2.new(0.25, 0, 0, 22), Position = UDim2.new(0.7, 0, 0, y), BackgroundColor3 = XP[key] and Color3.fromRGB(0,180,80) or Color3.fromRGB(180,40,40), Text = XP[key] and "✅ ВКЛ" or "❌ ВЫКЛ", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 10, Parent = parent }, { c("UICorner", { CornerRadius = UDim.new(0, 5) }) })
    b.MouseButton1Click:Connect(function() XP[key] = not XP[key]; b.Text, b.BackgroundColor3 = XP[key] and "✅ ВКЛ" or "❌ ВЫКЛ", XP[key] and Color3.fromRGB(0,180,80) or Color3.fromRGB(180,40,40) end)
end
makeToggle(xpHolder, 108, "🏃 Спринт:", "Sprint")
makeToggle(xpHolder, 134, "🛡️ Ноклип:", "Noclip")
makeToggle(xpHolder, 160, "🏠 Авто-возврат:", "AutoReturn")
makeToggle(xpHolder, 186, "🤖 Анти-АФК:", "AntiAFK")

local function makeBtn(x, w, text, color)
    return c("TextButton", { Size = UDim2.new(w, 0, 0, 26), Position = UDim2.new(x, 0, 0, 295), BackgroundColor3 = color, Text = text, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 11, Parent = main }, { c("UICorner", { CornerRadius = UDim.new(0, 5) }) })
end

local btnRun, btnStop, btnRef = makeBtn(0.05, 0.28, "▶ СТАРТ", Color3.fromRGB(0,180,120)), makeBtn(0.36, 0.28, "✖ СТОП", Color3.fromRGB(200,40,70)), makeBtn(0.67, 0.28, "🔄 ОБН.", Color3.fromRGB(70,50,120))
local lblCounter = c("TextLabel", { Size = UDim2.new(0.9, 0, 0, 20), Position = UDim2.new(0.05, 0, 0, 331), BackgroundColor3 = Color3.fromRGB(12,10,20), Text = "📊 XP: 0 | ⚡ 0 XP/m", TextColor3 = Color3.fromRGB(200,200,250), Font = Enum.Font.GothamMedium, TextSize = 10, Parent = main }, { c("UICorner", { CornerRadius = UDim.new(0, 4) }) })
local status = c("TextLabel", { Size = UDim2.new(0.9, 0, 0, 22), Position = UDim2.new(0.05, 0, 0, 353), BackgroundColor3 = Color3.fromRGB(12,10,20), Text = "ГОТОВ", TextColor3 = Color3.fromRGB(120,255,160), Font = Enum.Font.GothamMedium, TextSize = 10, Parent = main }, { c("UICorner", { CornerRadius = UDim.new(0, 4) }) })

local function switchMode(m)
    C.Mode = m
    local isXP = m == "XP"
    modeBtn.Text, modeBtn.BackgroundColor3 = isXP and "🔄 РЕЖИМ: XP" or "🔄 РЕЖИМ: РЕСЕТЫ", isXP and Color3.fromRGB(40,120,60) or Color3.fromRGB(60,40,120)
    resHolder.Visible, xpHolder.Visible, btnRef.Visible = not isXP, isXP, not isXP
    lblCounter.Text = isXP and string.format("📊 XP: %d | ⚡ 0 XP/m", State.totalXP) or ("📊 ВСЕГО: " .. State.totalDone)
end
modeBtn.MouseButton1Click:Connect(function() switchMode(C.Mode == "Resets" and "XP" or "Resets") end)

local function runXP()
    pcall(function()
        local char = LP.Character
        local hum, root = char and char:FindFirstChildOfClass("Humanoid"), char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end

        local now = os.clock()
        for p, t in pairs(processed) do if now - t > XP.BlacklistTime then processed[p] = nil end end

        local target, minD = nil, tonumber(xpMax.Text) or 90
        local civTeam = game.Teams:FindFirstChild("Civilian")
        
        if civTeam then
            for _, p in ipairs(civTeam:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and not processed[p] then
                    local last = p:GetAttribute("LastStamped")
                    if type(last) ~= "number" or now - last >= 3 then
                        local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if d <= minD then minD, target = d, p end
                    end
                end
            end
        end

        if target then
            local tRoot = target.Character.HumanoidRootPart
            local stopD = tonumber(xpStop.Text) or 6
            
            if XP.MoveToTarget and minD > stopD then
                status.Text = "🏃 ИДУ К " .. target.Name
                if XP.Sprint and not isSprinting then isSprinting = true; pressKey(Enum.KeyCode.LeftShift, true) end
                
                local moveStart = os.clock()
                local timedOut = false
                
                while not State.stop and tRoot.Parent and (root.Position - tRoot.Position).Magnitude > stopD do
                    if os.clock() - moveStart > 8 then timedOut = true; break end
                    hum:MoveTo(tRoot.Position)
                    task.wait(0.2)
                end
                
                if timedOut then
                    processed[target] = os.clock()
                    status.Text = "⏳ ТАЙМАУТ: " .. target.Name
                    hum:MoveTo(root.Position)
                    if isSprinting then isSprinting = false; pressKey(Enum.KeyCode.LeftShift, false) end
                    return
                end
                
                hum:MoveTo(root.Position)
            end

            if not State.stop and tRoot and tRoot.Parent then
                if isSprinting then isSprinting = false; pressKey(Enum.KeyCode.LeftShift, false) end
                root.CFrame = CFrame.new(root.Position, Vector3.new(tRoot.Position.X, tRoot.Position.Y, tRoot.Position.Z))
                target:SetAttribute("LastStamped", os.clock())

                -- Достаем штамп и даем 0.2 сек скрипту игры для генерации ProximityPrompt
                equipTool()
                task.wait(0.2)

                -- Адаптированный блок активации для Xeno
                local isSec = XP.CheckType == "Secondary"
                local targetKey = isSec and Enum.KeyCode.F or Enum.KeyCode.R

                pcall(function()
                    local promptFound = nil
                    for _, desc in ipairs(tRoot:GetDescendants()) do
                        if desc:IsA("ProximityPrompt") then
                            promptFound = desc
                            break
                        end
                    end

                    if promptFound and fireproximityprompt then
                        fireproximityprompt(promptFound)
                    elseif PronghornClient and PronghornClient.BorderAuthorisationService then
                        if isSec then
                            PronghornClient.BorderAuthorisationService:SendToInspection(target)
                        else
                            PronghornClient.BorderAuthorisationService:GrantEntry(target)
                        end
                    else
                        -- Эмуляция зажатия физической клавиши (0.3 сек задержки)
                        pressKey(targetKey, true)
                        task.wait(0.3)
                        pressKey(targetKey, false)
                    end
                end)

                processed[target] = os.clock()
                State.totalXP += (isSec and 25 or 20)
                State.lastStampTime = os.clock()
                
                local elapsedMins = math.max((os.clock() - State.startTime) / 60, 0.01)
                local xpPerMin = math.floor(State.totalXP / elapsedMins)
                
                lblCounter.Text = string.format("📊 XP: %d | ⚡ %d XP/m", State.totalXP, xpPerMin)
                status.Text = (isSec and "🟠 [Inspect]: " or "🟢 [Grant]: ") .. target.Name
            end
        else
            if isSprinting then isSprinting = false; pressKey(Enum.KeyCode.LeftShift, false) end
            if os.clock() - State.lastStampTime < 4 then
                status.Text = "⏳ ОЖИДАНИЕ ПАССАЖИРОВ..."
            elseif XP.AutoReturn and XP.ReturnPos and (root.Position - XP.ReturnPos.Position).Magnitude > 3 then
                status.Text = "🏠 ВОЗВРАТ НА ПОСТ..."
                safeTeleport(XP.ReturnPos)
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(0.4)
        if State.isRunning and C.Mode == "XP" then
            local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if root and root.Position.Y < -10 and XP.AutoReturn and XP.ReturnPos then
                status.Text = "⚠️ ВОЗВРАТ НА ПОСТ..."
                if isSprinting then isSprinting = false; pressKey(Enum.KeyCode.LeftShift, false) end
                safeTeleport(XP.ReturnPos)
                task.wait(1)
            end
        end
    end
end)

btnRun.MouseButton1Click:Connect(function()
    if State.isRunning then return end
    State.isRunning, State.stop = false, false

    if C.Mode == "XP" then
        State.isRunning = true
        State.startTime = os.clock()
        State.totalXP = 0
        btnRun.Text, status.Text, State.lastStampTime = "⏳ XP...", "🎯 XP ЗАПУЩЕН", 0
        
        task.spawn(function()
            equipTool()
            while not State.stop do
                runXP()
                task.wait(tonumber(xpDel.Text) or 0.5)
            end
            releaseKeys()
            State.isRunning, btnRun.Text, status.Text = false, "▶ СТАРТ", "⛔ ОСТАНОВЛЕНО"
        end)
    else
        State.isRunning = true
        calc()
        local startBal = tonumber(balBox.Text) or 0
        local resets = math.min(tonumber(resBox.Text) or 1, C.MaxResets)
        
        local t = State.target or (function() for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then return p end end end)()
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local tRoot = t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")

        if not tRoot or not root then
            status.Text = "❌ Цель не найдена!"
            State.isRunning = false
            return
        end

        btnRun.Text = "⏳ ..."
        task.spawn(function()
            local done = 0
            for i = 1, resets do
                if State.stop then break end
                local myChar = LP.Character
                if not myChar then break end
                
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                local hum = myChar:FindFirstChildOfClass("Humanoid")
                local targetRoot = t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")

                if myRoot and targetRoot and hum then
                    if myRoot.Anchored then myRoot.Anchored = false end
                    myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 2, 1.5)
                    task.wait(0.05)
                    hum.Health = 0
                    done += 1
                    State.totalDone += 1
                    lblCounter.Text = "📊 ВСЕГО: " .. State.totalDone
                    status.Text = "⚡ " .. i .. "/" .. resets
                    task.wait(0.8)
                else
                    task.wait(1)
                end
            end
            balBox.Text = tostring(math.max(startBal - (done * C.Loss), 0))
            calc()
            releaseKeys()
            State.isRunning, State.stop, btnRun.Text, status.Text = false, true, "▶ СТАРТ", "✅ ГОТОВО"
        end)
    end
end)

btnStop.MouseButton1Click:Connect(function() State.stop = true; releaseKeys(); status.Text = "⛔ ОСТАНОВЛЕНО" end)
btnRef.MouseButton1Click:Connect(refreshList)

switchMode(C.Mode)
setCheck(XP.CheckType)
refreshList()
print("🚀 ROCKET V2 (Xeno Fixed) успешно загружен!")
