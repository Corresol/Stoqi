

/// Occurs when AuthorizationManager has obtained token. Use this notification to setup relying managers.
let AuthorizationManagerAuthorizedNotification = "AuthorizationManagerAuthorizedNotification"

/// Occurs when AuthorizationManager has cleared token. Use this notification to clear all data related to that token.
let AuthorizationManagerDeauthorizedNotification = "AuthorizationManagerDeauthorizedNotification"

enum AuthorizationResult {
    case authorized(Account)
    case created(Account)
    case notExisted
    case failure(OperationError)
}

//typealias AccountCallback = (AuthorizationResult) -> Void

/// Used for authorization process.
protocol AuthorizationManager {
    
    var account : Account? {get}
     
    /**
     - Throws:
     * OperationError.InvalidParameters,
     * OperationError.InvalidResponse,
     * OperationError.NetworkError,
     * OperationError.NotAuthorized
     */
    func performAuthorization(withCredentials credentials: Credentials, callback : @escaping (AuthorizationResult) -> Void)
    
    func performRegistration(withCredentials credentials: Credentials, callback : @escaping (AuthorizationResult) -> Void)
    
    /**
     - Throws:
     * OperationError.InvalidResponse,
     * OperationError.NetworkError
     */
    func performFacebookAuthorization(_ facebookToken: String, callback : @escaping (AuthorizationResult) -> Void)
	
	func performPasswordRecovery(_ email: String, callback : @escaping (AnyOperationResult) -> Void)
    
    /// Commonly simply clears account data.
    /// - Note: Conformed types must send notifications described above to let other managers to clear their account related data.
    func performLogout(_ callback : @escaping (AnyOperationResult) -> Void)
}

extension AuthorizationManager {
    
//    func performAuthorization(withCredentials credentials: Credentials, callback : @escaping (AuthorizationResult) -> Void){
//        
//    }
//    func performRegistration(withCredentials credentials: Credentials, callback : @escaping (AuthorizationResult) -> Void){
//        
//    }
//    func performFacebookAuthorization(_ facebookToken: String, callback : @escaping (AuthorizationResult) -> Void){
//        
//    }
//    func performPasswordRecovery(_ email: String, callback : @escaping (AnyOperationResult) -> Void?){
//        
//    }
//    func performLogout() {
//        self.performLogout()
//    }
}
