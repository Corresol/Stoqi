struct AMEXValidator : ProxyValidator {
    let proxyValidator : Validator = PatternValidator(pattern: "^3[47][0-9]{5,}$")
    let failedMessage = "This is not a valid American Express card"
}