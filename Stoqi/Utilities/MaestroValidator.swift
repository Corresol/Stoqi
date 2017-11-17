struct MaestroValidator : ProxyValidator {
	let proxyValidator : Validator = PatternValidator(pattern: "^(?:5[0678]\\d\\d|6304|6390|67\\d\\d)\\d{8,15}$")
	let failedMessage = "This is not a valid Maestro card"
}
