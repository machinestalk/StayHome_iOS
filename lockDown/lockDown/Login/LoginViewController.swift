//
//  LoginViewController.swift
//  lockDown
//
//  Created by Ahmed Mh on 30/03/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoginViewController: BaseController {
        
   
    @IBOutlet weak var  titleLabel: Label!
    @IBOutlet weak var  titleTextField: Label!
    @IBOutlet weak var  recentPinBtn: Button!
    @IBOutlet weak var  loginBtn: Button!
    @IBOutlet weak var  userNameInputView: TextField!
    @IBOutlet weak var  text1: TextField!
    @IBOutlet weak var  text2: TextField!
    @IBOutlet weak var  text3: TextField!
    @IBOutlet weak var  text4: TextField!
    @IBOutlet weak var  text5: TextField!
    @IBOutlet weak var  text6: TextField!
    @IBOutlet weak var  dialCodeLbl: UILabel!
    @IBOutlet weak var  viewLogin: UIView!
    @IBOutlet weak var  dialCodeHolder: UIView!
    @IBOutlet weak var  dialCodeWidth: NSLayoutConstraint!
    @IBOutlet weak var  otpStackView: UIStackView!
    @IBOutlet weak var  scrollView: UIScrollView!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var usernameSeparator : UILabel!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var heightErrorView: NSLayoutConstraint!
    @IBOutlet weak var errorLblTop: NSLayoutConstraint!
  
    let kPhoneSubscriptWithZero = "+966"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //self.navigationController?.navigationBar.isHidden = true
        userNameInputView.becomeFirstResponder()
        
        
        if ( language == "ar"){
            //Text Aligment
            userNameInputView.textAlignment = NSTextAlignment.right
        }
                
        // For keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if !isItIPhoneX() {
            heightErrorView.constant = 70
            errorLblTop.constant = 0
            errorLbl.frame.size.height = errorView.frame.size.height
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UITextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.count == 1 {
            if textField == text1 {
                text2.becomeFirstResponder()
                text1.text = textField.text
            }
            if textField == text2 {
                text3.becomeFirstResponder()
                text2.text = textField.text
            }
            if textField == text3 {
                text4.becomeFirstResponder()
                text3.text = textField.text
            }
            if textField == text4 {
                text5.becomeFirstResponder()
                text4.text = textField.text
            }
            if textField == text5 {
                text6.becomeFirstResponder()
                text5.text = textField.text
            }
            if textField == text6 {
                
                text6.text = textField.text
                text6.resignFirstResponder()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.verifyOTP()
                }
            }
            textField.text = string
            return false
        }else{
            if textField == text2 {
                text1.becomeFirstResponder()
            }
            if textField == text3 {
                text2.becomeFirstResponder()
            }
            if textField == text4 {
                text3.becomeFirstResponder()
            }
            if textField == text5 {
                text4.becomeFirstResponder()
            }
            if textField == text6 {
                text5.text = textField.text
            }
            textField.text = string
            return false
        }
    }
    
    // MARK: - Keyboard handling
        
        @objc func keyboardWillShow(notification: NSNotification) {
            userNameInputView.maxLength = 9
            let userInfo: NSDictionary = notification.userInfo! as NSDictionary
            let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
            let keyboardSize = keyboardInfo.cgRectValue.size
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
        
        @objc func keyboardWillHide(notification: NSNotification) {
            scrollView.contentInset = .zero
            scrollView.scrollIndicatorInsets = .zero
        }
    
    func validateFields() -> Bool {
        
        guard let phoneText = userNameInputView.text else {
            return false
        }
        
        if phoneText.isEmptyOrNull {
            
            self.displayAlert(message:"SgIn_SgIn_lbl_empty_phone_number_email".localiz(), type: "phone")
           
            return false
        }
        else
        {
            //Case Phone Number
            if phoneText.isDigits
            {
                if !phoneText.isValidSaoudiPhoneNumber
                {
                    self.displayAlert(message:"SgIn_SgIn_lbl_invalid_lenght_phone_number".localiz(), type: "phone")
                    return false
                }
            }

        }
        
        return true
    }
    
    func changeView(){
        
        titleLabel.text = "SgIn_SgIn_Lbl_login_verifyPin".localiz()
        titleTextField.text = "SgIn_SgIn_Lbl_login_pin".localiz()
        dialCodeHolder.isHidden = true
        userNameInputView.isHidden = true
        userNameInputView.resignFirstResponder()
        otpStackView.isHidden = false
        recentPinBtn.isHidden = false
    
        if #available(iOS 12.0, *) {
            text1.textContentType = .oneTimeCode
        }
        text1.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
        text1.becomeFirstResponder()
        loginBtn.isHidden = true
        usernameSeparator.isHidden = true
        //Clear TextFields OTP
        clearTextFieldOTP()
    }
    
    func clearTextFieldOTP(){
        
        text1.text = ""
        text2.text = ""
        text3.text = ""
        text4.text = ""
        text5.text = ""
        text6.text = ""
        text1.becomeFirstResponder()
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {

        if #available(iOS 12.0, *) {

            if textField.textContentType == .oneTimeCode {
                if (textField.text?.count ?? 0) > 3 {

                    text1.text = (textField.text as NSString?)?.substring(with: NSRange(location: 0, length: 1))
                    text2.text = (textField.text as NSString?)?.substring(with: NSRange(location: 1, length: 1))
                    text3.text = (textField.text as NSString?)?.substring(with: NSRange(location: 2, length: 1))
                    text4.text = (textField.text as NSString?)?.substring(with: NSRange(location: 3, length: 1))
                    text5.text = (textField.text as NSString?)?.substring(with: NSRange(location: 4, length: 1))
                    text6.text = (textField.text as NSString?)?.substring(with: NSRange(location: 5, length: 1))
                }
            }
        }
    }
    
    func verifyOTP(){
        
        self.startLoading()
        let deviceUDIDString = UIDevice.current.identifierForVendor!.uuidString
        let otpString = String(format:"%@%@%@%@%@%@", text1.text!, text2.text!, text3.text!, text4.text!, text5.text!, text6.text!)
        let userDataFuture = APIClient.signIn(phoneNumber: UserDefaults.standard.value(forKey: "UserNameSignUp") as! String, phoneOtp: otpString, phoneUdid: deviceUDIDString)
        userDataFuture.execute(onSuccess: { userData in
            print(userData)
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.set(userData.deviceToken, forKey:"DeviceToken")
            UserDefaults.standard.set(userData.token, forKey:"Token")
            UserDefaults.standard.set(userData.refreshToken, forKey:"RefreshToken")
            UserDefaults.standard.set(userData.deviceID, forKey:"deviceId")
            let userDictionary = self.decode(jwtToken:userData.token!)
            UserDefaults.standard.set(userDictionary["customerId"], forKey:"customerId")
            self.finishLoading()
            self.displayHomePage()
        }, onFailure: {error in
            let errorr = error as NSError
            let errorDict = errorr.userInfo
            self.finishLoading()
            self.displayAlert(message:errorDict["message"] as! String, type: "login")
        })
    }
    
    @IBAction func LoginAction(_ sender: Any) {
        
        if self.validateFields() {
            //Case Phone Number
            if userNameInputView.text!.isDigits
            {
                self.startLoading()
                let newCountrycode = kPhoneSubscriptWithZero.replacingOccurrences(of: "+", with: "00", options: .literal, range: nil)
                let phoneString = newCountrycode + userNameInputView.text!
                APIClient.singUp(phoneNumber: phoneString, onSuccess: {(success) in
                    print(success)
                    self.finishLoading()
                    UserDefaults.standard.set(phoneString, forKey:"UserNameSignUp")
                    self.changeView()
                }, onFailure: {(error) in
                    self.finishLoading()
                    print(error)
                })
            }
        }
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func validateNumber(username: String){
        self.startLoading()
    }
    
    func displayHomePage(){
        
        let welcomeViewController = TermsAndConditionViewController(nibName: "TermsAndConditionViewController", bundle: nil)
        self.navigationController!.pushViewController(welcomeViewController, animated: true)
//        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
//        appDelegate?.getInstance().window?.rootViewController = appDelegate?.getLandingPageWithSideMenu()
    }
    
    func displayAlert(message: String, type: String) {
        
        let customAlert = CustomAlertViewController(nibName: "CustomAlertViewController", bundle: nil)
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = .overCurrentContext
        customAlert.modalTransitionStyle = .crossDissolve
        customAlert.type = type
        customAlert.message = message
        customAlert.delegate = self
        self.present(customAlert, animated: true, completion: nil)
    }
}

extension LoginViewController: CustomAlertViewDelegate {
    
    func okButtonTapped(customAlert: CustomAlertViewController) {
        if customAlert.type != "phone" {
            self.navigationController?.popViewController(animated: true)
        }
        
    }

    func cancelButtonTapped(customAlert: CustomAlertViewController) {
        if customAlert.type != "phone" {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

