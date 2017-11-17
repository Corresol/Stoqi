class RequestListConverter : ResponseConverter<RequestList> {

    override func convert(_ dictionary: [String : AnyObject]) -> RequestList? {
        guard let id = (dictionary["id"] as? String).flatMap({Int($0)}),
        let total = dictionary["price"] as? Float,
        let isDelivered = dictionary["isDelivered"] as? Bool
        else {
            return nil
        }
        let items = dictionary["totalItems"] as? Int ?? 0
		let serverStatus = dictionary["status"] as? Int ?? -1
        var status : RequestStatus? = nil
		
		let latest = (dictionary["nextReplacementOn"] as? String).flatMap({Date.fromString($0, withFormat: "yyyy-MM-dd HH:mm:ss")})
		let requested = (dictionary["requestedOn"] as? String).flatMap({Date.fromString($0, withFormat: "yyyy-MM-dd HH:mm:ss")})
		let autorized = (dictionary["authorizedOn"] as? String).flatMap({Date.fromString($0, withFormat: "yyyy-MM-dd HH:mm:ss")})
		let purchased = (dictionary["purchasedOn"] as? String).flatMap({Date.fromString($0, withFormat: "yyyy-MM-dd HH:mm:ss")})
		
        if isDelivered
		{
			//Delivered
            guard let delivered = (dictionary["deliveredOn"] as? String).flatMap({Date.fromString($0, withFormat: "yyyy-MM-dd HH:mm:ss")}) else {
                return nil
            }
            status = .delivered(date: delivered)
        }
		else
		{
			if serverStatus == 1 && autorized != nil
			{
				//Authotized
				if requested != nil
				{
					if latest != nil
					{
						status = .autorized(from: requested!, to: latest!, autOn: autorized!)
					}
					else
					{
						let latest = requested! + TSDateComponents.months(1)
						status = .autorized(from: requested!, to: latest!, autOn: autorized!)
					}
					
				}
			}
			else if serverStatus == 2 && purchased != nil
			{
				//Purchased
				if requested != nil
				{
					if latest != nil
					{
						status = .purchased(from: requested!, to: latest!, purchOn: purchased!)
					}
					else
					{
						let latest = requested! + TSDateComponents.months(1)
						status = .purchased(from: requested!, to: latest!, purchOn: purchased!)
					}
				}
			}
			else if serverStatus == 3 && purchased != nil
			{
				//In delivering
				status = .inDelivering(from: purchased!)
			}

			
			if status == nil
			{
				//Not Authorized
				if requested != nil
				{
					if latest != nil
					{
						status = .notAutorized(from: requested!, to: latest!)
					}
					else
					{
						let latest = requested! + TSDateComponents.months(1)
						status = .notAutorized(from: requested!, to: latest!)
					}
				}
				else
				{
					// Nil status
					let requested = Date()
					let latest = requested + TSDateComponents.months(1)
					status = .notAutorized(from: requested, to: latest!)
				}
			}
        }
        
        return RequestList(id: id, products: nil, status: status!, total: total, count: items)
    }
}

class RequestedProductConverter : ResponseConverter<ProductEntry> {
    
    fileprivate let productConverter : ResponseConverter<Product>
    
    init(productConverter : ResponseConverter<Product>) {
        self.productConverter = productConverter
    }
    
    override func convert(_ dictionary: [String : AnyObject]) -> ProductEntry? {
        guard let product = self.productConverter.convert(dictionary),
		let units = (dictionary["quantity"] as? String).flatMap({Int($0)})
			else {
                return nil
        }
		
		let suggested: ProductEntry? = (dictionary["suggested"] as? [String : AnyObject]).flatMap({self.convert($0)})
		
        return ProductEntry(product: product, units: units, suggestedProduct: suggested)
    }
}
