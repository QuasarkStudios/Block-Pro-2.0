//
//  SelectedBlockMembersCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/23/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class SelectedBlockMembersCell: UITableViewCell {

    let assignedLabel = UILabel()
    let membersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    var block: Block? {
        didSet {
            
            setAssignedLabel()
            membersCollectionView.reloadData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "selectedBlockMembersCell")
        
        self.clipsToBounds = true
        
        configureAssignedLabel()
        configureMembersCollectionView(membersCollectionView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAssignedLabel () {
        
        self.contentView.addSubview(assignedLabel)
        assignedLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            assignedLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 30),
            assignedLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -30),
            assignedLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            assignedLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        assignedLabel.textColor = .black
        assignedLabel.textAlignment = .left
    }
    
    private func configureMembersCollectionView (_ collectionView: UICollectionView) {
        
        self.contentView.addSubview(membersCollectionView)
        membersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            membersCollectionView.topAnchor.constraint(equalTo: assignedLabel.bottomAnchor, constant: 10),
            membersCollectionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            membersCollectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            membersCollectionView.heightAnchor.constraint(equalToConstant: 110)
        
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
        layout.sectionInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        layout.scrollDirection = .horizontal
        
        membersCollectionView.collectionViewLayout = layout
        
        membersCollectionView.register(MemberConfigurationCollectionViewCell.self, forCellWithReuseIdentifier: "memberConfigurationCollectionViewCell")
    }
    
    private func setAssignedLabel () {
        
        if block?.members?.count ?? 0 > 0 {
            
            assignedLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
            assignedLabel.text = "Assigned"
        }
        
        else {
            
            assignedLabel.font = UIFont(name: "Poppins-SemiBold", size: 16.5)
            assignedLabel.text = "No Members Yet"
        }
    }
}

extension SelectedBlockMembersCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return block?.members?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memberConfigurationCollectionViewCell", for: indexPath) as! MemberConfigurationCollectionViewCell
        
        cell.showCancelButton = false
        
        cell.member = block?.members?[indexPath.row]
        
        return cell
    }
}
