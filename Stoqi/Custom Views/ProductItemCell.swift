class ProductItemCell: UITableViewCell, TSTableViewElement {
    static let height : CGFloat = 60
    
    @IBOutlet weak fileprivate var lQuantity: UILabel!
    @IBOutlet weak fileprivate var lTitle: UILabel!
    @IBOutlet weak fileprivate var lBrand: UILabel!
    @IBOutlet weak fileprivate var lDetails: UILabel!
    @IBOutlet weak fileprivate var ivEditable: UIImageView!
	@IBOutlet weak fileprivate var bInfo: UIButton!
	
	var delegat : CellDelegate?
	
    var canEdit : Bool = true {
        didSet {
            self.ivEditable.isHidden = !canEdit
			self.bInfo.isHidden = self.bInfo.isHidden || !canEdit
        }
    }
    
    func configure(with dataSource: ProductItemCellDataSource) {
        self.lQuantity.text = "\(dataSource.quantity)"
        self.lTitle.text = dataSource.item
        self.lBrand.text = dataSource.brand
        self.lDetails.text = dataSource.details
		
		self.bInfo.isHidden = !dataSource.suggested
    }
}

// MARK: - Selection
extension ProductItemCell {
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.7 : 0, animations: {
                self.select(highlighted)
            })
        super.setHighlighted(highlighted, animated: animated)
    }
    
    fileprivate func select(_ selected : Bool){
        if selected {
            self.lTitle.textColor = UIColor.white
            self.contentView.backgroundColor = StoqiPallete.mainLightColor
        }
        else {
            self.lTitle.textColor = StoqiPallete.mainColor
            self.contentView.backgroundColor = UIColor.white
        }
    }
	
	typealias CellDelegate = () -> Void
	
	@IBAction func onInfo(_ sender: AnyObject) {
		self.delegat?()
	}
}


protocol ProductItemCellDataSource {
    var item : String {get}
    var quantity : Int {get}
    var brand : String {get}
    var details : String {get}
	var suggested : Bool {get}
}
