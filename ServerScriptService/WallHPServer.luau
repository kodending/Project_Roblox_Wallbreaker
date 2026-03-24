local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")

local hitRemote = remoteFolder:WaitForChild("WallHitEvent")
local hpUpdateRemote = remoteFolder:WaitForChild("WallHPUpdate")
local registerRemote = remoteFolder:WaitForChild("WallRegister")
local breakRemote = remoteFolder:WaitForChild("WallBreakStage")
local attackStartRemote = remoteFolder:WaitForChild("AttackStartEvent")
local popupRemote = remoteFolder:WaitForChild("DamagePopupEvent")
local goldRewardRemote = remoteFolder:WaitForChild("GoldRewardEvent")
local waveClearRemote = remoteFolder:WaitForChild("WaveClearEvent")
local waveStartRemote = remoteFolder:WaitForChild("WaveStartEvent")
local returnRemote = remoteFolder:WaitForChild("ReturnToPlazaEvent")

local SoundManager = require(ReplicatedStorage.SoundManager)

--------------------------------------------------
-- 플레이어 데이터
--------------------------------------------------

local playerWalls = {}
local playerStages = {}
local playerWave = {}

--------------------------------------------------
-- 플레이어 상태 초기화
--------------------------------------------------

_G.ResetPlayer = function(player)

	playerWalls[player] = nil
	playerStages[player] = nil
	playerWave[player] = nil

end

Players.PlayerRemoving:Connect(function(player)
	_G.ResetPlayer(player)
end)

--------------------------------------------------
-- 광장 복귀 시 초기화
--------------------------------------------------

returnRemote.OnServerEvent:Connect(function(player)
	_G.ResetPlayer(player)
end)

--------------------------------------------------
-- Wave 배수 계산
--------------------------------------------------

local function GetWaveRewardMultiplier(wave)

	local step = math.floor((wave-1)/5)
	return 1 + (step * 0.5)

end

local function GetWaveHPMultiplier(wave)

	local step = math.floor((wave-1)/5)
	return 1 + (step * 0.4)

end

--------------------------------------------------
-- Wave 보너스
--------------------------------------------------

local function GiveWaveBonus(player)

	local wave = playerWave[player] or 1

	if wave % 5 ~= 0 then return end

	local bonus = wave * 50

	local gold = tonumber(player:GetAttribute("Gold")) or 0
	player:SetAttribute("Gold", gold + bonus)

end

--------------------------------------------------
-- Wave 시작
--------------------------------------------------

local function StartWave(player)

	playerWave[player] = (playerWave[player] or 0) + 1

	print("Start Wave :", playerWave[player])

	GiveWaveBonus(player)

	waveStartRemote:FireClient(player, playerWave[player])

end

--------------------------------------------------
-- 외부 Wave 시작 호출
--------------------------------------------------

_G.StartPlayerWave = function(player)

	playerWave[player] = 0
	StartWave(player)

end

--------------------------------------------------
-- Wave Clear 체크
--------------------------------------------------

local function CheckWaveClear(player)

	local walls = playerWalls[player]
	if not walls then return end

	for _, data in pairs(walls) do
		if not data.Destroyed then
			return
		end
	end

	StartWave(player)

	waveClearRemote:FireClient(player)

end

--------------------------------------------------
-- 벽 등록
--------------------------------------------------

local function RegisterWall(player, wallId, maxHP, reward, position)

	playerWalls[player] = playerWalls[player] or {}
	playerStages[player] = playerStages[player] or {}

	local wave = playerWave[player] or 1

	local hpMul = GetWaveHPMultiplier(wave)
	local rewardMul = GetWaveRewardMultiplier(wave)

	local finalHP = math.floor(maxHP * hpMul)
	local finalReward = math.floor((reward or 0) * rewardMul)

	playerWalls[player][wallId] = {
		MaxHP = finalHP,
		HP = finalHP,
		Reward = finalReward,
		Position = position,
		Destroyed = false
	}

	playerStages[player][wallId] = 0
	
	hpUpdateRemote:FireClient(player, wallId, finalHP, finalHP)
end

registerRemote.OnServerEvent:Connect(function(player, wallId, maxHP, reward, position)
	RegisterWall(player, wallId, maxHP, reward, position)
end)

--------------------------------------------------
-- 데미지 처리
--------------------------------------------------

hitRemote.OnServerEvent:Connect(function(player, wallId)

	if not playerWalls[player] then return end
	if not playerWalls[player][wallId] then return end

	local wallData = playerWalls[player][wallId]

	if wallData.Destroyed then return end

	local damage, isCrit = _G.CalculateFinalDamage(player)
	if not damage then return end

	popupRemote:FireClient(player, damage, isCrit)

	if _G.IsPowerTestActive and _G.IsPowerTestActive(player) then
		if _G.AddPowerTestDamage then
			_G.AddPowerTestDamage(player, damage)
		end
		return
	end

	wallData.HP -= damage
	if wallData.HP < 0 then
		wallData.HP = 0
	end

	hpUpdateRemote:FireClient(player, wallId, wallData.HP, wallData.MaxHP)

	local maxHP = wallData.MaxHP
	local currentHP = wallData.HP

	local newStage = 0
	if currentHP <= maxHP * 0.75 then newStage = 1 end
	if currentHP <= maxHP * 0.50 then newStage = 2 end
	if currentHP <= maxHP * 0.25 then newStage = 3 end

	local previousStage = playerStages[player][wallId] or 0

	if newStage > previousStage then
		playerStages[player][wallId] = newStage
		breakRemote:FireClient(player, wallId, newStage)
	end

	if wallData.HP <= 0 and not wallData.Destroyed then

		wallData.Destroyed = true

		local reward = tonumber(wallData.Reward) or 0

		if reward > 0 then
			local currentGold = tonumber(player:GetAttribute("Gold")) or 0
			player:SetAttribute("Gold", currentGold + reward)

			goldRewardRemote:FireClient(player, reward, wallData.Position)
		end

		breakRemote:FireClient(player, wallId, "Final")
		
		SoundManager.Play("Break_Wall")

		CheckWaveClear(player)

	end

end)

--------------------------------------------------
-- 더블 공격 판정
--------------------------------------------------

attackStartRemote.OnServerEvent:Connect(function(player, wallId)

	local baseDouble = tonumber(player:GetAttribute("DoubleChance")) or 0
	local petDouble = tonumber(player:GetAttribute("PetDoubleChance")) or 0

	local totalDouble = baseDouble + petDouble

	local isDouble = math.random(1,100) <= totalDouble

	attackStartRemote:FireClient(player, wallId, isDouble)

end)

--------------------------------------------------
-- PowerTest 전용 벽 등록
--------------------------------------------------

_G.RegisterPowerTestWall = function(player, wallId, maxHP)

	playerWalls[player] = playerWalls[player] or {}
	playerStages[player] = playerStages[player] or {}

	playerWalls[player][wallId] = {
		MaxHP = maxHP,
		HP = maxHP,
		Reward = 0,
		Position = nil,
		Destroyed = false
	}

	playerStages[player][wallId] = 0

end