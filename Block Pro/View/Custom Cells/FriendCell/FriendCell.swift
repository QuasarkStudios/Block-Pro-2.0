//
//  FriendCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 9/2/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import Foundation

class FriendCell: UITableViewCell {
    
    @IBOutlet weak var initialContainer: UIView!
    @IBOutlet weak var initialContainerLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var initialContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var initialContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var friendInitial: UILabel!
    @IBOutlet weak var friendName: UILabel!
}
