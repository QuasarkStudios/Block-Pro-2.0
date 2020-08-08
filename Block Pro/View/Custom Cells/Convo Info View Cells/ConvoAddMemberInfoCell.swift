//
//  ConvoAddMemberInfoCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 8/2/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class ConvoAddMemberInfoCell: UITableViewCell {

    @IBOutlet weak var addMemberLabel: UILabel!
    
    var members: [Member]? {
        didSet {
            
            if members?.count ?? 0 == 1 {
                
                addMemberLabel.text = "Add Members"
            }
            
            else if members?.count ?? 0 > 1 {
                
                addMemberLabel.text = "Add New Members"
            }
        }
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
