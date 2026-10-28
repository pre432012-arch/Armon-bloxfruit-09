--[[
getgenv().Configs = {
	Team = "Pirates",
	FixLag = false,
	FPS = 60,
	WhiteScreen = false,
	Godhuman = true,
	Saber = true,
	CursedDualKatana = true,
	SkullGuitar = true,
	RaceV3 = true
}
--]]

local Config = getgenv().Configs

local LogCache = {}
local function LogChange(key, message)
	if LogCache[key] ~= message then
		LogCache[key] = message
		print(message)
	end
end

print("waiting for game...")
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer
print("game loaded")

local TweenService = cloneref(game:GetService("TweenService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local CoreGui = cloneref(game:GetService("CoreGui"))
local VirtualInputManager = game:GetService("VirtualInputManager")
local CommF_ = ReplicatedStorage.Remotes.CommF_
local CommE = ReplicatedStorage.Remotes.CommE
local MaxLevel = (workspace:GetAttribute("LEVEL_CAP") or 2800)
CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(v)
	if v.Name == "ErrorPrompt" and v:FindFirstChild("MessageArea") and v.MessageArea:FindFirstChild("ErrorFrame") then
		ReplicatedStorage.__ServerBrowser:InvokeServer("teleport", game.JobId)
	end
end)
game.NetworkClient.ChildRemoved:Connect(function()
	ReplicatedStorage.__ServerBrowser:InvokeServer("teleport", game.JobId)
	task.wait(5)
	TeleportService:Teleport(game.PlaceId)
end)

TeleportService.TeleportInitFailed:Connect(function(player, result, err)
	if result ~= Enum.TeleportResult.GameFull then
		ReplicatedStorage.__ServerBrowser:InvokeServer("teleport", game.JobId)
	end
end)

if Config.WhiteScreen then
	RunService:Set3dRenderingEnabled(false)
	print("white screen applied")
end
if Config.FixLag then
	pcall(function()
		for _,v in pairs(Lighting:GetChildren()) do
			if v:IsA("PostEffect") then
				v.Enabled = false
			end
		end
		local function optimize(obj)
			if obj:IsA("BasePart") then
				obj.Material = Enum.Material.Plastic
				obj.Reflectance = 0
			elseif obj:IsA("Decal") or obj:IsA("Texture") then
				obj:Destroy()
			elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
				obj.Enabled = false
			elseif obj:IsA("Explosion") then
				obj.BlastPressure = 0
				obj.BlastRadius = 0
			end
		end
		for _,v in pairs(game:GetDescendants()) do
			optimize(v)
		end
		game.DescendantAdded:Connect(optimize)
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 9e9
		Lighting.Brightness = 0
		Lighting.EnvironmentDiffuseScale = 0
		Lighting.EnvironmentSpecularScale = 0
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		for _, v in workspace.Map:GetDescendants() do
			if v:IsA('BasePart') and v.Transparency ~= 1 then
				v.Transparency = 1
			end
		end
	end)
	print("lag fix applied")
end

if Config.FPS then
	setfpscap(Config.FPS)
	print("fps cap set to " .. Config.FPS)
end

print("waiting for team...")

if not LocalPlayer.Team then
	repeat task.wait()
		CommF_:InvokeServer("SetTeam", Configs.Team)
	until LocalPlayer.Team
end
print("waiting for character...")
repeat task.wait(0.1) until LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
print("character ready")

print("team selected")

task.wait(2.5)

pcall(function() require(ReplicatedStorage.Util.CameraShaker):Stop() end)

print("camera shaker disabled")

print("initializing...")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
LocalPlayer.CharacterAdded:Connect(function(v)
	Character = v
	print("character respawned")
end)

pcall(function()
	LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
		if child.Name == "SpinnerWindow" then
			child:Destroy()
		end
	end)
	workspace.ChildAdded:Connect(function(df)
		if df:IsA('Tool') then
			df:Destroy()
		end
	end)
end)

task.spawn(function()
	while true do
		local hrp = Character:FindFirstChild("HumanoidRootPart")
		if hrp and not hrp:FindFirstChild("fixvelo") then
			local bv = Instance.new("BodyVelocity")
			bv.Name = "fixvelo"
			bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.P = 1000
			bv.Parent = hrp
		end
		task.wait(0.5)
	end
end)

RunService.Stepped:Connect(function()
	if Character ~= nil then
		for _, child in Character:GetDescendants() do
			if child:IsA("BasePart") and child.CanCollide == true then
				child.CanCollide = false
			end
		end
	end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KaitunUIKrita"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer.PlayerGui

local uiScale = Instance.new("UIScale")
uiScale.Scale = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X < 700) and 0.78 or 1
uiScale.Parent = ScreenGui
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        uiScale.Scale = workspace.CurrentCamera.ViewportSize.X < 700 and 0.78 or 1
    end)
end

local frame = Instance.new("Frame")
frame.Name = "AccountPanel"
frame.Size = UDim2.new(0, 600, 0, 330)
frame.Position = UDim2.new(0.5, -300, 0.5, -165)
frame.BackgroundColor3 = Color3.fromRGB(3, 9, 23)
frame.BackgroundTransparency = 0.03
frame.BorderSizePixel = 0
frame.Parent = ScreenGui
local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 24)
local edge = Instance.new("UIStroke", frame)
edge.Color = Color3.fromRGB(83, 190, 255)
edge.Thickness = 2
edge.Transparency = 0.08
local panelGradient = Instance.new("UIGradient", frame)
panelGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(3, 11, 28)),
    ColorSequenceKeypoint.new(0.55, Color3.fromRGB(2, 7, 19)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 20, 42))
})
panelGradient.Rotation = 18

local topBar = Instance.new("Frame", frame)
topBar.Name = "TopBar"
topBar.Active = true
topBar.Size = UDim2.new(1, -28, 0, 54)
topBar.Position = UDim2.new(0, 14, 0, 10)
topBar.BackgroundTransparency = 1
local logo = Instance.new("ImageLabel", frame)
logo.Name = "Logo"
logo.BackgroundColor3 = Color3.fromRGB(7, 21, 42)
logo.BackgroundTransparency = 0
logo.Position = UDim2.new(0, 20, 0, 72)
logo.Size = UDim2.new(0, 150, 0, 174)
logo.Image = "rbxassetid://87840957911768"
logo.ScaleType = Enum.ScaleType.Crop
logo.BorderSizePixel = 0
local logoCorner = Instance.new("UICorner", logo)
logoCorner.CornerRadius = UDim.new(0, 18)
local logoStroke = Instance.new("UIStroke", logo)
logoStroke.Color = Color3.fromRGB(77, 185, 255)
logoStroke.Thickness = 2

local heading = Instance.new("TextLabel", topBar)
heading.BackgroundTransparency = 1
heading.Position = UDim2.new(0, 6, 0, 0)
heading.Size = UDim2.new(1, -54, 0, 30)
heading.Font = Enum.Font.GothamBold
heading.Text = "ArMONHUB  |  ACCOUNT STATS"
heading.TextColor3 = Color3.fromRGB(244, 249, 255)
heading.TextSize = 20
heading.TextXAlignment = Enum.TextXAlignment.Left
heading.TextTruncate = Enum.TextTruncate.AtEnd
local playerName = Instance.new("TextLabel", topBar)
playerName.BackgroundTransparency = 1
playerName.Position = UDim2.new(0, 7, 0, 29)
playerName.Size = UDim2.new(1, -50, 0, 20)
playerName.Font = Enum.Font.GothamMedium
playerName.Text = "@" .. LocalPlayer.Name
playerName.TextColor3 = Color3.fromRGB(171, 194, 219)
playerName.TextSize = 12
playerName.TextXAlignment = Enum.TextXAlignment.Left
local closeButton = Instance.new("TextButton", topBar)
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 32, 0, 32)
closeButton.Position = UDim2.new(1, -34, 0, 1)
closeButton.BackgroundColor3 = Color3.fromRGB(17, 34, 57)
closeButton.Text = "×"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 25
closeButton.TextColor3 = Color3.fromRGB(225, 241, 255)
closeButton.AutoButtonColor = true
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 10)

local separator = Instance.new("Frame", frame)
separator.Position = UDim2.new(0, 190, 0, 70)
separator.Size = UDim2.new(1, -220, 0, 1)
separator.BackgroundColor3 = Color3.fromRGB(58, 91, 125)
separator.BackgroundTransparency = 0.2
separator.BorderSizePixel = 0

local statusDot = Instance.new("Frame", frame)
statusDot.Position = UDim2.new(0, 192, 0, 87)
statusDot.Size = UDim2.new(0, 7, 0, 7)
statusDot.BackgroundColor3 = Color3.fromRGB(49, 183, 255)
statusDot.BorderSizePixel = 0
Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)
local title = Instance.new("TextLabel", frame)
title.Name = "StatusLabel"
title.Position = UDim2.new(0, 207, 0, 78)
title.Size = UDim2.new(1, -225, 0, 25)
title.BackgroundTransparency = 1
title.Text = "initializing"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(75, 184, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextTruncate = Enum.TextTruncate.AtEnd

local function makeStat(text, x, y, width, size, color)
    local label = Instance.new("TextLabel", frame)
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, x, 0, y)
    label.Size = UDim2.new(0, width, 0, 30)
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(226, 239, 255)
    label.TextSize = size or 17
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    return label
end
local levelLabel = makeStat("Lv. --", 192, 112, 170, 19, Color3.fromRGB(90, 190, 255))
local moneyLabel = makeStat("$ --", 390, 112, 170, 19, Color3.fromRGB(90, 190, 255))
local fragmentsLabel = makeStat("♦ --", 192, 154, 170, 17, Color3.fromRGB(117, 202, 255))
local raceLabel = makeStat("RACE: --", 390, 154, 170, 17, Color3.fromRGB(117, 202, 255))
local itemsLabel = Instance.new("TextLabel", frame)
itemsLabel.BackgroundTransparency = 1
itemsLabel.Position = UDim2.new(0, 192, 0, 195)
itemsLabel.Size = UDim2.new(1, -218, 0, 35)
itemsLabel.Font = Enum.Font.GothamMedium
itemsLabel.Text = "ITEMS  •  loading..."
itemsLabel.TextColor3 = Color3.fromRGB(155, 181, 211)
itemsLabel.TextSize = 11
itemsLabel.TextXAlignment = Enum.TextXAlignment.Left
itemsLabel.TextYAlignment = Enum.TextYAlignment.Top
itemsLabel.TextWrapped = true
local footer = Instance.new("TextLabel", frame)
footer.BackgroundTransparency = 1
footer.Position = UDim2.new(0, 20, 1, -34)
footer.Size = UDim2.new(0.65, 0, 0, 20)
footer.Font = Enum.Font.GothamBold
footer.Text = "LIVE DATA  •  AUTO UPDATE"
footer.TextColor3 = Color3.fromRGB(100, 139, 178)
footer.TextSize = 10
footer.TextXAlignment = Enum.TextXAlignment.Left
local timeLabel = Instance.new("TextLabel", frame)
timeLabel.Name = "UptimeLabel"
timeLabel.BackgroundTransparency = 1
timeLabel.Position = UDim2.new(1, -210, 1, -36)
timeLabel.Size = UDim2.new(0, 190, 0, 22)
timeLabel.Font = Enum.Font.GothamSemibold
timeLabel.Text = "UPTIME: 00:00:00"
timeLabel.TextColor3 = Color3.fromRGB(131, 163, 195)
timeLabel.TextSize = 11
timeLabel.TextXAlignment = Enum.TextXAlignment.Right

local toggleButton = Instance.new("ImageButton", ScreenGui)
toggleButton.Name = "OpenCloseButton"
toggleButton.Size = UDim2.new(0, 54, 0, 54)
toggleButton.Position = UDim2.new(0, 16, 0.5, -27)
toggleButton.BackgroundColor3 = Color3.fromRGB(4, 16, 34)
toggleButton.Image = "rbxassetid://87840957911768"
toggleButton.ScaleType = Enum.ScaleType.Crop
toggleButton.AutoButtonColor = true
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)
local toggleStroke = Instance.new("UIStroke", toggleButton)
toggleStroke.Color = Color3.fromRGB(73, 190, 255)
toggleStroke.Thickness = 2
local panelOpen = true
local logoWasDragged = false
local function setPanelOpen(open)
    panelOpen = open
    frame.Visible = open
end
closeButton.Activated:Connect(function() setPanelOpen(false) end)
toggleButton.Activated:Connect(function()
    if logoWasDragged then
        logoWasDragged = false
        return
    end
    setPanelOpen(not panelOpen)
end)

-- Allow the panel and floating logo button to be moved independently.
local UserInputService = game:GetService("UserInputService")
local logoDragging, logoDragStart, logoStartPosition, logoDragInput
local logoMoved = false
local function isPointerInput(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end
toggleButton.InputBegan:Connect(function(input)
    if isPointerInput(input) then
        logoDragging = true
        logoMoved = false
        logoDragStart = input.Position
        logoStartPosition = toggleButton.Position
        if input.UserInputType == Enum.UserInputType.Touch then
            logoDragInput = input
        end
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                logoDragging = false
                if logoMoved then logoWasDragged = true end
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if logoDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input == logoDragInput) then
        local delta = input.Position - logoDragStart
        if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then
            logoMoved = true
        end
        if logoMoved then
            toggleButton.Position = UDim2.new(
                logoStartPosition.X.Scale,
                logoStartPosition.X.Offset + delta.X,
                logoStartPosition.Y.Scale,
                logoStartPosition.Y.Offset + delta.Y
            )
        end
    end
end)

-- Allow the panel to be moved by dragging its header.
local dragging, dragStart, startPosition
 topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end)

local startedAt = os.clock()
function SetStatus(text)
    local status = string.lower(tostring(text))
    if title.Text ~= status then
        print("ui: " .. status)
    end
    title.Text = status
end
task.spawn(function()
    while ScreenGui.Parent do
        pcall(function()
            local data = LocalPlayer:FindFirstChild("Data")
            if data then
                local level = data:FindFirstChild("Level")
                local money = data:FindFirstChild("Beli") or data:FindFirstChild("Money")
                local fragments = data:FindFirstChild("Fragments")
                local race = data:FindFirstChild("Race")
                if level then levelLabel.Text = "Lv. " .. tostring(level.Value) end
                if money then moneyLabel.Text = "$" .. tostring(money.Value):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") end
                if fragments then fragmentsLabel.Text = "♦ " .. tostring(fragments.Value) end
                if race then raceLabel.Text = "RACE: " .. tostring(race.Value) end
            end
            local found = {}
            local function addTools(container)
                if container then
                    for _, item in ipairs(container:GetChildren()) do
                        if item:IsA("Tool") and #found < 4 then table.insert(found, item.Name) end
                    end
                end
            end
            addTools(LocalPlayer:FindFirstChild("Backpack"))
            addTools(Character)
            itemsLabel.Text = "ITEMS  •  " .. (#found > 0 and table.concat(found, " / ") or "none detected")
            local elapsed = math.floor(os.clock() - startedAt)
            timeLabel.Text = string.format("UPTIME: %02d:%02d:%02d", math.floor(elapsed / 3600), math.floor(elapsed / 60) % 60, elapsed % 60)
        end)
        task.wait(1)
    end
end)
print("ui initialized")

pcall(function()
    assert(getrawmetatable)
    local grm = getrawmetatable(game)
    setreadonly(grm, false)
    local old = grm.__namecall
    grm.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local name = tostring(args[1])
        for _, remote in ipairs({"TeleportDetect", "CHECKER_1", "CHECKER", "GUI_CHECK", "OneMoreTime", "checkingSPEED", "BANREMOTE", "PERMAIDBAN", "KICKREMOTE", "BR_KICKPC", "BR_KICKMOBILE"}) do
            if name == remote then
                return
            end
        end
        return old(self, ...)
    end)
end)

print("anti anticheat initialized")

local function EquipTool(v)
	Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(v))
end

local function EquipWeapon(type)
	if not type then
		type = "Melee"
	end
	for _, v in LocalPlayer.Backpack:GetChildren() do
		if v.ToolTip == type then
			if not Character:FindFirstChild("HasBuso") then
				CommF_:InvokeServer("Buso")
			end
			Character.Humanoid:EquipTool(v)
			return
		end
	end
end

local function HasItem(name)
	if not Character then
		return
	end
	return Character:FindFirstChild(name) or LocalPlayer.Backpack:FindFirstChild(name)
end

local function CheckItem(Name)
	local data = IRS:GetItems(KEYS.QUANTITY)
	for _, v in data do
		local item = MATCH(v.ItemId)._ok
		local c = item.Display.Category
		if (c == "Sword" or c == "Gun" or c == "Accessory") and item.Index.StorageKey == Name then
			return true
		end
	end
	return false
end

local tw, conn
local function StopTween()
	if tw then
        LogChange("tween_stop", "tween: stopped")
		tw:Cancel()
		tw = nil
	end
	if conn then
		conn:Disconnect()
		conn = nil
	end
	local r = Character and Character:FindFirstChild("Root")
	if r then
		r:Destroy()
	end
end

local World = {}
World.Sea1 = function()
	return require(ReplicatedStorage.Util.Realm).getCurrentSeaAsync() == "Sea1"
end
World.Sea2 = function()
	return require(ReplicatedStorage.Util.Realm).getCurrentSeaAsync() == "Sea2"
end
World.Sea3 = function()
	return require(ReplicatedStorage.Util.Realm).getCurrentSeaAsync() == "Sea3"
