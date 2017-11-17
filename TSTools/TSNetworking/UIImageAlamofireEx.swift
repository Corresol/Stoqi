import AlamofireImage
import Alamofire

/// TSTOOLS: Move this to separate file since it relies on AlamofireImage framework
extension UIImage {
    
    typealias ImageLoaderCallback = (_ image : UIImage?) -> Void
    
    class func fromUri(_ uri : String, callback : @escaping ImageLoaderCallback) {
        print("\(type(of: self)): Downloading image at '\(uri)'...")
        Alamofire.request(uri).responseImage {
            if let img = $0.result.value {
                print("\(type(of: self)): Image downloaded successfully (\(uri))")
                callback(img)
            } else {
                print("\(type(of: self)): Image downloaded failed (\(uri))")
                callback(nil)
            }
        }
    }
}
