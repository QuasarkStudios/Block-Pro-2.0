//
//  CollabCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/8/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class HomeCollabTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collabCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collabCollectionView.dataSource = self
        collabCollectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.frame.width, height: 215)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        
        collabCollectionView.collectionViewLayout = layout
        
        collabCollectionView.register(UINib(nibName: "CollabCell", bundle: nil), forCellWithReuseIdentifier: "collabCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collabCell", for: indexPath)
        
        return cell
    }
}
