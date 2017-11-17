import GCDKit

class DummyStockManager : DummyAuthorizedManager, StockManager {
    
    func performSaveStock(_ stock: Stock, callback: @escaping (OperationResult<Stock>) -> Void) {
        self.stock = stock
        GCDQueue.main.after(1) {
            callback(.success(self.stock!))
        }
    }
    
    func performLoadStock(_ callback: @escaping (OperationResult<Stock>) -> Void) {
        self.stock = self.dummy
        GCDQueue.main.after(1) {
            callback(.success(self.stock!))
        }
    }

    
    var stock: Stock?
	let productsManager: ProductsManager
	
	init (productsManager: ProductsManager) {
		self.productsManager = productsManager
	}
}

extension DummyStockManager {
    fileprivate var dummy : Stock {
        let products : [StockProduct] = productsManager.products!.random(3).map {
            let total = (1...10).random
            let left = (0...total).random
			let confirmed = false
			return StockProduct(product: $0, left: Float(left)  * 0.25, total: Float(total) * 0.25, confirmed: confirmed)
        }
        return Stock(products: products)
    }
}
