import UIKit

@IBDesignable
class TSViewControllerNavEx: UIViewController {
    
    @IBInspectable var navigationBarColor : UIColor?
    
    var customLeftButton : UIView? {
        return nil
    }
    
    var backButton : UIView? {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.customLeftButton ?? self.backButton {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: view)
        }
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let color = self.navigationBarColor {
            setNavigationBarColor(color)
        }
        super.viewWillAppear(animated)
    }
    
    fileprivate func setNavigationBarColor(_ color:UIColor){
        if let navBar = self.navigationController?.navigationBar {
            navBar.barTintColor = color
        }
    }
}
