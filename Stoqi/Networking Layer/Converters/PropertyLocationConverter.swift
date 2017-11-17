class PropertyLocationConverter : ResponseConverter<PropertyLocation> {
    override func convert(_ dictionary: [String : AnyObject]) -> PropertyLocation? {
        guard let id = (dictionary["id"] as? String).flatMap({Int($0)}),
            let city = dictionary["cityName"] as? String,
            let region = dictionary["stateName"] as? String else {
                return nil
        }
        
        return PropertyLocation(id: id, cityName: city, regionName: region)
    }
}
