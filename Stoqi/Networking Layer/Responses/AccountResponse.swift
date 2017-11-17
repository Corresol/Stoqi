enum AccountResponseValue {
    case existingAccount(Account)
    case createdAccount(Account)
    case noAccount
}

struct AccountResponse : Response {
    let request : Request
    let value : AccountResponseValue
    static let kind = ResponseKind.json
    
    init?(request: Request, body: AnyObject) {
       self.request = request
        guard let response = (body as? [String : AnyObject])?["response"] as? [String : AnyObject] else {
            return nil
        }
        
        let accountConverter = try! Injector.inject(ResponseConverter<Account>.self)
        let exists = response["exists"] as? Bool ?? false
        
        if let account = accountConverter.convert(response) {
            self.value = exists ? .existingAccount(account) : .createdAccount(account)
        } else if !exists {
            self.value = .noAccount
        } else {
            return nil
        }
    }
}
