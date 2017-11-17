protocol UserInfoViewModel: ValidatableViewModel {
	
	var profile: Profile? {get}
	
	var name: ValidatableProperty<String> {get set}
	var email: ValidatableProperty<String> {get set}
	var phone: ValidatableProperty<String> {get set}
}

extension UserInfoViewModel
{
	var validatables: [Validatable] {
		return [name, email, phone]
	}
}
