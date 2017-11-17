import GCDKit

class DummyAnalyticManager: AnalyticManager
{

    func performLoadAnalytic(_ callback: @escaping (OperationResult<Analytic>) -> Void) {
        GCDQueue.main.after(1) {
            self.analytic = self.dummy
            callback(.success(self.analytic!))
        }
    }

	var analytic: Analytic?
	
}

extension DummyAnalyticManager {
	fileprivate var dummy : Analytic {
		return Analytic(money_saved: (10...1000).random.description,
		                monthly_average : (1...100).random.description,
		                spending_Money: (10...1000).random.description,
		                spending_Persent: (1...100).random.description,
		                consumption: (1...100).random.description,
		                favorite_Villain: "kind1",
		                favorite_Villain_Value: (1...100).random.description,
		                favorite_Hero: "kind2",
		                favorite_Hero_Value: (1...100).random.description,
		                clothing_Weight: (1...100).random.description,
		                cleaning_Weight: (1...100).random.description,
		                other_Weight: (1...100).random.description)
	}
}
