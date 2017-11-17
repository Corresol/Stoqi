class PropertyAreaViewController : StandaloneViewController, QuestionEditor {
   
    @IBOutlet weak fileprivate var lArea: UILabel!
    @IBOutlet weak fileprivate var lRooms: UILabel!
    @IBOutlet weak fileprivate var bKnownSize: UIButton!
    @IBOutlet weak fileprivate var sArea: UIStepper!
    @IBOutlet weak fileprivate var sRooms: UIStepper!
    @IBOutlet weak fileprivate var lRoomsLabel: UILabel!
    
    var delegate: QuestionEditorDelegate?
    var question : QuestionViewModel {
        get {
            return viewModel
        }
        set {
            viewModel = newValue as! PropertyAreaQuestionViewModel
        }
    }
    
    fileprivate var viewModel : PropertyAreaQuestionViewModel! {
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
extension PropertyAreaViewController : TSConfigurable {
    func configure(with dataSource: PropertyAreaQuestionViewModel) {
        self.lArea.text = (dataSource.knownSize.value ?? true) ? "\(dataSource.size.value ?? 0)" : "--" // m²
        self.lRooms.text = "\(dataSource.rooms.value ?? 0)"
        self.lRoomsLabel.text = (dataSource.rooms.value ?? 0) == 1 ? "Room" : "Rooms"
        self.bKnownSize.isSelected = !(dataSource.knownSize.value ?? true)
        self.sArea.value = Double(dataSource.size.value ?? 0)
        self.sRooms.value = Double(dataSource.rooms.value ?? 0)
        self.sArea.isEnabled = dataSource.knownSize.value ?? true
    }
}

// MARK: - Controller (View => ViewModel)
private extension PropertyAreaViewController {
    @IBAction func unknownAreaTouched(_ sender: UIButton) {
        self.viewModel.knownSize.value = !(self.viewModel.knownSize.value ?? true)
    }
    
    @IBAction func stepperChanged(_ sender: UIStepper) {
        switch sender {
        case self.sArea: self.viewModel.size.value = Int(sender.value)
        case self.sRooms: self.viewModel.rooms.value = Int(sender.value)
        default: break
        }
    }
}
