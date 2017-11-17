// TODO: Change it to store encrypted ids of the card instead of card info.
struct Card : Identifiable {
    let id: Int?
    let number : String
    let code : String
    let owner : String
    let month : Int
    let year : Int
	var isPrimary : Int
    
    init(id : Int,
         number : String,
         code : String,
         owner : String,
         month : Int,
         year : Int,
         isPrimary : Int) {
        self.id = id
        self.number = number
        self.code = code
        self.owner = owner
        self.month = month
        self.year = year
        self.isPrimary = isPrimary
    }
    
}
