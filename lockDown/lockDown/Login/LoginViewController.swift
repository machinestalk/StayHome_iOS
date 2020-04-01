//
//  LoginViewController.swift
//  lockDown
//
//  Created by Ahmed Mh on 30/03/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit
import NKVPhonePicker
import MBProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate {
        
   
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
    
    let kPhoneSubscriptWithZero = "+966"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = true
        
        if ( language == "ar"){
            //Text Aligment
            userNameInputView.textAlignment = NSTextAlignment.right
        }
                
        // For keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        return true;
    }
    
    // MARK: - Keyboard handling
        
        @objc func keyboardWillShow(notification: NSNotification) {
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
            setErrorMsg(msg: "SgIn_SgIn_lbl_empty_phone_number_email".localiz())
           
            return false
        }
        else
        {
            //Case Phone Number
            if phoneText.isDigits
            {
                if !phoneText.isValidSaoudiPhoneNumber
                {
                     setErrorMsg(msg: "SgIn_SgIn_lbl_invalid_lenght_phone_number".localiz())
                    return false
                }
            }
                //Case Email
            else
            {
                if !phoneText.isValidEmail
                {   setErrorMsg(msg: "SgIn_SgIn_lbl_invalid_email".localiz())
                    return false
                }
            }
        }
        
        
        
        return true
    }
    
    @IBAction func LoginAction(_ sender: Any) {
        
        if self.validateFields() {
            //Case Phone Number
            if userNameInputView.text!.isDigits
            {
                let newCountrycode = kPhoneSubscriptWithZero.replacingOccurrences(of: "+", with: "00", options: .literal, range: nil)
                let phoneString = newCountrycode + userNameInputView.text!
                self.validateNumber(username: phoneString)
                UserDefaults.standard.set(phoneString, forKey:"UserNameSignUp")
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
    func openOtpViewController() {
       
    }
    
//    func setErrorMsg(msg : String)  {
//        self.errorView.isHidden = false
//        self.errorLbl.text = msg
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            self.errorView.isHidden = true
//        }
//    }
}

