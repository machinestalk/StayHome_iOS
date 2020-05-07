//
//  BraceletStatusViewController.swift
//  lockDown
//
//  Created by Ahmed Mh on 01/05/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit
import MTBeaconPlus

class BraceletStatusViewController: BaseController {
    var macAddress = ""
     var errorBottomVC = ErrorBottomViewController()
     var BraceletConnectedBottomVC = BraceletConnectBottomViewController()
     @IBOutlet weak var macLabel0: UILabel!
     @IBOutlet weak var macLabel1: UILabel!
     @IBOutlet weak var macLabel2: UILabel!
     @IBOutlet weak var macLabel3: UILabel!
     @IBOutlet weak var macLabel4: UILabel!
     @IBOutlet weak var macLabel5: UILabel!
    var manager : MTCentralManager!
    var scannerDevices : Array<MTPeripheral>!
    var currentPeripheral:MTPeripheral?
    var dateStr : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "braceletStatusTitle".localiz()
        
        manager = MTCentralManager.sharedInstance()
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
        self.startLoading()
        checkMacAdress(macAdress: macAddress)
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkIfBraceletConnected(notification:)), name:NSNotification.Name("Alerts"), object:nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.isHidden = false
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Bg_navBar")!.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0 ,right: 0), resizingMode: .stretch), for: .default)
      
    }
    
    func checkMacAdress(macAdress: String) {
        
        let dataBody = ["macAddress": macAdress ,"deviceId":UserDefaults.standard.value(forKey: "deviceId") as Any,"tenantId":UserDefaults.standard.string(forKey: "tenantId") as Any,"customerId":UserDefaults.standard.string(forKey: "customerId") as Any] as [String : Any]
     
         APIClient.checkBracelet(data: dataBody, onSuccess: { (successObject) in
                       self.finishLoading()
                       print(successObject)
            
            if let objectDict = successObject.convertToDictionary(){
                if let objectInfo =  objectDict["additionalInfo"] as? NSDictionary{
                  //  if let additionalInfo = (objectInfo as! String).convertToDictionary(){
                    if let StimpStr = objectInfo.object(forKey: "connectDateTime") as? Double {
                            print("dateStimp =::> \(StimpStr)")
                             let date = Date(timeIntervalSince1970: StimpStr as! TimeInterval)
                            print("dateStimp =::> \(date.toString(dateFormat: "dd.MM.yyyy HH:mm a"))")
                            UserDefaults.standard.set(macAdress, forKey:"connected_bracelet")
                            self.dateStr = date.toString(dateFormat: "dd.MM.yyyy HH:mm a")
                            self.getBraceletStatus()
                        }
                   // }
                }
            }
            
                   }) { (error) in
                       self.finishLoading()
                    self.setupErrorBottomVC()
                       print(error)
                   }
    }

    
    // MARK: - ErrorBottom View
    func setupErrorBottomVC() {
        //self.BraceletConnectedBottomVC.view.removeFromSuperview()
        errorBottomVC.delegate = self
        let height = view.frame.height
        let width  = view.frame.width
        errorBottomVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
        self.addChild(errorBottomVC)
        self.view.addSubview(errorBottomVC.view)
        errorBottomVC.didMove(toParent: self)
        errorBottomVC.errorIcon.image = UIImage(named: "red_bluetooth")
        errorBottomVC.msgLbl.text = "errorMsgConnection".localiz()
    }
    
    // MARK: - ErrorBottom View
    func setupBraceletconnectedBottomVC(dateStr : String) {
       // self.errorBottomVC.view.removeFromSuperview()
        let image = UIImage(named: "ic_menu")?.withRenderingMode(.alwaysOriginal)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(menuButtonPressed))
        let leftNavigationButtons = NSMutableArray(array: self.navigationBarLeftButtons())
        leftNavigationButtons.add(button)
        self.navigationItem.leftBarButtonItems  = (leftNavigationButtons as! [UIBarButtonItem])
        
        BraceletConnectedBottomVC.delegate = self
        let height = view.frame.height
        let width  = view.frame.width
        BraceletConnectedBottomVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
        self.addChild(BraceletConnectedBottomVC)
        self.view.addSubview(BraceletConnectedBottomVC.view)
        BraceletConnectedBottomVC.didMove(toParent: self)
        BraceletConnectedBottomVC.dateLbl.text = "sinceTxt".localiz() + " " + dateStr
    }
   
   @objc func checkIfBraceletConnected(notification: Notification){
    let type = notification.userInfo!["type"] as! String
    if type == "bracelet" {
        getBraceletStatus()
    }
    }
func getBraceletStatus () {
    let myMacAdress = UserDefaults.standard.string(forKey:"connected_bracelet")
    if manager != nil {
        
        var braceletVisible = false
        for key in manager.scannedPeris {
            var bleName = "Unknown"
            var mac = "Unknown"
            if key.framer.name != nil {
                bleName = key.framer.name
            }
            
            if key.framer.mac != nil {
                mac = key.framer.mac
                if mac.uppercased().inserting(separator: ":", every: 2) == myMacAdress{
                    braceletVisible = true
                    break
                }
            }
            
        }
        if !braceletVisible && myMacAdress != nil {
            if !self.errorBottomVC.view.isDescendant(of: self.view) {
                setupErrorBottomVC()
            }
          
        }
        else {
            UserDefaults.standard.set(macAddress, forKey:"connected_bracelet")
             if !self.BraceletConnectedBottomVC.view.isDescendant(of: self.view) {
                self.setupBraceletconnectedBottomVC(dateStr: dateStr)
            }
        }
    }
}
}
extension BraceletStatusViewController : ErrorBottomProtocol {
    func ErrorDidAppear() {
        
    }
    
    
}

