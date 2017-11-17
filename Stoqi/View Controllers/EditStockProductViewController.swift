protocol StockProductEditorDelegate {
    func editor(_ editor : StockProductEditor, didEdit viewModel : StockProductViewModel)
    func editorDidCancel(_ editor : StockProductEditor)
}

protocol StockProductEditor {
    var viewModel : StockProductViewModel! {get}
    var delegate : StockProductEditorDelegate? {get set}
    func setProduct(_ product : StockProduct)
}

class EditStockProductViewController: StandaloneViewController, StockProductEditor {
    var delegate: StockProductEditorDelegate?
    var viewModel: StockProductViewModel! {
        didSet {
            if let viewModel = viewModel, isViewLoaded {
                configure(with: viewModel)
            }
        }
    }
    
    @IBOutlet fileprivate weak var sUnits: UIStepper!
    @IBOutlet fileprivate weak var lUnits: UILabel!
    @IBOutlet fileprivate weak var lUnitsLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let viewModel = viewModel {
            configure(with: viewModel)
        }
    }
    
    func setProduct(_ product: StockProduct) {
        viewModel = try! Injector.inject(StockProductViewModel.self, with: product)
    }
}

extension EditStockProductViewController : TSConfigurable {
    func configure(with dataSource: StockProductViewModel) {
        let left = dataSource.left.truncatingRemainder(dividingBy: 0.5) == 0 ? String(format: "%.1f", dataSource.left) : String(format: "%.2f",dataSource.left)
        lUnits.text = left
        lUnitsLabel.text = dataSource.left == 1.0 ? "Unit" : "Units"
        sUnits.value = Double(dataSource.left)
        sUnits.maximumValue = Double(dataSource.total)
    }
}


extension EditStockProductViewController {
    
    @IBAction func unitsChangedAction(_ sender: UIStepper) {
        viewModel.left = Float(sender.value)
		viewModel.confirmed = true
    }
    
    @IBAction func changeAction(_ sender: UIButton) {
        delegate?.editor(self, didEdit: viewModel)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        delegate?.editorDidCancel(self)
    }
}
