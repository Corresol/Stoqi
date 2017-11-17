protocol HomeViewModel {
    var minDeliveryDate : Date {get}
    var maxDeliveryDate : Date {get}
    var userName : String {get}
    var totalSaved : Float {get}
    var monthlySavings : Float {get}
	var canRefill : Bool {get}
}
