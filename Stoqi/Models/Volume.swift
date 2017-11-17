struct Volume : Identifiable {
    let id : Int?
    let name : String
    let volume : Float
    let unit : String
}

func === (first : Volume, second : Volume) -> Bool {
    return  first.name == second.name &&
        first.volume == second.volume &&
        first.unit == second.unit
}

func !== (first : Volume, second : Volume) -> Bool {
    return !(first === second)
}