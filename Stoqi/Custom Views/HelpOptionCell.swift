class HelpOptionCell: UITableViewCell, TSTableViewElement {
    
    @IBOutlet weak fileprivate var ivIcon: UIImageView!
    @IBOutlet weak fileprivate var lTitle: UILabel!
    @IBOutlet weak fileprivate var ivOpen: UIImageView!
    
    static var height : CGFloat {
        return 90
    }
    
    func configure(with dataSource: HelpOptionCellDataSource) {
        ivIcon.image = dataSource.icon
        lTitle.text = dataSource.title
        ivOpen.isHidden = !dataSource.canOpen
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            if animated {
                UIView.transition(with: self,
                                          duration:0.5,
                                          options: UIViewAnimationOptions.transitionCrossDissolve,
                                          animations: { self.setSelected() },
                                          completion: nil)
            } else {
                self.setSelected()
            }
            
        } else {
            self.selectedBackgroundView = nil
        }
    }
    
    fileprivate func setSelected() {
        self.selectedBackgroundView = UIImageView(image: UIImage(named:"misc_background"))
    }
    
}

protocol HelpOptionCellDataSource {
    var title : String {get}
    var icon : UIImage {get}
    var canOpen : Bool {get}
}
