//
//  iProgressView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/25/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import iProgressHUD

class iProgressView: UIView {

    var iProgress: iProgressHUD = iProgressHUD()
    var iProgressAttached: Bool = false
    
    weak var parentView: AnyObject?
    
    init (_ parentView: AnyObject, isShowModal: Bool = false, isShowCaption: Bool = false, isTouchDismiss: Bool = false, boxColor: UIColor = .clear, _ indicatorSize: CGFloat, _ indicatorStyle: NVActivityIndicatorType) {
        super.init(frame: .zero)
        
        self.backgroundColor = .clear
        
        self.parentView = parentView
        
        iProgress.isShowModal = isShowModal
        iProgress.isShowCaption = isShowCaption
        iProgress.isTouchDismiss = isTouchDismiss
        iProgress.boxColor = boxColor
        
        iProgress.indicatorSize = indicatorSize
        iProgress.indicatorStyle = indicatorStyle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !iProgressAttached {
            
            configureIProgressHUD()
            
            iProgressAttached = true
        }
    }
    
    private func configureIProgressHUD () {
        
        iProgress.attachProgress(toView: self)
        
        if let view = parentView as? PhotosPresentationCollectionViewCell, view.showProgress {
            
            self.showProgress()
        }
    }
}
