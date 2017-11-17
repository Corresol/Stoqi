class RegisterListIndicatorView : UILabel, TSIndicatorView {
    
    var defaultColor : UIColor = UIColor.lightGray
    var activeColor : UIColor = UIColor.darkGray
    
    init(title : String, defaultColor : UIColor, activeColor : UIColor) {
        super.init(frame: CGRect.zero)
        self.defaultColor = defaultColor
        self.activeColor = activeColor
        self.text = title
        self.backgroundColor = self.defaultColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
