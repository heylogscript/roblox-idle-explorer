local ArtifactData = {}

local artifactNames = {
	"Shiny Skibidi",
	"Glowing Gyatt",
	"Mysterious Rizz",
	"Lost Meme",
	"Fanum Fragment",
	"Brainrot Crystal",
	"Sigma Essence",
	"Tung Tung Shard",
	"Tralalero Note",
	"Grimace Drop",
	"Ohio Relic",
	"Hawk Tuah Feather",
	"Bruno's Mic",
	"Alpha Gem",
	"Mega Orb",
}

function ArtifactData.GetRandomName()
	return artifactNames[math.random(1, #artifactNames)]
end

local artifactColors = {
	Color3.fromRGB(255, 255, 100),
	Color3.fromRGB(100, 255, 100),
	Color3.fromRGB(100, 200, 255),
	Color3.fromRGB(255, 100, 255),
	Color3.fromRGB(255, 180, 100),
	Color3.fromRGB(255, 100, 100),
}

function ArtifactData.GetRandomColor()
	return artifactColors[math.random(1, #artifactColors)]
end

return ArtifactData
