class ServiceCardsManager: AuthorizedManager, CardsManager {
	let profileManager: ProfileManager
	
	init(requestManager : RequestManager, accountManager : AuthorizationManager, profileManager: ProfileManager) {
		self.profileManager = profileManager
		super.init(requestManager: requestManager, accountManager: accountManager)
	}
	
	func performAddCard(_ card: Card, callback: @escaping (OperationResult<[Card]>) -> Void)
	{
		guard let account = self.accountManager.account,
			let request = AddCardRequest(account: account, card: card) else {
				callback(.failure(.notAuthorized))
				return
		}
		
		let call = RequestCall(request: request, responseType: CardsResponse.self)
		{
			switch $0 {
			case .success(let response):
				self.profileManager.saveCards(response.value)
				callback(.success(response.value))
			case .failure(let error):
				callback(.failure(OperationError(error: error)))
			}
		}
		
		self.requestManager.request(call)
	}
	
	func performRemoveCard(_ card: Card, callback:  @escaping (AnyOperationResult) -> Void)
	{
		guard let account = self.accountManager.account else {
				callback(.failure(.notAuthorized))
				return
		}
		
		guard let request = RemoveCardRequest(account: account, card: card) else {
				callback(.failure(.invalidParameters))
				return
		}
		
		let call = RequestCall(request: request, responseType: EmptyResponse.self)
		{
			switch $0 {
			case .success:
				self.profileManager.removeCard(card)
				callback(.success)
			case .failure(let error):
				callback(.failure(OperationError(error: error)))
			}
		}
		
		self.requestManager.request(call)
	}
	
	func performSelectCard(_ card : Card, callback :  @escaping (AnyOperationResult) -> Void)
	{
		guard let account = self.accountManager.account else {
			callback(.failure(.notAuthorized))
			return
		}
		
		guard let request = SelectCardRequest(account: account, card: card) else {
			callback(.failure(.invalidParameters))
			return
		}
		
		let call = RequestCall(request: request, responseType: EmptyResponse.self)
		{
			switch $0 {
			case .success:
				self.profileManager.selectPrimaryCard(card)
				callback(.success)
			case .failure(let error):
				callback(.failure(OperationError(error: error)))
			}
		}
		
		self.requestManager.request(call)
	}
}
