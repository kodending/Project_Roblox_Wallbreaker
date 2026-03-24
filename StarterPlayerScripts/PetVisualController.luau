local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local resultRemote = remoteFolder:WaitForChild("PetEquipResult")
local PetModels = ReplicatedStorage:WaitForChild("PetModels")

local activePets = {}

--------------------------------------------------
-- 기존 제거
--------------------------------------------------

local function ClearPets()

	for _, data in pairs(activePets) do
		if data.Model then
			data.Model:Destroy()
		end
	end

	table.clear(activePets)

end

--------------------------------------------------
-- 펫 생성
--------------------------------------------------

local function SpawnPet(petId)

	local template = PetModels:FindFirstChild(petId)
	if not template then
		warn("Pet model not found:", petId)
		return
	end

	local clone = template:Clone()
	clone.Parent = workspace

	--------------------------------------------------
	-- ?? PrimaryPart 안전 처리 (중요)
	--------------------------------------------------

	if not clone.PrimaryPart then
		local primary = clone:FindFirstChildWhichIsA("BasePart")
		if primary then
			clone.PrimaryPart = primary
		else
			warn("No PrimaryPart:", petId)
			return
		end
	end

	--------------------------------------------------
	-- 애니메이션
	--------------------------------------------------

	local controller = clone:FindFirstChildOfClass("AnimationController")

	if controller then

		local animator = controller:FindFirstChildOfClass("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = controller
		end

		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://99348259760104"

		local track = animator:LoadAnimation(animation)
		track.Looped = true
		track:AdjustSpeed(0.75)
		track:Play()

	end

	--------------------------------------------------

	table.insert(activePets,{
		Model = clone,
		CurrentCF = clone:GetPrimaryPartCFrame()
	})

end

--------------------------------------------------
-- 메인 업데이트
--------------------------------------------------

RunService.RenderStepped:Connect(function()

	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local count = #activePets
	if count == 0 then return end

	local baseAngle = 45
	local radius = 3.5
	local height = 2.5
	local spread = 4

	for i, data in ipairs(activePets) do

		local model = data.Model
		if not model or not model.Parent then continue end
		if not model.PrimaryPart then continue end

		local percent = (count > 1) and ((i - 1) / (count - 1)) or 0

		local angle = math.rad(-baseAngle + percent * (baseAngle * 2))

		local backward = -hrp.CFrame.LookVector
		local right = hrp.CFrame.RightVector

		local offset =
			backward * radius +
			right * (math.sin(angle) * spread)

		local hover = math.sin(tick()*2 + i) * 0.5

		local targetPos =
			hrp.Position +
			offset +
			Vector3.new(0, height + hover, 0)

		local targetCF = CFrame.new(targetPos, targetPos + hrp.CFrame.LookVector)

		data.CurrentCF = data.CurrentCF:Lerp(targetCF, 0.15)

		model:SetPrimaryPartCFrame(data.CurrentCF)

	end
end)

--------------------------------------------------
-- 서버 결과 수신
--------------------------------------------------

resultRemote.OnClientEvent:Connect(function(data)

	if not data or not data.Equipped then return end

	--------------------------------------------------
	-- ?? 동일 상태면 재생성 방지 (중요)
	--------------------------------------------------

	local same = true

	for i = 1,3 do
		local info = data.Equipped[i]
		local active = activePets[i]

		if info then
			if not active or active.Model.Name ~= info.PetId then
				same = false
				break
			end
		else
			if active then
				same = false
				break
			end
		end
	end

	if same then return end

	--------------------------------------------------

	local newActive = {}

	for i = 1,3 do
		local info = data.Equipped[i]
		local current = activePets[i]

		if info then
			-- 같은 펫이면 유지
			if current and current.Model.Name == info.PetId then
				newActive[i] = current
			else
				-- 기존 제거
				if current and current.Model then
					current.Model:Destroy()
				end

				-- 새로 생성
				local template = PetModels:FindFirstChild(info.PetId)
				if template then
					local clone = template:Clone()
					clone.Parent = workspace

					-- PrimaryPart 보정
					if not clone.PrimaryPart then
						local primary = clone:FindFirstChildWhichIsA("BasePart")
						if primary then
							clone.PrimaryPart = primary
						else
							continue
						end
					end

					-- 애니메이션 (기존 유지)
					local controller = clone:FindFirstChildOfClass("AnimationController")
					if controller then
						local animator = controller:FindFirstChildOfClass("Animator")
						if not animator then
							animator = Instance.new("Animator")
							animator.Parent = controller
						end

						local animation = Instance.new("Animation")
						animation.AnimationId = "rbxassetid://99348259760104"

						local track = animator:LoadAnimation(animation)
						track.Looped = true
						track:AdjustSpeed(0.75)
						track:Play()
					end

					newActive[i] = {
						Model = clone,
						CurrentCF = clone:GetPrimaryPartCFrame()
					}
				end
			end
		else
			-- 슬롯 비었으면 제거
			if current and current.Model then
				current.Model:Destroy()
			end
		end
	end

	activePets = newActive

end)