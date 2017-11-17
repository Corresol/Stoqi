import MBCircularProgressBar

class MainViewController: BaseViewController {
    
    fileprivate static let segLogout = "segLogout"
	fileprivate static let segToStoqi = "segToStoqi"
	fileprivate static let segRegister = "segRegister"
    
    fileprivate let manager = try! Injector.inject(AuthorizationManager.self)
	fileprivate let productsManager = try! Injector.inject(ProductsManager.self)
    fileprivate let profileManager = try! Injector.inject(ProfileManager.self)
	fileprivate let requestsManager = try! Injector.inject(RequestsManager.self)
	fileprivate let analyticManager = try! Injector.inject(AnalyticManager.self)
    
    @IBOutlet weak fileprivate var lReplacementDate: UILabel!
    @IBOutlet weak fileprivate var lMonthlyAverage: UILabel!
    @IBOutlet weak fileprivate var lTotalSaved: UILabel!
    @IBOutlet weak fileprivate var lWelcome: UILabel!
	@IBOutlet weak fileprivate var lStoqi: UILabel!
	@IBOutlet weak var pvMainProggres: MBCircularProgressBarView!
 
    fileprivate var viewModel : HomeViewModel!
    
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		loadData()
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if analyticManager.analytic == nil
		{
			loadData()
		}
	}
	
	func loadData()
	{
		self.prepareStoqi(productsManager,
		                  profileManager: profileManager,
		                  requestsManager: requestsManager,
		                  analyticManager: analyticManager,
		                  completionSucces:{
							self.homeSetup()
							
							if !self.profileManager.checkProfileRegistered()
							{
								self.performSegue(withIdentifier: type(of: self).segRegister, sender: self)
							}
							
			}, completionFailure: {
				self.logoutAction(UIButton())
		})
	}
	
	func homeSetup()
	{
		guard let profile = profileManager.profile, let requests = requestsManager.requests else {
			print("FATAL ERROR: User data wasn't loaded!.")
			return
		}
		
		let analytic = analyticManager.analytic != nil ? analyticManager.analytic! : Analytic()
		
		self.viewModel = try! Injector.inject(HomeViewModel.self, with: HomeInjectionParameter(profile:  profile, requests: requests, analytic: analytic))
		self.configure(with: self.viewModel)
		Storage.temp[kStorageInitialSetup] = nil
	}
	
	@IBAction func onStoqi(_ sender: AnyObject)
	{
		if self.viewModel.canRefill
		{
			openYourList()
		}
		else
		{
			self.performSegue(withIdentifier: type(of: self).segToStoqi, sender: self)
		}
		
	}
	
	func openYourList()
	{
		guard let navController = (self.tabBarController as? StoqiTabBarController)?.openTab(StoqiTab.requests) as? UINavigationController, let controller = navController.viewControllers.last as? RequestsViewController  else {
			return
		}
		
		controller.openFirstList()
	}
}



// MARK: - Presenter
extension MainViewController : TSConfigurable {
    func configure(with dataSource: HomeViewModel) {
        self.lReplacementDate.text = "\(dataSource.minDeliveryDate.toString(withFormat: "dd MMM")) - \(dataSource.maxDeliveryDate.toString(withFormat: "dd MMM"))"
		
		let total = dataSource.maxDeliveryDate.timeIntervalSinceReferenceDate - dataSource.minDeliveryDate.timeIntervalSinceReferenceDate
		let progress = dataSource.maxDeliveryDate.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
		self.pvMainProggres.value = CGFloat(100 - (progress / (total / 100)))
		
        self.lTotalSaved.text = "R$ \(String(format:"%.2f", dataSource.totalSaved))"
        self.lMonthlyAverage.text = "R$ \(String(format:"%.2f", dataSource.monthlySavings))"
        self.lWelcome.text = "Hello, \(dataSource.userName)"
		self.lStoqi.text = dataSource.canRefill ? "Refill my" : "Check my"
    }
}

// MARK: - Controller 
private extension MainViewController {
    @IBAction func unwindProfile(_ segue : UIStoryboardSegue) {
        
    }
	
    @IBAction func logoutAction(_ sender: UIButton) {
//        let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        if self.btnStart != nil {
            self.btnStart.sendActions(for: .touchUpInside)
        }
        if self.profileManager.profile != nil {
            
            
            self.profileManager.performLogOutProfile(self.profileManager.profile!) { _ in }
            self.manager.performLogout { (_) in
                
            }
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
            
            //self.performSegueWithIdentifier(self.dynamicType.segLogout, sender: self)
        }
//        DispatchQueue.main.asyncAfter(deadline: delayTime) {
//        }
    }

}
