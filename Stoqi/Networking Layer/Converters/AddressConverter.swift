class AddressConverter : ResponseConverter<Address> {
    override func convert(_ dictionary: [String : AnyObject]) -> Address? {
        guard let street = dictionary["street"] as? String,
            let building = dictionary["streetNumber"] as? String,
            let zip = dictionary["zip"] as? String
            else {
                return nil
        }
        let latitude = (dictionary["latitude"] as? String).flatMap{Double($0)}
        let longitude = (dictionary["longitude"] as? String).flatMap{Double($0)}
        return Address(street: street,
                       building: building,
                       zip: zip,
                       latitude: latitude,
                       longitude: longitude)
    }
}
