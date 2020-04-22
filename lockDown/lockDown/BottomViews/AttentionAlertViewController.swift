//
//  AttentionAlertViewController.swift
//  lockDown
//
//  Created by Neffati on 09/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//



import UIKit
import BottomPopup
import DeviceKit

protocol AlertProtocol {
    
    func oKButtonTappedWithType(type:String)
    func emergencyBtnClick()
}
class AttentionAlertViewController: UIViewController {
    
    @IBOutlet weak var msgLbl: Label!
    @IBOutlet weak var titleLbl: Label!
    @IBOutlet weak var alertImage: UIImageView!
    @IBOutlet weak var okBtn: Button!
    @IBOutlet weak var stackView: UIStackView!
    var delegate: AlertProtocol?
    var type = ""
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //            attentionAlertViewControllerBluetooth.
        //            attentionAlertViewControllerBluetooth.
        titleLbl.text = "Alert_title_txt".localiz()
        switch type {
            
        case "bluetooth":
            msgLbl.text = "Alert_bluetooth_msg_txt".localiz()
            alertImage.image = UIImage(named: "red_bluetooth")
            break
        case "internet":
            msgLbl.text = "Alert_wifi_msg_txt".localiz()
            alertImage.image = UIImage(named: "red_wifi")
            break
        case "battery":
            msgLbl.text = "Alert_battery_msg_txt".localiz()
            alertImage.image = UIImage(named: "red_battery")
            break
        case "logout":
            msgLbl.text = "Alert_logout_msg_txt".localiz()
            alertImage.image = UIImage(named: "red_fail")
            break
        case "zone_exit":
            msgLbl.text = "Alert_out_zone_msg_txt".localiz()
            okBtn.isHidden = true
            stackView.isHidden = false
            alertImage.image = UIImage(named: "red_speaker")
            break
        case "zone_entry":
            msgLbl.text = "Alert_in_zone_msg_txt".localiz()
            okBtn.isHidden = true
            stackView.isHidden = false
            alertImage.image = UIImage(named: "red_speaker")
            break
        default:
            break
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
    }
    
    @IBAction func OKBtnAction(_ sender: Any) {
        
        delegate?.oKButtonTappedWithType(type: type)
    }
    
    @IBAction func emergencyBtnDidTap(_ sender: Any) {
        delegate?.emergencyBtnClick()
    }
    func isItIPhoneX() -> Bool {
        let device = Device()
        let check = device.isOneOf([.iPhoneX, .iPhoneXr , .iPhoneXs , .iPhoneXsMax ,
                                    .simulator(.iPhoneX), .simulator(.iPhoneXr) , .simulator(.iPhoneXs) , .simulator(.iPhoneXsMax) ])
        return check
    }
    
}

