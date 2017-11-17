struct DiscoverValidator : ProxyValidator {
	let proxyValidator : Validator = PatternValidator(pattern: "^6(?:011|5[0-9]{2})[0-9]{3,}$")
	let failedMessage = "This is not a valid Discover card"
}
