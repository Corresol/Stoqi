class StockConverter : ResponseConverter<Stock> {
    
    fileprivate let converter : ResponseConverter<StockProduct>
    
    init(stockProductConverter : ResponseConverter<StockProduct>) {
        self.converter = stockProductConverter
    }
    
    override func convert(_ dictionary: [String : AnyObject]) -> Stock? {
        guard let categories = dictionary["categories"] as? [[String : AnyObject]] else {
            return nil
        }

		let converter = try! Injector.inject(ResponseConverter<Category>.self)
		let productConverter = try! Injector.inject(ResponseConverter<StockProduct>.self)
		let products : [StockProduct] = categories.reduce([]) {
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
		
        return Stock(products: products)
    }
}

class StockProductConverter : ResponseConverter<StockProduct> {
    
    let productConverter : ResponseConverter<Product>
    
    init(productConverter : ResponseConverter<Product>) {
        self.productConverter = productConverter
    }
    
    override func convert(_ dictionary: [String : AnyObject]) -> StockProduct? {
        guard let product = self.productConverter.convert(dictionary),
            let units = (dictionary["quantityLeft"] as? Float).flatMap({Float($0)}),
            let total = (dictionary["quantity"] as? String).flatMap({Float($0)}),
			let confirmed = (dictionary["confirmed"] as? Bool).flatMap({Bool($0)})
			else {
                return nil
        }
        return StockProduct(product: product, left: units, total: total, confirmed: confirmed)
    }
}
