class RequestsViewController: BaseViewController, UITabBarControllerDelegate {
    
    fileprivate static let segOpenList = "segOpenList"
	fileprivate static let kStorageOpenFirstList = "kStorageOpenFirstList"
    
    fileprivate let manager : RequestsManager = try! Injector.inject(RequestsManager.self)
    
    @IBOutlet weak fileprivate var tvOptions: UITableView!
    
    fileprivate var requestsVM : [RequestViewModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if let requests = self.manager.requests {
//            self.initViewModel(requests)
//        } else {
            self.loadData()
//        }
    }
    
    fileprivate func initViewModel(_ requests : [RequestList]) {
        self.requestsVM = requests.sorted {
			
			if case .notAutorized = $0.0.status {
				return true
			} else if case .autorized = $0.0.status {
				return true
            } else if case .autorized = $0.0.status {
                return true
            } else if case .inDelivering = $0.1.status {
				return true
            }
//            else if case .inDelivering(let date1) = $0.0.status {
//                return date1 >= date2
//            }
//            else if case .inDelivering(let date2) = $0.1.status {
//				return date1 >= date2
//            } else if case .delivered(let date1) = $0.0.status {
//                
//            }else if case .delivered(let date2) = $0.1.status {
//				return date1 >= date2
//            } else if case .inDelivering(let date1) = $0.0.status{
//                return date1 >= date2
//            } else if case .delivered(let date2) = $0.1.status {
//				return date1 >= date2
//			}
            else {
				return false
			}

//            if case .New = $0.0.status {
//                return true
//			} else if case .Pending(let date1, _) = $0.0.status,
//				.Completed(let date2) = $0.1.status {
//				return date1 >= date2
//			} else if case .Pending(let date1, _) = $0.0.status,
//                .Pending(let date2, _) = $0.1.status {
//                return date1 >= date2
//            } else if case .Completed(let date1) = $0.0.status,
//                           .Completed(let date2) = $0.1.status {
//                return date1 >= date2
//			} else {
//                return false
//            }
			
            }.flatMap {try? Injector.inject(RequestViewModel.self, with: $0) }
        if self.requestsVM.count > 2 {
            self.requestsVM[1].hasNextNode = false
        }
        self.tvOptions.reloadData()
		if Storage.temp.popObjectForKey(type(of: self).kStorageOpenFirstList) as? Bool ?? false == true
		{
			openFirstList()
		}
    }
    
    fileprivate func loadData() {
        TSNotifier.showProgress(withMessage: "Loading requests..", on: self.view)
        self.manager.performLoadRequests {
            TSNotifier.hideProgress(on: self.view)
            switch $0 {
            case .success(let requests):
                self.initViewModel(requests)
			case let .failure(error):
				
				if error == .networkError {
					TSNotifier.notify("kNoInternetConnection".localized, withAppearance: [kTSNotificationAppearanceTextColor : UIColor.red], on: self.view)
				}
				
                let alert = UIAlertController(title: "Stoqi", message: "Failed to load request history. Please, try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { _ in
                    self.loadData()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                    (self.tabBarController as? StoqiTabBarController)?.openTab(.main)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func unwindRequestBuy(_ segue : UIStoryboardSegue) {
        (self.tabBarController as? StoqiTabBarController)?.openTab(.main)
    }
    
    @IBAction func unwindRequestCancel(_ segue : UIStoryboardSegue) { loadData() }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier, id == type(of: self).segOpenList else {
            return
        }
        
        guard let controller = segue.destination as? RequestListViewController else {
            return
        }

        controller.mode = .subsequent
    }
	
	func openFirstList()
	{
		guard let table = tvOptions, self.manager.requests != nil else {
			Storage.temp[type(of: self).kStorageOpenFirstList] = true
			return
		}
		tableView(table, didSelectRowAt: IndexPath(row: 0, section: 0))
	}
}

// MARK: TableView Implementation
extension RequestsViewController :  UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requestsVM?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.row == 0 ? CurrentRequestCell.height : HistoryRequestCell.height)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellOfType(CurrentRequestCell.self)
            cell.configure(with: self.requestsVM[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCellOfType(HistoryRequestCell.self)
            cell.configure(with: self.requestsVM[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if requestsVM != nil {
            
            Storage.temp[kStorageRequestListValue] = requestsVM[indexPath.row].request
            Storage.temp[kStorageRequestListReadonlyFlag] = (indexPath.row > 0)
        }
        self.performSegue(withIdentifier: type(of: self).segOpenList, sender: self)
        tableView.deselectRow(at: indexPath
            , animated: true)
    }
}
