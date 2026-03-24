local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local remote = ReplicatedStorage.RemoteEvents:WaitForChild("WallZoneEvent")
local hpUpdateRemote = ReplicatedStorage.RemoteEvents:WaitForChild("WallHPUpdate")
local breakRemote = ReplicatedStorage.RemoteEvents:WaitForChild("WallBreakStage")
local goldRewardRemote = ReplicatedStorage.RemoteEvents:WaitForChild("GoldRewardEvent")
local waveClearRemote = ReplicatedStorage.RemoteEvents:WaitForChild("WaveClearEvent")
local waveStartRemote = ReplicatedStorage.RemoteEvents:WaitForChild("WaveStartEvent")
local returnRemote = ReplicatedStorage.RemoteEvents:WaitForChild("ReturnToPlazaEvent")

local RankConfig = require(ReplicatedStorage:WaitForChild("RankConfig"))

local currentRank = "Unrank"
local currentMap = nil

--------------------------------------------------
-- UI 가져오기
--------------------------------------------------

local function GetHuntingUI()

	local playerGui = player:WaitForChild("PlayerGui")
	local huntingUI = playerGui:WaitForChild("HuntingUI")

	local waveText = huntingUI:WaitForChild("WaveText")
	local returnButton = huntingUI:WaitForChild("ReturnButton")

	return huntingUI, waveText, returnButton
end

--------------------------------------------------
-- 모든 벽 제거
--------------------------------------------------

local function ClearWalls()

	for _, obj in pairs(workspace:GetChildren()) do
		if obj.Name == "ClientWall" then
			obj:Destroy()
		end
	end

end

--------------------------------------------------
-- UI 세팅
--------------------------------------------------

local isUIInitialized = false

local function SetupHuntingUI()

	--local huntingUI, waveText, returnButton = GetHuntingUI()

	--returnButton.MouseButton1Click:Connect(function()

	--	ClearWalls()
	--	huntingUI.Enabled = false
	--	returnRemote:FireServer()

	--end)

	if isUIInitialized then return end
	isUIInitialized = true

	local huntingUI, waveText, returnButton = GetHuntingUI()

	-- ?? 공격 버튼 가져오기
	local attackButton = huntingUI:WaitForChild("AttackButton")

	-- ?? AttackController 안에 있는 BindableEvent 가져오기
	local playerScripts = player:WaitForChild("PlayerScripts")

	local attackBindable = playerScripts
		:WaitForChild("AttackController")
		:WaitForChild("AttackRequest")

	-- ?? 버튼 클릭 → 공격
	attackButton.MouseButton1Click:Connect(function()
		attackBindable:Fire()
	end)

	-- ?? 기존 리턴 버튼
	returnButton.MouseButton1Click:Connect(function()
		ClearWalls()
		huntingUI.Enabled = false
		
		-- ?? 추가
		local playerGui = player:WaitForChild("PlayerGui")
		local petDexUI = playerGui:WaitForChild("PetDexUI")
		petDexUI.Enabled = true
		
		returnRemote:FireServer()
	end)

end

SetupHuntingUI()

player.CharacterAdded:Connect(function()

	task.wait(1)
	SetupHuntingUI()

end)

--------------------------------------------------
-- 벽 생성
--------------------------------------------------

