import UIKit
import IQKeyboardManagerSwift
import Foundation
import FBSDKCoreKit


private let kStorageShowIntro = "kStorageShowIntro"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    override init() {
        Injector.configure(with: DummyInjectionPreset().managersRules) // To add all managers
        Injector.configure(with: ProductionInjectionPreset())
        //Injector.configure(with: DummyInjectionPreset().managersRules) // To override managers with dummy
        Injector.printConfiguration()
    }
    
    fileprivate func launch()
	{
        let show = Storage.local[kStorageShowIntro] as? Bool ?? true
        window = UIWindow(frame: UIScreen.main.bounds)
        if show
		{
            Storage.local[kStorageShowIntro] = false
            window?.rootViewController = UIStoryboard(name: "Intro", bundle: nil).instantiateInitialViewController()
        }
		else
		{
			let manager = try! Injector.inject(AuthorizationManager.self)
			if manager.account != nil
			{
				window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
			}
			else
			{
                Storage.local[kStorageShowIntro] = false
                window?.rootViewController = UIStoryboard(name: "Intro", bundle: nil).instantiateInitialViewController()
			}
        }
        window?.makeKeyAndVisible()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.sharedManager().enable = true
        TestFairy.begin("8b0874a39eda7d685f5c86bfeab27646d9d4fa94")
		OneSignal.initWithLaunchOptions(launchOptions, appId: "44cdadc0-7d19-46a5-a403-1886f14a2984")
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        launch()
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                     open: url,
                                                                     sourceApplication: sourceApplication,
                                                                     annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app,
                                                                     open: url,
                                                                     sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                                     annotation: options [UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
}

