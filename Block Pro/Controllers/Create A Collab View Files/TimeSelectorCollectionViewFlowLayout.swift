//
//  TimeSelectorCollectionViewFlowLayout.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/16/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

class TimeSelectorCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var pageWidth: CGFloat {
        
        return self.itemSize.width + self.minimumLineSpacing
    }
    
    override func prepare() {
        super.prepare()
        
        self.itemSize = CGSize(width: 4, height: 50)
        self.minimumLineSpacing = 8
        self.minimumInteritemSpacing = 5
        self.scrollDirection = .horizontal
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        var contentOffset: CGPoint = CGPoint(x: 0, y: 0)
        
        let flickVelocity: CGFloat = 0.3
        
        let rawPageValue = (collectionView?.contentOffset.x)! / pageWidth
        let currentPage = (velocity.x > 0.0) ? floor(rawPageValue) : ceil(rawPageValue)
        let nextPage = (velocity.x > 0.0) ? ceil(rawPageValue) : floor(rawPageValue)
        
        let pannedLessThanAPage: Bool = abs(1 + currentPage - rawPageValue) > 0.5
        let flicked: Bool = abs(velocity.x) > flickVelocity
        
        if pannedLessThanAPage && flicked {
            
            contentOffset.x = (nextPage * pageWidth) + adjustContentOffset()
        }
        
        else {
            
            contentOffset.x = (round(rawPageValue) * pageWidth) + adjustContentOffset()
        }
        
        return contentOffset
    }
    
    private func minMaxContentOffset () {
        
        
    }
    
    private func adjustContentOffset () -> CGFloat {
        
        //iPhone 11 Pro Max, iPhone 11, and iPhone 8 Plus
        if UIScreen.main.bounds.width == 414.0 {

            return 2
        }

        //iPhone 11 Pro and iPhone 8
        else if UIScreen.main.bounds.width == 375.0 {

            return -3
        }

        //iPhone SE
        else {

            return 1
        }
    }
}
