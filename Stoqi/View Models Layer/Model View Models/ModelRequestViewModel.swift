struct ModelRequestViewModel : RequestViewModel {
    let request: RequestList
	
    var date: Date {
        if case .delivered(let date) = self.request.status {
            return date
        } else {
            return Date()
        }
    }
    var startDate: Date? {
        if case .notAutorized(let from, _) = self.request.status {
            return from
		} else if case .autorized(let from, _, _) = self.request.status {
			return from
		} else {
            return Date()
        }
    }

    var endDate: Date? {
        if case .notAutorized(_, let to) = self.request.status {
            return to
		} else if case .autorized(_, let to, _) = self.request.status {
			return to
		} else {
            return Date()
        }
    }
    
    var hasNextNode: Bool
    
    var price: Float {
        return self.request.total
    }
	
    var items: Int {
        return self.request.count
    }
	
	var autorized : Bool {
		if case .autorized = self.request.status {
			return true
		} else {
			return false
		}
	}
    
    init(request : RequestList, hasNextNode : Bool = true) {
        self.request = request
        self.hasNextNode = hasNextNode
    }
}