local function GenerateWall(wallData, originPosition)

	local model = Instance.new("Model")
	model.Name = "ClientWall"
	model.Parent = workspace

	local config = RankConfig.Ranks[currentRank]
	local baseHP = config.BaseHP
	local multiplier = wallData.Multiplier or 1

	local maxHP = math.floor(baseHP * multiplier)
	
	local CELL_SIZE = wallData.CellSize or 0.3
	local HEIGHT = wallData.Height or 0.3

	model:SetAttribute("MaxHP", maxHP)
	model:SetAttribute("HP", maxHP)
	model:SetAttribute("BreakStage", 0)

	local wallId = tostring(math.random(100000,999999))
	model:SetAttribute("WallId", wallId)

	local visualFolder = Instance.new("Folder")
	visualFolder.Name = "VisualParts"
	visualFolder.Parent = model

	local grid = wallData.Grid
	local colorMap = wallData.ColorMap
	local palette = wallData.Palette

	local width = #grid[1]
	local height = #grid
	local offsetX = (width * CELL_SIZE) / 2

	for y = 1, height do
		for x = 1, width do
			if grid[y][x] == 1 then

				local part = Instance.new("Part")
				part.Size = Vector3.new(CELL_SIZE, HEIGHT, CELL_SIZE)
				part.Anchored = true
				part.TopSurface = Enum.SurfaceType.Smooth
				part.BottomSurface = Enum.SurfaceType.Smooth

				local worldX = originPosition.X + (x - 1) * CELL_SIZE - offsetX
				local worldY = originPosition.Y + (height - y) * CELL_SIZE

				part.Position = Vector3.new(worldX, worldY, originPosition.Z)

				local colorIndex = colorMap[y][x]
				if palette[colorIndex] then
					part.Color = palette[colorIndex]
				end

				part.Parent = visualFolder
			end
		end
	end

	local totalWidth = width * CELL_SIZE
	local totalHeight = height * CELL_SIZE

	local hitbox = Instance.new("Part")
	hitbox.Name = "Hitbox"
	hitbox.Size = Vector3.new(totalWidth + 1, totalHeight + 1, 5)
	hitbox.Position = originPosition + Vector3.new(0, totalHeight/2, 0)
	hitbox.Anchored = true
	hitbox.CanCollide = false
	hitbox.Transparency = 1
	hitbox.Parent = model

	local click = Instance.new("ClickDetector")
	click.MaxActivationDistance = 20
	click.Parent = hitbox

	--------------------------------------------------
	-- HP BAR
	--------------------------------------------------

	local hpPart = Instance.new("Part")
	hpPart.Name = "HPBarPart"
	hpPart.Size = Vector3.new(totalWidth,1.5,0.4)
	hpPart.Anchored = true
	hpPart.CanCollide = false
	hpPart.Transparency = 1
	hpPart.Position = originPosition + Vector3.new(0,totalHeight-1.5,0)
	hpPart.Orientation = Vector3.new(0,180,0)
	hpPart.Parent = model

	local surface = Instance.new("SurfaceGui")
	surface.Adornee = hpPart
	surface.Face = Enum.NormalId.Front
	surface.CanvasSize = Vector2.new(200,40)
	surface.Parent = hpPart

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1,0,1,0)
	bg.BackgroundColor3 = Color3.fromRGB(60,60,60)
	bg.BorderSizePixel = 0
	bg.Parent = surface

	local hpBar = Instance.new("Frame")
	hpBar.Name = "HPBar"
	hpBar.Size = UDim2.new(1,0,1,0)
	hpBar.BackgroundColor3 = Color3.fromRGB(0,255,0)
	hpBar.BorderSizePixel = 0
	hpBar.Parent = bg

	local text = Instance.new("TextLabel")
	text.Name = "HPText"
	text.Size = UDim2.new(1,0,1,0)
	text.BackgroundTransparency = 1
	text.TextScaled = true
	text.TextColor3 = Color3.new(1,1,1)
	text.Text = maxHP.." / "..maxHP
	text.Parent = bg

	local displayHP = maxHP
	
	local function UpdateHP()

		local targetHP = model:GetAttribute("HP")
		local max = model:GetAttribute("MaxHP")

		if not targetHP or not max then return end

		if displayHP < targetHP then
			displayHP = targetHP
		end

		displayHP = math.min(displayHP, max)

		hpBar.Size = UDim2.new(displayHP/max,0,1,0)
		text.Text = displayHP.." / "..max

		task.spawn(function()

			while displayHP > targetHP do
				displayHP -= math.ceil((displayHP - targetHP) * 0.2)
				if displayHP < targetHP then
					displayHP = targetHP
				end

				hpBar.Size = UDim2.new(displayHP/max,0,1,0)
				text.Text = displayHP.." / "..max

				task.wait(0.02)
			end

		end)

	end

	model:GetAttributeChangedSignal("HP"):Connect(UpdateHP)
	model:GetAttributeChangedSignal("MaxHP"):Connect(UpdateHP)

	UpdateHP()

	--------------------------------------------------

	local registerRemote = ReplicatedStorage.RemoteEvents:WaitForChild("WallRegister")
	local reward = wallData.Reward or 0

	registerRemote:FireServer(wallId, maxHP, reward, originPosition)

end

--------------------------------------------------
-- 벽 생성
--------------------------------------------------

