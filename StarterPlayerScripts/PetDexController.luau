local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local PetConfig = require(ReplicatedStorage:WaitForChild("PetConfig"))

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local equipRemote = remoteFolder:WaitForChild("RequestEquipPet")
local unequipRemote = remoteFolder:WaitForChild("RequestUnequipPet")
local resultRemote = remoteFolder:WaitForChild("PetEquipResult")
local petListRemote = remoteFolder:WaitForChild("PlayerPetList")

local PetModels = ReplicatedStorage:WaitForChild("PetModels")
local SoundManager = require(ReplicatedStorage.SoundManager)

local UserInputService = game:GetService("UserInputService")

--------------------------------------------------
-- UI
--------------------------------------------------

local ui = script.Parent
local mainFrame = ui:WaitForChild("MainFrame")

local openButton = ui:WaitForChild("PetDexOpenButton")
local closeButton = mainFrame:WaitForChild("CloseButton")

local equipPanel = mainFrame:WaitForChild("EquipPanel")

local gridPanel = mainFrame:WaitForChild("PetGridPanel")
local scroll = gridPanel:WaitForChild("ScrollingFrame")
local template = scroll:WaitForChild("PetCardTemplate")

local tooltip = mainFrame:WaitForChild("PetToolTipPanel")

local petNameText = tooltip:WaitForChild("PetNameText")
local rarityText = tooltip:WaitForChild("RarityText")
local statsText = tooltip:WaitForChild("StatsText")

local equipButton = tooltip:WaitForChild("EquipButton")
local unequipButton = tooltip:WaitForChild("UnequipButton")

--------------------------------------------------
-- 초기 상태
--------------------------------------------------

template.Visible = false
tooltip.Visible = false
mainFrame.Visible = false
local isProcessing = false

--------------------------------------------------
-- 상태
--------------------------------------------------

local cards = {}
local equipped = {}
local ownedPets = {}
local slotModels = {}

local selectedPetId = nil

local RarityFrameImage = {
	Common = "rbxassetid://133419203230187",
	Rare = "rbxassetid://101676459171930",
	Epic = "rbxassetid://137312696559444",
	Legendary = "rbxassetid://74814327290841",
}

--------------------------------------------------
-- UI 열기 / 닫기
--------------------------------------------------

openButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible

	if not mainFrame.Visible then
		tooltip.Visible = false
		SoundManager.Play("Panel_Close")
	else
		SoundManager.Play("Panel_Open")
	end
end)

closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	tooltip.Visible = false
	SoundManager.Play("Panel_Close")
end)

local function IsPetEquipped(petId)
	for i = 1,3 do
		local data = equipped[i]
		if data and data.PetId == petId then
			return true
		end
	end
	return false
end

--------------------------------------------------
-- 능력치 계산
--------------------------------------------------

local function GetOwnedPetData(petId)
	for _, data in ipairs(ownedPets) do
		if data.PetId == petId then
			return data
		end
	end
	return nil
end

local function CalcStat(base, add, enhance)
	if base and base > 0 then
		return base + ((add or 0) * enhance)
	end
	return 0
end

--------------------------------------------------
-- Tooltip
--------------------------------------------------

