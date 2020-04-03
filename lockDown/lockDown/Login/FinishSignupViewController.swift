//
//  FinishSignupViewController.swift
//  lockDown
//
//  Created by Ahmed Mh on 02/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit

class FinishSignupViewController: BaseController {

    @IBOutlet weak var instrictionsTxt: UITextView!
    @IBOutlet weak var SignUpfinishedView: UIView!
    @IBOutlet weak var instrictionsView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        instrictionsTxt.text = "instrutionsTxt".localiz()
        self.title = "SignUpTitle".localiz()
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
        instrictionsView.isHidden = true
        SignUpfinishedView.isHidden = false 
    }
    
}
