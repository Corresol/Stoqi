enum RequestStatus {
	case notAutorized(from: Date, to: Date)
	case autorized(from: Date, to: Date, autOn: Date)
	case purchased(from: Date, to: Date, purchOn: Date)
	case inDelivering(from: Date)
	case delivered(date: Date)
}

struct RequestList : Identifiable {
    let id : Int?
    var products : [ProductEntry]? {
        didSet {
           self.updateProductsMetrics()
        }
    }
    var status : RequestStatus
    fileprivate(set) var total : Float
    fileprivate(set) var count : Int
    
    fileprivate mutating func updateProductsMetrics() {
        if let products = self.products {
            self.total = products.reduce(0.0) {$0.0 + $0.1.product.price * Float($0.1.units)}
            self.count = products.count
        }
    }
    
    init(id : Int?, products : [ProductEntry]? = nil, status : RequestStatus, total : Float = 0, count : Int = 0) {
        self.id = id
        self.status = status
        self.total = total
        self.count = count
        self.products = products
        self.updateProductsMetrics()
    }
}
