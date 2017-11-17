class UbiquitousStorageProvider : StorageProvider {
    fileprivate var storage = NSUbiquitousKeyValueStore.default()
    
    subscript(key : String) -> Any? {
        set {
//            if newValue == nil {
//                storage.set(nil, forKey: key)
//            } else if let newValue = newValue as? AnyObject {
//                storage.set(newValue, forKey: key)
//            } else {
//                print("\(type(of: self)): Value can't be stored.")
//            }
            storage.set(newValue, forKey: key)
        }
        get {
            return storage.object(forKey: key)
        }
    }
    
    func removeAll() {
        let keys = dictionary.keys
        for key in keys {
            storage.removeObject(forKey: key)
        }
        storage.synchronize()
    }
    
    
    var count: Int {
        get {
            return storage.dictionaryRepresentation.count
        }
    }
    
    var dictionary: [String : Any]{
        return storage.dictionaryRepresentation
    }
    
    deinit{
        storage.synchronize()
    }
}
