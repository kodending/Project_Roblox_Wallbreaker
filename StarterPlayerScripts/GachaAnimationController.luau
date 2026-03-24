local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local startAnimRemote = remoteFolder:WaitForChild("StartPetGachaAnimation")
local finishRemote = remoteFolder:WaitForChild("GachaAnimationFinished")

local PetModels = ReplicatedStorage:WaitForChild("PetModels")
local PetConfig = require(ReplicatedStorage:WaitForChild("PetConfig"))

local GachaZone = workspace:WaitForChild("GachaZone")
local CameraPoint = GachaZone:WaitForChild("CameraPoint")
local EggSpawnPoint = GachaZone:WaitForChild("EggSpawnPoint")
local EggTemplate = GachaZone:WaitForChild("EggModel")

local playerGui = player:WaitForChild("PlayerGui")
local resultUI = playerGui:WaitForChild("GachaResultUI")
local frame = resultUI:WaitForChild("ResultFrame")
local nameText = frame:WaitForChild("PetNameText")
local rarityText = frame:WaitForChild("RarityText")
local statsText = frame:WaitForChild("StatsText")

local playerGui = player:WaitForChild("PlayerGui")

local MainHUD = playerGui:WaitForChild("MainHUD")
local PetDexUI = playerGui:WaitForChild("PetDexUI")
local PlayerStatusUI = playerGui:WaitForChild("PlayerStatusUI")

local SoundManager = require(ReplicatedStorage.SoundManager)

local RarityColors = {
	Common = Color3.fromRGB(200,200,200),
	Rare = Color3.fromRGB(80,150,255),
	Epic = Color3.fromRGB(180,80,255),
	Legendary = Color3.fromRGB(255,170,0)
}

local isPlaying = false
local cameraLockConnection = nil
local cameraShakeOffset = CFrame.new()
local cameraZoomOffset = CFrame.new()

-- ?? 더블 탭 감지
local skipEggMotion = false
local lastTapTime = 0
local DOUBLE_TAP_THRESHOLD = 0.35

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if not isPlaying then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		local now = tick()
		if now - lastTapTime <= DOUBLE_TAP_THRESHOLD then
			skipEggMotion = true
		end
		lastTapTime = now
	end
end)

--------------------------------------------------
-- 카메라
--------------------------------------------------

local function LockCamera()
	camera.CameraType = Enum.CameraType.Scriptable

	cameraLockConnection = RunService.RenderStepped:Connect(function()
		local baseCF = CFrame.new(
			CameraPoint.Position,
			EggSpawnPoint.Position
		)
		camera.CFrame = baseCF * cameraShakeOffset * cameraZoomOffset
	end)
end

local function UnlockCamera()
	if cameraLockConnection then
		cameraLockConnection:Disconnect()
		cameraLockConnection = nil
	end

	cameraShakeOffset = CFrame.new()
	cameraZoomOffset = CFrame.new()
	camera.CameraType = Enum.CameraType.Custom
end

--------------------------------------------------
-- 카메라 연출
--------------------------------------------------

local function PlayCameraShake(duration, magnitude)
	local startTime = tick()

	local connection
	connection = RunService.RenderStepped:Connect(function()
		local elapsed = tick() - startTime
		if elapsed >= duration then
			cameraShakeOffset = CFrame.new()
			connection:Disconnect()
			return
		end

		local decay = 1 - (elapsed / duration)
		local x = (math.random()-0.5) * magnitude * decay
		local y = (math.random()-0.5) * magnitude * decay
		local z = (math.random()-0.5) * magnitude * decay

		cameraShakeOffset = CFrame.new(x, y, z)
	end)
end

local function PlayZoomPunch(strength)
	local zoomOut = CFrame.new(0, 0, -strength)
	local zoomIn = CFrame.new()
	local duration = 0.15
	local startTime = tick()

	local connection
	connection = RunService.RenderStepped:Connect(function()
		local elapsed = tick() - startTime
		if elapsed >= duration then
			cameraZoomOffset = zoomIn
			connection:Disconnect()
			return
		end

		local alpha = elapsed / duration
		cameraZoomOffset = zoomOut:Lerp(zoomIn, alpha)
	end)
end

--------------------------------------------------
-- 알 흔들림
--------------------------------------------------

local function ShakeEgg(model, duration, intensity)
	local baseCF = EggSpawnPoint.CFrame
	local startTime = tick()

	local connection
	connection = RunService.RenderStepped:Connect(function()
		if not model or not model.Parent then
			connection:Disconnect()
			return
		end

		local elapsed = tick() - startTime
		if elapsed >= duration then
			model:PivotTo(baseCF)
			connection:Disconnect()
			return
		end

		local power = intensity * (elapsed / duration)

		local offsetRot = CFrame.Angles(
			math.rad(math.random(-power,power)),
			math.rad(math.random(-power,power)),
			math.rad(math.random(-power,power))
		)

		model:PivotTo(baseCF * offsetRot)
	end)
end

--------------------------------------------------
-- UI
--------------------------------------------------

