local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local Remotes = require(ReplicatedStorage:WaitForChild("RemoteHandler"))
local Constants = require(ReplicatedStorage:WaitForChild("Constants"))

local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local function make(c, p)
	local i = Instance.new(c)
	for k, v in pairs(p) do i[k] = v end
	return i
end

-- Top bar
make("Frame", {
	Parent = screenGui, Name = "TopBar",
	Size = UDim2.new(1, 0, 0, 75),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.45, BorderSizePixel = 0,
})

local memeLabel = make("TextLabel", {
	Parent = screenGui.TopBar, Name = "MemeLabel",
	Size = UDim2.new(0, 300, 0, 32),
	Position = UDim2.new(0.5, -150, 0, 4),
	BackgroundTransparency = 1,
	Text = "0 Memes",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.GothamBold, TextSize = 26,
})

local mpsLabel = make("TextLabel", {
	Parent = screenGui.TopBar, Name = "MPSLabel",
	Size = UDim2.new(0, 200, 0, 20),
	Position = UDim2.new(0.5, -100, 0, 38),
	BackgroundTransparency = 1,
	Text = "+0/s",
	TextColor3 = Color3.fromRGB(150, 200, 150),
	Font = Enum.Font.Gotham, TextSize = 15,
})

local zoneLabel = make("TextLabel", {
	Parent = screenGui.TopBar, Name = "ZoneLabel",
	Size = UDim2.new(0, 180, 0, 18),
	Position = UDim2.new(0.01, 0, 0.05, 0),
	BackgroundTransparency = 1,
	Text = "Common Fields",
	TextColor3 = Color3.fromRGB(180, 180, 180),
	Font = Enum.Font.Gotham, TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
})

local clickValLabel = make("TextLabel", {
	Parent = screenGui.TopBar, Name = "ClickValLabel",
	Size = UDim2.new(0, 180, 0, 18),
	Position = UDim2.new(0.01, 0, 0.48, 0),
	BackgroundTransparency = 1,
	Text = "Click: +5",
	TextColor3 = Color3.fromRGB(150, 200, 255),
	Font = Enum.Font.Gotham, TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
})

local artifactCountLabel = make("TextLabel", {
	Parent = screenGui.TopBar, Name = "ArtifactCountLabel",
	Size = UDim2.new(0, 180, 0, 18),
	Position = UDim2.new(0.01, 0, 0.74, 0),
	BackgroundTransparency = 1,
	Text = "Artifacts: 0",
	TextColor3 = Color3.fromRGB(200, 180, 255),
	Font = Enum.Font.Gotham, TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
})

-- Rebirth btn
local rebirthBtn = make("TextButton", {
	Parent = screenGui, Name = "RebirthBtn",
	Size = UDim2.new(0, 140, 0, 36),
	Position = UDim2.new(1, -155, 0, 20),
	Text = "Rebirth",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundColor3 = Color3.fromRGB(200, 60, 60),
	Font = Enum.Font.GothamBold, TextSize = 14,
	BorderSizePixel = 0,
})

-- Rebirth multiplier display 
local multLabel = make("TextLabel", {
	Parent = screenGui, Name = "MultLabel",
	Size = UDim2.new(0, 140, 0, 16),
	Position = UDim2.new(1, -155, 0, 58),
	BackgroundTransparency = 1,
	Text = "x1 mult",
	TextColor3 = Color3.fromRGB(255, 200, 100),
	Font = Enum.Font.Gotham, TextSize = 12,
})

-- Right panel
local rightPanel = make("Frame", {
	Parent = screenGui, Name = "RightPanel",
	Size = UDim2.new(0, 260, 0, 420),
	Position = UDim2.new(1, -275, 0.5, -210),
	BackgroundColor3 = Color3.fromRGB(10, 10, 25),
	BackgroundTransparency = 0.2, BorderSizePixel = 0,
})

make("TextLabel", {
	Parent = rightPanel, Name = "Title",
	Size = UDim2.new(1, 0, 0, 28),
	BackgroundTransparency = 1,
	Text = "Upgrades", TextColor3 = Color3.fromRGB(255, 200, 100),
	Font = Enum.Font.GothamBold, TextSize = 16,
})

local upgradesContainer = make("ScrollingFrame", {
	Parent = rightPanel, Name = "UpgradeList",
	Size = UDim2.new(1, -10, 1, -34),
	Position = UDim2.new(0, 5, 0, 32),
	BackgroundTransparency = 1,
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
	CanvasSize = UDim2.new(0, 0, 0, 0),
})