end

local LastTravel = 0

local function RunTween(v, high)
    while not Character or not Character.PrimaryPart or not Character:FindFirstChild("Humanoid") do
        LogChange("tween_wait", "tween: waiting for character")
        task.wait()
    end
    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        LogChange("tween_root", "tween: root missing")
        return
    end
    if typeof(v) == "CFrame" then
        v = v.Position
    end
    Character.Humanoid.Sit = false
    local targetCFrame = typeof(v) == "Vector3" and CFrame.new(v) or v
    local pos = targetCFrame.Position + Vector3.new(0, high or 0, 0)
    local rot = rootPart.CFrame - rootPart.Position
    local finalCFrame = CFrame.new(pos) * rot
    local distance = (rootPart.Position - finalCFrame.Position).Magnitude
    local speed
    if distance < 250 then
        speed = 285
    elseif distance < 500 then
        speed = 260
    elseif distance < 1000 then
        speed = 240
    else
        speed = 200
    end
    local travelTime = distance / speed
    if distance >= 1000 then
        LogChange("long_tween", "tween: long travel")
    end
    tw = TweenService:Create(rootPart, TweenInfo.new(travelTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { CFrame = finalCFrame })
    tw:Play()
    return tw
end
local function BreakClouds()
	if workspace.Map:FindFirstChild("Sky") then
		for _, v in workspace.Map.Sky:GetChildren() do
			if v:IsA("MeshPart") and v.Name == "cloud" and (Vector3.new(-4208.15869140625, 1089.8868408203125, -373.052490234375) - v.Position).Magnitude < 50 and not v:GetAttribute("Broken") then
				EquipWeapon()
                Character.HumanoidRootPart:PivotTo(v.CFrame)
				task.wait(0.25)
				ReplicatedStorage.Modules.Net["RE/RegisterAttack"]:FireServer(0.4)
				ReplicatedStorage.Modules.Net["RE/RegisterHit"]:FireServer(v)
                task.wait(0.5)
			end
		end
	end
end
local function SmartTween(t)
    if World.Sea3() then
        if not CheckItem("Valkyrie Helm") then
            LogChange("entrance_block", "travel: missing valkyrie helm")
            return
        end
    end
    if typeof(t) == "CFrame" then
        t = t.Position
    end
    while not Character or not Character.PrimaryPart or not Character:FindFirstChild("Humanoid") do
        task.wait()
    end
    local _is
    if World.Sea3() then
        _is = {
			{ Vector3.new(-5027.0302734375, 316.5475769042969, -3206.70361328125), Vector3.new(5650.94775390625, 1017.2747802734375, -350.37918090820312) },
            { Vector3.new(5650.94775390625, 1017.2747802734375, -350.37918090820312), Vector3.new(-5027.0302734375, 316.5475769042969, -3206.70361328125) },
            { Vector3.new(-12463.6025390625, 378.32705688476562, -7566.0830078125), Vector3.new(-5060.41162109375, 316.5475769042969, -3193.224853515625) },
            { Vector3.new(-5060.41162109375, 318.50201416015625, -3193.224853515625), Vector3.new(-12463.6025390625, 376.3725280761719, -7566.0830078125) },
        }
    elseif World.Sea2() then
        _is = {
            { Vector3.new(-390, 332, 673), Vector3.new(-390, 332, 673) },
            { Vector3.new(2285, 15, 905), Vector3.new(2285, 15, 905) },
            { Vector3.new(923, 126, 32852), Vector3.new(923, 126, 32852) },
            { Vector3.new(-6509, 83, -133), Vector3.new(-6509, 83, -133) },
        }
    elseif World.Sea1() then
        _is = {
			{ Vector3.new(61163.8515625, 11.6796875, 1819.7841796875), Vector3.new(4050.31103515625, -1.6880035400390625, -1814.1240234375) },
            { Vector3.new(3864.8515625, 6.6796875, -1926.7841796875), Vector3.new(61170.046875, -2, 1952.833984375) },
            { Vector3.new(-4166.60986328125, 1093.697998046875, -347.16226196289062), Vector3.new(-6020.27734375, 5469.15625, 2209.776123046875) },
        }
    else
        return
    end

    local min = nil
    local pos = 1
    for i, v in ipairs(_is) do
        local distanceToTarget = (t - v[1]).Magnitude
        if min == nil then
            min = distanceToTarget
        else
            if distanceToTarget < min then
                min = distanceToTarget
                pos = i
            end
        end
    end
    local dist = LocalPlayer:DistanceFromCharacter(t)
	local disttotp = LocalPlayer:DistanceFromCharacter(_is[pos][2])
    if (min + disttotp) < dist and (tick() - LastTravel) >= 1 then
        LastTravel = tick()
        print("travel: using entrance")
        tw = RunTween(_is[pos][2])
        if tw then
            tw.Completed:Wait()
        end
		task.wait(0.25)
		print("travel: requesting entrance")
		task.wait(0.25)
		if not CollectionService:HasTag(LocalPlayer, "Teleporting") then
			CommF_:InvokeServer("requestEntrance", _is[pos][1])
		end
		repeat task.wait() until (LocalPlayer:DistanceFromCharacter(_is[pos][1]) < LocalPlayer:DistanceFromCharacter(_is[pos][2]))
        print("travel: entrance reached")
        task.wait(0.25)
    end
end
local function Tween(v, speed, high)
    while not Character or not Character.PrimaryPart or not Character:FindFirstChild("Humanoid") do
        task.wait()
    end
    SmartTween(v)
    return RunTween(v, high)
end

local function WaitForAliveCharacter()
    while true do
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if character and humanoid and humanoid.Health > 0 and root then
            return character, humanoid, root
        end
        task.wait(0.1)
    end
end

local function TweenWithRespawnRetry(target, speed, high)
    while true do
        local currentCharacter = LocalPlayer.Character
        local currentHumanoid = currentCharacter and currentCharacter:FindFirstChildOfClass("Humanoid")
        local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
        if not currentCharacter or not currentHumanoid or currentHumanoid.Health <= 0 or not currentRoot then
            LogChange("respawn_wait", "tween: waiting for respawn")
        end
        local startCharacter, humanoid, root = WaitForAliveCharacter()
        LogChange("respawn_wait", "tween: character ready")
        local died = false
        local activeTween = nil

        local diedConnection = humanoid.Died:Connect(function()
            died = true
            if activeTween then
                pcall(function()
                    activeTween:Cancel()
                end)
            end
        end)

        local ok, tweenOrError = pcall(function()
            return Tween(target, speed, high)
        end)

        if ok and tweenOrError then
            activeTween = tweenOrError

            local finished = false
            local playbackState = nil
            local completedConnection = activeTween.Completed:Connect(function(state)
                playbackState = state
                finished = true
            end)

            local currentState = activeTween.PlaybackState
            if currentState == Enum.PlaybackState.Completed or currentState == Enum.PlaybackState.Cancelled then
                playbackState = currentState
                finished = true
            end

            if died then
                pcall(function()
                    activeTween:Cancel()
                end)
            end

            while not finished do
                task.wait(0.05)
            end

            completedConnection:Disconnect()
            diedConnection:Disconnect()

            local currentCharacter = LocalPlayer.Character
            local stillSameCharacter = currentCharacter == startCharacter
                and humanoid.Parent ~= nil
                and humanoid.Health > 0
                and root.Parent ~= nil
                and not died

            if not stillSameCharacter then
                print("tween: retry after respawn")
                task.wait(0.1)
            elseif playbackState == Enum.PlaybackState.Completed then
                LogChange("tween_result", "tween: complete")
                return true
            else
                LogChange("tween_result", "tween: cancelled")
                return false
            end
        else
            diedConnection:Disconnect()
            local characterChanged = LocalPlayer.Character ~= startCharacter
            if died or characterChanged or humanoid.Health <= 0 or not root.Parent then
                task.wait(0.1)
            else
                if not ok then
                    warn("tween retry failed: " .. tostring(tweenOrError))
                end
                return false
            end
        end
    end
end

task.spawn(function()
	while true do
		pcall(function()
			local char = LocalPlayer.Character
			if char and char.PrimaryPart and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
				CommE:FireServer("Dodge", nil, 30, true, workspace:GetServerTimeNow())
			end
		end)
		task.wait(2.5)
	end
end)

task.spawn(function()
	while task.wait(0.5) do
		for _, v in LocalPlayer.PlayerGui:GetDescendants() do
			if v:IsA("TextLabel") and v.Text:find("Confront the prisoner") then
				local BonusMomentsRemoteFunction = ReplicatedStorage.Remotes.BonusMomentsRemoteFunction
				BonusMomentsRemoteFunction:InvokeServer("Escape from Alcatraz", "Provoke", "Puncher")
				BonusMomentsRemoteFunction:InvokeServer("Escape from Alcatraz", "Provoke", "Digger")
				BonusMomentsRemoteFunction:InvokeServer("Escape from Alcatraz", "Provoke", "Raft")
				local success, controllerModule = pcall(require,  ReplicatedStorage.Controllers.BonusMomentsController)
				if success and type(controllerModule) == "table" and rawget(controllerModule, "GetLoadedMoments") then
					local loadedMoments = controllerModule:GetLoadedMoments()
					for momentName, momentInstance in pairs(loadedMoments) do
						if type(momentInstance) == "table" then
							if type(momentInstance.Trove and momentInstance.Trove.Clean) == "function" then
								pcall(function() momentInstance.Trove:Clean() end)
							end
							if type(momentInstance._MainMaid and momentInstance._MainMaid.DoCleaning) == "function" then
								pcall(function() momentInstance._MainMaid:DoCleaning() end)
							end
							if type(momentInstance._Maid and momentInstance._Maid.DoCleaning) == "function" then
								pcall(function() momentInstance._Maid:DoCleaning() end)
							end
						end
						loadedMoments[momentName] = nil
					end
				end
			end
		end
	end
end)

local function TeleportSeabeast(c5)
	local a = Vector3.new(0, c5:FindFirstChild("HumanoidRootPart").Position.Y, 0)
	local ab = Vector3.new(0, workspace.Map["WaterBase-Plane"].Position.Y, 0)
	if (a - ab).Magnitude <= 175 then
		Tween(c5.HumanoidRootPart.CFrame * CFrame.new(0, 300, 50), 280).Completed:Wait()
	else
		Tween(CFrame.new(c5.HumanoidRootPart.Position.X,workspace.Map["WaterBase-Plane"].Position.Y + 200,c5.HumanoidRootPart.Position.Z),280).Completed:Wait()
	end
end

local function CheckPirateBoat()
	for _, v in workspace.Enemies:GetChildren() do
		if table.find({"PirateBasic","PirateBrigade"}, v.Name) and v:FindFirstChild("Health") and v.Health.Value > 0 then
			return v
		end
	end
end

local function CheckSeabeast()
	if not workspace:FindFirstChild("SeaBeasts") then
		return
	end
	for _, v in workspace.SeaBeasts:GetChildren() do
		if v.Name == "SeaBeast1" then
			if v.Health.Value >= 34500 then
				return v
			end
		end
	end
	return false
end

local function CheckBoat()
	for _, v in workspace.Boats:GetChildren() do
		if v:IsA("Model") then
			if v:FindFirstChild("Owner") and tostring(v.Owner.Value) == LocalPlayer.Name and v.Humanoid.Value > 0 and v:FindFirstChild("Engine") then
				if LocalPlayer:DistanceFromCharacter(v.Engine.CFrame.Position) <= 1750 then
					return v
				end
			end
		end
	end
	return false
end

local function GetElite()
	for _, v in {"Diablo", "Deandre", "Urban", "Tyrant of the Skies"} do
		local e = ReplicatedStorage:FindFirstChild(v) or workspace.Enemies:FindFirstChild(v)
		if e and e:FindFirstChild("Humanoid") then
			if e.Humanoid.Health > 0 then
				return e
			end
		end
	end
	return false
end

local r, id
for _, v in {ReplicatedStorage.Util, ReplicatedStorage.Common, ReplicatedStorage.Remotes, ReplicatedStorage.Assets, ReplicatedStorage.FX} do
	for _, n in v:GetChildren() do
		if n:IsA("RemoteEvent") and n:GetAttribute("Id") then
			r, id = n, n:GetAttribute("Id")
		end
	end
	v.ChildAdded:Connect(function(n)
		if n:IsA("RemoteEvent") and n:GetAttribute("Id") then
			r, id = n, n:GetAttribute("Id")
		end
	end)
end

local function Attack()
	local char = Character
	local parts = {}
	for _, v in workspace.Enemies:GetChildren() do
		local hrp = v:FindFirstChild("HumanoidRootPart")
		local hum = v:FindFirstChild("Humanoid")
		if v ~= char and hrp and hum and hum.Health > 0 and LocalPlayer:DistanceFromCharacter(hrp.Position) <= 35 then
			for _, _v in v:GetChildren() do
				if _v:IsA("BasePart") and LocalPlayer:DistanceFromCharacter(hrp.Position) <= 35 then
					parts[#parts + 1] = { v, _v }
				end
			end
		end
	end
	if #parts == 0 then
		return
	end
	local tool = char:FindFirstChildOfClass("Tool")
	if #parts > 0 and tool and (tool.ToolTip == "Melee" or tool.ToolTip == "Sword") then
		if (tool.Name == "Black Leg" and tool.Level.Value >= 150) or (tool.Name == "Death Step" and tool.Level.Value >= 400) then
			if LocalPlayer.PlayerGui.Main.Skills:FindFirstChild(tool.Name) and LocalPlayer.PlayerGui.Main.Skills[tool.Name].V.Cooldown.AbsoluteSize.X <= 0 then
				VirtualInputManager:SendKeyEvent(true, "V", false, game)
				VirtualInputManager:SendKeyEvent(false, "V", false, game)
				task.wait(1.5)
			end
		end
		ReplicatedStorage.Modules.Net["RE/RegisterAttack"]:FireServer()
		local head = parts[1][1]:FindFirstChild("Head")
		ReplicatedStorage.Modules.Net["RE/RegisterHit"]:FireServer( head, parts, {}, tostring(LocalPlayer.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15) )
		cloneref(r):FireServer(
			string.gsub("RE/RegisterHit", ".", function(c)
				return string.char(bit32.bxor(string.byte(c), math.floor(workspace:GetServerTimeNow() / 10 % 10) + 1))
			end),
			bit32.bxor(id + 909090, ReplicatedStorage.Modules.Net.seed:InvokeServer() * 2),
			head,
			parts
		)
	end
end

local function GetNearestChests()
	local nearest, minDist = nil, 99999
	for _, v in workspace:GetDescendants() do
		if v.Name == "Chest1" or v.Name == "Chest2" or v.Name == "Chest3" then
			if v:IsA("Part") and v.CanTouch then
				local dist = LocalPlayer:DistanceFromCharacter(v:GetPivot().Position)
				if dist < minDist then
					minDist = dist
					nearest = v
				end
			end
		end
	end
	return nearest
end

local function IfTableHaveIndex(k)
	for _ in k do
		return true
	end
end
LastServersDataPulled = 0
CachedServers = {}
local function GetServers()
	if LastServersDataPulled then
		if os.time() - LastServersDataPulled < 60 then
			return CachedServers
		end
	end
	for i = 1, 100, 1 do
		local W = ReplicatedStorage:WaitForChild("__ServerBrowser"):InvokeServer(i)
		if IfTableHaveIndex(W) then
			LastServersDataPulled = os.time()
			CachedServers = W
			return W
		end
	end
end

local function HopLowServer()
	for i, v in GetServers() do
		if v.Count <= 5 then
			return ReplicatedStorage.__ServerBrowser:InvokeServer("teleport", i)
		end
	end
end

local function CheckSafezone(p)
	if not Character then
		return
	end
	if not Character:FindFirstChild("Humanoid") then
		return
	end
	if Character.Humanoid.Health > 0 then
		for _, v in workspace["_WorldOrigin"].SafeZones:GetChildren() do
			if v:IsA("Part") then
				if p and p:FindFirstChild("PrimaryPart") and (v.Position - p.PrimaryPart.Position).magnitude <= 200 and p.Humanoid.Health / p.Humanoid.MaxHealth >= 90 / 100 then
					return true
				end
			end
		end
	end
	return false
end

BlacklistedPlayers = {
	LocalPlayer.Name,
}
local Hop

local function GetSkyRacePlayer()
	for _, Player in Players:GetPlayers() do
		if Player and Player.Character then
			local Humanoid = Player.Character:FindFirstChild("Humanoid")
			if not table.find(BlacklistedPlayers, Player.Name) and Humanoid and Humanoid.Health > 0 then
				Hop()
				if Player.Data.Race.Value == "Skypiea" and not Player:GetAttribute("IslandRaiding") then
					if not CheckSafezone(Player) and LocalPlayer:DistanceFromCharacter(Player.Character.PrimaryPart.Position) < 12000 and Player.Character.PrimaryPart.CFrame.Y > 0 then
						table.insert(BlacklistedPlayers, Player.Name)
						return Player
					end
				end
			end
		end
	end
end

local function GetPlayerBoat()
	for _, boat in workspace.Boats:GetChildren() do
		if boat:IsA("Model") then
			local Owner = boat:FindFirstChild("Owner")
			local HD = boat:FindFirstChild("Humanoid")
			if Owner and HD and tostring(Owner.Value) == LocalPlayer.Name and HD.Value > 0 then
				return boat
			end
		end
	end
end

local function SendKey(key, hold)
	VirtualInputManager:SendKeyEvent(true, key, false, game)
	task.wait(hold)
	VirtualInputManager:SendKeyEvent(false, key, false, game)
end

local function GetSeabeast()
	for _, sb in workspace.SeaBeasts:GetChildren() do
		if sb.Health.Value > 30000 then
			return sb
		end
	end
end

task.spawn(function()
	while true do
		GetServers()
		task.wait(180)
	end
end)

Hop = function(k, W)
	local check_isvalid = false
	local h = GetServers()
	local X = {}
	for w, D in h do
		table.insert(X, { JobId = w, Players = D.Count, LastUpdate = D.__LastUpdate, Region = D.Region, })
	end
	for _ = 1, #X do
		while task.wait() do
			local h = math.random(1, #X)
			ServerData = X[h]
			if ServerData then
				if not k or ServerData.Players < k then
					if not W or ServerData.Region == W then
						break
					else
						check_isvalid = true
					end
				end
			end
		end
	end
	if not check_isvalid then
		ReplicatedStorage:WaitForChild("__ServerBrowser"):InvokeServer("teleport", ServerData.JobId)
	else
		local servers = {}
		local ok, req = pcall(function()
			return game:HttpGet( "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true" )
		end)
		if not ok or not req then
			return
		end
		local ok2, body = pcall(function()
			return HttpService:JSONDecode(req)
		end)
		if not ok2 or not body or not body.data then
			return
		end
		for _, v in body.data do
			if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < 2 and v.id ~= game.JobId then
				table.insert(servers, 1, v.id)
			end
		end
		if #servers > 0 then
			ReplicatedStorage.__ServerBrowser:InvokeServer("teleport", servers[math.random(1, #servers)])
		end
	end
end

local BringMob = function(v, s)
	if not Character or not Character.PrimaryPart then
		return
	end

	-- รวมมอนชื่อเดียวกันครั้งละไม่เกิน 3 ตัว โดยไม่แตะระบบส่วนอื่น
	local targets = {}
	for _, mob in ipairs(workspace.Enemies:GetChildren()) do
		local humanoid = mob:FindFirstChildOfClass("Humanoid")
		local root = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart

		if mob:IsA("Model")
			and root
			and humanoid
			and humanoid.Health > 0
			and (not v or mob.Name == v)
			and LocalPlayer:DistanceFromCharacter(root.Position) <= 180 then
			targets[#targets + 1] = { Model = mob, Root = root }
			if #targets >= 3 then
				break
			end
		end
	end

	if #targets < 2 then
		return
	end

	local targetCFrame = targets[1].Root.CFrame
	for _, target in ipairs(targets) do
		local root = target.Root
		if root and root.Parent then
			local ok, owns = pcall(isnetworkowner, root)
			if ok and owns then
				root.CFrame = targetCFrame
			end
		end
	end
end

local function WaitUntilNoBusy()
	pcall(function()
		task.wait(0.1)
		if Character.Busy.Value then
			repeat
				task.wait(0.1)
			until not Character.Busy.Value
		end
	end)
end

local function AutoSkill()
	for _, v in LocalPlayer.Backpack:GetChildren() do
		if v.ToolTip == "Melee" or v.ToolTip == "Sword" or v.ToolTip == "Blox Fruit" or v.ToolTip == "Gun" then
			Character.Humanoid:EquipTool(v)
			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
			WaitUntilNoBusy()
			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.X, false, game)
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.X, false, game)
			WaitUntilNoBusy()
			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game)
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game)
			break
		end
	end
end

local function Seabeast()
	if not CheckSeabeast() and not CheckPirateBoat() then
		if not CheckBoat() then
			if (Vector3.new(-12.7291985, 10.3120461, 2955.1543) - Character.HumanoidRootPart.Position).Magnitude > 8 then
				Tween(CFrame.new(-12.7291985, 10.3120461, 2955.1543), 280).Completed:Wait()
				CommF_:InvokeServer("BuyBoat", "PirateBrigade")
			else
				CommF_:InvokeServer("BuyBoat", "PirateBrigade")
			end
		else
			if (CheckBoat().VehicleSeat.Position - Vector3.new(28.4108, 1.2327, 3679.99)).Magnitude > 50 then
				CheckBoat().VehicleSeat.CFrame = CFrame.new(28.4108 + 20, 1.2327 + 10, 3679.99 + 20)
			else
				if not Character.Humanoid.Sit then
					if (CheckBoat().VehicleSeat.Position - Character.HumanoidRootPart.Position).Magnitude > 50 then
						Tween(CheckBoat().VehicleSeat.CFrame, 280).Completed:Wait()
					else
						Character.HumanoidRootPart.CFrame = CheckBoat().VehicleSeat.CFrame
					end
				end
			end
		end
	elseif CheckPirateBoat() then
		local v = CheckPirateBoat()
		repeat
			task.wait()
			Tween(v.Engine.CFrame * CFrame.new(0, -20, 0), 250).Completed:Wait()
			AutoSkill()
		until not v or not v.Parent or v.Health.Value <= 0 or not CheckPirateBoat()
	elseif CheckSeabeast() then
		local v = CheckSeabeast()
		repeat
			task.wait()
			TeleportSeabeast(v)
			AutoSkill()
		until not v or not v.Parent or v.Health.Value <= 0 or not CheckSeabeast()
	end
end

local function KillMonster(_v)
    LogChange("combat_target", "combat: target " .. string.lower(tostring(_v)))
    SetStatus("combat | target " .. string.lower(tostring(_v)))
	while not (Character and Character:FindFirstChildOfClass("Humanoid")) do
		task.wait()
	end
	if Character.Humanoid.Health > 0 then
		for _, v2 in {workspace.Enemies, ReplicatedStorage} do
			for _, v in v2:GetChildren() do
				if v.Name:find(_v) and v.PrimaryPart and v:FindFirstChildOfClass("Humanoid") then
					repeat
						task.wait()
						if not v or not v.PrimaryPart or not v:FindFirstChildOfClass("Humanoid") or v.Humanoid.Health <= 0 then
							break
						end
						Tween(v.PrimaryPart.Position + Vector3.new(0, 25, 7), 350)
						if LocalPlayer:DistanceFromCharacter(v.PrimaryPart.CFrame.Position) <= 200 then
							Tween(v.PrimaryPart.Position + Vector3.new(0, 25, 7), math.huge)
							if LocalPlayer:DistanceFromCharacter(v.PrimaryPart.CFrame.Position) <= 50 then
								EquipWeapon()
								Attack()
							end
						end
					until not v
						or not v.PrimaryPart
						or not v:FindFirstChildOfClass("Humanoid")
						or v.Humanoid.Health <= 0
						or Character.Humanoid.Health <= 0
						or not Character:FindFirstChild("Humanoid")
					break
				end
			end
		end
	end
end

local lastTakeQuest = 0
local QuestController, GetQuest, GetQuestData, GetQuestPosition

GetQuestPosition = function()
    local nearestPos = nil
    local shortestdist = math.huge
    for _, v in require(ReplicatedStorage.GuideModule).Data.NPCList do
        if typeof(v) == "table" and v.Position then
            for _, x in v do
                if x == GetQuest()["NameQuest"] then
                    local distance = LocalPlayer:DistanceFromCharacter(v.Position)
                    if distance < shortestdist then
                        shortestdist = distance
                        nearestPos = v.Position
                    end
                end
            end
        end
    end
    return nearestPos
end

local function TakeQuest()
	if (tick() - lastTakeQuest) < 0.75 then
		return
	end
	local q = GetQuest()
    if q and q.NameQuest then
        LogChange("quest_target", "quest: " .. string.lower(tostring(q.NameQuest)) .. " / " .. string.lower(tostring(q.NameMonster or "unknown")))
    else
        LogChange("quest_target", "quest: no target")
    end
	if q and q.NameQuest and q.ID and (not GetQuestData() or QuestController.CurrentQuestName ~= q.NameQuest) then
		local questPos = GetQuestPosition()
        LogChange("quest_travel", questPos and "quest: traveling to npc" or "quest: npc position missing")
		if not questPos then
			LogChange("quest_travel", "quest: npc position missing, hopping server")
			Hop()
		end
		if questPos and TweenWithRespawnRetry(questPos, 350) then
			task.wait(0.25)
			if LocalPlayer:DistanceFromCharacter(questPos) <= 15 then
                LogChange("quest_start", "quest: starting " .. string.lower(tostring(q.NameQuest)))
                SetStatus("quest | starting " .. string.lower(tostring(q.NameQuest)))
				CommF_:InvokeServer("StartQuest", q.NameQuest, q.ID)
			end
		end
	end
	lastTakeQuest = tick()
end

local MobsCakePrince = {
	"Cookie Crafter",
	"Cake Guard",
	"Baking Staff",
	"Head Baker",
}
local CakePrinceBosses = {
	"Dough King",
	"Cake Prince",
}
local function GetCakePrince()
	for _, v in {workspace.Enemies, ReplicatedStorage} do
		for _, v2 in v:GetChildren() do
			if table.find(CakePrinceBosses, v2.Name) and v2:FindFirstChild("Humanoid") and v2:FindFirstChild("HumanoidRootPart") and v2.Humanoid.Health > 0 then
				return v2
			end
		end
	end
end

QuestController = {
	CurrentQuest = "",
	CurrentQuestName = "",
	CachedQuestData = require(ReplicatedStorage.Quests),
	QuestConnection = nil,
}
QuestController.Set = function(self, data)
	self.CurrentQuest = (function()
		for i, _ in data.Progress do
			return i
		end
	end)()
	self.CurrentQuestName = data.InternalQuestName
end
QuestController.Reset = function(self)
	self.CurrentQuest = ""
	self.CurrentQuestName = ""
end

QuestController.QuestConnection = ReplicatedStorage.Remotes.QuestUpdate.OnClientEvent:Connect(function(a2, a3)
	if a2 and typeof(a2) == "table" then
		QuestController:Set(a2)
		return
	end
	QuestController:Reset()
end)

GetQuestData = function()
	return QuestController.CurrentQuest ~= ""
end

local function GetLastQuest()
	local data = require(ReplicatedStorage.GuideModule).Data
	if data and data.QuestData and data.QuestData.Task then
		for i, _ in data.QuestData.Task do
			return i
		end
	end
end

local function GetBestQuest()
	local bestLevelReq = -1
	local bestRnq, bestTaskName, bestRidq = nil, nil, nil
	for rnq, v in QuestController.CachedQuestData do
		if table.find({ "BartiloQuest", "Trainees", "MarineQuest", "CitizenQuest", }, tostring(rnq)) then
			continue
		end
		for ridq, ct in v do
			if ct.LevelReq < 0 or LocalPlayer.Data.Level.Value < ct.LevelReq then
				continue
			end
			for O, taskValue in ct.Task do
				if taskValue > 1 and ct.LevelReq > bestLevelReq then
					bestLevelReq = ct.LevelReq
					bestRnq = rnq
					bestTaskName = tostring(O)
					bestRidq = ridq
				end
			end
		end
	end
	if not bestRnq then
		return
	end
	return bestLevelReq, bestRnq, bestTaskName, bestRidq
end

GetQuest = function()
	local Level = LocalPlayer.Data.Level.Value
	local msn, nq, idq
	local min = 0
	if Level >= 275 and Level < 300 then
		nq, msn, idq = "ColosseumQuest", "Togga Warrior", 1
	elseif Level >= 1450 and World.Sea2() then
		nq, msn, idq = "ForgottenQuest", "Water Fighter", 2
	elseif Level >= 700 and World.Sea1() then
		nq, msn, idq = "FountainQuest", "Galley Captain", 2
	else
		min, nq, msn, idq = GetBestQuest()
	end
	local q = {}
	if Level >= 10 and not GetQuestData() and GetLastQuest() == msn then
		for rnq, v in QuestController.CachedQuestData do
			for _, N in v do
				for x, _ in N.Task do
					if tostring(x) == msn then
						for iq, v2 in v do
							for n, ct in v2.Task do
								if n ~= msn and ct > 1 then
									q.NameMonster = v2.LevelReq <= Level and tostring(n) or msn
									q.NameQuest = v2.LevelReq <= Level and rnq or nq
									q.ID = v2.LevelReq <= Level and iq or idq
									return q
								end
							end
						end
					end
				end
			end
		end
	end
	q.NameMonster = msn
	q.NameQuest = nq
	q.ID = idq
	return q
end

local function TakeQuestCake(b)
	if not GetQuestData() then
        LogChange("cake_quest", "quest: cake " .. string.lower(tostring(b)))
		local r = require(ReplicatedStorage.Quests)
		local t = {
			r.CakeQuest1,
			r.CakeQuest2,
		}
		local qn, id, lvrq
		for c, v in t do
			if typeof(v) == "table" then
				for i, v2 in v do
					if v2.Name == b then
						id = i
						qn = "CakeQuest" .. c
						lvrq = v2.LevelReq
					end
				end
			end
		end
		local p
		for _, v in require(ReplicatedStorage.GuideModule).Data.NPCList do
			if typeof(v) == "table" then
				for _, x in v do
					if x == qn then
						if LocalPlayer.Data.Level.Value >= lvrq then
							p = v.Position
						else
							return
						end
					end
				end
			end
		end

		if p and TweenWithRespawnRetry(p, 350) and LocalPlayer:DistanceFromCharacter(p) < 5 then
			task.wait(1)
			CommF_:InvokeServer("StartQuest", tostring(qn), id)
			task.wait(0.5)
		end
	end
end

local function TakeQuestBone(b)
	if not GetQuestData() then
        LogChange("bone_quest", "quest: bones " .. string.lower(tostring(b)))
		local r = require(ReplicatedStorage.Quests)
		local t = { r.HauntedQuest1, r.HauntedQuest2 }
		local qn, id, lvrq
		for c, v in t do
			if typeof(v) == "table" then
				for i, v2 in v do
					if v2.Name == b then
						id = i
						qn = "HauntedQuest" .. c
						lvrq = v2.LevelReq
					end
				end
			end
		end
		local p
		for _, v in require(ReplicatedStorage.GuideModule).Data.NPCList do
			if typeof(v) == "table" then
				for _, x in v do
					if x == qn then
						if LocalPlayer.Data.Level.Value >= lvrq then
							p = v.Position
						else
							return
						end
					end
				end
			end
		end

		if p and TweenWithRespawnRetry(p, 350) and LocalPlayer:DistanceFromCharacter(p) < 5 then
			task.wait(1)
			CommF_:InvokeServer("StartQuest", tostring(qn), id)
			task.wait(0.5)
		end
	end
end

local function GetMonsterName()
	local _v = {}
	for _, v in workspace.Enemies:GetChildren() do
		if not table.find(_v, v.Name) and v:IsA("Model") and v.Name ~= "PirateBasic" and not v.Name:find("Brigade") and not v.Name:find("FishBoat") and v:FindFirstChildOfClass("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
			table.insert(_v, v.Name)
		end
	end
	for _, v in _v do
		local name = v:gsub(" %pLv%. ?%d+%p", "")
		if QuestController.CurrentQuest == name then
			return name
		end
	end
	return false
end

local function LoadItem(v, t)
	CommF_:InvokeServer("LoadItem", v, { t, })
end

local function GetMaterial(name)
	local data = IRS:GetItems(KEYS.QUANTITY)
	for _, v in data do
		local item = MATCH(v.ItemId)._ok
		if item.Display.Category == "Material" and item.Index.StorageKey == name then
			return v.Value
		end
	end
	return 0
end

local function BringSG(v)
	while not (Character and Character.PrimaryPart) do
		task.wait()
	end
	local targets = {}
	for _, x in workspace.Enemies:GetChildren() do
		if x:FindFirstChild("HumanoidRootPart") and x:FindFirstChild("Humanoid") and x.Humanoid.Health > 0 and (not v or x.Name == v) and (p.Position - x.HumanoidRootPart.Position).Magnitude <= math.huge then
			targets[#targets + 1] = x
			if #targets == 6 then
				break
			end
		end
	end
	if #targets == 0 then
		return
	end
	local t = targets[1].HumanoidRootPart.CFrame
	for _, x in targets do
		sethiddenproperty(x.HumanoidRootPart, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
		x.HumanoidRootPart.CFrame = t
	end
end

local function GetSG()
    LogChange("soul_guitar", "soul guitar: checking puzzle")
	local check = CommF_:InvokeServer("GuitarPuzzleProgress", "Check")
	if not check then
		if Lighting.Sky.MoonTextureId == "http://www.roblox.com/asset/?id=9709149431" and (Lighting.ClockTime > 16 or Lighting.ClockTime < 5) then
            LogChange("soul_guitar_stage", "soul guitar: doing gravestone ritual")
            SetStatus("soul guitar | doing gravestone ritual")
			if LocalPlayer:DistanceFromCharacter(Vector3.new(-8654, 140, 6167)) > 50 then
				Tween(CFrame.new(-8654, 140, 6167), 350).Completed:Wait()
			end
			CommF_:InvokeServer("gravestoneEvent", 2)
			CommF_:InvokeServer("gravestoneEvent", 2, true)
        else
            LogChange("soul_guitar_stage", "soul guitar: waiting for full moon")
            SetStatus("soul guitar | waiting for full moon")
		end
	elseif check.Swamp == false then
        LogChange("soul_guitar_stage", "soul guitar: clearing swamp")
        SetStatus("soul guitar | clearing swamp")
		if (function() local b = 0 for _, v in workspace.Enemies:GetChildren() do if v.Name == "Living Zombie" and v.Humanoid and v.Humanoid.Health > 0 then
						b = b + 1
					end
				end
				return b
			end)() == 6
		then
			repeat
				for _, v in workspace.Enemies:GetChildren() do
					if v.Name == "Living Zombie" and v.Humanoid and v.Humanoid.Health > 0 then
						repeat
							task.wait()
							if not v or not v.PrimaryPart or not v:FindFirstChild("Humanoid") or v.Humanoid.Health <= 0 then
								break
							end
							Tween(v.PrimaryPart.CFrame * CFrame.new(0, 15, 10), 350)
							if LocalPlayer:DistanceFromCharacter(v.PrimaryPart.CFrame.Position) <= 220 then
								Tween(v.PrimaryPart.CFrame * CFrame.new(0, 15, 10), math.huge)
								if LocalPlayer:DistanceFromCharacter(v.PrimaryPart.CFrame.Position) <= 40 then
									BringSG(v.Name)
									EquipWeapon()
									Attack()
								end
							end
						until not v or not v.PrimaryPart or not v:FindFirstChild("Humanoid") or v.Humanoid.Health <= 0
					end
				end
			until CommF_:InvokeServer("GuitarPuzzleProgress", "Check").Swamp
				or (function()
						local b = 0
						for _, v in workspace.Enemies:GetChildren() do
							if v.Name == "Living Zombie" and v.PrimaryPart and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
								b = b + 1
							end
						end
						return b
					end)()
					== 0
		end
	elseif check.Gravestones == false then
        LogChange("soul_guitar_stage", "soul guitar: solving gravestones")
        SetStatus("soul guitar | solving gravestones")
		CommF_:InvokeServer("GuitarPuzzleProgress", "Gravestones")
	elseif check.Ghost == false then
        LogChange("soul_guitar_stage", "soul guitar: completing ghost challenge")
        SetStatus("soul guitar | completing ghost challenge")
		CommF_:InvokeServer("GuitarPuzzleProgress", "Ghost")
	elseif check.Trophies == false then
        LogChange("soul_guitar_stage", "soul guitar: completing trophy challenge")
        SetStatus("soul guitar | completing trophy challenge")
		CommF_:InvokeServer("GuitarPuzzleProgress", "Trophies")
	elseif check.Pipes == false then
        LogChange("soul_guitar_stage", "soul guitar: solving pipes")
        SetStatus("soul guitar | solving pipes")
		CommF_:InvokeServer("GuitarPuzzleProgress", "Pipes")
	elseif check.CraftedOnce == false then
		if LocalPlayer.Data.Fragments.Value >= 5000 and GetMaterial("Bones") >= 500 and GetMaterial("Ectoplasm") >= 250 then
            LogChange("soul_guitar_stage", "soul guitar: crafting")
            SetStatus("soul guitar | crafting")
			CommF_:InvokeServer("soulGuitarBuy")
        else
            LogChange("soul_guitar_stage", "soul guitar: collecting materials")
            SetStatus("soul guitar | collecting materials")
            LogChange("soul_guitar_materials", "soul guitar: fragments " .. tostring(LocalPlayer.Data.Fragments.Value) .. "/5000, bones " .. tostring(GetMaterial("Bones")) .. "/500, ectoplasm " .. tostring(GetMaterial("Ectoplasm")) .. "/250")
		end
	end
end

local CheckMonster

local function UnlockSecondSea()
    LogChange("sea_unlock", "sea: unlocking second sea")
	local travel = CommF_:InvokeServer("TravelDressrosa")
	if travel:find("Cannot") then
		local data = CommF_:InvokeServer("DressrosaQuestProgress")
		if not data.UsedKey then
			if not data.TalkedDetective then
                LogChange("sea2_stage", "sea 2: talking to detective")
                SetStatus("sea 2 | talking to detective")
				CommF_:InvokeServer("DressrosaQuestProgress", "Detective")
			elseif LocalPlayer.Backpack:FindFirstChild("Key") then
				Character.Humanoid:EquipTool(LocalPlayer.Backpack["Key"])
			end
			CommF_:InvokeServer("DressrosaQuestProgress", "UseKey")
		elseif not data.KilledIceBoss then
            LogChange("sea2_stage", "sea 2: defeating ice admiral")
            SetStatus("sea 2 | defeating ice admiral")
			if CheckMonster("Ice Admiral") then
				KillMonster("Ice Admiral")
			else
				Tween(CFrame.new(1328, 43, -1346), 300)
			end
		else
			CommF_:InvokeServer("TravelDressrosa")
		end
	end
end

local function GetFruitValue(_v)
	local data = IRS:GetItems(KEYS.QUANTITY)
	for _, v in data do
		local item = MATCH(v.ItemId)._ok
		if item.Display.Category == "Blox Fruit" and item.Quality.MoneyPrice >= _v then
			return item.Index.StorageKey
		end
	end
	return nil
end

local function GetFruitId(g)
	local ok = string.match(g, "((%u)[^%-]+)$")
	return ok .. "Fruit"
end

local zQuestProRemote = ReplicatedStorage.Remotes:FindFirstChild("RefreshZQuestPro")
if World.Sea2() and zQuestProRemote then
	local zQuestProConnection = zQuestProRemote.OnClientEvent:Connect(function(a)
		if a == "promptDialogue" then
			print("cutscene finished")
			HopLowServer()
		end
	end)
end

local GetFruits

local function UnlockThirdSea()
    LogChange("sea_unlock", "sea: unlocking third sea")
	local check = CommF_:InvokeServer("ZQuestProgress", "Check")
	if CommF_:InvokeServer("GetUnlockables").FlamingoAccess then
		print("check: " .. tostring(check))
		if check == 0 then
            LogChange("sea3_stage", "sea 3: starting rip indra quest")
            SetStatus("sea 3 | starting rip indra quest")
			CommF_:InvokeServer("TravelZou")
			if LocalPlayer:DistanceFromCharacter(Vector3.new(0, 0, 0)) < 20000 then
				CommF_:InvokeServer("ZQuestProgress", "Begin")
			end
			if CheckMonster("rip_indra") then
				KillMonster("rip_indra")
			else
				LocalPlayer:Kick("Rejoin to fix blox kid")
			end
		elseif check == 1 then
            LogChange("sea3_stage", "sea 3: continuing quest")
            SetStatus("sea 3 | continuing quest")
			CommF_:InvokeServer("TravelZou")
		else
			if CheckMonster("Don Swan") then
                LogChange("sea3_stage", "sea 3: defeating don swan")
                SetStatus("sea 3 | defeating don swan")
				KillMonster("Don Swan")
				SWAN_KILLED = true
				CommF_:InvokeServer("ZQuestProgress", "Begin")
			else
				if LocalPlayer:DistanceFromCharacter(Vector3.new(2288, 15, 863)) > 15 then
					Tween(CFrame.new(2288, 15, 863), 350).Completed:Wait()
					return true
				end
			end
		end
	else
        LogChange("sea3_stage", "sea 3: unlocking flamingo access")
        SetStatus("sea 3 | unlocking flamingo access")
		local talk = CommF_:InvokeServer("TalkTrevor", "1")
		if talk then
			if talk == 1 or talk ~= 2 then
				local df = GetFruitValue(1000000)
				if df then
					if talk == 1 then
						CommF_:InvokeServer("TalkTrevor", "2")
						task.wait(0.75)
					end
					PAUSE_AUTO_STORE = true
					CommF_:InvokeServer("LoadFruit", df)
					EquipTool(GetFruitId(df))
					CommF_:InvokeServer("TalkTrevor", "1")
					CommF_:InvokeServer("TalkTrevor", "2")
					CommF_:InvokeServer("TalkTrevor", "3")
					PAUSE_AUTO_STORE = false
				else
					local df = GetFruits()
					if df then
						pcall(function()
							Tween(df:GetPivot(), 350).Completed:Wait()
						end)
					end
					hop()
					task.wait(5)
				end
			end
		end
	end
end

GetFruits = function()
	for _, v in workspace:GetChildren() do
		if string.find(v.Name, "Fruit") and (v:IsA("Tool") or v:IsA("Model")) and (v.Name ~= "Fruit ") then
			return v
		end
	end
	return nil
end

local function GetCastleRaid()
	for _, v in {workspace.Enemies, ReplicatedStorage} do
		for _, v2 in v:GetChildren() do
			if v2:GetAttribute("Level") and v2:GetAttribute("Level") <= 1500 and v2:IsA("Model") and (v2:GetPivot().Position - Vector3.new(-5000, 350, -3035)).Magnitude <= 1000 then
				return true
			end
		end
	end
	return nil
end

task.spawn(function()
	while true do
		if not PAUSE_AUTO_STORE then
			pcall(function()
				local gg = {}
				for _, _v in {LocalPlayer.Backpack, LocalPlayer.Character} do
					if _v then
						for _, v in _v:GetChildren() do
							if v.Name:find("Fruit") and v:IsA("Tool") then
								local ori = v:GetAttribute("OriginalName") or v.Name
								if not CheckItem(v.Name) and not CheckItem(ori) then
									table.insert(gg, { tool = v, ori = ori, })
								end
							end
						end
					end
				end
				if #gg > 0 then
					local sf = {}
					local inv = CommF_:InvokeServer("getInventoryFruits")
					if type(inv) == "table" then
						for _, _v in inv do
							if type(_v) == "table" and _v.Name then
								sf[_v.Name] = true
							end
						end
					end
					for _, v in gg do
						if not sf[v.ori] then
							CommF_:InvokeServer("StoreFruit", v.ori, v.tool)
							sf[v.ori] = true
						end
					end
				end
			end)
		end
		CommF_:InvokeServer("Cousin", "DLCBoxData")
		task.wait(1)
	end
end)

local materialMon, materialPos
local function GetMaterialMon(material)
	if not Character or not Character.PrimaryPart then
		return
	end
	if World.Sea1() then
		if material == "Angel Wings" then
			materialMon = {
				"Shanda",
				"Royal Squad",
				"Royal Soldier",
				"Wysper",
				"Thunder God",
			}
			materialPos = CFrame.new(-4698, 845, -1912)
		elseif material == "Leather + Scrap Metal" then
			materialMon = {
				"Brute",
				"Pirate",
			}
			materialPos = CFrame.new(-1145, 15, 4350)
		elseif material == "Magma Ore" then
			materialMon = {
				"Military Soldier",
				"Military Spy",
				"Magma Admiral",
			}
			materialPos = CFrame.new(-5815, 84, 8820)
		elseif material == "Fish Tail" then
			materialMon = {
				"Fishman Warrior",
				"Fishman Commando",
				"Fishman Lord",
			}
			materialPos = CFrame.new(61123, 19, 1569)
		end
	elseif World.Sea2() then
		if material == "Leather + Scrap Metal" then
			materialMon = {
				"Marine Captain",
			}
			materialPos = CFrame.new(-2010.5059814453125, 73.00115966796875, -3326.620849609375)
		elseif material == "Magma Ore" then
			materialMon = {
				"Magma Ninja",
				"Lava Pirate",
			}
			materialPos = CFrame.new(-5428, 78, -5959)
		elseif material == "Ectoplasm" then
			materialMon = {
				"Ship Deckhand",
				"Ship Engineer",
				"Ship Steward",
				"Ship Officer",
			}
			materialPos = CFrame.new(911.35827636719, 125.95812988281, 33159.5390625)
		elseif material == "Mystic Droplet" then
			materialMon = {
				"Water Fighter",
			}
			materialPos = CFrame.new(-3385, 239, -10542)
		elseif material == "Radioactive Material" then
			materialMon = {
				"Factory Staff",
			}
			materialPos = CFrame.new(295, 73, -56)
		elseif material == "Vampire Fang" then
			materialMon = {
				"Vampire",
			}
			materialPos = CFrame.new(-6033, 7, -1317)
		end
	elseif World.Sea3() then
		if material == "Leather + Scrap Metal" then
			materialMon = {
				"Jungle Pirate",
				"Forest Pirate",
			}
			materialPos = CFrame.new(-11975.78515625, 331.7734069824219, -10620.0302734375)
		elseif material == "Fish Tail" then
			materialMon = {
				"Fishman Raider",
				"Fishman Captain",
			}
			materialPos = CFrame.new(-10993, 332, -8940)
		elseif material == "Conjured Cocoa" then
			materialMon = {
				"Chocolate Bar Battler",
				"Cocoa Warrior",
			}
			materialPos = CFrame.new(620, 78, -12581.369140625)
		elseif material == "Dragon Scale" then
			materialMon = {
				"Dragon Crew Warrior",
				"Dragon Crew Archer"
			}
			materialPos = CFrame.new(6594, 383, 139)
		elseif material == "Gunpowder" then
			materialMon = {
				"Pistol Billionaire",
			}
			materialPos = CFrame.new(-469, 74, 5904)
		elseif material == "Mini Tusk" then
			materialMon = {
				"Mythological Pirate",
			}
			materialPos = CFrame.new(-13545, 470, -6917)
		end
	end
end

local function FarmMaterial(material)
    LogChange("material", "material: farming " .. string.lower(tostring(material)))
	GetMaterialMon(material)
	local mob = nil
	local min = math.huge
	for _, v in workspace.Enemies:GetChildren() do
		if v.PrimaryPart and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and table.find(materialMon, v.Name) then
			local dist = LocalPlayer:DistanceFromCharacter(v.PrimaryPart.Position)
			if dist < min then
				min = dist
				mob = v
			end
		end
	end
	if mob and mob.PrimaryPart and mob.Humanoid and mob.Humanoid.Health > 0 then
        LogChange("material_target", "material: target found for " .. string.lower(tostring(material)))
        SetStatus("material | fighting for " .. string.lower(tostring(material)))
		repeat
			task.wait()
			EquipWeapon()
			Tween(mob.PrimaryPart.CFrame * CFrame.new(0, 20, 10), 350)
			if LocalPlayer:DistanceFromCharacter(mob.PrimaryPart.CFrame.Position) <= 200 then
				Tween(mob.PrimaryPart.CFrame * CFrame.new(0, 20, 10), math.huge)
				if LocalPlayer:DistanceFromCharacter(mob.PrimaryPart.CFrame.Position) <= 45 then
					BringMob(mob.Name)
					Attack()
				end
			end
		until not mob or not mob.PrimaryPart or not mob:FindFirstChild("Humanoid") or mob.Humanoid.Health <= 0
	else
        LogChange("material_target", "material: waiting for " .. string.lower(tostring(material)) .. " spawn")
        SetStatus("material | waiting for " .. string.lower(tostring(material)) .. " spawn")
		Tween(materialPos, 350).Completed:Wait()
	end
end

local function GetRaceGrade()
	local race = LocalPlayer.Data.Race
	if LocalPlayer.Backpack:FindFirstChild("Awakening") or Character:FindFirstChild("Awakening") then
		return "V4"
	elseif LocalPlayer.Backpack:FindFirstChild("Last Resort") or Character:FindFirstChild("Last Resort") or LocalPlayer.Backpack:FindFirstChild("Agility") or LocalPlayer.Character:FindFirstChild("Agility") or LocalPlayer.Backpack:FindFirstChild("Water Body") or Character:FindFirstChild("Water Body") or LocalPlayer.Backpack:FindFirstChild("Heavenly Blood") or Character:FindFirstChild("Heavenly Blood") or LocalPlayer.Backpack:FindFirstChild("Heightened Senses") or Character:FindFirstChild("Heightened Senses") or LocalPlayer.Backpack:FindFirstChild("Energy Core") or Character:FindFirstChild("Energy Core") or LocalPlayer.Backpack:FindFirstChild("Primordial Reign") or Character:FindFirstChild("Primordial Reign") then
		return "V3"
	elseif race:FindFirstChild("Evolved") then
		return "V2"
	else
		return "V1"
	end
end

BindedMeleeNPCNames = {}
local function MeleeNPCPosition(a, b, c)
	for i, v in {a, b, c} do
		if v and World["Sea" .. i]() then
			return v
		end
	end
	return nil
end

BindedMeleeNPCNames.BlackLeg =
	MeleeNPCPosition(Vector3.new(-985, 14, 3988), Vector3.new(-4754, 35, -4849), Vector3.new(-5045, 372, -3178))
BindedMeleeNPCNames.Electro =
	MeleeNPCPosition(Vector3.new(-5384, 14, -2149), Vector3.new(-4864, 35, -4765), Vector3.new(-4994, 315, -3201))
BindedMeleeNPCNames.FishmanKarate =
	MeleeNPCPosition(Vector3.new(61585, 19, 987), Vector3.new(-4957, 35, -4668), Vector3.new(-5022, 372, -3187))

BindedMeleeNPCNames.SharkmanKarate =
	MeleeNPCPosition(nil, Vector3.new(-2602, 239, -10317), Vector3.new(-4974, 315, -3221))
BindedMeleeNPCNames.DeathStep = MeleeNPCPosition(nil, Vector3.new(6356, 296, -6763), Vector3.new(-4997, 315, -3220))
BindedMeleeNPCNames.Superhuman = MeleeNPCPosition(nil, Vector3.new(1379, 247, -5190), Vector3.new(-5004, 372, -3194))
BindedMeleeNPCNames.DragonClaw = MeleeNPCPosition(nil, Vector3.new(702, 187, 653), Vector3.new(-4980, 372, -3205))

BindedMeleeNPCNames.ElectricClaw = MeleeNPCPosition(nil, nil, Vector3.new(-10371, 331, -10131))
BindedMeleeNPCNames.DragonTalon = MeleeNPCPosition(nil, nil, Vector3.new(5661, 1210, 863))
BindedMeleeNPCNames.Godhuman = MeleeNPCPosition(nil, nil, Vector3.new(-13774, 333, -9879))

local function TweenToMeleeBuyer(name)
	local p = BindedMeleeNPCNames[name]
	if p then
		return TweenWithRespawnRetry(p, 300)
	end
	return false
end
local function GetMastery(name)
	local melee = {
		"DeathStep",
		"Superhuman",
		"ElectricClaw",
		"DragonTalon",
		"SharkmanKarate",
		"BlackLeg",
		"Electro",
		"FishmanKarate",
		"SanguineArt",
		"DragonClaw",
	}
	if table.find(melee, name) then
		return MeleeData[name] or 0
	elseif CheckItem(name) then
		LoadItem(name)
		task.wait(1)
		local tool = LocalPlayer.Backpack:FindFirstChild(name)
		if tool then
			return tool.Level.Value
		end
	end
	return 0
end

local function DoRaceV2()
    LogChange("race_mode", "race v2: checking progress")
	if not World.Sea2() then
        LogChange("race_v2_travel", "race v2: traveling to sea 2")
        SetStatus("race v2 | traveling to sea 2")
		while true do
			CommF_:InvokeServer("TravelDressrosa")
			task.wait(5)
		end
	end
	if not LocalPlayer.Data.Race:FindFirstChild("Evolved") then
		local check = CommF_:InvokeServer("Alchemist", "1")
		if check == 0 then
            LogChange("race_v2_stage", "race v2: talking to alchemist")
            SetStatus("race v2 | talking to alchemist")
			CommF_:InvokeServer("Alchemist", "2")
		elseif check == 1 then
            if LocalPlayer.Backpack:FindFirstChild("Flower 1") or Character:FindFirstChild("Flower 1") then
                LogChange("race_v2_flower1", "race v2: flower 1 collected")
            end
            if LocalPlayer.Backpack:FindFirstChild("Flower 2") or Character:FindFirstChild("Flower 2") then
                LogChange("race_v2_flower2", "race v2: flower 2 collected")
            end
            if LocalPlayer.Backpack:FindFirstChild("Flower 3") or Character:FindFirstChild("Flower 3") then
                LogChange("race_v2_flower3", "race v2: flower 3 collected")
            end
			if not LocalPlayer.Backpack:FindFirstChild("Flower 1") and not Character:FindFirstChild("Flower 1") then
                LogChange("race_v2_stage", "race v2: collecting flower 1")
                SetStatus("race v2 | collecting flower 1")
				Tween(workspace.Flower1.CFrame, 350)
				firetouchinterest(workspace.Flower1, Character.HumanoidRootPart, 1)
				firetouchinterest(workspace.Flower1, Character.HumanoidRootPart, 0)
                LogChange("race_v2_flower1", "race v2: flower 1 collected")
			elseif not LocalPlayer.Backpack:FindFirstChild("Flower 2") and not Character:FindFirstChild("Flower 2") then
                LogChange("race_v2_stage", "race v2: collecting flower 2")
                SetStatus("race v2 | collecting flower 2")
				Tween(workspace.Flower2.CFrame, 350)
				firetouchinterest(workspace.Flower2, Character.HumanoidRootPart, 1)
				firetouchinterest(workspace.Flower2, Character.HumanoidRootPart, 0)
                LogChange("race_v2_flower2", "race v2: flower 2 collected")
			elseif not LocalPlayer.Backpack:FindFirstChild("Flower 3") and not Character:FindFirstChild("Flower 3") then
				if workspace.Enemies:FindFirstChild("Zombie") then
                    LogChange("race_v2_stage", "race v2: farming zombie for flower 3")
                    SetStatus("race v2 | farming zombie for flower 3")
					for _, v in workspace.Enemies:GetChildren() do
						if v.Name == "Zombie" then
							repeat
								task.wait()
								if not v or not v.PrimaryPart or not v:FindFirstChild("Humanoid") or v.Humanoid.Health <= 0 then
									break
								end
								Tween(v.PrimaryPart.CFrame * CFrame.new(0, 15, 10), 350)
								if LocalPlayer:DistanceFromCharacter(v.PrimaryPart.Position) <= 200 then
									Tween(v.PrimaryPart.CFrame * CFrame.new(0, 15, 10), math.huge)
									EquipWeapon()
									BringMob(v.Name)
									Attack()
								end
							until LocalPlayer.Backpack:FindFirstChild("Flower 3")
								or not v
								or not v.PrimaryPart
								or not v:FindFirstChild("Humanoid")
								or v.Humanoid.Health <= 0
						end
					end
				else
                    LogChange("race_v2_stage", "race v2: waiting for zombie spawn")
                    SetStatus("race v2 | waiting for zombie spawn")
					Tween(CFrame.new(-5685, 48, -853), 350).Completed:Wait()
				end
			end
		elseif check == 2 then
            LogChange("race_v2_stage", "race v2: submitting flowers")
            SetStatus("race v2 | submitting flowers")
			CommF_:InvokeServer("Alchemist", "3")
		end
    else
        LogChange("race_v2_stage", "race v2: already evolved")
        SetStatus("race v2 | already evolved")
	end
end

CheckMonster = function(name)
	return workspace.Enemies:FindFirstChild(name) or ReplicatedStorage:FindFirstChild(name)
end

MinkQuestStage = 0
HumanQuestStage = 0
local function DoRaceV3()
    LogChange("race_mode", "race v3: checking progress")
	if not World.Sea2() then
        LogChange("race_v3_travel", "race v3: traveling to sea 2")
        SetStatus("race v3 | traveling to sea 2")
		while true do
			CommF_:InvokeServer("TravelDressrosa")
			task.wait(5)
		end
	end
	local race = LocalPlayer.Data.Race.Value
	local check = CommF_:InvokeServer("Wenlocktoad", "1")
	if check == 0 then
        LogChange("race_v3_stage", "race v3: starting quest")
        SetStatus("race v3 | starting quest")
		CommF_:InvokeServer("Wenlocktoad", "2")
	elseif check == 1 then
		if race == "Human" then
			if HumanQuestStage == 0 then
                LogChange("race_v3_stage", "race v3: fighting jeremy")
                SetStatus("race v3 | fighting jeremy")
				if CheckMonster("Jeremy") then
					KillMonster("Jeremy")
					HumanQuestStage = 1
				else
					Tween(CFrame.new(2333.209228515625, 449.2427062988281, 699.5128784179688), 300).Completed:Wait()
				end
			elseif HumanQuestStage == 1 then
                LogChange("race_v3_stage", "race v3: fighting diamond")
                SetStatus("race v3 | fighting diamond")
				if CheckMonster("Diamond") then
					KillMonster("Diamond")
					HumanQuestStage = 2
				else
					Tween(CFrame.new(-1713.5589599609375, 198.99554443359375, -104.31584167480469), 300).Completed:Wait()
				end
			elseif HumanQuestStage == 2 then
                LogChange("race_v3_stage", "race v3: fighting orbitus")
                SetStatus("race v3 | fighting orbitus")
				if CheckMonster("Orbitus") then
					KillMonster("Orbitus")
					HumanQuestStage = 3
				else
					Tween(CFrame.new(-2148.7568359375, 73.27831268310547, -4304.4130859375), 300).Completed:Wait()
				end
			elseif HumanQuestStage == 3 then
                LogChange("race_v3_stage", "race v3: completing human trial")
                SetStatus("race v3 | completing human trial")
				CommF_:InvokeServer("Wenlocktoad", "3")
			end
		elseif race == "Rabbit" then
			for _, v in workspace.ChestModels:GetChildren() do
				if MinkQuestStage < 30 then
                    LogChange("race_v3_chests", "race v3: collecting chest " .. tostring(MinkQuestStage + 1) .. "/30")
                    SetStatus("race v3 | collecting chest " .. tostring(MinkQuestStage + 1) .. "/30")
					Tween(v.WorldPivot.Position, 350).Completed:Wait()
					MinkQuestStage = MinkQuestStage + 1
				elseif MinkQuestStage >= 30 then
                    LogChange("race_v3_stage", "race v3: completing rabbit trial")
                    SetStatus("race v3 | completing rabbit trial")
					CommF_:InvokeServer("Wenlocktoad", "3")
				end
			end
		elseif race == "Fishman" then
            LogChange("race_v3_stage", "race v3: farming sea beasts")
            SetStatus("race v3 | farming sea beasts")
			repeat
				Seabeast()
				task.wait(1)
				CommF_:InvokeServer("Wenlocktoad", "3")
			until GetRaceGrade() == "V3" or not string.find(race, "Fish")
		end
	elseif check == 2 then
        LogChange("race_v3_stage", "race v3: completing trial")
        SetStatus("race v3 | completing trial")
		CommF_:InvokeServer("Wenlocktoad", "3")
    else
        LogChange("race_v3_stage", "race v3: waiting for trial")
        SetStatus("race v3 | waiting for trial")
	end
end

local Travel = {
	Sea1 = function()
		if not World.Sea1() then
			while true do
				CommF_:InvokeServer("TravelMain")
				task.wait(10)
			end
		end
	end,
	Sea2 = function()
		if not World.Sea2() then
			while true do
				CommF_:InvokeServer("TravelDressrosa")
				task.wait(10)
			end
		end
	end,
	Sea3 = function()
		if not World.Sea3() then
			while true do
				CommF_:InvokeServer("TravelZou")
				task.wait(10)
			end
		end
	end
}

local function GetGodHuman()
    LogChange("godhuman", "godhuman: checking requirements")
	local check = CommF_:InvokeServer("BuyGodhuman", true)
	if check ~= 0 and check ~= 1 then
		for i, v in {"Dragon Scale", "Fish Tail", "Mystic Droplet", "Magma Ore"} do
			local max = 0
			if (i % 2) > 0 then
				max = 10
			else
				max = 20
			end
			if GetMaterial(v) < max then
                LogChange("godhuman_material", "godhuman: " .. string.lower(v) .. " " .. tostring(GetMaterial(v)) .. "/" .. tostring(max))
				if (i == 1 or i == 2) and not World.Sea3() then
					Travel.Sea3()
				elseif (i == 3 or i == 4) and not World.Sea2() then
					Travel.Sea2()
				end
				repeat
					FarmMaterial(v)
					task.wait(0.2)
				until GetMaterial(v) >= max
			end
		end
        LogChange("godhuman_stage", "godhuman: traveling to buyer")
        SetStatus("godhuman | traveling to buyer")
		Travel.Sea3()
		TweenToMeleeBuyer("Godhuman")
        LogChange("godhuman_stage", "godhuman: purchasing style")
        SetStatus("godhuman | purchasing style")
		CommF_:InvokeServer("BuyGodhuman", true)
		CommF_:InvokeServer("BuyGodhuman")
	else
        LogChange("godhuman_stage", "godhuman: purchasing style")
        SetStatus("godhuman | purchasing style")
		Travel.Sea3()
		TweenToMeleeBuyer("Godhuman")
		CommF_:InvokeServer("BuyGodhuman")
	end
end

local function GetSaber()
    LogChange("saber", "saber: checking progress")
	Travel.Sea1()
	CommF_:InvokeServer("AbandonQuest")
	local data = CommF_:InvokeServer("ProQuestProgress")
	if data.UsedRelic == false then
        LogChange("saber_stage", "saber: solving jungle puzzle")
        SetStatus("saber | solving jungle puzzle")
		while not (workspace.Map:FindFirstChild("Jungle") and workspace.Map.Jungle:FindFirstChild("QuestPlates") and workspace.Map.Jungle.QuestPlates:FindFirstChild("Door")) do
			task.wait()
			Tween(CFrame.new(-1254.25439453125, 18.39460563659668, 342.31976318359375), 350)
		end
		if workspace.Map.Jungle.QuestPlates.Door.Transparency == 0 then
            LogChange("saber_stage", "saber: activating jungle plates")
            SetStatus("saber | activating jungle plates")
			for _, v in workspace.Map.Jungle.QuestPlates:GetChildren() do
				if v:IsA("Model") and string.find(v.Name, "Plate") then
					firetouchinterest(v.Button, Character.HumanoidRootPart, 1)
					firetouchinterest(v.Button, Character.HumanoidRootPart, 0)
				end
			end
		else
			if data.UsedTorch == false then
                LogChange("saber_stage", "saber: collecting torch")
                SetStatus("saber | collecting torch")
				if LocalPlayer.Backpack:FindFirstChild("Torch") or Character:FindFirstChild("Torch") then
					CommF_:InvokeServer("ProQuestProgress", "DestroyTorch")
				else
					CommF_:InvokeServer("ProQuestProgress", "GetTorch")
				end
			else
				if data.UsedCup then
					if data.TalkedSon and data.KilledMob then
                        LogChange("saber_stage", "saber: placing relic")
                        SetStatus("saber | placing relic")
						if not data.UsedRelic then
							CommF_:InvokeServer("ProQuestProgress", "RichSon")
							if not Character:FindFirstChild("Relic") then
								Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild("Relic"))
							end
							CommF_:InvokeServer("ProQuestProgress", "PlaceRelic")
						end
					elseif data.TalkedSon == false then
                        LogChange("saber_stage", "saber: talking to rich son")
                        SetStatus("saber | talking to rich son")
						CommF_:InvokeServer("ProQuestProgress", "RichSon")
					elseif data.KilledMob == false then
                        LogChange("saber_stage", "saber: defeating mob leader")
                        SetStatus("saber | defeating mob leader")
						if CheckMonster("Mob Leader") then
							KillMonster("Mob Leader")
						end
					end
				else
                    LogChange("saber_stage", "saber: filling cup")
                    SetStatus("saber | filling cup")
					CommF_:InvokeServer("ProQuestProgress", "GetCup")
					if not Character:FindFirstChild("Cup") then
						Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild("Cup"))
					end
					CommF_:InvokeServer("ProQuestProgress", "FillCup", Character.Cup)
					CommF_:InvokeServer("ProQuestProgress", "SickMan")
				end
			end
		end
	else
        LogChange("saber_stage", "saber: fighting saber expert")
        SetStatus("saber | fighting saber expert")
		if CheckMonster("Saber Expert") then
			KillMonster("Saber Expert")
		else
			Tween( ReplicatedStorage.FortBuilderReplicatedSpawnPositionsFolder["Saber Expert"].CFrame * CFrame.new(0, 25, 0), 350 )
		end
	end
end

local function DoBartiloQuest()
    LogChange("bartilo", "bartilo: checking progress")
	if not World.Sea2() then
        LogChange("bartilo_travel", "bartilo: traveling to sea 2")
        SetStatus("bartilo | traveling to sea 2")
		while true do
			CommF_:InvokeServer("TravelDressrosa")
			task.wait(7.5)
		end
	end
	local function CheckKilledBanit()
		return CommF_:InvokeServer("BartiloQuestProgress").KilledBandits
	end
	local data = CommF_:InvokeServer("BartiloQuestProgress", "Bartilo")
	if CheckKilledBanit() == false then
        LogChange("bartilo_stage", "bartilo: farming swan pirates")
        SetStatus("bartilo | farming swan pirates")
		repeat
			if QuestController.CurrentQuestName ~= "BartiloQuest" then
				CommF_:InvokeServer("StartQuest", "BartiloQuest", 1)
			end
			if workspace.Enemies:FindFirstChild("Swan Pirate") then
				for _, v in workspace.Enemies:GetChildren() do
					if v.Name == "Swan Pirate" and v:FindFirstChildOfClass("Humanoid") and v.Humanoid.Health > 0 and v.PrimaryPart then
						repeat
							task.wait()
							if not v or not v.PrimaryPart or not v:FindFirstChildOfClass("Humanoid") or v.Humanoid.Health <= 0 then
								break
							end
							Tween(v.PrimaryPart.Position + Vector3.new(0, 20, 10), 350)
							if LocalPlayer:DistanceFromCharacter(v.PrimaryPart.Position) <= 200 then
								Tween(v.PrimaryPart.Position + Vector3.new(0, 20, 10), math.huge)
								EquipWeapon()
								BringMob(v.Name)
								Attack()
							end
						until not v or not v.PrimaryPart or v.Humanoid.Health <= 0
					end
				end
			else
				Tween(CFrame.new(932.624451, 156.106079, 1180.27466), 350).Completed:Wait()
			end
		until CheckKilledBanit()
	elseif data == 1 then
        LogChange("bartilo_stage", "bartilo: defeating jeremy")
        SetStatus("bartilo | defeating jeremy")
		if CheckMonster("Jeremy") then
			KillMonster("Jeremy")
		else
			Tween(Vector3.new(2129, 469, 779), 300).Completed:Wait()
		end
	elseif data == 2 then
		for i = 1, 8 do
            LogChange("bartilo_plate", "bartilo: activating plate " .. tostring(i) .. "/8")
            SetStatus("bartilo | activating plate " .. tostring(i) .. "/8")
			firetouchinterest(workspace.Map.Dressrosa.BartiloPlates["Plate" .. i], Character.PrimaryPart, 0)
			task.wait(0.1)
			firetouchinterest(workspace.Map.Dressrosa.BartiloPlates["Plate" .. i], Character.PrimaryPart, 1)
		end
	end
end
local function CheckDataLevel()
	local lv = LocalPlayer.Data.Level.Value
	if lv < 10 then
		return 1
	elseif lv < 70 then
		return 2
	elseif lv < 120 then
		return 3
	else
		return 4
	end
end
local function FarmLevelLogic()
	local levelData = CheckDataLevel()
    LogChange("farm_band", "farm: level band " .. tostring(levelData))
	if levelData == 2 then
        LogChange("farm_target", "farm: targeting shanda")
        SetStatus("farm | targeting shanda | lv " .. tostring(LocalPlayer.Data.Level.Value))
		local foundMob = false
		for _, v in {workspace.Enemies, ReplicatedStorage} do
			for _, v2 in v:GetChildren() do
				if v2:IsA("Model") then
					local hrp = v2:FindFirstChild("HumanoidRootPart") or v2.PrimaryPart
					if v2.Name == "Shanda" and hrp and v2:FindFirstChildOfClass("Humanoid") and v2:FindFirstChildOfClass("Humanoid").Health > 0 then
						foundMob = true
						repeat
							task.wait()
							local t = Tween(hrp.Position + Vector3.new(0, 20, 5), 350)
							if LocalPlayer:DistanceFromCharacter(hrp.Position) <= 160 then
								if t then
									t:Cancel()
								end
								Tween(hrp.Position + Vector3.new(0, 20, 5), math.huge)
								if LocalPlayer:DistanceFromCharacter(hrp.Position) <= 40 then
									BringMob(v2.Name)
									EquipWeapon()
									Attack()
								end
							end
						until not v2 or not v2:FindFirstChildOfClass("Humanoid") or v2.Humanoid.Health == 0
						pcall(function()
							v2:Destroy()
						end)
						if not CheckMonster("Shanda") then
							break
						end
					end
				end
			end
			if foundMob then
				break
			end
		end
		if not foundMob then
			local n = ReplicatedStorage.FortBuilderReplicatedSpawnPositionsFolder:FindFirstChild("Shanda")
			if n then
				Tween(n:GetPivot().Position + Vector3.new(0, 25, 0), 350).Completed:Wait()
			end
		end
	elseif levelData == 3 then
        LogChange("farm_target", "farm: targeting god's guard")
        SetStatus("farm | targeting god's guard | lv " .. tostring(LocalPlayer.Data.Level.Value))
		local foundMob = false
		for _, v in {workspace.Enemies, ReplicatedStorage} do
			for _, v2 in v:GetChildren() do
				if v2:IsA("Model") then
					local hrp = v2:FindFirstChild("HumanoidRootPart") or v2.PrimaryPart
					if v2.Name == "God's Guard" and hrp and v2:FindFirstChildOfClass("Humanoid") and v2:FindFirstChildOfClass("Humanoid").Health > 0 then
						foundMob = true
						repeat
							task.wait()
							local t = Tween(hrp.Position + Vector3.new(0, 25, 5), 350)
							if LocalPlayer:DistanceFromCharacter(hrp.Position) <= 160 then
								if t then
									t:Cancel()
								end
								Tween(hrp.Position + Vector3.new(0, 25, 5), math.huge)
								if LocalPlayer:DistanceFromCharacter(hrp.Position) <= 40 then
									BringMob(v2.Name)
									EquipWeapon()
									Attack()
								end
							end
						until not v2
							or not v2.Parent
							or not v2:FindFirstChildOfClass("Humanoid")
							or v2:FindFirstChildOfClass("Humanoid").Health <= 0
							or not v2.Name:find("God's Guard")
						pcall(function()
							v2:Destroy()
						end)
						if not CheckMonster("God's Guard") then
							break
						end
					end
				end
			end
			if foundMob then
				break
			end
		end
		if not foundMob then
			local n = ReplicatedStorage.FortBuilderReplicatedSpawnPositionsFolder:FindFirstChild("God's Guard")
			if n then
				Tween(n:GetPivot().Position + Vector3.new(0, 25, 0), 350).Completed:Wait()
			end
		end
	elseif levelData == 4 or levelData == 1 then
		if GetMonsterName() then
            LogChange("farm_target", "farm: targeting quest mob")
            SetStatus("farm | targeting quest mob | lv " .. tostring(LocalPlayer.Data.Level.Value))
			for _, v2 in {workspace.Enemies, ReplicatedStorage} do
				for _, v in v2:GetChildren() do
					if v.Name == GetMonsterName() and v.PrimaryPart and v:FindFirstChildOfClass("Humanoid") and v:FindFirstChildOfClass("Humanoid").Health > 0 then
						local startKillThisNPC = tick()
						repeat
							task.wait()
							TakeQuest()
							local t = Tween(v:GetPivot().Position + Vector3.new(0, 20, 5), 350)
							if LocalPlayer:DistanceFromCharacter(v:GetPivot().Position) <= 160 then
								if t then
									t:Cancel()
								end
								Tween(v:GetPivot().Position + Vector3.new(0, 20, 5), math.huge)
								if LocalPlayer:DistanceFromCharacter(v:GetPivot().Position) <= 40 then
									BringMob(v.Name)
									EquipWeapon()
									Attack()
								end
							end
						until not v
							or not v.PrimaryPart
							or not v:FindFirstChildOfClass("Humanoid")
							or v:FindFirstChildOfClass("Humanoid").Health <= 0
							or v.Name ~= GetMonsterName()
							or (tick() - startKillThisNPC) >= 90
						pcall(function()
							v:Destroy()
						end)
						if not CheckMonster(GetMonsterName()) then
							break
						end
					end
				end
			end
		else
            LogChange("farm_target", "farm: waiting for quest mob")
            SetStatus("farm | waiting for quest mob | lv " .. tostring(LocalPlayer.Data.Level.Value))
			TakeQuest()
			for _, v in {ReplicatedStorage.FortBuilderReplicatedSpawnPositionsFolder, workspace._WorldOrigin.EnemySpawns} do
				for _, v2 in v:GetChildren() do
					if not v2.Name:find("Boss") and QuestController.CurrentQuest == v2.Name then
						repeat task.wait()
							Tween(v2:GetPivot().Position + Vector3.new(0, 25, 0), 350)
						until GetMonsterName()
						break
					end
				end
			end
			task.wait(0.25)
		end
	end
end

boneNPCs = {
	"Reborn Skeleton",
	"Living Zombie",
	"Demonic Soul",
	"Posessed Mummy",
}
local function FarmBoneLogic()
    LogChange("bone_farm", "bone: searching for mobs")
	local mob = nil
	local min = math.huge
	for _, v in workspace.Enemies:GetChildren() do
		if v.PrimaryPart and v:FindFirstChildOfClass("Humanoid") and v.Humanoid.Health > 0 and table.find(boneNPCs, v.Name) then
			local dist = LocalPlayer:DistanceFromCharacter(v.PrimaryPart.Position)
			if dist < min then
				min = dist
				mob = v
			end
		end
	end
	if mob and mob.PrimaryPart and mob:FindFirstChildOfClass("Humanoid") and mob:FindFirstChildOfClass("Humanoid").Health > 0 then
        LogChange("bone_target", "bone: farming " .. string.lower(mob.Name))
        SetStatus("bone farm | " .. string.lower(mob.Name))
		TakeQuestBone(mob.Name)
		startKillThisNPC = tick()
		repeat
			task.wait()
			Tween(mob.PrimaryPart.CFrame * CFrame.new(0, 15, 5), 350)
			if LocalPlayer:DistanceFromCharacter(mob.PrimaryPart.Position) <= 210 then
				Tween(mob.PrimaryPart.CFrame * CFrame.new(0, 15, 5), math.huge)
				if LocalPlayer:DistanceFromCharacter(mob.PrimaryPart.Position) <= 30 then
					BringMob(mob.Name)
					EquipWeapon()
					Attack()
				end
			end
		until not mob or not mob.PrimaryPart or not mob:FindFirstChildOfClass("Humanoid") or mob.Humanoid.Health <= 0 or (tick() - startKillThisNPC) >= 90
	else
        LogChange("bone_target", "bone: waiting for spawn")
        SetStatus("bone farm | waiting for spawn")
		Tween(CFrame.new(-9515, 164, 5786), 350).Completed:Wait()
	end
end

local function FarmKataLogic()
    LogChange("cake_farm", "cake: checking prince")
	Travel.Sea3()
	if LocalPlayer:DistanceFromCharacter(Vector3.new(-2132, 70, -12319)) >= 1200 and not GetCakePrince() then
		Tween(CFrame.new(-2251, 146, -12196), 350).Completed:Wait()
	end
	if GetCakePrince() then
        LogChange("cake_target", "cake: fighting cake prince")
        SetStatus("cake farm | fighting cake prince")
		local Target = GetCakePrince()
		repeat
			if LocalPlayer:DistanceFromCharacter(Target.PrimaryPart.CFrame.Position) >= 1200 and GetCakePrince() then
				StopTween()
				Tween(workspace.Map.CakeLoaf.BigMirror.Main.CFrame, 350).Completed:Wait()
				task.wait(0.75)
			end
			Tween(Target.PrimaryPart.CFrame * CFrame.new(0, 17.5, 10), 350)
			if LocalPlayer:DistanceFromCharacter(Target.PrimaryPart.CFrame.Position) <= 200 then
				Tween(Target.PrimaryPart.CFrame * CFrame.new(0, 17.5, 10), math.huge)
				if LocalPlayer:DistanceFromCharacter(Target.PrimaryPart.CFrame.Position) <= 40 then
					EquipWeapon()
					Attack()
				end
			end
			task.wait()
		until not Target or not GetCakePrince() or Character.Humanoid.Health <= 0
	else
		local mob = nil
		local min = math.huge
		for _, v in workspace.Enemies:GetChildren() do
			if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
				local dist = LocalPlayer:DistanceFromCharacter(v.HumanoidRootPart.Position)
				if dist < min then
					min = dist
					mob = v
				end
			end
		end
		if mob and table.find(MobsCakePrince, mob.Name) and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
            LogChange("cake_target", "cake: farming " .. string.lower(mob.Name))
            SetStatus("cake farm | " .. string.lower(mob.Name))
			TakeQuestCake(mob.Name)
			startKillThisNPC = tick()
			repeat
				task.wait()
				Tween(mob.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0), 350)
				if LocalPlayer:DistanceFromCharacter(mob.HumanoidRootPart.Position) <= 200 then
					Tween(mob.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0), math.huge)
					if LocalPlayer:DistanceFromCharacter(mob.HumanoidRootPart.Position) <= 40 then
						BringMob(mob.Name)
						EquipWeapon()
						Attack()
					end
				end
			until not mob
				or not mob:FindFirstChild("Humanoid")
				or mob.Humanoid.Health <= 0
				or not mob:FindFirstChild("HumanoidRootPart")
				or (tick() - startKillThisNPC) >= 90
		end
	end
end

local function GetCDKLogic()
    LogChange("cdk", "cdk: checking progress")
	Travel.Sea3()
	if CommF_:InvokeServer("CDKQuest", "OpenDoor") == "can" then
		CommF_:InvokeServer("CDKQuest", "OpenDoor", true)
	end
	local q = CommF_:InvokeServer("CDKQuest", "Progress")
    LogChange("cdk_progress", "cdk: evil " .. tostring(q.Evil) .. " / good " .. tostring(q.Good))
	if q.Evil == 0 or q.Evil == -3 then
        LogChange("cdk_stage", "cdk: evil trial - mythological pirate")
        SetStatus("cdk | evil trial - mythological pirate")
		CommF_:InvokeServer("CDKQuest", "StartTrial", "Evil")
		if workspace.Enemies:FindFirstChild("Mythological Pirate") then
			repeat
				task.wait()
				Tween( workspace.Enemies:FindFirstChild("Mythological Pirate").HumanoidRootPart.CFrame * CFrame.new(5, 0, 0), 350 )
			until CommF_:InvokeServer("CDKQuest", "Progress").Evil ~= -3
				and GetMaterial("Alucard Fragment") == 1
		else
			Tween(Vector3.new(-13239, 520, -6813), 350).Completed:Wait()
		end
	elseif q.Evil == 1 or q.Evil == -4 then
        LogChange("cdk_stage", "cdk: evil trial - haze mobs")
        SetStatus("cdk | evil trial - haze mobs")
		CommF_:InvokeServer("CDKQuest", "StartTrial", "Evil")
		if LocalPlayer:FindFirstChild("QuestHaze") then
			for _, v in LocalPlayer.QuestHaze:GetChildren() do
				if v.Value > 0 then
                    LogChange("cdk_haze_target", "cdk: clearing " .. string.lower(v.Name) .. " " .. tostring(v.Value))
                    SetStatus("cdk | clearing " .. string.lower(v.Name))
					repeat
						task.wait()
						if LocalPlayer:DistanceFromCharacter( ReplicatedStorage.FortBuilderReplicatedSpawnPositionsFolder[v.Name].CFrame.Position ) >= 600 then
							Tween(ReplicatedStorage.FortBuilderReplicatedSpawnPositionsFolder[v.Name].CFrame, 350).Completed:Wait()
						end
						for _, v2 in workspace.Enemies:GetChildren() do
							if v2.Name == v.Name and v2:FindFirstChild("HumanoidRootPart") and v2:FindFirstChild("Humanoid") and v2.Humanoid.Health > 0 then
								repeat
									task.wait()
									Tween(v2.HumanoidRootPart.Position + Vector3.new(0, 25, 10), 350)
									if LocalPlayer:DistanceFromCharacter(v2.HumanoidRootPart.Position) <= 40 then
										BringMob(v2.Name)
										EquipWeapon()
										Attack()
									end
								until not v2.Humanoid or not v2.HumanoidRootPart or v2.Humanoid.Health <= 0 or not v2
								break
							end
						end
					until not v or v.Value == 0 or not LocalPlayer:FindFirstChild("QuestHaze")
				end
			end
		end
	elseif q.Evil == 2 or q.Evil == -5 then
        LogChange("cdk_stage", "cdk: evil trial - hell dimension")
        SetStatus("cdk | evil trial - hell dimension")
		CommF_:InvokeServer("CDKQuest", "StartTrial", "Evil")
		if workspace.Enemies:FindFirstChild("Soul Reaper") or workspace.Map:FindFirstChild("HellDimension") then
			if workspace.Enemies:FindFirstChild("Soul Reaper") and not workspace.Map:FindFirstChild("HellDimension") then
				repeat
					Tween(workspace.Enemies:FindFirstChild("Soul Reaper").HumanoidRootPart.CFrame, 350).Completed:Wait()
					task.wait()
				until workspace.Map:FindFirstChild("HellDimension")
			end
			if tw then
				tw:Cancel()
			end
			task.wait(1)
			for i = 1, 3 do
                LogChange("cdk_torch", "cdk: lighting hell torch " .. tostring(i) .. "/3")
                SetStatus("cdk | lighting hell torch " .. tostring(i) .. "/3")
				Tween(workspace.Map.HellDimension["Torch" .. i].CFrame, 350).Completed:Wait()
				fireproximityprompt(workspace.Map.HellDimension["Torch" .. i].ProximityPrompt)
				repeat
					task.wait()
				until #workspace.Enemies:GetChildren() > 0
				for _, v in workspace.Enemies:GetChildren() do
					if LocalPlayer:DistanceFromCharacter(v.HumanoidRootPart.CFrame.Position) <= 300 and v.HumanoidRootPart and v.Humanoid and v.Humanoid.Health > 0 then
						repeat
							task.wait()
							Tween(v.HumanoidRootPart.CFrame * CFrame.new(0, 25, 10), 350)
							if LocalPlayer:DistanceFromCharacter(v.HumanoidRootPart.Position) <= 210 then
								Tween(v.HumanoidRootPart.CFrame * CFrame.new(0, 25, 10), math.huge)
								if LocalPlayer:DistanceFromCharacter(v.HumanoidRootPart.Position) <= 40 then
									BringMob(v.Name)
									EquipWeapon()
									Attack()
								end
							end
						until not v
							or not v:FindFirstChild("Humanoid")
							or v.Humanoid.Health <= 0
							or not v:FindFirstChild("HumanoidRootPart")
					end
				end
			end
		else
			local boneNPCs = {
				"Reborn Skeleton",
				"Living Zombie",
				"Demonic Soul",
				"Posessed Mummy",
			}
			repeat
				task.wait()
				local mob = nil
				local min = math.huge
				for _, v in workspace.Enemies:GetChildren() do
					if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and table.find(boneNPCs, v.Name) then
						local dist = LocalPlayer:DistanceFromCharacter(v.HumanoidRootPart.Position)
						if dist < min then
							min = dist
							mob = v
						end
					end
				end
				if mob and mob.HumanoidRootPart and mob.Humanoid and mob.Humanoid.Health > 0 then
					repeat
						task.wait()
						Tween(mob.HumanoidRootPart.CFrame * CFrame.new(0, 15, 5), 350)
						if LocalPlayer:DistanceFromCharacter(mob.HumanoidRootPart.Position) <= 210 then
							Tween(mob.HumanoidRootPart.CFrame * CFrame.new(0, 15, 5), math.huge)
							if LocalPlayer:DistanceFromCharacter(mob.HumanoidRootPart.Position) <= 30 then
								BringMob(mob.Name)
								EquipWeapon()
								Attack()
							end
						end
					until not mob
						or not mob:FindFirstChild("Humanoid")
						or mob.Humanoid.Health <= 0
						or not mob:FindFirstChild("HumanoidRootPart")
				else
					Tween(CFrame.new(-9515, 164, 5786), 350).Completed:Wait()
				end
			until LocalPlayer.Backpack:FindFirstChild("Hallow Essence") or CheckMonster("Soul Reaper")
			if LocalPlayer.Backpack:FindFirstChild("Hallow Essence") then
				EquipTool("Hallow Essence")
				if Character:FindFirstChild("Hallow Essence") then
					firetouchinterest(Character.HumanoidRootPart, workspace.Map["Haunted Castle"].Summoner.Detection, 1)
					firetouchinterest(Character.HumanoidRootPart, workspace.Map["Haunted Castle"].Summoner.Detection, 0)
				end
			end
		end
	elseif q.Good == 0 or q.Good == -3 then
        LogChange("cdk_stage", "cdk: good trial - finding boats")
        SetStatus("cdk | good trial - finding boats")
		CommF_:InvokeServer("CDKQuest", "StartTrial", "Good")
		for _, x in {CFrame.new(-9550, 21, 4690), CFrame.new(-6120, 16, -2250), CFrame.new(-9530, 7, -8370)} do
			repeat
				LocalPlayer.Character.HumanoidRootPart.CFrame = x
				task.wait()
			until workspace.NPCs:FindFirstChildWhichIsA("Model")
				and workspace.NPCs:FindFirstChildWhichIsA("Model").Name:find("Boat")
			for _, n in workspace.NPCs:GetChildren() do
				if n.Name:find("Boat") then
					CommF_:InvokeServer("CDKQuest", "BoatQuest", n)
				end
			end
		end
	elseif q.Good == 1 or q.Good == -4 then
        LogChange("cdk_stage", "cdk: good trial - reaching objective")
        SetStatus("cdk | good trial - reaching objective")
		CommF_:InvokeServer("CDKQuest", "StartTrial", "Good")
		Tween(CFrame.new(6148.4116210938, 294.38687133789, -6741.1166992188), 350)
	elseif q.Good == 2 or q.Good == -5 then
        LogChange("cdk_stage", "cdk: good trial - heavenly dimension")
        SetStatus("cdk | good trial - heavenly dimension")
		CommF_:InvokeServer("CDKQuest", "StartTrial", "Good")
		if workspace.Map:FindFirstChild("HeavenlyDimension") ~= nil and workspace.Map:FindFirstChild("Heavenly Dimension") then
			if workspace.Map.HeavenlyDimension.Exit.Color ~= Color3.fromRGB(0, 0, 0) then
				firetouchinterest( workspace.Map.HeavenlyDimension.Exit.Touchinterest, LocalPlayer.Character.HumanoidRootPart, 0 )
			else
				for i = 1, 3 do
                    LogChange("cdk_heaven_torch", "cdk: lighting heaven torch " .. tostring(i) .. "/3")
                    SetStatus("cdk | lighting heaven torch " .. tostring(i) .. "/3")
					repeat
						task.wait()
						local e = workspace.Enemies:FindFirstChildWhichIsA("Model", true)
						if e and (e.Name:find("Cursed Skeleton") or e.Name:find("Heaven")) then
							KillMonster(e.Name)
						else
							if workspace.Map.HeavenlyDimension["Torch" .. i].ProximityPrompt.Enabled then
								Tween(workspace.Map.HeavenlyDimension["Torch" .. i].CFrame, 350).Completed:Wait()
								fireproximityprompt(workspace.Map.HeavenlyDimension["Torch" .. i].ProximityPrompt)
							end
						end
					until not workspace.Map.HeavenlyDimension["Torch" .. i].ProximityPrompt.Enabled
						or workspace.Map.HeavenlyDimension.Exit.Color ~= Color3.fromRGB(0, 0, 0)
						or Character.Humanoid.Health <= 0
					StopTween()
				end
			end
		else
			if CheckMonster("Cake Queen") then
				KillMonster("Cake Queen")
				StopTween()
			else
				HopLowServer()
			end
		end
	end
end

CheckedMelee = false
MeleeData = {

	BlackLeg = 0,
	Electro = 0,
	FishmanKarate = 0,

	SharkmanKarate = 0,
	DeathStep = 0,
	DragonClaw = 0,
	Superhuman = 0,

	ElectricClaw = 0,
	DragonTalon = 0,
	GodHuman = 0,
	SanguineArt = 0,
}

MeleePrices = {
	BlackLeg = {
		Price = {
			Beli = 150000,
		},
		Id = "BlackLeg",
		NextLevelRequirement = 400,
	},
	Electro = {
		Price = {
			Beli = 500000,
		},
		Id = "Electro",
		NextLevelRequirement = 400,
	},
	FishmanKarate = {
		Price = {
			Beli = 750000,
		},
		NextLevelRequirement = 400,
	},
	DragonClaw = {
		Price = {
			Fragments = 1500,
		},
		NextLevelRequirement = 400,
	},
	Superhuman = {
		Price = {
			Beli = 3000000,
		},
		NextLevelRequirement = 400,
	},
	DeathStep = {
		Price = {
			Beli = 2500000,
			Fragments = 5000,
		},
		NextLevelRequirement = 400,
	},
	SharkmanKarate = {
		Price = {
			Beli = 2500000,
			Fragments = 5000,
		},
		NextLevelRequirement = 400,
	},
	ElectricClaw = {
		Price = {
			Beli = 2500000,
			Fragments = 5000,
		},
		NextLevelRequirement = 400,
	},
	DragonTalon = {
		Price = {
			Beli = 2500000,
			Fragments = 5000,
		},
		NextLevelRequirement = 400,
	},
	Godhuman = {
		Price = {
			Beli = 5000000,
			Fragments = 5000,
		},
		NextLevelRequirement = 350,
	},
}

Name2Name = {
	["Water Kung Fu"] = "FishmanKarate",
	["Electric"] = "Electro",
	["Dark Step"] = "BlackLeg",
	["Dragon Breath"] = "DragonClaw",
}
local lastMeleeDataCheck = 0
local function CheckMeleeMastery()
	local now = tick()
	if (now - lastMeleeDataCheck) < 10 then
		return
	end
	lastMeleeDataCheck = now

	if not CheckedMelee then
        LogChange("melee_data", "melee: checking data")
	end

	local success = pcall(function()
		local data = IRS:GetItems(KEYS.MASTERY)
		for _, v in data do
			local matched = MATCH(v.ItemId)
			local item = matched and matched._ok
			if item and item.Index and item.Display then
				local n = item.Index.StorageKey
				if item.Display.Category == "Fighting Style" and n then
					local key = Name2Name[n] or n:gsub(" ", "")
					if MeleeData[key] ~= nil then
						MeleeData[key] = tonumber(v.Value) or MeleeData[key]
					end
				end
			end
		end
	end)

	if success then
		CheckedMelee = true
        LogChange("melee_data", "melee: data loaded")
    else
        LogChange("melee_data", "melee: data load failed")
	end
end

local CheckCanDungeon, AutoDungeon

local GetMeleeLogics = {
	SharkmanKarate = function()
		if not World.Sea2() then
			while true do
				CommF_:InvokeServer("TravelDressrosa")
				task.wait(10)
			end
		end
		local check = CommF_:InvokeServer("BuySharkmanKarate", true)
		if (not HasItem("Water Key")) and check ~= 0 and check ~= 1 and typeof(check) == "string" then
			if CheckMonster("Tide Keeper") then
				KillMonster("Tide Keeper")
			else
				HopLowServer()
				task.wait(5)
			end
		else
			TweenToMeleeBuyer("SharkmanKarate")
			CommF_:InvokeServer("BuySharkmanKarate", true)
			CommF_:InvokeServer("BuySharkmanKarate")
		end
	end,
	DeathStep = function()
		if not World.Sea2() then
			while true do
				CommF_:InvokeServer("TravelDressrosa")
				task.wait(10)
			end
		end
		local check = CommF_:InvokeServer("OpenLibrary")
		if not HasItem("Library Key") and not check then
			if CheckMonster("Awakened Ice Admiral") then
				KillMonster("Awakened Ice Admiral")
			else
				HopLowServer()
				task.wait(5)
			end
		elseif HasItem("Library Key") then
			CommF_:InvokeServer("OpenLibrary")
		elseif check == true then
			TweenToMeleeBuyer("DeathStep")
			CommF_:InvokeServer("BuyDeathStep")
		end
	end,
	ElectricClaw = function()
		Travel.Sea3()
		TweenToMeleeBuyer("ElectricClaw")
		CommF_:InvokeServer("BuyElectricClaw", "Start")
		Tween(CFrame.new(-12550, 336, -7510), 350).Completed:Wait()
		task.wait(0.5)
		TweenToMeleeBuyer("ElectricClaw")
		CommF_:InvokeServer("BuyElectricClaw")
	end,
	DragonTalon = function()
		Travel.Sea3()
		repeat
			task.wait()
			FarmBoneLogic()
			if GetMaterial("Bones") >= 50 then
				CommF_:InvokeServer("Bones", "Buy", 1, 1)
			end
		until HasItem("Fire Essence")
		TweenToMeleeBuyer("DragonTalon")
		CommF_:InvokeServer("BuyDragonTalon", true)
		CommF_:InvokeServer("BuyDragonTalon")
	end,
}

local function CheckYama()
	return CommF_:InvokeServer("EliteHunter", "Progress") or 0
end

local function MeleeKaitunLogic()
    LogChange("melee_logic", "melee: checking styles")
	if Character then
		local beli = LocalPlayer.Data.Beli.Value
		if not CollectionService:HasTag(Character, "Buso") and (beli >= 25000) then
			CommF_:InvokeServer("BuyHaki", "Buso")
		end
		if not CollectionService:HasTag(Character, "Geppo") and (beli >= 10000) then
			CommF_:InvokeServer("BuyHaki", "Geppo")
		end
		if not CollectionService:HasTag(Character, "Soru") and (beli >= 100000) then
			CommF_:InvokeServer("BuyHaki", "Soru")
		end
	else
		return
	end
	if not CheckedMelee then
		CheckMeleeMastery()
	end
	for _, v in {"BlackLeg", "Electro", "FishmanKarate"} do
		local realName = v:gsub("(%l)(%u)", "%1 %2")

			if (MeleeData[v] or 0) < 400 then
            LogChange("melee_progress", "melee: " .. string.lower(realName) .. " " .. tostring(MeleeData[v] or 0) .. "/400")

			if (MeleeData[v] or 0) == 0 and LocalPlayer.Data.Beli.Value < MeleePrices[v].Price.Beli then
                LogChange("melee_wait", "melee: need beli for " .. string.lower(realName))

				return
			end
			if not HasItem(realName) then
                LogChange("melee_action", "melee: getting " .. string.lower(realName))
				if not TweenToMeleeBuyer(v) then
					return
				end
				task.wait(0.5)
				CommF_:InvokeServer("Buy" .. v)
			end
			return
		end
	end

	if not World.Sea1() then
		for _, v in {"DragonClaw", "Superhuman", "DeathStep", "SharkmanKarate"} do
			local realName = v:gsub("(%l)(%u)", "%1 %2")
			if (MeleeData[v] or 0) < 400 then
				local hasEnoughEco = (
					(MeleePrices[v].Price.Beli == nil) or (LocalPlayer.Data.Beli.Value >= MeleePrices[v].Price.Beli)
				)
					and (
						(MeleePrices[v].Price.Fragments == nil)
						or (LocalPlayer.Data.Fragments.Value >= MeleePrices[v].Price.Fragments)
					)
				if (MeleeData[v] or 0) == 0 and hasEnoughEco then
                    LogChange("melee_action", "melee: unlocking " .. string.lower(realName))
					if v ~= "DragonClaw" and v ~= "Superhuman" then
						GetMeleeLogics[v]()
						return true
					else
						TweenToMeleeBuyer(v)
						if v == "Superhuman" then
							CommF_:InvokeServer("Buy" .. v)
						else
							CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "2")
						end
					end
				elseif (MeleeData[v] or 0) == 0 and (MeleePrices[v].Price.Fragments and (LocalPlayer.Data.Fragments.Value < MeleePrices[v].Price.Fragments)) and CheckCanDungeon() then
                    LogChange("melee_action", "melee: farming fragments")
					if (not World.Sea1()) and LocalPlayer.Data.Level.Value >= 1250 then
						AutoDungeon()
					end
				elseif (MeleeData[v] or 0) == 0 and not hasEnoughEco then
                    LogChange("melee_wait", "melee: waiting for " .. string.lower(realName) .. " resources")
				elseif (MeleeData[v] or 0) > 0 and not HasItem(realName) then
					if not TweenToMeleeBuyer(v) then
						break
					end
					if v == "DragonClaw" then
						CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "2")
					else
						CommF_:InvokeServer("Buy" .. v)
					end
				end
				return
			end
		end
		for _, v in {"ElectricClaw", "DragonTalon", "Godhuman"} do
			local realName = v:gsub("(%l)(%u)", "%1 %2")
			if (MeleeData[v] or 0) < 400 then
				local hasEnoughEco = (
					(MeleePrices[v].Price.Beli == nil) or (LocalPlayer.Data.Beli.Value >= MeleePrices[v].Price.Beli)
				)
					and (
						(MeleePrices[v].Price.Fragments == nil)
						or (LocalPlayer.Data.Fragments.Value >= MeleePrices[v].Price.Fragments)
					)
				if (MeleeData[v] or 0) == 0 and hasEnoughEco then
                    LogChange("melee_action", "melee: unlocking " .. string.lower(realName))
					if v == "Godhuman" then
						print("godhuman...")
						GetGodHuman()
					else
						GetMeleeLogics[v]()
					end
					return true
				elseif (MeleeData[v] or 0) == 0 and (MeleePrices[v].Price.Fragments and (LocalPlayer.Data.Fragments.Value < MeleePrices[v].Price.Fragments)) and CheckCanDungeon() then
					if (not World.Sea1()) and LocalPlayer.Data.Level.Value >= 1250 then
						AutoDungeon()
					end
				elseif (MeleeData[v] or 0) == 0 and not hasEnoughEco then
                    LogChange("melee_wait", "melee: waiting for " .. string.lower(realName) .. " resources")
				elseif (MeleeData[v] or 0) > 0 and not Character:FindFirstChild(realName) and not LocalPlayer.Backpack:FindFirstChild(realName) then
					if not TweenToMeleeBuyer(v) then
						break
					end
					CommF_:InvokeServer("Buy" .. v)
				end
				return
			end
		end
	end
