//
//  WelcomeViewController.swift
//  lockDown
//
//  Created by Aymen HECHMI on 04/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit

class WelcomeViewController: BaseController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.isHidden = false
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named:"Bg_navBar"),for: .default)
        self.navigationItem.setHidesBackButton(true, animated: true);

        self.title = "SignUpTitle".localiz()
    }
    
    @IBAction func showSurveyScreen(_ sender: Any) {
       let surveyViewController = SurveyViewController(nibName: "SurveyViewController", bundle: nil)
       self.navigationController!.pushViewController(surveyViewController, animated: true)
    }

}
