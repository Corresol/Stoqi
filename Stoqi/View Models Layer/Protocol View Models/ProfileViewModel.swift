protocol ProfileViewModel : ValidatableViewModel {
    var profile : Profile? {get}
    
    var name : NameQuestionViewModel {get set}
    var email : ValidatableProperty<String> {get set}
    var image : UIImage? {get set}
    var phone : ValidatableProperty<String> {get set}
    
    var address : AddressViewModel? {get set}
    var card : CardViewModel? {get set}
    
    var locationQuestion : PropertyLocationQuestionViewModel {get set}
    var propertyTypeQuestion : PropertyTypeQuestionViewModel {get set}
    var propertyAreaQuestion : PropertyAreaQuestionViewModel {get set}
    var propertyResidentsQuestion : PropertyResidentsQuestionViewModel {get set}
    var productsPriorityQuestion : ProductsPriorityQuestionViewModel {get set}
}
