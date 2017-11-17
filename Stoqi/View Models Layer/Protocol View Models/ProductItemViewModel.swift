/// Used within RequestList
protocol ProductItemViewModel : ProductItemCellDataSource {
    var product : ProductEntry {get}
}

protocol ProductsCategoryViewModel : ProductsCategoryHeaderViewDataSource {
    
    var category : Category {get}
    
    var categoryName : String {get}
    var items : [ProductItemViewModel] {get set}
}

extension ProductsCategoryViewModel {
    var title : String {
        return self.categoryName
    }
    
    var count : Int {
        return self.items.count
    }
    
    var products : [ProductEntry] {
        return self.items.map {$0.product}
    }
}