import GCDKit

let kStorageInitialSetup = "kStorageInitialSetup"
let kStorageInitialBuy = "kStorageInitialBuy"

class PurchaseViewController : BaseViewController {
    
    typealias `Self` = PurchaseViewController
    fileprivate static let segInitialClose = "segClose"
    fileprivate static let segSubsequentClose = "segCancel"
    fileprivate static let segInitialBuy = "segClose"
    fileprivate static let segSubsequentBuy = "segBuy"
	fileprivate static let segToCards = "segToCards"
	fileprivate static let segToAddress = "segToAddress"
	fileprivate static let segRegisterToCards = "segRegisterToCards"
	fileprivate static let segRegisterToProfile = "segRegisterToProfile"
	
    
    fileprivate var manager = try! Injector.inject(RequestsManager.self)
	fileprivate let profileManager = try! Injector.inject(ProfileManager.self)
	fileprivate var analyticManager = try! Injector.inject(AnalyticManager.self)
    
    var mode : RequestListViewControllerMode!
    var request : RequestList!
    fileprivate var viewModel : PurchaseViewModel!
    
    @IBOutlet weak var bClose: UIButton!
    @IBOutlet weak var lTotal: UILabel!
    @IBOutlet weak var lSavings: UILabel!
	@IBOutlet weak var bBuy: UIButton!

    fileprivate var segClose : String!
    fileprivate var segBuy : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let isInitial = self.mode! == .initial // weird
        self.segClose = isInitial ? Self.segInitialClose : Self.segSubsequentClose
        self.segBuy = isInitial ? Self.segInitialBuy : Self.segSubsequentBuy
        self.bClose.isHidden = !isInitial
        self.viewModel = try! Injector.inject(PurchaseViewModel.self, with: self.request)
        self.configure(with: self.viewModel)
    }
	
	fileprivate func openCards()
	{
		if self.mode! == .initial
		{
			Storage.temp[kStorageInitialSetup] = true
			performSegue(withIdentifier: Self.segRegisterToCards, sender: self)
		}
		else
		{
			performSegue(withIdentifier: Self.segToCards, sender: self)
		}
	}
	
	fileprivate func openProfile()
	{
		if self.mode! == .initial
		{
			Storage.temp[kStorageInitialSetup] = true
			performSegue(withIdentifier: Self.segRegisterToProfile, sender: self)
		}
		else
		{
			performSegue(withIdentifier: Self.segToAddress, sender: self)
		}
	}
	
	func checkCardAndAddress() -> Bool
	{
		let noCards = profileManager.profile?.cards?.isEmpty ?? true
		let noPrimaryCard = profileManager.profile?.primaryCard == nil
		
		if noPrimaryCard || noCards || profileManager.profile?.address == nil {
			
			let message: String
			let buttonTitle: String
			if noCards {
				message = "You haven't added any cards yet".localized
				buttonTitle = "Add Card".localized
			} else if noPrimaryCard {
				message = "You haven't select primary card yet".localized
				buttonTitle = "Select Card".localized
			} else {
				message = "You haven't set delivery address yet".localized
				buttonTitle = "Add Address".localized
			}
			
			let alert = UIAlertController(title: "Stoqi", message: message, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { _ in
				if noCards || noPrimaryCard
				{
					self.openCards()
				}
				else
				{
					self.openProfile()
				}
				
				Storage.temp[kStorageBackToPurchase] = true
			}))
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
				
			}))
			self.present(alert, animated: true, completion: nil)
			
			return false
		}
		
		return true
	}
	
	
    @IBAction func buyAction(_ sender: AnyObject) {
		
		if checkCardAndAddress() == false {
			return
		}
		
		if isInitialBuy()
		{
			/// If it's first buy - always buy
			let succesMessage = "Payment was successfully done".localized
			let succes = getSuccesBlock(succesMessage)
			
			TSNotifier.showProgress(withMessage: "Buying...".localized, on: self.view)
			self.manager.performProcessRequest(self.request) {
				TSNotifier.hideProgress()
				if case .success = $0 {
					succes()
				}
				else if case let .failure(error) = $0 {
					self.showError(error, errorMessage: "Error".localized)
				}
			}
		}
		else
		{
			/// Else check if it's authorize or buy
			let succesMessage = self.viewModel.moreThen7days ? "We will pre-authorize your replacement if any price will be changed until then we will let you know".localized : "Payment was successfully done".localized
			let succes = getSuccesBlock(succesMessage)
			
			TSNotifier.showProgress(withMessage: self.viewModel.moreThen7days ? "Authorizing...".localized : "Buying...".localized, on: self.view)
			if self.viewModel.moreThen7days
			{
				self.request.status = .autorized(from: Date(), to: Date(), autOn: Date())
				self.manager.performSaveRequest(self.request){
					TSNotifier.hideProgress()
					if case .success = $0 {
						succes()
					}
					else if case let .failure(error) = $0 {
						self.showError(error, errorMessage: "Error".localized)
					}
				}
			}
			else
			{
				self.manager.performProcessRequest(self.request) {
					TSNotifier.hideProgress()
					if case .success = $0 {
						succes()
					}
					else if case let .failure(error) = $0 {
						self.showError(error, errorMessage: "Error".localized)
					}
				}
			}
		}
    }
	
	func getSuccesBlock(_ message: String) -> ()->Void
	{
		return {
			self.view.isUserInteractionEnabled = false;
			self.setInitialBuy()
			TSNotifier.notify(message, withAppearance: [kTSNotificationAppearancePosition : TSNotificationPosition.NOTIFICATION_POSITION_CENTER_CENTER.rawValue], on: self.view)
			self.analyticManager.analytic = nil
			GCDQueue.main.after(3) {
				self.view.isUserInteractionEnabled = true;
				self.performSegue(withIdentifier: self.segBuy, sender: self)
			}
		}
	}
	
	func isInitialBuy() -> Bool {
		
		if let users = Storage.local[kStorageInitialBuy] as? [String]
		{
			for userEmail in users
			{
				if profileManager.profile?.email == userEmail
				{
					return false
				}
			}
		}
		
		return true
	}
	
	func setInitialBuy()
	{
		if var users = Storage.local[kStorageInitialBuy] as? [String]
		{
			users.append((profileManager.profile?.email)!)
			Storage.local[kStorageInitialBuy] = users
		}
		else
		{
			Storage.local[kStorageInitialBuy] = [(profileManager.profile?.email)!]
		}
	}
	
	
    @IBAction func closeAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: self.segClose, sender: self)
    }
}

extension PurchaseViewController : TSConfigurable {
    func configure(with dataSource : PurchaseViewModel) {
        self.lSavings.text = "R$ \(String(format:"%.2f", dataSource.saved))"
        self.lTotal.text = "R$ \(String(format:"%.2f", dataSource.total))"
		
		if isInitialBuy()
		{
			self.bBuy.setTitle("Buy".localized, for: UIControlState())
		}
		else
		{
			self.bBuy.setTitle(dataSource.moreThen7days ? "Authorize purchase".localized : "Buy".localized, for: UIControlState())
		}
    }
	
	
}
