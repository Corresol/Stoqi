struct RequestedProductsResponse : Response {
    let request: Request
    let value: [ProductEntry]
    
    init?(request: Request, body: AnyObject) {
        self.request = request
        
        guard let response = (body as? [String : AnyObject])?["response"] as? [String : AnyObject],
            let categories = response["categories"] as? [[String : AnyObject]] else {
                return nil
        }
        let converter = try! Injector.inject(ResponseConverter<Category>.self)
        let productConverter = try! Injector.inject(ResponseConverter<ProductEntry>.self)
        self.value = categories.reduce([]) {
            let category = converter.convert($0.1)
            guard let products = $0.1["products"] as? [[String : AnyObject]] else {
                return $0.0
            }
            return $0.0 + products.flatMap{
                var product = productConverter.convert($0)
                product?.product.category = category
                return product
            }
        }
    }
}
