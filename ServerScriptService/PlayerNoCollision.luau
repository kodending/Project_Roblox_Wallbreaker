local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

--------------------------------------------------
-- Collision Group 이름
--------------------------------------------------

local GROUP_NAME = "Players"

--------------------------------------------------
-- 그룹 생성
--------------------------------------------------

pcall(function()
	PhysicsService:RegisterCollisionGroup(GROUP_NAME)
end)

--------------------------------------------------
-- 플레이어끼리 충돌 비활성화
--------------------------------------------------

PhysicsService:CollisionGroupSetCollidable(GROUP_NAME, GROUP_NAME, false)

--------------------------------------------------
-- 캐릭터 파츠 적용
--------------------------------------------------

local function SetupCharacter(character)

	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = GROUP_NAME
		end
	end

	character.DescendantAdded:Connect(function(obj)
		if obj:IsA("BasePart") then
			obj.CollisionGroup = GROUP_NAME
		end
	end)

end

--------------------------------------------------
-- 플레이어 입장
--------------------------------------------------

Players.PlayerAdded:Connect(function(player)

	player.CharacterAdded:Connect(function(character)

		SetupCharacter(character)

	end)

end)