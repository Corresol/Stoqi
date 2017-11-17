/// Used within RegisterList Screen -> Residents Page
protocol PropertyResidentsQuestionViewModel : QuestionViewModel {
    var residents : PropertyResidents? {get}
    var adults : ValidatableProperty<Int> {get set}
    var children : ValidatableProperty<Int> {get set}
    var pets : ValidatableProperty<Int> {get set}
}

extension PropertyResidentsQuestionViewModel {
    var answer : String? {
        let adults = self.adults.value ?? 0
        let children = self.children.value ?? 0
        let pets = self.pets.value ?? 0
        
        let adultsString = adults > 0 ? "\(adults) \(adults == 1 ? "adult" : "adults")" : "No adults"
        let childrenString = children > 0 ? "\(children) \(children == 1 ? "child" : "children")" : "No children"
        let petsString = pets > 0 ? "\(pets) \(pets == 1 ? "pet" : "pets")" : "No pets"
        return "\(adultsString), \(childrenString), \(petsString)"
    }
    var validatables: [Validatable] {
        return [self.adults]
    }
}