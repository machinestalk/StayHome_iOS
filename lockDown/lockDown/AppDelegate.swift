//
//  AppDelegate.swift
//  lockDown
//
//  Created by Ahmed Mh on 30/03/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit
import LGSideMenuController
import Firebase
import GoogleMaps

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var sideMenu : LGSideMenuController?
    var navVC:UINavigationController?
    var dashboardVc: HomeViewController!
    let notificationCenter = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            notificationCenter.delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            notificationCenter.requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
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
            if UserDefaults.standard.bool(forKey: "isSignedUp") {
                self.window?.rootViewController = self.getLandingPageWithSideMenu()
            } else {
                self.window?.rootViewController = self.getNavControllerWithRootController(controller: WelcomeViewController())
            }
        } else {
            
            let centerVC = LandingViewController()
            let navVC:UINavigationController = UINavigationController(rootViewController: centerVC)
            self.window?.rootViewController = navVC;
            
        }
        self.window?.tintColor = UIColor.white
        self.window?.makeKeyAndVisible()
        GMSServices.provideAPIKey(LockDown.GoogleMaps.key)
        return true
    }
    
    
    func getLandingPageWithSideMenu()->UIViewController {
        
        self.navVC = self.getNavControllerWithRootController(controller: HomeViewController())
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
    
    var applicationStateString: String {
        if UIApplication.shared.applicationState == .active {
            return "active"
        } else if UIApplication.shared.applicationState == .background {
            return "background"
        }else {
            return "inactive"
        }
    }
    
    func requestNotificationAuthorization(application: UIApplication) {
        if #available(iOS 10.0, *) {
            notificationCenter.delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            notificationCenter.requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            NotificationCenter.default.post(name: Notification.Name("NotificationLocation"), object: nil)
        }
        else {
            NotificationCenter.default.post(name: Notification.Name("NotificationNoneLocation"), object: nil)
        }
        let VC = HomeViewController(nibName: "HomeViewController", bundle: nil)
        VC.startCustomTimer()
        
        // Call Refresh token
        
        if let refreshToken = UserDefaults.standard.string(forKey: "RefreshToken"){
            let userDataFuture = APIClient.getRefreshToken(refreshToken: refreshToken)
                userDataFuture.execute(onSuccess: { userData in
                    print(userData)
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    UserDefaults.standard.set(userData.token, forKey:"Token")
                    UserDefaults.standard.set(userData.refreshToken, forKey:"RefreshToken")
                    let userDictionary = self.decode(jwtToken:userData.token!)
                    UserDefaults.standard.set(userDictionary["customerId"], forKey:"customerId")
                }, onFailure: {error in
                    print(error)
                })
            }
    }
    
   // Call decode
    
    func decode(jwtToken jwt: String) -> [String: Any] {
           let segments = jwt.components(separatedBy: ".")
           return decodeJWTPart(segments[1]) ?? [:]
       }
    // Call decodeJWTPart
    
    func decodeJWTPart(_ value: String) -> [String: Any]? {
        guard let bodyData = base64UrlDecode(value),
            let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
                return nil
        }
        
        return payload
    }
    func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 = base64 + padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("WillTerminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
    }
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo["id"] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
      
        
        if let messageID = userInfo["id"] {
            print("Message ID: \(messageID)")
        }
        
        let deviceToken = UserDefaults.standard.string(forKey: "DeviceToken")
        APIClient.sendTelimetry(deviceToken: deviceToken!, iscomplaint: 0, raison: "app in background", onSuccess: { (Msg) in
            print(Msg)
        } ,onFailure : { (error) in
            print(error)
        })
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
    func getNotificationSettings() {
        if #available(iOS 10.0, *) {
            notificationCenter.getNotificationSettings { (settings) in
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        
        guard let aps = userInfo["aps"] as? NSDictionary else{return;}
        guard let value = aps.value(forKey: "alert") as? NSDictionary else { return;}
        guard let body = value.value(forKey: "body") as? String else { return;}
        
        
        
        // Print full message.
        print(userInfo)
        if body == "check_in" {
           let CheckInVC = CheckInViewController(nibName: "CheckInViewController", bundle: nil)
            CheckInVC.isFromNotif = true
            let navController:UINavigationController = UINavigationController(rootViewController: CheckInVC)
             navController.modalPresentationStyle = .overCurrentContext
            self.navVC?.visibleViewController!.present(navController, animated: true, completion: nil);
        }
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        print(userInfo)
        if let messageID = userInfo["id"] {
            print("Message ID: \(messageID)")
        }
        guard let aps = userInfo["aps"] as? NSDictionary else{return;}
        guard let value = aps.value(forKey: "alert") as? NSDictionary else { return;}
        guard let body = value.value(forKey: "body") as? String else { return;}
        if body == "check_in" {
            let CheckInVC = CheckInViewController(nibName: "CheckInViewController", bundle: nil)
            CheckInVC.isFromNotif = true
            let navController:UINavigationController = UINavigationController(rootViewController: CheckInVC)
            navController.modalPresentationStyle = .overCurrentContext
            self.navVC?.visibleViewController!.present(navController, animated: true, completion: nil);
        }
        
        completionHandler()
    }
}
// [END ios_10_message_handling]




extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        UserDefaults.standard.set(fcmToken, forKey: "firebaseToken")
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}
