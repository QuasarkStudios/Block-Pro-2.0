//
//  LinksConfigurationCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/14/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class LinksConfigurationCollectionViewCell: UICollectionViewCell {
    
    let leftLinkView = UIView()
    let leftCancelButton = UIButton(type: .system)
    let leftImageViewContainer = UIView()
    let leftImageView = UIImageView()
    let leftTextField = UITextField()
    
    let rightLinkView = UIView()
    let rightCancelButton = UIButton(type: .system)
    let rightImageViewContainer = UIView()
    let rightImageView = UIImageView()
    let rightTextField = UITextField()
    
    var leftLink: Link? {
        didSet {
            
            reconfigureLinkView(link: leftLink, linkView: leftLinkView, imageViewContainer: leftImageViewContainer, imageView: leftImageView, textField: leftTextField)
        }
    }
    
    var rightLink: Link? {
        didSet {
            
            reconfigureLinkView(link: rightLink, linkView: rightLinkView, imageViewContainer: rightImageViewContainer, imageView: rightImageView, textField: rightTextField)
        }
    }
    
    var leftImage: UIImage? {
        didSet {
            
            setImage(imageViewContainer: leftImageViewContainer, imageView: leftImageView, image: leftImage)
        }
    }
    
    var rightImage: UIImage? {
        didSet {
            
            setImage(imageViewContainer: rightImageViewContainer, imageView: rightImageView, image: rightImage)
        }
    }
    
    weak var linksConfigurationDelegate: LinksConfigurationProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureCell()
        configureLinkView(linkView: leftLinkView, cancelButton: leftCancelButton, imageViewContainer: leftImageViewContainer, imageView: leftImageView, textField: leftTextField)
        configureLinkView(linkView: rightLinkView, cancelButton: rightCancelButton, imageViewContainer: rightImageViewContainer, imageView: rightImageView, textField: rightTextField)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configure Cell
    
    private func configureCell () {
        
        contentView.addSubview(leftLinkView)
        leftLinkView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(rightLinkView)
        rightLinkView.translatesAutoresizingMaskIntoConstraints = false
        
        //70 is leading and trailing of the link container i.e. 40; + left and right anchors of the views i.e. 20; + the size of gap that should between the two cell i.e. 10
        let viewWidth = (UIScreen.main.bounds.width - 70) / 2
        
        [
        
            leftLinkView.topAnchor.constraint(equalTo: contentView.topAnchor),
            leftLinkView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            leftLinkView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            leftLinkView.widthAnchor.constraint(equalToConstant: viewWidth),
            
            rightLinkView.topAnchor.constraint(equalTo: contentView.topAnchor),
            rightLinkView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            rightLinkView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            rightLinkView.widthAnchor.constraint(equalToConstant: viewWidth)
            
        ].forEach({ $0.isActive = true })
        
        leftLinkView.layer.cornerRadius = 10
        leftLinkView.layer.borderWidth = 1
        leftLinkView.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        
        rightLinkView.layer.cornerRadius = 10
        rightLinkView.layer.borderWidth = 1
        rightLinkView.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
    }
    
    
    //MARK: - Configure Link View
    
    private func configureLinkView (linkView: UIView, cancelButton: UIButton, imageViewContainer: UIView, imageView: UIImageView, textField: UITextField) {
        
        setLinkViewConstraints(linkView: linkView, cancelButton: cancelButton, imageViewContainer: imageViewContainer, imageView: imageView, textField: textField)
        
        cancelButton.tintColor = UIColor(hexString: "222222")
        cancelButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        
        addCancelButtonTarget(leftCancelButton: cancelButton == leftCancelButton)
        
        imageViewContainer.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.65)
        imageViewContainer.layer.cornerRadius = 22
        imageViewContainer.clipsToBounds = true
        
        addTapGesture(leftImageView: imageView == leftImageView)

        imageView.tintColor = .black
        imageView.image = UIImage(systemName: "link")
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
        
        textField.borderStyle = .none
        textField.font = UIFont(name: "Poppins-SemiBold", size: 13)
        textField.textAlignment = .center
        textField.keyboardType = .URL
        textField.returnKeyType = .done
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        textField.setCustomPlaceholder(text: "Enter link", alignment: .center)
    }
    
    
    //MARK: - Reconfigure Link View
    
    private func reconfigureLinkView (link: Link?, linkView: UIView, imageViewContainer: UIView, imageView: UIImageView, textField: UITextField) {
        
        if link == nil {
            
            linkView.isHidden = true
        }
        
        else {
            
            linkView.isHidden = false
            
            setImage(imageViewContainer: imageViewContainer, imageView: imageView, image: link?.icon)
            
            if let name = link?.name, name.leniantValidationOfTextEntered() {
                
                textField.text = name
            }
            
            else {
                
                textField.text = link?.url
            }
        }
    }
    
    
    //MARK: - Set Link View Constraints
    
    private func setLinkViewConstraints (linkView: UIView, cancelButton: UIButton, imageViewContainer: UIView, imageView: UIImageView, textField: UITextField) {
        
        linkView.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        linkView.addSubview(imageViewContainer)
        imageViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        imageViewContainer.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        linkView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            cancelButton.topAnchor.constraint(equalTo: linkView.topAnchor, constant: 3),
            cancelButton.trailingAnchor.constraint(equalTo: linkView.trailingAnchor, constant: -3),
            cancelButton.widthAnchor.constraint(equalToConstant: 23),
            cancelButton.heightAnchor.constraint(equalToConstant: 23),
            
            imageViewContainer.centerXAnchor.constraint(equalTo: linkView.centerXAnchor),
            imageViewContainer.centerYAnchor.constraint(equalTo: linkView.centerYAnchor, constant: -7.5),
            imageViewContainer.widthAnchor.constraint(equalToConstant: 44),
            imageViewContainer.heightAnchor.constraint(equalToConstant: 44),
            
            imageView.centerXAnchor.constraint(equalTo: imageViewContainer.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: imageViewContainer.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 28),
            imageView.heightAnchor.constraint(equalToConstant: 28),
            
            textField.bottomAnchor.constraint(equalTo: linkView.bottomAnchor, constant: -3),
            textField.leadingAnchor.constraint(equalTo: linkView.leadingAnchor, constant: 5),
            textField.trailingAnchor.constraint(equalTo: linkView.trailingAnchor, constant: -5),
            textField.heightAnchor.constraint(equalToConstant: 17)
        
        ].forEach({ $0.isActive = true })
    }
    
    
    //MARK: - Set Image
    
    private func setImage (imageViewContainer: UIView, imageView: UIImageView, image: UIImage? ) {
        
        imageViewContainer.backgroundColor = image != nil ? .white : UIColor(hexString: "D8D8D8", withAlpha: 0.65)
        
        imageView.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                
                constraint.constant = image != nil ? 44 : 28
            }
        }
        
        imageView.image = image != nil ? image : UIImage(systemName: "link")
    }
    
    
    //MARK: - Open URL
    
    private func openURL (_ urlString: String) {
        
        var url: URL?
        
        //Attempts to ensure that all URL's entered are formatted correctly, and attempts reformat them if they aren't
        if urlString.localizedCaseInsensitiveContains("https:") {
            
            url = URL(string: urlString)
        }
        
        else {
            
            url = URL(string: "https://" + urlString)
        }
        
        if url != nil {
            
            UIApplication.shared.open(url!) //Opens url
        }
    }
    
    
    //MARK: - Add Cancel Button Target
    
    private func addCancelButtonTarget (leftCancelButton: Bool) {
        
        if leftCancelButton {
            
            self.leftCancelButton.addTarget(self, action: #selector(leftCancelButtonPressed), for: .touchUpInside)
        }
        
        else {
            
            rightCancelButton.addTarget(self, action: #selector(rightCancelButtonPressed), for: .touchUpInside)
        }
    }
    
    
    //MARK: - Add Link View Tap Gesture
    
    private func addTapGesture (leftImageView: Bool) {
        
        if leftImageView {
            
            leftImageViewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftLinkTapped)))
        }
        
        else {
            
            rightImageViewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightLinkTapped)))
        }
    }
    
    
    //MARK: - Cancel Button Pressed Functions
    
    @objc private func leftCancelButtonPressed () {
        
        linksConfigurationDelegate?.linkDeleted(leftLink?.linkID ?? "")
        
        leftTextField.setCustomPlaceholder(text: "Enter link", alignment: .center)
    }
    
    @objc private func rightCancelButtonPressed () {
        
        linksConfigurationDelegate?.linkDeleted(rightLink?.linkID ?? "")
        
        rightTextField.setCustomPlaceholder(text: "Enter link", alignment: .center)
    }
    
    
    //MARK: - Link Tapped Functions
    
    @objc private func leftLinkTapped () {
        
        if let urlString = leftLink?.url, urlString.leniantValidationOfTextEntered() {
            
            openURL(urlString)
        }
    }
    
    @objc private func rightLinkTapped () {
        
        if let urlString = rightLink?.url, urlString.leniantValidationOfTextEntered() {
            
            openURL(urlString)
        }
    }
}
