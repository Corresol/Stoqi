class PropertyAreaConverter : ResponseConverter<PropertyArea> {
    override func convert(_ dictionary : [String : AnyObject]) -> PropertyArea? {
        guard let area = (dictionary["propertyArea"] as? NSNumber)?.int32Value,
            let rooms = (dictionary["propertyRooms"] as? NSNumber)?.int32Value
            else {
            return nil
        }
        return PropertyArea(area: Int(area), rooms: Int(rooms))
    }
}
