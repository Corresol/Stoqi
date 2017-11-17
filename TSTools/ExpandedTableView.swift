/// UITableView subclass which will resize itself to fit content without scrolling.
class ExpandedTableView: UITableView {
    
    override var contentSize : CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    
    override var intrinsicContentSize : CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIViewNoIntrinsicMetric, height: self.contentSize.height)
    }
    
}
