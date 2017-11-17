class CardConverter : ResponseConverter<Card> {
    override func convert(_ dictionary: [String : AnyObject]) -> Card? {
        guard let name = (dictionary["name"] as? NSString).flatMap({String($0)}),
				let id = (dictionary["id"] as? Int).flatMap({Int($0)}),
				let isPrimary = (dictionary["isPrimary"] as? Int).flatMap({Int($0)}),
				let lastDigits = (dictionary["lastDigits"] as? Int).flatMap({Int($0)}),
                let month = (dictionary["expiryMonth"] as? Int).flatMap({Int($0)}),
                let year = (dictionary["expiryYear"] as? Int).flatMap({Int($0)})
        else {
            return nil
        }
        // TODO: parse code
		return Card(id: id, number: lastDigits.description, code: "", owner: name, month: month, year: year, isPrimary: isPrimary)
    }
}
