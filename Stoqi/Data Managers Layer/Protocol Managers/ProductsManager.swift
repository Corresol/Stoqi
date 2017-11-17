//typealias LoadProductsCallback = (OperationResult<[Product]>) -> Void
//typealias FindProductCallback = (OperationResult<Product>) -> Void
/// Contains product definitions
protocol ProductsManager {
    
    /// List of products available in the Stoqi
    var products : [Product]? {get}
    
    var categories : [Category]? {get}
    
    // TODO: Pagination is mandatory here
    
    /// Loads list of available products
    func performLoadProducts(_ callback : @escaping (OperationResult<[Product]>) -> Void)
    
    func performFindProduct(_ barcode : String, callback : @escaping (OperationResult<Product>) -> Void)
}
