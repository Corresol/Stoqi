struct PropertyResidents : Equatable {
    var adults : Int = 0
    var children : Int = 0
    var pets : Int = 0
    
    init(adults : Int,
         children : Int,
         pets : Int) {
        self.adults = adults
        self.children = children
        self.pets = pets
    }
}

extension PropertyResidents : Archivable {
    func archived() -> [String : AnyObject] {
        return [
            ArchiveKeys.Adults.rawValue : adults as AnyObject,
            ArchiveKeys.Children.rawValue : children as AnyObject,
            ArchiveKeys.Pets.rawValue : pets as AnyObject
        ]

    }
    
    init?(fromArchive archive: [String : AnyObject]) {
        guard let adults = archive[ArchiveKeys.Adults.rawValue] as? Int,
            let children = archive[ArchiveKeys.Children.rawValue] as? Int,
            let pets = archive[ArchiveKeys.Pets.rawValue] as? Int else {
                return nil
        }
        self.init(adults: adults, children: children, pets: pets)
    }
}

private enum ArchiveKeys : String {
    case Adults = "kPropertyResidentsAdults"
    case Children = "kPropertyResidentsChildren"
    case Pets = "kPropertyResidentsPets"
}


func == (r1 : PropertyResidents, r2 : PropertyResidents) -> Bool {
    return r1.adults == r2.adults &&
            r1.children == r2.children &&
            r1.adults == r2.adults
}
