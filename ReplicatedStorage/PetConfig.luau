local PetConfig = {}


----------------------------------
-- 가챠샵 가격
----------------------------------

PetConfig.GachaPrice = {
	Single = 1500,
	Ten = 14500
}

--------------------------------------------------
-- 등급 정보
--------------------------------------------------

PetConfig.Rarity = {
	Common = {
		Weight = 70
	},
	Rare = {
		Weight = 22
	},
	Epic = {
		Weight = 7
	},
	Legendary = {
		Weight = 1
	}
}

--------------------------------------------------
-- 강화 증가량
--------------------------------------------------

PetConfig.EnhanceStats = {

	Common = {
		DamageFlat = 35,
		DamagePercent = 5,
		DoubleChance = 1,
		CritChance = 1,
		CritBonus = 10
	},

	Rare = {
		DamageFlat = 50,
		DamagePercent = 10,
		DoubleChance = 2,
		CritChance = 2,
		CritBonus = 15
	},

	Epic = {
		DamageFlat = 0,
		DamagePercent = 20,
		DoubleChance = 4,
		CritChance = 4,
		CritBonus = 25
	},

	Legendary = {
		DamageFlat = 0,
		DamagePercent = 40,
		DoubleChance = 6,
		CritChance = 6,
		CritBonus = 40
	}
}

--------------------------------------------------
-- 펫 목록
--------------------------------------------------

