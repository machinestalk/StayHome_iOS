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
    @IBOutlet weak var  text2: UITextField!
    @IBOutlet weak var  text3: UITextField!
    @IBOutlet weak var  text4: UITextField!
    @IBOutlet weak var  text5: UITextField!
    @IBOutlet weak var  text6: UITextField!
    @IBOutlet weak var msgLbl: Label!
    var confirmationBottomVC = ConfirmationBottomViewController()
    var BraceletConnectedBottomVC = BraceletConnectBottomViewController()
    
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
        
        text1.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - UITextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        if count == 2 {
            if textField == text1 {
                text1.text = (textField.text! + string).uppercased()
                text2.becomeFirstResponder()
            }
            if textField == text2 {
                text2.text = (textField.text! + string).uppercased()
                text3.becomeFirstResponder()
            }
            if textField == text3 {
                text3.text = (textField.text! + string).uppercased()
                text4.becomeFirstResponder()
            }
            if textField == text4 {
                text4.text = (textField.text! + string).uppercased()
                text5.becomeFirstResponder()
            }
            if textField == text5 {
                text5.text = (textField.text! + string).uppercased()
                text6.becomeFirstResponder()
            }
            if textField == text6 {
                
                text6.text = (textField.text! + string).uppercased()
                text6.resignFirstResponder()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.setupConfirmationBottomVC()
                }
            }
        }else if count == 0 {
            if textField == text2 {
                text2.text = ""
                text1.becomeFirstResponder()
            }
            if textField == text3 {
                text3.text = ""
                text2.becomeFirstResponder()
            }
            if textField == text4 {
                text4.text = ""
                text3.becomeFirstResponder()
            }
            if textField == text5 {
                text5.text = ""
                text4.becomeFirstResponder()
            }
            if textField == text6 {
                text6.text = ""
                text5.becomeFirstResponder()
            }
            
        }
        return count <= 2
        
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
    // MARK: - ErrorBottom View
    func setupBraceletconnectedBottomVC(dateStr : String) {
        BraceletConnectedBottomVC.delegate = self
        let height = view.frame.height
        let width  = view.frame.width
        BraceletConnectedBottomVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
        self.addChild(BraceletConnectedBottomVC)
        self.view.addSubview(BraceletConnectedBottomVC.view)
        BraceletConnectedBottomVC.didMove(toParent: self)
        BraceletConnectedBottomVC.dateLbl.text = "sinceTxt".localiz() + " " + dateStr
    }
  
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
        let macAdress = String(format:"%@:%@:%@:%@:%@:%@", text1.text!, text2.text!, text3.text!, text4.text!, text5.text!, text6.text!)
        
        self.startLoading()
        let dataBody = ["macAddress": macAdress ,"deviceId":UserDefaults.standard.value(forKey: "deviceId") as Any,"tenantId":UserDefaults.standard.string(forKey: "tenantId") as Any,"customerId":UserDefaults.standard.string(forKey: "customerId") as Any] as [String : Any]
        
        APIClient.checkBracelet(data: dataBody, onSuccess: { (successObject) in
            self.finishLoading()
            if let objectDict = successObject.convertToDictionary(){
                if let StimpStr =  objectDict["createdTime"] {
                    print("dateStimp =::> \(StimpStr)")
                    let date = Date(timeIntervalSince1970: StimpStr as! TimeInterval)
                    
                    print("dateStimp =::> \(date.toString(dateFormat: "dd.MM.yyyy HH:mm a"))")
                    self.confirmationBottomVC.view.removeFromSuperview()
                    self.setupBraceletconnectedBottomVC(dateStr: date.toString(dateFormat: "dd.MM.yyyy HH:mm a"))
                    
                    
                }}
        }) { (error) in
            self.finishLoading()
            self.confirmationBottomVC.view.removeFromSuperview()
            self.setupErrorBottomVC()
            print(error)
        }
    }
    
}


extension AddBraceletManuallyViewController : ErrorBottomProtocol{
    func ErrorDidAppear(){
        
        
    }
}

