import UIKit

class LoginViewController: BaseViewController {
    
    fileprivate static let segLogin = "segLogin"
    fileprivate static let segRegister = "segRegister"
  
    fileprivate let manager = try! Injector.inject(AuthorizationManager.self)
    fileprivate let productsManager = try! Injector.inject(ProductsManager.self)
    fileprivate let profileManager = try! Injector.inject(ProfileManager.self)
	fileprivate let requestsManager = try! Injector.inject(RequestsManager.self)
	fileprivate let analyticManager = try! Injector.inject(AnalyticManager.self)
    
    @IBOutlet weak fileprivate var tfLogin: UITextField!
    @IBOutlet weak fileprivate var tfPassword: UITextField!
    
    fileprivate var viewModel : LoginViewModel!
    
    override func viewWillAppear(_ animated : Bool) {
        super.viewWillAppear(animated)
        
//        tfLogin.text = "xeieshan@gmail.com"
//        tfPassword.text = "Qwerty1"
        self.viewModel = try! Injector.inject(LoginViewModel.self)
        self.configure(with: self.viewModel)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if manager.account != nil {
            proceed()
        }
    }
    
    func proceed() {
		self.prepareStoqi(productsManager,
		                  profileManager: profileManager,
		                  requestsManager: requestsManager,
		                  analyticManager: analyticManager,
		                  completionSucces:{
				if self.profileManager.checkProfileRegistered()
				{
					self.performSegue(withIdentifier: type(of: self).segLogin, sender: self)
				}
				else
				{
					self.performSegue(withIdentifier: type(of: self).segRegister, sender: self)
				}
			}, completionFailure: {})
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier, id == type(of: self).segRegister else {
            return
        }
        
        guard let controller = segue.destination as? RequestListViewController else {
            return
        }
        
        controller.mode = .initial
    }
    
	fileprivate func showConfirmation(_ withRecovery: Bool) {
		
		let controller = UIAlertController(title: "Authorization", message: withRecovery ? "Password doesn't match entered email" : "Hello, we haven't recognized you. Please, confirm that you want to join Stoqi.", preferredStyle: .alert)
        
		
		if withRecovery
		{
			controller.addAction(UIAlertAction(title: "Recover Password", style: .default) { _ in
				self.recoverPassword()
				})
		}
		else
		{
            UserDefaults.standard.set(0, forKey: "CURRENT_INDEX")
			controller.addAction(UIAlertAction(title: "Sign Up", style: .default) { _ in
				self.register()
				})
		}

        controller.addAction(UIAlertAction(title: "Oops, let me check!", style: .cancel) { _ in })
        
        self.present(controller, animated: true, completion: nil)
    }
}

// MARK: - Controller
private extension LoginViewController {

    @IBAction func fieldsEdited(_ sender: UITextField) {
        switch sender {
        case tfLogin: self.viewModel.login.value = sender.text
        case tfPassword: self.viewModel.password.value = sender.text
        default: break
        }
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.login()
    }
    
    @IBAction func unwindLogout(_ segue : UIStoryboardSegue) {
        self.manager.performLogout { (_) in
            
        }
    }
    
    @IBAction func facebookAction(_ sender: UIButton) {
        view.endEditing(true)
        loginFacebook()
    }
    
    @IBAction func unwindToLogin(_ segue : UIStoryboardSegue) {
    }

}

// MARK: - Interactor
private extension LoginViewController {
    func login() {
        guard self.viewModel.isValid, let credentials = self.viewModel.credentials else {
            TSNotifier.notify(viewModel.validationErrors.first, withAppearance: [kTSNotificationAppearanceTextColor : UIColor.red])
            return
        }
        
        TSNotifier.showProgress(withMessage: "Logging in...".localized, on: self.view)
        self.manager.performAuthorization(withCredentials: credentials) {
            TSNotifier.hideProgress()
            if case .authorized = $0
			{
				self.proceed()
            }
            else if case .notExisted = $0 {
                self.showConfirmation(false)
            }
            else if case let .failure(error) = $0 {
				
				if error == .invalidResponse
				{
					self.showConfirmation(true)
				}
				else
				{
					self.showError(error, errorMessage: "kLoginFailed".localized)
				}
            }
        }
    }
	
	func recoverPassword()
	{
		guard self.viewModel.login.isValid, let email = self.viewModel.login.value  else {
			return
		}
		
		TSNotifier.showProgress(withMessage: "Recovering...".localized, on: self.view)
		self.manager.performPasswordRecovery(email) {
			TSNotifier.hideProgress(on: self.view)
			if case .success = $0
			{
				TSNotifier.notify("We've sent you an email".localized, on: self.view)
			}
			else if case let .failure(error) = $0 {
				self.showError(error, errorMessage: "Sorry. Try again later.".localized)
			}
		}
	}
    
    func register() {
        
        guard self.viewModel.isValid, let credentials = self.viewModel.credentials else {
            TSNotifier.notify("kEnterValidEmailAndPassword".localized, withAppearance: [kTSNotificationAppearanceTextColor : UIColor.red])
            return
        }
        
        TSNotifier.showProgress(withMessage: "Logging in...".localized, on: self.view)
        self.manager.performRegistration(withCredentials: credentials) {
            TSNotifier.hideProgress(on: self.view)
            if case .created = $0 {
                self.proceed()
			} else if case let .failure(error) = $0 {
				self.showError(error, errorMessage: "Sorry, login failed. Try again later.".localized)
			}
        }
    }
    
    func loginFacebook() {
        FacebookHelper.authorizeFacebook(fromViewController: self) {
            guard case let .authorized(token) = $0 else {
                if case .canceled = $0 {
                    print("Facebook authorization canceled.")
					TSNotifier.notify("To get access by Facebook we need permissions.", withAppearance: [kTSNotificationAppearanceTextColor : UIColor.red], on: self.view)
                } else {
                    print("Facebook authorization failed!")
					TSNotifier.notify("Facebook authorization failed!", withAppearance: [kTSNotificationAppearanceTextColor : UIColor.red], on: self.view)
                }
                return
            }
            TSNotifier.showProgress(withMessage: "Logging in..", on: self.view)
            self.manager.performFacebookAuthorization(token) {
                if case .authorized = $0 {
                    TSNotifier.hideProgress()
                    self.proceed()
                }
                else if case .created = $0 {
                    self.loadFacebookUser()
                }
				else  if case let .failure(error) = $0 {
					TSNotifier.hideProgress()
					self.showError(error, errorMessage: "Sorry, login failed. Try again later.".localized)
				}
            }
        }
    }
    
    func loadFacebookUser() {
        FacebookHelper.getUser {
            if case .success(let (_, email)) = $0 {
                let profile = Profile(email: email)
                self.profileManager.performSaveProfile(profile) { _ in
                    TSNotifier.hideProgress()
                    self.proceed()
                }
            } else {
                TSNotifier.hideProgress()
                self.proceed()
            }
        }
    }
	
}

// MARK: - Presenter 
extension LoginViewController : TSConfigurable {
    func configure(with dataSource: LoginViewModel) {
        self.tfLogin.text = dataSource.login.value
        self.tfPassword.text = dataSource.password.value
    }
}
