class ServiceRequestsManager : AuthorizedManager, RequestsManager {
    /// Loads user's both history and pending requests.
    func performLoadRequests(_ callback: @escaping (OperationResult<[RequestList]>) -> Void) {
        guard let account = self.accountManager.account,
            let request = LoadRequestsRequest(account: account) else {
                callback(.failure(.notAuthorized))
                return
        }
        
        let call = RequestCall(request: request, responseType: RequestsResponse.self){
            switch $0 {
            case .success(let response):
                self.requests = response.value
                callback(.success(response.value))
            case .failure(let error):
                callback(.failure(OperationError(error: error)))
            }
        }
        self.requestManager.request(call)
    }

    var requests: [RequestList]?
    
    func performLoadRequests1(_ callback: @escaping (OperationResult<[RequestList]>) -> Void) {
        guard let account = self.accountManager.account,
            let request = LoadRequestsRequest(account: account) else {
                callback(.failure(.notAuthorized))
                return
        }
        
        let call = RequestCall(request: request, responseType: RequestsResponse.self){
            switch $0 {
            case .success(let response):
                self.requests = response.value
                callback(.success(response.value))
			case .failure(let error):
				callback(.failure(OperationError(error: error)))
			}
        }
        self.requestManager.request(call)
    }
    
    func performLoadRequestList(_ requestList: RequestList, callback: @escaping (OperationResult<RequestList>) -> Void) {
        guard let request = LoadRequestProductsListRequest(requestList: requestList) else {
            callback(.failure(.invalidParameters))
            return
        }
        
        let call = RequestCall(request: request, responseType: RequestedProductsResponse.self) {
            switch $0 {
            case .success(let response):
                var list = requestList
                list.products = response.value
                self.requests?[requestList] = requestList
                callback(.success(list))
			case .failure(let error):
				callback(.failure(OperationError(error: error)))
			}
        }
        self.requestManager.request(call)
    }
    
    func performSaveRequest(_ requestList: RequestList, callback:  @escaping (AnyOperationResult) -> Void) {
        guard let account = self.accountManager.account,
            let request = SaveRequestListRequest(account: account, requestList: requestList) else {
                callback(.failure(.notAuthorized))
                return
        }
        let call = RequestCall(request: request, responseType: EmptyResponse.self){
            switch $0 {
            case .success:
                callback(.success)
			case .failure(let error):
				callback(.failure(OperationError(error: error)))
			}
        }
        self.requestManager.request(call)
    }
    
    func performProcessRequest(_ requestList: RequestList, callback: @escaping (AnyOperationResult) -> Void) {
        guard let request = ProcessRequestListRequest(requestList: requestList) else {
                callback(.failure(.notAuthorized))
                return
        }
        let call = RequestCall(request: request, responseType: RequestListResponse.self){
            switch $0 {
            case .success(let response):
                self.requests?.append(response.value)
                callback(.success)
			case .failure(let error):
				callback(.failure(OperationError(error: error)))
			}
        }
        self.requestManager.request(call)
    }
    
    override func deauthorize(_ notification: Notification) {
        super.deauthorize(notification)
        self.requests = nil
    }
}
