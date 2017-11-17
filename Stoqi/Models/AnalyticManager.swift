//typealias LoadAnalyticCallback = (OperationResult<Analytic>) -> Void

protocol AnalyticManager
{
	var analytic : Analytic? {get set}

	func performLoadAnalytic(_ callback: @escaping (OperationResult<Analytic>) -> Void)
}
