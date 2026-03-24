local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--------------------------------------------------
-- Remote
--------------------------------------------------

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local enterRemote = remoteFolder:WaitForChild("RequestEnterAnimationZone")
local ownedUpdateRemote = remoteFolder:WaitForChild("AnimationOwnedUpdate")
local ownedInitRemote = remoteFolder:WaitForChild("AnimationOwnedInit")
local equipRemote = remoteFolder:WaitForChild("AnimationEquipRequest")
local equippedUpdateRemote = remoteFolder:WaitForChild("AnimationEquippedUpdate")
local equippedInitRemote = remoteFolder:WaitForChild("AnimationEquippedInit")

local SoundManager = require(ReplicatedStorage.SoundManager)

local ownedAnimations = {}
local equippedAnimations = {}

--------------------------------------------------
-- UI
--------------------------------------------------

local playerGui = player:WaitForChild("PlayerGui")

local mainHUD = playerGui:WaitForChild("MainHUD")
local petDexUI = playerGui:WaitForChild("PetDexUI")
local playerStatusUI = playerGui:WaitForChild("PlayerStatusUI")
local animationShopUI = playerGui:WaitForChild("AnimationShopUI")

local animationButton = petDexUI:WaitForChild("AnimationShopButton")
local closeButton = animationShopUI:WaitForChild("CloseButton")

--------------------------------------------------
-- Shop UI
--------------------------------------------------

local shopFrame = animationShopUI:WaitForChild("ShopFrame")
local scroll = shopFrame:WaitForChild("ScrollingFrame")

local template = scroll:WaitForChild("AnimationCardTemplate")

local normalTab = shopFrame:WaitForChild("NormalTabButton")
local doubleTab = shopFrame:WaitForChild("DoubleTabButton")

local purchaseButton = animationShopUI:WaitForChild("PurchaseButton")
local equipButton = animationShopUI:WaitForChild("EquipButton")

local priceText = purchaseButton:WaitForChild("PriceText")
local animationNameText = animationShopUI:WaitForChild("AnimationName")

template.Visible = false

local MarketplaceService = game:GetService("MarketplaceService")

--------------------------------------------------
-- Zone
--------------------------------------------------

local zone = workspace:WaitForChild("AnimationZone")
local cameraPoint = zone:WaitForChild("CameraPoint")
local teleportPoint = zone:WaitForChild("TeleportPoint")

--------------------------------------------------
-- 상태
--------------------------------------------------

local savedCFrame = nil
local humanoid = nil

local currentType = "Normal"
local selectedCard = nil
local selectedAnimation = nil

local previewTrack = nil

--------------------------------------------------
-- Animation Config
--------------------------------------------------

local AnimationConfig = require(
	ReplicatedStorage:WaitForChild("AnimationConfig")
)

--------------------------------------------------
-- Tab 이미지
--------------------------------------------------

local NORMAL_TAB_IMAGE = "rbxassetid://111838251667025"
local DOUBLE_TAB_IMAGE = "rbxassetid://124993450628269"
local TAB_DISABLED_IMAGE = "rbxassetid://74550515611524"

--------------------------------------------------
-- Preview Animation
--------------------------------------------------

local function PlayPreview(animationId)

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	if previewTrack then
		previewTrack:Stop()
		previewTrack:Destroy()
		previewTrack = nil
	end

	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. animationId

	previewTrack = animator:LoadAnimation(anim)
	previewTrack.Looped = true
	previewTrack:Play()

end

--------------------------------------------------
-- 리스트 삭제
--------------------------------------------------

local function ClearList()

	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("ImageButton") and child ~= template then
			child:Destroy()
		end
	end

end

--------------------------------------------------
-- 선택 초기화
--------------------------------------------------

local function ClearSelection()

	for _, child in ipairs(scroll:GetChildren()) do

		if child:IsA("ImageButton") then

			local mark = child:FindFirstChild("SelectedMark")
			if mark then
				mark.Visible = false
			end

		end

	end

	selectedCard = nil
	selectedAnimation = nil

