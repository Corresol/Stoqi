class CommonHeaderView: UITableViewHeaderFooterView, TSTableViewElement {
    
    @IBOutlet weak fileprivate var lTitle: UILabel!
    
    func configure(with dataSource: CommonHeaderViewDataSource) {
        self.lTitle.text = dataSource.title
    }
    
    func style(with styleSource: CommonHeaderViewStyleSource) {
        self.backgroundView = UIView()
        self.backgroundView!.backgroundColor = styleSource.backgroundColor
        self.lTitle.textColor = styleSource.titleColor
    }
    
    
}


protocol CommonHeaderViewDataSource {
    var title : String {get}
}

protocol CommonHeaderViewStyleSource {
    var titleColor : UIColor {get}
    var backgroundColor : UIColor {get}
}


struct SimpleCommonHeaderViewDataSource : CommonHeaderViewDataSource {
    var title: String
}

struct SimpleCommonHeaderViewStyleSource : CommonHeaderViewStyleSource {
    var titleColor: UIColor
    var backgroundColor: UIColor
}
