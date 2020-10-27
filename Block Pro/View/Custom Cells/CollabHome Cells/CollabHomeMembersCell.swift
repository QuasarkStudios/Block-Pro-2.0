//
//  CollabHomeMembersCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/11/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class CollabHomeMembersCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var membersCollectionView: UICollectionView!
    
    var collab: Collab?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureCollectionView(membersCollectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return collab?.members.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collabMemberCollectionViewCell", for: indexPath) as! CollabMemberCollectionViewCell
        
        if collab != nil {
            
            cell.member = collab!.members[indexPath.row]
            cell.memberActivity = collab!.memberActivity?[collab!.members[indexPath.row].userID]
        }
        
        return cell
    }

    private func configureCollectionView (_ collectionView: UICollectionView) {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 170)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.scrollDirection = .horizontal
        
        collectionView.collectionViewLayout = layout
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.register(UINib(nibName: "CollabMemberCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "collabMemberCollectionViewCell")
    }
    
}
