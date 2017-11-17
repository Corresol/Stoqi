/// Used within login process.
protocol LoginViewModel : ValidatableViewModel {
    var credentials : Credentials? {get}
    
    var login : ValidatableProperty<String> {get set}
    var password : ValidatableProperty<String>  {get set}
}

extension LoginViewModel {
    var validatables: [Validatable] {
       return [self.login, self.password]
    }
}
