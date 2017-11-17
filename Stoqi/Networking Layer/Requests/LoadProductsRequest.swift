struct LoadProductsRequest : Request {
    let method = RequestMethod.get
    let url = "products"
    let parameters: [String : AnyObject]? = nil
}
