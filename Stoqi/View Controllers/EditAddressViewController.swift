protocol AddressEditorDelegate {
    func editor(_ editor : AddressEditor, didEdit viewModel : AddressViewModel)
    func editorDidCancel(_ editor : AddressEditor)
}

protocol AddressEditor {
    var viewModel : AddressViewModel! {get}
    var delegate : AddressEditorDelegate? {get set}
    
    func setAddress(_ address : Address)
}

class EditAddressViewController: StandaloneViewController, AddressEditor {
    @IBOutlet weak var tvStreet: TSTextField!
    @IBOutlet weak var tvBuilding: TSTextField!
    @IBOutlet weak var tvZip: TSTextField!
    
    var viewModel: AddressViewModel! {
        didSet {
            if let viewModel = viewModel, isViewLoaded {
                configure(with: viewModel)
            }
        }
    }
    
    var delegate: AddressEditorDelegate?
    
    func setAddress(_ address: Address) {
        viewModel = try! Injector.inject(AddressViewModel.self, with: address)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel == nil {
            viewModel = try! Injector.inject(AddressViewModel.self)
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

private extension EditAddressViewController {
    @IBAction func saveAction(_ sender: UIButton) {
        view.endEditing(true)
        if viewModel.isValid {
            delegate?.editor(self, didEdit: viewModel)
        } else {
            highlightErrors()
            TSNotifier.notify("Please, enter valid values",
                              withAppearance: [kTSNotificationAppearancePositionYOffset : 16, kTSNotificationAppearancePosition : TSNotificationPosition.NOTIFICATION_POSITION_CENTER_CENTER.rawValue],
                              on: presentingViewController?.view ?? view)
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        view.endEditing(true)
        delegate?.editorDidCancel(self)
    }
    @IBAction func editedAction(_ sender: TSTextField) {
        switch sender {
        case tvStreet: viewModel.street.value = sender.text
        case tvBuilding: viewModel.building.value = sender.text
        case tvZip: viewModel.zip.value = sender.text
        default:
            break
        }
        setView(sender, valid: true)
    }
}

extension EditAddressViewController : TSConfigurable {
    func configure(with dataSource: AddressViewModel) {
        tvStreet.text = dataSource.street.value
        tvBuilding.text = dataSource.building.value
        tvZip.text = dataSource.zip.value
    }
    
    func highlightErrors() {
        [(tvStreet,   viewModel?.street.isValid),
         (tvBuilding, viewModel?.building.isValid),
         (tvZip,      viewModel?.zip.isValid)].forEach {
            setView($0.0, valid: $0.1 ?? true)
        }
    }
    
    func resetErrors() {
        [tvStreet, tvBuilding, tvZip].forEach {
            setView($0, valid: true)
        }
    }
}
