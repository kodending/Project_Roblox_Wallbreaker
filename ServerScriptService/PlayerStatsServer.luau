local Players = game:GetService("Players")

--------------------------------------------------
-- 플레이어 입장 시 스탯 초기화
--------------------------------------------------

Players.PlayerAdded:Connect(function(player)

	-- ?? 기본 공격 관련
	player:SetAttribute("BaseDamage", 50)
	player:SetAttribute("UpgradeDamage", 0)

	-- ?? 확률 관련 (기본값)
	player:SetAttribute("DoubleChance", 5)  -- %
	player:SetAttribute("CritChance", 5)    -- %
	player:SetAttribute("CritBonus", 50)     -- %

	-- ?? 펫 추가 스탯 (초기값 0)
	player:SetAttribute("PetFlatDamage", 0)
	player:SetAttribute("PetPercentDamage", 0)
	player:SetAttribute("PetDoubleChance", 0)
	player:SetAttribute("PetCritChance", 0)
	player:SetAttribute("PetCritBonus", 0)

	-- ?? 재화
	player:SetAttribute("Gold", 0)

	-- ?? PowerTest 관련 기록
	player:SetAttribute("BestPowerScore", 0)
	player:SetAttribute("CurrentRank", "Unrank")

end)

--------------------------------------------------
-- 최종 데미지 계산 함수 (서버 전용)
--------------------------------------------------

_G.CalculateFinalDamage = function(player)

	if not player then return nil end

	--------------------------------------------------
	-- 기본 공격력 계산
	--------------------------------------------------

	local base = tonumber(player:GetAttribute("BaseDamage")) or 0
	local upgrade = tonumber(player:GetAttribute("UpgradeDamage")) or 0
	local petFlat = tonumber(player:GetAttribute("PetFlatDamage")) or 0
	local petPercent = tonumber(player:GetAttribute("PetPercentDamage")) or 0

	local damage = base + upgrade + petFlat
	damage = damage * (1 + (petPercent / 100))

	--------------------------------------------------
	-- 크리 확률 계산
	--------------------------------------------------

	local baseCrit = tonumber(player:GetAttribute("CritChance")) or 0
	local petCrit = tonumber(player:GetAttribute("PetCritChance")) or 0
	local totalCritChance = baseCrit + petCrit

	local isCrit = false

	if math.random(1,100) <= totalCritChance then

		local baseCritBonus = tonumber(player:GetAttribute("CritBonus")) or 0
		local petCritBonus = tonumber(player:GetAttribute("PetCritBonus")) or 0
		local totalCritBonus = baseCritBonus + petCritBonus

		damage = damage + (damage * (totalCritBonus / 100))
		isCrit = true
	end

	damage = tonumber(damage) or 0

	return math.floor(damage), isCrit
end