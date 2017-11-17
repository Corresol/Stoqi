import UIKit

class ProductsCategoryFooterView: UITableViewHeaderFooterView, TSTableViewElement {
    static let height : CGFloat = 64
    
    typealias DelegatedAction = () -> Void
    
    var delegatedAction : DelegatedAction?
    
    @IBAction func addItemAction(_ sender: UIButton) {
        if let delegate = self.delegatedAction {
            delegate()
        }
    }
    
    func configure(with dataSource : Any) { /* Nothing to do here */ }
}
