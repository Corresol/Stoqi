protocol QuestionViewModel : ProfileQuestionCellDataSource, ValidatableViewModel {
    var question : String {get}
    var answer : String? {get}
}