/// `UIViewController` which can be created with default nib file.
class StandaloneViewController : BaseViewController, TSIdentifiable {

    /// Loads itself from default `nib`.
    required init() {
        super.init(nibName: type(of: self).identifier, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
