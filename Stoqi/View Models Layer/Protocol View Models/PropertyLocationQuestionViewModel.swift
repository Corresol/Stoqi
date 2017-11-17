/// Used within RegisterList Screen -> SelectPropertyLocation & SearchPropertyLocation Pages
protocol PropertyLocationQuestionViewModel : QuestionViewModel {
    var location : PropertyLocation? {get set}
    var city : String? {get}
    var region : String? {get}
}

extension PropertyLocationQuestionViewModel {
    var answer : String? {
        guard let city = self.city, let region = self.region else {
            print("Failed to build answer for location.")
            return nil
        }
        return "\(city.capitalized), \(region.capitalized)"
    }
}

/// Same as above, but also serves as DataSource for SerachPropertyLocationCell
protocol SearchPropertyLocationViewModel : SearchPropertyLocationContentCellDataSource {
    var location : PropertyLocation {get}
    var city : String {get}
    var region : String {get}
}

/// Used within SearchPropertyLocation
protocol SearchQueryViewModel {
    var query : String? {get set}
    var isSearching : Bool {get set}
    var results : [SearchPropertyLocationViewModel] {get set}
}
