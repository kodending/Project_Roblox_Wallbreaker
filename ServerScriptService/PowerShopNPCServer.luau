local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage.RemoteEvents:WaitForChild("OpenPowerShopEvent")

--------------------------------------------------
-- NPC 경로 (수정 필요)
--------------------------------------------------

local npcPart = workspace.PlazaMap
	:WaitForChild("Growth_Store_Npc")
	:WaitForChild("SM_Man_Shaman_Tribal")

local prompt = npcPart:WaitForChild("ProximityPrompt")

--------------------------------------------------
-- Prompt 트리거
--------------------------------------------------

prompt.Triggered:Connect(function(player)

	-- ?? 추가 거리 체크 (보안 강화용)
	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if (root.Position - npcPart.Position).Magnitude > 15 then
		return
	end

	-- ?? UI 열기 신호
	remote:FireClient(player)

end)