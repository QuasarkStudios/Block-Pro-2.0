//
//  PersonalCollectionView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/20/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class PersonalCollectionViewFlowLayout: UICollectionViewFlowLayout{
    
    var pageWidth: CGFloat {
        
        return self.itemSize.width + self.minimumLineSpacing
    }
    
    override func prepare() {
        super.prepare()
        
        self.itemSize = CGSize(width: 205, height: (collectionView?.frame.height)!)
        self.minimumInteritemSpacing = 15
        self.minimumLineSpacing = 15
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
            
            contentOffset.x = nextPage * pageWidth
       }
        
        else {

            contentOffset.x = round(rawPageValue) * pageWidth
        }
        
        return contentOffset
    }
}