end

KEYS = require(ReplicatedStorage.ItemReplicationService.KEYS)
IRS = require(ReplicatedStorage.ItemReplicationService)
MATCH = require(ReplicatedStorage.ItemConfig.Storage).match
local function GetUseableFruit()
	local data = IRS:GetItems(KEYS.QUANTITY)
	for _, v in data do
		local item = MATCH(v.ItemId)._ok
		if item.Display.Category == "Blox Fruit" and item.Quality.MoneyPrice < 1000000 then
			return item.Index.StorageKey
		end
	end
end

CheckCanDungeon = function()
	local res = CommF_:InvokeServer("RaidsNpc", "Select", "Dark")
	if HasItem("Special Microchip") then
		return true
	elseif GetUseableFruit() then
		return true
	elseif LocalPlayer.Data.Beli.Value >= 100000 and ((type(res) == "number" and res == 1) or (type(res) == "string" and not res:find("wait"))) then
		return true
	end
end

local RaidController = {
	isRaiding = false,
}
RaidController.RaidState_Connection = nil
if World.Sea2() or World.Sea3() then
	if ReplicatedStorage.Remotes:FindFirstChild("Raids") then
		while not RaidController.RaidState_Connection do
			RaidController.RaidState_Connection = ReplicatedStorage.Remotes.Raids.OnClientEvent:Connect(function(a)
				if a == "StartTimer" then
					RaidController.isRaiding = true
				else
					RaidController.isRaiding = false
				end
			end)
			task.wait(0.5)
		end
	end
