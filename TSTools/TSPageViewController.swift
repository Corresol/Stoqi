	import UIKit

/**
 `UIViewController` subclass designed to simplify implementation of `UIPageViewController` via embedding it into self and providing various methods for configuration.
 
 ### Key Features:
    * Powerful delegation for each state of `UIPageViewController`.
    * Easily embedding `UIPageViewController` into nested views.
    * Simple implementation.
    * Provides `TSPageControl` as custom page indicator which is highly configurable.
 
 
 - Note: Designed to be subclassed.
 
 - Requires:
     * TSViewControllerNavEx.swift
     * TSPageControl.swift
     * TSArchitectureBase.swift
 
 ### 1. Setup:
    1. Subclass
    2. Conform to `TSPageViewControllerDelegate` and assign self to `pageControllerDelegate` (or define your own delegate).
    3. Define pages identifiers.
    4. In case you use `UIStoryboard` to create view controller's interface assign corresponding identifiers to those view controllers in Interface Builder.
    5. Implement delegate's `pageController(_, instantiateViewControllerWithIdentifier:)` method to define how `UIViewController`s for pages will be created. \
    If using `UIStoryboard` you usually would do something like following:
    ```
        func pageController(pageController: TSPageViewController, instantiateViewControllerWithIdentifier identifier: String) -> UIViewController {
            return self.storyboard!.instantiateViewControllerWithIdentifier(identifier)
        }
    ```
 
 ### 2. Handling page switching:
    1. Do **Setup**
    2. Implement delegate's one of two available `pageController(_, didShowViewController:, _)` to do whatever you want when page is switched.
 
 ### 3. Some advanced features:
    1. Access view controller which is next or previous to current while swiping pages:
        * `pageController(_, willShowViewController:, _)`
        * `pageController(_, didCancelShowViewController:, _)`
 
    2. Customize `pageControl`'s indicators appearance:
        1. Set `pageControl` property to use custom `TSPageControl`.
        2. Set `pageControl?.indicatorViewType` to one of the predefined types.
        3. For more details see `TSPageControl`.
 
 - Version:    1.0
 - Since:      9/23/2016
 - Author:     AdYa
 */
@IBDesignable
class TSPageViewController : TSViewControllerNavEx, TSPageControlDelegate {
    
    /// Delegate which will be notified about all `TSPageViewController`'s events.
    var pageControllerDelegate : TSPageViewControllerDelegate?
    
    /// Custom page control to be used as page indicator.
    /// - Note: If set to nil and `useDefaultPageIndicator = false` there won't be any indicator.
    @IBOutlet var pageControl : TSPageControl? {
        didSet {
            self.updatePageControl()
        }
    }
    
    /// Index of the currently displayed view controller.
    fileprivate(set) var currentIndex : Int = 0 {
        didSet {
            self.pageControl?.currentIndicator = self.currentIndex
        }
    }
    
    var currentIdentifier : String? {
        return self.pageIdentifiers?[self.currentIndex]
    }
    
    /// Captures identifiers of the view controllers to be displayed.
    fileprivate var pageIdentifiers : [String]? {
        didSet {
            self.updatePageControl()
            self.updatePages()
        }
    }
    
    /// Target `UIView` to which `UIPageViewController` will be embedded.
    @IBOutlet weak fileprivate var pageContentView : UIView!
    
    /// If `true` `TSPaeViewController` will use default `UIPageViewController` indicator instead of custom one.
    /// - Note: Use it if you don't need any custom indicators.
    @IBInspectable var useDefaultPageIndicator : Bool = false {
        didSet {
            self.updatePageControl()
            self.updatePageViewControllerHelper()
        }
    }
    
    @IBInspectable var allowGesureBasedNavigation : Bool = true {
        didSet {
            self.updatePageViewControllerHelper()
        }
    }
    
