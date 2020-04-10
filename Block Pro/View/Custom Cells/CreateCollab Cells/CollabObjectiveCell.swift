//
//  CollabObjectiveCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/10/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class CollabObjectiveCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var textViewContainer: UIView!
    @IBOutlet weak var objectiveTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureTextView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func configureTextView () {
        
        textViewContainer.backgroundColor = .clear
        textViewContainer.layer.borderWidth = 1
        textViewContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        
        textViewContainer.layer.cornerRadius = 13
        textViewContainer.clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            textViewContainer.layer.cornerCurve = .continuous
        }
        
        objectiveTextView.delegate = self
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "Enter Here" {
            
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            
            textView.text = "Enter Here"
            
            if #available(iOS 13.0, *) {

                textView.textColor = .placeholderText
                
            } else {
                
                textView.textColor = .lightGray
            }
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        textView.resignFirstResponder()
        return true
    }
    
}
