//
//  BaseController.swift
//  GenericApp
//
//  Created by Ahmed Mh on 2/12/18.
//  Copyright © 2018 Machinestalk. All rights reserved.
//

import UIKit
import LGSideMenuController
import CoreLocation
import DeviceKit
import MBProgressHUD


class BaseController: UIViewController ,UITextFieldDelegate, AlertProtocol  {
    
    

    var alertIsShown = false
    var selectedImage = UIImage.init()
    var attentionAlertViewController: AttentionAlertViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        NotificationCenter.default.addObserver(self, selector: #selector(self.showPopUpAlertWithType(notification:)), name:NSNotification.Name("Alerts"), object:nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    //MARK:- UITextField Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    //MARK:- Show popup
    
    @objc func showPopUpAlertWithType(notification: Notification){
        if let type = notification.userInfo!["type"] as? String {
            if type !=  "braceletStatus" {
                if let window = UIApplication.shared.delegate?.window {
                    if var viewController = window?.rootViewController {
                        // handle navigation controllers
                        if(viewController is UINavigationController){
                            viewController = (viewController as! UINavigationController).visibleViewController!
                        }
                        if(viewController is LGSideMenuController){
                            
                            viewController = (viewController as! LGSideMenuController).rootViewController!
                            
                            viewController = (viewController as! UINavigationController).visibleViewController!
                            
                            if(viewController is HomeViewController) {
                                if !alertIsShown {
                                    alertIsShown = true
                                    attentionAlertViewController = AttentionAlertViewController(nibName: "AttentionAlertViewController", bundle: nil)
                                    attentionAlertViewController.type = notification.userInfo!["type"] as! String
                                    attentionAlertViewController.delegate = self
                                    attentionAlertViewController.modalPresentationStyle = .overCurrentContext
                                    attentionAlertViewController.modalTransitionStyle = .crossDissolve
                                    appDelegate.window?.rootViewController!.present(attentionAlertViewController, animated: true, completion: nil)
                                    //self.navigationController?.visibleViewController!
                                }
                            }
                        }
                    }
                }
                }
        }
    }
    
    func hidePopUpAlert() {
        attentionAlertViewController.dismiss(animated: true, completion: nil)
    }
    
    func oKButtonTappedWithType(type: String) {
        
        alertIsShown = false
            self.hidePopUpAlert()
    }
    func emergencyBtnClick() {
        alertIsShown = false
        self.hidePopUpAlert()
        print("emergencyClick")
        makePhoneCall(phoneNumber:"937")
    }
    
    func makePhoneCall(phoneNumber: String) {
        
        if let phoneURL = NSURL(string: ("tel://" + phoneNumber)) {
            
            UIApplication.shared.open(phoneURL as URL, options: [:], completionHandler: nil)
        }
    }

    //MARK:- Set Up Navigation bar
    func setupNavigationBar()  {
        
        let button : UIBarButtonItem
        if let window = UIApplication.shared.delegate?.window {
            if var viewController = window?.rootViewController {
                // handle navigation controllers
                if(viewController is UINavigationController){
                    viewController = (viewController as! UINavigationController).visibleViewController!
                }
                if(viewController is LGSideMenuController){
                    
                    viewController = (viewController as! LGSideMenuController).rootViewController!
                    
                    viewController = (viewController as! UINavigationController).visibleViewController!
                    if(viewController is HomeViewController || viewController is FinishSignupViewController  || viewController is BraceletViewController ||
                        ((UserDefaults.standard.string(forKey:"connected_bracelet") != nil) && viewController is BraceletStatusViewController)
                        || self.navigationController?.viewControllers.count == 1 ){
                        let image = UIImage(named: "ic_menu")?.withRenderingMode(.alwaysOriginal)

                        button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(menuButtonPressed))
                    }
                    else {
                        if ( language == "ar"){
                            button = UIBarButtonItem(image: UIImage(named: "back-arrow-ar"), style: .plain, target: self, action: #selector(backButtonPressed))
                            
                        }
                        else {
                            button = UIBarButtonItem(image: UIImage(named: "back-arrow"), style: .plain, target: self, action: #selector(backButtonPressed))
                        }
                    }
                    
                    var leftNavigationButtons = NSMutableArray(array: self.navigationBarLeftButtons())
                    leftNavigationButtons.add(button)
                    self.navigationItem.leftBarButtonItems  = leftNavigationButtons as! [UIBarButtonItem]
                    
                }else {
                    if ( language == "ar"){
                        button = UIBarButtonItem(image: UIImage(named: "back-arrow-ar"), style: .plain, target: self, action: #selector(backButtonPressed))
                        
                    }
                    else {
                        button = UIBarButtonItem(image: UIImage(named: "back-arrow"), style: .plain, target: self, action: #selector(backButtonPressed))
                    }
                }
                var leftNavigationButtons = NSMutableArray(array: self.navigationBarLeftButtons())
                leftNavigationButtons.add(button)
                if !(viewController is TermsAndConditionViewController) {
                    self.navigationItem.leftBarButtonItems  = leftNavigationButtons as! [UIBarButtonItem]
                }
                
            }
        }
    }
    
    func navigationBarLeftButtons() -> [UIBarButtonItem] {
        return []
    }
    
    @objc func menuButtonPressed()  {
        
        if(LanguageManger.shared.isRightToLeft==true){
            
            self.sideMenuController?.toggleRightViewAnimated()
            
        }
        else {
            self.sideMenuController?.toggleLeftViewAnimated()
        }
        
    }
    @objc func backButtonPressed()  {
        self.navigationController?.popViewController(animated: true)
    }
    func setupLeftNavigationButtons(NavigationBarItems : NSArray)  {
      /*  self.navigationItem.setLeftBarButtonItems(nil, animated: false)
        let barButtons:NSArray
        barButtons= self.createBarButtons*/
        
    }
    
    func UIColorFromHex (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
   
    func setTitle(title : String){
        super.title  = title.localized(lang: language)
    }
    //MARK:- refreshTokenLogout Method
    func refreshTokenLogout() {
        // Dismiss your loader
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        appDelegate.window!.rootViewController = loginVC

    }
    
    func getTopViewController() -> UIViewController? {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        return topController
    }
    
    // MARK: - secondsToHoursMinutesSeconds
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> String {
        return String(format: "%02d:%02d:%02d",(seconds / 3600 ),(seconds % 3600) / 60,(seconds % 3600) % 60)
    }
    
    func startLoading() {
        // Show your loader
        MBProgressHUD .showAdded(to: self.view, animated: true)
        
    }
    
    func finishLoading() {
        // Dismiss your loader
        let delay = DispatchTime.now()
        DispatchQueue.main.asyncAfter(deadline: delay) {
            MBProgressHUD .hide(for: self.view, animated: true)
            
        }
    }
}
// MARK: - UINavigationControllerDelegate
extension BaseController: UINavigationControllerDelegate {
    // MARK: - check if object is valid
    
    func isValid(_ object:AnyObject!) -> Bool
    {
        if let _:AnyObject = nil
        {
            return true
        }
        
        return false
    }
    func isItIPhoneX() -> Bool {
        let device = Device()
        let check = device.isOneOf([.iPhoneX, .iPhoneXr , .iPhoneXs , .iPhoneXsMax ,
                                    .simulator(.iPhoneX), .simulator(.iPhoneXr) , .simulator(.iPhoneXs) , .simulator(.iPhoneXsMax) ])
        return check
    }
    func isItIPhonePlus() -> Bool {
        let device = Device()
        let check = device.isOneOf([.iPhone6Plus, .iPhone7Plus , .iPhone8Plus , .iPhone6sPlus ,
                                    .simulator(.iPhone6Plus), .simulator(.iPhone7Plus) , .simulator(.iPhone8Plus) , .simulator(.iPhone6sPlus) ])
        return check
    }
    
    
    func decode(jwtToken jwt: String) -> [String: Any] {
        let segments = jwt.components(separatedBy: ".")
        return decodeJWTPart(segments[1]) ?? [:]
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

    func decodeJWTPart(_ value: String) -> [String: Any]? {
        guard let bodyData = base64UrlDecode(value),
            let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
                return nil
        }
        
        return payload
    }
    
}

// MARK: - UIImagePickerControllerDelegate
/*extension BaseController: UIImagePickerControllerDelegate {
    func presentImagePicker() {
        // 2
        let imagePickerActionSheet = UIAlertController(title: "Base_Update_user_Image_Lbl".localiz(),
                                                       message: nil, preferredStyle: .actionSheet)
        imagePickerActionSheet.view.tintColor =  UIColor(red: 51/255, green: 153/255, blue: 255/255, alpha: 1)
        // 3
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: "Base_Take_photo_Lbl".localiz(),
                                             style: .default) { (alert) -> Void in
                                                let imagePicker = UIImagePickerController()
                                                imagePicker.delegate = self
                                                imagePicker.sourceType = .camera
                                                self.present(imagePicker, animated: true)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        // 1
        let libraryButton = UIAlertAction(title: "Base_Choose_existing_Lbl".localiz(),
                                          style: .default) { (alert) -> Void in
                                            let imagePicker = UIImagePickerController()
                                            imagePicker.delegate = self
                                            imagePicker.sourceType = .photoLibrary
                                            self.present(imagePicker, animated: true)
        }
        imagePickerActionSheet.addAction(libraryButton)
        // 2
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)
        // 3
        present(imagePickerActionSheet, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated: true, completion: {
            
        })
    }
    
    
    
    
    
}*/



