struct ModelEditableCardViewModel : EditableCardViewModel {
    var card : Card? {
        guard let number = number.value,
        let owner = owner.value,
        let code = code.value,
        let month = month.value,
            let year = year.value, isValid else {
                return nil
        }
        return Card(id: 0, number: number, code: code, owner: owner, month: month, year: year, isPrimary: 0)
    }
    var cardTypeImage: UIImage?
    var number : ValidatableProperty<String>
    var owner : ValidatableProperty<String>
    var code : ValidatableProperty<String>
    var month : ValidatableProperty<Int>
    var year : ValidatableProperty<Int>
    
    init(card : Card? = nil) {
        number = ValidatableProperty(value: card?.number, validators: [NilValidator(), VisaValidator() | AMEXValidator() | MasterCardValidator() | DinersValidator() | DiscoverValidator() | JCBValidator() | JCB15Validator() | UnionPayValidator() | HipercardValidator() | EloValidator() | MaestroValidator()])
        owner = ValidatableProperty(value: card?.owner, validators: [NilValidator()])
        code = ValidatableProperty(value: card?.code, validators: [NilValidator(), LengthValidator(minLength: 3, maxLength: 4)])
        month = ValidatableProperty(value: card?.month, validators: [NilValidator(), ValueValidator(minValue: 1, maxValue: 12)])
        year = ValidatableProperty(value: card?.year, validators: [NilValidator(), ValueValidator(minValue: Date().year)])
//        self.cardTypeImage = UIImage(named: "visa")
        // TODO: Complete card view model
    }
    
    var validatables : [Validatable] {
        return [number, owner, code, month, year]
    }
}
