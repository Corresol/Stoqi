struct CardsResponse: Response {
	let request: Request
	var value: [Card]
	
	init?(request: Request, body: AnyObject) {
		self.request = request
		
		guard let response = (body as? [String : AnyObject])?["response"] as? [[String : AnyObject]] else {
			return nil
		}
		
		let converter = try! Injector.inject(ResponseConverter<Card>.self)
		self.value = response.flatMap{converter.convert($0)}
	}
}