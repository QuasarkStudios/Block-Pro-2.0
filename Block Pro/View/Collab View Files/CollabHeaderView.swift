//
//  CollabHeaderView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/2/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

class CollabHeaderView: UIView {
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    lazy var addCoverButton = UIButton(type: .system)
    var coverPhoto: ProfilePicture? //= ProfilePicture(profilePic: UIImage(named: "Mountains"), shadowRadius: 0, shadowColor: UIColor.clear.cgColor, borderWidth: 0)
    
    let coverPhotoContainer = UIView()
    let coverPhotoImageView = UIImageView()
    
    let nameLabel = UILabel()
    
    let objectiveHeaderLabel = UILabel()
    let objectiveTextLabel = UILabel()
    
    let deadlineHeaderLabel = UILabel()
    let deadlineTextLabel = UILabel()
    
    let expandButton = UIButton(type: .system)
    
    var collab: Collab?
    let formatter = DateFormatter()
    
    weak var collabViewController: AnyObject?
    
    init (_ collab: Collab?) {
        super.init(frame: .zero)
        
        self.collab = collab
        
//        configureCoverPhoto()
//        configureAddCoverButton()
        configureNameLabel()
        configureObjectiveLabel()
        configureDeadlineLabel()
        configureExpandButton()
        
        setCoverPhoto(collab)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        configureView()
    }
    
    private func configureView () {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        guard let view = self.superview else { return }
        
            [
            
                self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                self.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
//                self.heightAnchor.constraint(equalToConstant: 325)
                self.heightAnchor.constraint(equalToConstant: configureViewHeight())
                
            ].forEach({ $0.isActive = true })
            
            self.backgroundColor = UIColor(hexString: "222222")
            
            self.layer.cornerRadius = 32.5
            self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
            self.layer.shadowRadius = 2
            self.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.layer.shadowOpacity = 0.35
    }
    
    private func configureAddCoverButton () {
        
        coverPhoto?.removeFromSuperview()
        addCoverButton.removeFromSuperview()
        
        self.addSubview(addCoverButton)
        addCoverButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            addCoverButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 86.66),
            addCoverButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            addCoverButton.widthAnchor.constraint(equalToConstant: 53),
            addCoverButton.heightAnchor.constraint(equalToConstant: 53)
        
        ].forEach({ $0.isActive = true })
        
        addCoverButton.backgroundColor = .white
        addCoverButton.tintColor = .black
        
        addCoverButton.layer.shadowColor = UIColor.white.cgColor
        addCoverButton.layer.shadowOpacity = 0.5
        addCoverButton.layer.shadowRadius = 2.5
        addCoverButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        addCoverButton.layer.cornerRadius = 53 * 0.5
        
        addCoverButton.setImage(UIImage(named: "add_a_cover"), for: .normal)
        addCoverButton.imageEdgeInsets = UIEdgeInsets(top: 11, left: 9.5, bottom: 9, right: 10.5)
        
        addCoverButton.addTarget(self, action: #selector(addCoverPressed), for: .touchUpInside)
    }
    
    func configureCoverPhoto (_ cover: UIImage? = nil) {
        
        coverPhoto?.removeFromSuperview()
        addCoverButton.removeFromSuperview()

        if cover != nil {
            
            coverPhoto = ProfilePicture(profilePic: cover, shadowRadius: 2.5, shadowColor: UIColor.white.cgColor, shadowOpacity: 0.5, borderColor: UIColor(hexString: "F4F4F4")!.withAlphaComponent(0.05).cgColor, borderWidth: 1)
            coverPhoto?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(coverPhotoPressed)))
        }
        
        else {
            
            coverPhoto = ProfilePicture(profilePic: UIImage(named: "Mountains"), shadowRadius: 0, shadowColor: UIColor.clear.cgColor, borderWidth: 0)
        }
        
        self.addSubview(coverPhoto!)
        coverPhoto?.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            coverPhoto?.topAnchor.constraint(equalTo: self.topAnchor, constant: 86.66),
            coverPhoto?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            coverPhoto?.widthAnchor.constraint(equalToConstant: 53),
            coverPhoto?.heightAnchor.constraint(equalToConstant: 53)
        
        ].forEach({ $0?.isActive = true })
    }
    
    private func configureNameLabel () {
        
        self.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
//            coverPhotoContainer.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 34),
            nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -34),
            nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: topBarHeight + 10),
            nameLabel.heightAnchor.constraint(equalToConstant: 30)
        
        ].forEach({ $0.isActive = true })
        
        nameLabel.text = collab?.name ?? "Collab Name"
        nameLabel.textColor = .white
        nameLabel.textAlignment = .left
        nameLabel.font = UIFont(name: "Poppins-SemiBold", size: 23)
    }
    
    private func configureObjectiveLabel () {
        
        self.addSubview(objectiveHeaderLabel)
        self.addSubview(objectiveTextLabel)
        
        objectiveHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        objectiveTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            objectiveHeaderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 34),
            objectiveHeaderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -34),
            objectiveHeaderLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 13),
            objectiveHeaderLabel.heightAnchor.constraint(equalToConstant: 20),
        
            objectiveTextLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 34),
            objectiveTextLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            objectiveTextLabel.topAnchor.constraint(equalTo: objectiveHeaderLabel.bottomAnchor, constant: 5),
            objectiveTextLabel.heightAnchor.constraint(equalToConstant: 50)
            
        ].forEach({ $0.isActive = true })
        
        objectiveHeaderLabel.text = "Objective:"
        objectiveHeaderLabel.textColor = .white
        objectiveHeaderLabel.font = UIFont(name: "Poppins-Medium", size: 16)
        
        objectiveTextLabel.textColor = .white
