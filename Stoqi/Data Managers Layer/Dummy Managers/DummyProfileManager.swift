import GCDKit

private let kStorageCacheProfile = "kStorageDummyCacheProfile"

class DummyProfileManager : ProfileManager {
    

    
    var profile: Profile?
    
    init() {
        restoreCachedProfileRegistration()
    }
    func performSearchPropertyLocation(withTerm term: String, callback: @escaping (OperationResult<[PropertyLocation]>) -> Void) {
        GCDQueue.main.after(1) {
            let searchableTerm = term.lowercased()
            callback(.success(type(of: self).createDummyLocations().filter({
                $0.cityName.lowercased().contains(searchableTerm) ||
                    $0.regionName.lowercased().contains(searchableTerm)
            })))
        }
    }
    
    func performCreateProfile(_ profile: Profile, callback: @escaping (AnyOperationResult) -> Void) {
        self.profile = profile
        GCDQueue.main.after(1) {
            callback(.success)
        }
    }
    
    func performSaveProfile(_ profile: Profile, callback: @escaping (AnyOperationResult) -> Void) {
        self.profile = profile
        GCDQueue.main.after(1) {
            callback(.success)
        }
    }
	
	func performLogOutProfile(_ profile: Profile, callback: @escaping (AnyOperationResult) -> Void)
	{
		
	}
    
    func performLoadProfile(_ callback: @escaping (OperationResult<Profile>) -> Void) {
        self.profile = type(of: self).createDummyProfile()
        GCDQueue.main.after(1) { 
            callback(.success(self.profile!))
        }
    }
    
    func checkProfileRegistered() -> Bool {
        guard let profile = profile else {
            return false
        }
        return profile.name != nil &&
            profile.location != nil &&
            profile.propertyType != nil &&
            profile.propertyArea != nil &&
            profile.propertyResidents != nil &&
            profile.priority != nil
    }
	
	
    
    func cacheProfileRegistration(_ profile : Profile) {
        let accountManager = try! Injector.inject(AuthorizationManager.self)
        let account = accountManager.account?.email ?? accountManager.account?.facebookToken
        guard let key = account else {
            return
        }
        var cache = Storage.local[kStorageCacheProfile] as? [String : AnyObject] ?? [:]
        cache[key] = profile.archived() as AnyObject
        Storage.local[kStorageCacheProfile] = cache
    }
    
    func restoreCachedProfileRegistration() {
        let accountManager = try! Injector.inject(AuthorizationManager.self)
        let account = accountManager.account?.email ?? accountManager.account?.facebookToken
        guard let key = account else {
            return
        }
        profile = ((Storage.local[kStorageCacheProfile] as? [String : AnyObject])?[key] as? [String : AnyObject]).flatMap{Profile(fromArchive: $0)}
    }
    
    func clearCache() {
        guard var cache = Storage.local[kStorageCacheProfile] as? [String : AnyObject] else {
            return
        }
        let accountManager = try! Injector.inject(AuthorizationManager.self)
        let account = accountManager.account?.email ?? accountManager.account?.facebookToken
        guard let key = account else {
            return
        }
        cache[key] = nil
        Storage.local[kStorageCacheProfile] = cache
    }
	
	func saveCards(_ cards: [Card]) {
		profile?.cards? += cards
	}
	
	func removeCard(_ card: Card) {
		profile?.cards?[card] = nil
	}
	
	func selectPrimaryCard(_ card: Card) {
		if (self.profile?.cards) != nil
		{
			for index in 0...(self.profile?.cards?.count)!-1
			{
				let pCard = self.profile?.cards?[index]
				if (pCard!.id == card.id)
				{
					self.profile?.cards?[index].isPrimary = 1
				}
				else
				{
					self.profile?.cards?[index].isPrimary = 0
				}
			}
		}
	}
}

extension DummyProfileManager {

    class func createDummyLocations() -> [PropertyLocation] {
        return [PropertyLocation(id: 1, cityName: "Sao Paolo", regionName: "SP"),
                PropertyLocation(id: 2, cityName: "Sao Jose dp Rio Preto", regionName: "SP"),
                PropertyLocation(id: 3, cityName: "Sao Jose do Xingu", regionName: "MT"),
                PropertyLocation(id: 4, cityName: "Sao Bernardo do Campo", regionName: "SP"),
                PropertyLocation(id: 5, cityName: "Test City 1", regionName: "TR1"),
                PropertyLocation(id: 6, cityName: "Test City 2", regionName: "TR1"),
                PropertyLocation(id: 7, cityName: "Test City 3", regionName: "TR1"),
                PropertyLocation(id: 8, cityName: "Test City 4", regionName: "TR1"),
                PropertyLocation(id: 9, cityName: "Test City 1", regionName: "TR2"),
                PropertyLocation(id: 10, cityName: "Test City 2", regionName: "TR2"),
                PropertyLocation(id: 11, cityName: "Test City 1", regionName: "TR3")
        ]
    }
    
    class func createDummyProfile() -> Profile {
        let locations = self.createDummyLocations()
        let area = PropertyArea(area: 60, rooms: 2, knownArea: true)
        let residents = PropertyResidents(adults: 2, children: 1, pets: 1)
		let cards = [Card(id: 1, number: "4111111111111111", code: "123", owner: "Test name", month: 1, year: 2017, isPrimary: 1)]
        return Profile(email: "tester@test.test",
                       name: "Tester",
                       saved: 150,
                       monthly: 30,
                       cards: cards,
                       location: locations[0],
                       propertyType: .apartment,
                       propertyArea: area,
                       propertyResidents: residents,
                       priority: .both)
    }
}
