//
//  RequestLocationViewController.swift
//  lockDown
//
//  Created by Ahmed Mh on 31/03/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit
import BottomPopup
import DeviceKit

protocol RequestLocationProtocol {
    func requestlocation()
    func nextBtnDidTap()
    func noBtnDidTap()
    

}


class RequestLocationViewController: BottomPopupViewController {
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var msgLbl: Label!
    @IBOutlet weak var noBtn: Button!
    @IBOutlet weak var yesBtn: Button!
    @IBOutlet weak var nextBtn: Button!
    @IBOutlet weak var handleArea: UIView!
    var delegate: RequestLocationProtocol?
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
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(self.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
        nextBtn.isHidden = false
        stackview.isHidden = true
        msgLbl.text = "RequestLocation_txt".localiz()
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
    
    @IBAction func nextBtnAction(_ sender: Any) {
        nextBtn.isHidden = true
        stackview.isHidden = false
        msgLbl.text = "confirmLocationTxt".localiz()
        self.delegate?.nextBtnDidTap()
    }
    @IBAction func noBtnDidTap(_ sender: Any) {
        nextBtn.isHidden = false
        stackview.isHidden = true
        msgLbl.text = "RequestLocation_txt".localiz()
        self.delegate?.noBtnDidTap()
    }
    @IBAction func yesBtnDidTap(_ sender: Any) {
        self.delegate?.requestlocation()
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
    @IBAction func swipeUp(_ sender: UIButton) {
        if isItIPhoneX(){
            if self.view.frame.origin.y == self.view.frame.height - 250 {
                
                self.view.frame.origin.y = self.view.frame.height - 100
            }
            else {
                self.view.frame.origin.y = self.view.frame.height - 250
            }
            //self.heightheader.constant = 85
        }
        else {
            if self.view.frame.origin.y == self.view.frame.height - 230 {
                self.view.frame.origin.y = self.view.frame.height - 65
            }else {
                self.view.frame.origin.y = self.view.frame.height - 230
            }
            //self.heightheader.constant = 60
        }
        UIView.animate(withDuration: 0.0) {
            self.view.layoutIfNeeded()
        }
    }
    
    func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .dark)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        view.insertSubview(bluredView, at: 0)
    }
    func isItIPhoneX() -> Bool {
        let device = Device()
        let check = device.isOneOf([.iPhoneX, .iPhoneXr , .iPhoneXs , .iPhoneXsMax ,
                                    .simulator(.iPhoneX), .simulator(.iPhoneXr) , .simulator(.iPhoneXs) , .simulator(.iPhoneXsMax) ])
        return check
    }
}
extension RequestLocationViewController: UIGestureRecognizerDelegate {
    
    // Solution
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: view).y
        
        let y = view.frame.minY
        
        
        return false
    }
    
}
