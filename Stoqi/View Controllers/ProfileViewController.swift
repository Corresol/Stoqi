import GCDKit
class ProfileViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {
    
    fileprivate enum Segues : String {
        case EditQuestion = "segEditQuestion"
        case ManageCards = "segCards"
		case MyInfo = "segMyInfo"
    }
    
    fileprivate enum Sections : Int, CustomStringConvertible {
        case deliver
        case payMethod
        case profile
        
        var description: String {
            switch self {
            case .deliver: return "Deliver on"
            case .payMethod: return "Pay method"
            case .profile: return "Your Profile"
            }
        }
        
        static let values : [Sections] = [.deliver, .payMethod, .profile]
    }
    
    fileprivate enum QuestionType : Int {
        case location
        case type
        case area
        case residents
        case priority
        
        static let values : [QuestionType] = [.location, .type, .area, .residents, .priority]
    }
    
    fileprivate let manager = try! Injector.inject(ProfileManager.self)
    
    fileprivate var editor : EditAddressViewController!
    
    @IBOutlet weak fileprivate var tvProfile: UITableView!
    @IBOutlet weak var lPhone: UILabel!
    @IBOutlet weak var lName: UILabel!
    @IBOutlet weak var lEmail: UILabel!
    @IBOutlet weak var ivPicture: UIImageView!
    
    fileprivate var selectedQuestion : QuestionType? {
        didSet {
            if selectedQuestion != nil {
                performSegue(withIdentifier: Segues.EditQuestion.rawValue, sender: self)
            }
        }
    }
    
    fileprivate var viewModel : ProfileViewModel! {
        didSet {
            tvProfile.reloadData()
            configure(with: viewModel)
        }
    }
//	fileprivate let emptyViewModel = try! Injector.inject(CommonEmptyResultsCellDataSource.self, with: "Payment method hasn't been defined yet.")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editor = EditAddressViewController()
        editor.modalPresentationStyle = .popover
        editor.isModalInPopover = true
        editor.preferredContentSize = CGSize(width: 316, height: 168)
        editor.delegate = self
        
        if let profile = manager.profile {
            viewModel = try! Injector.inject(ProfileViewModel.self, with: profile)
        } else {
            viewModel = try! Injector.inject(ProfileViewModel.self)
            loadProfile()
        }
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if Storage.temp[kStorageInitialSetup] != nil
		{
			openAddress()
		}
	}
	
	
	func openCards()
	{
		performSegue(withIdentifier: Segues.ManageCards.rawValue, sender: self)
	}
	
	func openAddress()
	{
		guard let cell = tvProfile.cellForRow(at: IndexPath(row: 0, section: Sections.deliver.rawValue)) else
		{
			return
		}
		
		showPopover(cell)
	}
	
	
	
    
    fileprivate func showPopover(_ base: UIView)
    {
        if let popover = editor.popoverPresentationController {
            popover.delegate = self
            popover.sourceView = base
            popover.sourceRect = base.bounds
            popover.permittedArrowDirections = [.up, .down]
            self.present(editor, animated: true, completion: nil)
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if segue.identifier == Segues.MyInfo.rawValue
		{
			guard let controller = segue.destination as? ChangeUserInfoViewController, let m_profile = manager.profile else {
				return
			}
			
			controller.delegate = self
			controller.setProfile(m_profile)
		}
		
        defer {
            selectedQuestion = nil
        }
        guard let type = selectedQuestion,
            let id = segue.identifier, id == Segues.EditQuestion.rawValue,
            let controller = segue.destination as? QuestionEditor else {
                return
        }
        
        let question = questionForType(type)
        controller.question = question
    }
	
	func openPurchase()
	{
		guard let navController = (self.tabBarController as? StoqiTabBarController)?.openTab(StoqiTab.requests) as? UINavigationController, let controller = navController.viewControllers.last as? RequestListViewController  else {
			return
		}
		
		GCDQueue.main.after(0.1)
		{
			controller.openPurchase()
		}
	}
	
	func openYourList()
	{
		guard let navController = (self.tabBarController as? StoqiTabBarController)?.openTab(StoqiTab.requests) as? UINavigationController, let controller = navController.viewControllers.last as? RequestsViewController  else {
			return
		}
		
		GCDQueue.main.after(0.1)
		{
			controller.openFirstList()
		}
	}
	
	
	func askToOpenYourList()
	{
		let alert = UIAlertController(title: "Stoqi", message: "Your changes impact our recommendations for the next repleishment. Want to check it out now?", preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
			self.openYourList()
		}))
		alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
		}))
		self.present(alert, animated: true, completion: nil)
	}

}

