struct ClosureValidator<T> : Validator {
    let failedMessage: String
    let closure : (T?) -> Bool
    
    init(message : String, closure : @escaping (T?) -> Bool) {
        self.closure = closure
        self.failedMessage = message
    }
    
    func validate(_ value: Any?) -> Bool {
        guard let supportedValue = value as? T else {
            self.logUnsupportedType(value)
            return true
        }
        return self.closure(supportedValue)
    }
}
