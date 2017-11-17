class ArticleCell: UITableViewCell, TSTableViewElement {
    static let height : CGFloat = 180
    
    @IBOutlet weak fileprivate var lTitle: UILabel!
    @IBOutlet weak fileprivate var lDescription: UILabel!
    
    var delegate : CellDelegate?
    
    func configure(with dataSource: ArticleCellDataSource) {
        self.lTitle.text = dataSource.title
        self.lDescription.text = dataSource.description
    }
    
    func style(with styleSource: ArticleCellStyleSource) {
        if let image = styleSource.backgroundImage {
            self.backgroundView = UIImageView(image: image)
            (self.backgroundView as! UIImageView).contentMode = .scaleAspectFill
            let shadowView = UIView(frame: self.bounds)
            shadowView.backgroundColor = UIColor(alpha: 128, white: 32)
            self.backgroundView?.addSubview(shadowView)
        } else if let color = styleSource.backgroundColor {
            self.backgroundView = UIView()
            self.backgroundView!.backgroundColor = color
        }
    }
    
    typealias CellDelegate = () -> Void
    
    @IBAction fileprivate func readMoreAction(_ sender: AnyObject) {
        self.delegate?()
    }
}

protocol ArticleCellDataSource {
    var title : String {get}
    var description : String {get}
}

protocol ArticleCellStyleSource {
    var backgroundColor : UIColor? {get}
    var backgroundImage : UIImage? {get}
}

extension ArticleCellStyleSource {
    var backgroundColor : UIColor? {
        return nil
    }
    
    var backgroundImage : UIImage? {
        return nil
    }
}
