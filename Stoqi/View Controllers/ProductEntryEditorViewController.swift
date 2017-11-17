import UIKit

protocol ProductEntryEditorDelegate {
    func editor(_ editor : ProductEntryEditor, didEditProductEntry product : ProductViewModel)
}

protocol ProductEntryEditor {
    var viewModel : ProductViewModel! {get}
    var isEdited : Bool {get}
    var delegate : ProductEntryEditorDelegate? {get set}
    
    func setProduct(_ entry : ProductEntry)
    func setCategory(_ category : Category)
}

class ProductEntryEditorViewController: StandaloneViewController, ProductEntryEditor {

    fileprivate let manager = try! Injector.inject(ProductsManager.self)
    
    @IBOutlet weak fileprivate var bSelectProduct: TSOptionButton!
    @IBOutlet weak fileprivate var bSelectBrand: TSOptionButton!
    @IBOutlet weak fileprivate var bSelectDescription: TSOptionButton!
    @IBOutlet weak fileprivate var lUnits: UILabel!
    @IBOutlet weak fileprivate var sUnits: UIStepper!
    
    fileprivate var kindPickerDataSource : PickerDataSource?
    fileprivate var brandPickerDataSource : PickerDataSource?
    fileprivate var volumePickerDataSource : PickerDataSource?
  
    fileprivate var originalProduct : ProductEntry? = nil
    
    var delegate : ProductEntryEditorDelegate?
    var viewModel : ProductViewModel! {
        didSet {
            if self.isLoaded, let vm = self.viewModel {
                self.configure(with: vm)
                delegate?.editor(self, didEditProductEntry: viewModel)
            }
            
        }
    }
    
    var useAccentTheme : Bool = false
    
    var isEdited : Bool {
        guard let originalProduct = originalProduct else {
            return true
        }
        guard let product = viewModel.productEntry else {
            return false
        }
        return originalProduct !== product
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configure(with: self.viewModel)
        applyTheme()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
		
		[bSelectProduct, bSelectBrand, bSelectDescription].forEach {
			$0?.circle = true
			$0?.imageAlignment = .right
		}
    }
    
    fileprivate func applyTheme() {
        let color = useAccentTheme ? StoqiPallete.accentColor : StoqiPallete.mainColor
        [bSelectProduct, bSelectBrand, bSelectDescription].forEach {
            $0?.setTitleColor(color, for: UIControlState())
            $0?.setTitleColor(color, for: .selected)
            $0?.tintColor = color
        }
        lUnits.textColor = color
   //     sUnits.tintColor = color
    }

    fileprivate func configureKindDataSource(withCategory category: Category) {
        let kinds = self.manager.products!.filter{$0.category == category}.map{$0.kind}.distinct
        self.kindPickerDataSource = try! Injector.inject(PickerDataSource.self, with: kinds)
        if let single = kinds.first, kinds.count == 1 {
			let item = try! Injector.inject(PickerItemViewModel.self, with: single)
            self.kindPickerDataSource?.initialValue = item
			self.viewModel.kind = item as? KindPickerItemViewModel
			configureBrandDataSource(withKind: single)
        }
//		else
//		{
//			self.kindPickerDataSource?.initialValue = nil
//			self.viewModel.kind = nil
//		}
    }
    
    fileprivate func configureBrandDataSource(withKind kind: Kind) {
        let brands = self.manager.products!.filter{$0.kind == kind}.map{$0.brand}.distinct
        self.brandPickerDataSource = try! Injector.inject(PickerDataSource.self, with: brands)
        if let single = brands.first, brands.count == 1 {
			let item = try! Injector.inject(PickerItemViewModel.self, with: single)
            self.brandPickerDataSource?.initialValue = item
			self.viewModel.brand = item as? BrandPickerItemViewModel
			configureVolumeDataSource(withKind: kind, andBrand: single)
        }
//		else
//		{
//			self.brandPickerDataSource?.initialValue = nil
//			self.viewModel.brand = nil
//		}
    }
    