//        objectiveTextLabel.font = UIFont(name: "Poppins-Regular", size: 13)
        objectiveTextLabel.numberOfLines = 0
            
        setObjectiveLabelText()
    }
    
    private func configureDeadlineLabel () {
        
        self.addSubview(deadlineHeaderLabel)
        self.addSubview(deadlineTextLabel)
        
        deadlineHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        deadlineTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            deadlineHeaderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 34),
            deadlineHeaderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -34),
            deadlineHeaderLabel.topAnchor.constraint(equalTo: objectiveTextLabel.bottomAnchor, constant: 10),
            deadlineHeaderLabel.heightAnchor.constraint(equalToConstant: 20),
            
            deadlineTextLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 34),
            deadlineTextLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -34),
            deadlineTextLabel.topAnchor.constraint(equalTo: deadlineHeaderLabel.bottomAnchor, constant: 5),
            deadlineTextLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        deadlineHeaderLabel.text = "Deadline:"
        deadlineHeaderLabel.textColor = .white
        deadlineHeaderLabel.font = UIFont(name: "Poppins-Medium", size: 16)
        
        if let deadline = collab?.dates["deadline"] {
             
            deadlineTextLabel.font = UIFont(name: "Poppins-Regular", size: 13)
            
            formatter.dateFormat = "d MMMM yyyy"
            var deadlineText = formatter.string(from: deadline)
            deadlineText += " at "
            
            formatter.dateFormat = "h:mm a"
            deadlineText += formatter.string(from: deadline)
            
            deadlineTextLabel.text = deadlineText
            
        }
        
        else {
            
            deadlineTextLabel.font = UIFont(name: "Poppins-Italic", size: 13)
            
            deadlineTextLabel.text = "No Deadline Yet"
        }
        
        deadlineTextLabel.textColor = .white
