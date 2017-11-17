struct ModelNameQuestionViewModel : NameQuestionViewModel {
    var name : ValidatableProperty<String>
    
    let question = "What is your name?"
    var answer : String? {
        return name.value
    }
    
    init(name : String? = nil) {
        self.name = ValidatableProperty(value: name, validators: [NilValidator(), NonEmptyValidator()])
    }
}