end

--------------------------------------------------
-- 버튼 상태 업데이트
--------------------------------------------------

local function UpdateButtons(animData)

	animationNameText.Text = animData.Name

	if ownedAnimations[animData.Id] or animData.Price == 0 then

		purchaseButton.Visible = false
		equipButton.Visible = true

	else

		purchaseButton.Visible = true
		equipButton.Visible = false
		priceText.Text = animData.Price .. " R$"

	end

end

--------------------------------------------------
-- 카드 클릭
--------------------------------------------------

local function OnCardClicked(card, animData)

	ClearSelection()

	local mark = card:FindFirstChild("SelectedMark")
	if mark then
		mark.Visible = true
	end
	
	SoundManager.Play("Button_Click")
	
	selectedCard = card
	selectedAnimation = animData

	animationNameText.Visible = true
	animationNameText.Text = animData.Name

	UpdateButtons(animData)

	PlayPreview(animData.AnimationId)

end

--------------------------------------------------
-- 카드 생성
--------------------------------------------------

local function CreateCard(animData)

	local card = template:Clone()
	card.Visible = true
	card.Parent = scroll

	local icon = card:WaitForChild("IconImage")
	local soldout = card:WaitForChild("SoldoutOverlay")
	local equipped = card:WaitForChild("EquippedMark")
	local selected = card:WaitForChild("SelectedMark")

	icon.Image = animData.Icon

	selected.Visible = false
	equipped.Visible = false
	soldout.Visible = false

	-- 소지 표시
	if ownedAnimations[animData.Id] then

		soldout.Visible = true

		local text = soldout:FindFirstChild("SoldoutText")
		if text then
			text.Text = "보유"
		end

	end
	
	if equippedAnimations[animData.Type] == animData.Id then
		equipped.Visible = true
	end

	card.MouseButton1Click:Connect(function()
		OnCardClicked(card, animData)
	end)

end

--------------------------------------------------
-- 리스트 생성
--------------------------------------------------

local function BuildList(animType)

	ClearList()
	ClearSelection()

	local list = AnimationConfig.Animations[animType]

	for _, anim in ipairs(list) do
		CreateCard(anim, animType)
	end

end

--------------------------------------------------
-- Tab 상태
--------------------------------------------------

local function UpdateTabs()

	if currentType == "Normal" then

		normalTab.Image = NORMAL_TAB_IMAGE
		doubleTab.Image = TAB_DISABLED_IMAGE

	else

		normalTab.Image = TAB_DISABLED_IMAGE
		doubleTab.Image = DOUBLE_TAB_IMAGE

	end

end

--------------------------------------------------
-- Tab 변경
--------------------------------------------------

local function SetTab(animType)

	currentType = animType
	
	-- 선택 초기화
	selectedAnimation = nil
	selectedCard = nil

	ClearSelection()

	-- 버튼 초기화
	purchaseButton.Visible = false
	equipButton.Visible = false
	animationNameText.Visible = false
	animationNameText.Text = ""

	-- 애니메이션 초기화
	if previewTrack then
		previewTrack:Stop()
		previewTrack = nil
	end

	UpdateTabs()
	BuildList(animType)

end

--------------------------------------------------
-- 다른 플레이어 숨기기
--------------------------------------------------

local hiddenCharacters = {}

local function HideOtherPlayers()

	for _,p in ipairs(Players:GetPlayers()) do

		if p ~= player then

			local char = p.Character
			if char and char.Parent == workspace then

				hiddenCharacters[p] = char
				char.Parent = ReplicatedStorage

			end

		end

	end

end

local function ShowOtherPlayers()

	for p,char in pairs(hiddenCharacters) do

		if char then
			char.Parent = workspace
		end

	end

	hiddenCharacters = {}

end

--------------------------------------------------
-- Animation Zone 진입
--------------------------------------------------

