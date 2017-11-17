struct ModelStockViewModel : StockViewModel {
    var stock : Stock? {
        return Stock(products: categories.flatMap{$0.products})
    }
    
    var categories : [StockProductsCategoryViewModel]
    var date : Date
    
    init(stock : Stock) {
        self.categories = []
        self.date = Date()
        let manager = try! Injector.inject(ProductsManager.self)
        guard let categories = manager.categories else {
            return
        }

        self.categories = categories.flatMap { category in
            try! Injector.inject(StockProductsCategoryViewModel.self,
                with: StockProductsCategoryInjectionParameter(category: category,
                    products: stock.products.filter{$0.product.category == category}.sorted { $0.0.product.kind.name.compare($0.1.product.kind.name) == .orderedAscending }))}
    }
}
