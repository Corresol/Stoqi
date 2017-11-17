import UIKit
import ActionSheetPicker_3_0
import Social
import GCDKit

enum InputErrors : Error {
    case missingFields([String]?)
    case invalidFields([String]?)
}

class BaseViewController : TSViewControllerNavEx {
    
    @IBOutlet weak var btnStart: UIButton!
    /// Indicates that view is loaded and can be configured with ViewModel
    fileprivate(set) var isLoaded : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isLoaded = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        TSNotifier.hideProgress()
        super.viewWillAppear(animated)
        
        if btnStart != nil{
            if UserDefaults.standard.value(forKey: "CURRENT_INDEX") != nil {
                if UserDefaults.standard.integer(forKey: "CURRENT_INDEX") != 0
                {
                    let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        self.btnStart.sendActions(for: .touchUpInside)
                    }
                }
            }
        }
    }
    
    
    func openPicker(_ dataSource : PickerDataSource, trigger : Triggerable, selectedBlock : @escaping (Int, PickerItemViewModel) -> Void) {
        var index : Int = 0
        if let value = dataSource.initialValue, let matchIndex = dataSource.values.index(where: {value.itemText == $0.itemText}) {
            index = matchIndex
        }
        trigger.isTriggered = true
        ActionSheetStringPicker(title: dataSource.pickerTitle, rows: dataSource.values.map {$0.itemText}, initialSelection: index, doneBlock: { (_, selected, _) in
            selectedBlock(selected, dataSource.values[selected])
            trigger.isTriggered = false
            }, cancel: { (_) in
                trigger.isTriggered = false
            }, origin: trigger).show()
    }
    
    /// Sets color of target view's border for either valid or invalid state.
    func setView(_ view : UIView, valid : Bool, validColor : UIColor = StoqiPallete.auxColor, invalidColor : UIColor = UIColor.red) {
        view.borderColor = valid ? validColor : invalidColor
    }
    
    func showError(_ error : OperationError, errorMessage : String) {
        TSNotifier.notify(error == .networkError ? "kNoInternetConnection".localized : errorMessage.localized, withAppearance: [kTSNotificationAppearanceTextColor : UIColor.red], on: self.view)
    }
    
    func showErrorOnCenter(_ error : OperationError, errorMessage : String) {
        TSNotifier.notify(error == .networkError ? "kNoInternetConnection".localized : errorMessage.localized, withAppearance: [kTSNotificationAppearanceTextColor : UIColor.red, kTSNotificationAppearancePosition : TSNotificationPosition.NOTIFICATION_POSITION_CENTER_CENTER.rawValue], on: self.view)
    }
    
    func shareOnWathApp(_ text : String?)
    {
        let urlString = text != nil ? text! : "Sending WhatsApp message from Stoqi"
        let urlStringEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let url  = URL(string: "whatsapp://send?text=\(urlStringEncoded!)")
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.openURL(url!)
        } else {
            let errorAlert = UIAlertView(title: "Cannot Send Message", message: "Your device is not able to send WhatsApp messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
    }
    
    func shareOnTwitter(_ text : String?)
    {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet.setInitialText(text != nil ? text! : "Stoqi Share on Twitter")
            self.present(twitterSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func shareOnFacebook(_ text : String?)
    {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText(text != nil ? text! : "Share on Facebook")
            self.present(facebookSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func prepareStoqi(_ prodsManager: ProductsManager, profileManager: ProfileManager, requestsManager: RequestsManager, analyticManager: AnalyticManager, completionSucces : @escaping () -> Void, completionFailure : @escaping () -> Void)
    {
        TSNotifier.showProgress(withMessage: "Preparing Stoqi..", on: self.view)
        let group = GCDGroup()
        var result : AnyOperationResult = .success
        
        if prodsManager.products == nil {
            group.enter()
            prodsManager.performLoadProducts {
                group.leave()
                if case .success = result {
                    result = AnyOperationResult(result: $0)
                }
            }
        }
        if profileManager.profile == nil {
            group.enter()
            profileManager.performLoadProfile() {
                group.leave()
                if case .success = result {
                    result = AnyOperationResult(result: $0)
                }
            }
        }
        if requestsManager.requests == nil {
            group.enter()
            requestsManager.performLoadRequests() {
                group.leave()
                if case .success = result {
                    result = AnyOperationResult(result: $0)
                }
            }
        }
        if analyticManager.analytic == nil {
            group.enter()
            analyticManager.performLoadAnalytic() {
                group.leave()
                if case .success = result {
                    result = AnyOperationResult(result: $0)
                }
            }
        }
        
        
        
        group.notify(GCDQueue.main) {
            TSNotifier.hideProgress()
            switch result {
            case .success:
                completionSucces()
            case .failure:
                let alert = UIAlertController(title: "Stoqi", message: "Failed to setup Stoqi for you. Please, try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { _ in
                    self.prepareStoqi(prodsManager, profileManager: profileManager, requestsManager: requestsManager, analyticManager: analyticManager, completionSucces: completionSucces, completionFailure: completionFailure)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                    completionFailure()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}

class RefreshableBaseViewController : BaseViewController {
    
    enum RefresherMessage {
        case date(title : String?, format : String?)
        case custom(String)
    }
    
    /// Color of the UIRefreshControl
    var refresherColor : UIColor {
        return StoqiPallete.mainColor
    }
    
    /// Target UITableView to which refresher will be added.
    var refresherTableView : UITableView? {
        return nil
    }
    
    /// Message type to be displayed on refresher.
    var refresherMessage : RefresherMessage {
        return .date(title: self.defaultMessageTitle, format: self.defaultMessageDateFormat)
    }
    
    /** Indicates whether the refresher is triggered or not.
     - Note: Setting property to true triggers refresher.
     */
    var refreshing : Bool {
        get { return self.rcRefresh?.isRefreshing ?? false }
        set {
            guard self.refreshing != newValue && self.rcRefresh != nil else {
                return
            }
            if newValue {
                self.rcRefresh?.beginRefreshing()
            } else {
                self.rcRefresh?.endRefreshing()
            }
        }
    }
    
    /// Updates refresher message with refresherMessage property.
    final func updateRefresher() {
        self.setRefreshTitle(Date())
    }
    
    /// Gets called whenever refresher is triggered
    func refresh() {
        print("\(type(of: self)): refresh() must be overriden to perform custom refreshing.")
    }
    
    fileprivate var rcRefresh : UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tableView = self.refresherTableView {
            self.rcRefresh = UIRefreshControl()
            self.rcRefresh?.tintColor = self.refresherColor
            self.rcRefresh?.addTarget(self, action: #selector(refresh), for: .valueChanged)
            self.setRefreshTitle()
            tableView.addSubview(self.rcRefresh!)
        }
    }
    
    fileprivate let defaultMessageTitle = "Last Updated"
    fileprivate let defaultMessageDateFormat = "MM/dd/yyyy HH:mm:ss"
    
    
    fileprivate func setRefreshTitle(_ date : Date? = nil) {
        let message : String
        switch refresherMessage {
        case .date(let title, let format):
            if let date = date {
                message = "\(title ?? self.defaultMessageTitle) \(date.toString(withFormat:format ?? self.defaultMessageDateFormat))"
            } else {
                message = "\(self.defaultMessageTitle): Never"
            }
            
        case .custom(let msg):
            message = msg
        }
        self.rcRefresh?.attributedTitle = NSAttributedString(string:message)
    }
}

