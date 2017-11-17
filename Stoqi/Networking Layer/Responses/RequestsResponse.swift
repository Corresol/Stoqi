struct RequestsResponse : Response {
    let request: Request
    let value: [RequestList]
    
    init?(request: Request, body: AnyObject) {
        self.request = request
        
        guard let response = (body as? [String : AnyObject])?["response"] as? [[String : AnyObject]] else {
            return nil
        }
        let converter = try! Injector.inject(ResponseConverter<RequestList>.self)
        self.value = response.flatMap {converter.convert($0)}
    }
}