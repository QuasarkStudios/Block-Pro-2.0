//
//  BlockOtherSettingCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/3/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class BlockOtherSettingCell: UITableViewCell {

    @IBOutlet weak var cellBackground: UIView!
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var settingSelectionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellBackground.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.35)
        
        cellBackground.layer.cornerRadius = 6
        cellBackground.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    
        
        // Configure the view for the selected state
    }
    

    
}
