protocol AddressViewModel : ValidatableViewModel, ProfileDeliveryCellDataSource {
    var address : Address? {get}
    var fullAddress : String? {get}
    var street : ValidatableProperty<String> {get set}
    var building : ValidatableProperty<String> {get set}
    var zip : ValidatableProperty<String> {get set}
}
