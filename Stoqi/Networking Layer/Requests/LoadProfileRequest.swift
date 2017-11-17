struct LoadProfileRequest : Request {
    let method = RequestMethod.get
    let url = "user/profile"
    let parameters: [String : AnyObject]?
    
    init?(account : Account) {
        guard let accountId = account.id else {
            return nil
        }
        
        self.parameters = ["accountId" : accountId as AnyObject]
    }
}
