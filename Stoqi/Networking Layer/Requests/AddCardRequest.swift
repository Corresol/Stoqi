struct AddCardRequest : Request
{
	let method = RequestMethod.post
	let url = "user/addcard"
	let parameters: [String : AnyObject]?
	
	init?(account : Account, card: Card) {
		guard let accountId = account.id else {
			return nil
		}
		
		var params : [String : AnyObject] = [:]
		params["accountId"] = accountId as AnyObject
		
		var cardParams : [String : AnyObject] = [:]
		cardParams["name"] = card.owner as AnyObject
		cardParams["cardNumber"] = card.number as AnyObject
		cardParams["expiryMonth"] = card.month as AnyObject
		cardParams["expiryYear"] = card.year as AnyObject
		cardParams["security"] = card.code as AnyObject
        let array : [[String : AnyObject]] = [cardParams]
		params["cards"] = array as AnyObject
        // Previously params["cards"] = [cardParams]
		
		self.parameters = params
	}
}
