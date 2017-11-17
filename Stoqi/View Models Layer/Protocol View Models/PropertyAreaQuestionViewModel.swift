/// Used within RegisterList Screen -> AreaSize Page
protocol PropertyAreaQuestionViewModel : QuestionViewModel {
    var area : PropertyArea? {get}
    var size : ValidatableProperty<Int> {get set}
    var knownSize : ValidatableProperty<Bool> {get set}
    var rooms : ValidatableProperty<Int> {get set}
}

extension PropertyAreaQuestionViewModel {
    var answer : String? {
        guard let rooms = self.rooms.value, rooms > 0 else {
            return nil
        }
        let area = self.size.value ?? 0
        let known = self.knownSize.value ?? true
        let areaString = area > 0 && known ? "\(area) m²" : "Unknown area"
        return "\(areaString), \(rooms) \(rooms == 1 ? "room" : "rooms")"
    }
    
    var isValid : Bool {
        guard let rooms = self.rooms.value, rooms > 0 else {
            return false
        }
        let size = self.size.value ?? 0
        let known = self.knownSize.value ?? true
        return (!known || size > 0)
    }
}
