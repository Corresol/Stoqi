struct PropertyLocationResponse : Response {
    let request: Request
    let value: [PropertyLocation]
    
    
    init?(request: Request, body: AnyObject) {
        self.request = request
        guard let response = (body as? [String : AnyObject])?["response"] as? [[String : AnyObject]] else {
            return nil
        }
        let converter = try! Injector.inject(ResponseConverter<PropertyLocation>.self)
        self.value = response.flatMap {converter.convert($0)}
    }
}