struct LoginRequest : Request {
    let method = RequestMethod.get
    let url = "login"
    let parameters: [String : AnyObject]?
    
    init(credentials : Credentials) {
        self.parameters = ["email" : credentials.email as AnyObject,
                          "password" : credentials.password as AnyObject]
    }
}
