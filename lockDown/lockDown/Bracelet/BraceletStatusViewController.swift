//
//  BraceletStatusViewController.swift
//  lockDown
//
//  Created by Ahmed Mh on 01/05/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit

class BraceletStatusViewController: BaseController {
    var macAddress = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "braceletStatusTitle".localiz()
        let final = macAddress.filter { $0 != ":" }.inserting(separator: " ", every: 2)
        print(final)
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

}
