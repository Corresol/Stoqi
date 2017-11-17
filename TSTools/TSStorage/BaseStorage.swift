class BaseStorage : TSStorage {
    private let storage : StorageProvider
    
    var count : Int {
        get {
            return storage.count
        }
    }
    
    init(storage: StorageProvider){
        self.storage = storage
    }
    
    func saveObject(object: AnyObject, forKey key: String) {
        storage[key] = object
    }
    
    func loadObjectForKey(key: String) -> AnyObject? {
        return storage[key]
    }
    
    func popObjectForKey(key: String) -> AnyObject? {
        if let obj = self.loadObjectForKey(key) {
            self.removeObjectForKey(key)
            return obj
        }
        return nil
    }
    
    func removeObjectForKey(key: String) {
        storage[key] = nil
    }
    
    func removeAllObjects() {
        storage.removeAll()
    }
    
    func hasObjectForKey(key: String) -> Bool {
        return (self.loadObjectForKey(key) != nil)
    }
}