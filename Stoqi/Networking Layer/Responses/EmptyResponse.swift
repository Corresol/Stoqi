
/// Represents a response which contains no useful data.
/// - Parameter value: Optionally contains message.
struct EmptyResponse : Response {
    let request : Request
    let value: String
    
    init?(request: Request, body: AnyObject) {
        self.request = request
        self.value = String(describing: body)
    }
}
