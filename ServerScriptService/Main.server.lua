local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local function requireSafe(container, name)
	local module = container:FindFirstChild(name)
	if module then
		local s, r = pcall(require, module)
		if s then return r end
		warn("BrainrotIdle: fail require " .. name .. ": " .. tostring(r))
	end
	return nil
end

local Constants = requireSafe(ReplicatedStorage, "Constants")
local ArtifactData = requireSafe(ReplicatedStorage, "ArtifactData")
local Remotes = requireSafe(ReplicatedStorage, "RemoteHandler")
local WorldManager = requireSafe(ServerScriptService, "WorldManager")
local GameManager = requireSafe(ServerScriptService, "GameManager")

if not Constants or not ArtifactData or not Remotes or not WorldManager or not GameManager then
	warn("BrainrotIdle: missing required modules")
	return
end

local worldManager = WorldManager.new(Constants, ArtifactData, Remotes)
worldManager:Build()

local gameManager = GameManager.new(Constants, worldManager, Remotes)
gameManager:Init()
worldManager:SetGameManager(gameManager)

game:GetService("Game").BindToClose(function()
	gameManager:Cleanup()
end)

print("BrainrotIdle exploration game started!")