    /// When `TSPageViewController` uses custom `pageControl` this property enables or disables user interaction on `pageControl`, allowing user to switch pages by tapping on indicators.
    @IBInspectable var allowPageControlSwitchPages : Bool = true {
        didSet {
            self.updatePageControl()
        }
    }
    
    /// Internal `UIPageViewController`
    fileprivate var pageViewController : UIPageViewController!

    /// Internal helper which implements `UIPageViewController`'s `Delegate` and `DataSource`.
    fileprivate var helper : TSPageViewControllerHelper!
    
    /// Cached instantiated `UIViewController`s
    fileprivate var pageViewControllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        self.updatePageControl()
        self.updatePageViewControllerHelper()
        
        self.addChildViewController(self.pageViewController)
        let viewName = (self.pageContentView != nil ? "root view" : "content view")
        let targetView : UIView = self.pageContentView ?? self.view
        self.pageContentView = targetView   // if targetView contains root view set reference to pageContentView
        targetView.addSubview(self.pageViewController.view)
        self.pageViewController!.didMove(toParentViewController: self)
        self.pageViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.constraintPageContentView()
        self.pageControllerDelegate?.pageController(self, didEmbedPageViewController: self.pageViewController, toContentView: targetView)
        
        print("\(type(of: self)): Page controller did embed UIPageViewController to \(viewName)")
    }
    
    /// Sets page indentifiers to be used to instantiate `UIViewController`s and updating own state.
    /// - Parameter pages: Array of `TSIdentifiable` types which provides identifiers.
    func setPages<T : TSIdentifiable> (withTypes pages : [T.Type]) {
        self.setPages(withIdentifiers:pages.map{$0.identifier})
    }
    
    /// Sets page indentifiers to be used to instantiate `UIViewController`s and updating own state.
    /// - Parameter pages: Array of page identifiers.
    func setPages(withIdentifiers pages : [String]) {
        self.pageIdentifiers = pages
        self.updatePages()
    }
    
    /// Shows page with given identifier if it's registered.
    /// - Parameter identifier: Identifier of the page to e shown.
    func showPage(withIdentifier identifier: String) {
        guard let index = pageIdentifiers?.index(of: identifier) else {
            return
        }
        showPage(atIndex: index)
        UserDefaults.standard.set(index, forKey: "CURRENT_INDEX")
    }
    
    /// Shows page at given index.
    /// - Parameter index: Index of the page to be shown.
    func showPage(atIndex index : Int) {
        guard let controller = self.viewControllerAtIndex(index) else {
            print("\(type(of: self)): Index \(index) is out of bounds [0, \(self.pageIdentifiers?.count ?? 0)].")
            return
        }
        self.pageViewController?.setViewControllers([controller], direction:(self.currentIndex < index ? .forward : .reverse), animated: true, completion: nil)
        self.currentIndex = index
        self.pageControllerDelegate?.pageController(self, didShowViewController: controller, forPageAtIndex: index)
    }
    
    /// Convinient method to show next page.
    func showNextPage() {
        self.showPage(atIndex: self.currentIndex + 1)
        UserDefaults.standard.set(currentIndex, forKey: "CURRENT_INDEX")
    }
    
    /// Convinient method to show previous page.
    func showPrevPage() {
        self.showPage(atIndex: self.currentIndex - 1)
        UserDefaults.standard.set(currentIndex, forKey: "CURRENT_INDEX")
    }
    
    /// Updates `pageControl` whenever configuration changes.
    fileprivate func updatePageControl() {
        self.pageControl?.delegate = self
        self.pageControl?.isHidden = self.useDefaultPageIndicator
        self.pageControl?.isUserInteractionEnabled = self.allowPageControlSwitchPages
        if let pages = self.pageIdentifiers?.count {
            self.pageControl?.indicatorsCount = pages
        }
        
    }
    
    /// Updates `helper` whenever configuration changes.
    fileprivate func updatePageViewControllerHelper() {
        self.helper = self.useDefaultPageIndicator ? TSPageViewControllerDefaultHelper(parent:self) : TSPageViewControllerHelper(parent: self)
        self.pageViewController?.dataSource = self.allowGesureBasedNavigation ? self.helper : nil
        self.pageViewController?.delegate = self.helper
    }
    
    /// Reloads pages and displays the first one.
    fileprivate func updatePages() {
        if (UserDefaults.standard.value(forKey: "CURRENT_INDEX")) != nil
        {
            let cIndex = UserDefaults.standard.integer(forKey: "CURRENT_INDEX")
            self.showPage(atIndex: cIndex)
        }
        else{
            self.showPage(atIndex: 0)
        }
    }
    
    /// Applies constraints to `contentView`.
    fileprivate func constraintPageContentView() {
        guard let pageView = self.pageViewController?.view else {
            return
        }
        self.pageContentView.addConstraints([
            NSLayoutConstraint(item: pageView, attribute: .left, relatedBy: .equal, toItem: self.pageContentView, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: pageView, attribute: .right, relatedBy: .equal, toItem: self.pageContentView, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: pageView, attribute: .top, relatedBy: .equal, toItem: self.pageContentView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: pageView, attribute: .bottom, relatedBy: .equal, toItem: self.pageContentView, attribute: .bottom, multiplier: 1, constant: 0)])
    }
    
    /// Gets `UIViewController` at requested index. If index is outside configured range of pages it returns `nil`.
    fileprivate func viewControllerAtIndex(_ index : Int) -> UIViewController? {
        guard let pageIdentifiers = self.pageIdentifiers, index >= 0 && index < pageIdentifiers.count else {
            return nil
        }
        var lastIndex : Int = self.pageViewControllers.count - 1
        while lastIndex <= index && lastIndex < pageIdentifiers.count-1 { // while loop allows  to instantiate all viewControllers in range when switching between distant pages.
            lastIndex += 1
            
            if let newPage = self.pageControllerDelegate?.pageController(self, instantiateViewControllerWithIdentifier:pageIdentifiers[lastIndex]) {
                self.pageViewControllers.append(newPage)
                
            }
            else {
                print("\(type(of: self)): Couldn't instantiate viewController because delegate was not set.")
                return nil
            }
        }
        return self.pageViewControllers[index]
        
    }
    
    /// Handles taps on `pageControl`'s indicators to switch pages.
    func pageControl(_ pageControl : TSPageControl, didSwitchFromIndex from : Int, toIndex to : Int) {
        guard self.allowPageControlSwitchPages else {
            print("\(type(of: self)): Page switching disabled by allowPageControlSwitchPages property.")
            return
        }
        self.showPage(atIndex: to)
    }
    
    /// Default implementation which allows subclasses to override customization.
    func pageControl(_ pageControl : TSPageControl, customizeIndicatorView view : UIView, atIndex index : Int) { }
}
    