-- Tutorial text
local tutorialText = make("TextLabel", {
	Parent = screenGui, Name = "TutorialText",
	Size = UDim2.new(0, 400, 0, 50),
	Position = UDim2.new(0.5, -200, 0.5, 80),
	BackgroundTransparency = 1,
	Text = "Walk around and click on glowing artifacts to collect Memes!",
	TextColor3 = Color3.fromRGB(255, 255, 200),
	Font = Enum.Font.GothamBold, TextSize = 18,
	TextStrokeTransparency = 0.3,
})

-- Gate opened notification
local gateNotif = make("TextLabel", {
	Parent = screenGui, Name = "GateNotif",
	Size = UDim2.new(0, 400, 0, 40),
	Position = UDim2.new(0.5, -200, 0.5, -40),
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = Color3.fromRGB(100, 255, 100),
	Font = Enum.Font.GothamBold, TextSize = 22,
	TextStrokeTransparency = 0.3,
	Visible = false,
})

-- Floating collection effect handler
local function showFloatingText(value, worldPos, color)
	local bg = Instance.new("BillboardGui")
	bg.Name = "CollectFX"
	bg.Size = UDim2.new(0, 120, 0, 30)
	bg.StudsOffset = Vector3.new(0, 1, 0)
	bg.AlwaysOnTop = true
	bg.Parent = workspace

	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(1, 0, 1, 0)
	txt.BackgroundTransparency = 1
	txt.Text = "+" .. value .. " Memes!"
	txt.TextColor3 = color or Color3.fromRGB(255, 255, 100)
	txt.TextScaled = true
	txt.Font = Enum.Font.GothamBold
	txt.Parent = bg

	local tween = game:GetService("TweenService"):Create(bg,
		TweenInfo.new(1.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{StudsOffset = Vector3.new(0, 4, 0)}
	)
	local tween2 = game:GetService("TweenService"):Create(txt,
		TweenInfo.new(1.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{TextTransparency = 1}
	)
	tween:Play()
	tween2:Play()
	task.delay(1.3, function()
		if bg then bg:Destroy() end
	end)
end

-- Gate opened notification
local function showGateNotification(zoneName)
	gateNotif.Text = "Zona desbloqueada: " .. zoneName .. "!"
	gateNotif.Visible = true
	gateNotif.TextTransparency = 0
	task.delay(3, function()
		gateNotif.Visible = false
	end)
end

-- Game state
local gameData = {
	memes = 0, totalMemesEarned = 0, artifactsCollected = 0,
	upgrades = {}, rebirthCount = 0, rebirthMultiplier = 1,
	clickValue = 5, regen = 0, collectionRange = 4,
}
local worldState = {zones = {}, gates = {}}

function formatNumber(n)
	if n >= 1e9 then return string.format("%.2fB", n / 1e9)
	elseif n >= 1e6 then return string.format("%.2fM", n / 1e6)
	elseif n >= 1e3 then return string.format("%.1fK", n / 1e3)
	else return string.format("%.0f", n) end
end

function updateUI()
	memeLabel.Text = formatNumber(gameData.memes) .. " Memes"
	mpsLabel.Text = "+" .. formatNumber(gameData.regen) .. "/s"
	clickValLabel.Text = "Click: +" .. formatNumber(gameData.clickValue)
	artifactCountLabel.Text = "Artifacts: " .. gameData.artifactsCollected
	multLabel.Text = "x" .. formatNumber(gameData.rebirthMultiplier) .. " mult"
	rebirthBtn.Text = "Rebirth (" .. gameData.rebirthCount .. ")"
end

function refreshData()
	local s, d = pcall(function() return Remotes.GetPlayerData:InvokeServer() end)
	if s and d then gameData = d; updateUI() end
	local s2, ws = pcall(function() return Remotes.GetWorldState:InvokeServer() end)
	if s2 and ws then worldState = ws; updateZoneLabel() end
end

function updateZoneLabel()
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local pos = hrp.Position
	local currentZone = "Unknown"
	for _, zone in pairs(worldState.zones) do
		local def = Constants.ZONES[zone.index]
		if def then
			local hx, hz = def.size.X / 2, def.size.Z / 2
			if pos.X >= def.center.X - hx and pos.X <= def.center.X + hx and pos.Z >= def.center.Z - hz and pos.Z <= def.center.Z + hz then
				currentZone = zone.name; break
			end
		end
	end
	zoneLabel.Text = currentZone
end

-- Click detection (gates only - artifacts use ClickDetector)
mouse.Button1Down:Connect(function()
	if not mouse.Target then return end
	local t = mouse.Target
	if string.find(t.Name or "", "Gate_") then
		local idx = tonumber(string.match(t.Name, "_(%d+)"))
		if idx then Remotes.BuyGate:FireServer(idx) end
	end
end)

-- Rebirth
rebirthBtn.MouseButton1Click:Connect(function()
	Remotes.Rebirth:FireServer()
	task.wait(0.2); refreshData()
end)

-- Upgrade panel
function loadUpgrades()
	for _, c in upgradesContainer:GetChildren() do c:Destroy() end
	local y = 0
	for _, def in ipairs(Constants.UPGRADES) do
		local ug = gameData.upgrades[def.id]
		local level = ug and ug.level or 0
		local cost = ug and ug.cost or def.cost
		local maxed = ug and ug.maxed or false
		local card = make("Frame", {
			Parent = upgradesContainer, Name = def.id,
			Size = UDim2.new(1, 0, 0, 56),
			Position = UDim2.new(0, 0, 0, y),
			BackgroundColor3 = Color3.fromRGB(25, 25, 45), BorderSizePixel = 0,
		})
		make("TextLabel", {
			Parent = card, Size = UDim2.new(1, -80, 0, 20), Position = UDim2.new(0, 8, 0, 4),
			BackgroundTransparency = 1,
			Text = def.name .. " (" .. level .. "/" .. def.maxLevel .. ")",
			TextColor3 = Color3.fromRGB(200, 200, 200), Font = Enum.Font.GothamBold, TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		make("TextLabel", {
			Parent = card, Size = UDim2.new(1, -80, 0, 18), Position = UDim2.new(0, 8, 0, 26),
			BackgroundTransparency = 1, Text = def.desc,
			TextColor3 = Color3.fromRGB(140, 140, 140), Font = Enum.Font.Gotham, TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		if not maxed then
			local btn = make("TextButton", {
				Parent = card, Size = UDim2.new(0, 72, 0, 28), Position = UDim2.new(1, -78, 0, 14),
				Text = formatNumber(cost), TextColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundColor3 = Color3.fromRGB(60, 100, 60), Font = Enum.Font.Gotham, TextSize = 12,
				BorderSizePixel = 0,
			})
			btn.MouseButton1Click:Connect(function()
				Remotes.BuyUpgrade:FireServer(def.id)
				task.wait(0.15); refreshData(); loadUpgrades()
			end)
		else
			make("TextLabel", {
				Parent = card, Size = UDim2.new(0, 72, 0, 28), Position = UDim2.new(1, -78, 0, 14),
				BackgroundTransparency = 1, Text = "MAX",
				TextColor3 = Color3.fromRGB(255, 200, 50), Font = Enum.Font.GothamBold, TextSize = 14,
			})
		end
		y = y + 60
	end
	upgradesContainer.CanvasSize = UDim2.new(0, 0, 0, y + 5)
end

-- Refresh loop
task.spawn(function()
	while true do
		refreshData()
		loadUpgrades()
		task.wait(2)
	end
end)

-- Floating collection effect from server
Remotes.ShowCollectionFx.OnClientEvent:Connect(function(value, worldPos, color)
	showFloatingText(value, worldPos, color)
end)

-- Gate opened effect
Remotes.ShowGateFx.OnClientEvent:Connect(function(zoneIdx, zoneName)
	showGateNotification(zoneName)
end)

-- Server push
Remotes.UpdatePlayerData.OnClientEvent:Connect(function(data)
	if data then gameData = data; updateUI() end
end)

Remotes.UpdateWorldState.OnClientEvent:Connect(function(ws)
	if ws then worldState = ws end
end)

-- Tutorial fade
task.delay(5, function()
	if not tutorialText or not tutorialText.Parent then return end
	local tween = game:GetService("TweenService"):Create(tutorialText,
		TweenInfo.new(1.5, Enum.EasingStyle.Linear),
		{TextTransparency = 1})
	tween:Play()
	task.delay(1.6, function()
		if tutorialText then tutorialText:Destroy() end
	end)
end)

refreshData()
