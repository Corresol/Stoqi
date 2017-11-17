struct ModelProductItemViewModel : ProductItemViewModel {
    let product: ProductEntry

    var item : String {
        return self.product.product.kind.name
    }
    
    var quantity : Int {
        return self.product.units
    }
    
    var brand : String {
        return self.product.product.brand.name
    }
    
    var details : String {
        let volume = self.product.product.volume
        return "\(volume.name.capitalized) \(volume.volume) \(volume.unit)"
    }
	
	var suggested : Bool {
		return self.product.suggestedProduct != nil
	}
}

struct ModelProductsCategoryViewModel : ProductsCategoryViewModel {
    
    let category : Category
    
    var categoryName : String {
        return self.category.name
    }
    
    var collapsed: Bool = true
    
	var items : [ProductItemViewModel]
		
    init(category : Category, products : [ProductEntry]) {
        self.category = category
        self.items = products.map {ModelProductItemViewModel(product: $0)}
    }
}
