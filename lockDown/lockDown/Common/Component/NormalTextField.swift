//
//  NormalTextField.swift
//  
//
//  Created by Ahmed Mh on 09/05/2018.
//  Copyright © 2018 Machinestalk. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class NormalTextField : UITextField
{
    @IBInspectable var key :String = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if(LanguageManger.shared.isRightToLeft && self.textAlignment==NSTextAlignment.left){
            self.textAlignment=NSTextAlignment.right;
            
        }
        self .setPlaceholderText()
    }
    func setPlaceholderText ()  {
        let  string=NSLocalizedString(self.key, comment: "")
        self.placeholder=string
        
    }
}

