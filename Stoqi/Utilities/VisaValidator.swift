struct VisaValidator : ProxyValidator {
    let proxyValidator : Validator = PatternValidator(pattern: "^4[0-9]{6,}$")
    let failedMessage = "This is not a valid Visa card"
}