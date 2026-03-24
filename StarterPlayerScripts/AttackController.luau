local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--------------------------------------------------
-- Remote
--------------------------------------------------

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")

local hitRemote = remoteFolder:WaitForChild("WallHitEvent")
local attackStartRemote = remoteFolder:WaitForChild("AttackStartEvent")
local powertestRemote = remoteFolder:WaitForChild("PowertestEvent")
local popupRemote = remoteFolder:WaitForChild("DamagePopupEvent")

local equippedInitRemote = remoteFolder:WaitForChild("AnimationEquippedInit")
local equippedUpdateRemote = remoteFolder:WaitForChild("AnimationEquippedUpdate")

local EffectManager = require(ReplicatedStorage.Modules.EffectManager)

--------------------------------------------------
-- Config
--------------------------------------------------

local AnimationConfig = require(
	ReplicatedStorage:WaitForChild("AnimationConfig")
)

local SoundManager = require(ReplicatedStorage.SoundManager)

--------------------------------------------------
-- 장착 애니메이션
--------------------------------------------------

local equippedAnimations = {
	Normal = "Normal_01",
	Double = "Double_01"
}

--------------------------------------------------
-- 공격 제어 변수
--------------------------------------------------

local ATTACK_COOLDOWN = 0.5
local canAttack = true
local currentTargetWall = nil
local isPowerTestActive = false

local mouse = player:GetMouse()

--------------------------------------------------
-- 애니메이션 변수
--------------------------------------------------

local humanoid
local normalTrack
local doubleTrack

local normalAnim = Instance.new("Animation")
local doubleAnim = Instance.new("Animation")

--------------------------------------------------
-- Hit 사운드 변수
--------------------------------------------------

local currentAnimType = "Normal"

local attackTargetWall = nil

--------------------------------------------------
-- 장착 애니메이션 적용
--------------------------------------------------

local function UpdateAnimationIds()

	local normalId = equippedAnimations["Normal"] or "Normal_01"
	local doubleId = equippedAnimations["Double"] or "Double_01"

	local normalAsset = AnimationConfig.GetAnimationId(normalId)
	local doubleAsset = AnimationConfig.GetAnimationId(doubleId)

	if normalAsset then
		normalAnim.AnimationId = "rbxassetid://" .. normalAsset
	end

	if doubleAsset then
		doubleAnim.AnimationId = "rbxassetid://" .. doubleAsset
	end

end

--------------------------------------------------
-- Hit 처리
--------------------------------------------------

local function ShakeCamera(intensity, duration)

	local startTime = tick()
	local connection

	connection = RunService.RenderStepped:Connect(function()

		if tick() - startTime > duration then
			if camera.CameraType == Enum.CameraType.Scriptable then
				_G.ShakeOffset = Vector3.zero
			end
			connection:Disconnect()
			return
		end

		local offset = Vector3.new(
			math.random(-intensity, intensity) / 100,
			math.random(-intensity, intensity) / 100,
			0
		)

		if camera.CameraType == Enum.CameraType.Scriptable then
			_G.ShakeOffset = offset
		else
			camera.CFrame = camera.CFrame * CFrame.new(offset)
		end
	end)
end

local function OnHit()

	if attackTargetWall then
		local wallId = attackTargetWall:GetAttribute("WallId")
		if wallId then
			hitRemote:FireServer(wallId)
		end
	end
	
	local char = player.Character
	if not char then return end

	local hand = char:FindFirstChild("RightHand") 
		or char:FindFirstChild("Right Arm")

	if not hand then return end

	--------------------------------------------------
	-- ?? 손 이펙트
	--------------------------------------------------

	local handPos = hand.Position
	EffectManager.Play("HitEffect", handPos)

	--------------------------------------------------
	-- ?? 벽 이펙트 (정확한 위치)
	--------------------------------------------------

	if mouse and mouse.Hit then
		local hitPos = mouse.Hit.Position
		EffectManager.Play("HitEffect", hitPos)
	end

	--------------------------------------------------
	ShakeCamera(15, 0.25)
end

--------------------------------------------------
-- 캐릭터 세팅
--------------------------------------------------

local function SetupCharacter(char)

	humanoid = char:WaitForChild("Humanoid")

	UpdateAnimationIds()

	normalTrack = humanoid:LoadAnimation(normalAnim)
	doubleTrack = humanoid:LoadAnimation(doubleAnim)

	normalTrack:GetMarkerReachedSignal("Hit"):Connect(OnHit)
	doubleTrack:GetMarkerReachedSignal("Hit"):Connect(OnHit)

end

player.CharacterAdded:Connect(SetupCharacter)

if player.Character then
	SetupCharacter(player.Character)
end

--------------------------------------------------
-- 장착 애니메이션 초기 수신
--------------------------------------------------

equippedInitRemote.OnClientEvent:Connect(function(data)

	equippedAnimations = data

	UpdateAnimationIds()

	if humanoid then
		SetupCharacter(player.Character)
	end

end)

--------------------------------------------------
-- 장착 애니메이션 업데이트
--------------------------------------------------

equippedUpdateRemote.OnClientEvent:Connect(function(animType, animId)

	equippedAnimations[animType] = animId

	UpdateAnimationIds()

	if humanoid then
		SetupCharacter(player.Character)
	end

end)

--------------------------------------------------
-- 벽 클릭 연결
--------------------------------------------------

--local function ConnectWall(model)

--	if not model:IsA("Model") then return end
--	if model.Name ~= "ClientWall" then return end

--	local click = model:FindFirstChildWhichIsA("ClickDetector", true)
--	if not click then return end

