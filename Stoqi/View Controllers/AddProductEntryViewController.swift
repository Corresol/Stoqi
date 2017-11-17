let kStorageProductEntryCategory = "kStorageProductEntryCategory"
let kStorageScannerTutorial = "kStorageScannerTutorial"

class AddProductEntryViewController : EmbedingViewController, ProductEntryEditorDelegate, UIScrollViewDelegate {

    fileprivate static let segAddProduct = "segAddProduct"
    fileprivate static let segTutorial = "segTutorial"
   
    fileprivate let manager = try! Injector.inject(ProductsManager.self)
    
    @IBOutlet fileprivate weak var bAdd: UIButton!
    @IBOutlet fileprivate weak var bScanner: UIButton!
    
    @IBInspectable var useAccentTheme : Bool = false
    fileprivate var editor : ProductEntryEditor!
    
    var product : ProductEntry? {
        guard let entry = editor?.viewModel?.productEntry else {
            return nil
        }
        let product = entry.product
        return manager.products?.filter {
            $0.brand == product.brand &&
                $0.kind == product.kind &&
                $0.volume == product.volume
            }.first.flatMap { ProductEntry(product: $0, units: entry.units, suggestedProduct: entry.suggestedProduct) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let controller = embed(ProductEntryEditorViewController.self)
        controller.delegate = self
        controller.useAccentTheme = useAccentTheme
        editor = controller
        let showTutorial = Storage.local[kStorageScannerTutorial] as? Bool ?? true
        if showTutorial {
            performSegue(withIdentifier: type(of: self).segTutorial, sender: self)
            Storage.local[kStorageScannerTutorial] = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let category = Storage.temp.popObjectForKey(kStorageProductEntryCategory) as? Category else {
            print("\(type(of: self)): Category was not set.")
            return
        }
        editor.setCategory(category)
        let categoryName = category.name.capitalized
        bAdd.setTitle("Add in \(categoryName)", for: UIControlState())
    }
    
    func editor(_ editor: ProductEntryEditor, didEditProductEntry product: ProductViewModel) {
        bAdd.isEnabled = product.isValid
    }
    
    // Locks top-edge bouncing
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset = CGPoint.zero
        }
    }
}

extension AddProductEntryViewController : UIPopoverPresentationControllerDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination.popoverPresentationController else {
            return
        }
        controller.delegate = self
        controller.sourceRect = bScanner.bounds
        controller.sourceView = bScanner
        segue.destination.isModalInPopover = true
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension AddProductEntryViewController {
    @IBAction func addAction(_ sender: UIButton) {
        addProduct()
    }
    
    @IBAction func closeScannerTutorial(_ segue : UIStoryboardSegue) {}
    @IBAction func unwindScannerCancel(_ segue : UIStoryboardSegue) {}
    @IBAction func unwindScannerScanned(_ segue : UIStoryboardSegue) {
        guard let scanner = segue.source as? ScannerViewController, let product = scanner.product else {
            return
        }
        let entry = ProductEntry(product: product, units: 1, suggestedProduct: nil)
        editor.setProduct(entry)
    }
}

extension AddProductEntryViewController {
    func addProduct() {
        guard var product = self.editor.viewModel?.productEntry else {
            TSNotifier.notify("Please, fill in all product details", withAppearance: [kTSNotificationAppearanceTextColor : UIColor.red])
            return
        }
        
        guard let registeredProduct = self.manager.products?.filter({$0 === product.product}).first else {
            print("\(type(of: self)): No matching product found in database.")
            return
        }
        product.product = registeredProduct
        performSegue(withIdentifier: type(of: self).segAddProduct, sender: self)
    }

}