local function ShowTooltip(card, pet)

	selectedPetId = pet.Id

	local enhance = 0
	local ownedData = GetOwnedPetData(pet.Id)

	if ownedData then
		enhance = ownedData.Enhance or 0
	end

	petNameText.Text =
		enhance > 0 and (pet.Name.." +"..enhance) or pet.Name

	rarityText.Text = pet.Rarity

	local inc = PetConfig.EnhanceStats[pet.Rarity] or {}
	local s = pet.Stats

	local lines = {}

	local flat = CalcStat(s.DamageFlat, inc.DamageFlat, enhance)
	if flat > 0 then table.insert(lines,"+"..flat.." 공격력") end

	local percent = CalcStat(s.DamagePercent, inc.DamagePercent, enhance)
	if percent > 0 then table.insert(lines,"+"..percent.."% 공격력") end

	local dbl = CalcStat(s.DoubleChance, inc.DoubleChance, enhance)
	if dbl > 0 then table.insert(lines,"+"..dbl.."% 더블") end

	local crit = CalcStat(s.CritChance, inc.CritChance, enhance)
	if crit > 0 then table.insert(lines,"+"..crit.."% 크리") end

	local critBonus = CalcStat(s.CritBonus, inc.CritBonus, enhance)
	if critBonus > 0 then table.insert(lines,"+"..critBonus.."% 크리데미지") end

	statsText.Text = table.concat(lines,"\n")

	tooltip.Visible = true
	
	local pos = card.AbsolutePosition
	local size = card.AbsoluteSize

	tooltip.AnchorPoint = Vector2.new(0, 0.5)

	tooltip.Position = UDim2.fromOffset(
		pos.X + size.X - 50,
		pos.Y + size.Y / 2
	)

	--------------------------------------------------
	-- 버튼 상태
	--------------------------------------------------

	local isEquipped = IsPetEquipped(pet.Id)

	local owned = GetOwnedPetData(pet.Id) ~= nil

	if not owned then
		equipButton.Visible = false
		unequipButton.Visible = false
	elseif isEquipped then
		equipButton.Visible = false
		unequipButton.Visible = true
	else
		equipButton.Visible = true
		unequipButton.Visible = false
	end

end

--------------------------------------------------
-- 도감 생성
--------------------------------------------------

local function BuildDex()

	for _, pet in ipairs(PetConfig.Pets) do

		local card = template:Clone()
		card.Visible = true
		card.Parent = scroll

		card:WaitForChild("PetIcon").Image = pet.Icon or ""
		
		
		local rarityImage = RarityFrameImage[pet.Rarity]
		
		if rarityImage then
			card.Image = rarityImage
		end

		card.MouseButton1Click:Connect(function()
			ShowTooltip(card, pet)
		end)

		cards[pet.Id] = card

	end

end

--------------------------------------------------
-- EquipPanel
--------------------------------------------------

local function RefreshEquipPanel()

	for i = 1,3 do

		local slot = equipPanel:FindFirstChild("Slot"..i)
		local viewport = slot:WaitForChild("ViewportFrame")
		local image = slot:WaitForChild("EquipImage")

		viewport:ClearAllChildren()
		slotModels[i] = nil

		local data = equipped[i]

		if data then

			image.Image = "rbxassetid://90856689130126"

			local model = PetModels:FindFirstChild(data.PetId)

			if model then

				local clone = model:Clone()
				clone.Parent = viewport

			--------------------------------------------------
			-- ?? PrimaryPart 강제 설정 (핵심)
			--------------------------------------------------

			if not clone.PrimaryPart then
				local primary = clone:FindFirstChildWhichIsA("BasePart")
				if primary then
					clone.PrimaryPart = primary
				else
					warn("No PrimaryPart:", data.PetId)
					return
				end
			end

			--------------------------------------------------
			-- ?? 모델 위치 초기화 (중요)
			--------------------------------------------------

			clone:SetPrimaryPartCFrame(CFrame.new(0,0,0))

			--------------------------------------------------
			-- ?? 크기 안정화 (추가 추천)
			--------------------------------------------------

			clone:ScaleTo(1)

			--------------------------------------------------
			-- ?? 카메라 생성
			--------------------------------------------------

			local camera = Instance.new("Camera")
			camera.Parent = viewport
			viewport.CurrentCamera = camera

			--------------------------------------------------
			-- ?? 카메라 자동 맞춤 (핵심)
			--------------------------------------------------

			local size = clone:GetExtentsSize()
			local maxSize = math.max(size.X, size.Y, size.Z)

			local distance = maxSize * 1.0

			camera.CFrame = CFrame.new(
				Vector3.new(0, size.Y * 0.5, distance),
				Vector3.new(0, size.Y * 0.5, 0)
			)


				slotModels[i] = clone
			end

		else
			image.Image = "rbxassetid://74609230277992"
		end

	end

end

