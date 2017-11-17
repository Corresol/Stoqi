struct ModelHomeViewModel : HomeViewModel {
    var minDeliveryDate: Date
    var maxDeliveryDate: Date
    var userName: String
    var totalSaved: Float
    var monthlySavings: Float
	var canRefill : Bool
    
	init?(profile : Profile, requests: [RequestList], analytic: Analytic) {
        self.userName = profile.name ?? profile.email ?? "Guest"
		self.totalSaved = Float(analytic.money_saved != nil ? analytic.money_saved! : "0.0")!
        self.monthlySavings = Float(analytic.monthly_average != nil ? analytic.monthly_average! : "0.0")!
		
		let newRequest = requests.filter {
			if case .notAutorized = $0.status{ return true }
			return false
		}.first
		
		let pendingRequest = requests.filter {
			if case .autorized = $0.status{ return true }
			return false
			}.first
		
		let request = newRequest == nil ? pendingRequest! : newRequest!
		
		do {
			self.minDeliveryDate = try {
				if case .notAutorized(let from, _) = request.status{
					return from
				} else if case .autorized(let from, _, _) = request.status{
					return from
				}
				throw Error1.minDate
				}()
			
			self.maxDeliveryDate = try {
				if case .notAutorized(_, let to) = request.status{
					return to
				} else if case .autorized(_, let to, _) = request.status{
					return to
				}
				throw Error1.maxDate
			}()
		}
		catch
		{
			return nil
		}
		
		self.canRefill = false
		self.canRefill = {
			return abs(self.maxDeliveryDate.timeIntervalSince1970 - Date().timeIntervalSince1970) <= 60*60*24*7*2
		}()
    }
}

private enum Error1: Error {
	case minDate
	case maxDate
}