local function EnterAnimationZone()
	
	local playerGui = player:WaitForChild("PlayerGui")
	
	SoundManager.Play("Teleport_Sound")

	mainHUD = playerGui:WaitForChild("MainHUD")
	petDexUI = playerGui:WaitForChild("PetDexUI")
	playerStatusUI = playerGui:WaitForChild("PlayerStatusUI")
	animationShopUI = playerGui:WaitForChild("AnimationShopUI")

	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")

	humanoid = character:WaitForChild("Humanoid")

	savedCFrame = root.CFrame

	enterRemote:FireServer()

	camera.CameraType = Enum.CameraType.Scriptable

	local camPos = cameraPoint.Position
	local lookPos = teleportPoint.Position + Vector3.new(3,4.5,0)

	camera.CFrame = CFrame.new(camPos, lookPos)

	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0

	mainHUD.Enabled = false
	petDexUI.Enabled = false
	playerStatusUI.Enabled = false

	HideOtherPlayers()

	animationShopUI.Enabled = true
	
	selectedAnimation = nil
	selectedCard = nil

	purchaseButton.Visible = false
	equipButton.Visible = false
	animationNameText.Visible = false
	animationNameText.Text = ""
	
	SetTab(currentType)
end

--------------------------------------------------
-- Animation Zone 종료
--------------------------------------------------

local function ExitAnimationZone()

	local character = player.Character
	if not character then return end

	SoundManager.Play("Teleport_Sound")

	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if root and savedCFrame then
		character:PivotTo(savedCFrame)
	end

	if humanoid then
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
	end

	if previewTrack then
		previewTrack:Stop()
		previewTrack = nil
	end

	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = humanoid

	mainHUD.Enabled = true
	petDexUI.Enabled = true
	playerStatusUI.Enabled = true

	ShowOtherPlayers()

	animationShopUI.Enabled = false
	
	selectedAnimation = nil
	selectedCard = nil

	purchaseButton.Visible = false
	equipButton.Visible = false
	animationNameText.Visible = false
	animationNameText.Text = ""

	ClearSelection()
end

ownedUpdateRemote.OnClientEvent:Connect(function(animId)

	ownedAnimations[animId] = true
	
	SetTab(currentType)   -- 추가
	
	if selectedAnimation and selectedAnimation.Id == animId then
		purchaseButton.Visible = false
		equipButton.Visible = true
	end

end)

ownedInitRemote.OnClientEvent:Connect(function(data)

	ownedAnimations = data

end)

equippedUpdateRemote.OnClientEvent:Connect(function(animType, animId)

	equippedAnimations[animType] = animId
	
	SetTab(currentType)
end)

equippedInitRemote.OnClientEvent:Connect(function(data)
	equippedAnimations = data
	
	print("Equipped Init:", data)
end)

--------------------------------------------------
-- Purchase Button
--------------------------------------------------

purchaseButton.MouseButton1Click:Connect(function()

	if not selectedAnimation then return end
	if not selectedAnimation.ProductId then return end

	SoundManager.Play("Button_Click")

	MarketplaceService:PromptProductPurchase(
		player,
		selectedAnimation.ProductId
	)

end)

--------------------------------------------------
-- Equip Button
--------------------------------------------------

equipButton.MouseButton1Click:Connect(function()

	if not selectedAnimation then return end
	
	SoundManager.Play("Button_Click")

	equipRemote:FireServer(
		selectedAnimation.Type,
		selectedAnimation.Id
	)

end)

--------------------------------------------------
-- Tab 버튼
--------------------------------------------------

normalTab.MouseButton1Click:Connect(function()
	SetTab("Normal")
	
	SoundManager.Play("Button_Click")

end)

doubleTab.MouseButton1Click:Connect(function()
	SetTab("Double")
	
	SoundManager.Play("Button_Click")
end)

--------------------------------------------------
-- 버튼 연결
--------------------------------------------------

animationButton.MouseButton1Click:Connect(EnterAnimationZone)
closeButton.MouseButton1Click:Connect(ExitAnimationZone)