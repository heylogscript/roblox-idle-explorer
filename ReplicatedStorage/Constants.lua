local Constants = {}

Constants.ZONES = {
	{
		name = "Common Fields",
		index = 1,
		center = Vector3.new(0, 0, 0),
		size = Vector3.new(80, 1, 80),
		color = Color3.fromRGB(120, 120, 120),
		entryCost = 0,
		artifactValue = 1,
		minArtifacts = 6,
		maxArtifacts = 10,
	},
	{
		name = "Uncommon Meadow",
		index = 2,
		center = Vector3.new(0, 0, 60),
		size = Vector3.new(100, 1, 60),
		color = Color3.fromRGB(100, 200, 100),
		entryCost = 250,
		artifactValue = 3,
		minArtifacts = 5,
		maxArtifacts = 8,
	},
	{
		name = "Rare Ridge",
		index = 3,
		center = Vector3.new(0, 0, 130),
		size = Vector3.new(120, 1, 60),
		color = Color3.fromRGB(80, 150, 255),
		entryCost = 2000,
		artifactValue = 10,
		minArtifacts = 4,
		maxArtifacts = 7,
	},
	{
		name = "Epic Expanse",
		index = 4,
		center = Vector3.new(0, 0, 200),
		size = Vector3.new(140, 1, 60),
		color = Color3.fromRGB(180, 80, 255),
		entryCost = 25000,
		artifactValue = 35,
		minArtifacts = 3,
		maxArtifacts = 6,
	},
	{
		name = "Legendary Summit",
		index = 5,
		center = Vector3.new(0, 0, 270),
		size = Vector3.new(160, 1, 60),
		color = Color3.fromRGB(255, 180, 50),
		entryCost = 300000,
		artifactValue = 120,
		minArtifacts = 3,
		maxArtifacts = 5,
	},
}

Constants.ARTIFACT_RESPAWN_TIME = 8
Constants.BASE_ARTIFACT_VALUE = 5

Constants.UPGRADES = {
	{
		id = "click_power",
		name = "Click Power",
		desc = "More memes per artifact collected",
		cost = 50,
		costMult = 2.5,
		effect = 1,
		maxLevel = 20,
	},
	{
		id = "regen_speed",
		name = "Meme Regen",
		desc = "Passive memes per second",
		cost = 100,
		costMult = 3,
		effect = 0.5,
		maxLevel = 30,
	},
	{
		id = "collect_range",
		name = "Collection Range",
		desc = "Auto-collect nearby artifacts",
		cost = 200,
		costMult = 2.2,
		effect = 2,
		maxLevel = 15,
	},
}

Constants.REBIRTH_MEME_COST = 50000
Constants.REBIRTH_MULT_PER = 2

Constants.AUTO_SAVE_INTERVAL = 30

return Constants
