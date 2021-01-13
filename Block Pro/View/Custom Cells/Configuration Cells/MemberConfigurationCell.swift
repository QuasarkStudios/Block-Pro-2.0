//
//  MemberConfigurationCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/7/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class MemberConfigurationCell: UITableViewCell {

    let membersLabel = UILabel()
    let membersCountLabel = UILabel()
    let membersContainer = UIView()
    
    let addMemberButton = UIButton()
    let addMemberImage = UIImageView(image: UIImage(systemName: "person.crop.circle.badge.plus"))
    let addMembersLabel = UILabel()
    
    let membersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    var collab: Collab?
    var members: [Any]? {
        didSet {
            
            reconfigureCell()
        }
    }
    
    weak var memberConfigurationDelegate: MemberConfigurationProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "memberConfigurationCell")
        
        configureMembersLabel()
        configureMembersCountLabel()
        configureMembersContainer()
        configureAddMembersButton()
        configureCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configure Members Label
    
    private func configureMembersLabel () {
        
        self.contentView.addSubview(membersLabel)
        membersLabel.configureConfigurationTitleLabelConstraints()
        
        membersLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
        membersLabel.textColor = .black
        membersLabel.textAlignment = .left
        membersLabel.text = "Members"
    }
    
    
    //MARK: - Configure Members Count Label
    
    private func configureMembersCountLabel () {
        
        self.contentView.addSubview(membersCountLabel)
        membersCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            membersCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            membersCountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            membersCountLabel.widthAnchor.constraint(equalToConstant: 75),
            membersCountLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        membersCountLabel.alpha = 0
        membersCountLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
        membersCountLabel.textColor = .black
        membersCountLabel.textAlignment = .right
    }
    
    
    //MARK: - Configure Members Container
    
    private func configureMembersContainer () {
        
        self.contentView.addSubview(membersContainer)
        membersContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            membersContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            membersContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            membersContainer.topAnchor.constraint(equalTo: self.membersLabel.bottomAnchor, constant: 10),
            membersContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        membersContainer.backgroundColor = .white
        
        membersContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        membersContainer.layer.borderWidth = 1

        membersContainer.layer.cornerRadius = 10
        membersContainer.layer.cornerCurve = .continuous
        membersContainer.clipsToBounds = true
    }

    
    //MARK: - Configure Add Members Button
    
    private func configureAddMembersButton () {
        
        membersContainer.addSubview(addMemberButton)
        addMemberButton.addSubview(addMemberImage)
        addMemberButton.addSubview(addMembersLabel)
        
        addMemberButton.translatesAutoresizingMaskIntoConstraints = false
        addMemberImage.translatesAutoresizingMaskIntoConstraints = false
        addMembersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            addMemberButton.leadingAnchor.constraint(equalTo: membersContainer.leadingAnchor, constant: 0),
            addMemberButton.trailingAnchor.constraint(equalTo: membersContainer.trailingAnchor, constant: 0),
            addMemberButton.bottomAnchor.constraint(equalTo: membersContainer.bottomAnchor, constant: 0),
            addMemberButton.heightAnchor.constraint(equalToConstant: 55),
            
            addMemberImage.leadingAnchor.constraint(equalTo: addMemberButton.leadingAnchor, constant: 20),
            addMemberImage.centerYAnchor.constraint(equalTo: addMemberButton.centerYAnchor),
            addMemberImage.widthAnchor.constraint(equalToConstant: 25),
            addMemberImage.heightAnchor.constraint(equalToConstant: 25),
            
            addMembersLabel.leadingAnchor.constraint(equalTo: addMemberButton.leadingAnchor, constant: 10),
            addMembersLabel.trailingAnchor.constraint(equalTo: addMemberButton.trailingAnchor, constant: -10),
            addMembersLabel.centerYAnchor.constraint(equalTo: addMemberButton.centerYAnchor),
            addMembersLabel.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        addMemberButton.backgroundColor = .clear
        addMemberButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        
        addMemberImage.tintColor = .black
        addMemberImage.isUserInteractionEnabled = false
        
        addMembersLabel.textColor = .black
        addMembersLabel.textAlignment = .center
        addMembersLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        addMembersLabel.isUserInteractionEnabled = false
    }
    
    
    //MARK: - Configure Collection View
    
    private func configureCollectionView () {
        
        membersContainer.addSubview(membersCollectionView)
        membersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            membersCollectionView.topAnchor.constraint(equalTo: membersContainer.topAnchor, constant: 10),
            membersCollectionView.leadingAnchor.constraint(equalTo: membersContainer.leadingAnchor, constant: 0),
            membersCollectionView.trailingAnchor.constraint(equalTo: membersContainer.trailingAnchor, constant: 0),
            membersCollectionView.heightAnchor.constraint(equalToConstant: members?.count ?? 0 > 0 ? 110 : 0)
        
        ].forEach({ $0.isActive = true })
        
        membersCollectionView.dataSource = self
        membersCollectionView.delegate = self
        
        membersCollectionView.backgroundColor = .white
        
        membersCollectionView.showsHorizontalScrollIndicator = false
        membersCollectionView.delaysContentTouches = false
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 95, height: 110)
        layout.minimumInteritemSpacing = 15
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        
        membersCollectionView.collectionViewLayout = layout
        
        membersCollectionView.register(MemberConfigurationCollectionViewCell.self, forCellWithReuseIdentifier: "memberConfigurationCollectionViewCell")
    }
    
    
    //MARK: - Reconfiguration Functions
    
    private func reconfigureCell() {
        
        if members?.count ?? 0 == (collab?.members.count ?? 0) - 1 {
            
            configureFullMembersCell()
        }
        
        else if members?.count ?? 0 > 0 {
            
            configurePartialMembersCell()
        }
        
        else {
            
            configureNoMembersCell()
        }
    }
    
    private func configureNoMembersCell () {
        
        membersCollectionView.alpha = 0
        
        //Resetting the constraints of the addMembersButton
        membersContainer.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .leading && constraint.firstItem as? UIButton != nil {
                
                constraint.constant = 0
            }
            
            else if constraint.firstAttribute == .trailing && constraint.firstItem as? UIButton != nil {
                
                constraint.constant = 0
            }
            
            else if constraint.firstAttribute == .bottom && constraint.firstItem as? UIButton != nil {
                
                constraint.constant = 0
            }
        }
        
        addMemberButton.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = 55
            }
        }
        ////////////////////////////////////////////////////////////////////////
        
        self.addMemberButton.backgroundColor = .clear
        
        UIView.transition(with: membersContainer, duration: 0.3, options: .transitionCrossDissolve) {
            
            self.membersCountLabel.alpha = 0

            self.addMemberButton.alpha = 1
            
            self.addMemberImage.tintColor = .black
            self.addMemberImage.isUserInteractionEnabled = false

            self.addMembersLabel.isUserInteractionEnabled = false
            self.addMembersLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
            self.addMembersLabel.textColor = .black
            self.addMembersLabel.textAlignment = .center
            
            self.addMembersLabel.text = self.memberConfigurationDelegate as? ConfigureBlockViewController != nil ? "Assign Members" : "Add Members"
        }
    }
    
    private func configurePartialMembersCell () {
        
        membersCountLabel.text = "\(members?.count ?? 0)/\((collab?.members.count ?? 6) - 1)"
        
        //Resetting the constraints of the addMembersButton
        membersContainer.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .leading && constraint.firstItem as? UIButton != nil {
                
                constraint.constant = 32.5
            }
            
            else if constraint.firstAttribute == .trailing && constraint.firstItem as? UIButton != nil {
                
                constraint.constant = -32.5
            }
            
            else if constraint.firstAttribute == .bottom && constraint.firstItem as? UIButton != nil {
                
                constraint.constant = -12.5
            }
        }
        
        addMemberButton.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = 40
            }
        }
        
        addMemberButton.backgroundColor = UIColor(hexString: "222222")
        addMemberButton.layer.cornerRadius = 20
        addMemberButton.clipsToBounds = true
        addMemberButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        
        addMemberImage.tintColor = .white
        addMemberImage.isUserInteractionEnabled = false
        
        addMembersLabel.isUserInteractionEnabled = false
        addMembersLabel.font = UIFont(name: "Poppins-SemiBold", size: 14)
        addMembersLabel.textColor = .white
        addMembersLabel.textAlignment = .center
        
        addMembersLabel.text = self.memberConfigurationDelegate as? ConfigureBlockViewController != nil ? "Assign" : "Add"
        
        //Resetting the height of the membersCollectionView
        membersCollectionView.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = 110
            }
        }
        
        membersCollectionView.reloadData()
        
        UIView.transition(with: membersContainer, duration: 0.3, options: .transitionCrossDissolve) {
            
            self.membersCountLabel.alpha = 1
            self.membersCollectionView.alpha = 1
            self.addMemberButton.alpha = 1
        }
    }
    
    private func configureFullMembersCell () {
        
        //Resetting the height of the membersCollectionView
        membersCollectionView.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = 110
            }
        }
        
        self.membersCollectionView.reloadData()
        
        UIView.transition(with: membersContainer, duration: 0.3, options: .transitionCrossDissolve) {
            
            self.membersCountLabel.text = "\(self.members?.count ?? 0)/\((self.collab?.members.count ?? 6) - 1)"
            
            self.membersCollectionView.alpha = 1
            
            self.addMemberButton.alpha = 0
        }
    }
    
    
    //MARK: - Add Button Pressed
    
    @objc private func addButtonPressed () {
        
        memberConfigurationDelegate?.moveToAddMemberView()
    }
}

//MARK: - CollectionView Extension
extension MemberConfigurationCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return members?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memberConfigurationCollectionViewCell", for: indexPath) as! MemberConfigurationCollectionViewCell
        
        cell.member = members?[indexPath.row]
        
        cell.memberConfigurationDelegate = memberConfigurationDelegate
        
        return cell
    }
}
