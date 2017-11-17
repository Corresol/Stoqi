struct JCBValidator : ProxyValidator {
	let proxyValidator : Validator = PatternValidator (pattern: "^(?:2131|1800|35\\d{3})\\d{11}$")
	let failedMessage = "This is not a valid JCB card"
}
