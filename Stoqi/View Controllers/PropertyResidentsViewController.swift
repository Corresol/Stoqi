class PropertyResidentsViewController : StandaloneViewController, QuestionEditor {
    
    @IBOutlet weak fileprivate var lAdults: UILabel!
    @IBOutlet weak fileprivate var lChildren: UILabel!
    @IBOutlet weak fileprivate var lPets: UILabel!
    @IBOutlet weak fileprivate var sAdults: UIStepper!
    @IBOutlet weak fileprivate var sChildren: UIStepper!
    @IBOutlet weak fileprivate var sPets: UIStepper!
    @IBOutlet weak fileprivate var lAdultsLabel: UILabel!
    @IBOutlet weak fileprivate var lChildrenLabel: UILabel!
    @IBOutlet weak fileprivate var lPetsLabel: UILabel!
    
    var delegate: QuestionEditorDelegate?
    var question : QuestionViewModel {
        get {
            return viewModel
        }
        set {
            viewModel = newValue as! PropertyResidentsQuestionViewModel
        }
    }
    
    fileprivate var viewModel : PropertyResidentsQuestionViewModel! {
        didSet {
            guard isViewLoaded else {
                return
            }
            self.configure(with: viewModel)
            delegate?.questionEditor(self, didEditQuestion: viewModel)
        }
    }
    
    override func viewWillAppear(_ animated : Bool) {
        super.viewWillAppear(animated)
        configure(with: viewModel)
    }
}

// MARK: - Presenter (ViewModel => View)
extension PropertyResidentsViewController : TSConfigurable {
    
    func configure(with dataSource: PropertyResidentsQuestionViewModel) {
        self.lAdults.text = "\(dataSource.adults.value ?? 0)"
        self.lChildren.text = "\(dataSource.children.value ?? 0)"
        self.lPets.text = "\(dataSource.pets.value ?? 0)"
        self.sAdults.value = Double(dataSource.adults.value ?? 0)
        self.sChildren.value = Double(dataSource.children.value ?? 0)
        self.sPets.value = Double(dataSource.pets.value ?? 0)
        
        self.lAdultsLabel.text = dataSource.adults.value ?? 0 == 1 ? "Adult" : "Adults"
        self.lChildrenLabel.text = dataSource.children.value ?? 0 == 1 ? "Child" : "Children"
        self.lPetsLabel.text = dataSource.pets.value ?? 0 == 1 ? "Dog / Cat" : "Dogs / Cats"
    }
}

// MARK: - Interactor (View => ViewModel)
private extension PropertyResidentsViewController {
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        let value = Int(sender.value)
        switch sender {
        case self.sAdults: self.viewModel.adults.value = value
        case self.sChildren: self.viewModel.children.value = value
        case self.sPets: self.viewModel.pets.value = value
        default: break
        }
    }
}
