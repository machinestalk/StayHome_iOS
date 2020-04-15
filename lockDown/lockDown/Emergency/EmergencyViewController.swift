//
//  EmergencyViewController.swift
//  lockDown
//
//  Created by Aymen HECHMI on 04/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit

class EmergencyViewController: BaseController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Emergency"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Bg_navBar")!.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0 ,right: 0), resizingMode: .stretch), for: .default)
    }
    
    @IBAction func callBtnDidTap(_ sender: Any) {
        
        makePhoneCall(phoneNumber:"937")
    }
    
    func makePhoneCall(phoneNumber: String) {

        if let phoneURL = NSURL(string: ("tel://" + phoneNumber)) {
            
            UIApplication.shared.open(phoneURL as URL, options: [:], completionHandler: nil)
        }
    }

    /*
    // MARK: - Navigation
     
     if let url = NSURL(string: "tel://\(busPhone)") where UIApplication.sharedApplication().canOpenURL(url) {
       UIApplication.sharedApplication().openURL(url)
     }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
