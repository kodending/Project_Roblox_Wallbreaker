local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage.RemoteEvents:WaitForChild("OpenPetShopEvent")

local priceRemote = ReplicatedStorage.RemoteEvents:WaitForChild("SendPetShopPrice")

local PetConfig = require(ReplicatedStorage:WaitForChild("PetConfig"))

--------------------------------------------------
-- NPC 경로 (실제 경로에 맞게 수정)
--------------------------------------------------

local npcPart = workspace.PlazaMap
	:WaitForChild("Pet_Store_Npc")
	:WaitForChild("man-tie")

local prompt = npcPart:WaitForChild("ProximityPrompt")

--------------------------------------------------
-- Prompt 트리거
--------------------------------------------------

prompt.Triggered:Connect(function(player)

	-- ?? 추가 거리 체크
	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if (root.Position - npcPart.Position).Magnitude > 15 then
		return
	end
	
	--------------------------------------------------
	-- ?? 여기 추가 (핵심)
	--------------------------------------------------

	local price = PetConfig.GachaPrice

	priceRemote:FireClient(player, {
		SingleGold = price.Single,
		TenGold = price.Ten,
		SingleRobux = 10,
		TenRobux = 95
	})

	--------------------------------------------------
	-- UI 열기
	--------------------------------------------------

	-- ?? UI 열기 신호
	remote:FireClient(player)

end)