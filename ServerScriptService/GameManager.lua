local GameManager = {}
GameManager.__index = GameManager

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

function GameManager.new(constants, worldManager, remotes)
	local self = setmetatable({}, GameManager)
	self.Constants = constants
	self.WorldManager = worldManager
	self.Remotes = remotes
	self.PlayerData = {}
	self.DataStore = DataStoreService:GetDataStore("BrainrotExploreData")
	self.TickConn = nil
	return self
end

function GameManager:Init()
	self.TickConn = game:GetService("RunService").Stepped:Connect(function(_, dt)
		self:Tick(dt)
	end)

	self.Remotes.CollectArtifact.OnServerEvent:Connect(function(pl, artifactPart)
		self:HandleCollect(pl, artifactPart)
	end)

	self.Remotes.BuyGate.OnServerEvent:Connect(function(pl, gateIdx)
		self:HandleBuyGate(pl, gateIdx)
	end)

	self.Remotes.BuyUpgrade.OnServerEvent:Connect(function(pl, upgradeId)
		self:HandleBuyUpgrade(pl, upgradeId)
	end)

	self.Remotes.Rebirth.OnServerEvent:Connect(function(pl)
		self:HandleRebirth(pl)
	end)

	self.Remotes.GetPlayerData.OnServerInvoke = function(pl)
		return self:GetPlayerData(pl)
	end

	self.Remotes.GetWorldState.OnServerInvoke = function(pl)
		return self.WorldManager:GetWorldState()
	end

	self.Remotes.GetLeaderboard.OnServerInvoke = function(pl)
		return self:GetLeaderboardData()
	end

	Players.PlayerAdded:Connect(function(pl)
		self:LoadPlayer(pl)
	end)

	Players.PlayerRemoving:Connect(function(pl)
		self:SavePlayer(pl)
	end)

	for _, pl in Players:GetPlayers() do
		self:LoadPlayer(pl)
	end

	print("GameManager initialized")
end

function GameManager:GetOrCreateData(player)
	local uid = player.UserId
	if not self.PlayerData[uid] then
		self.PlayerData[uid] = {
			memes = 0,
			totalMemesEarned = 0,
			artifactsCollected = 0,
			upgrades = {},
			rebirthCount = 0,
			rebirthMultiplier = 1,
			lastSaveTime = tick(),
		}
	end
	return self.PlayerData[uid]
end

function GameManager:GetClickValue(data)
	local clickPower = (data.upgrades["click_power"] or 0) * self.Constants.UPGRADES[1].effect
	return self.Constants.BASE_ARTIFACT_VALUE + clickPower
end

function GameManager:GetRegen(data)
	local regen = (data.upgrades["regen_speed"] or 0) * self.Constants.UPGRADES[2].effect
	return regen * data.rebirthMultiplier
end

function GameManager:GetCollectionRange(data)
	return 4 + (data.upgrades["collect_range"] or 0) * self.Constants.UPGRADES[3].effect
end

function GameManager:GetUpgradeCost(upgradeId, level)
	for _, def in ipairs(self.Constants.UPGRADES) do
		if def.id == upgradeId then
			return math.floor(def.cost * (def.costMult ^ level))
		end
	end
	return 999999
end

function GameManager:GetPlayerData(player)
	local data = self:GetOrCreateData(player)
	local upgrades = {}
	for _, def in ipairs(self.Constants.UPGRADES) do
		local level = data.upgrades[def.id] or 0
		upgrades[def.id] = {level = level, cost = self:GetUpgradeCost(def.id, level), maxed = level >= def.maxLevel}
	end
	return {
		memes = math.floor(data.memes),
		totalMemesEarned = math.floor(data.totalMemesEarned),
		artifactsCollected = data.artifactsCollected,
		upgrades = upgrades,
		rebirthCount = data.rebirthCount,
		rebirthMultiplier = data.rebirthMultiplier,
		clickValue = self:GetClickValue(data),
		regen = self:GetRegen(data),
		collectionRange = self:GetCollectionRange(data),
	}
end

function GameManager:SendUpdate(player)
	local data = self.PlayerData[player.UserId]
	if data then
		self.Remotes.UpdatePlayerData:FireClient(player, self:GetPlayerData(player))
	end
end

function GameManager:Tick(dt)
	local now = tick()
	for _, player in Players:GetPlayers() do
		local data = self.PlayerData[player.UserId]
		if data then
			local regen = self:GetRegen(data)
			local earned = regen * dt
			data.memes = data.memes + earned
			data.totalMemesEarned = data.totalMemesEarned + earned

			-- Auto-collect
			local range = self:GetCollectionRange(data)
			if range > 4 then
				local char = player.Character
				if char then
					local hrp = char:FindFirstChild("HumanoidRootPart")
					if hrp then
						self:TryAutoCollect(player, data, hrp.Position, range)
					end
				end
			end

			if now - data.lastSaveTime > self.Constants.AUTO_SAVE_INTERVAL then
				data.lastSaveTime = now
				self:SavePlayer(player)
			end
		end
	end