extension ProfileViewController : AddressEditorDelegate {
    func editor(_ editor: AddressEditor, didEdit viewModel: AddressViewModel) {
		
		saveAddress(viewModel)
		tvProfile.reloadRows(at: [IndexPath(row: 0, section: Sections.deliver.rawValue)], with: .automatic)
		dismiss(animated: true, completion: nil)
		
		if let _ = Storage.temp.popObjectForKey(kStorageBackToPurchase) as? Bool
		{
			openPurchase()
		}
		
		if Storage.temp[kStorageInitialSetup] != nil
		{
			self.dismiss(animated: true, completion: nil)
		}
    }
	
    func editorDidCancel(_ editor: AddressEditor)
	{
		Storage.temp.popObjectForKey(kStorageBackToPurchase)
		dismiss(animated: true)
		{
			if Storage.temp[kStorageInitialSetup] != nil
			{
				self.dismiss(animated: true, completion: nil)
			}
		}
    }
}


extension ProfileViewController : UserInfoEditorDelegate {
	func editor(_ editor : UserInfoEditor, didEdit viewModel : UserInfoViewModel)
	{
		saveUserInfo(viewModel)
	}
	
	func editorDidCancel(_ editor: UserInfoEditor) {
		
	}
}

// MARK: - Controller
private extension ProfileViewController {
    @IBAction func unwindProfile(_ segue : UIStoryboardSegue) {
        if segue.source is ManageCardsViewController {
			if let card = self.manager.profile?.primaryCard {
				viewModel.card = try! Injector.inject(CardViewModel.self, with: card)
			}
			else
			{
				viewModel.card = nil
			}
			
			if let segue = segue as? TSStoryboardSegue {
				segue.completion = {
					if Storage.temp.popObjectForKey(kStorageBackToPurchase) != nil
					{
						self.openPurchase()
					}
				}
			}
			
        }
    }
	
	
	@IBAction func unwindProfileToPurchase(_ segue : UIStoryboardSegue) {
		if let segue = segue as? TSStoryboardSegue {
			segue.completion = {
				self.openPurchase()
			}
		}
	}
	
	
    @IBAction func unwindPrimaryCardSet(_ segue : UIStoryboardSegue) {
        if let controller = segue.source as? ManageCardsViewController, let card = controller.selectedCard {
            viewModel.card = try! Injector.inject(CardViewModel.self, with: card)
            configure(with: viewModel)
        }
		
		if let segue = segue as? TSStoryboardSegue {
			segue.completion = {
				if Storage.temp.popObjectForKey(kStorageBackToPurchase) != nil
				{
					self.openPurchase()
				}
			}
		}
    }
    
    @IBAction func unwindQuestionChanged(_ segue : UIStoryboardSegue) {
		if let segue = segue as? TSStoryboardSegue {
			segue.completion = {
				guard let editor = segue.source as? QuestionEditor, editor.question.isValid else {
					return
				}
				self.saveQuestion(editor.question)
				self.tvProfile.reloadData()
			}
		}
    }
	
    @IBAction func saveAction(_ sender: UIButton) {
        saveProfile()
    }
}

