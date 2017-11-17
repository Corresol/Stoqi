struct DinersValidator : ProxyValidator {
	let proxyValidator : Validator = PatternValidator(pattern: "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$")
	let failedMessage = "This is not a valid Diners card"
}