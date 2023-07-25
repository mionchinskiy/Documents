

import UIKit
import KeychainSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = LoginViewController(passwordNeedSetup: KeychainSwift().get("password") == nil)
        window?.makeKeyAndVisible()

        return true
    }




}

