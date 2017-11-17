//typealias LoadStockCallback = (OperationResult<Stock>) -> Void

protocol StockManager {
    var stock : Stock? {get}
    
    func performLoadStock(_ callback : @escaping (OperationResult<Stock>) -> Void)
    func performSaveStock(_ stock : Stock, callback : @escaping (OperationResult<Stock>) -> Void)
}
