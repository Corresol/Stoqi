struct ProfileResponse : Response {
    let request: Request
    let value: Profile
    
    init?(request: Request, body: AnyObject) {
        self.request = request
        guard let response = (body as? [String : AnyObject])?["response"] as? [String : AnyObject], !response.isEmpty else {
            return nil
        }
        let profileDic = response["profile"] as? [String : AnyObject]
        let cardsArray = response["card"] as? [[String : AnyObject]]
        let addressDic = response["address"] as? [String : AnyObject]
        let cardConverter = try! Injector.inject(ResponseConverter<Card>.self)
        let addressConverter = try! Injector.inject(ResponseConverter<Address>.self)
        let propertyAreaConverter = try! Injector.inject(ResponseConverter<PropertyArea>.self)
        let propertyResidentsConverter = try! Injector.inject(ResponseConverter<PropertyResidents>.self)
        let locationConverter = try! Injector.inject(ResponseConverter<PropertyLocation>.self)
        
        var profile = Profile()
        profile.name = profileDic?["name"] as? String
        profile.email = profileDic?["email"] as? String
		profile.phone = addressDic?["phone1"] as? String
        profile.cards = cardsArray?.flatMap{cardConverter.convert($0)}
        //profile.primaryCard = cardDic.flatMap({cardConverter.convert($0)}) //TODO: need getting primary card
        profile.address = addressDic.flatMap({addressConverter.convert($0)})
        profile.location = (response["location"] as? [String : AnyObject]).flatMap{locationConverter.convert($0)}
        profile.propertyArea = propertyAreaConverter.convert(response)
        profile.propertyResidents = propertyResidentsConverter.convert(response)
        profile.propertyType = (addressDic?["propertyType"] as? String).flatMap{Int($0)}.flatMap{PropertyType(rawValue: $0)}
        profile.priority = (profileDic?["userType"] as? String).flatMap{Int($0)}.flatMap{ProductsPriority(rawValue: $0)}
        
        self.value = profile
    }
}
