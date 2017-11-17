import GCDKit

class ListCreationViewController : BaseViewController {
    
    typealias Static = ListCreationViewController
    fileprivate static let segDone = "segDone"
    
    @IBOutlet weak fileprivate var bTryAgain: UIButton!
    @IBOutlet weak fileprivate var aiSaving: UIActivityIndicatorView!
	@IBOutlet weak fileprivate var imgViewList: UIImageView!
    
    fileprivate let manager = try! Injector.inject(ProfileManager.self)
    
    var profile : Profile!
    
    fileprivate var isError : Bool = false {
        didSet {
            if !self.isError {
                self.aiSaving?.startAnimating()
            } else {
                self.aiSaving?.stopAnimating()
            }
            self.bTryAgain?.isHidden = !self.isError
        }
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let gif = UIImage.gifImageWithName("gif_createList")
		imgViewList.image = gif
	}
	
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
		
		GCDQueue.main.after(5)
		{
			self.saveProfile()
		}
    }
}

// MARK: - Controller (ViewModel <=> DataManager)
private extension ListCreationViewController {
    func saveProfile() {
        self.isError = false
		if self.profile != nil
		{
			self.profile.initial = true
			self.manager.performCreateProfile(self.profile) {
				if case .success = $0 {
					self.manager.clearCache()
					self.performSegue(withIdentifier: Static.segDone, sender: self)
				} else if case let .failure(error) = $0 {
					self.isError = true
					self.showError(error, errorMessage: "Failed to save your list.".localized)
				}
			}
		}
		else
		{
			self.isError = true
			TSNotifier.notify("Failed to save your list.")
		}
	}
}

// MARK: - Interactor (View => ViewModel)
extension ListCreationViewController {
    @IBAction func tryAgainAction(_ sender: UIButton) {
        self.saveProfile()
    }
}
