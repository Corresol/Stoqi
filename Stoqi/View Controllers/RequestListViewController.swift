let kStorageRequestListValue = "kRequestListValue"
let kStorageRequestListReadonlyFlag = "kRequestListOnlyFlag"

import GCDKit

class RequestListViewController : BaseViewController, UIScrollViewDelegate {
    
    fileprivate static let segFinalize = "segFinalize"
    fileprivate static let segInitialClose = "segClose"
    fileprivate static let segSubsequentClose = "segCancel"
    fileprivate static let segEditItem = "segEditItem"
    fileprivate static let segAddItem = "segAddItem"
    
    fileprivate let manager = try! Injector.inject(RequestsManager.self)
    fileprivate let productManager = try! Injector.inject(ProductsManager.self)
    
    fileprivate var viewModel : RequestListViewModel!
    
    @IBOutlet weak fileprivate var svContent: UIScrollView!
    @IBOutlet weak fileprivate var bBack: UIButton!
    @IBOutlet weak fileprivate var bClose: UIButton!
    @IBOutlet weak fileprivate var bFinalize: UIButton!
    @IBOutlet weak fileprivate var tvProducts: ExpandedTableView!
    
    var mode : RequestListViewControllerMode = .initial
    fileprivate var isReadOnly : Bool = false
    
    fileprivate var segClose : String!
	
	var selectedIndexPath: IndexPath?
	var selectedSection: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let isInitial = mode == .initial
        segClose = isInitial ? type(of: self).segInitialClose : type(of: self).segSubsequentClose
        bClose.isHidden = !isInitial
        bBack.isHidden = isInitial
        
        tvProducts.isHidden = true
        guard let request = Storage.temp[kStorageRequestListValue] as? RequestList else {
            print("\(type(of: self)): RequestList was not set.")
//            parent?.dismiss(animated: true, completion: nil)
//            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
            return
        }
        isReadOnly = Storage.temp.popObjectForKey(kStorageRequestListReadonlyFlag) as? Bool ?? false
        guard request.products != nil else {
            loadProducts(request)
            return
        }
        viewModel = try! Injector.inject(RequestListViewModel.self, with: request)
        updateView(nil)
		
