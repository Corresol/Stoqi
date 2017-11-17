class DummyCardsManager: CardsManager {
	let profileManager: ProfileManager
	
	init(profileManager: ProfileManager) {
		self.profileManager = profileManager
	}
	
	func performAddCard(_ card: Card, callback: @escaping (OperationResult<[Card]>) -> Void)
	{
		self.profileManager.saveCards([card])
		callback(.success([card]))
	}
	
	func performRemoveCard(_ card: Card, callback: @escaping (AnyOperationResult) -> Void)
	{
		self.profileManager.removeCard(card)
		callback(.success)
	}
	
	func performSelectCard(_ card : Card, callback : @escaping (AnyOperationResult) -> Void)
	{
		self.profileManager.selectPrimaryCard(card)
		callback(.success)
	}
}
