struct PropertyLocation : Identifiable {
    let id : Int?
    let cityName : String
    let regionName : String
    
    init(id : Int,
         cityName : String,
         regionName : String) {
        self.id = id
        self.cityName = cityName
        self.regionName = regionName
    }
}

extension PropertyLocation : Archivable {
    
    
    func archived() -> [String : AnyObject] {
        guard let id = id else {
            return [:]
        }
        return [
            ArchiveKeys.Id.rawValue : id as AnyObject,
            ArchiveKeys.City.rawValue : cityName as AnyObject,
            ArchiveKeys.Region.rawValue : regionName as AnyObject
        ]
    }
    
    init?(fromArchive archive: [String : AnyObject]) {
        guard let id = archive[ArchiveKeys.Id.rawValue] as? Int,
        let city = archive[ArchiveKeys.City.rawValue] as? String,
        let region = archive[ArchiveKeys.Region.rawValue] as? String
        else {
            return nil
        }
        self.init(id: id, cityName: city, regionName: region)
    }
}

private enum ArchiveKeys : String {
    case Id = "kLocationId"
    case City = "kLocationCity"
    case Region = "kLocationRegion"
}
