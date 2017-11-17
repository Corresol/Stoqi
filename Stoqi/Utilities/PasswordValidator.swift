struct PasswordValidator : Validator
{
	let failedMessage = "Password must have at least 1 large letter, 1 small, 1 digit and be at least 6 characters"
	
	func validate(_ value: Any?) -> Bool
	{
		guard let password = value as? String else
		{
			self.logUnsupportedType(value)
			return true
		}
		
		guard password.characters.count >= 6 else
		{
			return false
		}
		
		
		guard password.rangeOfCharacter(from: CharacterSet.decimalDigits, options: NSString.CompareOptions(), range: nil) != nil  else
		{
			return false
		}
		
		guard password.rangeOfCharacter(from: CharacterSet.letters, options: NSString.CompareOptions(), range: nil) != nil  else
		{
			return false
		}
		
		guard password.rangeOfCharacter(from: CharacterSet.uppercaseLetters, options: NSString.CompareOptions(), range: nil) != nil  else
		{
			return false
		}
		
		
		return true
	}
}
