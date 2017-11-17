class ListCreatedConfirmationViewController : BaseViewController {
    
    fileprivate static let segOpenList = "segOpenList"
    
    fileprivate let manager = try! Injector.inject(RequestsManager.self)
    
    
    @IBAction func openList(_ sender: UIButton) {
        guard let request = self.manager.requests?.first else {
            self.loadRequests()
            return
        }
		
		Storage.temp[kStorageRequestListValue] = request
        self.performSegue(withIdentifier: type(of: self).segOpenList, sender: self)
    }
    
    
    fileprivate func loadRequests() {
        TSNotifier.showProgress(withMessage: "Preparing Stoqi..", on: self.view)
        self.manager.performLoadRequests {
            TSNotifier.hideProgress()
            switch $0 {
            case .success(let requests):
                Storage.temp[kStorageRequestListValue] = requests.first
                self.performSegue(withIdentifier: type(of: self).segOpenList, sender: self)
            case let .failure(error):
				
				if error == .networkError {
					TSNotifier.notify("kNoInternetConnection".localized, withAppearance: [kTSNotificationAppearanceTextColor : UIColor.red], on: self.view)
				}
				
                let alert = UIAlertController(title: "Stoqi", message: "Failed to setup Stoqi for you. Please, try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { _ in
                    self.loadRequests()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}
