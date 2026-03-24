local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--------------------------------------------------
-- Remote
--------------------------------------------------

local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local enterRemote = remoteFolder:WaitForChild("RequestEnterAnimationZone")

--------------------------------------------------
-- Zone
--------------------------------------------------

local zone = workspace:WaitForChild("AnimationZone")
local teleportPoint = zone:WaitForChild("TeleportPoint")

--------------------------------------------------
-- 안전 텔레포트 함수
--------------------------------------------------

local function TeleportPlayer(player)

	local character = player.Character
	if not character then
		character = player.CharacterAdded:Wait()
	end

	local root = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:WaitForChild("Humanoid")

	-- 물리 상태 초기화
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero

	-- 안전 위치 (위로 띄우기)
	local targetCF = teleportPoint.CFrame + Vector3.new(0,3,0)

	-- 텔레포트
	character:PivotTo(targetCF)

	-- 물리 안정화
	task.wait()
	humanoid:ChangeState(Enum.HumanoidStateType.Running)

end

--------------------------------------------------
-- Remote 처리
--------------------------------------------------

enterRemote.OnServerEvent:Connect(function(player)

	if not player or not player:IsDescendantOf(Players) then
		return
	end

	TeleportPlayer(player)

end)