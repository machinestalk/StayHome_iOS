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
    
     @IBOutlet weak var macLabel0: UILabel!
     @IBOutlet weak var macLabel1: UILabel!
     @IBOutlet weak var macLabel2: UILabel!
     @IBOutlet weak var macLabel3: UILabel!
     @IBOutlet weak var macLabel4: UILabel!
     @IBOutlet weak var macLabel5: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "braceletStatusTitle".localiz()
        //let final = macAddress.filter { $0 != ":" }.inserting(separator: " ", every: 2)
        let characters = macAddress.components(separatedBy:":")
        print(characters)
        
        macLabel0.text = characters[0]
        macLabel1.text = characters[1]
        macLabel2.text = characters[2]
        macLabel3.text = characters[3]
        macLabel4.text = characters[4]
        macLabel5.text = characters[5]
        
        // Do any additional setup after loading the view.
        
        checkMacAdress(macAdress: "BC:23:3F:56:B6:2C")
    }
    
    func checkMacAdress(macAdress: String) {
        self.startLoading()
        let dataBody = ["macAddress": macAddress ,"deviceId":UserDefaults.standard.value(forKey: "deviceId") as Any,"tenantId":UserDefaults.standard.string(forKey: "tenantId") as Any,"customerId":UserDefaults.standard.string(forKey: "customerId") as Any] as [String : Any]
        
         APIClient.checkBracelet(data: dataBody, onSuccess: { (success) in
                       self.finishLoading()
                       print(success)
                   }) { (error) in
                       self.finishLoading()
                       print(error)
                   }
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
