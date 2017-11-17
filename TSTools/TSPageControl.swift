/// TODO: Description... 9/24/16.
/**
 1. Setup in IB
 2. Create reference outlet to parent
 3. Set delegate and dataSource
 4. Enjoy!
 */

/**
 1. Make your custom UIVIew conform to TSIndicatorView.
 2. Provide this custom view in dataSource.indicatorViewForIndex method
 3. Enjoy your custom indicators.
 */
import UIKit

protocol TSPageControlDelegate {
    func pageControl(_ pageControl : TSPageControl, didSwitchFromIndex from : Int, toIndex to : Int)
    func pageControl(_ pageControl : TSPageControl, customizeIndicatorView view: UIView, atIndex index: Int)
}

// All methods are optional.
extension TSPageControlDelegate {
    func pageControl(_ pageControl : TSPageControl, didSwitchFromIndex from : Int, toIndex to : Int) { }
    func pageControl(_ pageControl : TSPageControl, customizeIndicatorView view: UIView, atIndex index: Int) { }
}

protocol TSIndicatorView {
    func changeIndicatorState(_ active : Bool, animated : Bool)
}

enum TSPageControlIndicatorType {
    case color(colors : (defaultColor:UIColor, activeColor:UIColor))
    case image(images : (defaultImage:UIImage, activeImage:UIImage))
    case custom(delegate : (_ index : Int) -> UIView)
}

@IBDesignable
class TSPageControl : UIView {
    
    var delegate : TSPageControlDelegate?
    
    @IBInspectable var insetsConstant : CGFloat {
        get {
            return self.insets.top
        }
        set(value) {
            self.insets = UIEdgeInsets(top: value, left: value, bottom: value, right: value)
        }
    }
    
