import UIKit

@objc class TSButton: UIButton {
    typealias DidTapButton = (TSButton) -> ()
    
    var didTouchUpInside: DidTapButton? {
        didSet {
            if didTouchUpInside != nil {
                addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
            } else {
                removeTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
            }
        }
    }
    
    // MARK: - Actions
    
    func didTouchUpInside(_ sender: UIButton) {
        if let handler = didTouchUpInside {
            handler(self)
        }
    }
}
