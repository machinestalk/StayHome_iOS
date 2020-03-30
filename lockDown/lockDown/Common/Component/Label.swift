//
//  Label.swift
//  
//
//  Created by Ahmed Mh on 1/29/18.
//  Copyright © 2018 Machinestalk. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class Label : UILabel
{
    @IBInspectable var key :String = ""
    override func awakeFromNib() {
        super .awakeFromNib()
        if(LanguageManger.shared.isRightToLeft && self.textAlignment==NSTextAlignment.left){
            self.textAlignment=NSTextAlignment.right;
            
        }
        self .setText()
    }
    func setText ()  {
        let  string=NSLocalizedString(self.key, comment: "")
        self.text = string
        
    }
}
