//
//  LandingViewController.swift
//  lockDown
//
//  Created by Aymen HECHMI on 05/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.isHidden = true
    }
    
    @IBAction func signInSignUPDidTap(_ sender: Any) {
           let biometricsAuthVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
           self.navigationController!.pushViewController(biometricsAuthVC, animated: true)
       }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
