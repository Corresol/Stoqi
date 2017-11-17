
enum StoqiTab : Int {
	case main = 0
	case requests
	case analysis
	case school
	case settings
}

class StoqiTabBarController: UITabBarController {
	
	func openTab(_ tab : StoqiTab) -> UIViewController?
	{
		selectedIndex = tab.rawValue
		return viewControllers?[selectedIndex]
	}
}
