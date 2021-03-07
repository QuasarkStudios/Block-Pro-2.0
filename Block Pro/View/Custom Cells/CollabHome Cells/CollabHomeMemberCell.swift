//
//  CollabHomeMembersCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/21/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class CollabHomeMembersCell: UITableViewCell {

    let membersLabel = UILabel()
    let membersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    let membersPageControl = UIPageControl()
    
    let currentUser = CurrentUser.sharedInstance
    
    var collab: Collab? {
        didSet {
            
            configureMembersPageControl()
        }
    }
    
    var blocks: [Block]? {
        didSet {
            
            membersCollectionView.reloadData()
        }
    }
    
    weak var collabMemberDelegate: CollabMemberProtocol?
    
    override init (style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "collabHomeMembersCell")
        
        configureMembersLabel()
        configureCollectionView(membersCollectionView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configure Members Label
    
    private func configureMembersLabel () {
        
        self.contentView.addSubview(membersLabel)
        membersLabel.configureTitleLabelConstraints()
        
        membersLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
        membersLabel.textColor = .black
        membersLabel.textAlignment = .left
        membersLabel.text = "Members"
    }
    
    
    //MARK: - Configure Collection View
    
    private func configureCollectionView (_ collectionView: UICollectionView) {
        
        self.contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collectionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            collectionView.topAnchor.constraint(equalTo: membersLabel.bottomAnchor, constant: 7.5),
            collectionView.heightAnchor.constraint(equalToConstant: 110)
        
        ].forEach({ $0.isActive = true })
        
        membersCollectionView.dataSource = self
        membersCollectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
        layout.sectionInset = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        collectionView.backgroundColor = .clear
        collectionView.collectionViewLayout = layout
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        
        collectionView.register(CollabHomeMembersCollectionViewCell.self, forCellWithReuseIdentifier: "collabHomeMembersCollectionViewCell")
    }
    
    
    //MARK: - Configure Members Page Control
    
    private func configureMembersPageControl () {
        
        if let members = collab?.currentMembers, members.count > 1 {
            
            if membersPageControl.superview == nil {
                
                self.contentView.addSubview(membersPageControl)
            }
            
            membersPageControl.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                membersPageControl.topAnchor.constraint(equalTo: membersCollectionView.bottomAnchor, constant: -5),
                membersPageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                membersPageControl.widthAnchor.constraint(equalToConstant: 400),
                membersPageControl.heightAnchor.constraint(equalToConstant: 27.5)
            
            ].forEach({ $0.isActive = true })
            
            membersPageControl.numberOfPages = members.count - 1
            membersPageControl.pageIndicatorTintColor = UIColor(hexString: "D8D8D8")
            membersPageControl.currentPageIndicatorTintColor = UIColor(hexString: "222222")
            
            membersPageControl.addTarget(self, action: #selector(pageSelected), for: .valueChanged)
        }
        
        else {
            
            membersPageControl.removeFromSuperview()
        }
    }
    
    
    //MARK: - Page Selected
    
    @objc private func pageSelected () {
        
        membersCollectionView.scrollToItem(at: IndexPath(item: membersPageControl.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
}


//MARK: - CollectionView Extension

extension CollabHomeMembersCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let members = collab?.currentMembers {
            
            return members.count > 1 ? members.count - 1 : 1
        }
        
        else {
            
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collabHomeMembersCollectionViewCell", for: indexPath) as! CollabHomeMembersCollectionViewCell
        
        if let members = collab?.currentMembers {
            
            if members.count > 1 {
                
                var filteredMembers = members
                filteredMembers.removeAll(where: { $0.userID == currentUser.userID })
                
                cell.member = filteredMembers[indexPath.row]
                cell.memberActivity = collab?.memberActivity?[filteredMembers[indexPath.row].userID]
            }
            
            else {
                
                cell.member = members[indexPath.row]
                cell.memberActivity = collab?.memberActivity?[members[indexPath.row].userID]
            }
        }
        
        cell.blocks = blocks
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        membersPageControl.currentPage = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //Backup check in case the paging of collectionView wasn't completed and the collectionView returned to the index it was at before it was scrolled
        membersPageControl.currentPage = collectionView.indexPathsForVisibleItems.first?.row ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = membersCollectionView.cellForItem(at: indexPath) as? CollabHomeMembersCollectionViewCell, let member = cell.member {
            
            collabMemberDelegate?.moveToProfileView(member, cell.containerView)
            
            cell.profilePic.layer.shadowColor = UIColor.clear.cgColor
            cell.profilePic.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //Doing this ensures that the progressCircle gets set to it's correct position; wasn't before
        for indexPath in membersCollectionView.indexPathsForVisibleItems {
            
            if let cell = membersCollectionView.cellForItem(at: indexPath) as? CollabHomeMembersCollectionViewCell {
                
                cell.blocks = blocks
            }
        }
    }
}
