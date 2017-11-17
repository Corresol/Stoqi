class ProfileDeliveryCell: UITableViewCell, TSTableViewElement {
    
    @IBOutlet weak fileprivate var lAddress: UILabel!
    
    
    func configure(with dataSource: ProfileDeliveryCellDataSource) {
        self.lAddress.text = dataSource.fullAddress ?? "No address set"
    }
}

// MARK: - Selection
extension ProfileDeliveryCell {
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

protocol ProfileDeliveryCellDataSource {
    var fullAddress : String? {get}
}
