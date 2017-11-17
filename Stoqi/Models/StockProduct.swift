struct StockProduct : Identifiable {
    var id : Int? {
        return product.id
    }
    
    var product : Product
    var left : Float
    let total : Float
	var confirmed : Bool
}