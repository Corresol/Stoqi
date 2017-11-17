class ServiceProductsManager : ServiceManager, ProductsManager {
    var products: [Product]?
    var categories: [Category]?
    
    func performLoadProducts(_ callback: @escaping (OperationResult<[Product]>) -> Void) {
        let call = RequestCall(request: LoadProductsRequest(), responseType: CategoriesResponse.self) {
            switch $0 {
            case .success(let response):
                self.products = Array(response.value.values.flatMap{$0})
                self.categories = Array(response.value.keys)
                callback(.success(self.products!))
			case .failure(let error):
				callback(.failure(OperationError(error: error)))
			}
        }
		
        self.requestManager.request(call)
    }
    
    func performFindProduct(_ barcode: String, callback: @escaping (OperationResult<Product>) -> Void) {
        let call = RequestCall(request: FindProductRequest(barcode: barcode), responseType: ProductResponse.self) {
            switch $0 {
            case .success(let response):
                callback(.success(response.value))
			case .failure(let error):
				callback(.failure(OperationError(error: error)))
			}
        }
		
        self.requestManager.request(call)
    }
}
