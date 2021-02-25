//
//  CollabObjectiveViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/17/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class CollabObjectiveViewController: UIViewController {

    let navBar = UINavigationBar()
    let objectiveTextView = UITextView()
    
    var objective: String? {
        didSet {
            
            objectiveTextView.font = objective?.leniantValidationOfTextEntered() ?? false ? UIFont(name: "Poppins-Regular", size: 18) : UIFont(name: "Poppins-Italic", size: 18)
            objectiveTextView.text = objective?.leniantValidationOfTextEntered() ?? false ? objective : "No Objective Yet"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
        configureNavBar()
        configureObjectiveTextView()
    }
    
    private func configureNavBar () {
        
        self.view.addSubview(navBar)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            navBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            navBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            navBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            navBar.heightAnchor.constraint(equalToConstant: 44)
        
        ].forEach({ $0.isActive = true })
        
        navBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .black)
        
        let navigationItem = UINavigationItem(title: "Objective")
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(cancelButtonPressed))
        cancelButton.style = .done
        navigationItem.leftBarButtonItem = cancelButton
        
        navBar.setItems([navigationItem], animated: false)
    }
    
    private func configureObjectiveTextView () {
        
        self.view.addSubview(objectiveTextView)
        objectiveTextView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            objectiveTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            objectiveTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            objectiveTextView.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 10),
            objectiveTextView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            
        ].forEach({ $0.isActive = true })
        
        objectiveTextView.isEditable = false
        objectiveTextView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    @objc private func cancelButtonPressed () {
        
        self.dismiss(animated: true, completion: nil)
    }
}