// MARK: - Interactor
private extension ProfileViewController {
    func loadProfile() {
        TSNotifier.showProgress(withMessage: "Loading Profile..", on: view)
        manager.performLoadProfile {
            TSNotifier.hideProgress()
            switch $0 {
            case .success(let profile):
                self.viewModel = try! Injector.inject(ProfileViewModel.self, with: profile)
			case let .failure(error):
				
				if error == .networkError {
					TSNotifier.notify("kNoInternetConnection".localized, withAppearance: [kTSNotificationAppearanceTextColor : UIColor.red], on: self.view)
				}
				
                let alert = UIAlertController(title: "Stoqi", message: "Failed to load profile. Please, try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { _ in
                    self.loadProfile()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                    (self.tabBarController as? StoqiTabBarController)?.openTab(.main)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func saveProfile() {
        if let profile = viewModel?.profile, !isSaved {
            TSNotifier.showProgress(withMessage: "Saving Profile..", on: view)
            TSNotifier.hideProgress()
            manager.performSaveProfile(profile) {
                if case .success = $0 {
                    TSNotifier.notify("Profile saved!")
				} else if case let .failure(error) = $0 {
					self.showError(error, errorMessage: "Failed to save profile.".localized)
				}
                self.configure(with: self.viewModel!)
            }
        }
    }
    
    var isSaved : Bool {
        guard let profile = viewModel?.profile else {
            return true
        }
        return !(manager.profile == nil || profile !== manager.profile!)
    }
    
    func saveQuestion(_ question : QuestionViewModel) {

        if let question = question as? NameQuestionViewModel
		{
            viewModel.name = question
        }
		else if let question = question as? PropertyLocationQuestionViewModel
		{
			if question.location?.id == viewModel.locationQuestion.location?.id && viewModel.locationQuestion.location?.id != nil { return }
            viewModel.locationQuestion = question
        }
		else if let question = question as? PropertyAreaQuestionViewModel
		{
            viewModel.propertyAreaQuestion = question
        }
		else if let question = question as? PropertyTypeQuestionViewModel
		{
            viewModel.propertyTypeQuestion = question
        }
		else if let question = question as? PropertyResidentsQuestionViewModel
		{
            viewModel.propertyResidentsQuestion = question
        }
		else if let question = question as? ProductsPriorityQuestionViewModel
		{
            viewModel.productsPriorityQuestion = question
        }
		else
		{
            print("\(type(of: self)): Unable to determine QuestionEditor's QuestionViewModel type.")
        }
        if let profile = viewModel.profile {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            manager.performSaveProfile(profile) {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
				if case .success = $0
				{
					self.askToOpenYourList()
				}
				else if case let .failure(error) = $0
				{
					self.showError(error, errorMessage: "Failed to save profile.".localized)
				}
            }
        }
    }
    
    func saveAddress(_ address : AddressViewModel) {
        viewModel.address = address
        if let profile = viewModel.profile {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            manager.performSaveProfile(profile) {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
				if case let .failure(error) = $0
				{
					self.showErrorOnCenter(error, errorMessage: "Failed to save profile.".localized)
				}
            }
        }
    }
	
	func saveUserInfo(_ userInfo: UserInfoViewModel) {
		viewModel.name.name.value = userInfo.name.value
		viewModel.email.value = userInfo.email.value
		viewModel.phone.value = userInfo.phone.value
		
		if let profile = viewModel.profile {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			manager.performSaveProfile(profile) {
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				if case let .failure(error) = $0
				{
					self.showError(error, errorMessage: "Failed to save profile.".localized)
				}
			}
		}
	}
}

// MARK: - Presenter
extension ProfileViewController : TSConfigurable {
    func configure(with dataSource: ProfileViewModel) {
        lName.text = dataSource.name.name.value
        lEmail.text = dataSource.email.value
		if let phone = dataSource.phone.value
		{
			lPhone.text = toPhoneNumber(phone)
		}
		else
		{
			lPhone.text = ""
		}
    }
	
	func toPhoneNumber(_ str: String) -> String {
		return str.replacingOccurrences(of: "(\\d{2})(\\d{5})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: nil)
	}
}

// MARK: - TableView
extension ProfileViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.values.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Sections(rawValue: section) else {
            print("\(type(of: self)): Couldn't convert section to Sections enum value.")
            return 0
        }
        switch section {
        case .payMethod: return 1
        case .deliver: return 1
        case .profile: return viewModel != nil ? QuestionType.values.count : 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = Sections(rawValue: indexPath.section) else {
            print("\(type(of: self)): Couldn't convert section to Sections enum value.")
            return ProfileDeliveryCell.height
        }
        switch section {
        case .profile: return ProfileQuestionCell.height
        default: return ProfileDeliveryCell.height
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Sections(rawValue: indexPath.section) else {
            print("\(type(of: self)): Couldn't convert section to Sections enum value.")
            return UITableViewCell()
        }
        switch section {
        case .deliver:
            let cell = tableView.dequeueReusableCellOfType(ProfileDeliveryCell.self)
            if let address = viewModel.address {
                cell.configure(with: address)
            } else {
                print("\(type(of: self)): AddressViewModel not defined.")
            }
            return cell
            
        case .payMethod:
            if let card = viewModel.card {
				let cell = tableView.dequeueReusableCellOfType(ProfilePayMethodCell.self)
                cell.configure(with: card)
				return cell
            } else {
                print("\(type(of: self)): CardViewModel not defined.")
				let cell = tableView.dequeueReusableCellOfType(CommonEmptyResultsCell.self)
//				cell.configure(with: emptyViewModel)
				return cell
            }
        case .profile:
            let cell = tableView.dequeueReusableCellOfType(ProfileQuestionCell.self)
            if let question = questionForIndex(indexPath.row) {
                cell.configure(with: question)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Sections(rawValue: indexPath.section) else {
            print("\(type(of: self)): Couldn't convert section to Sections enum value.")
            return
        }
        if case .profile = section {
            selectedQuestion = QuestionType(rawValue: indexPath.row)
        } else if case .payMethod = section {
            performSegue(withIdentifier: Segues.ManageCards.rawValue, sender: self)
        } else if case .deliver = section, let cell = tableView.cellForRow(at: indexPath) {
            if let address = viewModel.address?.address {
                editor.setAddress(address)
            }
            showPopover(cell)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    fileprivate func questionForIndex(_ row : Int) -> QuestionViewModel? {
        guard let question = QuestionType(rawValue: row) else {
            return nil
        }
        return questionForType(question)
    }
    
    fileprivate func questionForType(_ question : QuestionType) -> QuestionViewModel {
        switch question {
        case .location:     return viewModel.locationQuestion
        case .type:         return viewModel.propertyTypeQuestion
        case .area:         return viewModel.propertyAreaQuestion
        case .residents:    return viewModel.propertyResidentsQuestion
        case .priority:     return viewModel.productsPriorityQuestion
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "" //Sections.values[section].description
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard let title = self.tableView(tableView, titleForHeaderInSection: section) else {
//            print("\(type(of: self)): Unable to get section title.")
//            return nil
//        }
        let titleStr :String? = Sections.values[section].description
        guard let title  = titleStr else {
            print("\(type(of: self)): Unable to get section title.")
            return nil
        }
        let view = tableView.dequeueReusableViewOfType(CommonHeaderView.self)
        // TODO: Hardcoded style
        let style = try! Injector.inject(CommonHeaderViewStyleSource.self, with: (StoqiPallete.darkGrayTextColor, StoqiPallete.lightColor))
        let dataSource = try! Injector.inject(CommonHeaderViewDataSource.self, with: title)
        view.configure(with: dataSource)
        view.style(with: style)
        return view
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CommonHeaderView.height
    }
}

