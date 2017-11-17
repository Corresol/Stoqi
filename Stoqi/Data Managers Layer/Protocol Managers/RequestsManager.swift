//typealias LoadRequestsCallback = (OperationResult<[RequestList]>) -> Void
//typealias LoadRequestListCallback = (OperationResult<RequestList>) -> Void

/// Manages user's requests
protocol RequestsManager {
    
    /// List of user's requests.
    var requests : [RequestList]? {get}
    
    /// Loads user's both history and pending requests.
    func performLoadRequests(_ callback :@escaping (OperationResult<[RequestList]>) -> Void)
    
    /// Loads products list of given request.
    func performLoadRequestList(_ requestList : RequestList, callback : @escaping (OperationResult<RequestList>) -> Void)
    
    /// Initiates request processing.
    func performProcessRequest(_ request : RequestList, callback : @escaping (AnyOperationResult) -> Void)
    
    /// Saves changes in the request
    func performSaveRequest(_ request : RequestList, callback : @escaping (AnyOperationResult) -> Void)
}
