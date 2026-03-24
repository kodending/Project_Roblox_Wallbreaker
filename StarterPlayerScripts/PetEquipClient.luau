local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local resultRemote = remoteFolder:WaitForChild("PetEquipResult")

--------------------------------------------------
-- 클라이언트 장착 상태 캐시
--------------------------------------------------

local equippedSlots = {
	[1] = nil,
	[2] = nil,
	[3] = nil
}

--------------------------------------------------
-- 결과 수신
--------------------------------------------------

resultRemote.OnClientEvent:Connect(function(data)

	if not data then return end

	if data.Success then
		print("장착 성공")
	else
		print("장착 실패")
	end

	local equipped = data.Equipped or {}

	-- 슬롯 초기화
	equippedSlots[1] = nil
	equippedSlots[2] = nil
	equippedSlots[3] = nil

	--------------------------------------------------
	-- ?? UID 제거 → PetId만 사용
	--------------------------------------------------

	for slot = 1,3 do

		local pet = equipped[slot]

		if pet then
			equippedSlots[slot] = {
				PetId = pet.PetId
			}
		end

	end

	print("현재 장착 상태:", equippedSlots)

end)