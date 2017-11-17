class AuthorizedManager : ServiceManager {
    let accountManager : AuthorizationManager
    
    init(requestManager : RequestManager, accountManager : AuthorizationManager) {
        self.accountManager = accountManager
        super.init(requestManager: requestManager)
        NotificationCenter.default.addObserver(self, selector: #selector(authorize), name: NSNotification.Name(rawValue: AuthorizationManagerAuthorizedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deauthorize), name: NSNotification.Name(rawValue: AuthorizationManagerDeauthorizedNotification), object: nil)
        
    }
    
    @objc func deauthorize(_ notification : Notification) {
        print("\(type(of: self)): Deauthorized.")
    }
    
    @objc func authorize(_ notification : Notification) {
        print("\(type(of: self)): Authorized.")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
