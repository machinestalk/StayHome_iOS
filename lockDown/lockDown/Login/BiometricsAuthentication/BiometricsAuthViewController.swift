//
//  BiometricsAuthViewController.swift
//  lockDown
//
//  Created by Aymen HECHMI on 31/03/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit

import LocalAuthentication

class BiometricsAuthViewController: BaseController {
    var isFromCheckIn = false
    var isFromNotif = false
    @IBOutlet weak var stepsImg: UIImageView!
    @IBOutlet weak var stateView: UIView!
    
    @IBOutlet weak var biometryTypeImageView: UIImageView!
    @IBOutlet weak var biometryTypeLabel: Label!
    
    enum CardState {
        case expanded
        case collapsed
    }
    var biometricsBottomVC = BiometricsBottomViewController()
    let cardHeight:CGFloat = 300
    let cardHandleAreaHeight:CGFloat = 65
    var cardVisible = false
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    
    /// An authentication context stored at class scope so it's available for use during UI updates.
    var context = LAContext()
    
    /// The available states of being logged in or not.
    enum AuthenticationState {
        case loggedin, loggedout
    }
    
    /// The current authentication state.
    var state = AuthenticationState.loggedout {
        
        // Update the UI on a change.
        didSet {
            //loginButton.isHighlighted = state == .loggedin  // The button text changes on highlight.
            //stateView.backgroundColor = state == .loggedin ? .green : .red
            // FaceID runs right away on evaluation, so you might want to warn the user.
            //  In this app, show a special Face ID prompt if the user is logged out, but
            //  only if the device supports that kind of authentication.
            //faceIDLabel.isHidden = (state == .loggedin) || (context.biometryType != .faceID)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(isFromCheckIn){
            self.title = "checkIn_txt".localiz()
            stepsImg.isHidden = true
        }
        else {
            self.title = "SignUpTitle".localiz()
        }
        setupBiometricsBottomVC()
        // The biometryType, which affects this app's UI when state changes, is only meaningful
        //  after running canEvaluatePolicy. But make sure not to run this test from inside a
        //  policy evaluation callback (for example, don't put next line in the state's didSet
        //  method, which is triggered as a result of the state change made in the callback),
        //  because that might result in deadlock.
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error){
            if self.context.evaluatedPolicyDomainState != nil {
                
                switch context.biometryType {
                case .none:
                    
                    biometryTypeImageView.image = UIImage(named: "ic_hold_near")
                    biometryTypeLabel.text = "We can not complete the process !"
                    biometricsBottomVC.nextBtn.isEnabled = false
                case .faceID:
                    biometricsBottomVC.nextBtn.isEnabled = true
                    biometryTypeImageView.image = UIImage(named: "ic_faceID")
                    biometryTypeLabel.text = "Face ID registration"
                case .touchID:
                    biometricsBottomVC.nextBtn.isEnabled = true
                    biometryTypeImageView.image = UIImage(named: "ic_finger")
                    biometryTypeLabel.text = "Touch ID registration"
                default:
                    break
                }
            }else{
                setupUnvailableBiometricsBottomVC()
                biometryTypeImageView.image = UIImage(named: "ic_hold_near")
                biometryTypeLabel.text = "We can not complete the process !"
            }
        }else{
            print(error?.localizedDescription ?? "")
        }
        
        
        // Set the initial app state. This impacts the initial state of the UI as well.
        state = .loggedout
        
    }
    
    /// Logs out or attempts to log in when the user taps the button.
    
    func tapButton() {
        
        if state == .loggedin {
            
            // Log out immediately.
            state = .loggedout
            
        } else {
            
            // Get a fresh context for each login. If you use the same context on multiple attempts
            //  (by commenting out the next line), then a previously successful authentication
            //  causes the next policy evaluation to succeed without testing biometry again.
            //  That's usually not what you want.
            context = LAContext()
            
            context.localizedCancelTitle = "Cancel"
            
            // First check if we have the needed hardware support.
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                
                let reason = "Log in to your account"
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
                    
                    if success {
                        
                        // Move to the main thread because a state update triggers UI changes.
                        DispatchQueue.main.async { [unowned self] in
                            if (UserDefaults.standard.data(forKey: "currentbiometricstate") != nil){
                                if UserDefaults.standard.data(forKey: "currentbiometricstate") == self.context.evaluatedPolicyDomainState  {
                                    self.state = .loggedin
                                    self.setupSuccessBiometricsBottomVC()
                                }
                                else {
                                    print("Not same user")
                                    let deviceToken = UserDefaults.standard.string(forKey: "DeviceToken")
                                    APIClient.sendTelimetry(deviceToken: deviceToken!, iscomplaint: 0,raison:"faceId doesn't match", onSuccess: { (Msg) in
                                        print(Msg)
                                    } ,onFailure : { (error) in
                                        print(error)
                                    })
                                    if self.isFromNotif {
                                        self.navigationController?.dismiss(animated: true, completion: nil)
                                    }
                                }
                            }
                            else {
                                let currentbiometricstate = self.context.evaluatedPolicyDomainState
                                UserDefaults.standard.set(currentbiometricstate, forKey: "currentbiometricstate")
                                self.state = .loggedin
                                self.setupSuccessBiometricsBottomVC()
                                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                            }
                        }
                        
                    } else {
                        print(error?.localizedDescription ?? "Failed to authenticate")
                        
                        // Fall back to a asking for username and password.
                        // ...
                        self.setupFailBiometricsBottomVC()
                    }
                }
            } else {
                print(error?.localizedDescription ?? "Can't evaluate policy")
                
                // Fall back to a asking for username and password.
                // ...
            }
        }
    }
    
    // MARK: - Bottom Views Methods
    func setupBiometricsBottomVC() {
        biometricsBottomVC.delegate = self
        let height = view.frame.height
        let width  = view.frame.width
        biometricsBottomVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
        self.addChild(biometricsBottomVC)
        self.view.addSubview(biometricsBottomVC.view)
        biometricsBottomVC.didMove(toParent: self)
    }
    
    func setupUnvailableBiometricsBottomVC(){
        
        biometricsBottomVC.msgLbl.text = "Please setup your FaceID/TouchID First !"
        biometricsBottomVC.titleLbl.isHidden = true
        biometricsBottomVC.successImage.image = UIImage(named: "red_fail")
        biometricsBottomVC.successImage.isHidden = false
        biometricsBottomVC.nextBtn.isHidden = true
    }
    
    func setupFailBiometricsBottomVC(){
        
        biometricsBottomVC.titleLbl.isHidden = true
        biometricsBottomVC.successImage.image = UIImage(named: "red_fail")
        biometricsBottomVC.successImage.isHidden = false
        biometricsBottomVC.nextBtn.setBackgroundImage(UIImage(named: "red_button"), for: .normal)
        biometricsBottomVC.nextBtn.titleLabel?.text = "Retry"
    }
    func setupSuccessBiometricsBottomVC(){
        
        biometricsBottomVC.titleLbl.isHidden = true
        biometricsBottomVC.successImage.image = UIImage(named: "big_green_check")
        biometricsBottomVC.successImage.isHidden = false
        biometricsBottomVC.nextBtn.setBackgroundImage(UIImage(named: "green_button"), for: .normal)
        biometricsBottomVC.nextBtn.titleLabel?.text = "Next"
    }
}

// MARK: RequestLocation delagates methods

extension BiometricsAuthViewController: BiometricsAuthProtocol {
    
    func requestRecognition() {
        switch state {
        case .loggedin:
            let FinishSignupVC = FinishSignupViewController(nibName: "FinishSignupViewController", bundle: nil)
            FinishSignupVC.isFromCheckIn = self.isFromCheckIn
            FinishSignupVC.isFromNotif = self.isFromNotif
            self.navigationController!.pushViewController(FinishSignupVC, animated: true)
            
        case .loggedout:
            self.tapButton()
        }
        
    }
}
