/// Used within RegisterList -> SelectPropertyLocation
struct ModelPropertyLocationQuestionViewModel : PropertyLocationQuestionViewModel {
    var location : PropertyLocation?
    let question = "Where the cleaning is done?"
    var city: String? {
        return self.location?.cityName
    }
    var region: String? {
        return self.location?.regionName
    }
    
    var isValid: Bool {
        return self.location != nil
    }
}