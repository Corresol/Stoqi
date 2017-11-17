class EmbedingViewController : BaseViewController {
    @IBOutlet weak fileprivate var vContent : UIView!
    
    func embed<T : StandaloneViewController>(_ controllerType : T.Type) -> T {
        let controller = controllerType.init()
        embed(controller)
        return controller
    }
    
    func embed(_ controller : UIViewController) -> UIViewController {
        addChildViewController(controller)
        vContent.addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content" : controller.view]) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[content]|", options: [], metrics: nil, views: ["content" : controller.view])
        NSLayoutConstraint.activate(constraints)
        controller.didMove(toParentViewController: self)
        return controller
    }
}
