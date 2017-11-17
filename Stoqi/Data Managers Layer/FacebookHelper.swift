import FBSDKLoginKit
import FBSDKCoreKit

enum FacebookResult {
    case authorized(token : String)
    case canceled
    case failed
}

class FacebookHelper {
    class func authorizeFacebook(fromViewController controller: UIViewController, callback : @escaping ( FacebookResult) -> Void) {
        let fb = FBSDKLoginManager()
        fb.logIn(withReadPermissions: ["email", "public_profile"], from: controller) { (result, error) in
            guard let result = result else {
                callback(.failed)
                return
            }
            
            guard !result.isCancelled else {
                callback(.canceled)
                return
            }
            
            let token = result.token.tokenString
            callback(.authorized(token: token!))
        }
    }
    
    class func getUser(_ callback : @escaping (OperationResult<(name : String, email : String)>) -> Void) {
        guard let token = FBSDKAccessToken.current() else {
            callback(.failure(.notAuthorized))
            return
        }
        
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "name, email"], tokenString: token.tokenString, version: nil, httpMethod: "GET").start { (_, res, _) in
            let result : [String:AnyObject] = res as! [String : AnyObject]
            guard let name = result["name"] as? String,
            let email = result["email"] as? String else {
                callback(.failure(.invalidResponse))
                return
            }
            callback(.success(name: name, email: email))
        }
    }
}
