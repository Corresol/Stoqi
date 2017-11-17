struct LoadStockRequest : Request {
    let method = RequestMethod.get
    let url = "user/loadstock"
    let parameters: [String : AnyObject]?
    
    init?(account : Account) {
        guard let id = account.id else {
            return nil
        }
        parameters = ["accountId" : id as AnyObject]
    }
}
