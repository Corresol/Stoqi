class EditQuestionViewController : EmbedingViewController, QuestionEditor {
    fileprivate static let segClose = "segClose"
    
    @IBOutlet weak fileprivate var lQuestion : UILabel!
    @IBOutlet weak fileprivate var bChange: UIButton!
   
    fileprivate var editor : QuestionEditor!
    
    var delegate: QuestionEditorDelegate?
    var question: QuestionViewModel {
        get {
            return editor.question
        }
        set {
            if newValue is PropertyLocationQuestionViewModel {
                editor = UIStoryboard(name: PropertyLocationViewController.identifier, bundle: nil).instantiateInitialViewController() as?  PropertyLocationViewController
                //createQuestionViewController(PropertyLocationViewController.self)
            } else if newValue is PropertyAreaQuestionViewModel {
                editor = PropertyAreaViewController.self.init()
                    //createQuestionViewController(PropertyAreaViewController.self)
            } else if newValue is PropertyTypeQuestionViewModel {
                editor = PropertyTypeViewController.self.init()
                    //createQuestionViewController(PropertyTypeViewController.self)
            } else if newValue is PropertyResidentsQuestionViewModel {
                editor = PropertyResidentsViewController.self.init()
                //createQuestionViewController(PropertyResidentsViewController.self)
            } else if newValue is ProductsPriorityQuestionViewModel {
                editor = ProductsPriorityViewController.self.init()
                    //createQuestionViewController(ProductsPriorityViewController.self)
            } else {
                editor = nil
                print("No suitable ViewController found for question \(type(of: newValue))")
            }
            editor.question = newValue
            editor.delegate = self
        }
    }
    
//    fileprivate func createQuestionViewController<T>(_ controllerType : T.Type) -> T? where T : StandaloneViewController, T : QuestionEditor {
//        
//        if controllerType == PropertyLocationViewController.self {
//            return UIStoryboard(name: PropertyLocationViewController.identifier, bundle: nil).instantiateInitialViewController() as? T
//        } else {
//            return controllerType.init()
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let questionPage = editor as! UIViewController
        _ = embed(questionPage)
        configure(with: question)
    }
    
}

extension EditQuestionViewController : QuestionEditorDelegate {
    func questionEditor(_ editor: QuestionEditor, didEditQuestion question: QuestionViewModel) {
        configure(with: question)
        delegate?.questionEditor(self, didEditQuestion: question)
    }
    
    func saveQuestion() {
        performSegue(withIdentifier: type(of: self).segClose, sender: self)
    }
}

// MARK: - Controller
private extension EditQuestionViewController {
    @IBAction func changeAction(_ sender: UIButton) {
        saveQuestion()
    }
}

// MARK: - Presenter
extension EditQuestionViewController : TSConfigurable {
    func configure(with dataSource: QuestionViewModel) {
        lQuestion.text = dataSource.question
        bChange.isEnabled = dataSource.isValid
    }
}
