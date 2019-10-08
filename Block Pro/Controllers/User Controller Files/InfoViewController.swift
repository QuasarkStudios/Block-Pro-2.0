//
//  InfoViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/7/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var textViewTopAnchor: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoTextView.layer.cornerRadius = 0.065 * infoTextView.bounds.size.width
        infoTextView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] //Top left corner and top right corner respectively
        infoTextView.clipsToBounds = true
        
        textViewTopAnchor.constant = view.frame.height
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        textViewTopAnchor.constant = 5
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }


}
