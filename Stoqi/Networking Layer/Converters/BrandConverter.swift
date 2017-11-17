class BrandConverter : ResponseConverter<Brand> {
    override func convert(_ dictionary: [String : AnyObject]) -> Brand? {
        guard let id = (dictionary["id"] as? String).flatMap({Int($0)}),
            let name = (dictionary["name"] as? NSString).flatMap({String($0)})
            else {
                return nil
        }
        
        return Brand(id: id, name: name)
    }
}
