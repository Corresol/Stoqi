struct UnionPayValidator : ProxyValidator {
	let proxyValidator : Validator = PatternValidator(pattern: "^(62|88)[0-9]{5,}$")
	let failedMessage = "This is not a valid UnionPay card"
}
