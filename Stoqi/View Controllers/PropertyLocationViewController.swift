import UIKit

class PropertyLocationViewController : StandaloneViewController, QuestionEditor {
    
    @IBOutlet weak fileprivate var vHolder: UIView!
    @IBOutlet weak fileprivate var lCity: UILabel!
    @IBOutlet weak fileprivate var lRegion: UILabel!
    var location11 : PropertyLocation?
    
    var delegate: QuestionEditorDelegate?
    var question : QuestionViewModel {
        get {
            return self.viewModel
        }
        set {
            self.viewModel = newValue as! PropertyLocationQuestionViewModel
        }
    }
    
    fileprivate var viewModel : PropertyLocationQuestionViewModel! {
        didSet {
            guard isViewLoaded else {
                return
            }
            self.viewModel.location = location11
            self.configure(with: self.viewModel)
            delegate?.questionEditor(self, didEditQuestion: question)
        }
    }
    
    override func viewWillAppear(_ animated : Bool) {
        super.viewWillAppear(animated)
        configure(with: self.viewModel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.vHolder.circle = true // reset circle to recalculate cornerRadius since vHolder will be dynamically resized based on constraints.
    }

    @IBAction func unwindSelectedCity(_ segue : UIStoryboardSegue) {
        if let controller = segue.source as? SearchPropertyLocationViewController,
            let selectedViewModel = controller.selectedViewModel {
            location11 = selectedViewModel.location
            self.viewModel = try! Injector.inject(PropertyLocationQuestionViewModel.self, with: selectedViewModel.location)
            self.viewModel.location = selectedViewModel.location
        }
    }
}

// MARK: - Presenter (ViewModel => View)
extension PropertyLocationViewController : TSConfigurable {
    func configure(with dataSource: PropertyLocationQuestionViewModel) {
        if let city = dataSource.city,
            let region = dataSource.region {
            self.lCity.text = city
            self.lRegion.text = region
        }
    }
}
