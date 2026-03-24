local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("WallZoneEvent")

local RankConfig = require(ReplicatedStorage:WaitForChild("RankConfig"))

local prompt = workspace.PlazaMap
	:WaitForChild("WallZone_Teleport")
	:WaitForChild("cave-skull") -- 네 Part 이름으로 수정
	:WaitForChild("ProximityPrompt")

prompt.Triggered:Connect(function(player)
	remote:FireClient(player, "OpenUI")
end)