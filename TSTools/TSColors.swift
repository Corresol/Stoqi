/// TSTOOLS: Description.. date 8/19/16


extension UIColor {
    
    convenience init(alpha : UInt8, red r: UInt8, green g: UInt8, blue b: UInt8) {
        self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(alpha)/255.0)
    }
    
    convenience init(red r: UInt8, green g: UInt8, blue b: UInt8) {
        self.init(alpha: 255, red: r, green: g, blue: b)
    }
    
    convenience init(alpha: UInt8, white: UInt8) {
        self.init(white: CGFloat(white)/255.0, alpha : CGFloat(alpha)/255.0)
    }
    
    convenience init(white: UInt8) {
        self.init(alpha: 255, white: white)
    }
    
    func lighten(_ correctionFactor : Float, preserveAlpha : Bool = true) -> UIColor? {
        if correctionFactor <= 0 || correctionFactor > 1 {
            print("Color '\(self)' can be lightened only with values in range (0; 1]")
            return nil
        }
        return changeLightness(correctionFactor)
    }
    
    func darken(_ correctionFactor : Float, preserveAlpha : Bool = true) -> UIColor? {
        if correctionFactor < -1 || correctionFactor >= 0 {
            print("Color '\(self)' can be darkened only with values in range [-1; 0)")
            return nil
        }
        return changeLightness(correctionFactor)
    }
    
    
    fileprivate func changeLightness(_ correctionFactor : Float, preserveAlpha : Bool = true) -> UIColor? {
        if let argb = self.getARGB() {
            var red = Float(argb.red)
            var green = Float(argb.green)
            var blue = Float(argb.blue)
            let alpha = (argb.alpha)
            
            red += (255 - red) * correctionFactor;
            green += (255 - green) * correctionFactor;
            blue += (255 - blue) * correctionFactor;
            
            return UIColor(alpha:(preserveAlpha ? UInt8(alpha) : 255), red: UIColor.clampComponent(red), green: UIColor.clampComponent(green), blue: UIColor.clampComponent(blue))
        }
        return nil
    }
    
    fileprivate static func clampComponent(_ value : Float) -> UInt8
    {
        return UInt8(0 > value ? 0 : (value > 255 ? 255 : value))
    }
    
    func getARGB() -> (red:UInt8, green:UInt8, blue:UInt8, alpha:UInt8)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = UInt8(fRed * 255.0)
            let iGreen = UInt8(fGreen * 255.0)
            let iBlue = UInt8(fBlue * 255.0)
            let iAlpha = UInt8(fAlpha * 255.0)
            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
        } else {
            // Could not extract RGBA components:
            print("Could not extract ARGB components from color '\(self)'")
            return nil
        }
    }
}

