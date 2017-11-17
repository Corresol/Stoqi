import UIKit

class ProfileQuestionCell: UITableViewCell, TSTableViewElement {
    
    @IBOutlet weak fileprivate var lQuestion: UILabel!
    @IBOutlet weak fileprivate var lAnswer: UILabel!
    
    static let height : CGFloat = 80
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(with dataSource: ProfileQuestionCellDataSource) {
        self.lQuestion.text = dataSource.question
        self.lAnswer.text = dataSource.answer
    }
}

// MARK: - Selection
extension ProfileQuestionCell {
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.7 : 0, animations: {
            self.select(highlighted)
        })
        super.setHighlighted(highlighted, animated: animated)
    }
    
    fileprivate func select(_ selected : Bool){
        if selected {
            self.lQuestion.textColor = UIColor.white
            self.contentView.backgroundColor = StoqiPallete.mainLightColor
        }
        else {
            self.lQuestion.textColor = StoqiPallete.grayTextColor
            self.contentView.backgroundColor = UIColor.white
        }
    }
}

protocol ProfileQuestionCellDataSource {
    var question : String {get}
    var answer : String? {get}
}
