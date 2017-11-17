struct Address {
    let zip : String
    let street : String
    let building : String
    let latitude : Double?
    let longitude : Double?
    
    init(street : String,
         building : String,
         zip : String,
         latitude : Double? = 0,
         longitude : Double? = 0) {
        self.zip = zip
        self.street = street
        self.building = building
        self.latitude = latitude
        self.longitude = longitude
    }
}

func ===(a1 : Address, a2 : Address) -> Bool {
    return a1.zip == a2.zip &&
    a1.street == a2.street &&
    a1.building == a2.building
}

func !==(a1 : Address, a2 : Address) -> Bool {
    return !(a1 === a2)
}
