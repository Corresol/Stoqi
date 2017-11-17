struct ModelPropertyAreaQuestionViewModel : PropertyAreaQuestionViewModel {
    var area : PropertyArea? {
        guard let size = self.size.value,
            let rooms = self.rooms.value, self.isValid else {
                return nil
        }
		let knownSize = self.knownSize.value ?? true
		
        return PropertyArea(area: size, rooms: rooms, knownArea: knownSize)
    }
    
    let question = "Which size?"
    var size: ValidatableProperty<Int>
    var knownSize: ValidatableProperty<Bool>
    var rooms: ValidatableProperty<Int>
    
    init(area : PropertyArea? = nil) {
        self.size = ValidatableProperty(value: area?.area ?? 70, validators: [NilValidator(), ValueValidator(minBound: .exclusive(0), maxValue: 500)])
        self.knownSize = ValidatableProperty(value: area?.knownArea, validators: [NilValidator()])
        self.rooms = ValidatableProperty(value: area?.rooms, validators: [NilValidator(), ValueValidator(minBound: .exclusive(0), maxValue: 10)])
    }
}
