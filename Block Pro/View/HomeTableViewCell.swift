//
//  HomeTableViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/31/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var cellBackground: UIView!
    
    @IBOutlet weak var personalCollectionView: UICollectionView!
    @IBOutlet weak var collabCollectionView: UICollectionView!
    
    let formatter = DateFormatter()
    
    var personalCollectionContent: [String]! {
        didSet {
            
            personalCollectionView.reloadData()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        personalCollectionView.delegate = self
        personalCollectionView.dataSource = self
        
        collabCollectionView.delegate = self
        collabCollectionView.dataSource = self
        
        cellBackground.layer.cornerRadius = 19
        cellBackground.clipsToBounds = true
        
        cellBackground.layer.masksToBounds = false
        cellBackground.layer.shadowColor = UIColor(hexString: "4E697B")?.cgColor
        cellBackground.layer.shadowOpacity = 0.5
        cellBackground.layer.shadowOffset = CGSize(width: 1, height: 2)
        cellBackground.layer.shadowRadius = 8
        
        personalCollectionView.register(UINib(nibName: "PersonalCell", bundle: nil), forCellWithReuseIdentifier: "personalCell")
        collabCollectionView.register(UINib(nibName: "PersonalCell", bundle: nil), forCellWithReuseIdentifier: "personalCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: 130, height: 120)
        
        layout.minimumInteritemSpacing = 15
        layout.minimumLineSpacing = 15
        
        layout.scrollDirection = .horizontal
        
        personalCollectionView.collectionViewLayout = layout
        collabCollectionView.collectionViewLayout = layout
        
        personalCollectionView.showsHorizontalScrollIndicator = false
        collabCollectionView.showsHorizontalScrollIndicator = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == personalCollectionView {
            
            print("check1")
            return personalCollectionContent.count
        }
        
        else {
            
            print("check2")
            return 0
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "personalCell", for: indexPath) as! PersonalCell
        
        cell.layer.cornerRadius = 25
        cell.clipsToBounds = true
        
        let date = Date()
        let calendar = Calendar.current
        
        cell.dayLabel.text = calendar.weekdaySymbols[indexPath.row]
        
        
        formatter.dateFormat = "d"
        
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("check")
        
    }
    
}
