struct StockResponse : Response {
    let request : Request
    let value: Stock
    
    init?(request: Request, body: AnyObject) {
        self.request = request
    
        guard let response = (body as? [String : AnyObject])?["response"] as? [String : AnyObject] else {
            return nil
        }
        let converter = try! Injector.inject(ResponseConverter<Stock>.self)
        guard let value = converter.convert(response) else {
            return nil
        }
        self.value = value
    }
}