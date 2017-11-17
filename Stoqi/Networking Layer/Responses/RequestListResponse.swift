struct RequestListResponse : Response {
    let request: Request
    let value: RequestList
    
    init?(request: Request, body: AnyObject) {
        self.request = request
        
        guard let response = (body as? [String : AnyObject])?["response"] as? [String : AnyObject] else {
            return nil
        }
        let converter = try! Injector.inject(ResponseConverter<RequestList>.self)
        guard let value = converter.convert(response) else {
            return nil
        }
        self.value = value
    }
}