local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage.RemoteEvents:WaitForChild("OpenPowerShopEvent")
local PowerShopConfig = require(ReplicatedStorage:WaitForChild("PowerShopConfig"))

local SoundManager = require(ReplicatedStorage.SoundManager)


--------------------------------------------------
-- UI 참조 변수 (리스폰 대응)
--------------------------------------------------

local ui
local mainFrame
local closeButton
local scrollFrame
local template

--------------------------------------------------
-- Blur 준비
--------------------------------------------------

local blur = Lighting:FindFirstChild("ShopBlur")

if not blur then
	blur = Instance.new("BlurEffect")
	blur.Name = "ShopBlur"
	blur.Size = 0
	blur.Parent = Lighting
end

--------------------------------------------------
-- 이미지 설정
--------------------------------------------------

local NORMAL_IMAGE = "rbxassetid://108437843253780"
local PRESSED_IMAGE = "rbxassetid://83756621593632"

--------------------------------------------------
-- UI 세팅 (핵심)
--------------------------------------------------

local function SetupUI()

	local playerGui = player:WaitForChild("PlayerGui")

	ui = playerGui:WaitForChild("PowerShopUI")
	mainFrame = ui:WaitForChild("MainFrame")
	closeButton = mainFrame:WaitForChild("CloseButton")
	scrollFrame = mainFrame:WaitForChild("ItemScrollFrame")
	template = scrollFrame:WaitForChild("ItemTemplate")

	template.Visible = false
	mainFrame.Visible = false

	closeButton.Image = NORMAL_IMAGE
	closeButton.AutoButtonColor = false

	--------------------------------------------------
	-- 버튼 연결 (재연결 필수)
	--------------------------------------------------

	closeButton.MouseButton1Down:Connect(function()
		closeButton.Image = PRESSED_IMAGE
	end)

	closeButton.MouseButton1Up:Connect(function()
		closeButton.Image = NORMAL_IMAGE
	end)

	closeButton.MouseLeave:Connect(function()
		closeButton.Image = NORMAL_IMAGE
	end)

	closeButton.MouseButton1Click:Connect(function()
		CloseShop()
	end)
end

--------------------------------------------------
-- 리스폰 대응
--------------------------------------------------

SetupUI()

player.CharacterAdded:Connect(function()
	task.wait(0.5)
	SetupUI()
end)

--------------------------------------------------
-- 열기 / 닫기
--------------------------------------------------

function OpenShop()

	if not mainFrame then return end

	SoundManager.Play("Panel_Open")

	mainFrame.Visible = true

	TweenService:Create(
		blur,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = 18 }
	):Play()
end

function CloseShop()

	SoundManager.Play("Panel_Close")

	TweenService:Create(
		blur,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = 0 }
	):Play()

	if mainFrame then
		mainFrame.Visible = false
	end
end

--------------------------------------------------
-- 아이템 생성
--------------------------------------------------

local function GenerateItems()

	if not scrollFrame or not template then return end

	-- 기존 아이템 제거
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") and child ~= template then
			child:Destroy()
		end
	end

	for _, itemData in ipairs(PowerShopConfig.Items) do

		local itemUI = template:Clone()
		itemUI.Visible = true
		itemUI.Name = itemData.Id
		itemUI.Parent = scrollFrame

		--------------------------------------------------
		-- 안전 접근
		--------------------------------------------------

		local icon = itemUI:FindFirstChild("Icon")
		if icon and icon:IsA("ImageLabel") then
			icon.Image = itemData.Icon
		end

		local desc = itemUI:FindFirstChild("Description")
		if desc and desc:IsA("TextLabel") then
			desc.Text = itemData.Description
		end

		local goldButton = itemUI:FindFirstChild("GoldButton")
		if goldButton then
			local goldLabel = goldButton:FindFirstChild("TextLabel")
			if goldLabel then
				goldLabel.Text = "?? " .. itemData.GoldPrice
			end

			goldButton.MouseButton1Click:Connect(function()
				if _G.OpenPurchaseConfirm then
					_G.OpenPurchaseConfirm(
						itemData.Id,
						"Gold",
						itemData.GoldPrice .. " Gold로 구매하시겠습니까?"
					)
				end
			end)
		end

		local robuxButton = itemUI:FindFirstChild("RobuxButton")
		if robuxButton then
			local robuxLabel = robuxButton:FindFirstChild("TextLabel")
			if robuxLabel then
				robuxLabel.Text = "R$ " .. itemData.RobuxPrice
			end

			local MarketplaceService = game:GetService("MarketplaceService")

			robuxButton.MouseButton1Click:Connect(function()
				if itemData.ProductId then
					MarketplaceService:PromptProductPurchase(player, itemData.ProductId)
				end
			end)
		end
	end
end

--------------------------------------------------
-- Remote 열기
--------------------------------------------------

remote.OnClientEvent:Connect(function()

	-- 리스폰 후 UI 다시 잡혀있는지 보장
	if not mainFrame or not mainFrame.Parent then
		SetupUI()
	end

	GenerateItems()
	OpenShop()
end)