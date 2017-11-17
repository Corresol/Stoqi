class ProfilePayMethodCell: UITableViewCell, TSTableViewElement {
    
    @IBOutlet weak fileprivate var ivImage: UIImageView!
    @IBOutlet weak fileprivate var lCard: UILabel!
    @IBOutlet weak fileprivate var ivValid: UIImageView!
    
    func configure(with dataSource: ProfilePayMethodCellDataSource) {
        
        let card = dataSource.cardNumber
		let cardLength : Int = card.characters.count
		let index = (cardLength > 4 ? card.characters.index(card.endIndex, offsetBy: -4) : card.startIndex)
		let lastDigits =  card.substring(from: index)
		self.lCard.text = "•••• \(lastDigits)"
		self.ivImage.image = dataSource.cardTypeImage
		self.ivValid.isHidden = !dataSource.isPrimary
    }
}

// MARK: - Selection
extension ProfilePayMethodCell {
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
            self.contentView.backgroundColor = UIColor.white
        }
    }
}

protocol ProfilePayMethodCellDataSource {
    var cardTypeImage : UIImage {get}
	var isPrimary : Bool {get}
    var cardNumber : String {get}
    var isValid : Bool {get}
}
