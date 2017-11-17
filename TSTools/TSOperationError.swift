/** Errors which may occur during operations in Data Layer.
 
 - Version:    1.0
 - Since:      11/03/2016
 - Author:     AdYa
 */
enum OperationError : Error {
    case notAuthorized
    case invalidResponse
    case networkError
    case invalidParameters
    case unknown
	
	init(error: RequestError)
	{
		switch error {
		case .serverError, .networkError:
			self = .networkError
			
		case .invalidRequest:
			self = .invalidParameters
			
		case .invalidResponseKind, .failedRequest:
			self = .invalidResponse
			
		case .authorizationError:
			self = .notAuthorized
		}
	}
}

/** Represents a result of any operation in Data Layer without any additional data attached to `Success` result.
 
 - Version:    1.0
 - Since:      11/03/2016
 - Author:     AdYa
 */
enum AnyOperationResult {
    
    /// Result with no additional data.
    case success
    
    /// Result with `OperationError` occured during the operation.
    case failure(OperationError)
    
    init<T>(result : OperationResult<T>) {
        if case .failure(let error) = result {
            self = .failure(error)
        } else {
            self = .success
        }
    }
}

/** Represents a result of any operation in Data Layer with additional data attached to `Success` result.
 
 - Parameter T: Type of the data to be attached to `Success` result.
 
 - Version:    1.0
 - Since:      11/03/2016
 - Author:     AdYa
 */
enum OperationResult<T> {
    
    /// Result with an additional data of type `T`.
    case success(T)
    
    /// Result with an `OperationError` occured during the operation.
    case failure(OperationError)
}

//typealias OperationCallback = (AnyOperationResult) -> Void
