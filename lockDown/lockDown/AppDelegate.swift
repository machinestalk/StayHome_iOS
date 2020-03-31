//
//  AppDelegate.swift
//  lockDown
//
//  Created by Ahmed Mh on 30/03/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit
import LGSideMenuController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var sideMenu : LGSideMenuController?
    var navVC:UINavigationController?
    var dashboardVc: DashboardViewController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        LanguageManger.shared.defaultLanguage = .en
        let userDefaults = Foundation.UserDefaults.standard
        if userDefaults.string(forKey: "language") == nil || userDefaults.string(forKey: "language") == "" {
            
            if(LanguageManger.shared.isRightToLeft==true)
            {
                language = "ar"
                userDefaults.set( language, forKey: "language")
                LanguageManger.shared.defaultLanguage = .ar
            }
            else {
                language = "en"
                userDefaults.set( language, forKey: "language")
                LanguageManger.shared.defaultLanguage = .en
            }
        } else {
            language = userDefaults.string(forKey: "language")!
            if language == "ar" {
                LanguageManger.shared.defaultLanguage = .ar
            } else {
                LanguageManger.shared.defaultLanguage = .en
            }
            
        }
        self.window = UIWindow(frame:UIScreen.main.bounds)
        if  UserDefaults.standard.bool(forKey: "isLoggedIn")  {
            
            self.window?.rootViewController = self.getLandingPageWithSideMenu()
        } else {
            let centerVC = LoginViewController()
            let navVC:UINavigationController = UINavigationController(rootViewController: centerVC)
            self.window?.rootViewController = navVC;
        }
        self.window?.tintColor = UIColor.white
        self.window?.makeKeyAndVisible()
        return true
    }
    
    
    func getLandingPageWithSideMenu()->UIViewController {
        
        self.navVC = self.getNavControllerWithRootController(controller: DashboardViewController())
        var leftController: UIViewController? = nil
        var rightController: UIViewController? = nil
        if LanguageManger.shared.isRightToLeft {
            
            rightController = MenuViewController()
        }
        else{
            
            leftController = MenuViewController()
        }
        sideMenu = LGSideMenuController.init(rootViewController: navVC, leftViewController: leftController, rightViewController: rightController)
        
        return sideMenu!
    }
    
    
    func getInstance()->AppDelegate{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate
    }
    func getSideMenuController ()-> MenuViewController {
        
        let controller:MenuViewController = LanguageManger.shared.isRightToLeft == true ? sideMenu!.rightViewController as! MenuViewController : sideMenu!.leftViewController as! MenuViewController
        
        return controller
    }
    func getNavControllerWithRootController(controller : UIViewController)->UINavigationController{
        self.navVC = UINavigationController(rootViewController: controller)
        self.navVC?.interactivePopGestureRecognizer?.isEnabled = true
        return self.navVC!
    }
    
}

