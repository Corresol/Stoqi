class ServiceAnalyticManager: AuthorizedManager, AnalyticManager
{
    

	var analytic: Analytic?
    func performLoadAnalytic(_ callback: @escaping (OperationResult<Analytic>) -> Void) {
        guard let account = accountManager.account,
            let request = LoadAnalyticRequest(account: account) else {
                callback(.failure(.notAuthorized))
                return
        }
        
        let call = RequestCall(request: request, responseType: AnalyticResponse.self) {
            if case .success(let response) = $0 {
                self.analytic = response.value
                callback(.success(response.value))
            } else if case .failure(let error) = $0 {
                callback(.failure(OperationError(error: error)))
                self.analytic = Analytic()
            }
        }
        requestManager.request(call)
    }
	
}