end

local function KillAura(distance)
	for _, v in workspace.Enemies:GetChildren() do
		if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChildOfClass("Humanoid") then
			if LocalPlayer:DistanceFromCharacter(v.PrimaryPart.Position) <= distance then
				v.Humanoid:ChangeState(15)
			end
		end
	end
end

AutoDungeon = function()
    LogChange("raid", "raid: preparing")
	local res = CommF_:InvokeServer("RaidsNpc", "Select", "Dark")
	while not Character or not Character.PrimaryPart do
		task.wait()
	end
	if not RaidController.isRaiding then
		if not (LocalPlayer.Backpack:FindFirstChild("Special Microchip") or Character:FindFirstChild("Special Microchip")) then
            LogChange("raid_stage", "raid: getting microchip")
            SetStatus("raid | getting microchip")
			if LocalPlayer.Data.Beli.Value >= 100000 and ((type(res) == "number" and res == 1) or (type(res) == "string" and not res:find("wait"))) then
				CommF_:InvokeServer("RaidsNpc", "Select", "Dark")
			else
				PAUSE_AUTO_STORE = true
				CommF_:InvokeServer("LoadFruit", GetUseableFruit())
				task.wait(0.5)
				CommF_:InvokeServer("RaidsNpc", "Select", "Dark")
				PAUSE_AUTO_STORE = false
			end
		end
		if World.Sea2() then
            LogChange("raid_stage", "raid: summoning at sea 2")
            SetStatus("raid | summoning at sea 2")
			local clickDetector = workspace.Map.CircleIsland.RaidSummon2:FindFirstChildWhichIsA("ClickDetector", true)
			if clickDetector then
				pcall(fireclickdetector, clickDetector)
			end
		elseif World.Sea3() then
            LogChange("raid_stage", "raid: summoning at sea 3")
            SetStatus("raid | summoning at sea 3")
			Tween(Vector3.new(-5018, 315, -2828), 300).Completed:Wait()
			task.wait(1)
			local clickDetector = workspace.Map["Boat Castle"].RaidSummon2:FindFirstChildWhichIsA("ClickDetector", true)
			if clickDetector then
				pcall(fireclickdetector, clickDetector)
			end
		end
		local startWait = tick()
        LogChange("raid_state", "raid: waiting to join")
        SetStatus("raid | waiting to join")
		repeat
			SetStatus("raid | waiting to join")
			StopTween()
			task.wait(0.25)
		until RaidController.isRaiding or (tick() - startWait) >= 30
        LogChange("raid_state", RaidController.isRaiding and "raid: started" or "raid: join timed out")
        SetStatus(RaidController.isRaiding and "raid | started" or "raid | join timed out")
		task.wait(0.5)
		while RaidController.isRaiding do
            LogChange("raid_state", "raid: clearing island")
			SetStatus("raid | clearing island")
			for _, v in workspace.Enemies:GetChildren() do
				if v.PrimaryPart and v:FindFirstChildOfClass("Humanoid") and v:FindFirstChildOfClass("Humanoid").Health > 0 and LocalPlayer:DistanceFromCharacter(v.PrimaryPart.Position) <= 2000 then
					repeat
						task.wait()
						pcall(sethiddenproperty, LocalPlayer, "SimulationRadius", math.huge)
						pcall(function()
							Tween(v.PrimaryPart.Position + Vector3.new(0, 28, 15), 350)
							if LocalPlayer:DistanceFromCharacter(v.PrimaryPart.Position) <= 200 then
								Tween(v.PrimaryPart.Position + Vector3.new(0, 28, 15), math.huge)
								if LocalPlayer:DistanceFromCharacter(v.PrimaryPart.Position) <= 50 then
									EquipWeapon()
									Attack()
								end
							end
						end)
					until not v
						or not v.PrimaryPart
						or not v:FindFirstChildOfClass("Humanoid")
						or v:FindFirstChildOfClass("Humanoid").Health == 0
					break
				end
			end
			local found = false
			for i = 5, 1, -1 do
				for _, z in workspace["_WorldOrigin"].Locations:GetChildren() do
					if z.Name == ("Island " .. i) and LocalPlayer:DistanceFromCharacter( workspace["_WorldOrigin"].Locations["Island " .. i]:GetPivot().Position ) <= 6000 then
                        LogChange("raid_island", "raid: moving to island " .. tostring(i))
                        SetStatus("raid | moving to island " .. tostring(i))
						found = true
						Tween( workspace["_WorldOrigin"].Locations["Island " .. i]:GetPivot() * CFrame.new(100, 70, 100), 350 )
						task.wait(0.5)
						break
					end
				end
				if found then
					break
				end
			end
			task.wait()
		end
	end
	 task.wait(5)
    LogChange("raid_state", "raid: cycle ended")
