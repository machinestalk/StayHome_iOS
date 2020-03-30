//
//  TextField.swift
//  
//
//  Created by Ahmed Mh on 1/29/18.
//  Copyright © 2018 Machinestalk. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class TextField : UITextField
{
    @IBInspectable var key :String = ""
    @IBInspectable var maxLength: Int = 0 // Max character length
    
    /************* Added new feature ***********************/
    // Accept only given character in string, this is case sensitive
    @IBInspectable var allowedCharInString: String = ""
    
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
    func verifyFields(shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = self.text, let textRange = Range(range, in: text) {
            let finalText = text.replacingCharacters(in: textRange, with: string)
            if maxLength > 0, maxLength < finalText.utf8.count {
                return false
            }
        }
        return true
    }
}

