class HistoryRequestCell : UITableViewCell, TSTableViewElement {
    
    @IBOutlet weak fileprivate var lDate: UILabel!
    @IBOutlet weak fileprivate var lInfo: UILabel!
    @IBOutlet weak fileprivate var vNextLine: UIView!
    
    static let height : CGFloat = 90
    
    func configure(with dataSource: HistoryRequestCellDataSource) {
        self.vNextLine.backgroundColor = dataSource.hasNextNode ? StoqiPallete.darkColor : StoqiPallete.grayColor
        self.lInfo.text = "\(dataSource.items) Items for R$ \(String(format:"%.2f",dataSource.price))"
        let date = dataSource.date.toString(withFormat: "dd MMM yyyy")
		
		let text = dataSource.date.timeIntervalSinceReferenceDate > Date().timeIntervalSinceReferenceDate ? "Waiting for delivery " : "Delivered on "
        self.lDate.text = "\(text)\(date)"
        self.contentView.backgroundColor = StoqiPallete.lightColor
    }
}

class CurrentRequestCell : UITableViewCell, TSTableViewElement {
    
    @IBOutlet weak fileprivate var lDate: UILabel!
    @IBOutlet weak fileprivate var lInfo: UILabel!
    @IBOutlet weak fileprivate var lTitle: UILabel!
    
    static let height : CGFloat = 90
    
    func configure(with dataSource: CurrentRequestCellDataSource) {
		self.lTitle.text = "Next replacement ".localized + (dataSource.autorized ? "authorized".localized : "not authorized".localized)
        self.lInfo.text = "\(dataSource.items) items for delivery between"
		
		if let startDate = dataSource.startDate?.toString(withFormat: "dd MMM"),
			let endDate = dataSource.endDate?.toString(withFormat: "dd MMM")
		{
			self.lDate.text = "\(startDate) - \(endDate)"
		}
		else
		{
			self.lDate.text = nil
		}
    }
}

// MARK: - Selection
extension CurrentRequestCell {
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.7 : 0, animations: {
            self.select(highlighted)
        })
        super.setHighlighted(highlighted, animated: animated)
    }
    
    fileprivate func select(_ selected : Bool){
        if selected {
            self.lDate.textColor = UIColor.white
            self.lTitle.textColor = UIColor.white
            self.contentView.backgroundColor = StoqiPallete.mainLightColor
        }
        else {
            self.lDate.textColor = StoqiPallete.mainColor
            self.lTitle.textColor = StoqiPallete.mainColor
            self.contentView.backgroundColor = UIColor.white
        }
    }
}

extension HistoryRequestCell {
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.7 : 0, animations: {
            self.select(highlighted)
        })
        super.setHighlighted(highlighted, animated: animated)
    }
    
    fileprivate func select(_ selected : Bool){
        if selected {
            self.contentView.backgroundColor = StoqiPallete.mainLightColor
        }
        else {
            self.contentView.backgroundColor = StoqiPallete.lightColor
        }
    }
}


protocol HistoryRequestCellDataSource {
    var items : Int {get}
    var date : Date {get}
    var price : Float {get}
    var hasNextNode : Bool {get set}
}

protocol CurrentRequestCellDataSource {
    var items : Int {get}
    var startDate : Date? {get}
    var endDate : Date? {get}
	var autorized: Bool {get}
}