--------------------------------------------------
-- Tooltip 외부 클릭 시 닫기
--------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gameProcessed)

	local Players = game:GetService("Players")

	local player = Players.LocalPlayer

	if gameProcessed then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	
	if not tooltip.Visible then return end

	local mousePos = UserInputService:GetMouseLocation()

	--------------------------------------------------
	-- ?? 현재 클릭된 UI들 가져오기 (핵심)
	--------------------------------------------------
	local guiObjects = player.PlayerGui:GetGuiObjectsAtPosition(mousePos.X, mousePos.Y)

	for _, obj in ipairs(guiObjects) do
		
		-- ?? Tooltip 내부 클릭 → 유지
		if obj:IsDescendantOf(tooltip) then
			return
		end
		
		-- ?? 카드 클릭 → 유지 (중요)
		if obj:IsDescendantOf(scroll) then
			return
		end
		
	end

	--------------------------------------------------
	-- ?? 아무것도 해당 안되면 닫기
	--------------------------------------------------
	tooltip.Visible = false

end)

--------------------------------------------------
-- 회전
--------------------------------------------------

RunService.RenderStepped:Connect(function(dt)

	for _,model in pairs(slotModels) do
		if model and model.PrimaryPart then
			model:SetPrimaryPartCFrame(
				model.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(25)*dt,0)
			)
		end
	end

end)

--------------------------------------------------
-- 서버 결과 수신
--------------------------------------------------

resultRemote.OnClientEvent:Connect(function(data)

	if not data then return end

	equipped = data.Equipped or {}

	-- ?? 입력 잠금 해제
	isProcessing = false

	-- ?? tooltip 강제 종료 (핵심)
	tooltip.Visible = false
	
	--------------------------------------------------
	-- ?? [추가] EquippedMark 갱신 (핵심)
	--------------------------------------------------

	-- 전체 OFF
	for _, card in pairs(cards) do
		local mark = card:FindFirstChild("EquippedMark")
		if mark then
			mark.Visible = false
		end
	end

	-- ?? PetId 기준 Map 생성
	for i = 1,3 do
		local info = equipped[i]
		if info then
			local card = cards[info.PetId]
			if card then
				local mark = card:FindFirstChild("EquippedMark")
				if mark then
					mark.Visible = true
				end
			end
		end
	end

	RefreshEquipPanel()

end)

petListRemote.OnClientEvent:Connect(function(pets)

	ownedPets = pets or {}
	
	-- ?? 기존 장착 초기화 (핵심)
	--equipped = {nil, nil, nil}
	
	for _, card in pairs(cards) do
		local mark = card:FindFirstChild("EquippedMark")
		if mark then mark.Visible = false end
	end

	for _, pet in ipairs(PetConfig.Pets) do

		local card = cards[pet.Id]
		if not card then continue end

		local locked = card:WaitForChild("LockedMark")

		local owned = GetOwnedPetData(pet.Id) ~= nil
		locked.Visible = not owned

	end
	
	--------------------------------------------------
	-- ?? [추가] EquippedMark 초기 동기화
	--------------------------------------------------

	for _, card in pairs(cards) do
		local mark = card:FindFirstChild("EquippedMark")
		if mark then
			mark.Visible = false
		end
	end

	for i = 1,3 do
		local info = equipped[i]
		if info then
			local card = cards[info.PetId]
			if card then
				local mark = card:FindFirstChild("EquippedMark")
				if mark then
					mark.Visible = true
				end
			end
		end
	end

end)

--------------------------------------------------
-- Equip 버튼
--------------------------------------------------

equipButton.MouseButton1Click:Connect(function()

	if isProcessing then return end
	if not selectedPetId then return end
	
	isProcessing = true
	tooltip.Visible = false
	
	
	---------------------------------
	-- 이미 장착된 펫 중복검사
	---------------------------------
	if IsPetEquipped(selectedPetId) then
		isProcessing = false
		return
	end

	for i = 1,3 do
		if not equipped[i] then
			equipRemote:FireServer(selectedPetId, i)
			SoundManager.Play("Equip_Pet")
			return
		end
	end

	isProcessing = false

end)

--------------------------------------------------
-- Unequip 버튼
--------------------------------------------------

unequipButton.MouseButton1Click:Connect(function()

	if isProcessing then return end

	isProcessing = true
	tooltip.Visible = false

	for i = 1,3 do
		local data = equipped[i]
		if data and data.PetId == selectedPetId then
			unequipRemote:FireServer(i)
			SoundManager.Play("Unequip_Pet")
			return
		end
	end

	isProcessing = false

end)

--------------------------------------------------

BuildDex()