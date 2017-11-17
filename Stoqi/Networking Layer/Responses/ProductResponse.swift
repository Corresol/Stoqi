struct ProductResponse : Response {
    let request : Request
    let value : Product
    
    init?(request : Request, body : AnyObject) {
        self.request = request
        guard let response = (body as? [String : AnyObject])?["response"] as? [String : AnyObject] else {
            return nil
        }
        
        let productConverter = try! Injector.inject(ResponseConverter<Product>.self)
        guard let product = productConverter.convert(response) else {
            return nil
        }
        
        value = product
    }
}