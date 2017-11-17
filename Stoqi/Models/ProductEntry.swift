struct ProductEntry : Identifiable {
    var id : Int? {
        return self.product.id
    }
    var product : Product
    var units : Int
	fileprivate let prSuggestedProduct: Product?
	fileprivate let suggestedUnits: Int?
	
	var suggestedProduct : ProductEntry? {
		guard let prProduct = prSuggestedProduct, let prUnits = suggestedUnits else {
			return nil
		}
		return ProductEntry(product: prProduct, units: prUnits)
	}
	
	init (product: Product, units: Int, suggestedProduct: ProductEntry? = nil)
	{
		self.product = product
		self.units = units
		self.prSuggestedProduct = suggestedProduct?.product
		self.suggestedUnits = suggestedProduct?.units
	}
}

func === (first : ProductEntry, second : ProductEntry) -> Bool {
    return  first.product === second.product &&
			first.units == second.units
}

func !== (first : ProductEntry, second : ProductEntry) -> Bool {
    return !(first === second)
}

