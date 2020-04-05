//
//  FinishSignupViewController.swift
//  lockDown
//
//  Created by Ahmed Mh on 02/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit

class FinishSignupViewController: BaseController {
   
    var isFromCheckIn = false
    @IBOutlet weak var instrictionsTxt: UITextView!
    @IBOutlet weak var SignUpfinishedView: UIView!
    @IBOutlet weak var instrictionsView: UIView!
    @IBOutlet weak var agreedButton: Button!
    @IBOutlet weak var successMsg: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instrictionsTxt.text = "instrutionsTxt".localiz()
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named:"Bg_navBar"),for: .default)
        if isFromCheckIn {
            successMsg.text = "FinishSuccessLbl".localiz()
            instrictionsView.isHidden = true
            SignUpfinishedView.isHidden = false
            self.title = "Check In"
        }
        else {
            instrictionsView.isHidden = false
            SignUpfinishedView.isHidden = true
            self.title = "SignUpTitle".localiz()
        }
        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func agreedBtnDidTap(_ sender: Any) {
        let agreedButton = sender as! Button
        if agreedButton.tag == 0 {
            agreedButton.tag = 1
            instrictionsView.isHidden = true
            SignUpfinishedView.isHidden = false
        } else {
            UserDefaults.standard.set(true, forKey:"isSignedUp")
            let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.getInstance().window?.rootViewController = appDelegate?.getLandingPageWithSideMenu()
        }
         
    }
    
}
