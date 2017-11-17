struct ModelProductsPriorityQuestionViewModel : ProductsPriorityQuestionViewModel {
    var priority : ProductsPriority?
    let question = "Brand or Price?"
    var answer: String? {
        return self.priority.flatMap{"\($0)"}
    }
    
    var isValid: Bool {
        return self.priority != nil
    }
}