
/// Account used to authorize API calls.
struct Account : Identifiable {
    
    var id : Int? = 0
    var email : String? = ""
    var facebookToken : String? = ""
    
    init(id : Int? = 0, email : String? = "", facebookToken : String? = "") {
        self.id = id
        self.facebookToken = facebookToken
        self.email = email
    }
}

private enum ArchiveKeys : String {
    case Id = "kAccountId"
    case Email = "kAccountEmail"
    case Token = "kAccountToken"
}

extension Account : Archivable {
    func archived() -> [String : AnyObject] {
        var dic = [String : AnyObject]()
        dic[ArchiveKeys.Id.rawValue] = id as AnyObject
        dic[ArchiveKeys.Email.rawValue] = email as AnyObject
        dic[ArchiveKeys.Token.rawValue] = facebookToken as AnyObject
        return dic
    }
    
    init?(fromArchive archive: [String : AnyObject]) {
        let id = archive[ArchiveKeys.Id.rawValue] as? Int
        let token = archive[ArchiveKeys.Token.rawValue] as? String
        let email = archive[ArchiveKeys.Email.rawValue] as? String
        self.init(id: id, email: email, facebookToken: token)
    }
}
