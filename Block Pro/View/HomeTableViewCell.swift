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
        
        let dx: CGFloat = 50
 //       let rect = CGRect(x: cellBackground.bounds.minX, y: cellBackground.bounds.minY, width: cellBackground.bounds.width + 5, height: cellBackground.bounds.height)
        
        //print(cellBackground.bounds)
        
        let shadowLayer: CAShapeLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 19).cgPath
        shadowLayer.fillColor = UIColor.white.cgColor

        shadowLayer.shadowColor = UIColor(hexString: "444F57")?.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 1, height: 2)
        shadowLayer.shadowOpacity = 0.5
        shadowLayer.shadowRadius = 3

    //    cellBackground.layer.insertSublayer(shadowLayer, at: 0)
        
   //     cellBackground.layer.cornerRadius = 19
   //     cellBackground.clipsToBounds = true
        
  //      cellBackground.backgroundColor = .clear
        
       // cellBackground.layer.masksToBounds = false
        
        personalCollectionView.delegate = self
        personalCollectionView.dataSource = self

        let layout = UICollectionViewFlowLayout()
        //layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 195, height: 430)
        
        layout.minimumInteritemSpacing = 15
        layout.minimumLineSpacing = 15
        
        layout.scrollDirection = .horizontal
        
        personalCollectionView.collectionViewLayout = layout
        
        personalCollectionView.showsHorizontalScrollIndicator = false
        
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
        
        //cell.backgroundColor = .green
        
//        cell.layer.cornerRadius = 20
//        cell.clipsToBounds = true

        formatter.dateFormat = "EEEE"
        cell.dayLabel.text = formatter.string(from: personalCollectionContent[indexPath.row])//calendar.weekdaySymbols[indexPath.row]

        formatter.dateFormat = "MMMM d, yyyy"
        cell.dateLabel.text = formatter.string(from: personalCollectionContent[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if personalCollectionContent.count == 1 {
            
            let leftInset: CGFloat = (UIScreen.main.bounds.width - 5) / 4
            
            //print(leftInset)
            
            return UIEdgeInsets(top: 10, left: leftInset, bottom: 10, right: 0)
        }
        
        else {
            
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("check")
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

