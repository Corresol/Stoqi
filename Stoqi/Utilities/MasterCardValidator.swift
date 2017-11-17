struct MasterCardValidator : ProxyValidator {
    let proxyValidator : Validator = PatternValidator(pattern: "^(5[1-5][0-9]{4}|677189)[0-9]{5,}$") ///"^5[1-5][0-9]{5,}|222[1-9][0-9]{3,}|22[3-9][0-9]{4,}|2[3-6][0-9]{5,}|27[01][0-9]{4,}|2720[0-9]{3,}$")
    let failedMessage = "This is not a valid MasterCard card"
}