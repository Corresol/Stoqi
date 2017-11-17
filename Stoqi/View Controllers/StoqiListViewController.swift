class StoqiListViewController : BaseViewController, UIPopoverPresentationControllerDelegate {
    
    fileprivate static let segBack = "segBack"
    fileprivate static let segAddItem = "segAddItem"
    
    @IBOutlet weak fileprivate var tvProducts: UITableView!
    @IBOutlet weak fileprivate var lDate: UILabel!
    
    fileprivate let manager = try! Injector.inject(StockManager.self)
    
    fileprivate var editor : EditStockProductViewController!
    fileprivate var selectedIndexPath : IndexPath?
	
	fileprivate var addingProduct: Bool = false
    
    fileprivate var viewModel : StockViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editor = EditStockProductViewController()
        editor.modalPresentationStyle = .popover
        editor.isModalInPopover = true
        editor.preferredContentSize = CGSize(width: 300, height: 140)
        editor.delegate = self
        self.lDate.text = "Today, \(Date().toString(withFormat: "dd MMM yyyy"))"
        self.tvProducts.isHidden = true
        guard let stock = self.manager.stock else {
            self.loadStock()
            return
        }
        self.viewModel = try! Injector.inject(StockViewModel.self, with: stock)
        configure(with: viewModel)
		
		tvProducts.estimatedRowHeight = ProductItemCell.height
		tvProducts.rowHeight = UITableViewAutomaticDimension
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.loadStock()
	}
    
    @IBAction func unwindAddItemSave(_ segue : UIStoryboardSegue) {
        if let controller = segue.source as? AddProductEntryViewController,
            let product = controller.product {
            addProduct(StockProduct(product: product.product,
                left: Float(product.units),
                total: Float(product.units),
				confirmed: false)) //TODO: need real value for confirmed
        }
    }
    
    @IBAction func unwindAddItemCancel(_ segue : UIStoryboardSegue) {
        
    }
    
    
    
    // Locks top-edge bouncing
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset = CGPoint.zero
        }
    }
    
    func showPopover(_ base: UIView)
    {
        if let popover = editor.popoverPresentationController {
            popover.delegate = self
            popover.sourceView = base
            popover.sourceRect = base.bounds
            popover.permittedArrowDirections = [.up, .down]
            popover.backgroundColor = StoqiPallete.darkColor
            self.present(editor, animated: true, completion: nil)
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension StoqiListViewController : StockProductEditorDelegate {
    func editor(_ editor: StockProductEditor, didEdit viewModel: StockProductViewModel) {
        guard let indexPath = selectedIndexPath else {
            return
        }
        selectedIndexPath = nil
        self.viewModel.categories[indexPath.section].items[indexPath.row] = viewModel
        tvProducts.reloadRows(at: [indexPath], with: .none)
        dismiss(animated: true, completion: nil)
    }
    
    func editorDidCancel(_ editor: StockProductEditor) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Controller
private extension StoqiListViewController {
    
    @IBAction func backAction(_ sender: UIButton) {
        self.saveStock()
        self.performSegue(withIdentifier: type(of: self).segBack, sender: self)
    }
}

// MARK: - Interactor 
private extension StoqiListViewController {
    func loadStock() {
		if addingProduct { return }
			
        TSNotifier.showProgress(withMessage: "Loading stock..", on: self.view)
        self.manager.performLoadStock(){
            TSNotifier.hideProgress(on: self.view)
            switch $0 {
            case .success(let stock):
                self.viewModel = try! Injector.inject(StockViewModel.self, with: stock)
                self.configure(with: self.viewModel)
            case .failure(let error):
				
				if error == .networkError {
					TSNotifier.notify("kNoInternetConnection".localized, withAppearance: [kTSNotificationAppearanceTextColor : UIColor.red], on: self.view)
				}
				
                let alert = UIAlertController(title: "Stoqi", message: "Failed to load your stock. Please, try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { _ in
                    self.loadStock()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func saveStock() {
        guard let stock = viewModel.stock else {
            print("Stock not available.")
            return
        }
        TSNotifier.showProgress(withMessage: "Saving stock..", on: self.view)
        self.manager.performSaveStock(stock) {
            TSNotifier.hideProgress(on: self.view)
			
			switch $0 {
			case .success(let stock):
				if self.addingProduct
				{
					self.addingProduct = false
					
					self.viewModel = try! Injector.inject(StockViewModel.self, with: stock)
					self.configure(with: self.viewModel)
				}
            case .failure(let error):
				if error == .networkError {
					TSNotifier.notify("kNoInternetConnection".localized, withAppearance: [kTSNotificationAppearanceTextColor : UIColor.red], on: self.view)
				}
				
                let alert = UIAlertController(title: "Stoqi", message: "Failed to save your stock. Please, try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { _ in
                     self.saveStock()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
					self.addingProduct = false
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func addProduct(_ product : StockProduct) {
        guard let selectedIndexPath = selectedIndexPath else {
            return
        }
        let productViewModel = try! Injector.inject(StockProductViewModel.self, with: product)
        
        addingProduct = true
		
        self.selectedIndexPath = nil
        viewModel.categories[selectedIndexPath.section].items.append(productViewModel)
        tvProducts.beginUpdates()
        tvProducts.reloadSections(IndexSet(integer: selectedIndexPath.section), with: .automatic)
        tvProducts.endUpdates()
		
		saveStock()
    }
}

// MARK: - Presenter
extension StoqiListViewController  : TSConfigurable {
    func configure(with dataSource: StockViewModel) {
        self.lDate.text = "Today, \(dataSource.date.toString(withFormat: "dd MMM yyyy"))"
        self.tvProducts.isHidden = dataSource.categories.isEmpty
        self.tvProducts.reloadData()
    }
}


extension StoqiListViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel?.categories.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isCollapsed = viewModel.categories[section].collapsed
        return isCollapsed ? 0 : self.viewModel.categories[section].items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ProductsCategoryHeaderView.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableViewOfType(ProductsCategoryHeaderView.self)
        header.configure(with: self.viewModel.categories[section])
        header.tapped = { _ in
            self.viewModel.categories[section].collapsed = !self.viewModel.categories[section].collapsed
            tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return viewModel.categories[section].collapsed ? 0.001 :ProductsCategoryFooterView.height
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableViewOfType(ProductsCategoryFooterView.self)
        footer.delegatedAction = {
            self.selectedIndexPath = IndexPath(row: 0, section: section)
            let category = self.viewModel.categories[section].category
            Storage.temp[kStorageProductEntryCategory] = category
            self.performSegue(withIdentifier: type(of: self).segAddItem, sender: self)
        }
        return footer
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		let text = viewModel.categories[indexPath.section].items[indexPath.row].item
		let height = text.heightForWithFont(UIFont.boldSystemFont(ofSize: 14.0), width: self.view.frame.width*0.35) + 63
		
		return height
    }
	
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellOfType(StockProductItemCell.self)
        cell.configure(with: self.viewModel.categories[indexPath.section].items[indexPath.row])
		cell.delegat =
		{
			self.viewModel.categories[indexPath.section].items[indexPath.row].confirmed = true
			self.tvProducts.reloadRows(at: [indexPath], with: .none)
			TSNotifier.notify("Confirmed".localized, on: self.view)
		}
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            selectedIndexPath = indexPath
            let product = viewModel.categories[indexPath.section].items[indexPath.row].product
            editor.setProduct(product)
            showPopover(cell)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

}
