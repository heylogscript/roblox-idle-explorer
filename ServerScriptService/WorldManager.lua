local WorldManager = {}
WorldManager.__index = WorldManager

local Debris = game:GetService("Debris")

function WorldManager.new(constants, artifactData, remotes)
	local self = setmetatable({}, WorldManager)
	self.Constants = constants
	self.ArtifactData = artifactData
	self.Remotes = remotes
	self.Zones = {}
	self.Gates = {}
	self.Artifacts = {}
	self.NPCs = {}
	self.GameManager = nil
	return self
end

function WorldManager:SetGameManager(gm)
	self.GameManager = gm
end

function WorldManager:Build()
	local zonesFolder = Instance.new("Folder")
	zonesFolder.Name = "Zones"
	zonesFolder.Parent = workspace

	for _, zoneDef in ipairs(self.Constants.ZONES) do
		local zonePart = Instance.new("Part")
		zonePart.Name = zoneDef.name
		zonePart.Size = zoneDef.size
		zonePart.CFrame = CFrame.new(zoneDef.center)
		zonePart.Anchored = true
		zonePart.CanCollide = false
		zonePart.Transparency = 0.8
		zonePart.Color = zoneDef.color
		zonePart.Material = Enum.Material.Neon
		zonePart.Parent = zonesFolder

		local value = Instance.new("NumberValue")
		value.Name = "ZoneIndex"
		value.Value = zoneDef.index
		value.Parent = zonePart

		self.Zones[zoneDef.index] = {
			definition = zoneDef,
			part = zonePart,
			isOpen = zoneDef.index == 1,
			artifacts = {},
		}
	end

	local gatesFolder = Instance.new("Folder")
	gatesFolder.Name = "Gates"
	gatesFolder.Parent = workspace

	for i = 2, #self.Constants.ZONES do
		local prev = self.Constants.ZONES[i - 1]
		local curr = self.Constants.ZONES[i]
		local midZ = (prev.center.Z + prev.size.Z / 2 + curr.center.Z - curr.size.Z / 2) / 2

		local wall = Instance.new("Part")
		wall.Name = "Gate_" .. i
		wall.Size = Vector3.new(100, 8, 1)
		wall.CFrame = CFrame.new(0, 4, midZ)
		wall.Anchored = true
		wall.CanCollide = true
		wall.BrickColor = BrickColor.new("Really red")
		wall.Material = Enum.Material.Neon
		wall.Parent = gatesFolder

		local prompt = Instance.new("BillboardGui")
		prompt.Name = "GatePrompt"
		prompt.Size = UDim2.new(0, 200, 0, 50)
		prompt.StudsOffset = Vector3.new(0, 5, 0)
		prompt.AlwaysOnTop = true
		prompt.Parent = wall

		local txt = Instance.new("TextLabel")
		txt.Name = "Label"
		txt.Size = UDim2.new(1, 0, 1, 0)
		txt.BackgroundTransparency = 1
		txt.Text = "ZONE " .. i .. ": " .. curr.name .. "\nCost: " .. curr.entryCost .. " Memes"
		txt.TextColor3 = curr.color
		txt.TextScaled = true
		txt.Font = Enum.Font.GothamBold
		txt.Parent = prompt

		self.Gates[i] = {
			zoneIndex = i,
			part = wall,
			cost = curr.entryCost,
			isOpen = false,
		}
	end

	-- NPCs decorativos
	local npcFolder = Instance.new("Folder")
	npcFolder.Name = "NPCs"
	npcFolder.Parent = workspace

	for _, zoneDef in ipairs(self.Constants.ZONES) do
		local x = zoneDef.center.X - zoneDef.size.X / 2 + 10
		local z = zoneDef.center.Z

		local parts = {}
		for _, partData in ipairs({
			{name = "Head", size = Vector3.new(2, 2, 2), pos = Vector3.new(x, 5.5, z), shape = Enum.PartType.Ball, color = zoneDef.color},
			{name = "Torso", size = Vector3.new(2, 2.5, 1.2), pos = Vector3.new(x, 3.25, z), color = zoneDef.color},
		}) do
			local p = Instance.new("Part")
			p.Name = partData.name
			p.Size = partData.size
			p.CFrame = CFrame.new(partData.pos)
			p.Anchored = true
			p.CanCollide = false
			p.Color = partData.color
			p.Material = Enum.Material.SmoothPlastic
			p.Parent = npcFolder
			parts[partData.name] = p
		end

		local bg = Instance.new("BillboardGui")
		bg.Name = "ZoneName"
		bg.Size = UDim2.new(0, 160, 0, 30)
		bg.StudsOffset = Vector3.new(0, 6, 0)
		bg.AlwaysOnTop = true
		bg.Parent = parts["Head"]

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = zoneDef.name
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Parent = bg
	end

	self:SpawnZoneArtifacts(1)
end

function WorldManager:SpawnZoneArtifacts(zoneIdx)
	local zone = self.Zones[zoneIdx]
	if not zone or not zone.isOpen then return end

	local def = zone.definition
	local count = math.random(def.minArtifacts, def.maxArtifacts)

	local folderName = "Zone" .. zoneIdx .. "Artifacts"
	local folder = workspace:FindFirstChild(folderName)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = folderName
		folder.Parent = workspace
	end

	for i = 1, count do
		self:SpawnArtifact(zoneIdx, folder)
	end
end