end

local function GetYama()
    LogChange("yama", "yama: unlocking")
    SetStatus("yama | unlocking")
	repeat
		fireclickdetector(workspace.Map.Waterfall.SealedKatana.Hitbox.ClickDetector)
		task.wait(0.5)
	until LocalPlayer.Backpack:FindFirstChild("Yama")
end

local function CheckTushita()
	return LocalPlayer.Data.Level.Value >= 2200
end

local function GetTushita()
    LogChange("tushita", "tushita: checking progress")
	if not workspace.Map.Turtle:FindFirstChild("TushitaGate") then
        LogChange("tushita_stage", "tushita: defeating longma")
        SetStatus("tushita | defeating longma")
		if CheckMonster("Longma") then
			KillMonster("Longma")
		end
	elseif (function() for _, v in {workspace.Enemies, ReplicatedStorage} do for _, v2 in v:GetChildren() do if v2:IsA("Model") and v2:FindFirstChild("Humanoid") and v2.Humanoid.Health > 0 and v2.Name:find("indra") then
						return true
					end
				end
			end
		end)()
	then
		if not Character:FindFirstChild("Holy Torch") and not LocalPlayer.Backpack:FindFirstChild("Holy Torch") then
            LogChange("tushita_stage", "tushita: collecting holy torch")
            SetStatus("tushita | collecting holy torch")
			Tween(workspace.Map.Waterfall.SecretRoom.Room.Door.Door.Hitbox.CFrame, 350).Completed:Wait()
			task.wait(1)
		else
			for i = 1, 5, 1 do
                LogChange("tushita_torch", "tushita: lighting torch " .. tostring(i) .. "/5")
                SetStatus("tushita | lighting torch " .. tostring(i) .. "/5")
				EquipTool("Holy Torch")
				Tween(workspace.Map.Turtle.QuestTorches["Torch" .. tostring(i)].Particles.Main.Enabled, 350).Completed:Wait()
			end
		end
	end
