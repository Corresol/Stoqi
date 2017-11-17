protocol CardEditorDelegate {
    func editor(_ editor : CardEditor, didEdit viewModel: EditableCardViewModel)
    func editorDidCancel(_ editor : CardEditor)
}

protocol CardEditor {
    var viewModel : EditableCardViewModel! {get}
    var delegate : CardEditorDelegate? {get set}
    func setCard(_ card : Card)
    func reset()
}

class AddCardViewController: StandaloneViewController, CardEditor {
    @IBOutlet weak fileprivate var tvNumber: UITextField!
    @IBOutlet weak fileprivate var tvName: UITextField!
    @IBOutlet weak fileprivate var tvCode: UITextField!
    @IBOutlet weak fileprivate var bMonth: TSOptionButton!
    @IBOutlet weak fileprivate var bYear: TSOptionButton!
    
    fileprivate var previousTextFieldContent : String?
    fileprivate var previousSelection : UITextRange?
    
    var viewModel : EditableCardViewModel! {
        didSet {
            if let viewModel = viewModel, isViewLoaded {
                configure(with: viewModel)
            }
        }
    }
    
    var delegate: CardEditorDelegate?
    
    func setCard(_ card: Card) {
        viewModel = try! Injector.inject(EditableCardViewModel.self, with: card)
    }
    
    func reset() {
        viewModel = try! Injector.inject(EditableCardViewModel.self)
    }
    
    fileprivate var monthPickerDataSource = try! Injector.inject(PickerDataSource.self, with: PickerInjectionParameter.monthsPicker)
    
    fileprivate var yearPickerDataSource = try! Injector.inject(PickerDataSource.self, with: PickerInjectionParameter.yearsPicker)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel == nil {
            viewModel = try! Injector.inject(EditableCardViewModel.self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let viewModel = viewModel {
            configure(with: viewModel)
        }
        resetErrors()
    }

}

// MARK: Card input formatting
extension AddCardViewController : UITextFieldDelegate {
    @IBAction func reformatAsCardNumber(_ textField: UITextField) {
        var targetCursorPosition = 0
        if let startPosition = textField.selectedTextRange?.start {
            targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: startPosition)
        }
        
        var cardNumberWithoutSpaces = ""
        if let text = textField.text {
            cardNumberWithoutSpaces = self.removeNonDigits(text, andPreserveCursorPosition: &targetCursorPosition)
        }
        
        if cardNumberWithoutSpaces.characters.count > 19 {
            textField.text = previousTextFieldContent
            textField.selectedTextRange = previousSelection
            return
        }
        
        let cardNumberWithSpaces = self.insertSpacesEveryFourDigitsIntoString(cardNumberWithoutSpaces, andPreserveCursorPosition: &targetCursorPosition)
        textField.text = cardNumberWithSpaces
        
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
    
    // TODO: Implement advanced card formatting (for acceptable card issuers)
    func insertSpacesEveryFourDigitsIntoString(_ string: String, andPreserveCursorPosition cursorPosition: inout Int) -> String {
        var stringWithAddedSpaces = ""
        let cursorPositionInSpacelessString = cursorPosition
        
        for i in 0..<string.characters.count {
            if i > 0 && (i % 4) == 0 {
                stringWithAddedSpaces += " "
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

extension AddCardViewController {
    
    @IBAction func optionTriggeredAction(_ sender: TSOptionButton) {
        view.endEditing(true)
        switch sender {
        case bMonth: openPicker(monthPickerDataSource, trigger: sender) { (index, item) in
            self.monthPickerDataSource.initialValue = item
            self.viewModel.month.value = (item as! MonthPickerItemViewModel).month
        }
        case bYear: openPicker(yearPickerDataSource, trigger: sender) { (index, item) in
            self.yearPickerDataSource.initialValue = item
            self.viewModel.year.value = (item as! YearPickerItemViewModel).year
            
        }
        default: break
        }
        setButton(sender, valid: true)
    }

    @IBAction func changeAction(_ sender: AnyObject) {
        view.endEditing(true)
        if viewModel.isValid {
            delegate?.editor(self, didEdit: viewModel)
        } else {
            highlightErrors()
            TSNotifier.notify("Please, enter valid values",
                              withAppearance: [kTSNotificationAppearancePositionYOffset : 16],
                              on: presentingViewController?.view ?? view)
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        view.endEditing(true)
        delegate?.editorDidCancel(self)
    }
    
    @IBAction func editedAction(_ sender: UITextField) {
        switch sender {
        case tvName: viewModel.owner.value = sender.text
        case tvNumber:
            if let text = sender.text {
                let card = text.replacingOccurrences(
                    of: "[^\\d]", with: "", options: .regularExpression,
                    range: text.startIndex..<text.endIndex)
                viewModel.number.value = card
            } else {
                viewModel.number.value = nil
            }
        case tvCode:
			if let text = sender.text{
				if text.characters.count < 5 {
					viewModel.code.value = sender.text
				} else {
					sender.text = text[text.startIndex...text.characters.index(text.startIndex, offsetBy: 3)]
				}
			}
        default: break
        }
        setView(sender, valid: true)
    }
}

extension AddCardViewController : TSConfigurable {
    func configure(with dataSource: EditableCardViewModel) {
        tvNumber.text = dataSource.number.value
        reformatAsCardNumber(tvNumber)
        tvName.text = dataSource.owner.value
        tvCode.text = dataSource.code.value
        bMonth.setTitle(dataSource.month.value.map{String(format:"%02d", $0)}, for: UIControlState())
        bYear.setTitle(dataSource.year.value.map{String(format:"%02d", $0)}, for: UIControlState())
    }
    
    func highlightErrors() {
        [(tvNumber, viewModel?.number.isValid),
         (tvCode,   viewModel?.code.isValid),
         (tvName,   viewModel?.owner.isValid)].forEach {
            setView($0.0, valid: $0.1 ?? true)
        }
        [(bMonth, viewModel?.month.isValid),
         (bYear,  viewModel?.year.isValid)].forEach {
            setButton($0.0, valid: $0.1 ?? true)
        }
    }
    
    func resetErrors() {
        [tvNumber, tvCode, tvName].forEach {
            setView($0, valid: true)
        }
        [bMonth, bYear].forEach {
            setButton($0, valid: true)
        }
    }
    
    func setButton(_ button : UIButton, valid : Bool) {
        setView(button, valid: valid, validColor: StoqiPallete.mainColor)
    }
    
    
}
