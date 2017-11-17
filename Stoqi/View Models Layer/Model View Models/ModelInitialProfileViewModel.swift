/// Used to create profile with questionnaire
struct ModelInitialProfileViewModel : ProfileViewModel {
    var profile : Profile? {
        return Profile(name : self.name.name.value,
                       location: self.locationQuestion.location,
                       propertyType: self.propertyTypeQuestion.type,
                       propertyArea: self.propertyAreaQuestion.area,
                       propertyResidents: self.propertyResidentsQuestion.residents,
                       priority: self.productsPriorityQuestion.priority)
    }
    
    var name: NameQuestionViewModel
    var email: ValidatableProperty<String> = ValidatableProperty(value: nil, validators: [])
    var image: UIImage? = nil
    
    var phone: ValidatableProperty<String> = ValidatableProperty(value: nil, validators: [])
    var address: AddressViewModel? = nil
    var card: CardViewModel? = nil
    
    var locationQuestion : PropertyLocationQuestionViewModel
    var propertyTypeQuestion : PropertyTypeQuestionViewModel
    var propertyAreaQuestion : PropertyAreaQuestionViewModel
    var propertyResidentsQuestion : PropertyResidentsQuestionViewModel
    var productsPriorityQuestion : ProductsPriorityQuestionViewModel
    
    init() {
        self.name = ModelNameQuestionViewModel()
        self.locationQuestion = ModelPropertyLocationQuestionViewModel()
        self.propertyTypeQuestion = ModelPropertyTypeQuestionViewModel()
        self.propertyAreaQuestion = ModelPropertyAreaQuestionViewModel()
        self.propertyResidentsQuestion = ModelPropertyResidentsQuestionViewModel()
        self.productsPriorityQuestion = ModelProductsPriorityQuestionViewModel()
    }
    
    var validatables: [Validatable] {
        return [self.name,
                self.locationQuestion,
                self.propertyTypeQuestion,
                self.propertyAreaQuestion,
                self.propertyResidentsQuestion,
                self.productsPriorityQuestion]
    }
}