/// `TSPageViewController`'s delegate which provides couple of methods to report state changes of the `TSPageViewController`.
protocol TSPageViewControllerDelegate {
    
    /**
     Called whenever user begins swiping of the page.
     
     - Note: This method is optional.
     
     - Parameter pageController: `TSPageViewController` which triggers the delegate.
     - Parameter controller: `UIViewController` which `pageController` will show. (see Attention).
     - Parameter index: Index of target `controller`.
     
     - Attention: Do not use this method to handle page switching. (See notes).
     
     - Note: When this method is called `pageController` still hasn't switched current page to target `UIViewController`. This means that user may cancel the swipe and therefore page won't be switched. However target `UIViewController` will be partially visible to user during swipe animation.
     
     - Important: In case swipe has been canceled `pageController` will call `pageController(_:, didCancelShowViewController:, _:) with currently displayed controller.
     */
    func pageController(_ pageController : TSPageViewController, willShowViewController controller : UIViewController, forPageAtIndex index : Int)
    
    /**
     Called whenever `pageController` switched to new page.
     
     - Note: This method is optional.
     
     - Parameter pageController: `TSPageViewController` which triggers the delegate.
     - Parameter controller: `UIViewController` which `pageController` did show.
     - Parameter index: Index of displayed `controller`.
     */
    func pageController(_ pageController : TSPageViewController, didShowViewController controller : UIViewController, forPageAtIndex index : Int)
    
