local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local equipRemote = remoteFolder:WaitForChild("AnimationEquipRequest")
local equippedUpdateRemote = remoteFolder:WaitForChild("AnimationEquippedUpdate")

local AnimationService = require(script.Parent:WaitForChild("AnimationService"))



equipRemote.OnServerEvent:Connect(function(player, animType, animId)

	if not AnimationService.HasAnimation(player, animId) then
		return
	end

	AnimationService.EquipAnimation(player, animType, animId)
	
	equippedUpdateRemote:FireClient(player, animType, animId)
end)