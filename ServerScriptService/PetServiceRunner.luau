local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetService = require(script.Parent:WaitForChild("PetService"))

local resultRemote = ReplicatedStorage.RemoteEvents:WaitForChild("PetEquipResult")
local petListRemote = ReplicatedStorage.RemoteEvents:WaitForChild("PlayerPetList")

--------------------------------------------------
-- 장착 데이터 구성 (PetId 기반)
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
-- 클라이언트용 펫 데이터 생성 (핵심 수정)
--------------------------------------------------

local function BuildPetList(player)

	local rawPets = PetService.GetPlayerPets(player)
	local equipped = PetService.GetEquipped(player)

	local sendPets = {}

	-- 장착 맵 (PetId 기준)
	local equippedMap = {}

	for _, petId in ipairs(equipped) do
		if petId then
			equippedMap[petId] = true
		end
	end

	--------------------------------------------------
	-- ?? 구조 변경 핵심
	-- rawPets: { [petId] = {Enhance = n} }
	--------------------------------------------------

	for petId, petData in pairs(rawPets) do

		table.insert(sendPets, {
			PetId = petId,
			Enhance = petData.Enhance or 0,
			Equipped = equippedMap[petId] or false
		})

	end

	return sendPets

end

--------------------------------------------------
-- 플레이어 입장
--------------------------------------------------

Players.PlayerAdded:Connect(function(player)

	PetService.Load(player)

	task.wait(0.5)

	--------------------------------------------------
	-- 장착 상태 전송
	--------------------------------------------------

	local equippedData = BuildEquippedData(player)

	resultRemote:FireClient(player, {
		Success = true,
		Equipped = equippedData
	})

	--------------------------------------------------
	-- 펫 리스트 전송
	--------------------------------------------------

	local petList = BuildPetList(player)

	petListRemote:FireClient(player, petList)

end)

--------------------------------------------------
-- 플레이어 퇴장
--------------------------------------------------

Players.PlayerRemoving:Connect(function(player)

	PetService.Save(player)

end)

--------------------------------------------------
-- 서버 종료 시 저장
--------------------------------------------------

game:BindToClose(function()

	for _, player in ipairs(Players:GetPlayers()) do
		PetService.Save(player)
	end

end)