--	click.MouseClick:Connect(function()

--		if isPowerTestActive then return end
--		if not canAttack then return end

--		canAttack = false
--		currentTargetWall = model

--		local wallId = model:GetAttribute("WallId")
--		if wallId then
--			attackStartRemote:FireServer(wallId)
--		end

--		task.delay(ATTACK_COOLDOWN, function()
--			canAttack = true
--		end)
--	end)
--end

function PerformAttack()

	if not canAttack then return end

	-- ?? PowerTest일 때 타겟 강제 지정
	if isPowerTestActive then
		currentTargetWall = workspace.PowertestMap:FindFirstChild("ClientWall", true)
	end

	-- ?? 일반 WallZone일 때 타겟 없으면 자동 탐색
	if not currentTargetWall then

		local character = player.Character
		if character then
			local root = character:FindFirstChild("HumanoidRootPart")

			if root then
				local closestWall = nil
				local closestDistance = math.huge

				for _, model in pairs(workspace:GetChildren()) do
					if model.Name == "ClientWall" then

						local pos = model:GetPivot().Position
						local dist = (root.Position - pos).Magnitude

						if dist < closestDistance then
							closestDistance = dist
							closestWall = model
						end
					end
				end

				currentTargetWall = closestWall
			end
		end
	end

	if not currentTargetWall then return end
	
	attackTargetWall = currentTargetWall

	canAttack = false

	local wallId = currentTargetWall:GetAttribute("WallId")
	if wallId then
		attackStartRemote:FireServer(wallId)
	end

	task.delay(ATTACK_COOLDOWN, function()
		canAttack = true
	end)


end

local function UpdateTargetWall()

	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local closestWall = nil
	local closestDistance = math.huge

	for _, model in pairs(workspace:GetChildren()) do
		if model.Name == "ClientWall" then

			local pos = model:GetPivot().Position
			local dist = (root.Position - pos).Magnitude

			if dist < closestDistance then
				closestDistance = dist
				closestWall = model
			end

		end
	end

	currentTargetWall = closestWall
end

--------------------------------------------------
-- 서버 애니메이션 분기
--------------------------------------------------

attackStartRemote.OnClientEvent:Connect(function(wallId, isDouble)

	if not normalTrack or not doubleTrack then return end

	if isDouble then
		currentAnimType = "Double"
		doubleTrack:Play()
	else
		currentAnimType = "Normal"
		normalTrack:Play()
	end
end)

--------------------------------------------------
-- 기존 벽 연결
--------------------------------------------------

--for _, model in ipairs(workspace:GetDescendants()) do
--	if model:IsA("Model") and model.Name == "ClientWall" then
--		ConnectWall(model)
--	end
--end

--workspace.DescendantAdded:Connect(function(child)
--	if child:IsA("Model") and child.Name == "ClientWall" then
--		ConnectWall(child)
--	end
--end)

--------------------------------------------------
-- 파워테스트 마우스 처리
--------------------------------------------------

--mouse.Button1Down:Connect(function()

--	if not isPowerTestActive then return end
--	if not canAttack then return end

--	local target = mouse.Target
--	if not target then return end

--	if target.Name == "SM_Training_Dummie_Empire" then

--		canAttack = false
--		currentTargetWall = workspace.PowertestMap:FindFirstChild("ClientWall")

--		if not currentTargetWall then return end

--		local wallId = currentTargetWall:GetAttribute("WallId")
--		if wallId then
--			attackStartRemote:FireServer(wallId)
--		end

--		task.delay(ATTACK_COOLDOWN, function()
--			canAttack = true
--		end)
--	end
--end)

--------------------------------------------------
-- Powertest 상태 관리
--------------------------------------------------

powertestRemote.OnClientEvent:Connect(function(action)

	if action == "StartTest" then
		isPowerTestActive = true
		canAttack = true
		currentTargetWall = nil
	end

	if action == "TestEndNotice" or action == "EndCamera" then
		isPowerTestActive = false
		canAttack = true
		currentTargetWall = nil
	end
end)

--------------------------------------------------
-- 데미지 팝업
--------------------------------------------------

popupRemote.OnClientEvent:Connect(function(damage, isCrit)

	local char = player.Character
	if not char then return end

	local head = char:FindFirstChild("Head")
	if not head then return end
	
	-- 사운드 추가
	local animId = equippedAnimations[currentAnimType]

	if attackTargetWall and animId then

		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")

		local pos = root and root.Position or Vector3.new(0,0,0)

		SoundManager.PlayHit(animId, pos, isCrit)

	end

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0,100,0,50)
	billboard.StudsOffsetWorldSpace = Vector3.new(0,3,0)
	billboard.Adornee = head
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.TextStrokeTransparency = 0
	label.Text = tostring(damage)

	if isCrit then
		label.TextColor3 = Color3.fromRGB(255,80,80)
	else
		label.TextColor3 = Color3.fromRGB(255,255,255)
	end

	label.Parent = billboard

	local tween = TweenService:Create(
		billboard,
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{StudsOffsetWorldSpace = Vector3.new(0,6,0)}
	)

	tween:Play()

	task.delay(0.4, function()
		local fadeTween = TweenService:Create(
			label,
			TweenInfo.new(0.3),
			{
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}
		)
		fadeTween:Play()
	end)

	task.delay(0.8, function()
		billboard:Destroy()
	end)

end)

local attackBindable = Instance.new("BindableEvent")
attackBindable.Name = "AttackRequest"
attackBindable.Parent = script

attackBindable.Event:Connect(function()
	PerformAttack()
end)

workspace.ChildAdded:Connect(function()
	UpdateTargetWall()
end)

workspace.ChildRemoved:Connect(function()
	UpdateTargetWall()
end)

UpdateTargetWall()