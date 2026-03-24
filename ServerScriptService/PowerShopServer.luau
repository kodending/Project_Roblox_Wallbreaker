local ReplicatedStorage = game:GetService("ReplicatedStorage")

local purchaseRemote = ReplicatedStorage.RemoteEvents:WaitForChild("PurchasePowerItemEvent")
local config = require(ReplicatedStorage:WaitForChild("PowerShopConfig"))

local purchaseCooldown = {}
local PURCHASE_DELAY = 0.5

--------------------------------------------------
-- 아이템 찾기
--------------------------------------------------

local function GetItemById(id)
	for _, item in pairs(config.Items) do
		if item.Id == id then
			return item
		end
	end
	return nil
end

--------------------------------------------------
-- 구매 처리
--------------------------------------------------

purchaseRemote.OnServerEvent:Connect(function(player, itemId, currencyType)

	-- ?? 쿨타임
	local now = tick()
	if purchaseCooldown[player] and now - purchaseCooldown[player] < PURCHASE_DELAY then
		return
	end
	purchaseCooldown[player] = now

	local item = GetItemById(itemId)
	if not item then return end

	--------------------------------------------------
	-- ?? Gold 구매
	--------------------------------------------------

	if currencyType == "Gold" then

		local price = item.GoldPrice or 0
		local playerGold = player:GetAttribute("Gold") or 0

		if playerGold < price then
			purchaseRemote:FireClient(player, {
				Success = false,
				Reason = "NotEnoughGold"
			})
			return
		end

		player:SetAttribute("Gold", playerGold - price)
	end

	--------------------------------------------------
	-- ?? 공격력 적용
	--------------------------------------------------

	local currentUpgrade = player:GetAttribute("UpgradeDamage") or 0
	local addedValue = 0

	if item.Type == "Fixed" then
		addedValue = item.Value

	elseif item.Type == "Random" then
		addedValue = math.random(item.Min, item.Max)
	end

	local newUpgrade = currentUpgrade + addedValue
	player:SetAttribute("UpgradeDamage", newUpgrade)

	--------------------------------------------------
	-- 클라 결과 반환
	--------------------------------------------------

	purchaseRemote:FireClient(player, {
		Success = true,
		AddedValue = addedValue,
		NewUpgrade = newUpgrade
	})
end)