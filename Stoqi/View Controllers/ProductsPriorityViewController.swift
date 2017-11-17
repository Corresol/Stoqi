import UIKit

class ProductsPriorityViewController : StandaloneViewController, QuestionEditor {
    
    @IBOutlet weak fileprivate var bPrice: UIButton!
    @IBOutlet weak fileprivate var bBrand: UIButton!
    @IBOutlet weak fileprivate var bMixed: UIButton!
    
    var delegate: QuestionEditorDelegate?
    var question : QuestionViewModel {
        get {
            return viewModel
        }
        set {
            viewModel = newValue as! ProductsPriorityQuestionViewModel
        }
    }
    
    fileprivate var viewModel : ProductsPriorityQuestionViewModel! {
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

// MARK: - Interactor
extension ProductsPriorityViewController {
    @IBAction func optionSelected(_ sender: UIButton) {
        
        switch sender {
        case self.bPrice: self.viewModel.priority = .price
        case self.bBrand: self.viewModel.priority = .brand
        case self.bMixed: self.viewModel.priority = .both
        default: break
        }
        
    }
}

// MARK: - Presenter
extension ProductsPriorityViewController {
    func configure(with dataSource: ProductsPriorityQuestionViewModel) {
        self.bPrice.isSelected = dataSource.priority == .price
        self.bBrand.isSelected = dataSource.priority == .brand
        self.bMixed.isSelected = dataSource.priority == .both
    }
}
