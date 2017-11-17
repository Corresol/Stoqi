struct ModelPropertyResidentsQuestionViewModel : PropertyResidentsQuestionViewModel {
    var residents : PropertyResidents? {
        guard let adults = adults.value,
            let children = children.value,
            let pets = pets.value else {
            return nil
        }
        return PropertyResidents(adults: adults,
                                 children: children,
                                 pets: pets)
    }
    let question = "How many people?"
    
    var adults: ValidatableProperty<Int>
    var children: ValidatableProperty<Int>
    var pets: ValidatableProperty<Int>
    
    init(residents : PropertyResidents? = nil) {
        self.adults = ValidatableProperty(value: residents?.adults ?? 0, validators: [NilValidator(), ValueValidator(minBound: .exclusive(0), maxValue: 10)])
        self.children = ValidatableProperty(value: residents?.children ?? 0, validators: [NilValidator()])
        self.pets = ValidatableProperty(value: residents?.pets ?? 0, validators: [NilValidator()])
    }
}
