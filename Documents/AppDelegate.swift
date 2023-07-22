

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

//        let mainVC = MainViewController()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: DirectoryViewController(currentURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]))
        window?.makeKeyAndVisible()

        return true
    }




}

