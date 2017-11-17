struct SaveProfileRequest : Request {
    let method = RequestMethod.post
    let url = "user/profile"
    let parameters: [String : AnyObject]?
    
    init?(account : Account, profile : Profile) {
        guard let accountId = account.id else {
                return nil
        }
        var params : [String : AnyObject] = [:]
        // Mandatory fields
        params["accountId"] = accountId as AnyObject
        
        // Optional fields
        
        params["propertyArea"] = profile.propertyArea?.area as AnyObject
        params["propertyRooms"] = profile.propertyArea?.rooms as AnyObject
        params["residentAdults"] = profile.propertyResidents?.adults as AnyObject
        params["residentChildren"] = profile.propertyResidents?.children as AnyObject
        params["residentPets"] = profile.propertyResidents?.pets as AnyObject
		
		if profile.initial
		{
			params["initial"] = 1 as AnyObject
		}
        
        // Address
        if profile.location != nil ||
            profile.propertyType != nil ||
            profile.address != nil ||
			profile.phone != nil {
            var addressParams : [String : AnyObject] = [:]
            addressParams["city"] = profile.location?.id as AnyObject
            addressParams["propertyType"] = profile.propertyType?.rawValue as AnyObject
            addressParams["street"] = profile.address?.street as AnyObject
            addressParams["streetNumber"] = profile.address?.building as AnyObject
            addressParams["phone1"] = profile.phone as AnyObject
            //addressParams["phone2"] = profile.address?.phoneSecondary
            addressParams["zip"] = profile.address?.zip as AnyObject
            addressParams["latitude"] = profile.address?.latitude as AnyObject
            addressParams["longitude"] = profile.address?.longitude as AnyObject
            
            params["address"] = addressParams as AnyObject
        }
        
        // Profile
        if profile.email != nil ||
            profile.name != nil ||
            profile.priority != nil {
            var profileParams : [String : AnyObject] = [:]
            profileParams["name"] = profile.name as AnyObject
            profileParams["email"] = profile.email as AnyObject
            profileParams["userType"] = profile.priority?.rawValue as AnyObject
            
            params["profile"] = profileParams as AnyObject
        }
        
        // Card
        if let card = profile.primaryCard {
            var cardParams : [String : AnyObject] = [:]
            cardParams["name"] = card.owner as AnyObject
            cardParams["number"] = card.number as AnyObject
            cardParams["expityMonth"] = card.month as AnyObject
            cardParams["expityYear"] = card.year as AnyObject
			//cardParams["cvv"] = card.code
            
            params["card"] = cardParams as AnyObject
        }
        
        self.parameters = params
    }
}
