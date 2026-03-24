local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local equipRemote = remoteFolder:WaitForChild("RequestEquipPet")
local unequipRemote = remoteFolder:WaitForChild("RequestUnequipPet")
local resultRemote = remoteFolder:WaitForChild("PetEquipResult")

local PetService = require(game.ServerScriptService:WaitForChild("PetService"))

--------------------------------------------------
-- 장착 결과 데이터 구성 (PetId 기반)
--------------------------------------------------

local function BuildEquippedData(player)

	local equippedData = {}

	local equippedList = PetService.GetEquipped(player)

	for slot = 1,3 do

		local petId = equippedList[slot]

		if petId then
			equippedData[slot] = {
				Slot = slot,
				PetId = petId
			}
		else
			equippedData[slot] = nil
		end

	end

	return equippedData
end

--------------------------------------------------
-- 장착 요청 (PetId 사용)
--------------------------------------------------

equipRemote.OnServerEvent:Connect(function(player, petId, slot)

	if not petId or not slot then return end

	local success = PetService.EquipPet(player, petId, slot)

	resultRemote:FireClient(player, {
		Success = success,
		Equipped = BuildEquippedData(player)
	})
end)

--------------------------------------------------
-- 해제 요청
--------------------------------------------------

unequipRemote.OnServerEvent:Connect(function(player, slot)

	if not slot then return end

	local success = PetService.UnequipPet(player, slot)

	resultRemote:FireClient(player, {
		Success = success,
		Equipped = BuildEquippedData(player)
	})
end)