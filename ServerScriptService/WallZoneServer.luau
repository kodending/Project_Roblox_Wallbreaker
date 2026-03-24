local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage
	:WaitForChild("RemoteEvents")
	:WaitForChild("WallZoneEvent")

local waveStartRemote = ReplicatedStorage
	:WaitForChild("RemoteEvents")
	:WaitForChild("WaveStartEvent")

local returnRemote = ReplicatedStorage
	:WaitForChild("RemoteEvents")
	:WaitForChild("ReturnToPlazaEvent")

local RankConfig = require(ReplicatedStorage:WaitForChild("RankConfig"))

remote.OnServerEvent:Connect(function(player, action)

	if action ~= "EnterWallZone" then return end

	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	--------------------------------------------------
	-- 입구 위치 체크
	--------------------------------------------------

	local npcPart = workspace.PlazaMap
		:WaitForChild("WallZone_Teleport")
		:WaitForChild("cave-skull")

	if (root.Position - npcPart.Position).Magnitude > 35 then
		return
	end

	--------------------------------------------------
	-- 현재 랭크
	--------------------------------------------------

	local rank = player:GetAttribute("CurrentRank")

	if not rank or not RankConfig.Ranks[rank] then
		rank = "Unrank"
		player:SetAttribute("CurrentRank", "Unrank")
	end

	local config = RankConfig.Ranks[rank]
	if not config then return end

	--------------------------------------------------
	-- 맵 찾기
	--------------------------------------------------

	local map = workspace
		:WaitForChild("WallZoneMaps")
		:FindFirstChild(config.MapName)

	if not map then
		warn("WallZone map not found for rank:", rank)
		return
	end

	--------------------------------------------------
	-- 스폰 이동
	--------------------------------------------------

	local spawnPoint = map
		:WaitForChild("WallZone_Ground")
		:WaitForChild("TeleportPoint")

	root.CFrame = spawnPoint.CFrame

	--------------------------------------------------
	-- 클라이언트 맵 진입
	--------------------------------------------------

	remote:FireClient(player, "EnterMap", rank)

	--------------------------------------------------
	-- Wave 1 시작
	--------------------------------------------------
	
	if _G.StartPlayerWave then
		_G.StartPlayerWave(player)
	end

end)

--------------------------------------------------
-- Plaza 복귀
--------------------------------------------------

returnRemote.OnServerEvent:Connect(function(player)

	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local plazaSpawn = workspace.PlazaMap:WaitForChild("SpawnLocation")

	root.CFrame = plazaSpawn.CFrame

end)