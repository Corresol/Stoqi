
/// Represents common interface of the Response. Used intensively to handle array of different `RequestCall`'s.
protocol AnyResponse {
    
    /// Defines kind of data which response can handle
    /// - Note: Optional. (default: .JSON)
    static var kind : ResponseKind {get}
    
    /// Mandatory initializer to set a request related to this response.
    /// - Note: Initializer can fail if it could not handle response body.
    init?(request : Request, body : AnyObject)
    
    /// Request related to the response.
    var request : Request {get}
}

/// Defines a response object.
protocol Response : AnyResponse {
    
    /// Type of the handled object.
    associatedtype ObjectType
    
    /// Contains response object.
    var value : ObjectType {get}
}

/// Defines what kind of data `Response` can handle
enum ResponseKind {
    
    /// Response handles JSON.
    case json
    
    /// Response handles NSData.
    case data
    
    /// Response handles String.
    case string
}

// MARK: - Response Defaults
extension Response {
    
    static var kind : ResponseKind {
        return .json
    }
    
    var description: String {
        if let descr = self.value as? CustomStringConvertible {
            return "Value: \(descr)"
        } else {
            return "Value: \(String(describing: self.value))"
        } 
    }
}