local function BuildStatText(petId)
	local petData = PetConfig.GetPetById(petId)
	if not petData or not petData.Stats then return "" end

	local s = petData.Stats
	local lines = {}

	if s.DamageFlat and s.DamageFlat > 0 then
		table.insert(lines, "+" .. s.DamageFlat .. " 공격력")
	end
	if s.DamagePercent and s.DamagePercent > 0 then
		table.insert(lines, "+" .. s.DamagePercent .. "% 공격력")
	end
	if s.DoubleChance and s.DoubleChance > 0 then
		table.insert(lines, "+" .. s.DoubleChance .. "% 더블")
	end
	if s.CritChance and s.CritChance > 0 then
		table.insert(lines, "+" .. s.CritChance .. "% 크리 확률")
	end
	if s.CritBonus and s.CritBonus > 0 then
		table.insert(lines, "+" .. s.CritBonus .. "% 크리 추가 데미지")
	end

	return table.concat(lines, "\n")
end

local function ShowResultUI(resultData)
	frame.Visible = true
	frame.Position = UDim2.new(-0.4, 0, 0.5, 0)

	local petData = PetConfig.GetPetById(resultData.PetId)

	nameText.Text = (petData and petData.Name) or resultData.PetId
	rarityText.Text = resultData.Rarity
	rarityText.TextColor3 = RarityColors[resultData.Rarity]
	statsText.Text = BuildStatText(resultData.PetId)

	TweenService:Create(
		frame,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Position = UDim2.new(0.05, 0, 0.5, 0)}
	):Play()
end

local function HideResultUI()
	TweenService:Create(
		frame,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{Position = UDim2.new(-0.4, 0, 0.5, 0)}
	):Play()

	task.delay(0.3, function()
		frame.Visible = false
	end)
end

local function SetHUDVisible(state)
	MainHUD.Enabled = state
	PetDexUI.Enabled = state
	PlayerStatusUI.Enabled = state
end

--------------------------------------------------
-- ?? 단일 연출 실행
--------------------------------------------------

local function PlaySingleAnimation(resultData)

	local humanoid = player.Character:FindFirstChild("Humanoid")
	local originalSpeed = humanoid.WalkSpeed
	local originalJump = humanoid.JumpPower

	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0

	LockCamera()
	task.wait(0.3)

	local egg = EggTemplate:Clone()
	egg.Parent = workspace
	egg:PivotTo(EggSpawnPoint.CFrame)
	
	local currentSound = SoundManager.Play("Gacha_Pick")
	currentSound.PlaybackSpeed = 1.2

	task.wait(0.5)

	local isLegendary = resultData.Rarity == "Legendary"
	local shakeTime = isLegendary and 3 or 2
	local intensity = isLegendary and 14 or 6

	ShakeEgg(egg, shakeTime, intensity)

	local startTime = tick()

	while tick() - startTime < (shakeTime + 0.5) do
		if skipEggMotion then
			break
		end
		RunService.Heartbeat:Wait()
	end

	skipEggMotion = false

	egg:Destroy()

	if isLegendary then
		PlayCameraShake(0.4, 0.8)
		PlayZoomPunch(2)
	else
		PlayCameraShake(0.25, 0.4)
		PlayZoomPunch(1)
	end

	task.wait(0.1)
	
	if currentSound then
		currentSound:Stop()
		currentSound:Destroy()
		currentSound = nil
	end

	local petTemplate = PetModels:FindFirstChild(resultData.PetId)
	if petTemplate then
		local pet = petTemplate:Clone()
		pet.Parent = workspace
		pet:PivotTo(EggSpawnPoint.CFrame * CFrame.new(0, -2, 0))
		pet:ScaleTo(1.5)

		--------------------------------------------------
		-- ?? 애니메이션 추가 (핵심)
		--------------------------------------------------

		local controller = pet:FindFirstChildOfClass("AnimationController")
		if controller then

			local animator = controller:FindFirstChildOfClass("Animator")
			if not animator then
				animator = Instance.new("Animator")
				animator.Parent = controller
			end

			local animation = Instance.new("Animation")

			-- ?? PetConfig에서 가져오면 더 좋음 (아래 설명 참고)
			animation.AnimationId = "rbxassetid://99348259760104"

			local track = animator:LoadAnimation(animation)
			track.Looped = true
			track:Play()
			track:AdjustSpeed(0.6)
		end

		--------------------------------------------------

		ShowResultUI(resultData)
		task.wait(3)
		HideResultUI()
		pet:Destroy()
	end

	UnlockCamera()
	
	humanoid.WalkSpeed = originalSpeed
	humanoid.JumpPower = originalJump
end

--------------------------------------------------
-- 배열 수신
--------------------------------------------------

startAnimRemote.OnClientEvent:Connect(function(results)

	if isPlaying then return end
	isPlaying = true
	
	SetHUDVisible(false) -- ?? 여기
	
	--------------------------------------------------
	-- ?? 여기 추가 (UI 강제 닫기)
	--------------------------------------------------
	local playerGui = player:WaitForChild("PlayerGui")
	local shopUI = playerGui:FindFirstChild("PetShopUI")

	if shopUI then
		local mainFrame = shopUI:FindFirstChild("MainFrame")
		if mainFrame then
			mainFrame.Visible = false
		end

		local confirmUI = shopUI:FindFirstChild("ConfirmFrame")
		if confirmUI then
			confirmUI.Visible = false
		end
	end
	--------------------------------------------------

	for _, resultData in ipairs(results) do
		PlaySingleAnimation(resultData)
	end

	SetHUDVisible(true) -- ?? 여기

	isPlaying = false
	finishRemote:FireServer(results)
end)