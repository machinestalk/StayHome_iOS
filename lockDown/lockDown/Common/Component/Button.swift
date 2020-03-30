//
//  Button.swift
//
//
//  Created by Ahmed Mh on 1/29/18.
//  Copyright © 2018 Machinestalk. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class Button : UIButton
{
    @IBInspectable var key :String = ""
    override func awakeFromNib() {
        super .awakeFromNib()
        if(LanguageManger.shared.isRightToLeft && self.contentHorizontalAlignment == .left){
            self.contentHorizontalAlignment = .right
        }
        self .setTitle()
    }
    func setTitle ()  {
        let  string=NSLocalizedString(self.key, comment: "")
        self.setTitle(string, for: .normal)
    }
}
@IBDesignable extension Button {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
