local Players = game:GetService("Players")

local player = Players.LocalPlayer

local gui = script.Parent
local frame = gui:WaitForChild("StatusFrame")

local titleLabel = frame:WaitForChild("TitleLabel")
local powerLabel = frame:WaitForChild("PowerLabel")
local rankLabel = frame:WaitForChild("RankLabel")

--------------------------------------------------
-- 숫자 포맷
--------------------------------------------------

local function FormatNumber(n)
	local formatted = tostring(n)
	while true do
		local new, count = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		formatted = new
		if count == 0 then break end
	end
	return formatted
end

--------------------------------------------------
-- 갱신 함수
--------------------------------------------------

local function UpdateUI()

	local rank = player:GetAttribute("CurrentRank") or "Unrank"
	local power = player:GetAttribute("CombatPower") or 0

	powerLabel.Text = FormatNumber(power)
	rankLabel.Text = rank

	-- 랭크 색상 강조
	local colors = {
		F = Color3.fromRGB(180,180,180),
		E = Color3.fromRGB(100,200,100),
		D = Color3.fromRGB(80,170,255),
		C = Color3.fromRGB(255,255,255),
		B = Color3.fromRGB(255,150,60),
		A = Color3.fromRGB(255,100,60),
		S = Color3.fromRGB(255,80,80),
		SS = Color3.fromRGB(200,80,255),
		SSS = Color3.fromRGB(255,215,0),
	}

	rankLabel.TextColor3 = colors[rank] or Color3.new(1,1,1)
end

--------------------------------------------------
-- Attribute 변화 감지
--------------------------------------------------

player:GetAttributeChangedSignal("CurrentRank"):Connect(UpdateUI)
player:GetAttributeChangedSignal("CombatPower"):Connect(UpdateUI)

-- 최초 실행
UpdateUI()