end

function GameManager:TryAutoCollect(player, data, pos, range)
	local closest = nil
	local closestDist = range
	for _, zone in pairs(self.WorldManager.Zones) do
		for part in pairs(zone.artifacts) do
			if part and part.Parent then
				local dist = (part.Position - pos).Magnitude
				if dist < closestDist then
					closestDist = dist
					closest = part
				end
			end
		end
	end
	if closest then
		self:HandleCollect(player, closest)
	end
end

function GameManager:HandleCollect(player, artifactPart)
	local data = self:GetOrCreateData(player)
	local value, pos, color = self.WorldManager:HandleCollect(player, artifactPart)
	if not value then return end

	local clickValue = self:GetClickValue(data)
	local totalValue = value + clickValue
	totalValue = math.floor(totalValue * data.rebirthMultiplier)

	data.memes = data.memes + totalValue
	data.totalMemesEarned = data.totalMemesEarned + totalValue
	data.artifactsCollected = data.artifactsCollected + 1

	self:SendUpdate(player)
	if pos and self.Remotes.ShowCollectionFx then
		self.Remotes.ShowCollectionFx:FireClient(player, totalValue, pos, color or Color3.fromRGB(255, 255, 100))
	end
end

function GameManager:HandleBuyGate(player, gateIdx)
	local data = self:GetOrCreateData(player)
	local gate = self.WorldManager.Gates[gateIdx]
	if not gate or gate.isOpen then return end
	if data.memes >= gate.cost then
		data.memes = data.memes - gate.cost
		self.WorldManager:OpenGate(gateIdx)
		self:SendUpdate(player)
	end
end

function GameManager:HandleBuyUpgrade(player, upgradeId)
	local data = self:GetOrCreateData(player)
	local currentLevel = data.upgrades[upgradeId] or 0
	for _, def in ipairs(self.Constants.UPGRADES) do
		if def.id == upgradeId then
			if currentLevel >= def.maxLevel then return end
			local cost = self:GetUpgradeCost(upgradeId, currentLevel)
			if data.memes >= cost then
				data.memes = data.memes - cost
				data.upgrades[upgradeId] = currentLevel + 1
				self:SendUpdate(player)
			end
			return
		end
	end
end

function GameManager:HandleRebirth(player)
	local data = self:GetOrCreateData(player)
	if data.totalMemesEarned < self.Constants.REBIRTH_MEME_COST then return end
	data.rebirthCount = data.rebirthCount + 1
	data.rebirthMultiplier = 1 + data.rebirthCount * self.Constants.REBIRTH_MULT_PER
	data.memes = 0
	data.upgrades = {}
	self:SendUpdate(player)
end

function GameManager:GetLeaderboardData()
	local entries = {}
	for _, player in Players:GetPlayers() do
		local data = self.PlayerData[player.UserId]
		if data then
			table.insert(entries, {username = player.Name, displayName = player.DisplayName, memes = math.floor(data.totalMemesEarned), rebirths = data.rebirthCount})
		end
	end
	table.sort(entries, function(a, b) return a.memes > b.memes end)
	return entries
end

function GameManager:LoadPlayer(player)
	local uid = tostring(player.UserId)
	local data = self:GetOrCreateData(player)
	local success, savedData = pcall(function() return self.DataStore:GetAsync(uid) end)
	if success and savedData then
		for k, v in pairs(savedData) do
			if data[k] ~= nil then data[k] = v end
		end
	end
	self:SendUpdate(player)
end

function GameManager:SavePlayer(player)
	local uid = tostring(player.UserId)
	local data = self.PlayerData[player.UserId]
	if not data then return end
	local saveData = {
		memes = data.memes,
		totalMemesEarned = data.totalMemesEarned,
		artifactsCollected = data.artifactsCollected,
		upgrades = data.upgrades,
		rebirthCount = data.rebirthCount,
		rebirthMultiplier = data.rebirthMultiplier,
	}
	pcall(function() self.DataStore:SetAsync(uid, saveData) end)
end

function GameManager:SaveAll()
	for _, player in Players:GetPlayers() do self:SavePlayer(player) end
end

function GameManager:Cleanup()
	if self.TickConn then self.TickConn:Disconnect(); self.TickConn = nil end
	self:SaveAll()
end

return GameManager
