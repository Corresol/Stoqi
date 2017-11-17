struct PasswordRecoveryRequest : Request {
	let method = RequestMethod.get
	var url = "user/passwordrecovery"
	let parameters: [String : AnyObject]? = nil
	
	init(email : String) {
		self.url = "\(url)/\(email)"
	}
}
