local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local SoundConfig = require(ReplicatedStorage.SoundConfig)
local AnimationConfig = require(ReplicatedStorage.AnimationConfig)

local SoundManager = {}

--------------------------------------------------
-- 기본 SFX
--------------------------------------------------

function SoundManager.Play(name, parent)

	local data = SoundConfig[name]
	if not data then return end

	local sound = Instance.new("Sound")
	sound.SoundId = data.Id
	sound.Volume = data.Volume or 1
	sound.Parent = parent or SoundService

	sound:Play()

	Debris:AddItem(sound, 3)
	
	return sound -- ?? 추가
end

--------------------------------------------------
-- 3D 사운드 (위치 기반)
--------------------------------------------------

function SoundManager.PlayAt(name, position)

	local data = SoundConfig[name]
	if not data then return end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Position = position
	part.Parent = workspace

	local sound = Instance.new("Sound")
	sound.SoundId = data.Id
	sound.Volume = data.Volume or 1
	sound.RollOffMode = Enum.RollOffMode.Inverse
	sound.Parent = part

	sound:Play()

	Debris:AddItem(part, 3)
end

--------------------------------------------------
-- ?? 애니메이션 기반 Hit 사운드 (핵심)
--------------------------------------------------

function SoundManager.PlayHit(animId, position, isCritical)


	local animData = AnimationConfig.GetAnimation(animId)
	if not animData then return end

	local soundName = animData.HitSound

	-- ?? 크리티컬이면 다른 사운드
	if isCritical then
		local critSounds = {
			"Hit_Wall_03",
			"Hit_Wall_04",
			"Hit_Wall_05",
		}
		soundName = critSounds[math.random(#critSounds)]
	end

	SoundManager.PlayAt(soundName, position)

end

--------------------------------------------------
-- BGM
--------------------------------------------------

local currentBGM = nil

function SoundManager.PlayBGM(name)

	if currentBGM then
		currentBGM:Stop()
		currentBGM:Destroy()
	end

	local data = SoundConfig[name]
	if not data then return end

	local sound = Instance.new("Sound")
	sound.SoundId = data.Id
	sound.Volume = data.Volume or 0.5
	sound.Looped = true
	sound.Parent = SoundService

	sound:Play()

	currentBGM = sound
end

--------------------------------------------------

return SoundManager