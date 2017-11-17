import UIKit

class IntroViewController: TSPageViewController, TSPageViewControllerDelegate {
    
    fileprivate let pageIdentifiers = ["introPage1", "introPage2", "introPage3", "introPage4", "introPage5", "introPage6", "introPage7"]
    
    @IBOutlet weak var vToolbar: UIView!
    @IBOutlet weak fileprivate var bSkip: UIButton!
    
    override func viewDidLoad() {
        self.setPages(withIdentifiers: pageIdentifiers)
        self.pageControllerDelegate = self
        self.pageControl?.delegate = self
        self.pageControl?.indicatorViewType = .color(colors:(defaultColor: StoqiPallete.lightColor, activeColor:StoqiPallete.darkColor))
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.showPage(atIndex: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func pageController(_ pageController: TSPageViewController, didShowViewController controller: UIViewController, forPageAtIndex index: Int) {
        let title = (index == pageIdentifiers.count - 1 ? "Close" : "Skip Intro")
        self.bSkip.setTitle(title, for: UIControlState())
    }
    
    func pageController(_ pageController: TSPageViewController, instantiateViewControllerWithIdentifier identifier: String) -> UIViewController {
        return self.storyboard!.instantiateViewController(withIdentifier: identifier)
    }
    
    override func pageControl(_ pageControl : TSPageControl, customizeIndicatorView view : UIView, atIndex index : Int) {
        view.circle = true
    }
    
    @IBAction func unwindToStart(_ segue : UIStoryboardSegue) {}
} 
