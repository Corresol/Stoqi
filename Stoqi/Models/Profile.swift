struct Profile : Identifiable {
    let id: Int?
    var email : String?
    var name : String?
	var phone: String?
    var address : Address?
	
    var cards : [Card]?
	// NOTE: Disabled primaryCard setter since there is no API to manage primary card and array of other cards.
	var primaryCard : Card?
	{
		var card: Card? = nil
		if let mCards = cards
		{
			for mCard in mCards
			{
				if(mCard.isPrimary == 1) {
					card = mCard
				}
			}
		}
		
		return card
	}
    var location : PropertyLocation?
    var propertyType : PropertyType?
    var propertyArea : PropertyArea?
    var propertyResidents : PropertyResidents?
    var priority : ProductsPriority?
    var saved : Float
    var monthly : Float
	var initial : Bool
    
    init(id : Int? = 0,
         email : String? = "",
         name : String? = "",
         phone : String? = "",
         saved : Float = 0,
         monthly : Float = 0,
         initial : Bool = false,
         address : Address? = Address(street : "",
                                      building : "",
                                      zip : "",
                                      latitude : 0,
                                      longitude : 0),
         primaryCard : Card? = Card(id : 0,
                                    number : "",
                                    code : "",
                                    owner : "",
                                    month : 0,
                                    year : 0,
                                    isPrimary : 0),
         cards : [Card]? = [],
         location : PropertyLocation? = PropertyLocation(id : 0,
                                                         cityName : "",
                                                         regionName : ""),
         propertyType : PropertyType? = .apartment,
         propertyArea : PropertyArea? = PropertyArea(area : 0, rooms : 0, knownArea : false),
         propertyResidents : PropertyResidents? = PropertyResidents(adults : 0,
                                                                    children : 0,
                                                                    pets : 0),
         priority : ProductsPriority? = .price) {
        self.id = id
        self.email = email
        self.name = name
		self.phone = phone
        self.saved = saved
        self.monthly = monthly
        if address != nil {
            self.address = address
        }
		self.initial = initial

        //self.primaryCard = primaryCard
        if cards != nil {
            
            self.cards = cards
        }
//        if let primaryCard = primaryCard {
//            if self.cards == nil {
//                self.cards = []
//            }
//            self.cards?.insert(primaryCard, atIndex: 0)
//        }
        if location != nil {
            
            self.location = location
        }
        
        if propertyType != nil {
            self.propertyType = propertyType
        }
        if propertyArea != nil {
            self.propertyArea = propertyArea
        }
        if propertyResidents != nil {
            self.propertyResidents = propertyResidents
        }
        if priority != nil {
            self.priority = priority
        }
    }
}

extension Profile {
    /// Builds new `Profile` with modified properties only
    func diff(_ profile : Profile) -> Profile {
        let email = self.email != profile.email ? profile.email : nil
        let name = self.name != profile.name ? profile.name : nil
		let phone = self.phone != profile.phone ? profile.phone : nil
        let address = profile.address == nil ? nil :
            self.address == nil || self.address! !== profile.address! ? profile.address : nil
       // let card = self.primaryCard != profile.primaryCard ? profile.primaryCard : nil
        let cards = profile.cards == nil ? nil : self.cards == nil || self.cards! != profile.cards! ? profile.cards : nil
        let location = self.location != profile.location ? profile.location : nil
        let type = self.propertyType != profile.propertyType ? profile.propertyType : nil
        let area = self.propertyArea != profile.propertyArea ? profile.propertyArea : nil
        let residents = self.propertyResidents != profile.propertyResidents ? profile.propertyResidents : nil
        let priority = self.priority != profile.priority ? profile.priority : nil
        return Profile(id: self.id,
                       email: email,
                       name: name,
                       phone: phone,
                       address: address,
                //       primaryCard: card,
                       cards: cards,
                       location: location,
                       propertyType: type,
                       propertyArea: area,
                       propertyResidents: residents,
                       priority: priority)
    }
    
