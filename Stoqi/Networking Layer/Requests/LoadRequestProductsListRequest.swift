struct LoadRequestProductsListRequest : Request {
    let method = RequestMethod.get
    let url = "user/loadRequest"
    let parameters: [String : AnyObject]?
    
    init?(requestList : RequestList) {
        guard let id = requestList.id else {
            return nil
        }
        
        self.parameters = ["requestId" : id as AnyObject]
    }
}
