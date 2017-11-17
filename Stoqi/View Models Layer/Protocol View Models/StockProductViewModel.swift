protocol StockProductViewModel : StockProductItemCellDataSource {
    var product : StockProduct {get}
    var left : Float {get set}
}

protocol StockProductsCategoryViewModel : ProductsCategoryHeaderViewDataSource {
    
    var category : Category {get}
    
    var categoryName : String {get}
    var items : [StockProductViewModel] {get set}
}

extension StockProductsCategoryViewModel {
    var title : String {
        return self.categoryName
    }
    
    var count : Int {
        return self.items.count
    }
    
    var products : [StockProduct] {
        return self.items.map {$0.product}
    }
}