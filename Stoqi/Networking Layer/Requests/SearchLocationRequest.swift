struct SearchLocationRequest : Request {
    let method = RequestMethod.get
    let url = "searchlocation"
    let parameters: [String : AnyObject]?
    
    init(term : String) {
        self.parameters = ["term" : term as AnyObject]
    }
}
