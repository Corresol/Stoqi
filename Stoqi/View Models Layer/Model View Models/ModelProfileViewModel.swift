/// Used in Profile screen
struct ModelProfileViewModel : ProfileViewModel {
    var profile : Profile? {
        guard let email = self.email.value, self.email.isValid else {
            return nil
        }
        return Profile(id: nil,
                       email: email,
                       name: self.name.name.value,
                       phone: self.phone.value,
                       address: self.address?.address,
                       primaryCard: self.card?.card,
                       location: self.locationQuestion.location,
                       propertyType: self.propertyTypeQuestion.type,
                       propertyArea: self.propertyAreaQuestion.area,
                       propertyResidents: self.propertyResidentsQuestion.residents,
                       priority: self.productsPriorityQuestion.priority)
    }
    
    var name: NameQuestionViewModel
    var email: ValidatableProperty<String>
    var image: UIImage?
    
    var phone: ValidatableProperty<String>
    var address: AddressViewModel?
    var card: CardViewModel?
    
    var locationQuestion : PropertyLocationQuestionViewModel
    var propertyTypeQuestion : PropertyTypeQuestionViewModel
    var propertyAreaQuestion : PropertyAreaQuestionViewModel
    var propertyResidentsQuestion : PropertyResidentsQuestionViewModel
    var productsPriorityQuestion : ProductsPriorityQuestionViewModel
    
    init(profile : Profile) {
        self.name = ModelNameQuestionViewModel(name: profile.name)
        self.email = ValidatableProperty(value: profile.email, validators: [])
        self.phone = ValidatableProperty(value: profile.phone, validators: [])
        self.address = ModelAddressViewModel(address: profile.address)
		self.card = profile.primaryCard.flatMap{ModelCardViewModel(card: $0)}
        self.locationQuestion = ModelPropertyLocationQuestionViewModel(location: profile.location)
        self.propertyTypeQuestion = ModelPropertyTypeQuestionViewModel(type: profile.propertyType)
        self.propertyAreaQuestion = ModelPropertyAreaQuestionViewModel(area: profile.propertyArea)
        self.propertyResidentsQuestion = ModelPropertyResidentsQuestionViewModel(residents: profile.propertyResidents)
        self.productsPriorityQuestion = ModelProductsPriorityQuestionViewModel(priority: profile.priority)
    }
    
    var validatables: [Validatable] {
        return [self.name,
                self.email,
                self.phone,
                self.locationQuestion,
                self.propertyTypeQuestion,
                self.propertyAreaQuestion,
                self.propertyResidentsQuestion,
                self.productsPriorityQuestion]
    }
}
