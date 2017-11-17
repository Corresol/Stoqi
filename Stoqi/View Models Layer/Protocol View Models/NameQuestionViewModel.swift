protocol NameQuestionViewModel : QuestionViewModel {
    var name : ValidatableProperty<String> {get set}
}

extension NameQuestionViewModel {
    var validatables : [Validatable] {
        return [name]
    }
}