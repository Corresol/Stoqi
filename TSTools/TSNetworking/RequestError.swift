/// Defines set of handles error.
enum RequestError : Error {
    
    /// Error occured while remote service processing the request.
    case serverError
    
    /// Request couldn't reach destination.
    case networkError
    
    /// Given `Request` object is not valid to be sent.
    case invalidRequest
    
    /// Actual response has type different from specified `ResponseKind`. Therefore couldn't be handled by `Response`.
    case invalidResponseKind
    
    /// Remote service correctly processed `Request`, but responsed with an error.
    case failedRequest
    
    /// Remote service requires authorization, which either was not provided or was invalid.
    case authorizationError
}
