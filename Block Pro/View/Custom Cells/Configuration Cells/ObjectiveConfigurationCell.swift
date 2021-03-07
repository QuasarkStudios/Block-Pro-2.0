//
//  ObjectiveConfigurationCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/25/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class ObjectiveConfigurationCell: UITableViewCell {

    let objectiveLabel = UILabel()
    let textViewContainer = UIView()
    let objectiveTextView = UITextView()
    
    var collab: Collab? {
        didSet {
            
            if !(collab?.objective?.leniantValidationOfTextEntered() ?? false) {
                
                objectiveTextView.textColor = .placeholderText
                objectiveTextView.text = "Enter Here"
            }
            
            else {
                
                objectiveTextView.textColor = .black
                objectiveTextView.text = collab?.objective
            }
        }
    }
    
    weak var objectiveConfigurationDelegate: ObjectiveConfigurationProtocol?
    
    override init (style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "objectiveConfigurationCell")
        
        configureNameLabel()
        configureTextViewContainer()
        configureObjectiveTextView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureNameLabel () {
        
        self.contentView.addSubview(objectiveLabel)
        objectiveLabel.configureTitleLabelConstraints()
        
        objectiveLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
        objectiveLabel.textColor = .black
        objectiveLabel.textAlignment = .left
        objectiveLabel.text = "Objective"
    }
    
    private func configureTextViewContainer () {
        
        self.contentView.addSubview(textViewContainer)
        textViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            textViewContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            textViewContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            textViewContainer.topAnchor.constraint(equalTo: self.objectiveLabel.bottomAnchor, constant: 10),
            textViewContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        textViewContainer.backgroundColor = .white
        
        textViewContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        textViewContainer.layer.borderWidth = 1

        textViewContainer.layer.cornerRadius = 10
        textViewContainer.layer.cornerCurve = .continuous
        textViewContainer.clipsToBounds = true
    }
    
    private func configureObjectiveTextView () {

        self.textViewContainer.addSubview(objectiveTextView)
        objectiveTextView.translatesAutoresizingMaskIntoConstraints = false

        [

            objectiveTextView.leadingAnchor.constraint(equalTo: textViewContainer.leadingAnchor, constant: 5),
            objectiveTextView.trailingAnchor.constraint(equalTo: textViewContainer.trailingAnchor, constant: -5),
            objectiveTextView.topAnchor.constraint(equalTo: textViewContainer.topAnchor, constant: 0),
            objectiveTextView.bottomAnchor.constraint(equalTo: textViewContainer.bottomAnchor, constant: 0)

        ].forEach({ $0.isActive = true })

        objectiveTextView.delegate = self

        objectiveTextView.font = UIFont(name: "Poppins-SemiBold", size: 15)
    }
}

extension ObjectiveConfigurationCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "Enter Here" {
            
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        objectiveConfigurationDelegate?.objectiveEntered(objectiveTextView.text ?? "")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if !textView.text.leniantValidationOfTextEntered() {
            
            textView.textColor = .placeholderText
            textView.text = "Enter Here"
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        textView.resignFirstResponder()
        return true
    }
}
