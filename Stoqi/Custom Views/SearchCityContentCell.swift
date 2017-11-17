import UIKit

class SearchCityContentCell : UITableViewCell, TSTableViewElement {
    
    @IBOutlet weak fileprivate var lResult: UILabel!
    
    fileprivate var style : SearchCityContentCellStyle = DefaultStyle()
    
    func configure(with dataSource: SearchPropertyLocationContentCellDataSource) {
        let text = "\(dataSource.city), \(dataSource.region)"

        if let term = dataSource.matchingTerm {
            let nsText = text as NSString
            let attributedString = NSMutableAttributedString(string: text, attributes: [NSForegroundColorAttributeName : style.defaultTextColor])
            var range = nsText.range(of: term, options: .caseInsensitive, range: NSRange(location: 0, length: nsText.length))
            while range.location != NSNotFound {
                attributedString.addAttributes(
                    [NSForegroundColorAttributeName : self.style.matchingTextColor,
                        NSFontAttributeName : UIFont.boldSystemFont(ofSize: 16)], range: range)
                let nextLocation = range.location + range.length
                range = nsText.range(of: term, options: .caseInsensitive, range: NSRange(location: nextLocation, length: nsText.length - nextLocation))
            }
            self.lResult.attributedText = attributedString
        } else {
            self.lResult.text = text
            self.lResult.textColor = self.style.defaultTextColor
        }
    }
    
    func style(with styleSource: SearchCityContentCellStyle) {
        self.style = StyleHolder(style: styleSource)
    }
}

protocol SearchPropertyLocationContentCellDataSource {
    var city : String {get}
    var region : String {get}
    var matchingTerm : String? {get}
}

protocol SearchCityContentCellStyle {
    var defaultTextColor : UIColor {get}
    var matchingTextColor : UIColor {get}
}

private struct StyleHolder : SearchCityContentCellStyle {
    var defaultTextColor: UIColor
    var matchingTextColor: UIColor
    
    init(style : SearchCityContentCellStyle) {
        self.defaultTextColor = style.defaultTextColor
        self.matchingTextColor = style.matchingTextColor
    }
}

private struct DefaultStyle : SearchCityContentCellStyle {
    var defaultTextColor: UIColor {
        return StoqiPallete.grayTextColor
    }
    
    var matchingTextColor: UIColor {
        return StoqiPallete.mainColor
    }
}