		tvProducts.estimatedRowHeight = ProductItemCell.height
		tvProducts.rowHeight = UITableViewAutomaticDimension
    }
    
	fileprivate func updateView(_ type: CellUpdateType?) {
		defer {
			tvProducts.isHidden = false
			bFinalize.isHidden = isReadOnly
		}
		
		guard let type = type else {
			tvProducts.reloadData()
			return
		}
		
		switch type {
		case .insert(let section):
			self.tvProducts.reloadSections(IndexSet(integer: section), with: .automatic)
		case .remove(let index):
			self.tvProducts.reloadSections(IndexSet(integer: index.section), with: .automatic)
		case .reload(let index):
			self.tvProducts.reloadRows(at: [index], with: .automatic)
		case .update(let index):
			self.tvProducts.reloadRows(at: [index], with: .none)
		}
    }
	
    fileprivate func loadProducts(_ request : RequestList) {
        TSNotifier.showProgress(withMessage: "Loading products..".localized, on: view)
        manager.performLoadRequestList(request){
            TSNotifier.hideProgress(on: self.view)
            switch $0 {
            case .success(let request):
                self.viewModel = try! Injector.inject(RequestListViewModel.self, with: request)
                self.updateView(nil)
			case let .failure(error):
				
				if error == .networkError {
					TSNotifier.notify("kNoInternetConnection".localized, withAppearance: [kTSNotificationAppearanceTextColor : UIColor.red], on: self.view)
				}
				
                let alert = UIAlertController(title: "Stoqi".localized, message: "Failed to load products. Please, try again.".localized, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { _ in
                    self.loadProducts(request)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
	
	func openPurchase()
	{
		saveList(){
			self.performSegue(withIdentifier: type(of: self).segFinalize, sender: self)
		}
	}
	
	func saveList(_ completion: (()->())? = nil)
	{
		TSNotifier.showProgress(withMessage: "Saving list..".localized, on: view)
        if viewModel.requestList != nil {
            manager.performSaveRequest(viewModel.requestList!, callback: {
                TSNotifier.hideProgress(on: self.view)
                switch $0 {
                case .success: completion?()
                case let .failure(error):
                    self.showError(error, errorMessage: "Failed to save products list.".localized)
                }
            })
        }
		
	}

    @IBAction func navAction(_ sender: UIButton) {
        switch sender {
        case bBack:
            guard !isReadOnly else {
                self.performSegue(withIdentifier: type(of: self).segSubsequentClose, sender: self)
                return
            }
			saveList(){
				self.performSegue(withIdentifier: type(of: self).segSubsequentClose, sender: self)
			}
        case bFinalize:

            guard (viewModel != nil) else {
                TSNotifier.notify("The list is empty".localized, on: self.view)
                return
            }
			guard (viewModel.categories.count > 0 && !viewModel.categories.reduce(true){ $0 && $1.count == 0 }) else
			{
				TSNotifier.notify("The list is empty".localized, on: self.view)
				return
			}
			
			openPurchase()
			
			case bClose:
				if mode == .initial
				{
					saveList(){
						self.performSegue(withIdentifier: self.segClose, sender: self)
					}
				}
				else
				{
					self.performSegue(withIdentifier: self.segClose, sender: self)
				}
			
        default: break
        }
    }
	
	@IBAction func unwindPurchaseToCards(_ segue : UIStoryboardSegue)
	{
		if let segue = segue as? TSStoryboardSegue {
			segue.completion = {
				guard let vc = (self.tabBarController as? StoqiTabBarController)?.openTab(StoqiTab.settings) as? ProfileViewController else {
					return
				}
				vc.openCards()
			}
		}
	}
	
	@IBAction func unwindPurchaseToAddress(_ segue : UIStoryboardSegue)
	{
		if let segue = segue as? TSStoryboardSegue {
			segue.completion = {
				guard let vc = (self.tabBarController as? StoqiTabBarController)?.openTab(StoqiTab.settings) as? ProfileViewController else {
					return
				}
				
				vc.openAddress()
			}
		}
	}
	
    @IBAction func unwindPurchaseToList(_ segue : UIStoryboardSegue) {}
    
    @IBAction func unwindManageItemCancel(_ segue : UIStoryboardSegue) {}
    
    @IBAction func unwindManageItemSave(_ segue : UIStoryboardSegue) {
        if let controller = segue.source as? EditProductEntryViewController,
            let product = controller.product {
            setProduct(product)
        } else if let controller = segue.source as? AddProductEntryViewController,
            let product = controller.product {
            addProduct(product)
        }
    }
    
    @IBAction func unwindManageItemDelete(_ segue : UIStoryboardSegue) {
        guard let controller = segue.source as? EditProductEntryViewController,
        let product = controller.product else {
            return
        }
        removeProduct(product)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? PurchaseViewController {
            controller.mode = mode
            controller.request = viewModel.requestList!
        }
    }
    
    // Locks top-edge bouncing
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset = CGPoint.zero
        }
    }
}

// MARK:- Interactor
extension RequestListViewController {
    
    func addProduct(_ product : ProductEntry) {
        guard let section = self.selectedSection else {
            return
        }
		
		for prodVM in viewModel.categories[section].items //// if product not in list - append
		{
			if prodVM.product.product.brand.id == product.product.brand.id &&
			prodVM.product.product.kind.id == product.product.kind.id &&
			prodVM.product.product.volume.id == product.product.volume.id
			{
				GCDQueue.main.after(0.3)
				{
					TSNotifier.notify("Product already in list", withAppearance: [kTSNotificationAppearanceTextColor : UIColor.red], on: self.view)
				}
				return
			}
		}
		
        viewModel.categories[section].items.append(try! Injector.inject(ProductItemViewModel.self, with: product))
        updateView(CellUpdateType.insert(section))
    }
    
    func setProduct(_ product : ProductEntry) {
		guard let index = self.selectedIndexPath else {
			return
		}
		viewModel.categories[index.section].items[index.row] = try! Injector.inject(ProductItemViewModel.self, with: product)
		updateView(CellUpdateType.update(index))
    }
	
	func replaceProduct(_ product : ProductEntry, with newProduct: ProductEntry) {
		guard let index = self.selectedIndexPath else {
			return
		}
		viewModel.categories[index.section].items[index.row] = try! Injector.inject(ProductItemViewModel.self, with: newProduct)
		updateView(CellUpdateType.reload(index))
	}

	
    func removeProduct(_ product : ProductEntry) {
        guard let index = self.selectedIndexPath else {
            return
        }
        viewModel.categories[index.section].items.remove(at: index.row)
		updateView(CellUpdateType.remove(index))
    }
}



// MARK: - Presenter (ViewModel => View)
extension RequestListViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.categories.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isCollapsed = viewModel.categories[section].collapsed
        return isCollapsed ? 0 : viewModel.categories[section].items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ProductsCategoryHeaderView.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableViewOfType(ProductsCategoryHeaderView.self)
        header.configure(with: viewModel.categories[section])
        header.tapped = { _ in
            self.viewModel.categories[section].collapsed = !self.viewModel.categories[section].collapsed
            tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return isReadOnly || viewModel.categories[section].collapsed ? 0.001 : ProductsCategoryFooterView.height
    }
	
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard !isReadOnly else {
            return nil
        }
        let footer = tableView.dequeueReusableViewOfType(ProductsCategoryFooterView.self)
        footer.delegatedAction = {
			self.selectedSection = section
            Storage.temp[kStorageProductEntryCategory] = self.viewModel.categories[section].category
            self.performSegue(withIdentifier: type(of: self).segAddItem, sender: self)
        }
        return footer
    }
	
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		let text = viewModel.categories[indexPath.section].items[indexPath.row].item
		let height = text.heightForWithFont(UIFont.boldSystemFont(ofSize: 14.0), width: self.view.frame.width*0.35) + 37
		
        return height
    }
	
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellOfType(ProductItemCell.self)
		let productViewModel = viewModel.categories[indexPath.section].items[indexPath.row]
        cell.configure(with: productViewModel)
        cell.canEdit = !isReadOnly
		cell.delegat = {
			print ("TODO: show alert view")
			if var suggProd = productViewModel.product.suggestedProduct
			{
				let alert = UIAlertController(title: "Stoqi".localized, message: "The brand".localized + " " + suggProd.product.brand.name + " " + "have a better price. Do you want replace ?".localized, preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "ACCEPT".localized, style: .default, handler: { _ in
					self.selectedIndexPath = indexPath
					suggProd.product.category = productViewModel.product.product.category
					suggProd.units = productViewModel.product.units
					self.replaceProduct(productViewModel.product, with: suggProd)
				}))
				alert.addAction(UIAlertAction(title: "DECLINE".localized, style: .default, handler: { _ in
				}))
				self.present(alert, animated: true, completion: nil)
			}
			else
			{
				print("Invalid product")
			}
			
		}
        return cell
    }
	
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isReadOnly else {
            print("\(type(of: self)): RequestList is read-only.")
            return
        }
		selectedIndexPath = indexPath
		
        Storage.temp[kStorageProductEntry] = viewModel.categories[indexPath.section].items[indexPath.row].product
        performSegue(withIdentifier: type(of: self).segEditItem, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension String {
	
	func heightForWithFont(_ font: UIFont, width: CGFloat) -> CGFloat {
		
		let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
		label.numberOfLines = 0
		label.lineBreakMode = NSLineBreakMode.byWordWrapping
		label.font = font
		label.text = self
		
		label.sizeToFit()
		return label.frame.height
	}
}

/// Identifies entry point for the RequestList storyboard to determine navigation flow.
enum RequestListViewControllerMode {
    
    /// Entry point is Registration.
    case initial
    
    /// Entry point is User RequestList.
    case subsequent
}

enum CellUpdateType {
	case insert(Int)
	case reload(IndexPath)
	case remove(IndexPath)
	case update(IndexPath)
}
