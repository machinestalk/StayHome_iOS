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
    var isFromNotif = false
    @IBOutlet weak var counter: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "CheckInTxt".localiz()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFromNotif {
            self.navigationController?.navigationBar.isHidden = true
        }else{
            self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Bg_navBar")!.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0 ,right: 0), resizingMode: .stretch), for: .default)
            self.navigationController?.navigationBar.isHidden = false
            let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
            navigationController?.navigationBar.titleTextAttributes = textAttributes
        }
        startTimer()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        desactivateTimer()
    }
    @IBAction func yesBtnDidTap(_ sender: Any) {
        let biometricsAuthVC = BiometricsAuthViewController(nibName: "BiometricsAuthViewController", bundle: nil)
        biometricsAuthVC.isFromCheckIn = true
        biometricsAuthVC.isFromNotif = isFromNotif
        self.navigationController!.pushViewController(biometricsAuthVC, animated: true)
    }
    
    func startTimer() {
        if(countdownTimer != nil ){
            countdownTimer.invalidate()
            countdownTimer = nil
        }
        totalTime = 300
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
                FailCheckInVC.isFromNotif = isFromNotif
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
