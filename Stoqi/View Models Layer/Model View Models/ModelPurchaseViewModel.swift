struct ModelPurchaseViewModel : PurchaseViewModel {
    let total : Float
    let saved : Float
	let moreThen7days : Bool
    
    init(request : RequestList) {
        self.total = request.total
        self.saved = 0.1 * self.total
		self.moreThen7days  = {
			if case .autorized(let from, let to, _) = request.status
			{
				if abs(Int32(from.timeIntervalSinceReferenceDate - to.timeIntervalSinceReferenceDate)) < 604800 // 7 days
				{
					return false
				}
			} else if case .notAutorized (let since, let purchOn) = request.status
			{
				if abs(Int32(since.timeIntervalSinceReferenceDate - purchOn.timeIntervalSinceReferenceDate)) < 604800 // 7 days
				{
					return false
				}
			}
			return true
		}()
        // TODO: Fix Savings value. it is 10% currently
    }
}
