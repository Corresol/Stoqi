struct SaveStockRequest : Request {
    let method = RequestMethod.post
    let url : String = "user/updatestock"
    let parameters: [String : AnyObject]?
    
    init?(account : Account, stock : Stock) {
        guard let id = account.id else {
            return nil
        }
        let products = stock.products.flatMap { product in
            product.id.flatMap {
                ["id" : $0,
                "quantityLeft" : product.left,
				"confirmed" : product.confirmed]
            }
        }
        
        parameters = ["accountId" : id as AnyObject,
                      "items" : products as AnyObject]
        
    }
}
