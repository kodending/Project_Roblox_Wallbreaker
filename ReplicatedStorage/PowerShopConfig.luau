local PowerShopConfig = {}

PowerShopConfig.Items = {

	{
		Id = "Damage_50",
		Type = "Fixed",
		Icon = "rbxassetid://97251106194624",
		Description = "공격력 + 50",
		GoldPrice = 700,
		RobuxPrice = 5,
		ProductId = 3548503656, -- ? Developer Product ID
		Value = 50
	},
	
	{
		Id = "Damage_500",
		Type = "Fixed",
		Icon = "rbxassetid://97251106194624",
		Description = "공격력 + 500",
		GoldPrice = 6850,
		RobuxPrice = 15,
		ProductId = 3560363550, -- ? Developer Product ID
		Value = 500
	},
	
	{
		Id = "Damage_5000",
		Type = "Fixed",
		Icon = "rbxassetid://97251106194624",
		Description = "공격력 + 5000",
		GoldPrice = 68500,
		RobuxPrice = 35,
		ProductId = 3560363713, -- ? Developer Product ID
		Value = 5000
	},
	
	{
		Id = "Damage_50000",
		Type = "Fixed",
		Icon = "rbxassetid://97251106194624",
		Description = "공격력 + 50000",
		GoldPrice = 685000,
		RobuxPrice = 75,
		ProductId = 3560363912, -- ? Developer Product ID
		Value = 50000
	},

	{
		Id = "Damage_Random_Small",
		Type = "Random",
		Icon = "rbxassetid://105895831256899",
		Description = "공격력 + (20 ~ 80)",
		GoldPrice = 600,
		RobuxPrice = 7,
		ProductId = 3548504164, -- ? Developer Product ID
		Min = 20,
		Max = 80
	},
	
	{
		Id = "Damage_Random_Medium",
		Type = "Random",
		Icon = "rbxassetid://105895831256899",
		Description = "공격력 + (200 ~ 1200)",
		GoldPrice = 7500,
		RobuxPrice = 18,
		ProductId = 3560364098, -- ? Developer Product ID
		Min = 200,
		Max = 1200
	},

	{
		Id = "Damage_Random_Large",
		Type = "Random",
		Icon = "rbxassetid://105895831256899",
		Description = "공격력 + (3000 ~ 15000)",
		GoldPrice = 75000,
		RobuxPrice = 40,
		ProductId = 3560364204, -- ? Developer Product ID
		Min = 3000,
		Max = 15000
	},
	
	{
		Id = "Damage_Random_Jackpot",
		Type = "Random",
		Icon = "rbxassetid://105895831256899",
		Description = "공격력 + (0 ~ 50000)",
		GoldPrice = 50000,
		RobuxPrice = 30,
		ProductId = 3560364323, -- ? Developer Product ID
		Min = 0,
		Max = 50000
	},
}

return PowerShopConfig