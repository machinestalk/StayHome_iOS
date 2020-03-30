//
//  Checkbox.swift
//  
//
//  Created by Ahmed Mh on 21/10/2019.
//  Copyright © 2019 Machinestalk. All rights reserved.
//


import UIKit

class Checkbox: UIButton {
    // Images
    let checkedImage = UIImage(named: "check_in")! as UIImage
    let uncheckedImage = UIImage(named: "check_off")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(uncheckedImage, for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}
