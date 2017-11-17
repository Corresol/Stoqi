
class ServiceStockManager : AuthorizedManager, StockManager {
    func performLoadStock(_ callback: @escaping (OperationResult<Stock>) -> Void) {
        guard let account = accountManager.account,
            let request = LoadStockRequest(account: account) else {
                callback(.failure(.notAuthorized))
                return
        }
        let call = RequestCall(request: request, responseType: StockResponse.self) {
            if case .success(let response) = $0 {
                self.stock = response.value
                callback(.success(response.value))
            } else if case .failure(let error) = $0 {
                callback(.failure(OperationError(error: error)))
            }
        }
        requestManager.request(call)
    }

    var stock: Stock?
    
    // TODO: Requests
    func performLoadStock1(_ callback: @escaping (OperationResult<Stock>) -> Void) {
        guard let account = accountManager.account,
            let request = LoadStockRequest(account: account) else {
            callback(.failure(.notAuthorized))
            return
        }
        let call = RequestCall(request: request, responseType: StockResponse.self) {
            if case .success(let response) = $0 {
                self.stock = response.value
                callback(.success(response.value))
			} else if case .failure(let error) = $0 {
				callback(.failure(OperationError(error: error)))
			}
        }
        requestManager.request(call)
    }
    
    func performSaveStock(_ stock: Stock, callback: @escaping (OperationResult<Stock>) -> Void) {
        guard let account = accountManager.account,
            let request = SaveStockRequest(account: account, stock: stock) else {
                callback(.failure(.notAuthorized))
                return
        }
        let call = RequestCall(request: request, responseType: StockResponse.self) {
            if case .success(let response) = $0 {
                self.stock = response.value
                callback(.success(response.value))
			} else if case .failure(let error) = $0 {
				callback(.failure(OperationError(error: error)))
			}
        }
        requestManager.request(call)
    }
}
