struct ModelLoginViewModel : LoginViewModel {
    var credentials: Credentials? {
        guard let email = self.login.value, let password = self.password.value else {
            return nil
        }
        return Credentials(email: email, password: password)
    }
    
    var login: ValidatableProperty<String>
    var password: ValidatableProperty<String>
    
    init (login : String? = nil, password : String? = nil, loginValidators: [Validator], passwordValidators: [Validator]) {
        self.login = ValidatableProperty(value: login, validators: loginValidators)
        self.password = ValidatableProperty(value: password, validators: passwordValidators)
    }
    
    init (credentials : Credentials, loginValidators: [Validator], passwordValidators: [Validator]) {
        self.init(login: credentials.email, password: credentials.password, loginValidators: loginValidators, passwordValidators: passwordValidators)
    }
}
