//
//  AddMembersCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/10/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol AddMembers: AnyObject {
    
    func addMemberButtonPressed ()
    
    func performSegueToProfileView (member: Friend)
}

class CollabMembersCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var addMembersButton: UIButton!
    @IBOutlet weak var addButtonLeadingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var addIconLeadingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var addLabel: UILabel!
    
    @IBOutlet weak var membersCollectionView: UICollectionView!
    
    var members: [Friend]?
    
    weak var addMembersDelegate: AddMembers?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        configureButton()
        configureCollectionView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return members?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "membersCollectionViewCell", for: indexPath) as! MembersCollectionViewCell
        
        cell.memberNameLabel.text = members?[indexPath.row].firstName
        
        cell.profilePicImageView.configureProfileImageView(profileImage: members?[indexPath.row].profilePictureImage)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if members != nil {
            
            addMembersDelegate?.performSegueToProfileView(member: members![indexPath.row])
        }
    }
    
    private func configureButton () {
        
        buttonContainer.layer.borderWidth = 1
        buttonContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        
        buttonContainer.layer.cornerRadius = 10
        buttonContainer.clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            buttonContainer.layer.cornerCurve = .continuous
        }
    }
    
    func reconfigureButtonContainer (collectionViewPresent: Bool) {
        
        if collectionViewPresent {
            
            addLabel.isHidden = true
            
            addButtonLeadingAnchor.constant = buttonContainer.frame.width - (25 + 20
            + 20)
                   
            addIconLeadingAnchor.constant = buttonContainer.frame.width - (25 + 20)
        }
        
        else {
            
            addLabel.isHidden = false
            
            addButtonLeadingAnchor.constant = 0
                   
            addIconLeadingAnchor.constant = 20
        }
    }
    
    private func configureCollectionView () {
        
        membersCollectionView.dataSource = self
        membersCollectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 95, height: 35)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        
        membersCollectionView.collectionViewLayout = layout
        membersCollectionView.showsHorizontalScrollIndicator = false
        
        membersCollectionView.register(UINib(nibName: "MembersCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "membersCollectionViewCell")
    }
    
    @IBAction func addMembersButton(_ sender: Any) {
        
        addMembersDelegate?.addMemberButtonPressed()
    }
    
}
