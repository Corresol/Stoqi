///  Created by AdYa on 9/20/16.


extension String {
    func convertToDictionary() -> [String:AnyObject]? {
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    func rangesOfString(_ searchString:String, options: NSString.CompareOptions = [], searchRange:Range<Index>? = nil ) -> [Range<Index>] {
        if let range = self.range(of: searchString, options: options, range:searchRange) {
            let nextRange = (range.upperBound..<self.endIndex)
            return [range] + rangesOfString(searchString, searchRange: nextRange)
        } else {
            return []
        }
    }
    
}
