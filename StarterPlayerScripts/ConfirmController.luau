local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local purchaseRemote = ReplicatedStorage.RemoteEvents:WaitForChild("PurchasePowerItemEvent")
local PowerShopConfig = require(ReplicatedStorage:WaitForChild("PowerShopConfig"))
local effectRemote = ReplicatedStorage.RemoteEvents:WaitForChild("RobuxPurchaseEffectEvent")

local ui = script.Parent
local confirmText = ui:WaitForChild("ConfirmText")
local confirmButton = ui:WaitForChild("ConfirmButton")
local cancelButton = ui:WaitForChild("CancelButton")
local warningText = ui:WaitForChild("WarningText")

local SoundManager = require(ReplicatedStorage.SoundManager)

local currentItemId = nil
local currentCurrencyType = nil

--------------------------------------------------
-- Item 찾기
--------------------------------------------------

local function GetItemById(id)
	for _, item in pairs(PowerShopConfig.Items) do
		if item.Id == id then
			return item
		end
	end
	return nil
end

--------------------------------------------------
-- 열기
--------------------------------------------------

function OpenConfirm(itemId, currencyType, priceText)

	currentItemId = itemId
	currentCurrencyType = currencyType

	warningText.Visible = false
	confirmText.Text = priceText
	ui.Visible = true
	
	SoundManager.Play("Panel_Open")
end

--------------------------------------------------
-- 닫기
--------------------------------------------------

local function CloseConfirm()
	ui.Visible = false
	currentItemId = nil
	currentCurrencyType = nil
	
	SoundManager.Play("Panel_Close")
end

cancelButton.MouseButton1Click:Connect(CloseConfirm)

--------------------------------------------------
-- 확인 클릭
--------------------------------------------------

confirmButton.MouseButton1Click:Connect(function()

	if not currentItemId or not currentCurrencyType then
		return
	end
	
	SoundManager.Play("Panel_Confirm")

	-- ?? Gold 구매
	if currentCurrencyType == "Gold" then
		purchaseRemote:FireServer(currentItemId, "Gold")
		return
	end

	-- ?? Robux 구매
	if currentCurrencyType == "Robux" then

		local item = GetItemById(currentItemId)
		if not item or not item.ProductId then
			return
		end

		CloseConfirm()
		MarketplaceService:PromptProductPurchase(player, item.ProductId)
	end
end)

--------------------------------------------------
-- Gold 결과 수신만 처리
--------------------------------------------------

purchaseRemote.OnClientEvent:Connect(function(result)

	if not result then return end
	
	SoundManager.Play("Purchase_Fail")

	if not result.Success then

		if result.Reason == "NotEnoughGold" then
			warningText.Text = "골드가 부족합니다."
		else
			warningText.Text = "구매 실패"
		end

		warningText.TextColor3 = Color3.fromRGB(255,60,60)
		warningText.Visible = true

		task.delay(2, function()
			if warningText then
				warningText.Visible = false
			end
		end)

		return
	end

	--------------------------------------------------
	-- Gold 성공 팝업
	--------------------------------------------------

	CloseConfirm()

	local added = result.AddedValue or 0

	local popup = Instance.new("TextLabel")
	popup.Size = UDim2.new(0,400,0,80)
	popup.Position = UDim2.new(0.5,-200,0.4,0)
	popup.BackgroundTransparency = 1
	popup.TextScaled = true
	popup.Font = Enum.Font.GothamBlack
	popup.TextStrokeTransparency = 0
	popup.TextColor3 = Color3.fromRGB(0,255,120)
	popup.Text = "+"..added.." 공격력"
	popup.Parent = ui.Parent

	popup.TextTransparency = 1

	TweenService:Create(
		popup,
		TweenInfo.new(0.2),
		{TextTransparency = 0}
	):Play()

	task.delay(0.8, function()
		local tween = TweenService:Create(
			popup,
			TweenInfo.new(0.3),
			{
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}
		)
		tween:Play()

		task.delay(0.3, function()
			popup:Destroy()
		end)
	end)

end)

_G.OpenPurchaseConfirm = OpenConfirm


effectRemote.OnClientEvent:Connect(function(added)

	local popup = Instance.new("TextLabel")
	popup.Size = UDim2.new(0,400,0,80)
	popup.Position = UDim2.new(0.5,-200,0.4,0)
	popup.BackgroundTransparency = 1
	popup.TextScaled = true
	popup.Font = Enum.Font.GothamBlack
	popup.TextStrokeTransparency = 0
	popup.TextColor3 = Color3.fromRGB(0,255,120)
	popup.Text = "+"..added.." 공격력"
	popup.Parent = ui.Parent

	popup.TextTransparency = 1

	TweenService:Create(
		popup,
		TweenInfo.new(0.2),
		{TextTransparency = 0}
	):Play()

	task.delay(0.8, function()
		local tween = TweenService:Create(
			popup,
			TweenInfo.new(0.3),
			{
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}
		)
		tween:Play()

		task.delay(0.3, function()
			popup:Destroy()
		end)
	end)

end)