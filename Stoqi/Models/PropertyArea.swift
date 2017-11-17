struct PropertyArea : Equatable {
    var area : Int = 0
    var rooms : Int = 0
    var knownArea : Bool = true
    
    init(area : Int, rooms : Int, knownArea : Bool) {
        self.area = area
        self.rooms = rooms
        self.knownArea = knownArea  
    }
    
    init(area : Int = 0, rooms : Int = 0) {
        self.init(area: area, rooms: rooms, knownArea: true) // area != 0)
    }
}

extension PropertyArea : Archivable {
    func archived() -> [String : AnyObject] {
        return [
            ArchiveKeys.Size.rawValue : area as AnyObject,
            ArchiveKeys.Known.rawValue : knownArea as AnyObject,
            ArchiveKeys.Rooms.rawValue : rooms as AnyObject
        ]
    }
    
    init?(fromArchive archive: [String : AnyObject]) {
        guard let area = archive[ArchiveKeys.Size.rawValue] as? Int,
            let known = archive[ArchiveKeys.Known.rawValue] as? Bool,
            let rooms = archive[ArchiveKeys.Rooms.rawValue] as? Int else {
                return nil
        }
        self.init(area: area, rooms: rooms, knownArea: known)
    }
}

func == (a1 : PropertyArea, a2 : PropertyArea) -> Bool {
    return a1.area == a2.area &&
            a1.rooms == a2.rooms &&
            a1.knownArea == a2.knownArea
}

private enum ArchiveKeys : String {
    case Size = "kPropertyAreaSize"
    case Known = "kPropertyAreaKnown"
    case Rooms = "kPropertyAreaRooms"
}