    func intercect(_ profile : Profile) -> Profile {
        let email = profile.email != nil ? profile.email : self.email
        let name = profile.name != nil ? profile.name : self.name
		let phone = profile.phone != nil ? profile.phone : self.phone
        let address = profile.address != nil ? profile.address : self.address
       // let card = profile.primaryCard != nil ? profile.primaryCard : self.primaryCard
        let cards = profile.cards != nil ? profile.cards : self.cards
        let location = profile.location != nil ? profile.location : self.location
        let propertyType = profile.propertyType != nil ? profile.propertyType : self.propertyType
        let propertyArea = profile.propertyArea != nil ? profile.propertyArea : self.propertyArea
        let propertyResidents = profile.propertyResidents != nil ? profile.propertyResidents : self.propertyResidents
        let priority = profile.priority != nil ? profile.priority : self.priority
        return Profile(id: self.id,
                       email: email,
                       name: name,
                       phone: phone,
                       address: address,
                    //   primaryCard: card,
                       cards: cards,
                       location: location,
                       propertyType: propertyType,
                       propertyArea: propertyArea,
                       propertyResidents: propertyResidents,
                       priority: priority)
    }
}

private enum ArchiveKeys : String {
    case Location = "kProfileLocation"
    case PropertyType = "kProfilePropertyType"
    case PropertyArea = "kProfilePropertyArea"
    case Residents = "kProfileResidents"
    case Priority = "kProfilePriority"
    case Name = "kProfileName"
	case Email = "kProfileEmail"
}

extension Profile : Archivable {
    func archived() -> [String : AnyObject] {
        var profileDic = [String : AnyObject]()
		profileDic[ArchiveKeys.Email.rawValue] = email as AnyObject
        profileDic[ArchiveKeys.Name.rawValue] = name as AnyObject
        profileDic[ArchiveKeys.Location.rawValue] = location?.archived() as AnyObject
        profileDic[ArchiveKeys.PropertyType.rawValue] = propertyType?.rawValue as AnyObject
        profileDic[ArchiveKeys.PropertyArea.rawValue] = propertyArea?.archived() as AnyObject
        profileDic[ArchiveKeys.Residents.rawValue] = propertyResidents?.archived() as AnyObject
        profileDic[ArchiveKeys.Priority.rawValue] = priority?.rawValue as AnyObject
        return profileDic
    }
    
    init?(fromArchive archive: [String : AnyObject]) {
		let email = archive[ArchiveKeys.Email.rawValue] as? String
        let name = archive[ArchiveKeys.Name.rawValue] as? String
        let location = (archive[ArchiveKeys.Location.rawValue] as? [String : AnyObject]).flatMap{PropertyLocation(fromArchive: $0)}
        let type = (archive[ArchiveKeys.PropertyType.rawValue] as? Int).flatMap{PropertyType(rawValue: $0)}
        let area = (archive[ArchiveKeys.PropertyArea.rawValue] as? [String : AnyObject]).flatMap{PropertyArea(fromArchive: $0)}
        let residents = (archive[ArchiveKeys.Residents.rawValue] as? [String : AnyObject]).flatMap{PropertyResidents(fromArchive: $0)}
        let priority = (archive[ArchiveKeys.Priority.rawValue] as? Int).flatMap{ProductsPriority(rawValue: $0)}
        self.init(id: nil, email: email,
                          name: name,
                          location: location,
                          propertyType: type,
                          propertyArea: area,
                          propertyResidents: residents,
                          priority: priority)

    }
}

func ===(p1 : Profile, p2 : Profile) -> Bool {
    return  p1.email == p2.email &&
            p1.name == p2.name &&
            (p1.address == nil ||
            p2.address == nil ||
            p1.address! === p2.address!) &&
            p1.primaryCard == p2.primaryCard &&
            p1.location == p2.location &&
            p1.propertyType == p2.propertyType &&
            p1.propertyArea == p2.propertyArea &&
            p1.propertyResidents == p2.propertyResidents &&
            p1.priority == p2.priority
}

func !==(p1 : Profile, p2 : Profile) -> Bool {
    return !(p1 === p2)
}
