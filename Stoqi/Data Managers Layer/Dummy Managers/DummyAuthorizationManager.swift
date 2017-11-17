import GCDKit

private let kAccount = "authorizedAccountDummy"

class DummyAuthorizationManager : AuthorizationManager {
    

    
    fileprivate static let dummyEmail = "test@test.test"
    
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

	init() {
		self.restoreAuthorizedUser()
	}
	
//    func performAuthorization(withCredentials credentials: Credentials, callback : @escaping AccountCallback) {
//        
//    }
    /**
     - Throws:
     * OperationError.InvalidParameters,
     * OperationError.InvalidResponse,
     * OperationError.NetworkError,
     * OperationError.NotAuthorized
     */
    func performAuthorization(withCredentials credentials: Credentials, callback: @escaping (AuthorizationResult) -> Void) {
        let fakeRegister = credentials.email == type(of: self).dummyEmail
        if !fakeRegister {
            self.account = type(of: self).createDummyAccount(credentials)
        }
        GCDQueue.main.after(1)  {
            callback(fakeRegister ? .notExisted : .authorized(self.account!))
        }
    }
    
    func performFacebookAuthorization(_ token : String, callback: @escaping (AuthorizationResult) -> Void) {
        self.account = type(of: self).createDummyAccount()
        GCDQueue.main.after(1)  {
            callback(.created(self.account!))
        }
    }
	
	func performPasswordRecovery(_ email: String, callback: @escaping (AnyOperationResult) -> Void) {
		callback(.success)
	}
    
    func performLogout(_ callback : @escaping (AnyOperationResult) -> Void) {
        self.account = nil
        callback(.success)
    }
    
    func performRegistration(withCredentials credentials: Credentials, callback : @escaping (AuthorizationResult) -> Void) {
        self.account = type(of: self).createDummyAccount(credentials)
        GCDQueue.main.after(1)  {
            callback(.created(self.account!))
        }
    }
    
    class func createDummyAccount(_ base : Credentials? = nil) -> Account {
        let email = base?.email ?? self.dummyEmail
        return Account(id: 1, email: email)
    }
}

// MARK: - Sinlge Sign-In
extension DummyAuthorizationManager {
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
extension DummyAuthorizationManager {
    func authorize() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AuthorizationManagerAuthorizedNotification), object: nil)
    }
    
    func deauthorize() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: AuthorizationManagerDeauthorizedNotification), object: nil)
    }
}