end

local c = 0
local function AutoChest()
	local m = workspace.Map:GetDescendants()
	local h = Character:FindFirstChild("Humanoid") or false
	for i = 1, #m do
		local v = m[i]
		if v:IsA("BasePart") and v.Name:find("Chest") and (v.Name:match("%d+") or v.Name:find("Frag")) and v.CanTouch then
			if (function() for _, v in {Character, LocalPlayer.Backpack} do for _, v2 in v:GetChildren() do if v2.Name == "God's Chalice" or v2.Name == "Fist of Darkness" or v2.Name == "Sweet Chalice" then
								return true
							end
						end
					end
					return false
				end)()
			then
				break
			end
			if c >= 10 then
				c = 0
				h.Health = 0
			else
				if Character.PrimaryPart and Character:FindFirstChildOfClass("Humanoid") then
					if Character.Humanoid.Health > 0 then
						Character:SetPrimaryPartCFrame(v.CFrame * CFrame.new(0, 2, 0))
						c = c + 1
					end
				end
			end
			task.wait(0.2)
		end
	end
end

local function CheckHakiLegendInTitles(NAME_HAKI)
	local res, kl = pcall(function()
		CommF_:InvokeServer("getTitles")
	end)
	if not res or not kl or typeof(kl) ~= "table" then
		return false
	end
	local gg = kl[NAME_HAKI]
	if not gg then
		return false
	end
	for _, v in kl do
		if v.Unlocked and v.Description and v.Description:find(gg) then
			return true
		end
	end
	return false