    /**
     Complementary method which is being called along with `pageController(_, willShowViewController:, foPageAtIndex:)`.
     
     - Note: This method is optional.
     
     - Parameter pageController: `TSPageViewController` which triggers the delegate.
     - Parameter controller: `UIViewController` which `pageController` will show. (see Attention).
     - Parameter identifier: Identifier of target `controller`.
     
     - Seealso: `pageController(_, willShowViewController:, forPageAtIndex:)` for more details.
     */
    func pageController(_ pageController : TSPageViewController, willShowViewController controller : UIViewController, forPageWithIdentifier identifier : String)
    
    /**
     Complementary method which is being called along with `pageController(_, didShowViewController:, foPageAtIndex:)`.
     
     - Note: This method is optional.
     
     - Parameter pageController: `TSPageViewController` which triggers the delegate.
     - Parameter controller: `UIViewController` which `pageController` did show.
     - Parameter identifier: Identifier of displayed `controller`.
     
     - Seealso: For more details see `pageController(_, didShowViewController:, forPageAtIndex:)`.
     */
    func pageController(_ pageController : TSPageViewController, didShowViewController controller : UIViewController, forPageWithIdentifier identifier : String)
    
    
    /**
     Called whenever `pageController` switched to new page.
     
     - Note: This method is optional.
     
     - Parameter pageController: `TSPageViewController` which triggers the delegate.
     - Parameter controller: `UIViewController` switching to which `pageController` did cancel.
     - Parameter index: Index of canceled `controller`.
     */
    func pageController(_ pageController : TSPageViewController, didCancelShowViewController controller : UIViewController, forPageAtIndex index : Int)
    
    /**
     Complementary method which is being called along with `pageController(_, didShowViewController:, foPageAtIndex:)`.
     
     - Note: This method is optional.
     
     - Parameter pageController: `TSPageViewController` which triggers the delegate.
     - Parameter controller: `UIViewController` switching to which `pageController` did cancel.
     - Parameter identifier: Identifier of canceled `controller`.
     
     - Seealso: For more details see `pageController(_, didCancelShowViewController:, forPageAtIndex:)`.
     */
    func pageController(_ pageController : TSPageViewController, didCancelShowViewController controller : UIViewController, forPageWithIdentifier identifier : String)
    
    /**
     Called whenever `pageController` needs to instantiate new `UIViewController`.
     
     - Parameter pageController: `TSPageViewController` which triggers the delegate.
     - Parameter identifier: Identifier of the page for which `UIViewController` will be instantiated.
     */
    func pageController(_ pageController : TSPageViewController, instantiateViewControllerWithIdentifier identifier : String) -> UIViewController
    
    /**
     Called when `pageController` finished initialization and has been embedded.
     
     - Parameter pageController: `TSPageViewController` which triggers the delegate.
     - Parameter controller: `UIPageViewController` which has been embedded.
     - Parameter view: Content view into which `controller` has been embedded.
     */
    func pageController(_ pageController : TSPageViewController, didEmbedPageViewController controller : UIPageViewController, toContentView view : UIView)
}

