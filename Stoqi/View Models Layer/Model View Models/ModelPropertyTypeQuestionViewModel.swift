struct ModelPropertyTypeQuestionViewModel : PropertyTypeQuestionViewModel {
    var type : PropertyType?
    let question = "What kind of house?"
    var answer: String? {
        return self.type.flatMap{"\($0)"}
    }
    
    var isValid: Bool {
        return self.type != nil
    }
}