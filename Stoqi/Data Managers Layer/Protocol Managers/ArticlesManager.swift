

protocol ArticlesManager {
    
    var articles : [Article]? {get}
    
    func performLoadArticles(_ callback : @escaping (OperationResult<[Article]>) -> Void)
}
