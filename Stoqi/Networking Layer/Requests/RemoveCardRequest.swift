struct RemoveCardRequest : Request
{
	let method = RequestMethod.delete
	var url = "user/removecard"
	let parameters: [String : AnyObject]?
	
	init?(account : Account, card: Card) {
		guard let accountId = account.id, let cardID = card.id else {
			return nil
		}
		
		self.url = "\(self.url)/\(accountId)/\(cardID)"
		
		self.parameters = nil
	}
}
