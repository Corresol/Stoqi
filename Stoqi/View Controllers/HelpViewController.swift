import UIKit
import MessageUI

class HelpViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    fileprivate let helpOptionsDS : [HelpOptionCellDataSource] = [SimpleHelpOptionDataSource(title: "How the Stoqi works?", icon: "help_about"),
                                                              SimpleHelpOptionDataSource(title: "When I receive my replacement?", icon: "help_receive_replacement"),
                                                              SimpleHelpOptionDataSource(title: "How can I request a purchase?", icon: "help_about"),
                                                              SimpleHelpOptionDataSource(title: "Send an email to Stoqi", icon: "help_mail_us", canOpen: true)/*,
                                                              SimpleHelpOptionDataSource(title: "Talk with us", icon: "help_talk_to_us", canOpen: false)*/]
    
    @IBOutlet weak fileprivate var tvOptions: UITableView!
	
	fileprivate var subjectStr: String = ""
	fileprivate let manager = try! Injector.inject(ProfileManager.self)
	fileprivate let accaunt = try! Injector.inject(AuthorizationManager.self)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let profile = manager.profile {
			if let userid = accaunt.account?.id {
				subjectStr = "\(profile.name!): \(userid)"
			}
			else
			{
				subjectStr = profile.name!
			}
		}
		else
		{
			loadProfile()
		}
	}
	
	func loadProfile() {
		TSNotifier.showProgress(withMessage: "Loading Profile..", on: view)
		manager.performLoadProfile {
			TSNotifier.hideProgress()
			switch $0 {
			case .success(let profile):
				if let userid = self.accaunt.account?.id {
					self.subjectStr = "\(profile.name!): \(userid)"
				}
				else
				{
					self.subjectStr = profile.name!
				}
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
	
	
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.helpOptionsDS.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HelpOptionCell.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellOfType(HelpOptionCell.self)
        cell.configure(with: helpOptionsDS[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		if indexPath.row == 3
		{
			sendEmail()
		}
		
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension HelpViewController : MFMailComposeViewControllerDelegate{
	
	func sendEmail()
	{
		let mailComposeViewController = configuredMailComposeViewController()
		if MFMailComposeViewController.canSendMail()
		{
			self.present(mailComposeViewController, animated: true, completion: nil)
		}
		else
		{
			TSNotifier.notify("Your device could not send e-mail.  Please check e-mail configuration and try again.", withAppearance: [kTSNotificationAppearanceTextColor : UIColor.red], on: self.view)
		}
	}
	
	func configuredMailComposeViewController() -> MFMailComposeViewController
	{
		let mailComposerVC = MFMailComposeViewController()
		mailComposerVC.mailComposeDelegate = self
		
		mailComposerVC.setToRecipients(["ajudalimpeza@stoqi.com"])
		mailComposerVC.setSubject(subjectStr)
		mailComposerVC.setMessageBody("", isHTML: false)
		
		return mailComposerVC
	}
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
	{
		controller.dismiss(animated: true, completion: nil)
		
		if result == .sent
		{
			TSNotifier.notify("Email sended!", withAppearance: [kTSNotificationAppearancePosition : TSNotificationPosition.NOTIFICATION_POSITION_CENTER_CENTER.rawValue], on: self.view)
		}
		else if result == .failed
		{
			TSNotifier.notify("Could not send e-mail.", withAppearance: [kTSNotificationAppearanceTextColor : UIColor.red, kTSNotificationAppearancePosition : TSNotificationPosition.NOTIFICATION_POSITION_CENTER_CENTER.rawValue], on: self.view)
		}
	}
}

private struct SimpleHelpOptionDataSource : HelpOptionCellDataSource {
    var title: String
    var icon: UIImage
    var canOpen: Bool
    
    init(title: String, icon : String, canOpen : Bool = true) {
        self.title = title
        self.icon = UIImage(named:icon)!
        self.canOpen = canOpen
    }
}
