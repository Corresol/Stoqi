let kStorageProductEntry = "kStorageProductEntryValue"

class EditProductEntryViewController : EmbedingViewController, ProductEntryEditorDelegate {
    
    fileprivate static let segSaveProduct = "segSaveProduct"
    fileprivate static let segDeleteProduct = "segDeleteProduct"
    fileprivate static let segCancel = "segCancel"

    fileprivate let manager = try! Injector.inject(ProductsManager.self)

    @IBOutlet weak fileprivate var bDelete: UIButton!
    @IBOutlet weak fileprivate var bSave: UIButton!
    
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
        editor = embed(ProductEntryEditorViewController.self)
        editor.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let product = Storage.temp[kStorageProductEntry] as? ProductEntry else {
            print("\(type(of: self)): Product entry not found.")
            return
        }
        editor.setProduct(product)
    }

    func editor(_ editor: ProductEntryEditor, didEditProductEntry product: ProductViewModel) {
        self.bSave.isEnabled = product.isValid
    }
}

// MARK: Controller
extension EditProductEntryViewController {
    
    @IBAction func saveAction(_ sender: UIButton) {
        self.saveProduct()
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        self.deleteProduct()
    }
}

// MARK: Interactor
extension EditProductEntryViewController {
    func saveProduct() {
        guard var product = self.editor.viewModel?.productEntry else {
            TSNotifier.notify("Please, fill in all product details", withAppearance: [kTSNotificationAppearanceTextColor : UIColor.red])
            return
        }

        guard self.editor.isEdited else {
            self.performSegue(withIdentifier: type(of: self).segCancel, sender: self)
            return
        }
        
        guard let registeredProduct = self.manager.products?.filter({$0 === product.product}).first else {
            return
        }
        product.product = registeredProduct
        TSNotifier.notify("Product saved!")
        self.performSegue(withIdentifier: type(of: self).segSaveProduct, sender: self)
    }
    
    func deleteProduct() {
        TSNotifier.notify("Product removed!")
        self.performSegue(withIdentifier: type(of: self).segDeleteProduct, sender: self)
    }
}
