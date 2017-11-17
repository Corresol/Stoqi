struct NilValidator : Validator {
    let failedMessage = "Value can't be empty"
    
    func validate(_ value: Any?) -> Bool {
        return value != nil
    }
}
