struct JCB15Validator : ProxyValidator {
	let proxyValidator : Validator = PatternValidator(pattern: "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$")
	let failedMessage = "This is not a valid JCB15 card"
}
