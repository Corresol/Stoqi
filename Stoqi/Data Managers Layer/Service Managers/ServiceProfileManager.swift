private let kStorageCacheProfile = "kStorageCacheProfile"

class ServiceProfileManager : AuthorizedManager, ProfileManager {
    func performLogOutProfile(_ profile: Profile, callback: @escaping (AnyOperationResult) -> Void) {
        guard let account = accountManager.account,
            let request = LogoutRequest(account: account) else {
                callback(.failure(.invalidParameters))
                return
        }
        
        let call = RequestCall(request: request, responseType: EmptyResponse.self) { _ in
        }
        requestManager.request(call)
    }

    func performSaveProfile(_ profile: Profile, callback: @escaping (AnyOperationResult) -> Void) {
        guard let account = accountManager.account,
            let request = SaveProfileRequest(account: account, profile: self.profile?.diff(profile) ?? profile) else {
                callback(.failure(.invalidParameters))
                return
        }
        
        let call = RequestCall(request: request, responseType: EmptyResponse.self) {
            switch $0 {
            case .success:
                self.profile = self.profile?.intercect(profile) ?? profile
                callback(.success)
            case .failure(let error):
                callback(.failure(OperationError(error: error)))
            }
        }
        requestManager.request(call)
    }

    func performCreateProfile(_ profile: Profile, callback: @escaping (AnyOperationResult) -> Void) {
        guard let account = accountManager.account,
            let request = SaveProfileRequest(account: account, profile: profile) else {
                callback(.failure(.invalidParameters))
                return
        }
        
        let call = RequestCall(request: request, responseType: EmptyResponse.self) {
            switch $0 {
            case .success:
                self.profile = self.profile?.intercect(profile) ?? profile
                callback(.success)
            case .failure(let error):
                callback(.failure(OperationError(error: error)))
            }
        }
        requestManager.request(call)

    }

    var profile : Profile?
    
    
    override init(requestManager : RequestManager, accountManager : AuthorizationManager) {
        super.init(requestManager: requestManager, accountManager: accountManager)
        restoreCachedProfileRegistration()
    }
    
    func performSearchPropertyLocation(withTerm term: String, callback: @escaping (OperationResult<[PropertyLocation]>) -> Void) {
        let call = RequestCall(request: SearchLocationRequest(term: term), responseType: PropertyLocationResponse.self) {
            switch $0 {
            case .success(let response):
                callback(.success(response.value))
			case .failure(let error):
				callback(.failure(OperationError(error: error)))
			}
        }
		
        requestManager.request(call)
    }
    
//    func performCreateProfile(_ profile: Profile, callback: @escaping OperationCallback) {
//            }

    
//    func performSaveProfile(_ profile: Profile, callback: @escaping (AnyOperationResult) -> Void?) {
//       
//    }
    
    func performLoadProfile(_ callback: @escaping (OperationResult<Profile>) -> Void) {
        guard let account = accountManager.account,
            let request = LoadProfileRequest(account: account) else {
                callback(.failure(.invalidParameters))
                return
        }
        let call = RequestCall(request: request, responseType: ProfileResponse.self) {
            switch $0 {
            case .success(let response):
                self.profile = response.value
                callback(.success(self.profile!))
			case .failure(let error):
				callback(.failure(OperationError(error: error)))
			}
        }
        requestManager.request(call)
    }
	
//	func performLogOutProfile(_ profile: Profile, callback: @escaping (AnyOperationResult) -> Void?) {
//		
//	}
	
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
    
    override func deauthorize(_ notification: Notification) {
        super.deauthorize(notification)
        profile = nil
    }
	
	func saveCards(_ cards: [Card]) {
		self.profile?.cards? += cards
	}
	
	func removeCard(_ card: Card) {
		if let index = self.profile?.cards?.index(of: card) {
			self.profile?.cards?.remove(at: index)
		}
	}
	
	func selectPrimaryCard(_ card: Card)
	{
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

extension ServiceProfileManager {
    func cacheProfileRegistration(_ profile : Profile) {
        let account = accountManager.account?.email ?? accountManager.account?.facebookToken
        guard let key = account else {
            return
        }
        var cache = Storage.local[kStorageCacheProfile] as? [String : AnyObject] ?? [:]
        cache[key] = profile.archived() as AnyObject
        Storage.local[kStorageCacheProfile] = cache
    }
    
    func restoreCachedProfileRegistration() {
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
        let account = accountManager.account?.email ?? accountManager.account?.facebookToken
        guard let key = account else {
            return
        }
        cache[key] = nil
        Storage.local[kStorageCacheProfile] = cache
    }
}
