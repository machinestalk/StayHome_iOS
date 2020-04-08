//
//  CheckInViewController.swift
//  lockDown
//
//  Created by Ahmed Mh on 04/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit

class CheckInViewController: BaseController {
    var countdownTimer: Timer!
       var totalTime : Int!
    @IBOutlet weak var counter: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "CheckInTxt".localiz()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTimer()
    }
    @IBAction func yesBtnDidTap(_ sender: Any) {
        let biometricsAuthVC = BiometricsAuthViewController(nibName: "BiometricsAuthViewController", bundle: nil)
        biometricsAuthVC.isFromCheckIn = true
        self.navigationController!.pushViewController(biometricsAuthVC, animated: true)
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
                counter.text =  String(format: "%02d:%02d", minutes, secondes) + " min"
                
            } else if secondes == 0 {
                

                desactivateTimer()
                let FailCheckInVC = FailCheckInViewController(nibName: "FailCheckInViewController", bundle: nil)
                self.navigationController!.pushViewController(FailCheckInVC, animated: true)
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
