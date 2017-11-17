class AccountConverter : ResponseConverter<Account> {
    override func convert(_ dictionary: [String : AnyObject]) -> Account? {
        guard let id = (dictionary["userId"] as? String).flatMap({Int($0)}) else { // jesus helped me to write this line to handle Int value since it was there as NSTaggedPointerString..
            return nil
        }
        return Account(id: id)
    }
}
