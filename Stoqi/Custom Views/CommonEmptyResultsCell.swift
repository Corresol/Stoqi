import UIKit

class CommonEmptyResultsCell : UITableViewCell, TSTableViewElement {
    
    @IBOutlet weak fileprivate var lMessage: UILabel!
    
    func configure(with dataSource: CommonEmptyResultsCellDataSource) {
        self.lMessage.text = dataSource.message
    }
}

protocol CommonEmptyResultsCellDataSource {
    var message : String {get}
}
