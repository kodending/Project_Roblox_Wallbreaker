local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--------------------------------------------------
-- Modules
--------------------------------------------------

local PowerShopConfig = require(ReplicatedStorage:WaitForChild("PowerShopConfig"))
local PetConfig = require(ReplicatedStorage:WaitForChild("PetConfig"))
local PetService = require(game.ServerScriptService:WaitForChild("PetService"))

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local powerEffectRemote = remoteFolder:WaitForChild("RobuxPurchaseEffectEvent")

local AnimationConfig = require(ReplicatedStorage:WaitForChild("AnimationConfig"))
local AnimationService = require(game.ServerScriptService:WaitForChild("AnimationService"))

--------------------------------------------------
-- ?? DevProduct IDs
--------------------------------------------------

local PET_SINGLE_PRODUCT_ID = 3549257009
local PET_TEN_PRODUCT_ID = 3550110449 -- ?? 10회용 추가

--------------------------------------------------
-- PowerShop Product Map
--------------------------------------------------

local PowerProductMap = {}

for _, item in pairs(PowerShopConfig.Items) do
	if item.ProductId then
		PowerProductMap[item.ProductId] = item
	end
end

--------------------------------------------------
-- Animation Product Map
--------------------------------------------------

local AnimationProductMap = {}

for _, list in pairs(AnimationConfig.Animations) do
	for _, anim in ipairs(list) do
		if anim.ProductId then
			AnimationProductMap[anim.ProductId] = anim
		end
	end
end

--------------------------------------------------
-- ?? 확률
--------------------------------------------------

local function RollNormalRarity()
	local rand = math.random(1,100)
	if rand <= 70 then return "Common"
	elseif rand <= 92 then return "Rare"
	elseif rand <= 99 then return "Epic"
	else return "Legendary"
	end
end

local function RollGuaranteedRarity()
	local rand = math.random(1,100)
	if rand <= 60 then return "Rare"
	elseif rand <= 90 then return "Epic"
	else return "Legendary"
	end
end

local function GetRandomPetByRarity(rarity)
	local list = PetConfig.GetPetsByRarity(rarity)
	if #list == 0 then return nil end
	return list[math.random(1,#list)]
end

--------------------------------------------------
-- ?? 1회 지급
--------------------------------------------------
local startAnimRemote = ReplicatedStorage.RemoteEvents.StartPetGachaAnimation

local function GrantSinglePet(player)

	local rarity = RollNormalRarity()
	local petData = GetRandomPetByRarity(rarity)
	if not petData then return false end

	local uid = PetService.AddPet(player, petData.Id, rarity)

	startAnimRemote:FireClient(player,{
		{
			UID = uid,
			PetId = petData.Id,
			Rarity = rarity
		}
	})

	return true
end

--------------------------------------------------
-- ?? 10회 지급 (Rare 이상 1회 보장)
--------------------------------------------------

local function GrantTenPets(player)

	local guaranteeIndex = math.random(1,10)

	local results = {}

	for i = 1,10 do

		local rarity

		if i == guaranteeIndex then
			rarity = RollGuaranteedRarity()
		else
			rarity = RollNormalRarity()
		end

		local petData = GetRandomPetByRarity(rarity)

		if petData then
			local uid = PetService.AddPet(player, petData.Id, rarity)

			table.insert(results,{
				UID = uid,
				PetId = petData.Id,
				Rarity = rarity
			})
		end

	end

	return results
end

--------------------------------------------------
-- ?? 영수증 처리
--------------------------------------------------

local function ProcessReceipt(receiptInfo)

	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	--------------------------------------------------
	-- ?? Pet 1회
	--------------------------------------------------

	if receiptInfo.ProductId == PET_SINGLE_PRODUCT_ID then

		if GrantSinglePet(player) then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	--------------------------------------------------
	-- ?? Pet 10회
	--------------------------------------------------

	if receiptInfo.ProductId == PET_TEN_PRODUCT_ID then

		local results = GrantTenPets(player)

		if results then

			local startAnimRemote = ReplicatedStorage.RemoteEvents.StartPetGachaAnimation
			startAnimRemote:FireClient(player, results)

			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	--------------------------------------------------
	-- Animation Shop
	--------------------------------------------------

	local anim = AnimationProductMap[receiptInfo.ProductId]

	if anim then

		AnimationService.GrantAnimation(player, anim.Id)

		return Enum.ProductPurchaseDecision.PurchaseGranted

	end

	--------------------------------------------------
	-- ? PowerShop
	--------------------------------------------------

	local item = PowerProductMap[receiptInfo.ProductId]
	if item then

		local currentUpgrade = player:GetAttribute("UpgradeDamage") or 0
		local addedValue = 0

		if item.Type == "Fixed" then
			addedValue = item.Value
		elseif item.Type == "Random" then
			addedValue = math.random(item.Min, item.Max)
		end

		local newValue = currentUpgrade + addedValue
		player:SetAttribute("UpgradeDamage", newValue)

		powerEffectRemote:FireClient(player, addedValue, newValue)

		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

MarketplaceService.ProcessReceipt = ProcessReceipt