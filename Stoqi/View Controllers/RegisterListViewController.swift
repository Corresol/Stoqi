import UIKit

class RegisterListViewController : TSPageViewController {
    
    typealias `Self` = RegisterListViewController
    fileprivate static let segCreateList = "segCreateList"
	fileprivate static let segLogin = "segToLogin"
	
    
    fileprivate let manager = try! Injector.inject(ProfileManager.self)
    
    typealias QuestionPage = (controller : StandaloneViewController.Type,
                            question : () -> QuestionViewModel)
    
    fileprivate var pages : [QuestionPage]!
    fileprivate var defaults = UserDefaults.standard
    
    @IBOutlet weak fileprivate var bNext: UIButton!
    @IBOutlet weak fileprivate var bBack: UIButton!
    @IBOutlet weak fileprivate var lTitle: UILabel!
    
    
    var viewModel : ProfileViewModel! {
        didSet {
            update()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        pageControllerDelegate = self
        pageControl?.indicatorViewType = TSPageControlIndicatorType.custom(delegate: { (index) -> UIView in
            let view = RegisterListIndicatorView(title: String(index + 1), defaultColor: UIColor.clear, activeColor: StoqiPallete.mainLightColor)
            view.textColor = UIColor.white
            view.textAlignment = .center
            return view
        })
        pages = [
            QuestionPage(controller: UserNameViewController.self, question: {self.viewModel.name}),
            QuestionPage(controller: PropertyLocationViewController.self,
                question: {self.viewModel.locationQuestion}),
            QuestionPage(controller: PropertyTypeViewController.self,
                question: {self.viewModel.propertyTypeQuestion}),
            QuestionPage(controller: PropertyAreaViewController.self,
                question: {self.viewModel.propertyAreaQuestion}),
            QuestionPage(controller: PropertyResidentsViewController.self,
                question: {self.viewModel.propertyResidentsQuestion}),
            QuestionPage(controller: ProductsPriorityViewController.self,
                question: {self.viewModel.productsPriorityQuestion})
        ]
        if let profile = manager.profile {
            viewModel = try! Injector.inject(ProfileViewModel.self, with: profile)
        } else {
            viewModel = try! Injector.inject(ProfileViewModel.self)
        }
        
        setPages(withIdentifiers: pages.map{$0.controller.identifier})
        checkCachedQuestions()
//        if (defaults.valueForKey("CURRENT_INDEX")) != nil
//        {
//            let cIndex = self.defaults.integerForKey("CURRENT_INDEX")
//            self.showPage(atIndex: cIndex)
//        }
        
    }	
    
    fileprivate func update() {
        guard let id = currentIdentifier,
            let dataSource = pages.filter({$0.controller.identifier == id}).first?.question() else {
            print("Couldn't get question.")
            return
        }
        configure(with: dataSource)
    }
    
    override func pageControl(_ pageControl: TSPageControl, customizeIndicatorView view: UIView, atIndex index: Int) {
        view.circle = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier, id == Self.segCreateList else {
            return
        }
        
        guard let controller = segue.destination as? ListCreationViewController else {
            return
        }
    
        guard let profile = viewModel.profile else {
            print("Profile is not valid.")
            return
        }
        controller.profile = profile
    }
    
    fileprivate func checkCachedQuestions() {
        if !viewModel.name.isValid {
            showPage(withIdentifier: UserNameViewController.identifier)
        } else if !viewModel.locationQuestion.isValid {
            showPage(withIdentifier: PropertyLocationViewController.identifier)
        } else if !viewModel.propertyTypeQuestion.isValid {
            showPage(withIdentifier: PropertyTypeViewController.identifier)
        } else if !viewModel.propertyAreaQuestion.isValid {
            showPage(withIdentifier: PropertyAreaViewController.identifier)
        } else if !viewModel.propertyResidentsQuestion.isValid {
            showPage(withIdentifier: PropertyResidentsViewController.identifier)
        } else {
            showPage(withIdentifier: ProductsPriorityViewController.identifier)
        }
    }
    
    func saveQuestion(_ question : QuestionViewModel) {
        if let question = question as? NameQuestionViewModel {
            viewModel.name = question
        } else if let question = question as? PropertyLocationQuestionViewModel {
            viewModel.locationQuestion = question
        } else if let question = question as? PropertyAreaQuestionViewModel {
            viewModel.propertyAreaQuestion = question
        } else if let question = question as? PropertyTypeQuestionViewModel {
            viewModel.propertyTypeQuestion = question
        } else if let question = question as? PropertyResidentsQuestionViewModel {
            viewModel.propertyResidentsQuestion = question
        } else if let question = question as? ProductsPriorityQuestionViewModel {
            viewModel.productsPriorityQuestion = question
        } else {
            print("\(type(of: self)): Unable to determine QuestionEditor's QuestionViewModel type.")
        }
    }
}

extension RegisterListViewController : QuestionEditorDelegate {
    func questionEditor(_ editor: QuestionEditor, didEditQuestion question: QuestionViewModel) {
        saveQuestion(question)
        configure(with: question)
    }
}

// MARK: - Controller
extension RegisterListViewController {
	
