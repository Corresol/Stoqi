struct LogoutRequest : Request {
	let method = RequestMethod.get
	var url = ""
	let parameters: [String : AnyObject]?
	
	init?(account : Account) {
		guard let id = account.id else {
			return nil
		}
		
		self.url = "logout?userId=\(id.description)"
		
		parameters = nil
	}
}