    @IBInspectable var insets : UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) { didSet { self.setNeedsLayout() } }
    
    @IBInspectable var indicatorsCount : Int = 0 { didSet { self.reset() } }
    @IBInspectable var indicatorsSize : CGSize = CGSize(width: 8, height: 8) { didSet { self.setNeedsLayout() } }
    @IBInspectable var indicatorsSpacing : CGFloat = 8 { didSet { self.setNeedsLayout() } }
    
    var indicatorViewType : TSPageControlIndicatorType = .color(colors: (defaultColor: UIColor.lightGray, activeColor: UIColor.darkGray)) { didSet { self.reset() } }
    
    @IBInspectable var currentIndicator : Int = 0 {
        willSet {
            self.setIndicatorActive(false, atIndex: self.currentIndicator, animated: true)
        }
        
        didSet {
            self.setIndicatorActive(true, atIndex: self.currentIndicator, animated: true)
        }
    }
    
    override var isUserInteractionEnabled: Bool {
        didSet {
            self.subviews.forEach{ $0.isUserInteractionEnabled = self.isUserInteractionEnabled }
        }
    }
    
    fileprivate var indicators : [UIView] = [UIView]()
    
    fileprivate func setup(){
        self.setIndicatorActive(true, atIndex: self.currentIndicator, animated: false)
    }
    
    fileprivate func setIndicatorActive(_ active : Bool, atIndex index: Int, animated : Bool) {
        guard self.currentIndicator >= 0 && self.currentIndicator < self.indicators.count else {
            return
        }
        if let prevIndicatorView = self.indicators[currentIndicator] as? TSIndicatorView {
            prevIndicatorView.changeIndicatorState(active, animated: animated)
        } else {
            print("\(type(of: self)): Unable to set active state to indicator, because it doesn't conform to TSIndicatorView protocol.")
        }
    }
    
    func reset() {
        for indicator in self.indicators {
            indicator.removeFromSuperview()
        }
        self.indicators.removeAll()
        self.updateIndicators()
    }
    
    fileprivate func updateIndicators() {
        let frame = self.frameForIndicators()
        for index in 0..<self.indicatorsCount {
            let view = self.indicatorViewAtIndex(index)
            self.updateIndicatorPosition(view, atIndex: index, withFrame:frame)
        }
    }
    
    fileprivate func updateIndicatorPosition(_ indicator : UIView, atIndex index : Int, withFrame frame: CGRect) {
        let shift : CGFloat = self.distanceToCenter(fromIndex: index) * (index < self.indicatorsCount/2 ? -1 : 1) // multiplier defines sign (to shift left or right)
        let x = frame.midX + shift
        let y = frame.midY
        indicator.isUserInteractionEnabled = self.isUserInteractionEnabled
        indicator.center = CGPoint(x:x,y:y)
    }
    
    /** Calculates distance from frame center to center of the indicator at given index*/
    fileprivate func distanceToCenter(fromIndex index : Int) -> CGFloat {
        let even = self.indicatorsCount % 2 == 0
        let center = CGFloat(even ? (CGFloat(self.indicatorsCount - 1)/2) : (CGFloat(self.indicatorsCount)/2)) // handle special case with even number of indicators ( correct placement of two indicators nearest to the center)
        let indexDistance = abs(center - CGFloat(index))
        let measureUnit = self.indicatorsSize.width/2 + self.indicatorsSpacing/2 // measeureUnit represents distance between indicator center and spacing center. This will ease calculation algorithm
        let unitsNumber = indexDistance * 2
        return measureUnit * unitsNumber
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchedView = touches.first?.view, let index = self.indicators.index(of: touchedView), index != self.currentIndicator else {
            return
        }
        let prevIndex = currentIndicator
        self.currentIndicator = index
        self.delegate?.pageControl(self, didSwitchFromIndex: prevIndex, toIndex: currentIndicator)
    }
    
    override var intrinsicContentSize : CGSize {
        return sizeForIndicators(true)
    }
    
    override func sizeToFit() {
        let size = self.intrinsicContentSize
        self.frame = CGRect(origin: self.frame.origin, size:size)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateIndicators()
        self.setIndicatorActive(true, atIndex: self.currentIndicator, animated: false)
    }
    
    fileprivate func frameForIndicators() -> CGRect {
        let size = self.sizeForIndicators(false)
        return CGRect(x: (self.frame.width-size.width)/2, y: (self.frame.height-size.height)/2, width: size.width, height: size.height)
    }
    
    fileprivate func sizeForIndicators(_ adjustInsets : Bool) -> CGSize {
        var width = self.indicatorsSize.width * CGFloat(self.indicatorsCount) +  self.indicatorsSpacing * CGFloat(self.indicatorsCount - 1)
        var height = self.indicatorsSize.height
        if adjustInsets {
            width +=  self.insets.left + self.insets.right
            height += self.insets.top + self.insets.bottom
        }
        return CGSize(width: width, height: height)
    }
    
    /** Retrieves indicator view at given index. */
    fileprivate func indicatorViewAtIndex(_ index : Int) -> UIView {
        if !self.indicators.isEmpty && index >= 0 && index < self.indicators.count {
            return self.indicators[index]
        }
        let indicatorView : UIView
        switch self.indicatorViewType {
        case .color(let colors):
            indicatorView = TSColorIndicatorView(defaultColor: colors.defaultColor, activeColor: colors.activeColor)
        case .image(let images):
            indicatorView = TSImageIndicatorView(defaultImage: images.defaultImage, activeImage: images.activeImage)
        case .custom(let delegate):
            indicatorView = delegate(index)
        }
        
        indicatorView.frame = CGRect(origin: CGPoint.zero, size: self.indicatorsSize)
        
        self.indicators.append(indicatorView)
        self.addSubview(indicatorView)
        indicatorView.isUserInteractionEnabled = true
        self.delegate?.pageControl(self, customizeIndicatorView: indicatorView, atIndex: index)
        setIndicatorActive((index == self.currentIndicator), atIndex: index, animated: false)
        return self.indicators[index]
    }
}

private class TSColorIndicatorView : UIView, TSIndicatorView {
    
    var defaultColor : UIColor?
    var activeColor : UIColor?
    
    init(defaultColor : UIColor, activeColor : UIColor) {
        super.init(frame: CGRect.zero)
        self.setup(defaultColor, activeColor: activeColor)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    fileprivate func setup(_ defaultColor: UIColor = UIColor.lightGray, activeColor : UIColor = UIColor.darkGray) {
        self.defaultColor = defaultColor
        self.activeColor = activeColor
        self.backgroundColor = self.defaultColor
    }
    
    func changeIndicatorState(_ active: Bool, animated : Bool) {
        let color = active ? self.activeColor : self.defaultColor
        if animated {
            UIView.animate(withDuration: 0.4, animations: { 
                self.backgroundColor = color
            })
        } else {
            self.backgroundColor = color
        }
        
    }
}

private class TSImageIndicatorView : UIImageView, TSIndicatorView {
    var defaultImage : UIImage? = nil
    var activeImage : UIImage? = nil
    
    init(defaultImage : UIImage, activeImage : UIImage) {
        super.init(frame: CGRect.zero)
        self.setup(defaultImage, activeImage: activeImage)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func setup(_ defaultImage: UIImage, activeImage : UIImage) {
        self.defaultImage = defaultImage
        self.activeImage = activeImage
        self.image = self.defaultImage
    }
    
    func changeIndicatorState(_ active: Bool, animated : Bool) {
        let image = active ? self.activeImage : self.defaultImage
        if animated {
            UIView.animate(withDuration: 0.4, animations: {
                self.image = image
            })
        } else {
            self.image = image
        }
        
    }
    
}
