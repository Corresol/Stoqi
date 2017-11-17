struct ModelAnalyticVewModel: AnalyticViewModel {
	let analytic: Analytic?
	
	let money_saved : String
	let monthly_average : String
	
	let spending_Money: String
	let spending_Persent: String
	let consumption: String
	
	let favorite_Villain: String
	let favorite_Villain_Value: String
	let favorite_Hero: String
	let favorite_Hero_Value: String
	
	let clothing_Weight: String
	let cleaning_Weight: String
	let other_Weight: String
	
	init(analytic: Analytic) {
		
		self.analytic = analytic
		
		if let value = analytic.money_saved {
			self.money_saved = "R$ " + value
		} else {
			self.money_saved = "R$ 0"
		}
		
		if let value = analytic.monthly_average {
			self.monthly_average = "R$ " + value
		} else {
			self.monthly_average = "R$ 0"
		}
		
		if let value = analytic.spending_Money {
			self.spending_Money = "R$ " + value
		} else {
			self.spending_Money = "R$ 0"
		}
		
		if let value = analytic.spending_Persent {
			self.spending_Persent = value + "%"
		} else {
			self.spending_Persent = "0%"
		}
		
		if let value = analytic.consumption {
			self.consumption = "+" + value + "%"
		} else {
			self.consumption = "+0%"
		}
		
		if let value = analytic.favorite_Villain {
			self.favorite_Villain = "His villain is the ".localized + value
		} else {
			self.favorite_Villain = "His villain is the ".localized + "????"
		}
		
		if let value = analytic.favorite_Villain_Value {
			self.favorite_Villain_Value = "+" + value + "%"
		} else {
			self.favorite_Villain_Value = "+0%"
		}
		
		if let value = analytic.favorite_Hero {
			self.favorite_Hero = "Your hero is the ".localized + value
		} else {
			self.favorite_Hero = "Your hero is the ".localized + "????"
		}
		
		if let value = analytic.favorite_Hero_Value {
			self.favorite_Hero_Value = "+" + value + "%"
		} else {
			self.favorite_Hero_Value = "+0%"
		}

		if let value = analytic.clothing_Weight {
			self.clothing_Weight = value + "%"
		} else {
			self.clothing_Weight = "0%"
		}
		
		if let value = analytic.cleaning_Weight {
			self.cleaning_Weight = value + "%"
		} else {
			self.cleaning_Weight = "0%"
		}
		
		if let value = analytic.other_Weight {
			self.other_Weight = value + "%"
		} else {
			self.other_Weight = "0%"
		}
		
	}
}
