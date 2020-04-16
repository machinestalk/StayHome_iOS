//
//  TermsAndConditionViewController.swift
//  lockDown
//
//  Created by Aymen HECHMI on 16/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit

class TermsAndConditionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           self.navigationController!.navigationBar.isHidden = false
           self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Bg_navBar")!.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0 ,right: 0), resizingMode: .stretch), for: .default)
           self.navigationItem.setHidesBackButton(true, animated: true);
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes

           self.title = "TermTitle".localiz()
       }
       
       @IBAction func showSurveyScreen(_ sender: Any) {
          let surveyViewController = SurveyViewController(nibName: "SurveyViewController", bundle: nil)
          self.navigationController!.pushViewController(surveyViewController, animated: true)
       }

}