	@IBAction func unwindRegistration(_ segue : UIStoryboardSegue) {
	}
	
    @IBAction fileprivate func back(_ sender: UIButton) {
		if currentIndex == 0
		{
			performSegue(withIdentifier: Self.segLogin, sender: self)
		}
		else
		{
			showPrevPage()
		}
    }
    
    @IBAction fileprivate func nextQuestion(_ sender: AnyObject) {
        
        var pf : Profile = (viewModel?.profile)!
        if pf.address == nil {
            pf.address = Address(street : "",
                                 building : "",
                                 zip : "",
                                 latitude : 0,
                                 longitude : 0)
        }
        
        if pf.primaryCard == nil {
//            pf.primaryCard = Card(id : 0,
//                                  number : "",
//                                  code : "",
//                                  owner : "",
//                                  month : 0,
//                                  year : 0,
//                                  isPrimary : 0)
        }
        if pf.cards == nil {
            pf.cards = []
        }
        
        if pf.location == nil {
            pf.location = PropertyLocation(id : 0,
                                           cityName : "",
                                           regionName : "")}
        
        if pf.propertyType == nil {
            pf.propertyType = .apartment
        }
        
        if pf.propertyArea == nil {
            pf.propertyArea = PropertyArea(area : 0, rooms : 0, knownArea : false)
        }
        if pf.propertyResidents == nil {
            pf.propertyResidents = PropertyResidents(adults : 0, children : 0, pets : 0)
        }
        if pf.priority == nil { pf.priority = .price }
        if pf.phone == nil { pf.phone = "" }
        
        if let profile : Profile = pf {
            manager.cacheProfileRegistration(profile)
        }
        if currentIndex == pages.count - 1 {
            performSegue(withIdentifier: Self.segCreateList, sender: self)
        } else {
            showNextPage()
        }
    }
}

// MARK: - Presenter
extension RegisterListViewController : TSConfigurable {
    func configure(with dataSource: QuestionViewModel) {
        let nextTitle : String
        switch currentIndex {
        case pages.count - 1: nextTitle = "Create my list"
        case pages.count - 2: nextTitle = "Last Question"
        default: nextTitle = "Next Question"
        }
        lTitle.text = dataSource.question
        bNext.setTitle(nextTitle, for: UIControlState())
		if currentIndex == pages.count - 1
		{
			bNext.isEnabled = pages.reduce(true){
				$0 && $1.question().isValid
			}
		}
		else
		{
			bNext.isEnabled = dataSource.isValid
		}
    }
}

// MARK: - Page Controller customization.
extension RegisterListViewController : TSPageViewControllerDelegate {
    
    func pageController(_ pageController: TSPageViewController, instantiateViewControllerWithIdentifier identifier: String) -> UIViewController {
        let controller : UIViewController
        if identifier == PropertyLocationViewController.identifier {
            controller = UIStoryboard(name: identifier, bundle: Bundle.main).instantiateInitialViewController()!
        } else {            
            controller = pages.filter{$0.controller.identifier == identifier}.first!.controller.init()
        }
        
        if let page = controller as? QuestionEditor {
            page.delegate = self
            page.question = pages.filter{$0.controller.identifier == identifier}.first!.question()
        }
        return controller
    }
    
    func pageController(_ pageController: TSPageViewController, didShowViewController controller: UIViewController, forPageAtIndex index: Int) {
        update()
        UserDefaults.standard.set(index, forKey: "CURRENT_INDEX")
    }
    
   
}
