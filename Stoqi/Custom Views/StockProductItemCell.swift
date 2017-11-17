class StockProductItemCell: UITableViewCell, TSTableViewElement {
    static let height : CGFloat = 80
    
    @IBOutlet weak fileprivate var lTitle: UILabel!
    @IBOutlet weak fileprivate var lBrand: UILabel!
    @IBOutlet weak fileprivate var lDetails: UILabel!
    @IBOutlet weak fileprivate var lUnits: UILabel!
    @IBOutlet weak fileprivate var pvStock: UIProgressView!
	@IBOutlet weak var bConfirm: UIButton!
	
	var delegat : CellDelegate?
    
    func configure(with dataSource: StockProductItemCellDataSource) {
        self.lTitle.text = dataSource.item
        self.lBrand.text = dataSource.brand
        self.lDetails.text = dataSource.details
        let progress = dataSource.left / dataSource.total
//        let stringProgress = progress % 0.5 == 0 ? String(format: "%.1f", progress) : String(format: "%.2f", progress)
//        self.lUnits.text = "\(stringProgress) units"
        self.pvStock.progress = progress
		
		self.bConfirm.isHidden = dataSource.confirmed
        
        
        let left = dataSource.left.truncatingRemainder(dividingBy: 0.5) == 0 ? String(format: "%.1f", dataSource.left) : String(format: "%.2f",dataSource.left)
        self.lUnits.text = "\(left) \(dataSource.left == 1.0 ? "Unit" : "Units")"
//        
//        lUnits.text = left
//        lUnitsLabel.text =
//        sUnits.value = Double(dataSource.left)
//        sUnits.maximumValue = Double(dataSource.total)
    }
}

// MARK: - Selection
extension StockProductItemCell {
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.7 : 0, animations: {
            self.select(highlighted)
        })
        super.setHighlighted(highlighted, animated: animated)
    }
    
    fileprivate func select(_ selected : Bool){
        if selected {
            self.lTitle.textColor = UIColor.white
            self.contentView.backgroundColor = StoqiPallete.lightColor
        }
        else {
            self.lTitle.textColor = StoqiPallete.accentColor
            self.contentView.backgroundColor = UIColor.white
        }
    }
	
	typealias CellDelegate = () -> Void
	
	@IBAction func onConfirm(_ sender: AnyObject) {
		self.delegat?()
	}
    
}


protocol StockProductItemCellDataSource {
    var item : String {get}
    var total : Float {get}
    var left : Float {get}
    var brand : String {get}
    var details : String {get}
	var confirmed : Bool {get set}
}
