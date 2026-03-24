local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local SoundManager = require(ReplicatedStorage.SoundManager)

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local remote = ReplicatedStorage
	:WaitForChild("RemoteEvents")
	:WaitForChild("PowertestEvent")

local cameraConnection
_G.ShakeOffset = Vector3.zero

--------------------------------------------------
-- UI 동적 재참조 (리스폰 대응)
--------------------------------------------------

local ui
local readyLabel
local timerLabel
local resultPanel
local damageText
local rankText

local function SetupUI()
	local playerGui = player:WaitForChild("PlayerGui")
	ui = playerGui:WaitForChild("PowerTestUI"):WaitForChild("PowerTestUI")

	readyLabel = ui:WaitForChild("ReadyLabel")
	timerLabel = ui:WaitForChild("TimerLabel")
	resultPanel = ui:WaitForChild("ResultPanel")
	damageText = resultPanel:WaitForChild("DamageFrame"):WaitForChild("DamageText")
	rankText = resultPanel:WaitForChild("RankText")

	resultPanel.Visible = false
	timerLabel.Visible = false
	readyLabel.Visible = false
end

SetupUI()

--------------------------------------------------
-- 캐릭터 대응
--------------------------------------------------

local humanoid
local originalWalkSpeed
local originalJumpPower

local function SetupCharacter(char)
	humanoid = char:WaitForChild("Humanoid")
	originalWalkSpeed = humanoid.WalkSpeed
	originalJumpPower = humanoid.JumpPower
end

player.CharacterAdded:Connect(function(char)
	SetupCharacter(char)
	task.wait(0.5)
	SetupUI() -- UI도 재참조
end)

if player.Character then
	SetupCharacter(player.Character)
end

--------------------------------------------------
-- 카메라
--------------------------------------------------

local function StartQuarterView()

	camera.CameraType = Enum.CameraType.Scriptable

	cameraConnection = RunService.RenderStepped:Connect(function()

		local char = player.Character
		if not char then return end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		local wall = workspace.PowertestMap:FindFirstChild("ClientWall")
		if not wall then return end

		local dummy = wall:FindFirstChild("SM_Training_Dummie_Empire")
		if not hrp or not dummy then return end

		local midpoint = (hrp.Position + dummy.Position) / 2
		local offset = Vector3.new(20,18,20)
		local shake = _G.ShakeOffset or Vector3.zero

		camera.CFrame = CFrame.new(midpoint + offset + shake, midpoint)
	end)
end

local function StopQuarterView()
	if cameraConnection then
		cameraConnection:Disconnect()
		cameraConnection = nil
	end
	camera.CameraType = Enum.CameraType.Custom
end

--------------------------------------------------
-- 결과
--------------------------------------------------

local function ShowResult(totalDamage, rank)
	resultPanel.Visible = true
	damageText.Text = tostring(totalDamage or 0)
	rankText.Text = rank or "Unrank"
	task.delay(3,function()
		resultPanel.Visible = false
	end)
	
	SoundManager.Play("PowertestResult_Sound")
end

--------------------------------------------------
-- Remote
--------------------------------------------------

remote.OnClientEvent:Connect(function(action, totalDamage, rank)

	if action == "StartCamera" then
		StartQuarterView()

	elseif action == "ReadyStart" then

		if not humanoid then return end

		originalWalkSpeed = humanoid.WalkSpeed
		originalJumpPower = humanoid.JumpPower

		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0

		readyLabel.Visible = true
		readyLabel.Text = "READY!"
		task.wait(2)

		readyLabel.Text = "START!"
		task.wait(1)
		readyLabel.Visible = false

	elseif action == "StartTest" then

		timerLabel.Visible = true

		local playerGui = player:WaitForChild("PlayerGui")
		local huntingUI = playerGui:WaitForChild("HuntingUI")

		-- ?? 부모 켜기
		huntingUI.Enabled = true

		-- ?? 전부 끄기
		for _, child in pairs(huntingUI:GetChildren()) do
			if child:IsA("GuiObject") then
				child.Visible = false
			end
		end

		-- ?? AttackButton만 켜기
		local attackButton = huntingUI:WaitForChild("AttackButton")
		attackButton.Visible = true

		for i = 10,1,-1 do
			timerLabel.Text = tostring(i)
			task.wait(1)
		end

	elseif action == "TestEndNotice" then

		timerLabel.Text = "FINISH!"
		task.wait(2)
		timerLabel.Visible = false

		-- ?? HuntingUI 다시 끄기
		local playerGui = player:WaitForChild("PlayerGui")
		local huntingUI = playerGui:WaitForChild("HuntingUI")

		-- ?? 전부 끄기
		for _, child in pairs(huntingUI:GetChildren()) do
			if child:IsA("GuiObject") then
				child.Visible = true
			end
		end

		huntingUI.Enabled = false

		ShowResult(totalDamage, rank)

	elseif action == "EndCamera" then

		if humanoid then
			humanoid.WalkSpeed = originalWalkSpeed
			humanoid.JumpPower = originalJumpPower
		end

		StopQuarterView()
	end
end)