struct ProcessRequestListRequest : Request {
    let method = RequestMethod.post
    let url = "user/processRequest"
    let encoding = RequestEncoding.url
    let parameters: [String : AnyObject]?
    
    init?(requestList : RequestList) {
        guard let id = requestList.id else {
            return nil
        }
        self.parameters = ["requestId" : id as AnyObject]
    }
}
