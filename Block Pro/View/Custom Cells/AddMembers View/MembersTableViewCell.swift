//
//  AddMembersCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/12/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class MembersTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicContainer: UIView!
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var addedIndicator: UILabel!
    
    var memberUserID: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profilePicContainer.configureProfilePicContainer()
        
        addedIndicator.backgroundColor = UIColor(hexString: "222222")
        addedIndicator.layer.cornerRadius = 0.21 * addedIndicator.frame.width
        addedIndicator.clipsToBounds = true
        addedIndicator.isHidden = true
    }

    //Handles the cell backgroundColor animation when the cell is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.backgroundColor = UIColor(hexString: "D8D8D8")?.lighten(byPercentage: 0.1)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        self.backgroundColor = nil
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut, animations: {
            
            self.backgroundColor = nil
        })
    }
}