function WorldManager:SpawnArtifact(zoneIdx, parentFolder)
	local zone = self.Zones[zoneIdx]
	if not zone then return end

	local def = zone.definition
	local halfX = def.size.X / 2 - 5
	local halfZ = def.size.Z / 2 - 5
	local x = def.center.X + math.random() * halfX * 2 - halfX
	local z = def.center.Z + math.random() * halfZ * 2 - halfZ

	local color = self.ArtifactData.GetRandomColor()

	local part = Instance.new("Part")
	part.Name = "Artifact"
	part.Size = Vector3.new(5, 5, 5)
	part.Shape = Enum.PartType.Ball
	part.CFrame = CFrame.new(x, 4, z)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.3
	part.Color = color
	part.Material = Enum.Material.Neon
	part.Parent = parentFolder or workspace

	local light = Instance.new("PointLight")
	light.Name = "Light"
	light.Brightness = 4
	light.Range = 16
	light.Color = color
	light.Parent = part

	local attachment = Instance.new("Attachment")
	attachment.Name = "ParticleAttach"
	attachment.Parent = part

	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "Glow"
	emitter.Rate = 10
	emitter.Lifetime = NumberRange.new(0.8, 1.2)
	emitter.SpreadAngle = Vector2.new(0, 180)
	emitter.VelocityInheritance = 0
	emitter.Speed = NumberRange.new(0.3, 0.8)
	emitter.Texture = "rbxasset://textures/particles/sparkle_03.png"
	emitter.Size = NumberSequence.new(0.5)
	emitter.Transparency = NumberSequence.new(0.3, 0.9)
	emitter.Color = ColorSequence.new(color)
	emitter.Parent = attachment

	local clickDetector = Instance.new("ClickDetector")
	clickDetector.Name = "ClickDetector"
	clickDetector.MaxActivationDistance = 60
	clickDetector.Parent = part

	clickDetector.MouseClick:Connect(function(player)
		if self.GameManager then
			self.GameManager:HandleCollect(player, part)
		end
	end)

	local zVal = Instance.new("NumberValue")
	zVal.Name = "ZoneIndex"
	zVal.Value = zoneIdx
	zVal.Parent = part

	zone.artifacts[part] = true

	return part
end

function WorldManager:HandleCollect(player, artifactPart)
	if not artifactPart or not artifactPart.Parent then return nil end

	local zoneIdx = artifactPart:FindFirstChild("ZoneIndex")
	if not zoneIdx then return nil end

	local zIdx = zoneIdx.Value
	local zone = self.Zones[zIdx]
	if not zone or not zone.isOpen then return nil end

	local def = zone.definition
	local baseValue = self.Constants.BASE_ARTIFACT_VALUE + def.artifactValue

	zone.artifacts[artifactPart] = nil
	local pos = artifactPart.Position
	local folder = artifactPart.Parent

	-- Spawn particles on destroy
	local boom = Instance.new("ParticleEmitter")
	boom.Rate = 0
	boom.Lifetime = NumberRange.new(0.3, 0.6)
	boom.SpreadAngle = Vector2.new(0, 360)
	boom.Speed = NumberRange.new(2, 6)
	boom.Texture = "rbxasset://textures/particles/sparkle_03.png"
	boom.Size = NumberSequence.new(0.5)
	boom.Transparency = NumberSequence.new(0, 1)
	boom.Color = ColorSequence.new(artifactPart.Color)
	boom.Parent = artifactPart
	boom:Emit(12)

	artifactPart:Destroy()

	task.delay(self.Constants.ARTIFACT_RESPAWN_TIME, function()
		if zone and zone.isOpen then
			self:SpawnArtifact(zIdx, folder)
		end
	end)

	return baseValue, pos, artifactPart.Color
end

function WorldManager:OpenGate(gateIdx)
	local gate = self.Gates[gateIdx]
	if not gate or gate.isOpen then return end

	gate.isOpen = true
	gate.part.CanCollide = false
	gate.part.Transparency = 0.9

	-- Particles on gate
	local emitter = Instance.new("ParticleEmitter")
	emitter.Rate = 30
	emitter.Lifetime = NumberRange.new(0.5, 1)
	emitter.SpreadAngle = Vector2.new(0, 90)
	emitter.Speed = NumberRange.new(1, 4)
	emitter.Texture = "rbxasset://textures/particles/sparkle_03.png"
	emitter.Size = NumberSequence.new(0.4)
	emitter.Transparency = NumberSequence.new(0.3, 1)
	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 100))
	emitter.Parent = gate.part
	task.delay(1.5, function()
		if emitter and emitter.Parent then
			emitter.Rate = 0
			task.delay(1, function() emitter:Destroy() end)
		end
	end)

	local zone = self.Zones[gate.zoneIndex]
	if zone then
		zone.isOpen = true
		self:SpawnZoneArtifacts(gate.zoneIndex)
	end

	self.Remotes.UpdateWorldState:FireAllClients(self:GetWorldState())
	self.Remotes.ShowGateFx:FireAllClients(gate.zoneIndex, self.Constants.ZONES[gate.zoneIndex].name)
end

function WorldManager:GetWorldState()
	local state = {zones = {}, gates = {}}
	for idx, zone in pairs(self.Zones) do
		state.zones[idx] = {name = zone.definition.name, isOpen = zone.isOpen, index = idx}
	end
	for idx, gate in pairs(self.Gates) do
		state.gates[idx] = {isOpen = gate.isOpen, cost = gate.cost, zoneName = self.Zones[gate.zoneIndex] and self.Zones[gate.zoneIndex].definition.name or ""}
	end
	return state
end

return WorldManager
