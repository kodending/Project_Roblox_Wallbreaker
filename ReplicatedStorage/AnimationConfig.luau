local AnimationConfig = {}

--------------------------------------------------
-- Animation Type
--------------------------------------------------

AnimationConfig.Types = {
	Normal = "Normal",
	Double = "Double"
}

--------------------------------------------------
-- Animation Data
--------------------------------------------------

AnimationConfig.Animations = {

	Normal = {

		{
			Id = "Normal_01",
			Name = "Basic Punch",
			Icon = "rbxassetid://116115327318061",
			AnimationId = 113516268237106,
			ProductId = nil,
			Price = 0,
			HitSound = "Hit_Wall_06",
		},

		{
			Id = "Normal_02",
			Name = "Knee Strike",
			Icon = "rbxassetid://71198137054917",
			AnimationId = 127873449849891,
			ProductId = 3552580441,
			Price = 20,
			HitSound = "Hit_Wall_06",
		},
		
		{
			Id = "Normal_03",
			Name = "Hadouken",
			Icon = "rbxassetid://96436519663169",
			AnimationId = 127207982629444,
			ProductId = 3558920712,
			Price = 20,
			HitSound = "Hit_Wall_06",
		},
		
		{
			Id = "Normal_04",
			Name = "Dragon Punch",
			Icon = "rbxassetid://99509612867707",
			AnimationId = 131886109886016,
			ProductId = 3558921353,
			Price = 20,
			HitSound = "Hit_Wall_06",
		},
		
		{
			Id = "Normal_05",
			Name = "HeadAttack",
			Icon = "rbxassetid://89611955190508",
			AnimationId = 106417496484779,
			ProductId = 3558921406,
			Price = 20,
			HitSound = "Hit_Wall_06",
		},

		{
			Id = "Normal_06",
			Name = "Jump Slam",
			Icon = "rbxassetid://117852817770702",
			AnimationId = 119205549367384,
			ProductId = 3558934164,
			Price = 20,
			HitSound = "Hit_Wall_06",
		},
		
		{
			Id = "Normal_07",
			Name = "Rolling Punch",
			Icon = "rbxassetid://107093408871624",
			AnimationId = 106531316693496,
			ProductId = 3558934250,
			Price = 20,
			HitSound = "Hit_Wall_06",
		},

		{
			Id = "Normal_08",
			Name = "Superman Punch",
			Icon = "rbxassetid://112144552421003",
			AnimationId = 133611200536599,
			ProductId = 3559057377,
			Price = 20,
			HitSound = "Hit_Wall_06",
		},


		{
			Id = "Normal_09",
			Name = "Upper Kick",
			Icon = "rbxassetid://111820376672925",
			AnimationId = 138500863176103,
			ProductId = 3559057450,
			Price = 20,
			HitSound = "Hit_Wall_06",
		},
		
		{
			Id = "Normal_10",
			Name = "Body Slam",
			Icon = "rbxassetid://113709092609393",
			AnimationId = 99208319691615,
			ProductId = 3559057564,
			Price = 20,
			HitSound = "Hit_Wall_06",
		},
		
		{
			Id = "Normal_11",
			Name = "Tornado Punch",
			Icon = "rbxassetid://132302313220307",
			AnimationId = 138926708166502,
			ProductId = 3559057653,
			Price = 20,
			HitSound = "Hit_Wall_06",
		},
	},

	Double = {

		{
			Id = "Double_01",
			Name = "Basic Double Punch",
			Icon = "rbxassetid://123093801011214",
			AnimationId = 122244619332052,
			ProductId = nil,
			Price = 0,
			HitSound = "Hit_Wall_02",
		},

		{
			Id = "Double_02",
			Name = "Flying Knee Punch",
			Icon = "rbxassetid://97446628601667",
			AnimationId = 117504536477359,
			ProductId = 3552580556,
			Price = 20,
			HitSound = "Hit_Wall_02",
		},
		
		{
			Id = "Double_03",
			Name = "Tornado Spin Kick",
			Icon = "rbxassetid://130799847119922",
			AnimationId = 108781183459426,
			ProductId = 3559385677,
			Price = 20,
			HitSound = "Hit_Wall_02",
		},
		
		{
			Id = "Double_04",
			Name = "Double Kick",
			Icon = "rbxassetid://113971380875662",
			AnimationId = 84446359879639,
			ProductId = 3559385804,
			Price = 20,
			HitSound = "Hit_Wall_02",
		},
		
		{
			Id = "Double_05",
			Name = "Jump Rocket Punch",
			Icon = "rbxassetid://117543952009314",
			AnimationId = 98059161362754,
			ProductId = 3559385908,
			Price = 20,
			HitSound = "Hit_Wall_02",
		},
		
		{
			Id = "Double_06",
			Name = "Punch Kick Combo",
			Icon = "rbxassetid://92926186141304",
			AnimationId = 79432332275714,
			ProductId = 3559386091,
			Price = 20,
			HitSound = "Hit_Wall_02",
		},
		
		{
			Id = "Double_07",
			Name = "Physical Beauty",
			Icon = "rbxassetid://105922198796508",
			AnimationId = 73717389348427,
			ProductId = 3559386578,
			Price = 20,
			HitSound = "Hit_Wall_02",
		},
		
		{
			Id = "Double_08",
			Name = "Grumbling",
			Icon = "rbxassetid://105560728461069",
			AnimationId = 138098535190038,
			ProductId = 3559386747,
			Price = 20,
			HitSound = "Hit_Wall_02",
		},
		
		{
			Id = "Double_09",
			Name = "Tri Beam",
			Icon = "rbxassetid://107976904541113",
			AnimationId = 73352863074310,
			ProductId = 3559387263,
			Price = 20,
			HitSound = "Hit_Wall_02",
		},

	}

}

--------------------------------------------------
-- 빠른 조회용 캐시
--------------------------------------------------

AnimationConfig.ById = {}

for typeName, list in pairs(AnimationConfig.Animations) do

	for _, anim in ipairs(list) do

		AnimationConfig.ById[anim.Id] = anim
		anim.Type = typeName

	end

end

--------------------------------------------------
-- 함수
--------------------------------------------------

function AnimationConfig.GetAnimations(animType)

	return AnimationConfig.Animations[animType]

end

function AnimationConfig.GetAnimation(animId)

	return AnimationConfig.ById[animId]

end

function AnimationConfig.GetAnimationId(animId)

	local data = AnimationConfig.ById[animId]
	if data then
		return data.AnimationId
	end

	return nil
end

return AnimationConfig