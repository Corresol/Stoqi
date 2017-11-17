struct CategoriesResponse : Response {
    let request: Request
    let value: [Category : [Product]]
    
    init?(request: Request, body: AnyObject) {
        self.request = request
        guard let response = (body as? [String : AnyObject])?["response"] as? [String : AnyObject],
        let categories = response["categories"] as? [[String : AnyObject]] else {
            return nil
        }
        let converter = try! Injector.inject(ResponseConverter<Category>.self)
        let productConverter = try! Injector.inject(ResponseConverter<Product>.self)
        self.value = categories.reduce([:]) {
            
            guard let category = converter.convert($0.1),
                let products = $0.1["products"] as? [[String : AnyObject]] else {
                return $0.0
            }
            var dic = $0.0
            dic[category] = products.flatMap{
               var product = productConverter.convert($0)
                product?.category = category
                return product
            }
            return dic
        }
    }
}
