struct FindProductRequest : Request {
    let method = RequestMethod.get
    let url : String
    let parameters: [String : AnyObject]? = nil
    
    init(barcode : String) {
        url = "product/\(barcode)"
    }
}
