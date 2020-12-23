//
//  CollabHomeLinkCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 12/13/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import FavIcon

class CollabHomeLinkCollectionViewCell: UICollectionViewCell {
    
    let leftLinkView = UIView()
    let leftImageViewContainer = UIView()
    let leftImageView = UIImageView()
    let leftLinkLabel = UILabel()
    
    let rightLinkView = UIView()
    let rightImageViewContainer = UIView()
    let rightImageView = UIImageView()
    let rightLinkLabel = UILabel()
    
    var leftLink: Link? {
        didSet {
            
            reconfigureLinkView(link: leftLink, linkView: leftLinkView, imageViewContainer: leftImageViewContainer, imageView: leftImageView, label: leftLinkLabel)
        }
    }
    
    var rightLink: Link? {
        didSet {
            
            reconfigureLinkView(link: rightLink, linkView: rightLinkView, imageViewContainer: rightImageViewContainer, imageView: rightImageView, label: rightLinkLabel)
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
    
    weak var cacheIconDelegate: CacheIconProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureCell()
        configureLinkView(linkView: leftLinkView, imageViewContainer: leftImageViewContainer, imageView: leftImageView, label: leftLinkLabel)
        configureLinkView(linkView: rightLinkView, imageViewContainer: rightImageViewContainer, imageView: rightImageView, label: rightLinkLabel)
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
    
    private func configureLinkView (linkView: UIView, imageViewContainer: UIView, imageView: UIImageView, label: UILabel) {
        
        setLinkViewConstraints(linkView: linkView, imageViewContainer: imageViewContainer, imageView: imageView, label: label)
        
        imageViewContainer.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.65)
        imageViewContainer.layer.cornerRadius = 22
        imageViewContainer.clipsToBounds = true

        addTapGesture(leftImageView: imageView == leftImageView)
        
        imageView.tintColor = .black
        imageView.image = UIImage(systemName: "link")
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
        
        label.font = UIFont(name: "Poppins-SemiBold", size: 13)
        label.textAlignment = .center
        label.textColor = .black
    }
    
    
    //MARK: - Reconfigure Link View
    
    private func reconfigureLinkView (link: Link?, linkView: UIView, imageViewContainer: UIView, imageView: UIImageView, label: UILabel) {
        
        if link == nil {
            
            linkView.isHidden = true
        }
        
        else {
            
            linkView.isHidden = false
            
            retrieveIcon(link: link!) { [weak self] (icon) in
                
                self?.setImage(imageViewContainer: imageViewContainer, imageView: imageView, image: icon)
            }
            
            if let name = link?.name, name.leniantValidationOfTextEntered() {
                
                label.text = name
            }
            
            else {
                
                label.text = link?.url
            }
        }
    }
    
    
    //MARK: - Set Link View Constraints
    
    private func setLinkViewConstraints (linkView: UIView, imageViewContainer: UIView, imageView: UIImageView, label: UILabel) {
        
        linkView.addSubview(imageViewContainer)
        imageViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        imageViewContainer.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        linkView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            imageViewContainer.centerXAnchor.constraint(equalTo: linkView.centerXAnchor),
            imageViewContainer.centerYAnchor.constraint(equalTo: linkView.centerYAnchor, constant: -7.5),
            imageViewContainer.widthAnchor.constraint(equalToConstant: 44),
            imageViewContainer.heightAnchor.constraint(equalToConstant: 44),
            
            imageView.centerXAnchor.constraint(equalTo: imageViewContainer.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: imageViewContainer.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 28),
            imageView.heightAnchor.constraint(equalToConstant: 28),
            
            label.bottomAnchor.constraint(equalTo: linkView.bottomAnchor, constant: -3),
            label.leadingAnchor.constraint(equalTo: linkView.leadingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: linkView.trailingAnchor, constant: -5),
            label.heightAnchor.constraint(equalToConstant: 15)
        
        ].forEach({ $0.isActive = true })
    }
    
    
    //MARK: - Retrieve Icon
    
    private func retrieveIcon (link: Link, completion: @escaping ((_ icon: UIImage?) -> Void)) {
        
        if link.icon == nil {
            
            retrieveFavIcon(urlString: link.url) { [weak self] (icon) in
                
                completion(icon != nil ? icon : UIImage(named: "link"))
                
                self?.cacheIconDelegate?.cacheIcon(linkID: link.linkID ?? "", icon: icon != nil ? icon : UIImage(named: "link"))
            }
        }
        
        else {
            
            completion(link.icon)
        }
    }
    
    
    //MARK: - Retrieve Fav Icon
    
    func retrieveFavIcon (urlString: String?, completion: @escaping ((_ image: UIImage?) -> Void)) {
        
        var url: String = ""
        
        //Attempts to ensure that all URL's entered are formatted correctly, and attempts reformat them if they aren't
        if urlString?.localizedCaseInsensitiveContains("https:") ?? false {
            
            url = urlString!
        }
        
        else {
            
            url = "https://" + urlString!
        }
        
        do {
                
            try FavIcon.downloadPreferred(url, completion: { (result) in
                
                if case let .success(image) = result {
                    
                    //Prevents images that will be too blurry from being used
                    if image.size.width >= 30 || image.size.height >= 30 {
                        
                        completion(image)
                    }
                    
                    else {
                        
                        completion(nil)
                    }
                }
                
                //If the download failed
                else {
                    
                    completion(nil)
                }
            })
            
        } catch {
            
            completion(nil)
        }
    }
    
    
    //MARK: - Set Image
    
    private func setImage (imageViewContainer: UIView, imageView: UIImageView, image: UIImage?) {
        
        imageViewContainer.backgroundColor = image != UIImage(named: "link") ? .white : UIColor(hexString: "D8D8D8", withAlpha: 0.65)
        
        imageView.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                
                constraint.constant = image != UIImage(named: "link") ? 44 : 28
            }
        }
        
        imageView.image = image
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
    
    
    //MARK: - Add Link View Tap Gesture
    
    private func addTapGesture (leftImageView: Bool) {
        
        if leftImageView {
            
            leftImageViewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftLinkTapped)))
        }
        
        else {
            
            rightImageViewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightLinkTapped)))
        }
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
