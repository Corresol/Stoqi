struct SaveRequestListRequest : Request {
    let method = RequestMethod.post
    let url = "user/saverequest"
    let parameters: [String : AnyObject]?
    
    init?(account : Account, requestList : RequestList) {
        guard let accountId = account.id, let reqID = requestList.id  else {
            return nil
        }
		
		var status = 0
		
		switch requestList.status {
		case .notAutorized:
			status = 0
		case .autorized:
			status = 1
		case .purchased:
			status = 2
		case .inDelivering:
			status = 3
		case .delivered:
			status = 4
		}
		
		
        let items : [[String : AnyObject]] = requestList.products?.flatMap { product in
            product.id.flatMap {
                ["id" : $0,
					"price" : product.product.price,
                "quantity" : product.units]
            }
		} as! [[String : AnyObject]] ?? []
		
		
		self.parameters = ["accountId" : accountId as AnyObject,
		                   "items" : items as AnyObject,
		                   "requestId" : reqID as AnyObject,
							"status": status as AnyObject]
    }
}
