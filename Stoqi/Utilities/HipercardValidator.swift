struct HipercardValidator : ProxyValidator {
	let proxyValidator : Validator = PatternValidator(pattern: "^(606282|3841)[0-9]{5,}$")
	let failedMessage = "This is not a valid Hipercard card"
}
