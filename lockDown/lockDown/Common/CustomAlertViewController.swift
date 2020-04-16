//
//  CustomAlertViewController.swift
//  lockDown
//
//  Created by Aymen HECHMI on 16/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit

protocol CustomAlertViewDelegate: class {
    func okButtonTapped()
    func cancelButtonTapped()
}

class CustomAlertViewController: UIViewController {
    
    @IBOutlet weak var msgLbl: Label!
    @IBOutlet weak var titleLbl: Label!
    @IBOutlet weak var alertImage: UIImageView!
    @IBOutlet weak var okBtn: Button!
    @IBOutlet weak var cancelBtn: Button!
    @IBOutlet weak var okbtnConstraint: NSLayoutConstraint!
    
    var delegate: CustomAlertViewDelegate?
    var type = ""
    var message = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        // Do any additional setup after loading the view.
    }
    
    func configure() {
        
        switch type {
        case "login":
            okBtn.isHidden = true
            titleLbl.isHidden = true
            alertImage.image = UIImage(named: "red_fail")
            msgLbl.text = message
        case "logout0":
            okBtn.isHidden = false
            titleLbl.isHidden = true
            alertImage.isHidden = true
            msgLbl.text = "logout0_txt_msg".localiz()
            okBtn.setTitle("logout0_btn_txt".localiz(), for: .normal)
            okbtnConstraint.constant = 90
        case "logout1":
            okBtn.isHidden = true
            titleLbl.isHidden = true
            alertImage.image = UIImage(named: "red_fail")
            msgLbl.text = "logout1_txt_msg".localiz()
        default:
            break
        }
        
    }
    
    @IBAction func onTapCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.cancelButtonTapped()
    }
    
    @IBAction func onTapOkButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.okButtonTapped()
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
