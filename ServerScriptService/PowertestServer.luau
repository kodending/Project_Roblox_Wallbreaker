local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PowertestEvent")

local RankConfig = require(ReplicatedStorage:WaitForChild("RankConfig"))

-- ? 서버 기준 상태 테이블
local PowerTestState = {}
-- [player] = { endTime = number }

local TotalDamage = {} -- [player] = number

---------------------------------------
-- 랭크 기록
---------------------------------------

local orderedRanks = {
	"SSS","SS","S","A","B","C","D","E","F"
}

local function GetPowerTestRank(totalDamage)

	for _, rankName in ipairs(orderedRanks) do
		local data = RankConfig.Ranks[rankName]
		if data and totalDamage >= (data.PowerTestScore or math.huge) then
			return rankName
		end
	end

	return "U"
end

remote.OnServerEvent:Connect(function(player, action)

	if action ~= "EnterPowertest" then return end

	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local npcPart = workspace.PlazaMap
		:WaitForChild("Powertest_Teleport")
		:WaitForChild("SM_Training_Dummie_Empire")

	if (root.Position - npcPart.Position).Magnitude > 35 then
		return
	end

	local spawnPoint = workspace.PowertestMap:WaitForChild("TeleportPoint")

	root.CFrame = spawnPoint.CFrame

	task.wait()

	remote:FireClient(player, "StartCamera")
	remote:FireClient(player, "ReadyStart")

	-- ? READY 3초 후 테스트 시작
	task.delay(3, function()

		-- 서버 기준 10초 기록
		PowerTestState[player] = {
			endTime = tick() + 10
		}
		
		local wallId = "PowertestDummy"
		local maxHP = 999999999 -- 충분히 큰 값

		-- 기존 Wall 서버 스크립트의 RegisterWall을 직접 호출하는 대신
		-- playerWalls 테이블에 직접 넣어준다.

		_G.RegisterPowerTestWall(player, wallId, maxHP)

		remote:FireClient(player, "StartTest")

		-- ? 10초 후 자동 종료
		task.delay(10, function()

			if PowerTestState[player] then
				PowerTestState[player] = nil

				local total = TotalDamage[player] or 0
				local newRank = GetPowerTestRank(total)

				--------------------------------------------------
				-- 최고 전투력 갱신
				--------------------------------------------------

				local currentBestPower = player:GetAttribute("CombatPower") or 0

				if total > currentBestPower then
					player:SetAttribute("CombatPower", total)
				end

				--------------------------------------------------
				-- 최고 랭크 갱신
				--------------------------------------------------

				local rankOrder = {
					Unrank = 0,
					F = 1, E = 2, D = 3, C = 4,
					B = 5, A = 6, S = 7,
					SS = 8, SSS = 9
				}

				local currentRank = player:GetAttribute("CurrentRank") or "Unrank"

				local newRankValue = rankOrder[newRank] or 0
				local currentRankValue = rankOrder[currentRank] or 0

				if newRankValue > currentRankValue then
					player:SetAttribute("CurrentRank", newRank)
				end
				-- ? 종료 UI 신호
				remote:FireClient(player, "TestEndNotice", total, newRank)
				
				TotalDamage[player] = 0
				
				_G.ResetPlayer(player)

				task.wait(2)

				-- ? 카메라 복원
				remote:FireClient(player, "EndCamera")

				local plazaSpawn = workspace.PlazaMap:WaitForChild("SpawnLocation")
				local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if root then
					root.CFrame = plazaSpawn.CFrame
				end
			end

		end)

	end)
end)

_G.IsPowerTestActive = function(player)
	local state = PowerTestState[player]
	if not state then return false end

	if tick() > state.endTime then
		PowerTestState[player] = nil
		return false
	end

	return true
end

_G.AddPowerTestDamage = function(player, damage)
	TotalDamage[player] = (TotalDamage[player] or 0) + damage
end