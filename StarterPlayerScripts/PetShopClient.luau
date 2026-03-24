local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local openRemote = remoteFolder:WaitForChild("OpenPetShopEvent")
local promptPurchaseRemote = remoteFolder:WaitForChild("PromptPetProductPurchase")
local purchaseFinishedRemote = remoteFolder:WaitForChild("PetPurchaseFinished")
local priceRemote = remoteFolder:WaitForChild("SendPetShopPrice")

local SoundManager = require(ReplicatedStorage.SoundManager)

--------------------------------------------------
-- Blur 준비
--------------------------------------------------

--local blur = Lighting:FindFirstChild("ShopBlur")

--if not blur then
--	blur = Instance.new("BlurEffect")
--	blur.Name = "ShopBlur"
--	blur.Size = 0
--	blur.Parent = Lighting
--end

--------------------------------------------------
-- 상태
--------------------------------------------------

local currentMode = 1

-- 배경 이미지
local SINGLE_BG = "rbxassetid://116968608208397"
local TEN_BG = "rbxassetid://87339850756028"

-- 토글 이미지
local TOGGLE1_ON_IMAGE = "rbxassetid://111838251667025"
local TOGGLE1_OFF_IMAGE = "rbxassetid://74550515611524"

local TOGGLE10_ON_IMAGE = "rbxassetid://124993450628269"
local TOGGLE10_OFF_IMAGE = "rbxassetid://74550515611524"

-- 가격
local SINGLE_GOLD_PRICE = 95
local TEN_GOLD_PRICE = 0

local SINGLE_ROBUX_PRICE = 10
local TEN_ROBUX_PRICE = 0

--------------------------------------------------
-- UI 참조
--------------------------------------------------

local ui
local mainFrame
local background
local toggle1
local toggle10
local moneyButton
local robuxButton
local closeButton

--------------------------------------------------
-- 가격 텍스트 갱신
--------------------------------------------------

local function UpdatePriceText()

	local moneyLabel = moneyButton:WaitForChild("TextLabel")
	local robuxLabel = robuxButton:WaitForChild("TextLabel")

	if currentMode == 1 then
		moneyLabel.Text = "?? " .. SINGLE_GOLD_PRICE
		robuxLabel.Text = "R$ " .. SINGLE_ROBUX_PRICE
	else
		moneyLabel.Text = "?? " .. TEN_GOLD_PRICE
		robuxLabel.Text = "R$ " .. TEN_ROBUX_PRICE
	end
end

--------------------------------------------------
-- 모드 초기화
--------------------------------------------------

local function ResetToSingleMode()

	currentMode = 1
	background.Image = SINGLE_BG

	toggle1.Image = TOGGLE1_ON_IMAGE
	toggle10.Image = TOGGLE10_OFF_IMAGE

	UpdatePriceText()
end

--------------------------------------------------
-- Setup
--------------------------------------------------

local function SetupUI()

	local playerGui = player:WaitForChild("PlayerGui")

	ui = playerGui:WaitForChild("PetShopUI")
	mainFrame = ui:WaitForChild("MainFrame")

	background = mainFrame:WaitForChild("BackgroundImage")
	toggle1 = mainFrame:WaitForChild("Toggle_1Draw")
	toggle10 = mainFrame:WaitForChild("Toggle_10Draw")
	moneyButton = mainFrame:WaitForChild("MoneyButton")
	robuxButton = mainFrame:WaitForChild("RobuxButton")
	closeButton = mainFrame:WaitForChild("CloseButton")

	mainFrame.Visible = false

	--------------------------------------------------
	-- 토글 버튼
	--------------------------------------------------

	toggle1.MouseButton1Click:Connect(function()
		SoundManager.Play("Button_Click")
		currentMode = 1
		background.Image = SINGLE_BG
		toggle1.Image = TOGGLE1_ON_IMAGE
		toggle10.Image = TOGGLE10_OFF_IMAGE
		UpdatePriceText()
	end)

	toggle10.MouseButton1Click:Connect(function()
		SoundManager.Play("Button_Click")
		currentMode = 10
		background.Image = TEN_BG
		toggle1.Image = TOGGLE1_OFF_IMAGE
		toggle10.Image = TOGGLE10_ON_IMAGE
		UpdatePriceText()
	end)

	--------------------------------------------------
	-- ?? Gold 버튼
	--------------------------------------------------

	moneyButton.MouseButton1Click:Connect(function()

		if not _G.OpenPetConfirm then return end

		SoundManager.Play("Button_Click")

		if currentMode == 1 then
			_G.OpenPetConfirm(
				"Gold",
				1,
				SINGLE_GOLD_PRICE .. " Gold로 펫 1회 뽑기 하시겠습니까?"
			)
		else
			_G.OpenPetConfirm(
				"Gold",
				10,
				TEN_GOLD_PRICE .. " Gold로 펫 10회 뽑기 하시겠습니까?"
			)
		end
	end)

	--------------------------------------------------
	-- ?? Robux 버튼
	--------------------------------------------------

	robuxButton.MouseButton1Click:Connect(function()

		if not _G.OpenPetConfirm then return end

		SoundManager.Play("Button_Click")

		if currentMode == 1 then
			_G.OpenPetConfirm(
				"Robux",
				1,
				SINGLE_ROBUX_PRICE .. " Robux로 펫 1회 뽑기 하시겠습니까?"
			)
		else
			_G.OpenPetConfirm(
				"Robux",
				10,
				TEN_ROBUX_PRICE .. " Robux로 펫 10회 뽑기 하시겠습니까?"
			)
		end
	end)

	--------------------------------------------------
	-- 닫기 버튼
	--------------------------------------------------

	closeButton.MouseButton1Click:Connect(function()
		mainFrame.Visible = false
		-- ?? 추가
		SoundManager.Play("Panel_Close")
	end)

	ResetToSingleMode()
end

--------------------------------------------------
-- 서버 → 결제창 열기
--------------------------------------------------

promptPurchaseRemote.OnClientEvent:Connect(function(productId)
	MarketplaceService:PromptProductPurchase(player, productId)
end)

--------------------------------------------------
-- ?? Robux 결제 완료
--------------------------------------------------

MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, isPurchased)

	if userId ~= player.UserId then return end
	if not isPurchased then return end
end)

--------------------------------------------------
-- 상점 열기
--------------------------------------------------

openRemote.OnClientEvent:Connect(function()

	if not mainFrame or not mainFrame.Parent then
		SetupUI()
	end

	ResetToSingleMode()
	mainFrame.Visible = true
	
	-- ?? 추가
	SoundManager.Play("Panel_Open")
end)

priceRemote.OnClientEvent:Connect(function(data)

	SINGLE_GOLD_PRICE = data.SingleGold
	TEN_GOLD_PRICE = data.TenGold

	SINGLE_ROBUX_PRICE = data.SingleRobux
	TEN_ROBUX_PRICE = data.TenRobux

	UpdatePriceText()

end)

SetupUI()