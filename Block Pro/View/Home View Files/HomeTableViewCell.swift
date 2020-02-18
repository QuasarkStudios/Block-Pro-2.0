//
//  HomeTableViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/31/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol TimeBlockView {
    
    func performSegue ()
}

class HomeTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var personalCollectionView: UICollectionView!
    
    let formatter = DateFormatter()
    
    var personalCollectionContent: [Date]! {
        didSet {

            personalCollectionView.reloadData()
        }
    }
    
    var visibleItem: IndexPath?
    
    var homeViewController: HomeViewController?
    
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
        
        if personalCollectionContent.count < 3 {
            
            return personalCollectionContent.count
        }
        
        else {
            
            return personalCollectionContent.count + 1
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row < personalCollectionContent.count {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "personalCell", for: indexPath) as! PersonalCell
            cell.isHidden = false
            
            formatter.dateFormat = "EEEE"
            cell.dayLabel.text = formatter.string(from: personalCollectionContent[indexPath.row])//calendar.weekdaySymbols[indexPath.row]

            formatter.dateFormat = "MMMM d, yyyy"
            cell.dateLabel.text = formatter.string(from: personalCollectionContent[indexPath.row])
            
            return cell
        }
        
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "personalCell", for: indexPath) as! PersonalCell
            cell.isHidden = true
            
//            formatter.dateFormat = "EEEE"
//            cell.dayLabel.text = formatter.string(from: personalCollectionContent[indexPath.row])//calendar.weekdaySymbols[indexPath.row]
//
//            formatter.dateFormat = "MMMM d, yyyy"
//            cell.dateLabel.text = formatter.string(from: personalCollectionContent[indexPath.row])
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let leftInset: CGFloat = (UIScreen.main.bounds.width - 5) / 4
        
        return UIEdgeInsets(top: 10, left: leftInset, bottom: 10, right: 0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //scrollView.
        
        if scrollView.contentOffset.x > 1300 {

            scrollView.setContentOffset(CGPoint(x: 1265, y: 0), animated: true)
            
            //scrollView.contentOffset.x = 1265
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        shrinkPersonalCell()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if decelerate == false {
            
            scrollToMostVisibleItem()
        }
        
        else {
            
//            if scrollView.contentOffset.x > 1265 {
//
//                UIView.animate(withDuration: 0.2) {
//                    self.personalCollectionView.contentOffset.x = 1265
//                }
//            }
            

        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        scrollToMostVisibleItem()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        homeViewController!.moveToTimeBlockView(selectedDate: personalCollectionContent[indexPath.row])
        
        
        print("check")
    }
    
    private func scrollToMostVisibleItem () {
        
        assignVisibleCell {
            self.growPersonalCell()
            //print(self.personalCollectionView.contentOffset)
        }
    }
    
    func assignVisibleCell (completion: @escaping () -> ()) {
        
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
        
        if centeredItems.count != 0 {
            
            var indexPath: IndexPath = IndexPath(item: centeredItems[0].last!, section: 0)
            
            if indexPath.row < personalCollectionContent.count {
                
                personalCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                visibleItem = indexPath
            }
            
            else {
                
                //print(personalCollectionView.contentOffset)
                
                indexPath = IndexPath(item: indexPath.row - 1, section: 0)
                personalCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                visibleItem = indexPath
            }
            

        }

        completion()
    }
    
    func growPersonalCell (delay: Double = 0) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            
            if self.visibleItem ?? nil != nil {
                
                guard let cell = self.personalCollectionView.cellForItem(at: self.visibleItem!) as? PersonalCell else { return }
                    
                    cell.cellBackgroundTopAnchor.constant = 5
                    cell.cellBackgroundBottomAnchor.constant = 5
                    cell.cellBackgroundLeadingAnchor.constant = 5
                    cell.cellBackgroundTrailingAnchor.constant = 5
                    
                    cell.detailsButtonTopAnchor.constant = 0
                    cell.shareButtonTopAnchor.constant = 0
                    cell.deleteButtonTopAnchor.constant = 0
                    
                    UIView.animate(withDuration: 0.3) {
                        
                        cell.layoutIfNeeded()
                        
                        cell.blurView.alpha = 0.2
                        
                        cell.detailsButton.alpha = 1
                        cell.shareButton.alpha = 1
                        cell.deleteButton.alpha = 1
                    
                    }
                }
            }
            

    }
    
    func shrinkPersonalCell () {
        
        if visibleItem ?? nil != nil {
            
            guard let cell = personalCollectionView.cellForItem(at: self.visibleItem!) as? PersonalCell  else { return }
            
            //let cell = personalCollectionView.cellForItem(at: self.visibleItem!) as! PersonalCell
            
            cell.cellBackgroundTopAnchor.constant = 15
            cell.cellBackgroundBottomAnchor.constant = 75
            cell.cellBackgroundLeadingAnchor.constant = 15
            cell.cellBackgroundTrailingAnchor.constant = 15
        
            cell.detailsButtonTopAnchor.constant = -50
            cell.shareButtonTopAnchor.constant = -50
            cell.deleteButtonTopAnchor.constant = -50
            
            UIView.animate(withDuration: 0.3) {
                
                cell.layoutIfNeeded()
                
                cell.blurView.alpha = 1
                
                cell.detailsButton.alpha = 0
                cell.shareButton.alpha = 0
                cell.deleteButton.alpha = 0
            }
        }
    }
}

