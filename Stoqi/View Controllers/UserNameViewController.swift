class UserNameViewController : StandaloneViewController, QuestionEditor {
 
    @IBOutlet weak var tfName: UITextField!
    
    var delegate: QuestionEditorDelegate?
    var question : QuestionViewModel {
        get {
            return viewModel
        }
        set {
            viewModel = newValue as! NameQuestionViewModel
        }
    }
    
    fileprivate var viewModel : NameQuestionViewModel! {
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

// MARK: - Controller
private extension UserNameViewController {
    
    @IBAction func fieldsEdited(_ sender: UITextField) {
        viewModel.name.value = sender.text
    }
}

// MARK: - Presenter
extension UserNameViewController : TSConfigurable {
    func configure(with dataSource: NameQuestionViewModel) {
        tfName.text = dataSource.name.value
    }
}