end

local function GetTitle(title)
	local a = CommF_:InvokeServer("getTitles") or {}
	for _, v in a do
		if v.InternalName == title and v.Name ~= "(LOCKED)" then
			return true
		end
	end
	return false
end

SWAN_KILLED = false
if GetTitle("Heavenly Devil") then
	SWAN_KILLED = true
end
local function GetSwanKilled()
	return SWAN_KILLED
end

task.spawn(function()
	for _, v in {"EASTEREXP", "BANEXPLOIT", "NOMOREHACKS", "WildDares", "BossBuild", "GetPranked", "EARN_FRUITS", "Sub2UncleKizaru", "FIGHT4FRUIT", "kittgaming", "TRIPLEABUSE", "Sub2CaptainMaui", "Sub2Fer999", "Enyu_is_Pro", "Magicbus", "JCWK", "Starcodeheo", "Bluxxy", "SUB2GAMERROBOT_EXP1", "Sub2NoobMaster123", "Sub2Daigrock", "Axiore", "TantaiGaming", "StrawHatMaine", "Sub2OfficialNoobie", "TheGreatAce", "SEATROLLIN", "24NOADMIN", "ADMIN_TROLL", "NEWTROLL", "SECRET_ADMIN", "staffbattle", "NOEXPLOIT", "NOOB2ADMIN", "CODESLIDE", "fruitconcepts"} do
		ReplicatedStorage.Remotes.Redeem:InvokeServer(v)
	end
end)

