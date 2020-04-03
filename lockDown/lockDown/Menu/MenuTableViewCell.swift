//
//  MenuTableViewCell.swift
//  GenericApp
//
//  Created by Meriam Messaoui on 09/05/2018.
//  Copyright © 2018 Machinestalk. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var menuIcon: UIImageView!
    @IBOutlet weak var selectedView: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
