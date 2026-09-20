for _, obj in getgc(true) do
        if typeof(obj) ~= "table" or getrawmetatable(obj) then continue end
        local mainrun = false
        for _, v in obj do
            if v == obj then mainrun = true break end
        end
        if not mainrun then continue end
        for _, v in obj do
            if typeof(v) == "number" and v >= 1 and v <= 3 and obj[v] == nil then
                setmetatable(obj, {__newindex = function() end})
                break
            end
        end
    end
    local _chk_Players = game:GetService("Players")
    local _chk_TweenService = game:GetService("TweenService")
    local _chk_CoreGui = game:GetService("CoreGui")
    local _chk_player = _chk_Players.LocalPlayer

    local REQUIRED_FUNCS = {
        { Name = "loadstring",      Test = function() return type(loadstring) == "function" end },
        { Name = "game:HttpGet",    Test = function() return type(game.HttpGet) == "function" or pcall(function() game:HttpGet("https://example.com") end) end },
    }

    local missing = {}
    for _, item in ipairs(REQUIRED_FUNCS) do
        local ok = pcall(item.Test)
        if not ok then
            table.insert(missing, item.Name)
        end
    end

    local function showWarning(msg)
        local sg = Instance.new("ScreenGui")
        sg.Name = "ExecutorCompatWarning"
        sg.ResetOnSpawn = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pcall(function() sg.Parent = _chk_CoreGui end)
        if not sg.Parent then sg.Parent = _chk_player:WaitForChild("PlayerGui") end

        local blur = Instance.new("Frame")
        blur.Size = UDim2.new(1, 0, 1, 0)
        blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        blur.BackgroundTransparency = 0.35
        blur.BorderSizePixel = 0
        blur.ZIndex = 100
        blur.Parent = sg

        local card = Instance.new("Frame")
        card.Size = UDim2.new(0, 340, 0, 160)
        card.Position = UDim2.new(0.5, -170, 0.5, -80)
        card.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
        card.BorderSizePixel = 0
        card.ZIndex = 101
        card.Parent = sg

        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)

        local stroke = Instance.new("UIStroke", card)
        stroke.Color = Color3.fromRGB(255, 80, 80)
        stroke.Thickness = 2

        local icon = Instance.new("TextLabel", card)
        icon.Size = UDim2.new(1, 0, 0, 40)
        icon.Position = UDim2.new(0, 0, 0, 14)
        icon.BackgroundTransparency = 1
        icon.Text = "⚠️"
        icon.TextSize = 32
        icon.Font = Enum.Font.GothamBold
        icon.TextColor3 = Color3.fromRGB(255, 80, 80)
        icon.ZIndex = 102

        local title = Instance.new("TextLabel", card)
        title.Size = UDim2.new(1, -24, 0, 24)
        title.Position = UDim2.new(0, 12, 0, 56)
        title.BackgroundTransparency = 1
        title.Text = "Executor Not Supported"
        title.TextSize = 17
        title.Font = Enum.Font.GothamBold
        title.TextColor3 = Color3.fromRGB(240, 240, 245)
        title.ZIndex = 102

        local body = Instance.new("TextLabel", card)
        body.Size = UDim2.new(1, -24, 0, 50)
        body.Position = UDim2.new(0, 12, 0, 84)
        body.BackgroundTransparency = 1
        body.Text = msg
        body.TextSize = 12
        body.Font = Enum.Font.Gotham
        body.TextColor3 = Color3.fromRGB(180, 180, 190)
        body.TextWrapped = true
        body.ZIndex = 102
    end

    local function showSuccessPopup()
        local sg = Instance.new("ScreenGui")
        sg.Name = "ExecutorCompatSuccess"
        sg.ResetOnSpawn = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pcall(function() sg.Parent = _chk_CoreGui end)
        if not sg.Parent then sg.Parent = _chk_player:WaitForChild("PlayerGui") end

        local card = Instance.new("Frame")
        card.Size = UDim2.new(0, 260, 0, 44)
        card.Position = UDim2.new(0.5, -130, 0, -60)
        card.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
        card.BorderSizePixel = 0
        card.ZIndex = 101
        card.Parent = sg

        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

        local stroke = Instance.new("UIStroke", card)
        stroke.Color = Color3.fromRGB(80, 220, 120)
        stroke.Thickness = 1.5

        local icon = Instance.new("TextLabel", card)
        icon.Size = UDim2.new(0, 30, 1, 0)
        icon.Position = UDim2.new(0, 10, 0, 0)
        icon.BackgroundTransparency = 1
        icon.Text = "✅"
        icon.TextSize = 18
        icon.Font = Enum.Font.GothamBold
        icon.TextColor3 = Color3.fromRGB(80, 220, 120)
        icon.ZIndex = 102

        local lbl = Instance.new("TextLabel", card)
        lbl.Size = UDim2.new(1, -50, 1, 0)
        lbl.Position = UDim2.new(0, 40, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "Executor Supported"
        lbl.TextSize = 14
        lbl.Font = Enum.Font.GothamBold
        lbl.TextColor3 = Color3.fromRGB(240, 240, 245)
        lbl.ZIndex = 102

        _chk_TweenService:Create(card, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -130, 0, 24)
        }):Play()

        task.delay(2.5, function()
            local out = _chk_TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -130, 0, -60)
            })
            out:Play()
            out.Completed:Wait()
            sg:Destroy()
        end)
    end

    if #missing > 0 then
        showWarning("Your executor is missing required functions:\n" .. table.concat(missing, ", ") .. "\n\nThis script requires a full Roblox executor.")
        return
    else
        showSuccessPopup()
    end

    local WindUI = loadstring(game:HttpGet(
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
    ))()

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local TeleportService = game:GetService("TeleportService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local PathfindingService = game:GetService("PathfindingService")
    local player = Players.LocalPlayer

    local Memory = getgenv().MergedUtilityMemory
    if not Memory then
        Memory = {
            SpeedEnabled = true,
            DesiredSpeed = 500,
            SpeedBypassMethod = "GC Hook Bypass",
            AntiKnockbackEnabled = false,
            AntiRagdollEnabled = false,
            InstantAccelerationEnabled = false,
            AntiRejoinEnabled = false,
            FlyEnabled = false,
            FlySpeed = 50,
            EggEspEnabled = false,
            EggAutoStealEnabled = false,
            EggRarityPriorities = {"All"},
            EggBigOnly = false,
            BatAuraEnabled = false,
            AntiTrapEnabled = false,
            AutoSellEnabled = false,
            AutoSellRarities = {"Common", "Uncommon", "Rare", "Epic"},
            AutoStealSpeed = 1000,
            AutoTreadmillEnabled = false,
        }
        getgenv().MergedUtilityMemory = Memory
    end

    _G.DiabloState = _G.DiabloState or {}
    _G.DiabloState.DesiredSpeed = Memory.DesiredSpeed or 500
    _G.DiabloState.SpeedEnabled = Memory.SpeedEnabled or false
    _G.DiabloState.SpeedBypassMethod = Memory.SpeedBypassMethod or "GC Hook Bypass"
    _G.DiabloState.AntiKnockbackEnabled = Memory.AntiKnockbackEnabled or false
    _G.DiabloState.AntiRagdollEnabled = Memory.AntiRagdollEnabled or false
    _G.DiabloState.InstantAccelerationEnabled = Memory.InstantAccelerationEnabled or false
    _G.DiabloState.AntiRejoinEnabled = Memory.AntiRejoinEnabled or false
    _G.DiabloState.FlyEnabled = Memory.FlyEnabled or false
    _G.DiabloState.FlySpeed = Memory.FlySpeed or 50
    _G.DiabloState.BatAuraEnabled = Memory.BatAuraEnabled or false
    _G.DiabloState.AntiTrapEnabled = Memory.AntiTrapEnabled or false
    _G.DiabloState.AutoSellEnabled = Memory.AutoSellEnabled or false
    _G.DiabloState.AutoSellRarities = Memory.AutoSellRarities or {"Common", "Uncommon", "Rare", "Epic"}
    _G.DiabloState.AutoStealSpeed = math.clamp(tonumber(Memory.AutoStealSpeed) or 1000, 100, 1000)
    _G.DiabloState.AutoTreadmillEnabled = Memory.AutoTreadmillEnabled == true
    _G.DiabloState.FlyBodyVelocity = nil
    _G.DiabloState.FlyBodyGyro = nil
    _G.DiabloState.FlyConnection = nil
    _G.DiabloState.CurrentHumanoid = nil
    _G.DiabloState.ragdollConnection = nil

    local DEFAULT_THEME = "Willow Rose"

    local function Gradient(colors, rotation)
        local points = {}
        for position, color in pairs(colors) do
            if type(color) == "table" then
                points[position] = {
                    Color = Color3.fromHex(color.Color),
                    Transparency = color.Transparency or 0,
                }
            else
                points[position] = {
                    Color = Color3.fromHex(color),
                    Transparency = 0,
                }
            end
        end
        return WindUI:Gradient(points, { Rotation = rotation or 45 })
    end

    WindUI:AddTheme({
        Name = DEFAULT_THEME,
        Accent = Gradient({ ["0"] = "#711E42", ["50"] = "#E45B91", ["100"] = "#711E42" }, 45),
        Background = Gradient({
            ["0"] = { Color = "#0B0408", Transparency = 0.06 },
            ["25"] = { Color = "#190812", Transparency = 0.08 },
            ["50"] = { Color = "#351126", Transparency = 0.10 },
            ["75"] = { Color = "#711E42", Transparency = 0.13 },
            ["100"] = { Color = "#0B0408", Transparency = 0.06 },
        }, 135),
        Outline = Gradient({
            ["0"] = { Color = "#4B1730", Transparency = 0.45 },
            ["50"] = { Color = "#D14F85", Transparency = 0.22 },
            ["100"] = { Color = "#5A1C39", Transparency = 0.42 },
        }, 90),
        Button = Gradient({
            ["0"] = { Color = "#2A0C1C", Transparency = 0.72 },
            ["50"] = { Color = "#7E2850", Transparency = 0.61 },
            ["100"] = { Color = "#2A0C1C", Transparency = 0.74 },
        }, 90),
        Text = Color3.fromHex("#FFFFFF"),
        Placeholder = Color3.fromHex("#B8A0A8"),
        Icon = Color3.fromHex("#FFFFFF"),
    })

    WindUI:SetTheme(DEFAULT_THEME)

    local Window = WindUI:CreateWindow({
        Title = "Diablo",
        Icon = "rbxthumb://type=Asset&id=108210086503555&w=150&h=150",
        Author = "made by Diablo",
        Folder = "DiabloHub",
        Size = UDim2.fromOffset(520, 420),
        MinSize = Vector2.new(420, 320),
        ToggleKey = Enum.KeyCode.K,
        Transparent = true,
        Theme = DEFAULT_THEME,
        Resizable = true,
        SideBarWidth = 160,
        HideSearchBar = true,
        ScrollBarEnabled = true,
        Background = "rbxthumb://type=Asset&id=108210086503555&w=150&h=150",
        BackgroundImageTransparency = 0.7,
        ShadowTransparency = 0.22,
        Radius = 14,
        ElementsRadius = 10,
        Acrylic = true,
        NewElements = true,
        HidePanelBackground = true,
        Topbar = { Height = 44, ButtonsType = "Mac" },
        OpenButton = {
            Title = "Open Diablo",
            Icon = "rbxthumb://type=Asset&id=108210086503555&w=150&h=150",
            CornerRadius = UDim.new(1, 0),
            StrokeThickness = 1,
            Draggable = true,
            Enabled = true,
            OnlyMobile = false,
            Scale = 0.92,
            Color = ColorSequence.new(Color3.fromHex("#711E42"), Color3.fromHex("#E45B91")),
        },
        User = {
            Enabled = true,
            Anonymous = false,
            Image = "rbxthumb://type=Asset&id=108210086503555&w=150&h=150",
            Callback = function()
                WindUI:Notify({
                    Title = "Diablo",
                    Content = player.Name,
                    Icon = "user",
                    Duration = 3,
                })
            end,
        },
    })

    Window:SetBackgroundTransparency(0.5)

    local MainTab = Window:Tab({ Title = "Main", Icon = "layout-dashboard" })
    local EggTab = Window:Tab({ Title = "Egg Steal", Icon = "egg" })
    local AdjustTab = Window:Tab({ Title = "Adjust", Icon = "sliders-horizontal" })
    local AutoSellTab = Window:Tab({ Title = "Auto Sell", Icon = "tag" })
    local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    _G.DiabloState.TreadmillPlotState = _G.DiabloState.TreadmillPlotState or nil
    if not _G.DiabloState.TreadmillPlotState then
        pcall(function()
            local module = ReplicatedStorage:FindFirstChild("Client") and ReplicatedStorage.Client:FindFirstChild("PlotState")
            if module and module:IsA("ModuleScript") then
                _G.DiabloState.TreadmillPlotState = require(module)
            end
        end)
    end
    _G.DiabloState.TreadmillNetworking = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
    _G.DiabloState.TreadmillFetchBestStatus = _G.DiabloState.TreadmillNetworking and _G.DiabloState.TreadmillNetworking:FindFirstChild("RF/Haul/FetchWearBestStatus")
    _G.DiabloState.TreadmillAskWearStill = _G.DiabloState.TreadmillNetworking and _G.DiabloState.TreadmillNetworking:FindFirstChild("RF/Treadmill/AskWearStill")
    _G.DiabloState.TreadmillAskDoff = _G.DiabloState.TreadmillNetworking and _G.DiabloState.TreadmillNetworking:FindFirstChild("RF/Treadmill/AskDoff")
    _G.DiabloState.treadmillLoopRunning = false
    _G.DiabloState.lastTreadmillUse = 0
    _G.DiabloState.TreadmillHighlight = _G.DiabloState.TreadmillHighlight or nil

    local function getTreadmillVisual(object)
        if not object or not object.Parent then return nil end
        if object:IsA("Model") or object:IsA("BasePart") then
            return object
        end
        local model = object:FindFirstChildWhichIsA("Model", true)
        if model then return model end
        return object:FindFirstChildWhichIsA("BasePart", true)
    end

    local function clearTreadmillESP()
        local h = _G.DiabloState.TreadmillHighlight
        if h then
            pcall(function() h:Destroy() end)
        end
        _G.DiabloState.TreadmillHighlight = nil
    end

    local function refreshTreadmillESP()
        if not _G.DiabloState.AutoTreadmillEnabled then
            clearTreadmillESP()
            return
        end

        local object = nil
        local part = nil
        pcall(function()
            local finder = _G.DiabloState.FindLocalTreadmill
            if type(finder) == "function" then
                object, part = finder(false)
            end
        end)
        if not object and _G.DiabloTreadmillState then
            object = _G.DiabloTreadmillState.Object
            part = _G.DiabloTreadmillState.Part
        end

        local adornee = getTreadmillVisual(object) or (part and part.Parent and part)
        if not adornee or not adornee.Parent then
            clearTreadmillESP()
            return
        end

        local h = _G.DiabloState.TreadmillHighlight
        if not h or not h.Parent then
            h = Instance.new("Highlight")
            h.Name = "DiabloOwnTreadmillESP"
            h.FillTransparency = 0.72
            h.OutlineTransparency = 0
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillColor = Color3.fromRGB(190, 130, 255)
            h.OutlineColor = Color3.fromRGB(225, 190, 255)
            h.Parent = Workspace
            _G.DiabloState.TreadmillHighlight = h
        end
        h.Adornee = adornee
    end

    local function stopTreadmill()
        if _G.DiabloState.TreadmillAskDoff and _G.DiabloState.TreadmillAskDoff:IsA("RemoteFunction") then
            pcall(function() _G.DiabloState.TreadmillAskDoff:InvokeServer() end)
        end
        clearTreadmillESP()
    end

    local function useTreadmill()
        if not _G.DiabloState.TreadmillAskWearStill or not _G.DiabloState.TreadmillAskWearStill:IsA("RemoteFunction") then
            return false
        end
        if _G.DiabloState.TreadmillFetchBestStatus and _G.DiabloState.TreadmillFetchBestStatus:IsA("RemoteFunction") then
            pcall(function() _G.DiabloState.TreadmillFetchBestStatus:InvokeServer() end)
        end
        local ok = pcall(function()
            _G.DiabloState.TreadmillAskWearStill:InvokeServer()
        end)
        if ok then
            _G.DiabloState.lastTreadmillUse = tick()
            task.defer(refreshTreadmillESP)
        end
        return ok
    end

    local function startTreadmillLoop()
        if _G.DiabloState.treadmillLoopRunning then return end
        _G.DiabloState.treadmillLoopRunning = true
        task.spawn(function()
            while _G.DiabloState.AutoTreadmillEnabled do
                local priorityReady = false
                if type(_G.DiabloState.HasPriorityEggAvailable) == "function" then
                    local ok, result = pcall(_G.DiabloState.HasPriorityEggAvailable)
                    priorityReady = ok and result == true
                end

                if priorityReady then
                    stopTreadmill()
                    task.wait(0.12)
                    continue
                end

                local atPlot = false
                local mover = _G.DiabloState.TweenToTreadmill
                if type(mover) == "function" then
                    local ok, result = pcall(mover)
                    atPlot = ok and result == true
                end

                if atPlot then
                    if tick() - _G.DiabloState.lastTreadmillUse >= 6 then
                        useTreadmill()
                    else
                        refreshTreadmillESP()
                    end
                else
                    refreshTreadmillESP()
                end

                task.wait(0.15)
            end
            stopTreadmill()
            _G.DiabloState.treadmillLoopRunning = false
        end)
    end

    local function safeRequire(parent, ...)
        local current = parent
        for _, name in ipairs({...}) do
            local child = current:FindFirstChild(name)
            if not child then
                local success, result = pcall(function() return current:WaitForChild(name, 5) end)
                if success and result then child = result else return nil end
            end
            current = child
        end
        if not current:IsA("ModuleScript") then return nil end
        local success, result = pcall(require, current)
        return success and result or nil
    end

    local EggState = safeRequire(ReplicatedStorage, "Client", "EggState")
    local Assets = safeRequire(ReplicatedStorage, "Data", "Assets")
    local WorkspaceEggVisibility = nil
    pcall(function()
        WorkspaceEggVisibility = require(LocalPlayer.PlayerScripts.Game.AreaEggs.WorkspaceEggVisibility)
    end)

    if not EggState or not Assets then
        warn("Axur Steal: Critical modules missing.")
    end

    local RarityColors = {
        Common = Color3.fromRGB(150,150,150), Uncommon = Color3.fromRGB(100,200,100),
        Rare = Color3.fromRGB(100,150,255), SuperRare = Color3.fromRGB(80,120,255),
        Epic = Color3.fromRGB(180,80,255), Legendary = Color3.fromRGB(255,200,50),
        Mythic = Color3.fromRGB(255,100,200), Mythical = Color3.fromRGB(255,100,200),
        Divine = Color3.fromRGB(255,50,50), Secret = Color3.fromRGB(255,30,30),
        BrainrotGod = Color3.fromRGB(255,0,0), God = Color3.fromRGB(255,0,0),
        Exclusive = Color3.fromRGB(255,100,50), Limited = Color3.fromRGB(255,150,50),
        Prismatic = Color3.fromRGB(255,100,255), Transcendent = Color3.fromRGB(200,50,255),
        Eternal = Color3.fromRGB(100,255,255), Exotic = Color3.fromRGB(255,200,100),
        Rainbow = Color3.fromRGB(255,100,255), Superior = Color3.fromRGB(255,80,80),
        Titan = Color3.fromRGB(255,120,50), Celestial = Color3.fromRGB(100,200,255),
        Cosmic = Color3.fromRGB(150,100,255), Admin = Color3.fromRGB(255,0,0),
    }

    _G.DiabloState.espEnabled = Memory.EggEspEnabled or false
    _G.DiabloState.autoStealEnabled = Memory.EggAutoStealEnabled or false
    _G.DiabloState.EggRarityPriorities = Memory.EggRarityPriorities
    if type(_G.DiabloState.EggRarityPriorities) ~= "table" then
        if type(Memory.EggRarityFilter) == "string" and Memory.EggRarityFilter ~= "All" then
            _G.DiabloState.EggRarityPriorities = {Memory.EggRarityFilter}
        else
            _G.DiabloState.EggRarityPriorities = {"All"}
        end
    end
    Memory.EggRarityPriorities = _G.DiabloState.EggRarityPriorities
    _G.DiabloState.eggBigOnly = Memory.EggBigOnly or false
    _G.DiabloState.trackedEggs = {}
    _G.DiabloState.bestEggUid = nil
    _G.DiabloState.espBeam = nil
    _G.DiabloState.espPlayerAttach = nil
    _G.DiabloState.espEggAttach = nil
    _G.DiabloState.modelCache = {}
    _G.DiabloState.promptCache = {}
    _G.DiabloState.espLoopRunning = false
    _G.DiabloState.autoLoopRunning = false
    _G.DiabloState.bigOnlyAutoStealEnabled = false
    _G.DiabloState.bigOnlyLoopRunning = false

    local function findEggModel(uid)
        local cached = _G.DiabloState.modelCache[uid]
        if cached and cached.Parent then return cached end

        if WorkspaceEggVisibility and WorkspaceEggVisibility.ResolveModel then
            local s, r = pcall(function() return WorkspaceEggVisibility.ResolveModel(uid) end)
            if s and r and r:IsA("Model") then
                _G.DiabloState.modelCache[uid] = r
                return r
            end
        end

        local m = Workspace:FindFirstChild(uid)
        if m and m:IsA("Model") then
            _G.DiabloState.modelCache[uid] = m
            return m
        end

        local aesc = Workspace:FindFirstChild("AreaEggSlotsClient")
        if aesc then
            m = aesc:FindFirstChild(uid)
            if m and m:IsA("Model") then
                _G.DiabloState.modelCache[uid] = m
                return m
            end
        end

        return nil
    end

    local function getModelBasePart(model)
        if not model then return nil end
        if model.PrimaryPart then return model.PrimaryPart end
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("BasePart") then return d end
        end
        return nil
    end

    local function getModelPrompt(model)
        if not model then return nil end
        local cached = _G.DiabloState.promptCache[model]
        if cached and cached.Parent then return cached end
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("ProximityPrompt") and d.Name == "CarryAreaEgg" then
                _G.DiabloState.promptCache[model] = d
                return d
            end
        end
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                _G.DiabloState.promptCache[model] = d
                return d
            end
        end
        return nil
    end

    local function isEggCarriedByOtherPlayer(uid)
        local data = _G.DiabloState.trackedEggs[uid]
        if not data then return false end
        local model = data.model
        if not model then return false end

        -- Check 1: Is the egg model parented to another player's character?
        local parent = model.Parent
        if parent then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and parent:IsDescendantOf(plr.Character) then
                    return true, plr
                end
            end
        end

        -- Check 2: Does another player have an egg tool in their character or backpack?
        local record = data.record
        local eggName = nil
        if record and record.AssetCategory then
            eggName = tostring(record.AssetCategory):lower()
        end
        local modelName = model.Name:lower()

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local char = plr.Character
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            local tName = tool.Name:lower()
                            if tName:find("area egg") or tName:find("carryareaegg") or
                            tName == "egg" or tName:find("^egg_") or tName:find("_egg$") then
                                -- If we know the egg name, try to match it
                                if eggName and (tName:find(eggName) or modelName:find(tName) or tName:find(modelName)) then
                                    return true, plr
                                elseif not eggName then
                                    return true, plr
                                end
                            end
                        end
                    end
                end
                local backpack = plr:FindFirstChild("Backpack")
                if backpack then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            local tName = tool.Name:lower()
                            if tName:find("area egg") or tName:find("carryareaegg") or
                            tName == "egg" or tName:find("^egg_") or tName:find("_egg$") then
                                if eggName and (tName:find(eggName) or modelName:find(tName) or tName:find(modelName)) then
                                    return true, plr
                                elseif not eggName then
                                    return true, plr
                                end
                            end
                        end
                    end
                end
            end
        end

        -- Check 3: Is the egg's proximity prompt disabled? (often indicates being carried)
        local prompt = getModelPrompt(model)
        if prompt and prompt.Enabled == false then
            return true, nil
        end

        -- Check 4: Does the egg model have a Carrier attribute?
        local carrierAttr = model:GetAttribute("Carrier")
        if carrierAttr and carrierAttr ~= LocalPlayer.UserId then
            return true, Players:GetPlayerByUserId(carrierAttr)
        end

        return false, nil
    end

    local carriedEggsCache = {}
    local lastCarryCheckTime = 0

    local function refreshCarriedEggsCache()
        local now = tick()
        if now - lastCarryCheckTime < 0.3 then return end
        lastCarryCheckTime = now
        carriedEggsCache = {}
        for uid in pairs(_G.DiabloState.trackedEggs) do
            local carried, carrier = isEggCarriedByOtherPlayer(uid)
            if carried then
                carriedEggsCache[uid] = carrier
            end
        end
    end

    local function findPromptNearPosition(position, maxDist)
        maxDist = maxDist or 25
        local bestPrompt, bestDist = nil, maxDist
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Name == "CarryAreaEgg" and obj.Enabled then
                local parent = obj.Parent
                if parent and parent:IsA("BasePart") then
                    local dist = (parent.Position - position).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestPrompt = obj
                    end
                end
            end
        end
        return bestPrompt
    end

    local function getRarityColor(category)
        local info = Assets and Assets.Directory and Assets.Directory[category]
        local r = info and info.Rarity
        if not r then return Color3.fromRGB(150,150,150) end
        local rarityName = r.DisplayName or r.Name
        if not rarityName then return Color3.fromRGB(150,150,150) end
        return RarityColors[tostring(rarityName)] or RarityColors[tostring(r.Name)] or Color3.fromRGB(150,150,150)
    end

    local rarityNameCache = {}
    local function getEggRarityName(record)
        if not record then return "Unknown" end
        local cat = record.AssetCategory
        if not cat then return "Unknown" end
        local cached = rarityNameCache[cat]
        if cached then return cached end
        local info = Assets and Assets.Directory and Assets.Directory[cat]
        local r = info and info.Rarity
        if not r then
            rarityNameCache[cat] = "Unknown"
            return "Unknown"
        end
        local name = r.DisplayName or r.Name
        if name == nil and type(r) == "string" then
            name = r
        end
        name = tostring(name or "Unknown")
        rarityNameCache[cat] = name
        return name
    end

    local RarityPriority = {
        ["admin"] = 100, ["secret"] = 99, ["brainrotgod"] = 98,
        ["divine"] = 97, ["god"] = 96,
        ["eternal"] = 90, ["transcendent"] = 89, ["prismatic"] = 88,
        ["celestial"] = 87, ["cosmic"] = 86, ["titan"] = 85,
        ["mythical"] = 80, ["mythic"] = 79, ["superior"] = 78,
        ["exclusive"] = 77, ["limited"] = 76,
        ["legendary"] = 60,
        ["epic"] = 50, ["exotic"] = 49, ["rainbow"] = 48,
        ["superrare"] = 30, ["rare"] = 20, ["uncommon"] = 10, ["common"] = 1,
    }

    local function getModelSizeScore(model)
        if not model or not model.Parent then return 0 end
        local success, size = pcall(function()
            return model:GetExtentsSize()
        end)
        if success and size then
            local maxDim = math.max(size.X, size.Y, size.Z)
            return math.floor(maxDim * 100)
        end
        return 0
    end

    local function getEggRarityPriority(record)
        local info = Assets and Assets.Directory and Assets.Directory[record.AssetCategory]
        local r = info and info.Rarity
        if not r then return 0 end
        local name = r.Name and tostring(r.Name):lower() or ""
        local priority = RarityPriority[name] or 0
        if priority == 0 and record.AssetCategory then
            local catName = tostring(record.AssetCategory):lower()
            for rarityName, p in pairs(RarityPriority) do
                if catName:find(rarityName) then
                    priority = p
                    break
                end
            end
        end
        return priority
    end

    local function scoreEgg(data)
        local record = data.record
        local sizeScore = getModelSizeScore(data.model)
        if _G.DiabloState.eggBigOnly then
            return sizeScore
        end
        local priority = getEggRarityPriority(record)
        local info = Assets and Assets.Directory and Assets.Directory[record.AssetCategory]
        local r = info and info.Rarity
        local rarityNumber = (r and r.RarityNumber) or 0

        return (priority * 100000000) + (rarityNumber * 10000) + sizeScore
    end

    local function isEggRarityPriorityAllowed(record)
        if table.find(_G.DiabloState.EggRarityPriorities, "All") then
            return true
        end
        local rarityName = getEggRarityName(record)
        for _, selected in ipairs(_G.DiabloState.EggRarityPriorities) do
            if tostring(selected):lower() == rarityName:lower() then
                return true
            end
        end
        return false
    end

    local function hasPriorityEggAvailable()
        for uid, data in pairs(_G.DiabloState.trackedEggs) do
            if data.model and data.model.Parent and not carriedEggsCache[uid] then
                if isEggRarityPriorityAllowed(data.record) then
                    return true
                end
            end
        end
        return false
    end

    _G.DiabloState.HasPriorityEggAvailable = hasPriorityEggAvailable

    _G.DiabloTreadmillState = _G.DiabloTreadmillState or {
        Object = nil,
        Part = nil,
        TreadmillId = nil,
        LastSearch = 0,
        AtStation = false,
        RouteStage = nil,
    }
    _G.DiabloTreadmillRuntimeRefs = _G.DiabloTreadmillRuntimeRefs or {}
    local TreadmillState = _G.DiabloTreadmillState
    local TreadmillRefs = _G.DiabloTreadmillRuntimeRefs

    local function getTreadmillRuntimeRefs()
        if not TreadmillRefs.Save then
            local ok, result = pcall(function()
                return require(ReplicatedStorage.Shared.Save)
            end)
            if ok then TreadmillRefs.Save = result end
        end
        if not TreadmillRefs.Treadmills then
            local ok, result = pcall(function()
                return require(ReplicatedStorage.Data.Treadmills)
            end)
            if ok then TreadmillRefs.Treadmills = result end
        end
        if not TreadmillRefs.RuntimeInstanceRegistry then
            local ok, result = pcall(function()
                return require(ReplicatedStorage.Client.Modules.RuntimeInstanceRegistry)
            end)
            if ok then TreadmillRefs.RuntimeInstanceRegistry = result end
        end
        return TreadmillRefs.Save and TreadmillRefs.Treadmills and TreadmillRefs.RuntimeInstanceRegistry
    end

    local function getOwnedTreadmillConfig()
        if not getTreadmillRuntimeRefs() then return nil end
        local ok, config = pcall(function()
            local data = TreadmillRefs.Save.Get()
            if not data then return nil end
            local level = tonumber(data.TreadmillUpgradeLevel)
            if not level then return nil end
            return TreadmillRefs.Treadmills.GetByUpgradeLevel(level)
        end)
        return ok and config or nil
    end

    local function getTreadmillPart(object)
        if not object or not object.Parent then return nil end
        local part = object:FindFirstChild("SpeedPerSecond", true)
        if part and part:IsA("BasePart") then
            return part
        end
        return object:FindFirstChildWhichIsA("BasePart", true)
    end

    local function findLocalTreadmill(force)
        local now = tick()
        if not force and TreadmillState.Object and TreadmillState.Object.Parent and TreadmillState.Part and TreadmillState.Part.Parent then
            return TreadmillState.Object, TreadmillState.Part
        end
        if not force and now - TreadmillState.LastSearch < 0.25 then
            return TreadmillState.Object, TreadmillState.Part
        end

        TreadmillState.LastSearch = now
        TreadmillState.Object = nil
        TreadmillState.Part = nil
        TreadmillState.TreadmillId = nil

        local config = getOwnedTreadmillConfig()
        if not config or not config._id then return nil, nil end

        local ok, treadmill = pcall(function()
            return TreadmillRefs.RuntimeInstanceRegistry.Demand("Treadmill", config._id)
        end)

        if not ok or typeof(treadmill) ~= "Instance" or not treadmill.Parent then
            treadmill = nil
        end

        if not treadmill then
            pcall(function()
                treadmill = Workspace:FindFirstChild(config._id, true)
            end)
        end

        if not treadmill then
            local targetName = tostring(config._id):lower()
            pcall(function()
                for _, inst in ipairs(Workspace:GetDescendants()) do
                    if inst.Name:lower() == targetName then
                        treadmill = inst
                        break
                    end
                end
            end)
        end

        if not treadmill then
            pcall(function()
                local character = LocalPlayer.Character
                local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                if character then
                    local obj = character:FindFirstChild(config._id)
                    if obj then treadmill = obj end
                end
                if not treadmill and backpack then
                    local obj = backpack:FindFirstChild(config._id)
                    if obj then treadmill = obj end
                end
            end)
        end

        if not treadmill or not treadmill.Parent then
            return nil, nil
        end

        local part = getTreadmillPart(treadmill)
        if not part then return nil, nil end

        TreadmillState.Object = treadmill
        TreadmillState.Part = part
        TreadmillState.TreadmillId = config._id
        return treadmill, part
    end

    _G.DiabloState.FindLocalTreadmill = findLocalTreadmill

    local function resetTreadmillPath()
        TreadmillState.AtStation = false
        TreadmillState.RouteStage = nil
    end

    local function findBestEgg(respectPriorities)
        local bestUid, bestScore = nil, -1
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local playerPos = hrp and hrp.Position or nil

        refreshCarriedEggsCache()

        for uid, data in pairs(_G.DiabloState.trackedEggs) do
            if data.model and data.model.Parent then
                -- Skip eggs carried by other players
                if carriedEggsCache[uid] then continue end

                if respectPriorities and not isEggRarityPriorityAllowed(data.record) then
                    continue
                end

                local s = scoreEgg(data)
                local isBetter = false
                if s > bestScore then
                    isBetter = true
                elseif s == bestScore and playerPos then
                    local bp = data.basePart or getModelBasePart(data.model)
                    if bp then
                        local dist = (playerPos - bp.Position).Magnitude
                        local bestData = bestUid and _G.DiabloState.trackedEggs[bestUid]
                        local bestBp = bestData and (bestData.basePart or getModelBasePart(bestData.model))
                        local bestDist = bestBp and (playerPos - bestBp.Position).Magnitude or math.huge
                        if dist < bestDist then
                            isBetter = true
                        end
                    end
                end
                if isBetter then
                    bestScore = s
                    bestUid = uid
                end
            end
        end
        return bestUid, bestScore
    end

    local function clearEspVisuals()
        for uid, data in pairs(_G.DiabloState.trackedEggs) do
            pcall(function() if data.highlight then data.highlight:Destroy() end end)
            pcall(function() if data.rarityBillboard then data.rarityBillboard:Destroy() end end)
            data.highlight = nil
            data.rarityBillboard = nil
            data.rarityLabel = nil
        end
        pcall(function() if _G.DiabloState.espBeam then _G.DiabloState.espBeam:Destroy() end end)
        pcall(function() if _G.DiabloState.espPlayerAttach then _G.DiabloState.espPlayerAttach:Destroy() end end)
        pcall(function() if _G.DiabloState.espEggAttach then _G.DiabloState.espEggAttach:Destroy() end end)
        _G.DiabloState.espBeam = nil
        _G.DiabloState.espPlayerAttach = nil
        _G.DiabloState.espEggAttach = nil
    end

    local function clearAll()
        clearEspVisuals()
        _G.DiabloState.trackedEggs = {}
        _G.DiabloState.modelCache = {}
        _G.DiabloState.promptCache = {}
        _G.DiabloState.bestEggUid = nil
    end

    local function ensureHighlight(uid)
        local data = _G.DiabloState.trackedEggs[uid]
        if not data then return end
        local model = data.model
        if not model or not model.Parent then return end
        local rarityName = getEggRarityName(data.record)
        local billboardPart = data.basePart or getModelBasePart(model)
        data.basePart = billboardPart
        if billboardPart then
            if not data.rarityBillboard or not data.rarityBillboard.Parent then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "AxurEggRarityESP"
                billboard.AlwaysOnTop = true
                billboard.LightInfluence = 0
                billboard.Size = UDim2.fromOffset(120, 28)
                billboard.StudsOffset = Vector3.new(0, 4, 0)
                billboard.MaxDistance = 300
                billboard.Adornee = billboardPart
                billboard.Parent = billboardPart

                local label = Instance.new("TextLabel")
                label.Name = "Rarity"
                label.Size = UDim2.fromScale(1, 1)
                label.BackgroundTransparency = 1
                label.BorderSizePixel = 0
                label.Font = Enum.Font.GothamBold
                label.TextSize = 14
                label.TextStrokeTransparency = 0.25
                label.Text = rarityName
                label.TextColor3 = getRarityColor(data.record.AssetCategory)
                label.Parent = billboard

                data.rarityBillboard = billboard
                data.rarityLabel = label
            else
                data.rarityBillboard.Adornee = billboardPart
                if data.rarityLabel then
                    data.rarityLabel.Text = rarityName
                    data.rarityLabel.TextColor3 = getRarityColor(data.record.AssetCategory)
                end
            end
        end
        if data.highlight and data.highlight.Parent then
            pcall(function()
                local color = getRarityColor(data.record.AssetCategory)
                data.highlight.FillColor = color
                data.highlight.OutlineColor = color
            end)
            return
        end
        pcall(function()
            local color = getRarityColor(data.record.AssetCategory)
            local hl = Instance.new("Highlight")
            hl.Name = "AxurEggESP"
            hl.Adornee = model
            hl.FillTransparency = 0.7
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.FillColor = color
            hl.OutlineColor = color
            hl.Parent = model
            data.highlight = hl
        end)
    end

    local function updateBeam()
        if not _G.DiabloState.espEnabled or not _G.DiabloState.bestEggUid then return end
        local data = _G.DiabloState.trackedEggs[_G.DiabloState.bestEggUid]
        if not data then return end
        local model = data.model
        if not model or not model.Parent then return end
        local basePart = data.basePart
        if not basePart or not basePart.Parent then
            basePart = getModelBasePart(model)
            data.basePart = basePart
            if not basePart then return end
        end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if not _G.DiabloState.espPlayerAttach or _G.DiabloState.espPlayerAttach.Parent ~= hrp then
            pcall(function() if _G.DiabloState.espPlayerAttach then _G.DiabloState.espPlayerAttach:Destroy() end end)
            _G.DiabloState.espPlayerAttach = Instance.new("Attachment")
            _G.DiabloState.espPlayerAttach.Name = "BestEggESP_PlayerAttachment"
            _G.DiabloState.espPlayerAttach.Parent = hrp
            if _G.DiabloState.espBeam then _G.DiabloState.espBeam.Attachment0 = _G.DiabloState.espPlayerAttach end
        end
        if not _G.DiabloState.espEggAttach or _G.DiabloState.espEggAttach.Parent ~= basePart then
            pcall(function() if _G.DiabloState.espEggAttach then _G.DiabloState.espEggAttach:Destroy() end end)
            _G.DiabloState.espEggAttach = Instance.new("Attachment")
            _G.DiabloState.espEggAttach.Name = "BestEggESP_EggAttachment"
            _G.DiabloState.espEggAttach.Parent = basePart
            if _G.DiabloState.espBeam then _G.DiabloState.espBeam.Attachment1 = _G.DiabloState.espEggAttach end
        end
        if not _G.DiabloState.espBeam or _G.DiabloState.espBeam.Parent == nil then
            _G.DiabloState.espBeam = Instance.new("Beam")
            _G.DiabloState.espBeam.Name = "BestEggESP_Tracer"
            _G.DiabloState.espBeam.FaceCamera = true
            _G.DiabloState.espBeam.LightEmission = 1
            _G.DiabloState.espBeam.LightInfluence = 0
            _G.DiabloState.espBeam.Width0 = 0.18
            _G.DiabloState.espBeam.Width1 = 0.18
            _G.DiabloState.espBeam.Transparency = NumberSequence.new(0)
            _G.DiabloState.espBeam.Segments = 12
            _G.DiabloState.espBeam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
            _G.DiabloState.espBeam.Parent = hrp
            _G.DiabloState.espBeam.Attachment0 = _G.DiabloState.espPlayerAttach
            _G.DiabloState.espBeam.Attachment1 = _G.DiabloState.espEggAttach
        end
    end

    local function syncEggs()
        if not EggState or not EggState.ReadFieldEggs then return end
        lastSyncTime = tick()
        local success, snapshot = pcall(EggState.ReadFieldEggs, EggState)
        if not success or not snapshot or not snapshot.Records then
            clearAll()
            return
        end

        local currentUids = {}
        for _, record in ipairs(snapshot.Records) do
            currentUids[record.Uid] = true
            if not _G.DiabloState.trackedEggs[record.Uid] then
                _G.DiabloState.trackedEggs[record.Uid] = {record = record, highlight = nil, rarityBillboard = nil, rarityLabel = nil, model = nil, basePart = nil}
            else
                _G.DiabloState.trackedEggs[record.Uid].record = record
            end
        end

        for uid in pairs(_G.DiabloState.trackedEggs) do
            if not currentUids[uid] then
                pcall(function() if _G.DiabloState.trackedEggs[uid].highlight then _G.DiabloState.trackedEggs[uid].highlight:Destroy() end end)
                pcall(function() if _G.DiabloState.trackedEggs[uid].rarityBillboard then _G.DiabloState.trackedEggs[uid].rarityBillboard:Destroy() end end)
                _G.DiabloState.trackedEggs[uid] = nil
                _G.DiabloState.modelCache[uid] = nil
                if _G.DiabloState.bestEggUid == uid then _G.DiabloState.bestEggUid = nil end
            end
        end

        for uid, data in pairs(_G.DiabloState.trackedEggs) do
            if not data.model or not data.model.Parent then
                local model = findEggModel(uid)
                if model then
                    data.model = model
                    data.basePart = getModelBasePart(model)
                end
            end
            if data.model and data.model.Parent then
                if _G.DiabloState.espEnabled then
                    ensureHighlight(uid)
                else
                    pcall(function() if data.highlight then data.highlight:Destroy() end end)
                    pcall(function() if data.rarityBillboard then data.rarityBillboard:Destroy() end end)
                    data.highlight = nil
                    data.rarityBillboard = nil
                    data.rarityLabel = nil
                end
            end
        end

        local newBest = findBestEgg(false)
        if newBest ~= _G.DiabloState.bestEggUid then
            _G.DiabloState.bestEggUid = newBest
            pcall(function() if _G.DiabloState.espEggAttach then _G.DiabloState.espEggAttach:Destroy() end end)
            _G.DiabloState.espEggAttach = nil
        end
    end

    EggTab:Section({ Title = "Egg Stealer", Icon = "egg", Opened = true })

    local EggRarityOptions = {
        "All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic",
        "Cosmic", "Secret", "Prismatic", "Eternal", "Transcendent",
        "Divine", "Celestial", "Titan"
    }

    EggTab:Dropdown({
        Title = "Priority rarities",
        Desc = "Choose which rarities the auto farms are allowed to collect.",
        Icon = "filter",
        Multi = true,
        Values = EggRarityOptions,
        Value = _G.DiabloState.EggRarityPriorities,
        Callback = function(selected)
            _G.DiabloState.EggRarityPriorities = selected or {}
            Memory.EggRarityPriorities = _G.DiabloState.EggRarityPriorities
        end,
    })

    local EggEspToggle = EggTab:Toggle({
        Title = "Egg ESP",
        Desc = "Shows every tracked egg with its rarity.",
        Icon = "eye",
        Type = "Toggle",
        Value = _G.DiabloState.espEnabled,
        Callback = function(value)
            _G.DiabloState.espEnabled = value
            Memory.EggEspEnabled = value
            if _G.DiabloState.espEnabled then
                syncEggs()
                if not _G.DiabloState.espLoopRunning then
                    _G.DiabloState.espLoopRunning = true
                    task.spawn(function()
                        while _G.DiabloState.espEnabled do
                            syncEggs()
                            task.wait(0.5)
                        end
                        _G.DiabloState.espLoopRunning = false
                    end)
                end
            else
                clearEspVisuals()
            end
        end,
    })

    local StealState = {
        IDLE = "IDLE",
        MOVING_TO_EGG = "MOVING_TO_EGG",
        COLLECTING = "COLLECTING",
        RETURNING = "RETURNING",
        DEPOSITING = "DEPOSITING",
        WAITING_RESET = "WAITING_RESET",
        WAITING = "WAITING",
        RAGDOLLED_RUSH = "RAGDOLLED_RUSH",
        MOVING_TO_BEST = "MOVING_TO_BEST",
        COLLECTING_BEST = "COLLECTING_BEST",
    }

    local currentStealState = StealState.IDLE
    local activeTween = nil
    local targetEggUid = nil
    local safePosition = Vector3.new(536.423340, 70.333313, -364.236969)
    local antiTrapPosition = Vector3.new(806, 167, -407)
    local tweenSpeed = 600
    local isCarryingEgg = false

    local function getReturnPosition()
        if _G.DiabloState.AntiTrapEnabled then
            return Vector3.new(safePosition.X, antiTrapPosition.Y, safePosition.Z)
        end
        return safePosition
    end

    local virtualAnchor = Instance.new("Part")
    virtualAnchor.Anchored = true
    virtualAnchor.CanCollide = false
    virtualAnchor.Transparency = 1
    virtualAnchor.Size = Vector3.new(1, 1, 1)
    virtualAnchor.Parent = workspace.Terrain

    local currentConnection = nil
    local tweenCancelled = false

    local AreaEggResetWall = safeRequire(ReplicatedStorage, "Client", "AreaEggResetWall")
    local EggStateModule = safeRequire(ReplicatedStorage, "Client", "EggState")

    local rawCarryState = false
    if EggStateModule and EggStateModule.CarryChanged then
        pcall(function()
            EggStateModule.CarryChanged:Connect(function(carryData)
                rawCarryState = carryData and carryData.IsCarrying == true
            end)
        end)
    end

    local function cancelActiveTween()
        tweenCancelled = true
        if activeTween then
            pcall(function() activeTween:Cancel() end)
            activeTween = nil
        end
        if currentConnection then
            pcall(function() currentConnection:Disconnect() end)
            currentConnection = nil
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end

    local function tweenCharacterTo(targetPos, speed, yOffset)
        cancelActiveTween()
        local char = LocalPlayer.Character
        if not char then return false end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end

        local dist = (hrp.Position - targetPos).Magnitude
        if dist < 3 then return true end

        tweenCancelled = false
        virtualAnchor.CFrame = hrp.CFrame

        local duration = math.max(dist / speed, 0.03)
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local targetCFrame = CFrame.new(targetPos + Vector3.new(0, yOffset or 3, 0)) * CFrame.Angles(0, math.atan2(
            targetPos.X - hrp.Position.X,
            targetPos.Z - hrp.Position.Z
        ), 0)

        activeTween = TweenService:Create(virtualAnchor, tweenInfo, {CFrame = targetCFrame})

        local completed = false
        currentConnection = RunService.Heartbeat:Connect(function()
            if not completed and not tweenCancelled and hrp and hrp.Parent and virtualAnchor and virtualAnchor.Parent then
                hrp.CFrame = virtualAnchor.CFrame
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end)

        activeTween.Completed:Connect(function()
            completed = true
            if currentConnection then
                pcall(function() currentConnection:Disconnect() end)
                currentConnection = nil
            end
            if hrp and hrp.Parent and not tweenCancelled then
                hrp.CFrame = targetCFrame
            end
            activeTween = nil
        end)

        activeTween:Play()
        return true
    end

    local function getLocalPlotTreadmillTarget()
        local plotState = _G.DiabloState.TreadmillPlotState
        if not plotState or type(plotState.ResolvePlot) ~= "function" then
            return nil, nil
        end

        local ok, plot = pcall(function()
            return plotState.ResolvePlot()
        end)
        if not ok or not plot or not plot.PlotFolder or not plot.PlotFolder.Parent then
            return nil, nil
        end

        local center = plot.CenterPoint
        local bestModel, bestPart, bestDist = nil, nil, math.huge
        if center and center:IsA("BasePart") then
            for _, inst in ipairs(plot.PlotFolder:GetDescendants()) do
                local name = string.lower(inst.Name)
                if name:find("treadmill", 1, true) then
                    local model = inst:IsA("Model") and inst or inst:FindFirstAncestorWhichIsA("Model")
                    if model and model:IsDescendantOf(plot.PlotFolder) then
                        local bp = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
                        if bp then
                            local dist = (bp.Position - center.Position).Magnitude
                            if dist < bestDist then
                                bestDist = dist
                                bestModel = model
                                bestPart = bp
                            end
                        end
                    elseif inst:IsA("BasePart") then
                        local dist = (inst.Position - center.Position).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            bestModel = nil
                            bestPart = inst
                        end
                    end
                end
            end
        end

        if bestPart and bestPart.Parent then
            return bestModel or bestPart, bestPart.Position
        end

        local fallback = center
        if not fallback or not fallback:IsA("BasePart") then
            local spawn = plot.PlotFolder:FindFirstChild("SpawnPoint", true)
            if spawn and spawn:IsA("BasePart") then
                fallback = spawn
            end
        end
        if fallback and fallback:IsA("BasePart") then
            return plot.PlotFolder, fallback.Position
        end

        if plot.RespawnPointCFrame then
            return plot.PlotFolder, plot.RespawnPointCFrame.Position
        end
        return nil, nil
    end

    local TREADMILL_SAFE_ROUTE_SPEED = 500
    local TREADMILL_FAR_DISTANCE = 150

    local function isTreadmillPathBlocked(char, target, targetObject)
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not target then
            return false
        end

        local origin = hrp.Position + Vector3.new(0, 2, 0)
        local destination = target + Vector3.new(0, 2, 0)
        local direction = destination - origin
        local directionMagnitude = direction.Magnitude

        if directionMagnitude <= 5 then
            return false
        end

        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {char}
        params.IgnoreWater = true

        local currentOrigin = origin
        local remainingDirection = direction

        for _ = 1, 6 do
            local result = Workspace:Raycast(currentOrigin, remainingDirection, params)
            if not result then
                return false
            end

            local hit = result.Instance
            if hit and hit:IsA("BasePart") then
                local remainingDistance = (destination - result.Position).Magnitude
                local isNearTarget = remainingDistance <= 15
                local belongsToTreadmill = targetObject and (
                    hit == targetObject or hit:IsDescendantOf(targetObject)
                )

                if hit.CanCollide and not isNearTarget and not belongsToTreadmill then
                    return true
                end
            end

            local traveled = (result.Position - currentOrigin).Magnitude
            local remaining = remainingDirection.Magnitude - traveled
            if remaining <= 1 then
                return false
            end

            currentOrigin = result.Position + remainingDirection.Unit * 0.5
            remainingDirection = destination - currentOrigin
        end

        return false
    end

    local function tweenToTreadmill()
        if not _G.DiabloState.AutoTreadmillEnabled then
            return false
        end

        local object, target = getLocalPlotTreadmillTarget()
        if not target then
            local finder = _G.DiabloState.FindLocalTreadmill
            if type(finder) == "function" then
                local ok, _, part = pcall(finder, true)
                if ok and part and part.Parent then
                    target = part.Position
                    object = part.Parent
                end
            end
        end
        if not target then
            return false
        end

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            return false
        end

        if TreadmillState.RouteStage == "TO_PLOT" then
            if (hrp.Position - target).Magnitude <= 12 then
                cancelActiveTween()
                TreadmillState.RouteStage = nil
                TreadmillState.AtStation = true
                useTreadmill()
                return true
            end

            TreadmillState.AtStation = false
            if activeTween then
                return false
            end

            return tweenCharacterTo(target, TREADMILL_SAFE_ROUTE_SPEED, 3)
        end

        local distance = (hrp.Position - target).Magnitude
        if distance <= 12 then
            cancelActiveTween()
            TreadmillState.RouteStage = nil
            TreadmillState.AtStation = true
            useTreadmill()
            return true
        end

        TreadmillState.AtStation = false
        if activeTween then
            return false
        end

        if distance >= TREADMILL_FAR_DISTANCE and isTreadmillPathBlocked(char, target, object) then
            TreadmillState.RouteStage = "TO_PLOT"

            if (hrp.Position - safePosition).Magnitude <= 12 then
                return tweenCharacterTo(target, TREADMILL_SAFE_ROUTE_SPEED, 3)
            end

            TreadmillState.RouteStage = "TO_SAFEZONE"
            return tweenCharacterTo(safePosition, TREADMILL_SAFE_ROUTE_SPEED, 3)
        end

        return tweenCharacterTo(target, math.max(_G.DiabloState.AutoStealSpeed or 1000, 1000), 3)
    end

    _G.DiabloState.TweenToTreadmill = tweenToTreadmill

    local function isAtPosition(pos, threshold)
        threshold = threshold or 5
        local char = LocalPlayer.Character
        if not char then return false end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        return (hrp.Position - pos).Magnitude <= threshold
    end

    local carryConfirmations = 0
    local CARRY_CONFIRM_THRESHOLD = 1
    local lastVerifiedCarry = false

    local function checkCarryingEgg()
        local detected = false

        if EggStateModule then
            local ok, carrying = pcall(function()
                if type(EggStateModule.IsCarrying) == "function" then
                    return EggStateModule:IsCarrying()
                elseif EggStateModule.CarryData then
                    return EggStateModule.CarryData.IsCarrying == true
                end
                return rawCarryState
            end)
            if ok and carrying then detected = true end
        elseif rawCarryState then
            detected = true
        end

        if not detected then
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        local name = tool.Name:lower()
                        if (name:find("area egg") or name:find("carryareaegg") or 
                            name == "egg" or name:find("^egg_") or name:find("_egg$")) then
                            detected = true
                            break
                        end
                    end
                end
            end
        end

        if not detected then
            local char = LocalPlayer.Character
            if char then
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        local name = tool.Name:lower()
                        if (name:find("area egg") or name:find("carryareaegg") or 
                            name == "egg" or name:find("^egg_") or name:find("_egg$")) then
                            detected = true
                            break
                        end
                    end
                end
            end
        end

        if detected then
            carryConfirmations = carryConfirmations + 1
        else
            carryConfirmations = 0
        end

        local verified = carryConfirmations >= CARRY_CONFIRM_THRESHOLD

        if verified ~= lastVerifiedCarry then
            lastVerifiedCarry = verified
            if verified then
            else
            end
        end

        return verified
    end

    local function resetCarryDetection()
        carryConfirmations = 0
        lastVerifiedCarry = false
    end

    local function instantFirePrompt(prompt)
        if not prompt or not prompt.Parent then return end
        pcall(function()
            local originalHold = prompt.HoldDuration
            prompt.HoldDuration = 0
            if fireproximityprompt then
                fireproximityprompt(prompt)
            else
                prompt:InputHoldBegin()
                task.wait(0.05)
                prompt:InputHoldEnd()
            end
            prompt.HoldDuration = originalHold
        end)
    end

    local function isAreaSealed()
        if AreaEggResetWall and AreaEggResetWall.IsSealed ~= nil then
            if type(AreaEggResetWall.IsSealed) == "function" then
                local ok, sealed = pcall(function() return AreaEggResetWall:IsSealed() end)
                if ok then return sealed end
            else
                return AreaEggResetWall.IsSealed
            end
        end
        return false
    end

    local function findBiggestEggAll()
        refreshCarriedEggsCache()
        local biggestUid, biggestSize = nil, -1
        for uid, data in pairs(_G.DiabloState.trackedEggs) do
            if data.model and data.model.Parent then
                if carriedEggsCache[uid] then continue end
                local size = getModelSizeScore(data.model)
                if size > biggestSize then
                    biggestSize = size
                    biggestUid = uid
                end
            end
        end
        return biggestUid, biggestSize
    end

    local function findNearestBigEgg()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local playerPos = hrp.Position
        local nearestUid, nearestDist = nil, math.huge

        refreshCarriedEggsCache()

        for uid, data in pairs(_G.DiabloState.trackedEggs) do
            if data.model and data.model.Parent then
                if carriedEggsCache[uid] then continue end
                local bp = data.basePart or getModelBasePart(data.model)
                if bp then
                    local dist = (playerPos - bp.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestUid = uid
                    end
                end
            end
        end
        return nearestUid, nearestDist
    end

    local isPlayerRagdolled

    local bigBestLocked = false
    local bigCurrentState = StealState.IDLE
    local bigTargetUid = nil
    local bigCollectionAttempts = 0
    local bigLastPromptFire = 0
    local bigPromptFireInterval = 0.08

    -- Fires the carry prompt of a tracked egg if we are in range.
    -- Returns: firedInRange (bool), updatedLastFireTime
    local function firePromptForUid(uid, lastFire, interval)
        local data = _G.DiabloState.trackedEggs[uid]
        if not data then return false, lastFire end
        local model = data.model
        local prompt = nil
        local promptPos = nil

        if model and model.Parent then
            prompt = getModelPrompt(model)
        end
        if not prompt then
            local bp = data.basePart or getModelBasePart(model)
            if bp then
                prompt = findPromptNearPosition(bp.Position, 30)
                if prompt and prompt.Parent then
                    promptPos = prompt.Parent.Position
                end
            end
        elseif prompt and prompt.Parent then
            promptPos = prompt.Parent.Position
        end

        if not prompt then return false, lastFire end

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and promptPos then
            local dist = (hrp.Position - promptPos).Magnitude
            if dist > (prompt.MaxActivationDistance + 5) then
                return false, lastFire
            end
        end

        local now = tick()
        if now - lastFire >= interval then
            instantFirePrompt(prompt)
            lastFire = now
        end
        return true, lastFire
    end

    local function runBigOnlyAutoSteal()
        bigBestLocked = false
        bigCurrentState = StealState.IDLE
        bigTargetUid = nil
        bigCollectionAttempts = 0

        while _G.DiabloState.bigOnlyAutoStealEnabled do
            local waitTime = 0.03

            syncEggs()

            local carrying = checkCarryingEgg()

            if isAreaSealed() then
                if bigCurrentState ~= StealState.WAITING_RESET then
                    bigCurrentState = StealState.WAITING_RESET
                    cancelActiveTween()
                end
                waitTime = 0.3
            elseif bigCurrentState == StealState.WAITING_RESET then
                bigCurrentState = StealState.IDLE
                bigTargetUid = nil
                bigCollectionAttempts = 0
                waitTime = 0.5
            elseif carrying then
                if bigCurrentState ~= StealState.RETURNING and bigCurrentState ~= StealState.DEPOSITING then
                    bigCurrentState = StealState.RETURNING
                    bigCollectionAttempts = 0
                    cancelActiveTween()
                    tweenCharacterTo(getReturnPosition(), _G.DiabloState.AutoStealSpeed)
                elseif bigCurrentState == StealState.RETURNING and isAtPosition(getReturnPosition(), 12) then
                    cancelActiveTween()
                    bigCurrentState = StealState.DEPOSITING
                else
                    waitTime = 0.1
                end
            elseif bigCurrentState == StealState.DEPOSITING then
                bigCurrentState = StealState.IDLE
                bigTargetUid = nil
                bigCollectionAttempts = 0
                resetCarryDetection()
                waitTime = 0.3
            else
                local biggestUid = findBiggestEggAll()

                if not biggestUid or not _G.DiabloState.trackedEggs[biggestUid] then
                    bigCurrentState = StealState.IDLE
                    bigTargetUid = nil
                    waitTime = 0.2
                else
                    bigTargetUid = biggestUid
                    local data = _G.DiabloState.trackedEggs[biggestUid]
                    local bp = data.basePart or getModelBasePart(data.model)
                    data.basePart = bp

                    if not bp or not bp.Parent or carriedEggsCache[biggestUid] then
                        bigTargetUid = nil
                        waitTime = 0.1
                    elseif isAtPosition(bp.Position, 8) then
                        bigCurrentState = StealState.COLLECTING_BEST
                        bigCollectionAttempts = bigCollectionAttempts + 1

                        if bigCollectionAttempts > 75 then
                            bigCollectionAttempts = 0
                            cancelActiveTween()
                            tweenCharacterTo(bp.Position + Vector3.new(2, 0, 2), 100000)
                        else
                            local fired, newLast = firePromptForUid(biggestUid, bigLastPromptFire, bigPromptFireInterval)
                            bigLastPromptFire = newLast
                            if not fired then
                                cancelActiveTween()
                                tweenCharacterTo(bp.Position, 100000)
                                bigCurrentState = StealState.MOVING_TO_BEST
                            end
                        end
                        waitTime = 0.08
                    else
                        bigCurrentState = StealState.MOVING_TO_BEST
                        if not activeTween then
                            tweenCharacterTo(bp.Position, 100000)
                        end
                        waitTime = 0.03
                    end
                end
            end

            task.wait(waitTime)
        end

        _G.DiabloState.bigOnlyLoopRunning = false
        cancelActiveTween()
        bigBestLocked = false
        bigCurrentState = StealState.IDLE
        bigTargetUid = nil
        bigCollectionAttempts = 0
        resetCarryDetection()
    end

    local EggBigOnlyToggle = EggTab:Toggle({
        Title = "Big Eggs Only",
        Desc = "Steals the biggiest balls in the current eggs.",
        Icon = "maximize",
        Type = "Toggle",
        Value = _G.DiabloState.eggBigOnly,
        Callback = function(value)
            _G.DiabloState.eggBigOnly = value
            Memory.EggBigOnly = value

            -- Mutual exclusivity: Big Only and Auto Steal Best cannot both be on
            if value then
                -- Force disable Auto Steal Best if it's on
                if _G.DiabloState.autoStealEnabled then
                    _G.DiabloState.autoStealEnabled = false
                    Memory.EggAutoStealEnabled = false
                    _G.DiabloState.autoLoopRunning = false
                    pcall(function()
                        if EggStealToggle and EggStealToggle.Set then
                            EggStealToggle:Set(false)
                        elseif EggStealToggle and EggStealToggle.SetValue then
                            EggStealToggle:SetValue(false)
                        end
                    end)
                    cancelActiveTween()
                    currentStealState = StealState.IDLE
                    targetEggUid = nil
                    targetEggScore = nil
                    collectionAttempts = 0
                    resetCarryDetection()
                end
                _G.DiabloState.bigOnlyAutoStealEnabled = true
                if not _G.DiabloState.bigOnlyLoopRunning then
                    _G.DiabloState.bigOnlyLoopRunning = true
                    task.spawn(runBigOnlyAutoSteal)
                end
            else
                _G.DiabloState.bigOnlyAutoStealEnabled = false
                cancelActiveTween()
                resetCarryDetection()
                bigCurrentState = StealState.IDLE
                bigTargetUid = nil
                bigTargetScore = nil
                bigCollectionAttempts = 0
                bigRushMode = false
            end

            syncEggs()
        end,
    })

    isPlayerRagdolled = function()
        local char = LocalPlayer.Character
        if not char then return true end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return true end

        -- Check PlatformStand (most common ragdoll indicator)
        if hum.PlatformStand then return true end

        -- Check humanoid state
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.FallingDown then
            return true
        end

        -- Check for Ragdolled attribute on character or humanoid
        if char:GetAttribute("Ragdolled") == true then return true end
        if hum:GetAttribute("Ragdolled") == true then return true end
        if char:GetAttribute("Ragdoll") == true then return true end
        if hum:GetAttribute("Ragdoll") == true then return true end

        -- Check if character has BallSocketConstraints (ragdoll joints)
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BallSocketConstraint") then
                return true
            end
        end

        -- Check if Motor6Ds are missing from key joints (ragdoll replaces them)
        local hasMotor6D = false
        local hasConstraint = false
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("Motor6D") then
                hasMotor6D = true
            elseif v:IsA("Constraint") then
                hasConstraint = true
            end
        end
        if hasConstraint and not hasMotor6D then
            return true
        end

        return false
    end

    local function findNearestEgg()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local playerPos = hrp.Position
        local nearestUid, nearestDist = nil, math.huge

        refreshCarriedEggsCache()

        for uid, data in pairs(_G.DiabloState.trackedEggs) do
            if data.model and data.model.Parent then
                if carriedEggsCache[uid] then continue end
                local bp = data.basePart or getModelBasePart(data.model)
                if bp then
                    local dist = (playerPos - bp.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestUid = uid
                    end
                end
            end
        end
        return nearestUid, nearestDist
    end

    local EggStealToggle = EggTab:Toggle({
        Title = "Auto Steal Best",
        Desc = "Steals best egg currently on the game",
        Icon = "mouse-pointer-click",
        Type = "Toggle",
        Value = _G.DiabloState.autoStealEnabled,
        Callback = function(value)
            _G.DiabloState.autoStealEnabled = value
            Memory.EggAutoStealEnabled = value

            -- Mutual exclusivity: Auto Steal Best and Big Only cannot both be on
            if value then
                if _G.DiabloState.bigOnlyAutoStealEnabled then
                    _G.DiabloState.bigOnlyAutoStealEnabled = false
                    Memory.EggBigOnly = false
                    _G.DiabloState.eggBigOnly = false
                    _G.DiabloState.bigOnlyLoopRunning = false
                    pcall(function()
                        if EggBigOnlyToggle and EggBigOnlyToggle.Set then
                            EggBigOnlyToggle:Set(false)
                        elseif EggBigOnlyToggle and EggBigOnlyToggle.SetValue then
                            EggBigOnlyToggle:SetValue(false)
                        end
                    end)
                    resetTreadmillPath()
                    cancelActiveTween()
                    resetCarryDetection()
                end
            end

            if not _G.DiabloState.autoStealEnabled then
                resetTreadmillPath()
                cancelActiveTween()
                currentStealState = StealState.IDLE
                targetEggUid = nil
                targetEggScore = nil
                collectionAttempts = 0
                resetCarryDetection()
                return
            end

            if _G.DiabloState.autoLoopRunning then return end
            _G.DiabloState.autoLoopRunning = true

            local targetUid = nil
            local collectionAttempts = 0
            local maxCollectionAttempts = 20
            local lastPromptFire = 0
            local promptFireInterval = 0.08
            local bestLocked = false
            local autoStealPhase = "NEAREST"
            currentStealState = StealState.IDLE
            targetUid = nil
            collectionAttempts = 0
            cancelActiveTween()

            task.spawn(function()
                while _G.DiabloState.autoStealEnabled do
                    local waitTime = 0.03

                    syncEggs()

                    if _G.DiabloState.AutoTreadmillEnabled and autoStealPhase == "TREADMILL" then
                        refreshTreadmillESP()
                    end

                    local carrying = checkCarryingEgg()
                    local ragdolled = isPlayerRagdolled()

                    if not carrying and autoStealPhase == "NEAREST" and currentStealState == StealState.IDLE then
                        refreshCarriedEggsCache()
                        if not hasPriorityEggAvailable() then
                            if _G.DiabloState.AutoTreadmillEnabled and not _G.DiabloState.bigOnlyAutoStealEnabled then
                                autoStealPhase = "TREADMILL"
                                currentStealState = StealState.IDLE
                                resetTreadmillPath()
                                cancelActiveTween()
                            else
                                cancelActiveTween()
                                waitTime = 0.25
                                task.wait(waitTime)
                                continue
                            end
                        end
                    end

                    if isAreaSealed() then
                        if currentStealState ~= StealState.WAITING_RESET then
                            currentStealState = StealState.WAITING_RESET
                            cancelActiveTween()
                        end
                        waitTime = 0.3
                    elseif currentStealState == StealState.WAITING_RESET then
                        currentStealState = StealState.IDLE
                        waitTime = 0.5
                    elseif autoStealPhase == "TREADMILL" then
                        if not _G.DiabloState.AutoTreadmillEnabled or _G.DiabloState.bigOnlyAutoStealEnabled then
                            resetTreadmillPath()
                            cancelActiveTween()
                            autoStealPhase = "NEAREST"
                            currentStealState = StealState.IDLE
                            waitTime = 0.1
                        elseif hasPriorityEggAvailable() then
                            stopTreadmill()
                            resetTreadmillPath()
                            cancelActiveTween()
                            autoStealPhase = "NEAREST"
                            currentStealState = StealState.IDLE
                            waitTime = 0.01
                        else
                            local atTreadmill = false
                            if type(_G.DiabloState.TweenToTreadmill) == "function" then
                                local ok, result = pcall(_G.DiabloState.TweenToTreadmill)
                                atTreadmill = ok and result == true
                            end
                            if atTreadmill then
                                useTreadmill()
                                refreshTreadmillESP()
                                waitTime = 0.15
                            else
                                refreshTreadmillESP()
                                waitTime = activeTween and 0.05 or 0.1
                            end
                        end
                    elseif autoStealPhase == "BEST" then
                        -- ============================================================
                        -- BEST LOCKED MODE
                        -- Once we rush for the best egg we STAY collecting the best
                        -- egg. If the best egg is lost we simply re-lock onto the
                        -- new best egg - we NEVER restart the nearest->best flow.
                        -- We ONLY go back to start (nearest loop) when the egg is
                        -- confirmed in our inventory (carrying == true) and it has
                        -- been returned/deposited.
                        -- ============================================================
                                            if carrying then
                            collectionAttempts = 0
                            if currentStealState ~= StealState.RETURNING and currentStealState ~= StealState.DEPOSITING then
                                currentStealState = StealState.RETURNING
                                cancelActiveTween()
                                tweenCharacterTo(getReturnPosition(), _G.DiabloState.AutoStealSpeed)
                            elseif currentStealState == StealState.RETURNING and isAtPosition(getReturnPosition(), 12) then
                                cancelActiveTween()
                                currentStealState = StealState.DEPOSITING
                            end
                                                                                    elseif currentStealState == StealState.DEPOSITING then
                            if carrying then
                                -- Still holding at return point, wait
                                waitTime = 0.1
                            else
                                -- Egg successfully returned: full reset to beginning cycle
                                bestLocked = false
                                autoStealPhase = "NEAREST"
                                currentStealState = StealState.IDLE
                                targetUid = nil
                                collectionAttempts = 0
                                resetCarryDetection()
                                waitTime = 0.3
                            end
                                            elseif currentStealState == StealState.RETURNING then
                            if carrying then
                                -- Egg still in inventory on return trip -> keep going
                                if isAtPosition(getReturnPosition(), 12) then
                                    cancelActiveTween()
                                    currentStealState = StealState.DEPOSITING
                                end
                            else
                                -- Egg lost on the way back -> re-rush best, do NOT restart nearest loop
                                cancelActiveTween()
                                autoStealPhase = "BEST"
                                currentStealState = StealState.RAGDOLLED_RUSH
                                targetUid = nil
                                collectionAttempts = 0
                                resetCarryDetection()
                            end
                            waitTime = 0.1

                        else
                            -- Collect the best egg as much as possible
                            refreshCarriedEggsCache()
                            local bestUid = findBestEgg(true)
                            if bestUid and _G.DiabloState.trackedEggs[bestUid] then
                                targetUid = bestUid
                                local data = _G.DiabloState.trackedEggs[bestUid]
                                local bp = data.basePart or getModelBasePart(data.model)
                                data.basePart = bp

                                if bp and bp.Parent then
                                    if carriedEggsCache[bestUid] then
                                        waitTime = 0.15
                                    elseif isAtPosition(bp.Position, 8) then
                                        currentStealState = StealState.COLLECTING_BEST
                                        collectionAttempts = collectionAttempts + 1
                                        if collectionAttempts > 75 then
                                            -- Prompt seems dead, nudge position but STAY locked
                                            collectionAttempts = 0
                                            cancelActiveTween()
                                            tweenCharacterTo(bp.Position + Vector3.new(2, 0, 2), 100000)
                                        else
                                            local fired, newLast = firePromptForUid(bestUid, lastPromptFire, promptFireInterval)
                                            lastPromptFire = newLast
                                            if not fired then
                                                cancelActiveTween()
                                                tweenCharacterTo(bp.Position, 100000)
                                                currentStealState = StealState.MOVING_TO_BEST
                                            end
                                        end
                                        waitTime = 0.08
                                    else
                                        currentStealState = StealState.MOVING_TO_BEST
                                        if not activeTween then
                                            tweenCharacterTo(bp.Position, 100000)
                                        end
                                        waitTime = 0.03
                                    end
                                else
                                    waitTime = 0.1
                                end
                            else
                                -- No best egg available right now. STAY locked,
                                -- never fall back to the nearest-egg loop.
                                waitTime = 0.2
                            end
                        end
                    else
                        -- ============================================================
                        -- NORMAL MODE: nearest egg first, wait, then lock best
                        -- ============================================================
                        if autoStealPhase == "NEAREST" and currentStealState == StealState.IDLE then
                            bestLocked = false
                            targetUid = nil
                            collectionAttempts = 0
                            local nearestUid = findNearestEgg()
                            if nearestUid and _G.DiabloState.trackedEggs[nearestUid] then
                                local data = _G.DiabloState.trackedEggs[nearestUid]
                                local bp = data.basePart or getModelBasePart(data.model)
                                data.basePart = bp
                                if bp then
                                    targetUid = nearestUid
                                    collectionAttempts = 0
                                    currentStealState = StealState.MOVING_TO_EGG
                                    tweenCharacterTo(bp.Position, 240)
                                end
                            else
                                waitTime = 0.2
                            end

                        elseif currentStealState == StealState.MOVING_TO_EGG then
                            if carrying then
                                currentStealState = StealState.WAITING
                                cancelActiveTween()
                            elseif not targetUid or not _G.DiabloState.trackedEggs[targetUid] or carriedEggsCache[targetUid] then
                                currentStealState = StealState.IDLE
                                cancelActiveTween()
                                targetUid = nil
                            else
                                local data = _G.DiabloState.trackedEggs[targetUid]
                                local bp = data.basePart
                                if bp and bp.Parent and isAtPosition(bp.Position, 8) then
                                    cancelActiveTween()
                                    collectionAttempts = 0
                                    currentStealState = StealState.COLLECTING
                                end
                            end

                        elseif currentStealState == StealState.COLLECTING then
                            if carrying then
                                collectionAttempts = 0
                                currentStealState = StealState.WAITING
                                cancelActiveTween()
                            elseif not targetUid or not _G.DiabloState.trackedEggs[targetUid] then
                                currentStealState = StealState.IDLE
                                cancelActiveTween()
                                targetUid = nil
                            else
                                collectionAttempts = collectionAttempts + 1
                                if collectionAttempts <= maxCollectionAttempts then
                                    local fired, newLast = firePromptForUid(targetUid, lastPromptFire, promptFireInterval)
                                    lastPromptFire = newLast
                                    if not fired then
                                        local data = _G.DiabloState.trackedEggs[targetUid]
                                        local bp = data.basePart or getModelBasePart(data.model)
                                        if bp then
                                            tweenCharacterTo(bp.Position, 240)
                                        end
                                    end
                                    waitTime = 0.08
                                else
                                    currentStealState = StealState.IDLE
                                    cancelActiveTween()
                                    targetUid = nil
                                    collectionAttempts = 0
                                end
                            end

                        elseif currentStealState == StealState.WAITING then
                            if ragdolled then
                                bestLocked = true
                                autoStealPhase = "BEST"
                                targetUid = nil
                                collectionAttempts = 0
                                currentStealState = StealState.RAGDOLLED_RUSH
                                cancelActiveTween()
                            end

                                                                                    elseif currentStealState == StealState.DEPOSITING then
                            if carrying then
                                -- Still holding at return point, wait
                                waitTime = 0.1
                            else
                                -- Egg successfully returned: full reset to beginning cycle
                                bestLocked = false
                                autoStealPhase = "NEAREST"
                                currentStealState = StealState.IDLE
                                targetUid = nil
                                collectionAttempts = 0
                                resetCarryDetection()
                                waitTime = 0.3
                            end
                                            elseif currentStealState == StealState.RETURNING then
                            if carrying then
                                -- Still returning with egg -> keep moving to return point
                                if isAtPosition(getReturnPosition(), 12) then
                                    cancelActiveTween()
                                    currentStealState = StealState.DEPOSITING
                                end
                            else
                                -- Egg lost on the way back -> re-rush best, do NOT restart at nearest
                                bestLocked = true
                                autoStealPhase = "BEST"
                                cancelActiveTween()
                                currentStealState = StealState.RAGDOLLED_RUSH
                                targetUid = nil
                                collectionAttempts = 0
                                resetCarryDetection()
                            end

                        end
                    end

                    task.wait(waitTime)
                end

                _G.DiabloState.autoLoopRunning = false
                resetTreadmillPath()
                cancelActiveTween()
                currentStealState = StealState.IDLE
                targetUid = nil
                collectionAttempts = 0
                resetCarryDetection()
            end)
        end,
    })
        if _G.DiabloState.espEnabled then updateBeam()
    end

    LocalPlayer.CharacterAdded:Connect(function()
        if _G.DiabloState.espEnabled then
            task.wait(0.5)
            pcall(function()
                if _G.DiabloState.espBeam then _G.DiabloState.espBeam.Attachment0 = nil end
                if _G.DiabloState.espPlayerAttach then _G.DiabloState.espPlayerAttach:Destroy(); _G.DiabloState.espPlayerAttach = nil end
            end)
        end
        if _G.DiabloState.autoStealEnabled then
            resetTreadmillPath()
            cancelActiveTween()
            currentStealState = StealState.IDLE
            targetEggUid = nil
            targetEggScore = nil
            collectionAttempts = 0
            isCarryingEgg = false
            rushMode = false
        end
        if _G.DiabloState.bigOnlyAutoStealEnabled then
            cancelActiveTween()
            bigCurrentState = StealState.IDLE
            bigTargetUid = nil
            bigTargetScore = nil
            bigCollectionAttempts = 0
            bigRushMode = false
        end
    end)

    _G.DiabloAutoTreadmillToggleCallback = function(value)
        _G.DiabloState.AutoTreadmillEnabled = value == true
        Memory.AutoTreadmillEnabled = _G.DiabloState.AutoTreadmillEnabled
        if _G.DiabloState.AutoTreadmillEnabled then
            task.spawn(function()
                task.wait(0.1)
                if _G.DiabloState.AutoTreadmillEnabled then
                    tweenToTreadmill()
                    startTreadmillLoop()
                    refreshTreadmillESP()
                end
            end)
        else
            stopTreadmill()
            resetTreadmillPath()
            cancelActiveTween()
        end
    end

    MainTab:Section({ Title = "Movement", Icon = "move", Opened = true })
    if _G.DiabloState.AutoTreadmillEnabled then
        task.spawn(function()
            task.wait(0.1)
            if _G.DiabloState.AutoTreadmillEnabled then
                tweenToTreadmill()
                startTreadmillLoop()
                refreshTreadmillESP()
            end
        end)
    end


    local SpeedInput = MainTab:Input({
        Title = "Walk Speed",
        Desc = "Set your desired movement speed.",
        InputIcon = "gauge",
        Value = tostring(_G.DiabloState.DesiredSpeed),
        Placeholder = "16",
        Callback = function(value)
            local num = tonumber(value)
            if num then
                _G.DiabloState.DesiredSpeed = num
                Memory.DesiredSpeed = num
                if _G.DiabloState.SpeedEnabled and _G.DiabloState.CurrentHumanoid then
                    pcall(function() _G.DiabloState.CurrentHumanoid.WalkSpeed = _G.DiabloState.DesiredSpeed end)
                end
            end
        end,
    })

    local SpeedBypassDropdown = MainTab:Dropdown({
        Title = "Speed Bypass Method",
        Desc = "Choose which bypass method to use for speed.",
        Icon = "settings-2",
        Values = {"Humanoid Clone", "GC Hook Bypass"},
        Value = _G.DiabloState.SpeedBypassMethod,
        Callback = function(value)
            _G.DiabloState.SpeedBypassMethod = value
            Memory.SpeedBypassMethod = value
            if _G.DiabloState.SpeedEnabled then
                stopNewBypass()
                task.wait(0.1)
                startNewBypass()
            end
        end,
    })

    local SpeedToggle = MainTab:Toggle({
        Title = "Speed Hack",
        Desc = "Enable custom walk speed.",
        Icon = "zap",
        Type = "Toggle",
        Value = _G.DiabloState.SpeedEnabled,
        Callback = function(value)
            _G.DiabloState.SpeedEnabled = value
            Memory.SpeedEnabled = value

            if _G.DiabloState.SpeedEnabled then
                startNewBypass()
            else
                stopNewBypass()
                if _G.DiabloState.CurrentHumanoid then
                    pcall(function() _G.DiabloState.CurrentHumanoid.WalkSpeed = 16 end)
                end
            end
        end,
    })

    local FlyInput = MainTab:Input({
        Title = "Fly Speed",
        Desc = "Set your flight speed.",
        InputIcon = "plane",
        Value = tostring(_G.DiabloState.FlySpeed),
        Placeholder = "50",
        Callback = function(value)
            local num = tonumber(value)
            if num then
                _G.DiabloState.FlySpeed = num
                Memory.FlySpeed = num
            end
        end,
    })

    local FlyToggle = MainTab:Toggle({
        Title = "Fly",
        Desc = "Enable noclip flight.",
        Icon = "plane",
        Type = "Toggle",
        Value = _G.DiabloState.FlyEnabled,
        Callback = function(value)
            _G.DiabloState.FlyEnabled = value
            Memory.FlyEnabled = value
            if _G.DiabloState.FlyEnabled then
                startFly()
            else
                stopFly()
            end
        end,
    })

    MainTab:Divider()

    MainTab:Section({ Title = "Combat / Physics", Icon = "shield", Opened = true })

    local AntiKnockbackToggle = MainTab:Toggle({
        Title = "Anti Knockback",
        Desc = "Prevents being flung.",
        Icon = "anchor",
        Type = "Toggle",
        Value = _G.DiabloState.AntiKnockbackEnabled,
        Callback = function(value)
            _G.DiabloState.AntiKnockbackEnabled = value
            Memory.AntiKnockbackEnabled = value
        end,
    })

    local AntiRagdollToggle = MainTab:Toggle({
        Title = "Anti Ragdoll",
        Desc = "Prevents ragdoll by either gaurd or player.",
        Icon = "user-x",
        Type = "Toggle",
        Value = _G.DiabloState.AntiRagdollEnabled,
        Callback = function(value)
            _G.DiabloState.AntiRagdollEnabled = value
            Memory.AntiRagdollEnabled = value
        end,
    })

    local InstantAccelToggle = MainTab:Toggle({
        Title = "Instant Acceleration",
        Desc = "Instantly reach max velocity when moving Dork.",
        Icon = "fast-forward",
        Type = "Toggle",
        Value = _G.DiabloState.InstantAccelerationEnabled,
        Callback = function(value)
            _G.DiabloState.InstantAccelerationEnabled = value
            Memory.InstantAccelerationEnabled = value
        end,
    })

    local AntiRejoinToggle = MainTab:Toggle({
        Title = "Anti Rejoin / Kick",
        Desc = "Blocks Kick and Teleport attempts.",
        Icon = "ban",
        Type = "Toggle",
        Value = _G.DiabloState.AntiRejoinEnabled,
        Callback = function(value)
            _G.DiabloState.AntiRejoinEnabled = value
            Memory.AntiRejoinEnabled = value
        end,
    })

    _G.DiabloAutoTreadmillToggle = MainTab:Toggle({
        Title = "Auto Treadmill",
        Desc = "Auto use Treadmill.",
        Icon = "footprints",
        Type = "Toggle",
        Value = _G.DiabloState.AutoTreadmillEnabled,
        Callback = _G.DiabloAutoTreadmillToggleCallback,
    })

    local BatAuraToggle = MainTab:Toggle({
        Title = "Bat Aura",
        Locked = true,
        Desc = "This doesnt work so fuh off it will be working once i work into this.",
        Icon = "swords",
        Type = "Toggle",
        Value = _G.DiabloState.BatAuraEnabled,
        Callback = function(value)
            _G.DiabloState.BatAuraEnabled = value
            Memory.BatAuraEnabled = value
            if _G.DiabloState.BatAuraEnabled then
                startBatAura()
            else
                stopBatAura()
            end
        end,
    })

    local AntiTrapToggle = EggTab:Toggle({
        Title = "Anti Trap",
        Desc = "anti trap if you cant understand this ur a bum.",
        Icon = "shield",
        Type = "Toggle",
        Value = _G.DiabloState.AntiTrapEnabled,
        Callback = function(value)
            _G.DiabloState.AntiTrapEnabled = value
            Memory.AntiTrapEnabled = value
        end,
    })

    MainTab:Divider()

    MainTab:Paragraph({
        Title = "Diablo Utility",
        Desc = "Script still on progress so expect more changes.",
        Icon = "info",
    })

    MainTab:Divider()

    MainTab:Section({ Title = "Avatar", Icon = "user", Opened = true })

    MainTab:Button({
        Title = "R6",
        Desc = "Execute R6 avatar script.",
        Icon = "person-standing",
        Callback = function()
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Methions/Thingsomething/refs/heads/main/R6"))()
            end)
            if not success then
                warn("[R6] Failed to execute: " .. tostring(err))
            end
        end,
    })


    -- ===================== AUTO SELL TAB =====================
    AdjustTab:Section({ Title = "Auto Steal", Icon = "zap", Opened = true })

    AdjustTab:Slider({
        Title = "Tween Speed",
        Desc = "For Returning eggs.",
        Icon = "gauge",
        Step = 10,
        Value = {
            Min = 100,
            Max = 1000,
            Default = _G.DiabloState.AutoStealSpeed,
        },
        Callback = function(value)
            _G.DiabloState.AutoStealSpeed = math.clamp(tonumber(value) or 1000, 100, 1000)
            Memory.AutoStealSpeed = _G.DiabloState.AutoStealSpeed
        end,
    })

    AutoSellTab:Section({ Title = "Auto Sell", Icon = "tag", Opened = true })

    local RarityOptions = {
        "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic",
        "Cosmic", "Secret", "Prismatic", "Eternal", "Transcendent",
        "Divine", "Celestial", "Titan"
    }

    local SellRarityDropdown = AutoSellTab:Dropdown({
        Title = "Sell Rarities",
        Desc = "Select which egg rarities to auto sell.",
        Icon = "filter",
        Multi = true,
        Values = RarityOptions,
        Value = _G.DiabloState.AutoSellRarities,
        Callback = function(selected)
            _G.DiabloState.AutoSellRarities = selected
            Memory.AutoSellRarities = selected
        end,
    })


    AutoSellTab:Toggle({
        Title = "Auto Sell",
        Desc = "Automatically sell eggs of selected rarities.",
        Icon = "tag",
        Type = "Toggle",
        Value = _G.DiabloState.AutoSellEnabled,
        Callback = function(value)
            _G.DiabloState.AutoSellEnabled = value
            Memory.AutoSellEnabled = value
        end,
    })

    SettingsTab:Section({ Title = "Window", Icon = "panel-top", Opened = true })

    SettingsTab:Button({
        Title = "Open Window",
        Desc = "Open Diablo immediately.",
        Icon = "panel-top-open",
        Callback = function()
            Window:Open()
        end,
    })

    SettingsTab:Button({
        Title = "Close Window",
        Desc = "Close Diablo UI.",
        Icon = "x",
        Callback = function()
            Window:Close()
        end,
    })

    SettingsTab:Keybind({
        Title = "UI Keybind",
        Desc = "Key to open/close the Diablo UI.",
        Icon = "keyboard",
        Value = "K",
        CanChange = true,
        Callback = function(key)
            Window:SetToggleKey(Enum.KeyCode[key])
        end,
    })

    SettingsTab:Divider()

    SettingsTab:Section({ Title = "About", Icon = "info", Opened = true })

    SettingsTab:Paragraph({
        Title = "Diablo",
        Desc = "ELLLLLLLLLLLLLLLLLLLLLLLLDIAAAAAAABLOOOOOOOO.",
        Icon = "zap",
    })

    local newBypassConnections = {}
    local newBypassCharConnection = nil

    -- ===================== GC HOOK BYPASS =====================
    local GCHookBypass = {
        RunService = RunService,
        Players = Players,
        speedconn = nil,
        hookedfunc3 = nil,
    }

    function GCHookBypass:collectgarbage()
        local s, r = pcall(function(...)
            return getgc()
        end)
        if s and r then
            return r    
        end
        return warn("failed to get garbage: "..tostring(r))
    end

    function GCHookBypass:safehook(f, c)
        local s, r = pcall(function(...)
            return hookfunction(f, newlclosure(c))
        end)
        if s and r then
            return r    
        end
        return warn("failed to hook function: "..tostring(r))
    end

    function GCHookBypass:findfunction(nups, linedefined)
        local s, r = pcall(function(...)
            for _, f in next, self:collectgarbage() do
                if typeof(f) == 'function' and islclosure(f) then
                    local upvs = debug.getupvalues(f)
                    local line = debug.info(f, "l")

                    if upvs and #upvs == nups and line == linedefined then
                        if nups == 10 then
                            local t = debug.getupvalue(f, 3)
                            if typeof(t) == "table" and rawget(t, "Humanoid") then
                                return f
                            end
                        else
                            return f
                        end
                    end
                end
            end
            return nil
        end)
        if s and r then
            return r
        end
        return nil
    end

    function GCHookBypass:init()
        self.LocalPlayer = self.Players.LocalPlayer
        if not self.LocalPlayer then
            return warn("failed to get localplayer")
        end

        if not getgc then
            self.LocalPlayer:Kick("UNSUPPORT EXECUTOR MISSING getgc")
        end

        if not hookfunction then
            self.LocalPlayer:Kick("UNSUPPORT EXECUTOR MISSING hookfunction")
        end

        if not islclosure then
            self.LocalPlayer:Kick("UNSUPPORT EXECUTOR MISSING islclosure")
        end

        local func3 = self:findfunction(19, 3)
        if not func3 then
            return warn("failed to get function 3")
        end

        local v7 = debug.getupvalue(func3, 2)
        if not v7 then
            return warn("failed to get v7")
        end

        self.hookedfunc3 = self:safehook(v7, function(p1, p2)
            if p2 and typeof(p2) == "table" then
                setmetatable(p2, {})
            end
            return self.hookedfunc3(p1,p2)
        end)

        self.speedconn = self.RunService.Heartbeat:Connect(function()
            local char = self.LocalPlayer.Character
            if not char then 
                return
            end
            local hum = char:FindFirstChild("Humanoid")
            if not hum then 
                return
            end
            hum.WalkSpeed = _G.DiabloState.DesiredSpeed
        end)

        warn("[GC Hook Bypass] Initialized")
        return true
    end

    function GCHookBypass:stop()
        if self.speedconn then
            pcall(function() self.speedconn:Disconnect() end)
            self.speedconn = nil
        end
        warn("[GC Hook Bypass] Stopped")
    end

    local function startGCHookBypass()
        GCHookBypass:init()
    end

    local function stopGCHookBypass()
        GCHookBypass:stop()
    end

    -- ===================== HUMANOID CLONE BYPASS =====================

    local function forceWalkSpeedNewBypass(humanoid)
        if newBypassConnections[humanoid] then
            pcall(function() newBypassConnections[humanoid]:Disconnect() end)
        end
        newBypassConnections[humanoid] = RunService.Heartbeat:Connect(function()
            if humanoid and humanoid.Parent then
                if humanoid.WalkSpeed ~= _G.DiabloState.DesiredSpeed then
                    humanoid.WalkSpeed = _G.DiabloState.DesiredSpeed
                end
            else
                if newBypassConnections[humanoid] then
                    newBypassConnections[humanoid]:Disconnect()
                    newBypassConnections[humanoid] = nil
                end
            end
        end)
    end

    local function applyNewBypass(character)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        local camera = workspace.CurrentCamera
        local animateScript = character:FindFirstChild("Animate")
        local jumpPower = humanoid.JumpPower
        local jumpHeight = humanoid.JumpHeight
        local health = humanoid.Health
        local maxHealth = humanoid.MaxHealth

        if animateScript and animateScript:IsA("LocalScript") then
            animateScript.Disabled = true
        end

        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in next, animator:GetPlayingAnimationTracks() do
                track:Stop(0)
            end
        end

        humanoid.Archivable = true
        local newHumanoid = humanoid:Clone()
        for _, child in next, newHumanoid:GetChildren() do
            if child:IsA("Animator") then
                child:Destroy()
            end
        end

        humanoid.Name = "_OldHumanoid"
        newHumanoid.Name = "Humanoid"
        newHumanoid.Parent = character

        local newAnimator = Instance.new("Animator")
        newAnimator.Parent = newHumanoid

        newHumanoid.WalkSpeed = _G.DiabloState.DesiredSpeed
        newHumanoid.JumpPower = jumpPower
        newHumanoid.JumpHeight = jumpHeight
        newHumanoid.MaxHealth = maxHealth
        newHumanoid.Health = math.min(health, maxHealth)

        if camera then
            camera.CameraSubject = newHumanoid
        end

        humanoid:Destroy()

        if animateScript and animateScript:IsA("LocalScript") then
            task.wait()
            animateScript.Disabled = false
            task.defer(function()
                if animateScript.Parent then
                    animateScript.Disabled = true
                    task.wait()
                    animateScript.Disabled = false
                end
            end)
        end

        task.defer(function()
            if newHumanoid.Parent then
                newHumanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)

        forceWalkSpeedNewBypass(newHumanoid)
        _G.DiabloState.CurrentHumanoid = newHumanoid
        return newHumanoid
    end

    local function setupNewBypass(character)
        character:WaitForChild("Humanoid")
        task.wait()
        applyNewBypass(character)
    end

    local function startHumanoidCloneBypass()
        if newBypassCharConnection then
            pcall(function() newBypassCharConnection:Disconnect() end)
        end
        newBypassCharConnection = player.CharacterAdded:Connect(function(char)
            if _G.DiabloState.SpeedEnabled then
                task.spawn(setupNewBypass, char)
            end
        end)
        if player.Character then
            task.spawn(setupNewBypass, player.Character)
        end
    end

    local function stopHumanoidCloneBypass()
        for hum, conn in pairs(newBypassConnections) do
            pcall(function() conn:Disconnect() end)
        end
        newBypassConnections = {}
        if newBypassCharConnection then
            pcall(function() newBypassCharConnection:Disconnect() end)
            newBypassCharConnection = nil
        end
    end

    local function startNewBypass()
        if _G.DiabloState.SpeedBypassMethod == "GC Hook Bypass" then
            startGCHookBypass()
        else
            startHumanoidCloneBypass()
        end
    end

    local function stopNewBypass()
        if _G.DiabloState.SpeedBypassMethod == "GC Hook Bypass" then
            stopGCHookBypass()
        else
            stopHumanoidCloneBypass()
        end
    end

    local function startFly()
        if _G.DiabloState.FlyConnection then
            _G.DiabloState.FlyConnection:Disconnect()
            _G.DiabloState.FlyConnection = nil
        end
        if _G.DiabloState.FlyBodyVelocity then
            _G.DiabloState.FlyBodyVelocity:Destroy()
            _G.DiabloState.FlyBodyVelocity = nil
        end
        if _G.DiabloState.FlyBodyGyro then
            _G.DiabloState.FlyBodyGyro:Destroy()
            _G.DiabloState.FlyBodyGyro = nil
        end

        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        _G.DiabloState.FlyBodyGyro = Instance.new("BodyGyro")
        _G.DiabloState.FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        _G.DiabloState.FlyBodyGyro.CFrame = hrp.CFrame
        _G.DiabloState.FlyBodyGyro.P = 9e4
        _G.DiabloState.FlyBodyGyro.Parent = hrp

        _G.DiabloState.FlyBodyVelocity = Instance.new("BodyVelocity")
        _G.DiabloState.FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        _G.DiabloState.FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        _G.DiabloState.FlyBodyVelocity.Parent = hrp

        _G.DiabloState.FlyConnection = RunService.RenderStepped:Connect(function()
            if not _G.DiabloState.FlyEnabled then return end
            if not (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then return end
            local currentHrp = player.Character.HumanoidRootPart
            local cam = workspace.CurrentCamera
            local direction = Vector3.new(0, 0, 0)

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end

            if direction.Magnitude > 0 then
                direction = direction.Unit * _G.DiabloState.FlySpeed
            end

            if _G.DiabloState.FlyBodyGyro and _G.DiabloState.FlyBodyGyro.Parent then
                _G.DiabloState.FlyBodyGyro.CFrame = cam.CFrame
            end
            if _G.DiabloState.FlyBodyVelocity and _G.DiabloState.FlyBodyVelocity.Parent then
                _G.DiabloState.FlyBodyVelocity.Velocity = direction
            end
        end)
    end

    local function stopFly()
        if _G.DiabloState.FlyConnection then
            _G.DiabloState.FlyConnection:Disconnect()
            _G.DiabloState.FlyConnection = nil
        end
        if _G.DiabloState.FlyBodyVelocity then
            _G.DiabloState.FlyBodyVelocity:Destroy()
            _G.DiabloState.FlyBodyVelocity = nil
        end
        if _G.DiabloState.FlyBodyGyro then
            _G.DiabloState.FlyBodyGyro:Destroy()
            _G.DiabloState.FlyBodyGyro = nil
        end
    end

    local kickHook
    kickHook = hookmetamethod(game, "__namecall", function(self, ...)
        if _G.DiabloState.AntiRejoinEnabled and not checkcaller() then
            local method = getnamecallmethod()
            if method == "Kick" and self == player then
                warn("[Anti Rejoin] Blocked kick attempt")
                return nil
            end
            if method == "Teleport" and self == TeleportService then
                warn("[Anti Rejoin] Blocked namecall teleport attempt")
                return nil
            end
            if method == "TeleportAsync" and self == TeleportService then
                warn("[Anti Rejoin] Blocked namecall TeleportAsync attempt")
                return nil
            end
            if method == "TeleportToPlaceInstance" and self == TeleportService then
                warn("[Anti Rejoin] Blocked namecall TeleportToPlaceInstance attempt")
                return nil
            end
        end
        return kickHook(self, ...)
    end)

    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local name = remote.Name:lower()
            if name:find("kick") or name:find("ban") or name:find("teleport") or name:find("rejoin") or name:find("hop") or name:find("server") then
                local oldName = remote.Name
            end
        end
    end



    local function storeJoints(character)
        joints = {}
        for _, joint in pairs(character:GetDescendants()) do
            if joint:IsA("Motor6D") then
                joints[joint.Name] = {
                    Part0 = joint.Part0,
                    Part1 = joint.Part1,
                    C0 = joint.C0,
                    C1 = joint.C1
                }
            end
        end
    end

    local function restoreJoints(character)
        for name, data in pairs(joints) do
            if data.Part0 and data.Part1 then
                local existing = data.Part0:FindFirstChild(name)
                if existing and existing:IsA("Motor6D") then
                    existing.Part0 = data.Part0
                    existing.Part1 = data.Part1
                    existing.C0 = data.C0
                    existing.C1 = data.C1
                elseif not existing then
                    local joint = Instance.new("Motor6D")
                    joint.Name = name
                    joint.Part0 = data.Part0
                    joint.Part1 = data.Part1
                    joint.C0 = data.C0
                    joint.C1 = data.C1
                    joint.Parent = data.Part0
                end
            end
        end
    end

    local function startAntiRagdoll(character)
        local humanoid = character:WaitForChild("Humanoid")
        storeJoints(character)

        if _G.DiabloState.ragdollConnection then
            _G.DiabloState.ragdollConnection:Disconnect()
        end

        _G.DiabloState.ragdollConnection = RunService.RenderStepped:Connect(function()
            if not _G.DiabloState.AntiRagdollEnabled then return end
            if not character.Parent then return end
            local state = humanoid:GetState()
            if state == Enum.HumanoidStateType.Physics or
            state == Enum.HumanoidStateType.Freefall or
            state == Enum.HumanoidStateType.Seated then
                pcall(function()
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    restoreJoints(character)
                end)
            end
        end)
    end

    local function onCharacterAdded(character)
        _G.DiabloState.CurrentHumanoid = character:FindFirstChildOfClass("Humanoid")
        if _G.DiabloState.CurrentHumanoid then
            if _G.DiabloState.SpeedEnabled then
                _G.DiabloState.CurrentHumanoid.WalkSpeed = _G.DiabloState.DesiredSpeed
            end
        end
        startAntiRagdoll(character)
        if _G.DiabloState.FlyEnabled then
            task.wait(0.5)
            startFly()
        end
    end

    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)

    RunService.Heartbeat:Connect(function()
        if _G.DiabloState.SpeedEnabled then
            if not _G.DiabloState.CurrentHumanoid or not _G.DiabloState.CurrentHumanoid:IsDescendantOf(game) then
                local char = player.Character
                if char then
                    _G.DiabloState.CurrentHumanoid = char:FindFirstChildOfClass("Humanoid")
                end
            end
            if _G.DiabloState.CurrentHumanoid then
                pcall(function() _G.DiabloState.CurrentHumanoid.WalkSpeed = _G.DiabloState.DesiredSpeed end)
            end
            if _G.DiabloState.InstantAccelerationEnabled then
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and _G.DiabloState.CurrentHumanoid then
                    pcall(function()
                        local moveDir = _G.DiabloState.CurrentHumanoid.MoveDirection
                        if moveDir.Magnitude > 0 then
                            local targetVel = moveDir.Unit * _G.DiabloState.DesiredSpeed
                            hrp.AssemblyLinearVelocity = Vector3.new(targetVel.X, hrp.AssemblyLinearVelocity.Y, targetVel.Z)
                        end
                    end)
                end
            end
        end
    end)

    RunService.Heartbeat:Connect(function()
        if not _G.DiabloState.AntiKnockbackEnabled then return end
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if not (hrp and hum) then return end

        if hum.MoveDirection.Magnitude == 0 then
            hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
        end
        hrp.RotVelocity = Vector3.new(0, 0, 0)
    end)

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            v.HoldDuration = 0
        end
    end

    workspace.DescendantAdded:Connect(function(v)
        if v:IsA("ProximityPrompt") then
            v.HoldDuration = 0
        end
    end)

    local DiabloUserBillboards = {}
    local DiabloUsersFolder = nil

    pcall(function()
        DiabloUsersFolder = ReplicatedStorage:FindFirstChild("DiabloUsers")
        if not DiabloUsersFolder then
            DiabloUsersFolder = Instance.new("Folder")
            DiabloUsersFolder.Name = "DiabloUsers"
            DiabloUsersFolder.Parent = ReplicatedStorage
        end
    end)

    if DiabloUsersFolder then
        local function attachBillboardToHead(targetPlayer, billboard)
            if not targetPlayer.Character then return false end
            local head = targetPlayer.Character:FindFirstChild("Head")
            if head then
                billboard.Parent = head
                return true
            end
            return false
        end

        local function createDiabloBillboard(targetPlayer)
            if targetPlayer == player then return end
            if DiabloUserBillboards[targetPlayer] then return end
            if not targetPlayer:IsDescendantOf(game) then return end

            local billboard = Instance.new("BillboardGui")
            billboard.Name = "DiabloUserIndicator"
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 150, 0, 42)
            billboard.StudsOffset = Vector3.new(0, 3.4, 0)
            billboard.LightInfluence = 0
            billboard.MaxDistance = 200
            billboard.ResetOnSpawn = false

            local bg = Instance.new("Frame")
            bg.Name = "Bg"
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
            bg.BackgroundTransparency = 0.12
            bg.BorderSizePixel = 0
            bg.Parent = billboard
            Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)

            local stroke = Instance.new("UIStroke", bg)
            stroke.Color = Color3.fromRGB(228, 91, 145)
            stroke.Thickness = 1.8

            local icon = Instance.new("TextLabel")
            icon.Name = "Icon"
            icon.Size = UDim2.new(0, 26, 1, 0)
            icon.Position = UDim2.new(0, 8, 0, 0)
            icon.BackgroundTransparency = 1
            icon.Text = "🔥"
            icon.TextSize = 17
            icon.Font = Enum.Font.GothamBold
            icon.TextColor3 = Color3.fromRGB(228, 91, 145)
            icon.Parent = bg

            local txt = Instance.new("TextLabel")
            txt.Name = "Text"
            txt.Size = UDim2.new(1, -40, 1, 0)
            txt.Position = UDim2.new(0, 32, 0, 0)
            txt.BackgroundTransparency = 1
            txt.Text = "Diablo User"
            txt.TextSize = 14
            txt.Font = Enum.Font.GothamBold
            txt.TextColor3 = Color3.fromRGB(240, 240, 245)
            txt.Parent = bg

            DiabloUserBillboards[targetPlayer] = billboard

            if not attachBillboardToHead(targetPlayer, billboard) then
                local charConn
                charConn = targetPlayer.CharacterAdded:Connect(function()
                    task.wait(0.2)
                    if attachBillboardToHead(targetPlayer, billboard) then
                        charConn:Disconnect()
                    end
                end)
            end

            local respawnConn = targetPlayer.CharacterAdded:Connect(function()
                task.wait(0.2)
                attachBillboardToHead(targetPlayer, billboard)
            end)

            targetPlayer.AncestryChanged:Connect(function()
                if not targetPlayer:IsDescendantOf(game) then
                    pcall(function() respawnConn:Disconnect() end)
                    if billboard and billboard.Parent then
                        billboard:Destroy()
                    end
                    DiabloUserBillboards[targetPlayer] = nil
                end
            end)

            pcall(function()
                WindUI:Notify({
                    Title = "Diablo",
                    Content = targetPlayer.Name .. " is also using Diablo!",
                    Icon = "users",
                    Duration = 4,
                })
            end)
        end

        local function removeDiabloBillboard(targetPlayer)
            if DiabloUserBillboards[targetPlayer] then
                pcall(function() DiabloUserBillboards[targetPlayer]:Destroy() end)
                DiabloUserBillboards[targetPlayer] = nil
            end
        end

        local function onUserMarkerAdded(marker)
            local userId = tonumber(marker.Name)
            if not userId or userId == player.UserId then return end
            local targetPlayer = Players:GetPlayerByUserId(userId)
            if targetPlayer then
                createDiabloBillboard(targetPlayer)
            end
        end

        local function onUserMarkerRemoved(marker)
            local userId = tonumber(marker.Name)
            if not userId then return end
            local targetPlayer = Players:GetPlayerByUserId(userId)
            if targetPlayer then
                removeDiabloBillboard(targetPlayer)
            end
        end

        local myMarkerName = tostring(player.UserId)
        local existingMarker = DiabloUsersFolder:FindFirstChild(myMarkerName)
        if existingMarker then
            pcall(function() existingMarker:Destroy() end)
        end

        local myMarker = Instance.new("BoolValue")
        myMarker.Name = myMarkerName
        myMarker.Value = true
        myMarker.Parent = DiabloUsersFolder

        for _, marker in ipairs(DiabloUsersFolder:GetChildren()) do
            onUserMarkerAdded(marker)
        end

        DiabloUsersFolder.ChildAdded:Connect(onUserMarkerAdded)
        DiabloUsersFolder.ChildRemoved:Connect(onUserMarkerRemoved)

        Players.PlayerRemoving:Connect(function(plr)
            if plr == player then
                pcall(function()
                    local m = DiabloUsersFolder:FindFirstChild(myMarkerName)
                    if m then m:Destroy() end
                end)
            else
                removeDiabloBillboard(plr)
            end
        end)
    end

    local batAuraConnection = nil
    local batAuraLastSwing = 0

    local BatAuraSwingRemote = nil
    local BatAuraToolGameplayGuard = nil

    local function initBatAuraRefs()
        BatAuraSwingRemote = nil
        BatAuraToolGameplayGuard = nil

        local packages = ReplicatedStorage:FindFirstChild("Packages")
        if not packages then
            warn("[Bat Aura] Packages folder not found in ReplicatedStorage")
            return false
        end

        local networking = packages:FindFirstChild("Networking")
        if not networking then
            warn("[Bat Aura] Networking folder not found in Packages")
            return false
        end

        BatAuraSwingRemote = networking:FindFirstChild("RE/BatSwing/Trigger")
        if not BatAuraSwingRemote then
            warn("[Bat Aura] RE/BatSwing/Trigger remote not found")
            return false
        end

        local client = ReplicatedStorage:FindFirstChild("Client")
        if client then
            local guardModule = client:FindFirstChild("ToolGameplayGuard")
            if guardModule then
                local ok, result = pcall(require, guardModule)
                if ok and result then
                    BatAuraToolGameplayGuard = result
                else
                    warn("[Bat Aura] ToolGameplayGuard require failed: " .. tostring(result))
                end
            else
                warn("[Bat Aura] ToolGameplayGuard module not found")
            end
        else
            warn("[Bat Aura] Client folder not found")
        end

        return true
    end

    local function batAuraCreateSeed()
        local s, r = pcall(function()
            return ("%*:%*:%*"):format(LocalPlayer.UserId, 100, math.floor(Workspace:GetServerTimeNow() * 1000))
        end)
        if s and r then return r end
        return nil
    end

    local function batAuraCanUseTool()
        local s, r = pcall(function()
            local c = LocalPlayer.Character
            if not c then return false end

            local t = c:FindFirstChildOfClass("Tool")
            if not t or t:GetAttribute("ItemType") ~= "Gear" then
                return false
            end

            local h = c:FindFirstChild("HumanoidRootPart")
            if not h then return false end

            if BatAuraToolGameplayGuard and BatAuraToolGameplayGuard.IsLocalInsideArena then
                local n = not BatAuraToolGameplayGuard.IsLocalInsideArena()
                if n then return false end
            end

            if Workspace:GetAttribute("Event_MonsterEvent") then
                return -268 < h.Position.Z
            end
            return true
        end)
        if s and r then return r end
        return false
    end

    local function batAuraGetClosestPlayer()
        local c = nil
        local cd = math.huge
        for _, p in next, Players:GetPlayers() do
            if p == LocalPlayer then continue end
            local char = p.Character
            if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            local dist = LocalPlayer:DistanceFromCharacter(hrp.Position)
            if dist < cd and dist <= 16.5 then
                cd = dist
                c = p
            end
        end
        return c
    end

    local function batAuraAttack(targetPlayer)
        if not BatAuraSwingRemote then return end
        local s, r = pcall(function()
            return BatAuraSwingRemote:FireServer(targetPlayer, batAuraCreateSeed())
        end)
        if not s then
            warn("[Bat Aura] Attack error: " .. tostring(r))
        end
    end

    local function startBatAura()
        if batAuraConnection then
            pcall(function() batAuraConnection:Disconnect() end)
            batAuraConnection = nil
        end

        if not initBatAuraRefs() then
            warn("[Bat Aura] Initialization failed. Toggle off and on again after game loads fully.")
            return
        end

        batAuraConnection = RunService.Heartbeat:Connect(function()
            if not _G.DiabloState.BatAuraEnabled then return end
            if not BatAuraSwingRemote then return end

            local now = tick()
            if now - batAuraLastSwing < 0.1 then return end

            local target = batAuraGetClosestPlayer()
            if not target then return end

            if batAuraCanUseTool() then
                batAuraAttack(target)
                batAuraLastSwing = now
            end
        end)

        warn("[Bat Aura] Started")
    end

    local function stopBatAura()
        if batAuraConnection then
            pcall(function() batAuraConnection:Disconnect() end)
            batAuraConnection = nil
        end
        warn("[Bat Aura] Stopped")
    end

    if _G.DiabloState.BatAuraEnabled then
        task.spawn(function()
            task.wait(2)
            startBatAura()
        end)
    end

    if _G.DiabloState.SpeedEnabled then
        startNewBypass()
    end

    local AutoSellUtility = {
        ReplicatedStorage = game:GetService("ReplicatedStorage")
    }

    function AutoSellUtility:init()
        self.Shared = self.ReplicatedStorage:FindFirstChild("Shared")
        if not self.Shared then
            return warn("[Auto Sell] failed to get Shared")
        end

        self.Data = self.ReplicatedStorage:FindFirstChild("Data")
        if not self.Data then
            return warn("[Auto Sell] failed to get Data")
        end

        self.Save = require(self.Shared:FindFirstChild("Save"))
        if not self.Save then
            return warn("[Auto Sell] failed to get Save")
        end

        self.Assets = require(self.Data:FindFirstChild("Assets"))
        if not self.Assets then
            return warn("[Auto Sell] failed to get Assets")
        end

        self.Packages = self.ReplicatedStorage:FindFirstChild("Packages")
        if not self.Packages then
            return warn("[Auto Sell] failed to get Packages")
        end

        self.Networking = self.Packages:FindFirstChild("Networking")
        if not self.Networking then
            return warn("[Auto Sell] failed to get Networking")
        end

        self.AskWearTool = self.Networking:FindFirstChild("RF/EggWorld/AskWearTool")
        if not self.AskWearTool then
            return warn("[Auto Sell] failed to get RF/EggWorld/AskWearTool")
        end

        self.SellPet = self.Networking:FindFirstChild("RE/PetSatchel/SellPet")
        if not self.SellPet then
            return warn("[Auto Sell] failed to get RE/PetSatchel/SellPet")
        end

        task.spawn(function()
            while true do
                task.wait(1)
                if not _G.DiabloState.AutoSellEnabled then continue end

                local success, err = pcall(function()
                    local data = self.Save.Get()
                    if not data then return end
                    local inv = data.EggInventory
                    if not inv then return end

                    for Uid, eggdata in next, inv do
                        if not _G.DiabloState.AutoSellEnabled then break end
                        if eggdata.Placement then continue end

                        local assetInfo = self.Assets.Directory[eggdata.AssetCategory]
                        if not assetInfo then continue end
                        local rarity = assetInfo.Rarity
                        if not rarity then continue end

                        local rarityName = rarity.DisplayName or rarity.Name or "Unknown"
                        if table.find(_G.DiabloState.AutoSellRarities, rarityName) then
                            pcall(function()
                                self.AskWearTool:InvokeServer(Uid)
                            end)
                            task.wait(0.05)
                            pcall(function()
                                self.SellPet:FireServer({Uid})
                            end)
                            task.wait(0.1)
                        end
                    end
                end)

                if not success then
                    warn("[Auto Sell] Error: " .. tostring(err))
                end
            end
        end)

        warn("[Auto Sell] Initialized successfully")
    end

    AutoSellUtility:init()

    _G.DiabloUpgradeUtility = _G.DiabloUpgradeUtility or {
        ReplicatedStorage = ReplicatedStorage,
    }

    function _G.DiabloUpgradeUtility:GetTreadmils()
        local s, r = pcall(function()
            local d = self.Save.Get()
            local o = {}
            if not d or not self.Treadmills then return o end
            local l = d.TreadmillUpgradeLevel
            for id, t in next, self.Treadmills.Directory do
                if self.Treadmills.GetUpgradeLevel(id) > l and self.CanAfford(d.Money, t.Price) then
                    table.insert(o, id)
                end
            end
            return o
        end)
        if s and r then return r end
        return nil
    end

    function _G.DiabloUpgradeUtility:GetBaseUpgradeable()
        local s, r = pcall(function()
            local d = self.Save.Get()
            if not d then return false end
            local l = d.BaseUpgradeLevel + 1
            local n = self.Bases.BASES[l]
            if not n then return false end
            return self.CanAfford(d.Money, n.Cost)
        end)
        if s and r then return r end
        return false
    end

    function _G.DiabloUpgradeUtility:GetTrails()
        local s, r = pcall(function()
            local d = self.Save.Get()
            local o = {}
            if not d or not self.Trails then return o end
            for _, trial in next, self.Trails.Directory do
                if not d.TrailInventory[trial._id] and self.CanAfford(d.Money, trial.Price) then
                    table.insert(o, trial._id)
                end
            end
            return o
        end)
        if s and r then return r end
        return nil
    end

    _G.DiabloUpgradeUtility.CanAfford = function(m, c)
        local s, r = pcall(function()
            return m >= c
        end)
        if s and r then return r end
        return false
    end

    function _G.DiabloUpgradeUtility:Purchase(remote, id)
        local s, r = pcall(function()
            return remote:InvokeServer(id)
        end)
        if s and r then return r end
        return false
    end

    function _G.DiabloUpgradeUtility:Init()
        self.Data = self.ReplicatedStorage:FindFirstChild("Data")
        if not self.Data then return warn("Couldnt get data") end

        self.Treadmills = require(self.Data:FindFirstChild("Treadmills"))
        if not self.Treadmills then return warn("failed to get Treadmills") end

        self.Trails = require(self.Data:FindFirstChild("Trails"))
        if not self.Trails then return warn("Couldnt get Trails") end

        self.Bases = require(self.Data:FindFirstChild("Bases"))
        if not self.Bases then return warn("Couldnt get Bases") end

        self.Shared = self.ReplicatedStorage:FindFirstChild("Shared")
        if not self.Shared then return warn("couldnt get Shared") end

        self.Save = require(self.Shared:FindFirstChild("Save"))
        if not self.Save then return warn("couldnt get Save") end

        self.Packages = self.ReplicatedStorage:FindFirstChild("Packages")
        if not self.Packages then return warn("couldnt get Packages") end

        self.Networking = self.Packages:FindFirstChild("Networking")
        if not self.Networking then return warn("couldnt get Networking") end

        self["RF/Trailwear/AskPurchase"] = self.Networking:FindFirstChild("RF/Trailwear/AskPurchase")
        if not self["RF/Trailwear/AskPurchase"] then return warn("couldnt get RF/Trailwear/AskPurchase") end

        self["RF/Treadmill/AskTierRaise"] = self.Networking:FindFirstChild("RF/Treadmill/AskTierRaise")
        if not self["RF/Treadmill/AskTierRaise"] then return warn("couldnt get RF/Treadmill/AskTierRaise") end

        self["RE/Homestead/AskBaseTierRaise"] = self.Networking:FindFirstChild("RE/Homestead/AskBaseTierRaise")
        if not self["RE/Homestead/AskBaseTierRaise"] then return warn("couldnt get RE/Homestead/AskBaseTierRaise") end

        if self._Running then return true end
        self._Running = true

        task.spawn(function()
            while task.wait(0.1) do
                local trials = self:GetTrails()
                if typeof(trials) == "table" then
                    for _, trail in next, trials do
                        self:Purchase(self["RF/Trailwear/AskPurchase"], trail)
                        task.wait(0.1)
                    end
                end

                local treadmils = self:GetTreadmils()
                if typeof(treadmils) == "table" then
                    for _, treadmil in next, treadmils do
                        self:Purchase(self["RF/Treadmill/AskTierRaise"], treadmil)
                        task.wait(0.1)
                    end
                end

                if self:GetBaseUpgradeable() then
                    pcall(function()
                        self["RE/Homestead/AskBaseTierRaise"]:FireServer()
                    end)
                end
            end
        end)
        return true
    end

    _G.DiabloUpgradeUtility:Init()

    wait(5)
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    -- Guardamos la posición original de las articulaciones
    local joints = {}
    for _, joint in pairs(character:GetDescendants()) do
        if joint:IsA("Motor6D") then
            joints[joint.Name] = {Part0 = joint.Part0, Part1 = joint.Part1, C0 = joint.C0, C1 = joint.C1}
        end
    end

    -- Función para restaurar joints
    local function restoreJoints()
        for name, data in pairs(joints) do
            if data.Part0:FindFirstChild(name) == nil then
                local joint = Instance.new("Motor6D")
                joint.Name = name
                joint.Part0 = data.Part0
                joint.Part1 = data.Part1
                joint.C0 = data.C0
                joint.C1 = data.C1
                joint.Parent = data.Part0
            end
        end
    end

    -- Previene la caída (ragdoll) cada frame
    game:GetService("RunService").RenderStepped:Connect(function()
        if humanoid:GetState() == Enum.HumanoidStateType.Physics or
        humanoid:GetState() == Enum.HumanoidStateType.Freefall or
        humanoid:GetState() == Enum.HumanoidStateType.Seated then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
            restoreJoints()
        end
    end)
