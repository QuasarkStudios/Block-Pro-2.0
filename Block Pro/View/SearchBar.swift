//
//  SearchBar.swift
//  Block Pro
//
//  Created by Nimat Azeez on 8/20/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class SearchBar: UIView {

    let searchImage = UIImageView(image: UIImage(named: "search2"))
    let searchTextField = UITextField()
    
    weak var parentViewController: AnyObject?
    
    init (parentViewController: AnyObject, placeholderText: String) {
        super.init(frame: .zero)
        
        self.parentViewController = parentViewController
        
        configureSearchBarContainer()
        configureSearchImage()
        configureSearchTextField(placeholderText: placeholderText)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSearchBarContainer () {
        
        self.layer.cornerRadius = 18
        self.clipsToBounds = true
        self.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        self.layer.borderWidth = 1
        
        if #available(iOS 13.0, *) {
            self.layer.cornerCurve = .continuous
        }
    }
    
    private func configureSearchImage () {
        
        self.addSubview(searchImage)
        searchImage.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            searchImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            searchImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            searchImage.widthAnchor.constraint(equalToConstant: 21),
            searchImage.heightAnchor.constraint(equalToConstant: 21)
        
        ].forEach({ $0.isActive = true })
    }
    
    private func configureSearchTextField (placeholderText: String) {
        
        self.addSubview(searchTextField)
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            searchTextField.leadingAnchor.constraint(equalTo: searchImage.trailingAnchor, constant: 14),
            searchTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            searchTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            searchTextField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
            
        
        ].forEach({ $0.isActive = true })
        
        searchTextField.delegate = self
        
        searchTextField.borderStyle = .none
        searchTextField.font = UIFont(name: "Poppins-Medium", size: 15.5)
        searchTextField.placeholder = placeholderText
        searchTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor(hexString: "AAAAAA") as Any])
        
        searchTextField.returnKeyType = .done
        
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
    }
    
    @objc private func searchTextChanged () {
        
        if let messagesHomeVC = parentViewController as? MessagesHomeViewController {
            
            messagesHomeVC.searchTextChanged(searchText: searchTextField.text ?? "")
        }
        
        else if let addLocationVC = parentViewController as? AddLocationViewController {
            
            addLocationVC.searchTextChanged(searchText: searchTextField.text ?? "")
        }
        
        else if let addMemberVC = parentViewController as? AddMembersViewController {
            
            addMemberVC.searchTextChanged(searchText: searchTextField.text ?? "")
        }
    }
}

extension SearchBar: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if let addLocationVC = parentViewController as? AddLocationViewController {
            
            addLocationVC.searchBegan()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                
                let endOfTextField = textField.endOfDocument
                textField.selectedTextRange = textField.textRange(from: endOfTextField, to: endOfTextField) //Setting the cursor to the end
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        if let addLocationVC = parentViewController as? AddLocationViewController {
            
            addLocationVC.searchEnded()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        searchTextField.resignFirstResponder()
        return true
    }
}
