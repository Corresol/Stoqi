protocol UserInfoEditorDelegate {
	func editor(_ editor : UserInfoEditor, didEdit viewModel : UserInfoViewModel)
	func editorDidCancel(_ editor : UserInfoEditor)
}

protocol UserInfoEditor {
	var viewModel : UserInfoViewModel! {get}
	var delegate : UserInfoEditorDelegate? {get set}
	
	func setProfile(_ profile : Profile)
}



class ChangeUserInfoViewController: BaseViewController, UserInfoEditor {
	
	@IBOutlet weak fileprivate var tfName: TSTextField!
	@IBOutlet weak fileprivate var tfEmail: TSTextField!
	@IBOutlet weak fileprivate var tfPhone: TSTextField!
	@IBOutlet weak fileprivate var bChange: UIButton!
	
	fileprivate var previousTextFieldContent : String?
	fileprivate var previousSelection : UITextRange?
	
	static let segToProfile = "segToProfile"
	
	var viewModel: UserInfoViewModel!
	var delegate: UserInfoEditorDelegate?
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if viewModel != nil {
			configure(with: viewModel)
		}
	}
	
	func setProfile(_ profile: Profile) {
		viewModel = try! Injector.inject(UserInfoViewModel.self, with: profile)
		if isViewLoaded {
			configure(with: viewModel)
		}
	}

}


extension ChangeUserInfoViewController
{
	@IBAction func actionBack(_ sender: AnyObject)
	{
		self.delegate?.editorDidCancel(self)
	}
	
	
	@IBAction func actionChangeInfo(_ sender: AnyObject) {
		view.endEditing(true)
		
		if let text = viewModel.phone.value {
			let phone = text.replacingOccurrences(
				of: "[^\\d]", with: "", options: .regularExpression,
				range: text.startIndex..<text.endIndex)
			viewModel.phone.value = phone
		}
		
		if viewModel.isValid {
			delegate?.editor(self, didEdit: viewModel)
			performSegue(withIdentifier: ChangeUserInfoViewController.segToProfile, sender: self)
		} else {
			highlightErrors()
			TSNotifier.notify("Please, enter valid values",
			                  withAppearance: [kTSNotificationAppearancePositionYOffset : 16],
			                  on: presentingViewController?.view ?? view)
		}
	}
	
	@IBAction func editedAction(_ sender: TSTextField) {
		switch sender {
		case tfName: viewModel.name.value = sender.text
		case tfEmail: viewModel.email.value = sender.text
		case tfPhone: viewModel.phone.value = sender.text
		default:
			break
		}
		setView(sender, valid: true)
	}

}

extension ChangeUserInfoViewController : TSConfigurable {
	func configure(with dataSource: UserInfoViewModel) {
		tfName.text = dataSource.name.value
		tfEmail.text = dataSource.email.value
		tfPhone.text = dataSource.phone.value
		reformatAsPhoneNumber(tfPhone)
	}
	
	func highlightErrors() {
		[(tfName,   viewModel?.name.isValid),
			(tfEmail, viewModel?.email.isValid),
			(tfPhone,      viewModel?.phone.isValid)].forEach {
				setView($0.0, valid: $0.1 ?? true)
		}
	}
	
	func resetErrors() {
		[tfName, tfEmail, tfPhone].forEach {
			setView($0, valid: true)
		}
	}
}

extension ChangeUserInfoViewController : UITextFieldDelegate {
	@IBAction func reformatAsPhoneNumber(_ textField: UITextField) {
		var targetCursorPosition = 0
		if let startPosition = textField.selectedTextRange?.start {
			targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: startPosition)
		}
		
		var phoneNumberWithoutSpaces = ""
		if let text = textField.text {
			phoneNumberWithoutSpaces = self.removeNonDigits(text, andPreserveCursorPosition: &targetCursorPosition)
		}
		
		if phoneNumberWithoutSpaces.characters.count > 13 {
			textField.text = previousTextFieldContent
			textField.selectedTextRange = previousSelection
			return
		}
		
		let phoneNumberWithSpaces = self.insertPhoneMaskIntoString(phoneNumberWithoutSpaces, andPreserveCursorPosition: &targetCursorPosition)
		textField.text = phoneNumberWithSpaces
		
		if let targetPosition = textField.position(from: textField.beginningOfDocument, offset: targetCursorPosition) {
			textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
		}
	}
	
	func removeNonDigits(_ string: String, andPreserveCursorPosition cursorPosition: inout Int) -> String {
		var digitsOnlyString = ""
		let originalCursorPosition = cursorPosition
		
		for i in 0..<string.characters.count {
			let characterToAdd = string[string.characters.index(string.startIndex, offsetBy: i)]
			if characterToAdd >= "0" && characterToAdd <= "9" {
				digitsOnlyString.append(characterToAdd)
			}
			else if i < originalCursorPosition {
				cursorPosition -= 1
			}
		}
		
		return digitsOnlyString
	}
	
	func insertPhoneMaskIntoString(_ string: String, andPreserveCursorPosition cursorPosition: inout Int) -> String {
		var stringWithAddedSpaces = ""
		let cursorPositionInSpacelessString = cursorPosition

		for i in 0..<string.characters.count
		{
			if i == 0
			{
				stringWithAddedSpaces += "("
				if i < cursorPositionInSpacelessString {
					cursorPosition += 1
				}
			} else if (i == 2) {
				stringWithAddedSpaces += ") "
				if i < cursorPositionInSpacelessString {
					cursorPosition += 2
				}
			} else if (i == 7) {
				stringWithAddedSpaces += "-"
				if i < cursorPositionInSpacelessString {
					cursorPosition += 1
				}
			}
			
			
			let characterToAdd = string[string.characters.index(string.startIndex, offsetBy: i)]
			stringWithAddedSpaces.append(characterToAdd)
		}
		
		return stringWithAddedSpaces
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		previousTextFieldContent = textField.text;
		previousSelection = textField.selectedTextRange;
		return true
	}
}




