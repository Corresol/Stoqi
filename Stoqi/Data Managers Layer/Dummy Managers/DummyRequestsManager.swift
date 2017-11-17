import GCDKit

class DummyRequestsManager : DummyAuthorizedManager, RequestsManager {
    var requests: [RequestList]?
	let productsManager: ProductsManager
	
	init(productsManager: ProductsManager) {
		self.productsManager = productsManager
	}
	
    func performLoadRequests(_ callback: @escaping (OperationResult<[RequestList]>) -> Void) {
        self.requests = self.dummies
        GCDQueue.main.after(1) {
            callback(.success(self.requests!))
        }
    }
    
    func performLoadRequestList(_ requestList: RequestList, callback: @escaping (OperationResult<RequestList>) -> Void) {
        GCDQueue.main.after(1) {
            callback(.success(requestList))
        }
    }
    
    func performProcessRequest(_ request: RequestList, callback: @escaping (AnyOperationResult) -> Void) {
        guard case .notAutorized = request.status  else {
            callback(.failure(.invalidParameters))
            return
        }
        var request = request
        request.status = .delivered(date: Date())
        self.requests?[request] = request
        let id = (self.requests?.last?.id ?? self.dummies.last?.id ?? 0) + 1
        let newRequest = RequestList(id: id,
                                 products: self.requestedProducts(productsManager.products!.random(4)),
                                 status: .notAutorized(from: Date(), to: (Date() + TSDateComponents.months(1))!))
        self.requests?.append(newRequest)
        GCDQueue.main.after(1) {
            callback(.success)
        }
    }
    
    func performSaveRequest(_ request: RequestList, callback: @escaping (AnyOperationResult) -> Void) {
        self.requests?[request] = request
        GCDQueue.main.after(1) {
            callback(.success)
        }
    }
}

extension DummyRequestsManager {
    
    fileprivate func requestedProducts(_ products : [Product]) -> [ProductEntry] {
		let products = productsManager.products!
		let prodEntry : ()->ProductEntry? = {
			[true, false].random ? ProductEntry(product: products.random, units: (1...5).random) : nil
		}
		
		return products.map {ProductEntry(product: $0, units: (1...5).random, suggestedProduct: prodEntry())}
    }
    
	fileprivate var dummies : [RequestList] {
        let products = productsManager.products!
        return [
            RequestList(id: 1,
                products: self.requestedProducts(products.random(3)),
                status: .delivered(date: Date.fromString("24/06/2016", withFormat: "dd/MM/yyyy")!)),
            RequestList(id: 2,
                products: self.requestedProducts(products.random(3)),
                status: .delivered(date: Date.fromString("23/04/2016", withFormat: "dd/MM/yyyy")!)),
            RequestList(id: 3,
                products: self.requestedProducts(products.random(2)),
                status: .delivered(date: Date.fromString("24/02/2016", withFormat: "dd/MM/yyyy")!)),
            RequestList(id: 5,
				products: self.requestedProducts(products.random(2)),
				status: .notAutorized(from: Date.fromString("28/08/2017", withFormat: "dd/MM/yyyy")!,
								 to: Date.fromString("04/09/2017", withFormat: "dd/MM/yyyy")!)),
            RequestList(id: 4,
                products: self.requestedProducts(products.random(2)),
                status: .inDelivering(from: Date.fromString("28/08/2016", withFormat: "dd/MM/yyyy")!))
            
        ]
    }
}