task.spawn(function()
	while task.wait() do
		if LocalPlayer.Data.Points.Value > 0 then
			local Melee = LocalPlayer.Data.Stats.Melee.Level.Value
			local Defense = LocalPlayer.Data.Stats.Defense.Level.Value
			local Sword = LocalPlayer.Data.Stats.Sword.Level.Value
			CommF_:InvokeServer("AddPoint","Melee",LocalPlayer.Data.Level.Value * 2 - Melee)
			CommF_:InvokeServer("AddPoint","Defense",LocalPlayer.Data.Level.Value - Defense)
			if Melee == MaxLevel and Defense == MaxLevel then
				CommF_:InvokeServer("AddPoint","Sword",LocalPlayer.Data.Level.Value * 3 - MaxLevel * 2)
			end
		end
	end
end)

CAN_SPAWN_CAKE_PRINCE = true
task.spawn(function()
	while World.Sea3() do
		if CAN_SPAWN_CAKE_PRINCE then
			CommF_:InvokeServer("CakePrinceSpawner")
		end
		if GetMaterial("Bones") >= 50 then
			CommF_:InvokeServer("Bones", "Buy", 1, 1)
		end
		task.wait(0.5)
	end
end)

print("initialized")
task.spawn(function()
    print("main loop started")
	while task.wait() do
		if MeleeKaitunLogic() then
			continue
		end
		if Config.CursedDualKatana and (function() local b = 0 for i in {"Tushita", "Yama"} do if CheckItem(i) then
						LoadItem(i, "Sword")
						for _, v in {LocalPlayer.Backpack, Character} do
							if v.Name == i and v.ToolTip == "Sword" and v.Level.Value >= 350 then
								b = b + 1
							end
						end
					end
				end
				return b
			end)() == 2
			and LocalPlayer.Data.Level.Value >= 2200
		then
            LogChange("main_mode", "mode: cursed dual katana")
			GetCDKLogic()
		elseif Config.Saber and LocalPlayer.Data.Level.Value >= 200 and not CheckItem("Saber") then
            LogChange("main_mode", "mode: saber")
			GetSaber()
		elseif World.Sea3() and ( (HasItem("Sweet Chalice") or HasItem("Sweet Chalice")) or (function() for _, v in {workspace.Enemies, ReplicatedStorage} do for _, v2 in v:GetChildren() do if v2.Name:find("indra") or v2.Name:find("Dough King") then
								return true
							end
						end
					end
					return false
				end)()
			)
		then
            LogChange("main_mode", "mode: farm indra / dough king")
			if (function() for _, v in {workspace.Enemies, ReplicatedStorage} do for _, v2 in v:GetChildren() do if v2.Name:find("indra") or v2.Name:find("Dough King") then
								return true
							end
						end
					end
					return false
				end)()
			then
				for _, v in {workspace.Enemies, ReplicatedStorage} do
					for _, v2 in v:GetChildren() do
						if (v2.Name:find("indra") or v2.Name:find("Dough King")) and v2:FindFirstChildOfClass("Humanoid") then
							return KillMonster(v2.Name)
						end
					end
				end
			elseif HasItem("Sweet Chalice") then
				local msg = CommF_:InvokeServer("CakePrinceSpawner")
				if type(msg) == "string" and msg:find("defeat") then
					pcall(FarmKataLogic)
				end
			elseif HasItem("God's Chalice") then
				if (function() local b = 0 pcall(function() for _, v in workspace.Map["Boat Castle"].Summoner:GetChildren() do if v:IsA("Part") and v.Name == "Part" then
									if v.Color ~= Color3.fromRGB(99, 95, 98) then
										b = b + 1
									end
								end
							end
						end)
						return b
					end)() == 3
				then
					if not Character:FindFirstChild("God's Chalice") then
                        LogChange("chalice_stage", "chalice: summoning boss")
                        SetStatus("chalice | summoning boss")
						EquipTool("God's Chalice")
					end
					pcall(firetouchinterest, workspace.Map["Boat Castle"].Summoner.Detection, Character.PrimaryPart)
				else
					if GetMaterial("Conjured Cocoa") >= 10 then
						CommF_:InvokeServer("SweetChaliceNpc")
					else
						pcall(FarmMaterial, "Conjured Cocoa")
					end
				end
			end
		elseif LocalPlayer.Data.Level.Value >= 850 and not CheckItem("Warrior Helmet") then
            LogChange("main_mode", "mode: bartilo quest")
			DoBartiloQuest()
		elseif Config.RaceV3 and LocalPlayer.Data.Level.Value >= 850 and LocalPlayer.Data.Beli.Value >= 500000 and GetRaceGrade() == "V1" and CheckItem("Warrior Helmet") then
            LogChange("main_mode", "mode: race v2")
			DoRaceV2()
		elseif Config.RaceV3 and (LocalPlayer.Data.Level.Value >= 1000) and (LocalPlayer.Data.Beli.Value >= 2000000) and GetRaceGrade() == "V2" and GetSwanKilled() then
            LogChange("main_mode", "mode: race v3")
			DoRaceV3()
		elseif Config.CursedDualKatana and World.Sea3() and GetElite() then
            LogChange("main_mode", "mode: farm elite")
			pcall(function()
				for _, v2 in {workspace.Enemies, ReplicatedStorage} do
					for _, v in v2:GetChildren() do
						if v:IsA("Model") and v:GetAttribute("Level") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
							if table.find({"Tyrant of the Skies", "Diablo", "Urban", "Deandre"}, v.Name) then
								if QuestController.CurrentQuest:find(v.Name) then
									return KillMonster(v.Name)
								else
									CommF_:InvokeServer("EliteHunter")
								end
							end
						end
					end
				end
			end)
		elseif Config.SkullGuitar and LocalPlayer.Data.Level.Value >= 2300 then
            LogChange("main_mode", "mode: skull guitar")
			GetSG()
		elseif World.Sea3() and GetCastleRaid() and false then
			SetStatus("farm castle raid")
			if LocalPlayer:DistanceFromCharacter(Vector3.new(-5000, 350, -3035)) > 700 then
				CommF_:InvokeServer("requestEntrance", Vector3.new(-5000, 350, -3035))
			end
			for _, v in workspace.Enemies:GetChildren() do
				if v.PrimaryPart and v:FindFirstChild("Humanoid") and LocalPlayer:DistanceFromCharacter(v.WorldPivot.Position) <= 700 then
					repeat
						task.wait()
						EquipWeapon()
						Tween(v:GetPivot() * CFrame.new(0, 20, 10), 350)
						Attack()
					until not v or not v.PrimaryPart or not v:FindFirstChild("Humanoid") or v.Humanoid.Health <= 0
				end
				break
			end
		elseif World.Sea2() and workspace.Enemies:FindFirstChild("Factory") and false then
			SetStatus("farm factory")
			local coreEnemy = workspace.Enemies:FindFirstChild("Core")
			if coreEnemy and coreEnemy.Humanoid.Health > 0 then
				repeat
					task.wait()
					EquipWeapon()
					Tween(coreEnemy.HumanoidRootPart.CFrame, 300)
					Attack()
				until coreEnemy.Humanoid.Health <= 0
			end
		elseif Config.CursedDualKatana and CheckYama() >= 30 and not CheckItem("Yama") then
            LogChange("main_mode", "mode: get yama")
			SetStatus("yama | unlocking")
			GetYama()
		elseif Config.CursedDualKatana and World.Sea3() and not CheckItem("Tushita") and CheckMonster("rip_indra") then
            LogChange("main_mode", "mode: get tushita")

			GetTushita()
		elseif LocalPlayer.Data.Level.Value >= 700 and World.Sea1() then
            LogChange("main_mode", "mode: unlock second sea")
			UnlockSecondSea()
		elseif LocalPlayer.Data.Level.Value >= 1500 and World.Sea2() then
            LogChange("main_mode", "mode: unlock third sea")
			UnlockThirdSea()
		elseif World.Sea2() and CheckMonster("Darkbeard") then
			KillMonster("Darkbeard")
		else
            LogChange("main_mode", "mode: farm level")
            if not title.Text:find("^farm |") then
                SetStatus("farm level | level " .. tostring(LocalPlayer.Data.Level.Value))
            end
			if World.Sea2() then
				if HasItem("Hidden Key") and not CheckItem("Rengoku") then
					EquipTool("Hidden Key")
					Tween(CFrame.new(6571, 298, -6967), 300).Completed:Wait()
					task.wait(1)
				elseif HasItem("Library Key") and workspace.Map.IceCastle.Hall.LibraryDoor.PhoeyuDoor.Transparency == 0 then
					CommF_:InvokeServer("OpenLibrary")
					task.wait(1)
				elseif HasItem("Water Key") and CommF_:InvokeServer("BuySharkmanKarate", true):find("lost") then
					if TweenToMeleeBuyer("SharkmanKarate") then
						CommF_:InvokeServer("BuySharkmanKarate", true)
						CommF_:InvokeServer("BuySharkmanKarate")
					end
				end
			elseif World.Sea3() then
				if HasItem("Fire Essence") and CommF_:InvokeServer("BuyDragonTalon", true):find("your") then
					if TweenToMeleeBuyer("DragonTalon") then
						CommF_:InvokeServer("BuyDragonTalon", true)
						CommF_:InvokeServer("BuyDragonTalon")
					end
				end
			end
			if LocalPlayer.Data.Level.Value == MaxLevel then
				pcall(FarmKataLogic)
			else
				pcall(FarmLevelLogic)
			end
		end
	end
end)
