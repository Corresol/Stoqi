private let kAccount = "authorizedAccount"

class ServiceAuthorizationManager : ServiceManager, AuthorizationManager {
    var account: Account? {
        didSet {
            if account != nil {
                authorize()
                saveAuthorizedUser()
            } else {
                deauthorize()
                clearAuthorizedUser()
            }
        }
    }
    
    override init(requestManager : RequestManager) {
        super.init(requestManager: requestManager)
        self.restoreAuthorizedUser()
    }
    
    func performAuthorization(withCredentials credentials: Credentials, callback: @escaping (AuthorizationResult) -> Void) {
        let request = LoginRequest(credentials: credentials)
        let call = RequestCall(request: request, responseType: AccountResponse.self) {
            switch $0 {
            case .success(let response):
                if case .existingAccount(let account) = response.value {
                    self.account = Account(id: account.id, email: credentials.email)
                    callback(.authorized(account))
                } else {
                    callback(.notExisted)
                }

            case .failure(let error):
                callback(.failure(OperationError(error: error)))
            }
        }
        self.requestManager.request(call)
    }
	
	
	func performPasswordRecovery(_ email: String, callback: @escaping (AnyOperationResult) -> Void)
	{
		let request = PasswordRecoveryRequest(email: email)
		let call = RequestCall(request: request, responseType: EmptyResponse.self) {
			switch $0 {
			case .success:
				callback(.success)
			case .failure(let error):
			callback(.failure(OperationError(error: error)))
			}
		}
		self.requestManager.request(call)
	}
	
    
    func performRegistration(withCredentials credentials: Credentials, callback: @escaping (AuthorizationResult) -> Void) {
        let request = RegisterRequest(credentials: credentials)
        let call = RequestCall(request: request, responseType: AccountResponse.self) {
            switch $0 {
            case .success(let response):
                if case .createdAccount(let account) = response.value {
                    self.account = Account(id: account.id, email: credentials.email)
                    callback(.created(account))
                } else {
                    callback(.notExisted)
                }
               
			case .failure(let error):
				callback(.failure(OperationError(error: error)))
			}
        }
        self.requestManager.request(call)
    }
    
    func performFacebookAuthorization(_ token : String, callback: @escaping (AuthorizationResult) -> Void) {
        let request = FacebookLoginRequest(token: token)
        let call = RequestCall(request: request, responseType: AccountResponse.self) {
            switch $0 {
            case .success(let response):
                if case .existingAccount(let account) = response.value {
                    self.account = Account(id: account.id, facebookToken: token)
                    callback(.authorized(account))
                } else if case .createdAccount(let account) = response.value {
                    self.account = Account(id: account.id, facebookToken: token)
                    callback(.created(account))
                } else {
                    callback(.notExisted)
                }
			case .failure(let error):
				callback(.failure(OperationError(error: error)))
			}
        }
        self.requestManager.request(call)
    }
    
    func performLogout(_ callback: @escaping (AnyOperationResult) -> Void) {
        self.account = nil
        deauthorize()
        clearAuthorizedUser()
    }
    
    // MARK: - Authorization Notifications
    func authorize() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AuthorizationManagerAuthorizedNotification), object: nil)
    }
    
    func deauthorize() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AuthorizationManagerDeauthorizedNotification), object: nil)
    }
    
    // MARK: - Sinlge Sign-In
    func saveAuthorizedUser() {
        Storage.local[kAccount] = account?.archived()
    }
    
    func restoreAuthorizedUser() {
        account = (Storage.local[kAccount] as? [String : AnyObject]).flatMap{Account(fromArchive: $0)}
        authorize()
    }
    
    func clearAuthorizedUser() {
        Storage.local[kAccount] = nil
    }
}

// MARK: - Authorization Notifications
extension ServiceAuthorizationManager {
//    func authorize() {
//        NotificationCenter.default.post(name: Notification.Name(rawValue: AuthorizationManagerAuthorizedNotification), object: nil)
//    }
//    
//    func deauthorize() {
//        NotificationCenter.default.post(name: Notification.Name(rawValue: AuthorizationManagerDeauthorizedNotification), object: nil)
//    }
}

// MARK: - Sinlge Sign-In
extension ServiceAuthorizationManager {
//    func saveAuthorizedUser() {
//        Storage.local[kAccount] = account?.archived()
//    }
//    
//    func restoreAuthorizedUser() {
//        account = (Storage.local[kAccount] as? [String : AnyObject]).flatMap{Account(fromArchive: $0)}
//        authorize()
//    }
//    
//    func clearAuthorizedUser() {
//        Storage.local[kAccount] = nil
//    }
}
