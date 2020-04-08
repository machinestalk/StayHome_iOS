//
//  FailCheckInViewController.swift
//  lockDown
//
//  Created by Ahmed Mh on 08/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit

class FailCheckInViewController: BaseController {
    var countdownTimer: Timer!
    var totalTime : Int!
    var isFromNotif = false
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var tryBtn: Button!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "CheckInTxt".localiz()
        startTimer()
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        desactivateTimer()
    }
    @IBAction func tryAgainDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func startTimer() {
        if(countdownTimer != nil ){
            countdownTimer.invalidate()
            countdownTimer = nil
        }
        totalTime = 60
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        if(countdownTimer != nil){
            let secondes = (totalTime % 60)
            let minutes : Int = Int(totalTime / 60)
            
            if totalTime != 0 {
                totalTime -= 1
                timerLbl.text =  String(format: "%02d:%02d", minutes, secondes) + " " + "minTxt".localiz()
                
            } else if secondes == 0 {
                
                
                desactivateTimer()
                let deviceToken = UserDefaults.standard.string(forKey: "DeviceToken")
                APIClient.sendTelimetry(deviceToken: deviceToken!, iscomplaint: 0,raison:"not check In", onSuccess: { (Msg) in
                    print(Msg)
                } ,onFailure : { (error) in
                    print(error)
                })
                if isFromNotif {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
            else {
                
                //endTimer()
            }
            
        }
    }
    
    // MARK : Desactivate Timer
    func desactivateTimer()  {
        if(countdownTimer != nil ){
            countdownTimer.invalidate()
            countdownTimer = nil
        }
    }
    
    
}
