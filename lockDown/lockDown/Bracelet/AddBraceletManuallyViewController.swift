//
//  AddBraceletManuallyViewController.swift
//  lockDown
//
//  Created by Ahmed Mh on 05/05/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit

class AddBraceletManuallyViewController: BaseController {
    @IBOutlet weak var  text1: UITextField!
    @IBOutlet weak var  text2: TextField!
    @IBOutlet weak var  text3: TextField!
    @IBOutlet weak var  text4: TextField!
    @IBOutlet weak var  text5: TextField!
    @IBOutlet weak var  text6: TextField!
    @IBOutlet weak var msgLbl: Label!
    var confirmationBottomVC = ConfirmationBottomViewController()
    var errorBottomVC = ErrorBottomViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        text1.delegate = self
        text2.delegate = self
        text3.delegate = self
        text4.delegate = self
        text5.delegate = self
        text6.delegate = self
        self.title = "addmanuallyTitle".localiz()
        // Do any additional setup after loading the view.
    }

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
                    self.setupConfirmationBottomVC()
                }
            }
            textField.text = string
            return false
        }else if string.count == 0 {
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
        textField.text = string
                   return false
 
    }
    @objc func textFieldDidChange(_ textField: UITextField) {

        if #available(iOS 12.0, *) {

            if textField.textContentType == .oneTimeCode {
                if (textField.text?.count ?? 0) > 3 {

                    text1.text = (textField.text as NSString?)?.substring(with: NSRange(location: 0, length: 2))
                    text2.text = (textField.text as NSString?)?.substring(with: NSRange(location: 1, length: 2))
                    text3.text = (textField.text as NSString?)?.substring(with: NSRange(location: 2, length: 2))
                    text4.text = (textField.text as NSString?)?.substring(with: NSRange(location: 3, length: 2))
                    text5.text = (textField.text as NSString?)?.substring(with: NSRange(location: 4, length: 2))
                    text6.text = (textField.text as NSString?)?.substring(with: NSRange(location: 5, length: 2))
                }
            }
        }
    }
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           self.view.endEditing(true)
           return false
       }
    
    // MARK: - ConfirmationBottom View
    func setupConfirmationBottomVC() {
        confirmationBottomVC.delegate = self
        let height = view.frame.height
        let width  = view.frame.width
        confirmationBottomVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
        self.addChild(confirmationBottomVC)
        self.view.addSubview(confirmationBottomVC.view)
        confirmationBottomVC.didMove(toParent: self)
        confirmationBottomVC.msgLbl.text = "ConfirmBraceletTxt".localiz()
        confirmationBottomVC.confirmBtn.setTitle("logout0_btn_txt".localiz(), for: .normal)
        msgLbl.text = "beaconmacTxt".localiz()
    }
    
    // MARK: - ErrorBottom View
    func setupErrorBottomVC() {
        errorBottomVC.delegate = self
        let height = view.frame.height
        let width  = view.frame.width
        errorBottomVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
        self.addChild(errorBottomVC)
        self.view.addSubview(errorBottomVC.view)
        errorBottomVC.didMove(toParent: self)
        errorBottomVC.msgLbl.text = "errorAddBracelet".localiz()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func checkMacAdress(macAdress: String) {
        self.startLoading()
        let dataBody = ["macAddress": macAdress ,"deviceId":UserDefaults.standard.value(forKey: "deviceId") as Any,"tenantId":UserDefaults.standard.string(forKey: "tenantId") as Any,"customerId":UserDefaults.standard.string(forKey: "customerId") as Any] as [String : Any]
        
         APIClient.checkBracelet(data: dataBody, onSuccess: { (success) in
                       self.finishLoading()
                       print(success)
                   }) { (error) in
                       self.finishLoading()
                    self.setupErrorBottomVC()
                       print(error)
                   }
    }
}
extension AddBraceletManuallyViewController:ConfirmationBottomProtocol{
    func ConfirmBtnDidtap() {
        let macAdress = String(format:"%@%@%@%@%@%@", text1.text!, text2.text!, text3.text!, text4.text!, text5.text!, text6.text!)
       
        self.startLoading()
        let dataBody = ["macAddress": macAdress ,"deviceId":UserDefaults.standard.value(forKey: "deviceId") as Any,"tenantId":UserDefaults.standard.string(forKey: "tenantId") as Any,"customerId":UserDefaults.standard.string(forKey: "customerId") as Any] as [String : Any]
               
        APIClient.checkBracelet(data: dataBody, onSuccess: { (success) in
                              self.finishLoading()
                              print(success)
                          }) { (error) in
                              self.finishLoading()
                              print(error)
                          }
           }
        
    }
    
    
extension AddBraceletManuallyViewController : ErrorBottomProtocol{
    func ErrorDidAppear(){
        
        
    }
}

