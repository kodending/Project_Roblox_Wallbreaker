local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local ownedUpdateRemote = remoteFolder:WaitForChild("AnimationOwnedUpdate")
local ownedInitRemote = remoteFolder:WaitForChild("AnimationOwnedInit")
local equippedInitRemote = remoteFolder:WaitForChild("AnimationEquippedInit")

local DataStoreService = game:GetService("DataStoreService")
local animationStore = DataStoreService:GetDataStore("PlayerAnimations_test_v11")

local AnimationService = {}

local playerAnimations = {}

local DirtyFlag = {}

--------------------------------------------------
-- Player 초기화
--------------------------------------------------

function AnimationService.InitPlayer(player)
	
	local data = {
		Owned = {
			Normal_01 = true,
			Double_01 = true
		},
		
		Equipped = {
			Normal = "Normal_01",
			Double = "Double_01"
		}
	}

	local success, savedData = pcall(function()
		return animationStore:GetAsync(player.UserId)
	end)

	if success and savedData then
		data = savedData
	end

	playerAnimations[player] = data
	
	task.wait(1)
	
	ownedInitRemote:FireClient(player, data.Owned)
	equippedInitRemote:FireClient(player, data.Equipped)
end

--------------------------------------------------
-- 애니메이션 지급
--------------------------------------------------

function AnimationService.GrantAnimation(player, animId)

	local data = playerAnimations[player]
	if not data then return end

	data.Owned[animId] = true

	ownedUpdateRemote:FireClient(player, animId)

	print("Animation Added:", animId)

end

--------------------------------------------------
-- 애니메이션 적용
--------------------------------------------------

function AnimationService.EquipAnimation(player, animType, animId)

	local data = playerAnimations[player]
	if not data then return end

	data.Equipped = data.Equipped or {}

	data.Equipped[animType] = animId

	-- 바로 저장
	DirtyFlag[player] = true

end

--------------------------------------------------
-- 보유 여부
--------------------------------------------------

function AnimationService.HasAnimation(player, animId)

	local data = playerAnimations[player]
	if not data then return false end

	return data.Owned[animId] == true

end

--------------------------------------------------
-- Player 연결
--------------------------------------------------

Players.PlayerAdded:Connect(function(player)
	AnimationService.InitPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)


	local data = playerAnimations[player]
	if not data then return end

	local success, err = pcall(function()
		for i=1,5 do

			local success = pcall(function()
				animationStore:SetAsync(player.UserId, data)
			end)

			if success then break end

			task.wait(2)

		end
	end)

	print("Animation Save:", player.UserId, success, err)

	playerAnimations[player] = nil

end)

task.spawn(function()

	while true do

		task.wait(300)

		for player,data in pairs(playerAnimations) do

			if DirtyFlag[player] then

				for i=1,5 do

					local success = pcall(function()
						animationStore:SetAsync(player.UserId, data)
					end)

					if success then
						DirtyFlag[player] = false
						break
					end

					task.wait(2)

				end

			end

		end

	end

end)

return AnimationService