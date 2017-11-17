protocol EditableCardViewModel : ValidatableViewModel {
    var card : Card? {get}
    var number : ValidatableProperty<String> {get set}
    var owner : ValidatableProperty<String> {get set}
    var code : ValidatableProperty<String> {get set}
    var month : ValidatableProperty<Int> {get set}
    var year : ValidatableProperty<Int> {get set}
}