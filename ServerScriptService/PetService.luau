local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local PetConfig = require(game.ReplicatedStorage:WaitForChild("PetConfig"))
local PetDataStore = DataStoreService:GetDataStore("PlayerPets_test_v53")

local PetService = {}

--------------------------------------------------
-- 서버 메모리
--------------------------------------------------

local PetCache = {}
local DirtyFlag = {}

--------------------------------------------------
-- 기본 데이터
--------------------------------------------------

local function CreateDefaultData()
	return {
		Pets = {}, -- [petId] = { Enhance = number }
		Equipped = { nil, nil, nil } -- petId 저장
	}
end

--------------------------------------------------
-- Attribute 초기화
--------------------------------------------------

local function InitializePetAttributes(player)

	player:SetAttribute("PetFlatDamage", 0)
	player:SetAttribute("PetPercentDamage", 0)
	player:SetAttribute("PetDoubleChance", 0)
	player:SetAttribute("PetCritChance", 0)
	player:SetAttribute("PetCritBonus", 0)

end

--------------------------------------------------
-- 스탯 계산 보조
--------------------------------------------------

local function ApplyStat(base, enhanceValue, enhance)

	if base and base > 0 then
		return base + ((enhanceValue or 0) * enhance)
	end

	return 0

end

--------------------------------------------------
-- 스탯 재계산
--------------------------------------------------

function PetService.RecalculatePetStats(player)

	local data = PetCache[player]
	if not data then return end

	local totalFlat = 0
	local totalPercent = 0
	local totalDouble = 0
	local totalCritChance = 0
	local totalCritBonus = 0

	for _, petId in ipairs(data.Equipped) do

		if petId then

			local pet = data.Pets[petId]
			local petData = PetConfig.GetPetById(petId)

			if pet and petData and petData.Stats then

				local s = petData.Stats
				local rarity = petData.Rarity
				local enhance = pet.Enhance or 0

				local enhanceStats = PetConfig.EnhanceStats[rarity] or {}

				totalFlat += ApplyStat(s.DamageFlat, enhanceStats.DamageFlat, enhance)
				totalPercent += ApplyStat(s.DamagePercent, enhanceStats.DamagePercent, enhance)
				totalDouble += ApplyStat(s.DoubleChance, enhanceStats.DoubleChance, enhance)
				totalCritChance += ApplyStat(s.CritChance, enhanceStats.CritChance, enhance)
				totalCritBonus += ApplyStat(s.CritBonus, enhanceStats.CritBonus, enhance)

			end

		end

	end

	player:SetAttribute("PetFlatDamage", totalFlat)
	player:SetAttribute("PetPercentDamage", totalPercent)
	player:SetAttribute("PetDoubleChance", totalDouble)
	player:SetAttribute("PetCritChance", totalCritChance)
	player:SetAttribute("PetCritBonus", totalCritBonus)

end

--------------------------------------------------
-- Load
--------------------------------------------------

function PetService.Load(player)

	local success, data = pcall(function()
		return PetDataStore:GetAsync(player.UserId)
	end)

	if success and data then

		data.Pets = data.Pets or {}
		data.Equipped = data.Equipped or { nil, nil, nil }

		PetCache[player] = data

	else

		PetCache[player] = CreateDefaultData()

	end

	DirtyFlag[player] = false

	InitializePetAttributes(player)
	PetService.RecalculatePetStats(player)
end

--------------------------------------------------
-- Save
--------------------------------------------------

function PetService.Save(player)

	if not PetCache[player] then return end
	if not DirtyFlag[player] then return end

	pcall(function()
		PetDataStore:SetAsync(player.UserId, PetCache[player])
	end)

	DirtyFlag[player] = false

end

--------------------------------------------------
-- AddPet (UID 제거)
--------------------------------------------------

function PetService.AddPet(player, petId, rarity)

	local data = PetCache[player]
	if not data then return nil end

	local pet = data.Pets[petId]

	if pet then
		pet.Enhance = math.min((pet.Enhance or 0) + 1, 5)
	else
		data.Pets[petId] = {
			Enhance = 0
		}
	end

	DirtyFlag[player] = true

	return petId

end

--------------------------------------------------
-- Equip (PetId 기반)
--------------------------------------------------

function PetService.EquipPet(player, petId, slot)

	local data = PetCache[player]
	if not data then return false end
	if slot < 1 or slot > 3 then return false end

	if not data.Pets[petId] then
		return false
	end

	-- 이미 다른 슬롯에 있으면 제거
	for i, v in ipairs(data.Equipped) do
		if v == petId then
			data.Equipped[i] = nil
		end
	end

	data.Equipped[slot] = petId

	DirtyFlag[player] = true
	PetService.RecalculatePetStats(player)

	return true

end

--------------------------------------------------
-- Unequip
--------------------------------------------------

function PetService.UnequipPet(player, slot)

	local data = PetCache[player]
	if not data then return false end
	if slot < 1 or slot > 3 then return false end

	data.Equipped[slot] = nil

	DirtyFlag[player] = true
	PetService.RecalculatePetStats(player)

	return true

end

--------------------------------------------------
-- Getter
--------------------------------------------------

function PetService.GetPlayerPets(player)
	return PetCache[player] and PetCache[player].Pets or {}
end

function PetService.GetEquipped(player)
	return PetCache[player] and PetCache[player].Equipped or {}
end

--------------------------------------------------
-- 자동 저장
--------------------------------------------------

task.spawn(function()

	while true do

		task.wait(300)

		for player,_ in pairs(PetCache) do
			PetService.Save(player)
		end

	end

end)

game:BindToClose(function()

	for player,_ in pairs(PetCache) do
		PetService.Save(player)
	end

	task.wait(3)

end)

return PetService