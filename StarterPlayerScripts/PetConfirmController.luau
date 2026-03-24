local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local petGachaRemote = ReplicatedStorage.RemoteEvents:WaitForChild("RequestPetGacha")
local resultRemote = ReplicatedStorage.RemoteEvents:WaitForChild("PetGachaResult")

local ui = script.Parent
local confirmText = ui:WaitForChild("ConfirmText")
local confirmButton = ui:WaitForChild("ConfirmButton")
local cancelButton = ui:WaitForChild("CancelButton")
local warningText = ui:WaitForChild("WarningText")

local currentCurrencyType = nil
local currentDrawCount = nil

--------------------------------------------------
-- 열기
--------------------------------------------------

function OpenPetConfirm(currencyType, drawCount, priceText)

	currentCurrencyType = currencyType
	currentDrawCount = drawCount

	warningText.Visible = false
	confirmText.Text = priceText
	ui.Visible = true
end

--------------------------------------------------
-- 닫기
--------------------------------------------------

local function CloseConfirm()
	ui.Visible = false
	currentCurrencyType = nil
	currentDrawCount = nil
end

cancelButton.MouseButton1Click:Connect(CloseConfirm)

--------------------------------------------------
-- 확인 클릭
--------------------------------------------------

confirmButton.MouseButton1Click:Connect(function()

	if not currentCurrencyType or not currentDrawCount then
		return
	end

	local shopUI = ui.Parent
	local mainFrame = shopUI:WaitForChild("MainFrame")

	--------------------------------------------------
	-- Gold
	--------------------------------------------------

	if currentCurrencyType == "Gold" then

		-- ? 여기서 닫지 않는다
		petGachaRemote:FireServer("Gold", currentDrawCount)
		return
	end

	--------------------------------------------------
	-- Robux
	--------------------------------------------------

	if currentCurrencyType == "Robux" then

		-- Robux는 결제창 띄워야 하니까 닫아도 OK
		ui.Visible = false
		mainFrame.Visible = false

		petGachaRemote:FireServer("Robux", currentDrawCount)
		return
	end
end)

--------------------------------------------------
-- 서버 결과 수신
--------------------------------------------------

resultRemote.OnClientEvent:Connect(function(data)

	if not data then return end

	--------------------------------------------------
	-- 실패
	--------------------------------------------------

	if data.Success == false then

		if data.Reason == "NotEnoughGold" then
			warningText.Text = "골드가 부족합니다."
		else
			warningText.Text = "구매 실패"
		end

		warningText.Visible = true

		task.delay(2, function()
			warningText.Visible = false
		end)

		return
	end

	--------------------------------------------------
	-- 성공
	--------------------------------------------------

	local shopUI = ui.Parent
	local mainFrame = shopUI:WaitForChild("MainFrame")

	mainFrame.Visible = false
	CloseConfirm()
end)

_G.OpenPetConfirm = OpenPetConfirm