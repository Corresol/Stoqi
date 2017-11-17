/// Used within RegisterList -> SelectPropertyLocation -> SearchPropertyLocation
struct ModelSearchPropertyLocationViewModel : SearchPropertyLocationViewModel {
    let location : PropertyLocation
    
    var city : String {
        return self.location.cityName
    }
    var region : String {
        return self.location.regionName
    }
    
    var matchingTerm: String?
    
    init(location : PropertyLocation, matchingTerm : String? = nil) {
        self.location = location
        self.matchingTerm = matchingTerm
    }
}

/// Used within RegisterList -> SelectPropertyLocation -> SearchPropertyLocation
struct ModelSearchQueryViewModel : SearchQueryViewModel {
    var query : String?
    var isSearching: Bool = false
    var results : [SearchPropertyLocationViewModel] = []
}