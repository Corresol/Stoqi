struct Product : Identifiable {
    let id: Int?
    var category : Category!
    let kind : Kind
    let brand : Brand
    let volume : Volume
    let price : Float
}

func === (first : Product, second : Product) -> Bool {
    return  first.kind == second.kind &&
            first.brand == second.brand &&
            first.volume == second.volume &&
            first.category == second.category
}

func !== (first : Product, second : Product) -> Bool {
    return !(first === second)
}
