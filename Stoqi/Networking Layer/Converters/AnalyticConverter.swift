class AnalyticConverter: ResponseConverter<Analytic>
{
	override func convert(_ dictionary: [String : AnyObject]) -> Analytic? {
		
		let money_saved = (dictionary["money_saved"] as? Float).flatMap{String($0)}
		let monthly_average = (dictionary["monthly_average"] as? Float).flatMap{String($0)}
		let spending_Money = (dictionary["spending_Money"] as? Float).flatMap{String($0)}
		let spending_Persent = (dictionary["spending_Persent"] as? Int).flatMap{String($0)}
		let consumption = (dictionary["consumption"] as? Int).flatMap{String($0)}
		let favorite_Villain = (dictionary["favorite_Villain"] as? String).flatMap{String($0)}
		let favorite_Villain_Value = (dictionary["favorite_Villain_Value"] as? Int).flatMap{String($0)}
		let favorite_Hero = (dictionary["favorite_Hero"] as? String).flatMap{String($0)}
		let favorite_Hero_Value = (dictionary["favorite_Hero_Value"] as? Int).flatMap{String($0)}
		let clothing_Weight = (dictionary["clothing_Weight"] as? Int).flatMap{String($0)}
		let cleaning_Weight = (dictionary["cleaning_Weight"] as? Int).flatMap{String($0)}
		let other_Weight = (dictionary["other_Weight"] as? Int).flatMap{String($0)}
		
		
		return Analytic(money_saved: money_saved,
		                monthly_average : monthly_average,
		                spending_Money: spending_Money,
		                spending_Persent: spending_Persent,
		                consumption: consumption,
		                favorite_Villain: favorite_Villain,
		                favorite_Villain_Value: favorite_Villain_Value,
		                favorite_Hero: favorite_Hero,
		                favorite_Hero_Value: favorite_Hero_Value,
		                clothing_Weight: clothing_Weight,
		                cleaning_Weight: cleaning_Weight,
		                other_Weight: other_Weight)
	}
}
