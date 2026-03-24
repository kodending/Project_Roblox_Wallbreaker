local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

--------------------------------------------------
-- UI 참조
--------------------------------------------------

local hud = script.Parent

local moneyFrame = hud:WaitForChild("MoneyFrame")
local moneyText = moneyFrame:WaitForChild("MoneyText")

local statsFrame = hud:WaitForChild("StatsFrame")
local damageText = statsFrame:WaitForChild("DamageText")
local doubleText = statsFrame:WaitForChild("DoubleText")
local critChanceText = statsFrame:WaitForChild("CritChanceText")
local critBonusText = statsFrame:WaitForChild("CritBonusText")

--------------------------------------------------
-- 숫자 포맷
--------------------------------------------------

local function FormatNumber(num)
	local formatted = tostring(math.floor(num))
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then break end
	end
	return formatted
end

--------------------------------------------------
-- 골드 애니메이션
--------------------------------------------------

local displayedGold = player:GetAttribute("Gold") or 0
local tweenConnection = nil

local function AnimateMoneyChange(oldValue, newValue)

	if tweenConnection then
		tweenConnection:Disconnect()
	end

	local duration = 0.4
	local startTime = tick()

	tweenConnection = game:GetService("RunService").RenderStepped:Connect(function()
		local alpha = (tick() - startTime) / duration

		if alpha >= 1 then
			displayedGold = newValue
			moneyText.Text = FormatNumber(newValue)
			tweenConnection:Disconnect()
			return
		end

		local current = oldValue + (newValue - oldValue) * alpha
		moneyText.Text = FormatNumber(current)
	end)
end

--------------------------------------------------
-- 스탯 업데이트
--------------------------------------------------

local function UpdateStats()

	local base = player:GetAttribute("BaseDamage") or 0
	local upgrade = player:GetAttribute("UpgradeDamage") or 0
	local petFlat = player:GetAttribute("PetFlatDamage") or 0
	local petPercent = player:GetAttribute("PetPercentDamage") or 0

	local baseDouble = player:GetAttribute("DoubleChance") or 0
	local petDouble = player:GetAttribute("PetDoubleChance") or 0

	local baseCritChance = player:GetAttribute("CritChance") or 0
	local petCritChance = player:GetAttribute("PetCritChance") or 0

	local baseCritBonus = player:GetAttribute("CritBonus") or 0
	local petCritBonus = player:GetAttribute("PetCritBonus") or 0

	--------------------------------------------------
	-- 공격력 계산
	--------------------------------------------------

	local rawDamage = base + upgrade
	local totalDamage = (rawDamage + petFlat) * (1 + petPercent / 100)

	damageText.Text =
		FormatNumber(totalDamage) ..
		"(+" .. FormatNumber(petFlat) ..
		(petPercent > 0 and " +" .. petPercent .. "%" or "") ..
		")"

	--------------------------------------------------
	-- 더블 확률
	--------------------------------------------------

	local totalDouble = baseDouble + petDouble
	doubleText.Text =
		totalDouble .. "%" ..
		(petDouble > 0 and "(+" .. petDouble .. "%)" or "")

	--------------------------------------------------
	-- 크리 확률
	--------------------------------------------------

	local totalCritChance = baseCritChance + petCritChance
	critChanceText.Text =
		totalCritChance .. "%" ..
		(petCritChance > 0 and "(+" .. petCritChance .. "%)" or "")

	--------------------------------------------------
	-- 크리 추가 데미지
	--------------------------------------------------

	local totalCritBonus = baseCritBonus + petCritBonus
	critBonusText.Text =
		totalCritBonus .. "%" ..
		(petCritBonus > 0 and "(+" .. petCritBonus .. "%)" or "")

end

--------------------------------------------------
-- Attribute 변경 감지 연결
--------------------------------------------------

player:GetAttributeChangedSignal("Gold"):Connect(function()
	local newGold = player:GetAttribute("Gold") or 0
	AnimateMoneyChange(displayedGold, newGold)
	displayedGold = newGold
end)

-- 기본 스탯
player:GetAttributeChangedSignal("BaseDamage"):Connect(UpdateStats)
player:GetAttributeChangedSignal("UpgradeDamage"):Connect(UpdateStats)
player:GetAttributeChangedSignal("DoubleChance"):Connect(UpdateStats)
player:GetAttributeChangedSignal("CritChance"):Connect(UpdateStats)
player:GetAttributeChangedSignal("CritBonus"):Connect(UpdateStats)

-- 펫 스탯
player:GetAttributeChangedSignal("PetFlatDamage"):Connect(UpdateStats)
player:GetAttributeChangedSignal("PetPercentDamage"):Connect(UpdateStats)
player:GetAttributeChangedSignal("PetDoubleChance"):Connect(UpdateStats)
player:GetAttributeChangedSignal("PetCritChance"):Connect(UpdateStats)
player:GetAttributeChangedSignal("PetCritBonus"):Connect(UpdateStats)

--------------------------------------------------
-- 초기 세팅
--------------------------------------------------

displayedGold = player:GetAttribute("Gold") or 0
moneyText.Text = FormatNumber(displayedGold)
UpdateStats()