local function SpawnWalls()

	if not currentMap then return end

	local wallFolder = ReplicatedStorage:WaitForChild("WallData"):WaitForChild(currentRank)
	local allWalls = wallFolder:GetChildren()

	local spawnFolder = currentMap:WaitForChild("WallSpawns")
	local spawns = spawnFolder:GetChildren()

	for i = 1, math.min(5, #spawns) do

		local randomIndex = math.random(1, #allWalls)
		local wallData = require(allWalls[randomIndex])
		local spawnPart = spawns[i]

		if spawnPart and spawnPart:IsA("BasePart") then
			GenerateWall(wallData, spawnPart.Position)
		end

	end

end

--------------------------------------------------
-- 사냥터 입장
--------------------------------------------------

remote.OnClientEvent:Connect(function(action, rank)
	
	if action == "EnterMap" then

		ClearWalls()

		currentRank = rank

		local mapName = (rank == "Unrank") and "Tutorial" or (rank .. "Zone")
		currentMap = workspace:WaitForChild("WallZoneMaps"):WaitForChild(mapName)

		SpawnWalls()

		local huntingUI = GetHuntingUI()
		huntingUI.Enabled = true
		
		-- ?? 추가 (여기!)
		local playerGui = player:WaitForChild("PlayerGui")
		local petDexUI = playerGui:WaitForChild("PetDexUI")
		petDexUI.Enabled = false
		
		local character = player.Character
		if not character then return end

		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then return end
		
		task.wait(0.1)

		-- ?? 카메라 세팅
		local camera = workspace.CurrentCamera
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = character:FindFirstChild("Humanoid")

		local TweenService = game:GetService("TweenService")

		-- ?? 핵심: 왼쪽 위 사선
		local offset = Vector3.new(-6, 6, 12)

		local cameraPos = root.CFrame * CFrame.new(offset)

		local targetCFrame = CFrame.new(
			cameraPos.Position,
			root.Position + Vector3.new(0, 2, 0)
		)

		local tween = TweenService:Create(
			camera,
			TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{CFrame = targetCFrame}
		)

		tween:Play()

	end
end)

--------------------------------------------------
-- HP 업데이트
--------------------------------------------------

hpUpdateRemote.OnClientEvent:Connect(function(wallId, newHP, newMaxHP)

	for _, model in pairs(workspace:GetChildren()) do
		if model.Name == "ClientWall" and model:GetAttribute("WallId") == wallId then
			model:SetAttribute("MaxHP", newMaxHP)
			model:SetAttribute("HP", newHP)
			break
		end
	end

end)

--------------------------------------------------
-- 벽 파괴
--------------------------------------------------

breakRemote.OnClientEvent:Connect(function(wallId, stage)

	for _, model in pairs(workspace:GetChildren()) do
		if model.Name == "ClientWall" and model:GetAttribute("WallId") == wallId then

			local parts = model.VisualParts:GetChildren()

			if stage == "Final" then

				local explodeCount = math.min(50, #parts)

				for i = 1, explodeCount do
					local index = math.random(1, #parts)
					local part = table.remove(parts, index)

					if part then
						part.Parent = workspace
						part.Anchored = false

						local impulse = Vector3.new(
							math.random(-40,40),
							math.random(30,80),
							math.random(-40,40)
						)

						part:ApplyImpulse(impulse * part.AssemblyMass)

						task.delay(1.5, function()
							if part then part:Destroy() end
						end)
					end
				end

				for _, part in pairs(parts) do
					part:Destroy()
				end

				model:Destroy()
				return
			end

			local breakCount = math.min(50, #parts)

			for i = 1, breakCount do
				local index = math.random(1, #parts)
				local part = table.remove(parts, index)

				if part then
					part.Anchored = false
					part.CanCollide = false

					local impulse = Vector3.new(
						math.random(-15,15),
						math.random(15,40),
						math.random(-15,15)
					)

					part:ApplyImpulse(impulse * part.AssemblyMass)

					task.delay(1, function()
						if part then part:Destroy() end
					end)
				end
			end

			break
		end
	end
end)

--------------------------------------------------
-- 골드 팝업
--------------------------------------------------

goldRewardRemote.OnClientEvent:Connect(function(reward, position)

	local anchorPart = Instance.new("Part")
	anchorPart.Anchored = true
	anchorPart.CanCollide = false
	anchorPart.Transparency = 1
	anchorPart.Size = Vector3.new(1,1,1)
	anchorPart.Position = position + Vector3.new(0,2,0)
	anchorPart.Parent = workspace

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0,150,0,50)
	billboard.Adornee = anchorPart
	billboard.AlwaysOnTop = true
	billboard.Parent = anchorPart

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = Color3.fromRGB(255,215,0)
	label.Text = "+ "..reward.." Gold"
	label.Parent = billboard

	task.delay(1,function()
		anchorPart:Destroy()
	end)

end)

waveClearRemote.OnClientEvent:Connect(function()

	if not currentMap then return end

	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	task.wait(0.3)

	local spawnPoint = currentMap.WallZone_Ground.TeleportPoint
	root.CFrame = spawnPoint.CFrame

	task.wait(0.1)

	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable

	local TweenService = game:GetService("TweenService")

	-- ?? 월드 기준 고정 오프셋
	local offset = Vector3.new(-6, 6, 12)
	local cameraPos = root.Position + offset

	local targetCFrame = CFrame.new(
		cameraPos,
		root.Position + Vector3.new(0, 2, 0)
	)

	local tween = TweenService:Create(
		camera,
		TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{CFrame = targetCFrame}
	)

	tween:Play()

	-- ?? tween 끝나면 복구
	tween.Completed:Connect(function()
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = character:FindFirstChild("Humanoid")
	end)

	task.wait(0.3)

	SpawnWalls()

end)

--------------------------------------------------
-- Wave UI
--------------------------------------------------

waveStartRemote.OnClientEvent:Connect(function(wave)

	local huntingUI, waveText = GetHuntingUI()

	waveText.Text = "Wave " .. wave

end)