local Remotes = {}

local remoteDefs = {
	CollectArtifact = "RemoteEvent",
	BuyGate = "RemoteEvent",
	BuyUpgrade = "RemoteEvent",
	Rebirth = "RemoteEvent",
	GetPlayerData = "RemoteFunction",
	GetWorldState = "RemoteFunction",
	GetLeaderboard = "RemoteFunction",
	UpdatePlayerData = "RemoteEvent",
	UpdateWorldState = "RemoteEvent",
	ShowCollectionFx = "RemoteEvent",
	ShowGateFx = "RemoteEvent",
}

for name, className in pairs(remoteDefs) do
	local existing = script:FindFirstChild(name)
	if existing then
		Remotes[name] = existing
	else
		local inst = Instance.new(className)
		inst.Name = name
		inst.Parent = script
		Remotes[name] = inst
	end
end

return Remotes
