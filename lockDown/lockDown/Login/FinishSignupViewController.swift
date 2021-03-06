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
    var isFromNotif = false 
    
    @IBOutlet weak var instrictionsTxt: UITextView!
    @IBOutlet weak var SignUpfinishedView: UIView!
    @IBOutlet weak var instrictionsView: UIView!
    @IBOutlet weak var agreedButton: Button!
    @IBOutlet weak var successMsg: Label!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instrictionsTxt.text = "instrutionsTxt".localiz()
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Bg_navBar")!.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0 ,right: 0), resizingMode: .stretch), for: .default)
        if isFromCheckIn {
            successMsg.text = "FinishSuccessLbl".localiz()
            instrictionsView.isHidden = true
            SignUpfinishedView.isHidden = false
            agreedButton.isHidden = true
            self.title = "Check In"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { 
               let homeVC = HomeViewController(nibName: "HomeViewController", bundle: nil)
                self.navigationController!.pushViewController(homeVC, animated: true)
            }
        }
        else {
            instrictionsView.isHidden = false
            SignUpfinishedView.isHidden = true
            self.title = "SignUpTitle".localiz()
        }
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFromNotif {
            self.perform(#selector(dismissVc), with: nil, with: 5)
        }
    }

    @objc func dismissVc(){
        self.navigationController?.dismiss(animated: true, completion: nil)
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
        
            UserDefaults.standard.set(true, forKey:"isSignedUp")
            let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.getInstance().window?.rootViewController = appDelegate?.getLandingPageWithSideMenu()
        
         
    }
    
}
