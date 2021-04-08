//
//  CollabCollectionViewFlowLayout.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/12/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import Foundation

class CollabCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var pageHeight: CGFloat {
        
        return self.itemSize.height + self.minimumLineSpacing
    }
    
    let flickVelocity: CGFloat = 0.3
    
    weak var homeViewController: AnyObject?
    
    init (_ parentViewController: AnyObject) {
        super.init()
        
        self.homeViewController = parentViewController
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        
        self.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 100/*110*/)
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 20
        self.scrollDirection = .vertical
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        var contentOffset: CGPoint = CGPoint(x: 0.0, y: 0.0)
        
        let rawPageValue = self.collectionView!.contentOffset.y / pageHeight
        let currentPage = (velocity.y > 0.0) ? floor(rawPageValue) : ceil(rawPageValue)
        let nextPage = (velocity.y > 0.0) ? ceil(rawPageValue) : floor(rawPageValue)
        
        let pannedLessThanAPage: Bool = abs(1 + currentPage - rawPageValue) > 0.5
        let flicked: Bool = abs(velocity.y) > flickVelocity
        
        if pannedLessThanAPage && flicked {
            
            contentOffset.y = nextPage * pageHeight
        }
        
        else {
            
            contentOffset.y = round(rawPageValue) * pageHeight
        }
        
        if let viewController = homeViewController as? HomeViewController {
            
            viewController.yCoordForExpandedCell = contentOffset.y >= 0 ? contentOffset.y : 0
        }
        
        return contentOffset
    }
}
