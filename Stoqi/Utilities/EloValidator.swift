struct EloValidator : ProxyValidator {
	let proxyValidator : Validator = PatternValidator(pattern: "^((((636368)|(438935)|(504175)|(451416)|(636297))[0-9]{0,10})|((5067)|(4576)|(4011))[0-9]{0,12})$")
	let failedMessage = "This is not a valid Elo card"
}