// MARK: - Default implementation for TSPageViewControllerDelegate
extension TSPageViewControllerDelegate {
    func pageController(_ pageController : TSPageViewController, willShowViewController controller : UIViewController, forPageAtIndex index : Int) {}
    func pageController(_ pageController : TSPageViewController, didShowViewController controller : UIViewController, forPageAtIndex index : Int) {}
    func pageController(_ pageController : TSPageViewController, willShowViewController controller : UIViewController, forPageWithIdentifier identifier : String) {}
    func pageController(_ pageController : TSPageViewController, didShowViewController controller : UIViewController, forPageWithIdentifier identifier : String) {}
    func pageController(_ pageController : TSPageViewController, didEmbedPageViewController controller : UIPageViewController, toContentView view : UIView) {}
    func pageController(_ pageController : TSPageViewController, didCancelShowViewController controller : UIViewController, forPageAtIndex index : Int) {}
    func pageController(_ pageController : TSPageViewController, didCancelShowViewController controller : UIViewController, forPageWithIdentifier identifier : String){}
}

// MARK: - TSPageViewController helpers
/// Implements `UIPageViewController`'s `Delegate` and `DataSource`.
private class TSPageViewControllerHelper : NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    fileprivate let pageController : TSPageViewController
    init(parent : TSPageViewController) {
        self.pageController = parent
    }
    
    @objc func pageViewController(_ pageViewController : UIPageViewController, viewControllerAfter viewController : UIViewController) -> UIViewController? {
        
        if let index = self.pageController.pageViewControllers.index(of: viewController) {
            return self.pageController.viewControllerAtIndex(index + 1)
        }
        return nil
    }
    
    @objc func pageViewController(_ pageViewController : UIPageViewController, viewControllerBefore viewController : UIViewController) -> UIViewController? {
        if let index = self.pageController.pageViewControllers.index(of: viewController) {
            return self.pageController.viewControllerAtIndex(index - 1)
        }
        return nil
    }
   
    @objc func pageViewController(_ pageViewController : UIPageViewController, willTransitionTo pendingViewControllers : [UIViewController]) {
        guard let controller = pendingViewControllers.first, let index = self.pageController.pageViewControllers.index(of: controller) else {
            return
        }
        self.pageController.pageControllerDelegate?.pageController(self.pageController, willShowViewController: controller, forPageAtIndex: index)
        if let identifier = self.pageController.pageIdentifiers?[index] {
            self.pageController.pageControllerDelegate?.pageController(self.pageController, willShowViewController: controller, forPageWithIdentifier: identifier)
        }
    }
    
    @objc func pageViewController(_ pageViewController : UIPageViewController, didFinishAnimating finished : Bool, previousViewControllers : [UIViewController], transitionCompleted completed : Bool) {
        guard let controller = pageViewController.viewControllers?.first, let index = self.pageController.pageViewControllers.index(of: controller) else {
            return
        }
        
        guard completed else {
            self.pageController.pageControllerDelegate?.pageController(pageController, didCancelShowViewController: controller, forPageAtIndex: index)
            if let identifier = self.pageController.pageIdentifiers?[index] {
                self.pageController.pageControllerDelegate?.pageController(self.pageController, didCancelShowViewController: controller, forPageWithIdentifier: identifier)
            }
            return
        }
        
        self.pageController.currentIndex = index
        self.pageController.pageControllerDelegate?.pageController(pageController, didShowViewController: controller, forPageAtIndex: index)
        if let identifier = self.pageController.pageIdentifiers?[index] {
            self.pageController.pageControllerDelegate?.pageController(self.pageController, didShowViewController: controller, forPageWithIdentifier: identifier)
        }
    }
}

/// Implements `UIPageViewController`'s `Delegate` and `DataSource` and enables default `UIPageViewController`'s page indicator.
private class TSPageViewControllerDefaultHelper : TSPageViewControllerHelper {
    @objc func presentationCountForPageViewController(_ pageViewController : UIPageViewController) -> Int {
        return self.pageController.pageIdentifiers?.count ?? 0
    }
    
    @objc func presentationIndexForPageViewController(_ pageViewController : UIPageViewController) -> Int {
        return self.pageController.currentIndex
    }
}
   
