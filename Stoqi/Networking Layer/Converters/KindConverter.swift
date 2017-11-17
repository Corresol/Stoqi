class KindConverter : ResponseConverter<Kind> {
    override func convert(_ dictionary: [String : AnyObject]) -> Kind? {
        guard let id = (dictionary["id"] as? String).flatMap({Int($0)}),
			let name = (dictionary["name"] as? NSString).flatMap({String($0)})
            else {
                return nil
        }
        
        return Kind(id: id, name: name)
    }
}
