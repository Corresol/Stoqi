class ProductConverter : ResponseConverter<Product> {
    
    let kindConverter : ResponseConverter<Kind>
    let brandConverter : ResponseConverter<Brand>
    let volumeConverter : ResponseConverter<Volume>
    
    init(kindConverter : ResponseConverter<Kind>,
         brandConverter : ResponseConverter<Brand>,
         volumeConverter : ResponseConverter<Volume>) {
        self.kindConverter = kindConverter
        self.brandConverter = brandConverter
        self.volumeConverter = volumeConverter
    }
    
    override func convert(_ dictionary: [String : AnyObject]) -> Product?
	{
        guard let id = (dictionary["id"] as? String).flatMap({Int($0)}),
            let kind = (dictionary["kind"] as? [String : AnyObject]).flatMap({self.kindConverter.convert($0)}),
            let brand = (dictionary["brand"] as? [String : AnyObject]).flatMap({self.brandConverter.convert($0)}),
        let volume = (dictionary["volume"] as? [String : AnyObject]).flatMap({self.volumeConverter.convert($0)}),
        let price = (dictionary["price"] as? String).flatMap({Float($0)})
		else {
            return nil
        }
        return Product(id: id, category: nil, kind: kind, brand: brand, volume: volume, price: price)
    }
}
