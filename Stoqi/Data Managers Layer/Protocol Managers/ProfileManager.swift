//typealias PropertyLocationCallback = (OperationResult<[PropertyLocation]>) -> Void
//typealias ProfileCallback = (OperationResult<Profile>) -> Void

protocol ProfileManager {
    
    var profile : Profile? {get}
    
    func performSearchPropertyLocation(withTerm term : String, callback : @escaping (OperationResult<[PropertyLocation]>) -> Void)
    
    func performCreateProfile(_ profile : Profile, callback : @escaping (AnyOperationResult) -> Void)
    
    func performSaveProfile(_ profile : Profile, callback :@escaping (AnyOperationResult) -> Void)
    
    func performLoadProfile(_ callback : @escaping (OperationResult<Profile>) -> Void)
	
	func performLogOutProfile(_ profile: Profile, callback: @escaping (AnyOperationResult) -> Void)
    
    func checkProfileRegistered() -> Bool
    
    func cacheProfileRegistration(_ profile : Profile)
    
    func clearCache()
	
	func saveCards(_ cards: [Card])
	func removeCard(_ card: Card)
	func selectPrimaryCard(_ card: Card)
}
