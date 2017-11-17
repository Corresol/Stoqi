struct SelectCardRequest : Request
{
	let method = RequestMethod.post
	var url = "user"
	let parameters: [String : AnyObject]?
	
	init?(account : Account, card: Card) {
		guard let accountId = account.id, let cardID = card.id else {
			return nil
		}
		
		self.url = "\(self.url)/\(accountId)/selectcard/\(cardID)"
		
		self.parameters = nil
	}
}
