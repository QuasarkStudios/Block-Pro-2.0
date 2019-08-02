//
//  CollabBlockTableCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/29/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class CollabBlockTableCell: UITableViewCell {

    @IBOutlet weak var cellContainerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var initialContainer: UIView!
    
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    
    @IBOutlet weak var alphaView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellContainerView.backgroundColor = UIColor.flatMint()
        cellContainerView.layer.cornerRadius = 0.05 * cellContainerView.bounds.size.width
        cellContainerView.clipsToBounds = true
        
        initialContainer.layer.cornerRadius = 0.5 * initialContainer.bounds.size.width
        initialContainer.clipsToBounds = true
        
        alphaView.layer.cornerRadius = 0.05 * alphaView.bounds.size.width
        alphaView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
