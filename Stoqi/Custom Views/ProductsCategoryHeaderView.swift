typealias HeaderTapped = () -> Void

class ProductsCategoryHeaderView : UITableViewHeaderFooterView, TSTableViewElement {
    
    @IBOutlet weak fileprivate var lTitle: UILabel!
    @IBOutlet weak fileprivate var lItems: UILabel!
    @IBOutlet weak fileprivate var ivIndicator: UIImageView!
    @IBOutlet weak fileprivate var bHeader: TSButton!
    
    static let height : CGFloat = 64
    
    var tapped : HeaderTapped? {
        didSet {
            if tapped != nil {
                bHeader?.didTouchUpInside = { _ in
                    self.tapped?()
                }
            }
        }
    }
    
    func configure(with dataSource: ProductsCategoryHeaderViewDataSource) {
        self.ivIndicator.image = UIImage(named: dataSource.collapsed ? "misc_expander_selected" : "misc_expander")
        self.lTitle.text = dataSource.title.uppercased()
        let label = dataSource.count == 1 ? "Item" : "Items"
        self.lItems.text = "\(dataSource.count) \(label)"
    }
}

protocol ProductsCategoryHeaderViewDataSource {
    var title : String {get}
    var count : Int {get}
    var collapsed : Bool {get set}
}
