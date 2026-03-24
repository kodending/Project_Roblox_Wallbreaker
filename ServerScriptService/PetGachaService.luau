local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")

local requestRemote = remoteFolder:WaitForChild("RequestPetGacha")
local startAnimRemote = remoteFolder:WaitForChild("StartPetGachaAnimation")
local resultRemote = remoteFolder:WaitForChild("PetGachaResult")
local finishRemote = remoteFolder:WaitForChild("GachaAnimationFinished")
local promptPurchaseRemote = remoteFolder:WaitForChild("PromptPetProductPurchase")
local purchaseFinishedRemote = remoteFolder:WaitForChild("PetPurchaseFinished")

local petListRemote = remoteFolder:WaitForChild("PlayerPetList")

local PetConfig = require(ReplicatedStorage:WaitForChild("PetConfig"))
local PetService = require(game.ServerScriptService:WaitForChild("PetService"))

--------------------------------------------------
-- DevProduct
--------------------------------------------------

local PET_SINGLE_PRODUCT_ID = 3549257009
local PET_TEN_PRODUCT_ID = 3550110449

--------------------------------------------------
-- 확률
--------------------------------------------------

local function RollNormalRarity()

	local rand = math.random(1,100)

	if rand <= 70 then
		return "Common"
	elseif rand <= 92 then
		return "Rare"
	elseif rand <= 99 then
		return "Epic"
	else
		return "Legendary"
	end

end

local function RollGuaranteedRarity()

	local rand = math.random(1,100)

	if rand <= 60 then
		return "Rare"
	elseif rand <= 90 then
		return "Epic"
	else
		return "Legendary"
	end

end

--------------------------------------------------
-- 펫 선택
--------------------------------------------------

local function GetRandomPetByRarity(rarity)

	local list = PetConfig.GetPetsByRarity(rarity)

	if #list == 0 then return nil end

	return list[math.random(1,#list)]

end

--------------------------------------------------
-- ?? 도감 갱신 (PetId 기반)
--------------------------------------------------

local function UpdatePetDex(player)

	local rawPets = PetService.GetPlayerPets(player)
	local equipped = PetService.GetEquipped(player)

	local sendPets = {}
	local equippedMap = {}

	for _, petId in ipairs(equipped) do
		if petId then
			equippedMap[petId] = true
		end
	end

	for petId, petData in pairs(rawPets) do
		table.insert(sendPets,{
			PetId = petId,
			Enhance = petData.Enhance or 0,
			Equipped = equippedMap[petId] or false
		})
	end

	petListRemote:FireClient(player, sendPets)

end

--------------------------------------------------
-- 1회 가챠
--------------------------------------------------

local function ProcessSingleDraw(player)

	local rarity = RollNormalRarity()

	local petData = GetRandomPetByRarity(rarity)
	if not petData then return end

	PetService.AddPet(player, petData.Id, rarity)

	local resultData = {
		PetId = petData.Id,
		Rarity = rarity
	}

	startAnimRemote:FireClient(player, {resultData})

end

--------------------------------------------------
-- 10회 가챠
--------------------------------------------------

local function ProcessTenDraw(player)

	local results = {}
	local guaranteeIndex = math.random(1,10)

	for i = 1,10 do

		local rarity

		if i == guaranteeIndex then
			rarity = RollGuaranteedRarity()
		else
			rarity = RollNormalRarity()
		end

		local petData = GetRandomPetByRarity(rarity)

		if petData then

			PetService.AddPet(player, petData.Id, rarity)

			table.insert(results,{
				PetId = petData.Id,
				Rarity = rarity
			})

		end

	end

	startAnimRemote:FireClient(player, results)

end

--------------------------------------------------
-- 가챠 요청
--------------------------------------------------

requestRemote.OnServerEvent:Connect(function(player, currencyType, drawCount)

	if drawCount ~= 1 and drawCount ~= 10 then return end

	--------------------------------------------------
	-- Gold
	--------------------------------------------------

	if currencyType == "Gold" then

		local priceData = PetConfig.GachaPrice
		local cost = (drawCount == 1) and priceData.Single or priceData.Ten
		local gold = player:GetAttribute("Gold") or 0

		if gold < cost then

			resultRemote:FireClient(player,{
				Success = false,
				Reason = "NotEnoughGold"
			})

			return
		end

		player:SetAttribute("Gold", gold - cost)

		if drawCount == 1 then
			ProcessSingleDraw(player)
		else
			ProcessTenDraw(player)
		end

		return
	end

	--------------------------------------------------
	-- Robux
	--------------------------------------------------

	if currencyType == "Robux" then

		if drawCount == 1 then
			promptPurchaseRemote:FireClient(player, PET_SINGLE_PRODUCT_ID)
		else
			promptPurchaseRemote:FireClient(player, PET_TEN_PRODUCT_ID)
		end

	end

end)

--------------------------------------------------
-- 애니메이션 완료
--------------------------------------------------

finishRemote.OnServerEvent:Connect(function(player, results)

	resultRemote:FireClient(player,{
		Success = true,
		Results = results
	})

	--------------------------------------------------
	-- ?? 핵심: 도감 즉시 갱신
	--------------------------------------------------

	UpdatePetDex(player)

end)

--------------------------------------------------
-- Robux 구매 완료
--------------------------------------------------

purchaseFinishedRemote.OnServerEvent:Connect(function(player, productId)

	if productId == PET_SINGLE_PRODUCT_ID then
		ProcessSingleDraw(player)
	elseif productId == PET_TEN_PRODUCT_ID then
		ProcessTenDraw(player)
	end

end)