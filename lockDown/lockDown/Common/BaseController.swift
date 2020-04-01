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


class BaseController: UIViewController ,UITextFieldDelegate  {
    var selectedImage = UIImage.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
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
                    if(viewController is DashboardViewController ||  self.navigationController?.viewControllers.count == 1 ){
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



