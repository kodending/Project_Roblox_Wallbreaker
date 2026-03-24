local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PowertestEvent")

local prompt = workspace.PlazaMap
	:WaitForChild("Powertest_Teleport")
	:WaitForChild("SM_Training_Dummie_Empire") -- 네 Part 이름으로 수정
	:WaitForChild("ProximityPrompt")

prompt.Triggered:Connect(function(player)
	remote:FireClient(player, "OpenUI")
end)