PetConfig.Pets = {

	--------------------------------------------------
	-- Common
	--------------------------------------------------

	{
		Id = "Common_Pet_01",
		Name = "꼬물이",
		Rarity = "Common",
		Icon = "rbxassetid://140446972679554",

		Stats = {
			DamageFlat = 20,
			DamagePercent = 0,
			DoubleChance = 0,
			CritChance = 0,
			CritBonus = 0
		}
	},
	
	{
		Id = "Common_Pet_02",
		Name = "뿅드래",
		Rarity = "Common",
		Icon = "rbxassetid://101936979503548",

		Stats = {
			DamageFlat = 0,
			DamagePercent = 0,
			DoubleChance = 3,
			CritChance = 0,
			CritBonus = 0
		}
	},
	
	{
		Id = "Common_Pet_03",
		Name = "포포곤",
		Rarity = "Common",
		Icon = "rbxassetid://105020849572585",

		Stats = {
			DamageFlat = 0,
			DamagePercent = 0,
			DoubleChance = 0,
			CritChance = 0,
			CritBonus = 15
		}
	},
	
	{
		Id = "Common_Pet_04",
		Name = "드래몽",
		Rarity = "Common",
		Icon = "rbxassetid://73058658229821",

		Stats = {
			DamageFlat = 0,
			DamagePercent = 5,
			DoubleChance = 0,
			CritChance = 0,
			CritBonus = 0
		}
	},


	--------------------------------------------------
	-- Rare
	--------------------------------------------------

	{
		Id = "Rare_Pet_01",
		Name = "플레미",
		Rarity = "Rare",
		Icon = "rbxassetid://117749286920273",

		Stats = {
			DamageFlat = 60,
			DamagePercent = 8,
			DoubleChance = 0,
			CritChance = 0,
			CritBonus = 0
		}
	},
	
	{
		Id = "Rare_Pet_02",
		Name = "루미드",
		Rarity = "Rare",
		Icon = "rbxassetid://77983347135647",

		Stats = {
			DamageFlat = 0,
			DamagePercent = 10,
			DoubleChance = 0,
			CritChance = 4,
			CritBonus = 0
		}
	},
	
	{
		Id = "Rare_Pet_03",
		Name = "드래핀",
		Rarity = "Rare",
		Icon = "rbxassetid://116072845615164",

		Stats = {
			DamageFlat = 0,
			DamagePercent = 0,
			DoubleChance = 0,
			CritChance = 5,
			CritBonus = 20
		}
	},
	
	{
		Id = "Rare_Pet_04",
		Name = "볼케리",
		Rarity = "Rare",
		Icon = "rbxassetid://129919058158692",

		Stats = {
			DamageFlat = 0,
			DamagePercent = 8,
			DoubleChance = 6,
			CritChance = 0,
			CritBonus = 0
		}
	},
	
	{
		Id = "Rare_Pet_05",
		Name = "프로니",
		Rarity = "Rare",
		Icon = "rbxassetid://109058813985839",

		Stats = {
			DamageFlat = 0,
			DamagePercent = 6,
			DoubleChance = 0,
			CritChance = 6,
			CritBonus = 10
		}
	},

	--------------------------------------------------
	-- Epic
	--------------------------------------------------

	{
		Id = "Epic_Pet_01",
		Name = "블레이즈링",
		Rarity = "Epic",
		Icon = "rbxassetid://105753531805953",

		Stats = {
			DamageFlat = 0,
			DamagePercent = 15,
			DoubleChance = 5,
			CritChance = 5,
			CritBonus = 0
		}
	},
	
	{
		Id = "Epic_Pet_02",
		Name = "크림슨윙",
		Rarity = "Epic",
		Icon = "rbxassetid://106187949789453",

		Stats = {
			DamageFlat = 0,
			DamagePercent = 10,
			DoubleChance = 3,
			CritChance = 5,
			CritBonus = 30
		}
	},
	
	{
		Id = "Epic_Pet_03",
		Name = "아스트로곤",
		Rarity = "Epic",
		Icon = "rbxassetid://79419577594518",

		Stats = {
			DamageFlat = 0,
			DamagePercent = 10,
			DoubleChance = 0,
			CritChance = 8,
			CritBonus = 30
		}
	},
	
	{
		Id = "Epic_Pet_04",
		Name = "네오드래",
		Rarity = "Epic",
		Icon = "rbxassetid://125036993056564",

		Stats = {
			DamageFlat = 0,
			DamagePercent = 12,
			DoubleChance = 5,
			CritChance = 0,
			CritBonus = 25
		}
	},
	
	{
		Id = "Epic_Pet_05",
		Name = "쉐도윙",
		Rarity = "Epic",
		Icon = "rbxassetid://93055725826410",

		Stats = {
			DamageFlat = 0,
			DamagePercent = 10,
			DoubleChance = 8,
			CritChance = 5,
			CritBonus = 15
		}
	},


	--------------------------------------------------
	-- Legendary
	--------------------------------------------------

	{
		Id = "Legendary_Pet_01",
		Name = "인페르노 로드",
		Rarity = "Legendary",
		Icon = "rbxassetid://123705932416961",

		Stats = {
			DamageFlat = 0,
			DamagePercent = 30,
			DoubleChance = 10,
			CritChance = 10,
			CritBonus = 40
		}
	},


	{
		Id = "Legendary_Pet_02",
		Name = "템페스트 킹",
		Rarity = "Legendary",
		Icon = "rbxassetid://96366387400609",

		Stats = {
			DamageFlat = 0,
			DamagePercent = 60,
			DoubleChance = 5,
			CritChance = 5,
			CritBonus = 30
		}
	},
	
	{
		Id = "Legendary_Pet_03",
		Name = "아르카 드래곤",
		Rarity = "Legendary",
		Icon = "rbxassetid://112269608673232",

		Stats = {
			DamageFlat = 0,
			DamagePercent = 25,
			DoubleChance = 20,
			CritChance = 5,
			CritBonus = 30
		}
	},
	
	{
		Id = "Legendary_Pet_04",
		Name = "블러드 스케일",
		Rarity = "Legendary",
		Icon = "rbxassetid://140037573503576",

		Stats = {
			DamageFlat = 0,
			DamagePercent = 25,
			DoubleChance = 5,
			CritChance = 20,
			CritBonus = 30
		}
	},
	
	{
		Id = "Legendary_Pet_05",
		Name = "월광의 미르",
		Rarity = "Legendary",
		Icon = "rbxassetid://118254367319811",

		Stats = {
			DamageFlat = 0,
			DamagePercent = 25,
			DoubleChance = 5,
			CritChance = 5,
			CritBonus = 80
		}
	},
}

--------------------------------------------------
-- 등급 필터 함수 (서버용)
--------------------------------------------------

function PetConfig.GetPetsByRarity(rarity)

	local list = {}

	for _, pet in ipairs(PetConfig.Pets) do
		if pet.Rarity == rarity then
			table.insert(list, pet)
		end
	end

	return list
end

--------------------------------------------------
-- Id로 펫 찾기
--------------------------------------------------

function PetConfig.GetPetById(id)

	for _, pet in ipairs(PetConfig.Pets) do
		if pet.Id == id then
			return pet
		end
	end

	return nil
end

return PetConfig