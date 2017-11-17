struct ModelRequestListViewModel : RequestListViewModel {
    var requestList : RequestList?
	var categories : [ProductsCategoryViewModel] {
		didSet{
			requestList?.products = self.categories.flatMap({$0.products})
		}
	}
		
    init(requestList : RequestList) {
        self.categories = []
        self.requestList = requestList
        let manager = try! Injector.inject(ProductsManager.self)
        guard let categories = manager.categories else {
            return
        }
        self.categories = categories.flatMap { category in
            try! Injector.inject(ProductsCategoryViewModel.self,
                with: ProductsCategoryInjectionParameter(category: category,
                    products: requestList.products?.filter{$0.product.category == category}.sorted { $0.0.product.kind.name.compare($0.1.product.kind.name) == .orderedAscending } ?? []))}
    }
}
