struct ModelStockProductViewModel : StockProductViewModel {
    var product: StockProduct
    
    var item : String {
        return product.product.kind.name
    }
    
    var total : Float {
        return product.total
    }
    
    var left : Float {
        get {
            return product.left
        }
        set {
            product.left = newValue
        }
    }
    
    var brand : String {
        return product.product.brand.name
    }
    
    var details : String {
        let volume = product.product.volume
        return "\(volume.name.capitalized) \(volume.volume) \(volume.unit)"
    }
	
	var confirmed: Bool {
		get {
			return product.confirmed
		}
		set {
			product.confirmed = newValue
		}
	}
}

struct ModelStockProductsCategoryViewModel : StockProductsCategoryViewModel {
    
    let category : Category
    
    var categoryName : String {
        return self.category.name
    }
    
    var collapsed: Bool = true
    
    var items : [StockProductViewModel]
    
    init(category : Category, products : [StockProduct]) {
        self.category = category
        self.items = products.map {ModelStockProductViewModel(product: $0)}
    }
}
