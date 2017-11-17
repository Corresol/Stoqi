/**
 RequestCall represents a single request call with configured `Request` object and defined type of expected Response object.
 - Parameter Request: Configured Request object.
 - Parameter Type: Type of expected Response object.
 */
struct RequestCall<ResponseType : AnyResponse> : AnyRequestCall {
    
    /// `Request` to be called.
    let request : Request
    
    /// Type of `Response` responsible for handling actual response from remote service.
    fileprivate let genericResponseType : ResponseType.Type
    
    /// `Request` completion called once the request is completed.
    /// - Parameter result: Contains result of the `request`. Can be either succesful with `Response` object constructed or failure with an error.
    fileprivate let genericCompletion : ((ResponseResult<ResponseType>) -> Void)?
    
    /// Generalized `Request` completion called once the request is completed.
    /// - Note: Forwards calls to actual completion with generic type.
    var completion: AnyResponseResultCompletion? { // Tricky things happens here that allows whole thing to work.
        return { res in
            switch res {
            case .success(let response): self.genericCompletion?(.success(response: response as! ResponseType))
            case .failure(let error) : self.genericCompletion?(.failure(error: error))
            }
        }
    }
    
    /// Generalized type of the `Response`.
    /// - Note: Returns actual generic type.
    var responseType: AnyResponse.Type {
        return self.genericResponseType
    }
    
    init(request : Request, responseType : ResponseType.Type, completion : ((ResponseResult<ResponseType>) -> Void)? = nil) {
        self.request = request
        self.genericResponseType = responseType
        self.genericCompletion = completion
    }
}

/// Represents common interface of the RequestCall. Used intensively to handle array of different `RequestCall`'s.
protocol AnyRequestCall {
    
    /// `Request` to be called.
    var request : Request {get}
    
    /// Generalized `Request` completion called once the request is completed.
    /// - Note: Forwards calls to actual completion with generic type.
    var completion : AnyResponseResultCompletion? {get}
    
    /// Generalized type of the `Response`.
    /// - Note: Returns actual generic type.
    var responseType : AnyResponse.Type {get}
}

typealias AnyResponseResultCompletion = (AnyResponseResult) -> Void
