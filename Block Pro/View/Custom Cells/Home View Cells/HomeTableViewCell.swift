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
    
    @IBOutlet weak var weekLabel: UILabel!
    
    @IBOutlet weak var personalCollectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var homeViewController: HomeViewController?; #warning("change to a protocol lol")
    
    let formatter = DateFormatter()
    
    var personalCollectionContent: [Date]! {
        didSet {
            
            configureWeekLabel()
            
            pageControl.numberOfPages = personalCollectionContent.count
            
            personalCollectionView.reloadData()
        }
    }
    
    var visibleItem: IndexPath?
    
    var pageWidth: CGFloat?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        personalCollectionView.delegate = self
        personalCollectionView.dataSource = self
        
        let layout = PersonalCollectionViewFlowLayout()
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
            
            formatter.dateFormat = "EEEE, MMMM d"
            cell.dayLabel.text = formatter.string(from: personalCollectionContent[indexPath.row])//calendar.weekdaySymbols[indexPath.row]
            
            cell.currentDate = personalCollectionContent[indexPath.row]
            
            return cell
        }
        
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "personalCell", for: indexPath) as! PersonalCell
            cell.isHidden = true
            
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let leftInset: CGFloat = (UIScreen.main.bounds.width - 5) / 4
        
        return UIEdgeInsets(top: -40, left: leftInset, bottom: 0, right: 0)
    }


    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.x > 1335 {

            scrollView.setContentOffset(CGPoint(x: 1335, y: 0), animated: false)
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

                    UIView.animate(withDuration: 0.3) {

                        cell.layoutIfNeeded()
                    }
                
                    cell.detailsButtonTopAnchor.constant = 320
                    cell.detailsButtonCenterXAnchor.constant = -50
                
                    cell.deleteButtonTopAnchor.constant = 320
                    cell.deleteButtonCenterXAnchor.constant = 50
                
                    UIView.animate(withDuration: 0.4) {
                        
                        cell.layoutIfNeeded()

                        cell.detailsButton.alpha = 1
                        cell.shareButton.alpha = 1
                        cell.deleteButton.alpha = 1
                    }
                
                
                    self.pageControl.currentPage = self.visibleItem!.row
                }
            }
            

    }
    
    
    func shrinkPersonalCell () {
        
        if visibleItem ?? nil != nil {

            guard let cell = personalCollectionView.cellForItem(at: self.visibleItem!) as? PersonalCell  else { return }

            cell.detailsButtonTopAnchor.constant = 270
            cell.detailsButtonCenterXAnchor.constant = 0
            
            cell.deleteButtonTopAnchor.constant = 270
            cell.deleteButtonCenterXAnchor.constant = 0
            
            UIView.animate(withDuration: 0.2) {
                
                cell.layoutIfNeeded()

                cell.detailsButton.alpha = 0
                cell.shareButton.alpha = 0
                cell.deleteButton.alpha = 0
            }

            cell.cellBackgroundTopAnchor.constant = 30
            cell.cellBackgroundBottomAnchor.constant = 75
            cell.cellBackgroundLeadingAnchor.constant = 15
            cell.cellBackgroundTrailingAnchor.constant = 15


            UIView.animate(withDuration: 0.3) {
                
                cell.layoutIfNeeded()
            }
        }
    }
    
    
    func configureWeekLabel () {
        
        formatter.dateFormat = "MMMM d"
        
        if personalCollectionContent.count == 1 {
            
            
            weekLabel.text = formatter.string(from: personalCollectionContent.first!)
        }
        
        else {
            
            weekLabel.text = formatter.string(from: personalCollectionContent.first!) + "  -  " + formatter.string(from: personalCollectionContent.last!)
        }
    }
    
    
    @IBAction func pageControl(_ sender: Any) {
        
        pageControl.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            
            self.pageControl.isUserInteractionEnabled = true
        }
        
        let indexPath: IndexPath = IndexPath(item: pageControl.currentPage, section: 0)
        
        personalCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        guard visibleItem != nil else { return }

            shrinkPersonalCell()

            visibleItem = indexPath

            growPersonalCell()
    }
}
