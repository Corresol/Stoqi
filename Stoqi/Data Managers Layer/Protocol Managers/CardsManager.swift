//typealias CardsCallback = (OperationResult<[Card]>) -> Void

/// Manages user's cards
protocol CardsManager
{	
	func performAddCard(_ card : Card, callback : @escaping (OperationResult<[Card]>) -> Void)
	func performRemoveCard(_ card : Card, callback : @escaping (AnyOperationResult) -> Void)
	func performSelectCard(_ card : Card, callback : @escaping (AnyOperationResult) -> Void)
}
