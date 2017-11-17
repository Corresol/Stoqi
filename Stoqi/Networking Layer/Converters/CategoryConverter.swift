class CategoryConverter : ResponseConverter<Category> {
    override func convert(_ dictionary: [String : AnyObject]) -> Category? {
        guard let id = (dictionary["id"] as? String).flatMap({Int($0)}),
            let name = (dictionary["name"] as? NSString).flatMap({String($0)})
            else {
                return nil
        }
        
        return Category(id: id, name: name)
    }
}
