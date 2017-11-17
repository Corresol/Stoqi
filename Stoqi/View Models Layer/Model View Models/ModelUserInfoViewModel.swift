struct ModelUserInfoViewModel: UserInfoViewModel {
	
	var profile: Profile?{
		guard let name = name.value,
			let email = email.value,
			let phone = phone.value, isValid else {
			return nil
		}
		return Profile(email: email, name: name, phone: phone)
	}
	
	var name: ValidatableProperty<String>
	var email: ValidatableProperty<String>
	var phone: ValidatableProperty<String>
	
	init(profile: Profile){
		self.name = ValidatableProperty(value: profile.name, validators: [NilValidator()])
		self.email = ValidatableProperty(value: profile.email, validators: [EmailValidator()])
		self.phone = ValidatableProperty(value: profile.phone, validators: [NilValidator(), NumbersValidator(), LengthValidator(minLength:9)])
	}
	
}
