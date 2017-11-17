import UIKit

class PropertyTypeViewController : StandaloneViewController, QuestionEditor {
    
    @IBOutlet weak fileprivate var bApartment: UIButton!
    @IBOutlet weak fileprivate var bHouse: UIButton!
    @IBOutlet weak fileprivate var bCommercial: UIButton!

    var delegate: QuestionEditorDelegate?
    var question : QuestionViewModel {
        get {
            return viewModel
        }
        set {
            viewModel = newValue as! PropertyTypeQuestionViewModel
        }
    }
    
    fileprivate var viewModel : PropertyTypeQuestionViewModel! {
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


// MARK: - Interactor (View => ViewModel)
private extension PropertyTypeViewController {
    @IBAction func optionSelected(_ sender: UIButton) {
        
        switch sender {
        case self.bApartment: self.viewModel.type = .apartment
        case self.bHouse: self.viewModel.type = .house
        case self.bCommercial: self.viewModel.type = .commercialRoom
        default: break
        }
    }
}

extension PropertyTypeViewController : TSConfigurable {
    func configure(with dataSource: PropertyTypeQuestionViewModel) {
        self.bHouse.isSelected = dataSource.type == .house
        self.bApartment.isSelected = dataSource.type == .apartment
        self.bCommercial.isSelected = dataSource.type == .commercialRoom
    }
}
