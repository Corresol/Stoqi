class VolumeConverter : ResponseConverter<Volume> {
    override func convert(_ dictionary: [String : AnyObject]) -> Volume? {
        guard let id = (dictionary["id"] as? String).flatMap({Int($0)}),
            let name = (dictionary["name"] as? NSString).flatMap({String($0)}),
            let unit = dictionary["unit"] as? String,
            let volume = (dictionary["volume"] as? String).flatMap({Float($0)})
            else {
                return nil
        }
        
        return Volume(id: id, name: name, volume: volume, unit: unit)
    }
}
