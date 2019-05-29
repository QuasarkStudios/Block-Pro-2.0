//
//  CustomBlockTableCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/19/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import ChameleonFramework

class CustomBlockTableCell: UITableViewCell {

    @IBOutlet weak var cellContainerView: UIView!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var blockBar: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellContainerView.layer.cornerRadius = 0.05 * cellContainerView.bounds.size.width
        cellContainerView.clipsToBounds = true
        
        blockBar.layer.cornerRadius = 0.01 * blockBar.bounds.size.width
        blockBar.clipsToBounds = true
        
        cellContainerView.backgroundColor = UIColor.flatSkyBlue()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func editButton(_ sender: Any) {
        print ("1")
    }
}
