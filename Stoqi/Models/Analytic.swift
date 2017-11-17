struct Analytic
{
	let money_saved : String?
	let monthly_average : String?
	
	let spending_Money: String?
	let spending_Persent: String?
	let consumption: String?
	
	let favorite_Villain: String?
	let favorite_Villain_Value: String?
	let favorite_Hero: String?
	let favorite_Hero_Value: String?
	
	let clothing_Weight: String?
	let cleaning_Weight: String?
	let other_Weight: String?
	
	init(){
		self.money_saved = nil
		self.monthly_average = nil
		self.spending_Money = nil
		self.spending_Persent = nil
		self.consumption = nil
		self.favorite_Villain = nil
		self.favorite_Villain_Value = nil
		self.favorite_Hero = nil
		self.favorite_Hero_Value = nil
		self.clothing_Weight = nil
		self.cleaning_Weight = nil
		self.other_Weight = nil
	}
	
	init(money_saved: String?,
	     monthly_average : String?,
		 spending_Money: String?,
		 spending_Persent: String?,
		 consumption: String?,
		 favorite_Villain: String?,
		 favorite_Villain_Value: String?,
		 favorite_Hero: String?,
		 favorite_Hero_Value: String?,
		 clothing_Weight: String?,
		 cleaning_Weight: String?,
		 other_Weight: String?)
	{
		self.money_saved = money_saved
		self.monthly_average = monthly_average
		self.spending_Money = spending_Money
		self.spending_Persent = spending_Persent
		self.consumption = consumption
		self.favorite_Villain = favorite_Villain
		self.favorite_Villain_Value = favorite_Villain_Value
		self.favorite_Hero = favorite_Hero
		self.favorite_Hero_Value = favorite_Hero_Value
		self.clothing_Weight = clothing_Weight
		self.cleaning_Weight = cleaning_Weight
		self.other_Weight = other_Weight
	}
}
