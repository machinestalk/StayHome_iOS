//
//  AttentionOutZoneAlertViewController.swift
//  lockDown
//
//  Created by Neffati on 10/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//


import UIKit
import BottomPopup
import DeviceKit

protocol responceProtocol {
    func oKClick()
    func emergencyClick()

}
class AttentionOutZoneAlertViewController: BottomPopupViewController {
    
  
    var delegate: responceProtocol?
    
    
    var fullView: CGFloat {
        
        if isItIPhoneX(){
            return UIScreen.main.bounds.height - 250
        }
        else {
            return UIScreen.main.bounds.height - 230
        }
    }
    var partialView: CGFloat {
        if isItIPhoneX(){
            return UIScreen.main.bounds.height - 100
        }
        else {
            return UIScreen.main.bounds.height - 130
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            let frame = self?.view.frame
            let yComponent = self?.fullView
            self?.view.frame = CGRect(x: 0, y: yComponent!, width: frame!.width, height: frame!.height )
        })
    }
    
    @IBAction func OKBtnAction(_ sender: Any) {
               delegate?.oKClick()
          
           
       }
    @IBAction func emergencyBtnAction(_ sender: Any) {
               delegate?.emergencyClick()
          
           
       }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        
        let y = self.view.frame.minY
        if (y + translation.y >= fullView) && (y + translation.y <= partialView) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )
            
            duration = duration > 1.3 ? 1 : duration
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    
                    self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: self.view.frame.height)
                } else {
                    self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: self.view.frame.height)
                    
                }
                
            }, completion: { [weak self] _ in
                if ( velocity.y < 0 ) {
                    
                }
            })
        }
    }
   
    
   
    func isItIPhoneX() -> Bool {
        let device = Device()
        let check = device.isOneOf([.iPhoneX, .iPhoneXr , .iPhoneXs , .iPhoneXsMax ,
                                    .simulator(.iPhoneX), .simulator(.iPhoneXr) , .simulator(.iPhoneXs) , .simulator(.iPhoneXsMax) ])
        return check
    }
    
}

