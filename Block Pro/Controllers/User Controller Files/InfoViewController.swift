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
    @IBOutlet weak var infoLabelTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var exitButton: UIButton!
    
    var selectedInfo: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exitButton.layer.cornerRadius = 0.5 * exitButton.bounds.size.width
        exitButton.clipsToBounds = true
        
        infoTextView.layer.cornerRadius = 0.065 * infoTextView.bounds.size.width
        infoTextView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] //Top left corner and top right corner respectively
        infoTextView.clipsToBounds = true
        
        infoLabelTopAnchor.constant = 0
        textViewHeightConstraint.constant = 0
        
        infoLabel.text = selectedInfo
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        infoLabelTopAnchor.constant = 5
        textViewHeightConstraint.constant = view.frame.height - 60
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        stuff()
    }


    func stuff () {
        
        let screenshot = NSTextAttachment()
        screenshot.image = UIImage(named: "TabBar ScreenShot")
        screenshot.bounds = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        
        let screenshotImage = NSAttributedString(attachment: screenshot)
        
        let text = NSMutableAttributedString(string: "hello \n ")
        
        text.addAttribute(.foregroundColor, value: UIColor.flatPink(), range: NSRange(location: 0, length: 5))
        
        text.append(screenshotImage)
        
        infoTextView.attributedText = text
        infoTextView.font = UIFont(name: "HelveticaNeue-Thin", size: 50.0)
        
        
    }
    
    
    @IBAction func exitButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
}
