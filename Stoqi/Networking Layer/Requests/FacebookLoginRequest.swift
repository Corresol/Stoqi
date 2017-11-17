struct FacebookLoginRequest : Request {
    let method = RequestMethod.get
    let url : String
    let parameters: [String : AnyObject]? = nil
    
    init(token : String) {
        self.url = "login/social/\(token)"
    }
}