    fileprivate func configureVolumeDataSource(withKind kind: Kind, andBrand brand : Brand) {
        let volumes = self.manager.products!.filter{$0.kind == kind && $0.brand == brand}
            .map{$0.volume}.distinct
        self.volumePickerDataSource = try! Injector.inject(PickerDataSource.self, with: volumes)
        if let single = volumes.first, volumes.count == 1 {
			let item = try! Injector.inject(PickerItemViewModel.self, with: single)
            self.volumePickerDataSource?.initialValue = item
			self.viewModel.volume = item as? VolumePickerItemViewModel
        }
		else
		{
			self.volumePickerDataSource?.initialValue = nil
			self.viewModel.volume = nil
		}
    }

}

extension ProductEntryEditorViewController {
    func setProduct(_ product : ProductEntry) {
        self.viewModel = try! Injector.inject(ProductViewModel.self, with: product)
        self.originalProduct = product
        self.configureKindDataSource(withCategory: product.product.category)
        self.configureBrandDataSource(withKind: product.product.kind)
        self.configureVolumeDataSource(withKind: product.product.kind, andBrand: product.product.brand)
        
        self.kindPickerDataSource?.initialValue = try! Injector.inject(PickerItemViewModel.self, with: product.product.kind)
        self.brandPickerDataSource?.initialValue = try! Injector.inject(PickerItemViewModel.self, with: product.product.brand)
        self.volumePickerDataSource?.initialValue = try! Injector.inject(PickerItemViewModel.self, with: product.product.volume)
    }
    
    func setCategory(_ category : Category) {
        self.viewModel = try! Injector.inject(ProductViewModel.self, with: category)
        self.configureKindDataSource(withCategory: category)
        self.originalProduct = nil
    }
}

extension ProductEntryEditorViewController {
    // TODO: Optimize picking products
    @IBAction func optionAction(_ sender: TSOptionButton) {
        switch sender {
        case self.bSelectProduct:
            self.openPicker(self.kindPickerDataSource!, trigger: sender, selectedBlock: { (index, value) in
                self.kindPickerDataSource?.initialValue = value
                let kind = value as! KindPickerItemViewModel
                self.configureBrandDataSource(withKind: kind.kind)
                self.viewModel.kind = kind
            })
        case self.bSelectBrand:
            self.openPicker(self.brandPickerDataSource!, trigger: sender, selectedBlock: { (index, value) in
                self.brandPickerDataSource?.initialValue = value
                let brand = value as! BrandPickerItemViewModel
                self.configureVolumeDataSource(withKind: self.viewModel.kind!.kind, andBrand: brand.brand)
                self.viewModel.brand = brand
            })
        case self.bSelectDescription:
            self.openPicker(self.volumePickerDataSource!, trigger: sender, selectedBlock: { (index, value) in
                self.volumePickerDataSource?.initialValue = value
                self.viewModel.volume = (value as! VolumePickerItemViewModel)
            })
        default: break
        }
    }
    
    @IBAction func unitsChangedAction(_ sender : UIStepper) {
        self.viewModel.units = Int(sender.value)
    }

}

// MARK: Presenter
extension ProductEntryEditorViewController : TSConfigurable {
    func configure(with dataSource: ProductViewModel) {
        self.bSelectProduct.isEnabled = !(self.kindPickerDataSource?.values.isEmpty ?? true)
        self.bSelectBrand.isEnabled = !(self.brandPickerDataSource?.values.isEmpty ?? true)
        self.bSelectDescription.isEnabled = !(self.volumePickerDataSource?.values.isEmpty ?? true)
        self.bSelectProduct.setTitle(dataSource.kind?.itemText, for: UIControlState())
        self.bSelectBrand.setTitle(dataSource.brand?.name, for: UIControlState())
        self.bSelectDescription.setTitle(dataSource.volume?.itemText, for: UIControlState())
        self.lUnits.text = "\(dataSource.units)"
        self.sUnits.value = Double(dataSource.units)
    }
}
