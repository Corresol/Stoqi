struct RegisterRequest : Request {
    let method = RequestMethod.post
    let url = "register"
    let encoding = RequestEncoding.url
    let parameters: [String : AnyObject]?
    
    init(credentials : Credentials) {
        self.parameters = ["email" : credentials.email as AnyObject,
                           "password" : credentials.password as AnyObject]
    }
}
