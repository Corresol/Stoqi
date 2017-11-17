struct Category : Identifiable {
    let id: Int?
    let name : String
    
    init(id : Int? = nil, name : String) {
        self.id = id
        self.name = name
    }
    
    init() {
        self.init(name: "")
    }
}