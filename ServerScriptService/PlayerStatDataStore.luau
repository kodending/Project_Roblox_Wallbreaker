local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

--------------------------------------------------
-- DataStore
--------------------------------------------------

local statStore = DataStoreService:GetDataStore("PlayerStats_v26")

--------------------------------------------------
-- 설정
--------------------------------------------------

local AUTOSAVE_INTERVAL = 300
local RETRY_COUNT = 5

--------------------------------------------------
-- 저장할 스탯
--------------------------------------------------

local STAT_LIST = {

	"BaseDamage",
	"UpgradeDamage",

	"DoubleChance",
	"CritChance",
	"CritBonus",

	"PetFlatDamage",
	"PetPercentDamage",
	"PetDoubleChance",
	"PetCritChance",
	"PetCritBonus",

	"Gold",

	"CombatPower",
	"CurrentRank"
}

--------------------------------------------------
-- 데이터 수집
--------------------------------------------------

local function CollectPlayerData(player)

	local data = {}

	for _, stat in ipairs(STAT_LIST) do
		data[stat] = player:GetAttribute(stat)
	end

	return data

end

--------------------------------------------------
-- Save (Retry 포함)
--------------------------------------------------

local function SavePlayer(player)

	local data = CollectPlayerData(player)

	for i = 1, RETRY_COUNT do

		local success, err = pcall(function()

			statStore:SetAsync(player.UserId, data)

		end)

		if success then
			return
		end

		warn("Save retry :", i, err)

		task.wait(2)

	end

end

--------------------------------------------------
-- Load (Retry 포함)
--------------------------------------------------

local function LoadPlayer(player)

	for i = 1, RETRY_COUNT do

		local success, data = pcall(function()

			return statStore:GetAsync(player.UserId)

		end)

		if success then

			if data then
				for stat, value in pairs(data) do
					player:SetAttribute(stat, value)
				end
			end

			return
		end

		warn("Load retry :", i)

		task.wait(2)

	end

end

--------------------------------------------------
-- Player Join
--------------------------------------------------

Players.PlayerAdded:Connect(function(player)

	task.wait(1)

	LoadPlayer(player)

end)

--------------------------------------------------
-- Player Leave
--------------------------------------------------

Players.PlayerRemoving:Connect(function(player)

	SavePlayer(player)

end)

--------------------------------------------------
-- AutoSave
--------------------------------------------------

task.spawn(function()

	while true do

		task.wait(AUTOSAVE_INTERVAL)

		for _, player in ipairs(Players:GetPlayers()) do
			SavePlayer(player)
		end

	end

end)

--------------------------------------------------
-- 서버 종료 보호
--------------------------------------------------

game:BindToClose(function()

	for _, player in ipairs(Players:GetPlayers()) do
		SavePlayer(player)
	end

	task.wait(3)

end)