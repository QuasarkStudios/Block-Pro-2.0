//
//  HomeTableViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/31/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var personalCollectionView: UICollectionView!
    
    let formatter = DateFormatter()
    
    var personalCollectionContent: [Date]! {
        didSet {

            personalCollectionView.reloadData()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        personalCollectionView.delegate = self
        personalCollectionView.dataSource = self

        let layout = UICollectionViewFlowLayout()
        //layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 195, height: 430)
        
        layout.minimumInteritemSpacing = 15
        layout.minimumLineSpacing = 15
        
        layout.scrollDirection = .horizontal
        
        personalCollectionView.collectionViewLayout = layout
        
        personalCollectionView.register(UINib(nibName: "PersonalCell", bundle: nil), forCellWithReuseIdentifier: "personalCell")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return personalCollectionContent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "personalCell", for: indexPath) as! PersonalCell

        formatter.dateFormat = "EEEE"
        cell.dayLabel.text = formatter.string(from: personalCollectionContent[indexPath.row])//calendar.weekdaySymbols[indexPath.row]

        formatter.dateFormat = "MMMM d, yyyy"
        cell.dateLabel.text = formatter.string(from: personalCollectionContent[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let leftInset: CGFloat = (UIScreen.main.bounds.width - 5) / 4
        
        return UIEdgeInsets(top: 10, left: leftInset, bottom: 10, right: 0)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if decelerate == false {
            
            scrollToMostVisibleItem()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        scrollToMostVisibleItem()
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("check")
    }
    
    private func scrollToMostVisibleItem () {
        
        let visibleItems: [IndexPath] = personalCollectionView.indexPathsForVisibleItems
        let centeredRect: CGRect = CGRect(x: personalCollectionView.center.x - 10, y: 0, width: 20, height: personalCollectionView.frame.height)
        var centeredItems: [IndexPath] = []
        
        var count = 0
        
        for cell in personalCollectionView.visibleCells {
            
            let cellFrame: CGRect = CGRect(x: cell.frame.minX - personalCollectionView.contentOffset.x, y: cell.frame.minY, width: cell.frame.width, height: cell.frame.height)
            
            if cellFrame.intersects(centeredRect) {
                
                centeredItems.append(visibleItems[count])
            }
            
            count += 1
        }
        
        let indexPath: IndexPath = IndexPath(item: centeredItems[0].last!, section: 0)
        personalCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
    }
}



extension CALayer {
    
    func applyShadow (color: UIColor, alpha: Float = 0.5, x: CGFloat, y: CGFloat, blur: CGFloat, spread: CGFloat, bounds: CGRect) {
        
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        
        if spread == 0 {
            
            shadowPath = nil
        }
        
        else {
          
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}

