class PropertyResidentsConverter : ResponseConverter<PropertyResidents> {
    override func convert(_ dictionary : [String : AnyObject]) -> PropertyResidents? {
        guard let adults = (dictionary["residentAdults"] as? NSNumber)?.int32Value,
            let children = (dictionary["residentChildren"] as? NSNumber)?.int32Value,
            let pets = (dictionary["residentPets"] as? NSNumber)?.int32Value
            else {
                return nil
        }
        return PropertyResidents(adults: Int(adults), children: Int(children), pets: Int(pets))
    }
}
