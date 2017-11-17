/// TSTOOLS: 10/25/16.
class ResponseConverter <T> {
    func convert(_ dictionary : [String : AnyObject]) -> T? {return nil}
    
    func log(_ entity : AnyObject) {
        print("\(type(of: self)): Failed to parse: \n \(entity)")
    }
}

class RequestConverter <T> {
    func convert(_ model : T) -> [String : AnyObject]? { return nil }
}
