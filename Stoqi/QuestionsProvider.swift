protocol QuestionEditorDelegate {
    func questionEditor(_ editor : QuestionEditor, didEditQuestion : QuestionViewModel)
}

protocol QuestionEditor : class {
    var delegate : QuestionEditorDelegate? {get set}
    var question : QuestionViewModel {get set}
}