//        deadlineTextLabel.font = UIFont(name: "Poppins-Regular", size: 13)
    }
    
    private func configureExpandButton () {
        
        self.addSubview(expandButton)
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            expandButton.topAnchor.constraint(equalTo: deadlineHeaderLabel.topAnchor, constant: 12.5),
            expandButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            expandButton.widthAnchor.constraint(equalToConstant: 20),
            expandButton.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        expandButton.setImage(UIImage(named: "expand"), for: .normal)
        expandButton.contentVerticalAlignment = .fill
        expandButton.contentHorizontalAlignment = .fill
        expandButton.tintColor = .white
    }
    
    func configureViewHeight () -> CGFloat {
        
        let viewHeightWithoutDeadlineText: CGFloat = topBarHeight + 133
        
        if let objective = collab?.objective {
            
            let objectiveTextLabelHeight = objective.estimateHeightForObjectiveTextLabel().height < 55 ? objective.estimateHeightForObjectiveTextLabel().height : 55
            return viewHeightWithoutDeadlineText + objectiveTextLabelHeight + 100//70
        }
        
        else {
            
            return viewHeightWithoutDeadlineText + 20 + 100//70
        }
    }
    
    func setCoverPhoto (_ collab: Collab?) {
        
        if let collab = collab {
            
            if collab.coverPhotoID != nil {
                
                configureCoverPhoto()
                
                if let collabIndex = firebaseCollab.collabs.firstIndex(where: { $0.collabID == collab.collabID }) {
                    
                    if let cover = firebaseCollab.collabs[collabIndex].coverPhoto {
                        
                        configureCoverPhoto(cover)
                    }
                    
                    else {
                        
                        firebaseStorage.retrieveCollabCoverPhoto(collabID: collab.collabID) { (cover, error) in
                            
                            if error != nil {
                                
                                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                            }
                            
                            else {
                                
                                self.configureCoverPhoto(cover)
                                
                                self.firebaseCollab.collabs[collabIndex].coverPhoto = cover
                            }
                        }
                    }
                }
            }
            
            else {
                
                configureAddCoverButton()
            }
        }
    }
    
    func setObjectiveLabelText() {
        
        objectiveTextLabel.text = collab?.objective ?? "No Objective Yet"
        objectiveTextLabel.font = collab?.objective != nil ? UIFont(name: "Poppins-Regular", size: 13) : UIFont(name: "Poppins-Italic", size: 13)
        
        let objectiveTextLabelHeightConstraint = objectiveTextLabel.constraints.first(where: { $0.firstAttribute == .height })
        
        if let objective = collab?.objective {
            
            let objectiveTextLabelHeight = objective.estimateHeightForObjectiveTextLabel().height < 55 ? objective.estimateHeightForObjectiveTextLabel().height : 55
            objectiveTextLabelHeightConstraint?.constant = objectiveTextLabelHeight
        }
        
        else {
            
            objectiveTextLabelHeightConstraint?.constant = 20
        }
    }
    
    @objc private func addCoverPressed () {
        
        if let viewController = collabViewController as? CollabViewController {
            
            viewController.presentAddPhotoAlert(tracker: "coverAlert", shrinkView: true)
        }
    }
    
    @objc private func coverPhotoPressed () {
        
        if let viewController = collabViewController as? CollabViewController {
//
//            viewController.editCoverButton.removeTarget(nil, action: nil, for: .allEvents)
//            viewController.deleteCoverButton.removeTarget(nil, action: nil, for: .allEvents)
//
//            viewController.editCoverButton.addTarget(viewController, action: #selector(viewController.editCoverButtonPressed), for: .touchUpInside)
//            viewController.deleteCoverButton.addTarget(viewController, action: #selector(viewController.deleteCoverButtonPressed), for: .touchUpInside)
            
            if let imageView = coverPhoto?.profilePicImageView {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    
                    self.coverPhoto?.layer.shadowColor = UIColor.clear.cgColor
                    self.coverPhoto?.layer.borderColor = UIColor.clear.cgColor
                }
                
                viewController.zoomingMethods = ZoomingImageViewMethods(on: imageView, cornerRadius: 53 * 0.5, with: [viewController.editCoverButton, viewController.deleteCoverButton], completion: {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        
                        let shadowAnimation = CABasicAnimation(keyPath: "shadowColor")
                        shadowAnimation.fromValue = UIColor.clear.cgColor
                        shadowAnimation.toValue = UIColor.white.cgColor
                        shadowAnimation.duration = 0.3
                        self.coverPhoto?.layer.add(shadowAnimation, forKey: nil)
                        self.coverPhoto?.layer.shadowColor = UIColor.white.cgColor
                        
                        let borderAnimation = CABasicAnimation(keyPath: "borderColor")
                        borderAnimation.fromValue = UIColor.clear.cgColor
                        borderAnimation.toValue = UIColor(hexString: "F4F4F4")?.withAlphaComponent(0.05).cgColor
                        borderAnimation.duration = 0.3
                        self.coverPhoto?.layer.add(borderAnimation, forKey: nil)
                        self.coverPhoto?.layer.borderColor = UIColor(hexString: "F4F4F4")?.withAlphaComponent(0.05).cgColor
                    }
                })
                
                viewController.zoomingMethods?.performZoom()
            }
        }
    }
}
