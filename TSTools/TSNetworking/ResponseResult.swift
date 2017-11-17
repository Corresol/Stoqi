/// Represents result of the request.
enum ResponseResult <T: Any> {
    
    /// Response was successful and valid.
    /// - Parameter response: a response object.
    case success(response : T)
    
    /// Request failed with an error.
    /// - Parameter error: Occured error.
    case failure(error : RequestError)
}

enum Result {
    case success
    case failure(error : RequestError)
}

// MARK: - Conversion
extension Result {
    init(responseResult : AnyResponseResult) {
        switch responseResult {
        case .success: self = .success
        case .failure(let error): self = .failure(error: error)
        }
    }
}

typealias AnyResponseResult = ResponseResult<AnyResponse>
