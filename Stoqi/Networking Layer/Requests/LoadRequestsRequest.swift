struct LoadRequestsRequest : Request {
    let method = RequestMethod.get
    let url = "user/requests"
    let parameters: [String : AnyObject]?
    
    init?(account : Account) {
        guard let accountId = account.id else {
            return nil
        }
        
        self.parameters = ["accountId" : accountId as AnyObject]
    }
}
