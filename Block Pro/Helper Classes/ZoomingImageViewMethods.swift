//
//  ZoomingImageViewMethods.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/6/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class ZoomingImageViewMethods {
    
    var zoomedOutImageView: UIImageView?
    var zoomedOutImageViewFrame: CGRect?
    var zoomedOutImageViewCornerRadius: CGFloat?
    
    var blackBackground: UIView?
    var zoomedInImageView: UIImageView?
    var zoomedInImageViewFrame: CGRect?
    
    var optionalButtons: [UIButton?] = []
    
    var zoomOutCompletion: (() -> Void)
    
    var panGesture: UIPanGestureRecognizer?
    
    init (on imageView: UIImageView, cornerRadius: CGFloat, with buttons: [UIButton?] = [], completion: @escaping (() -> Void) = {}) {
        
        self.zoomedOutImageView = imageView
        self.zoomedOutImageViewCornerRadius = cornerRadius
        
        self.optionalButtons = buttons
        
        self.zoomOutCompletion = completion
    }
    
    func performZoom () {
        
        blackBackground = UIView(frame: UIScreen.main.bounds)
        blackBackground?.backgroundColor = .clear
        
        blackBackground?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOutOnImageView)))
        
        UIApplication.shared.keyWindow?.addSubview(blackBackground!)
        
        optionalButtons.forEach { (button) in
            
            if button != nil {
                
                UIApplication.shared.keyWindow?.addSubview(button!)
            }
        }
        
        if let imageView = zoomedOutImageView, let startingFrame = imageView.superview?.convert(imageView.frame, to: blackBackground!) {
            
            zoomedOutImageViewFrame = startingFrame
            
            let zoomingImageView = UIImageView(frame: zoomedOutImageViewFrame!)
            zoomingImageView.contentMode = .scaleAspectFill
            zoomingImageView.image = imageView.image
            zoomingImageView.layer.cornerRadius = zoomedOutImageViewCornerRadius ?? 0
            zoomingImageView.clipsToBounds = true
            
            zoomingImageView.isUserInteractionEnabled = true
            zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOutOnImageView)))
            
            UIApplication.shared.keyWindow?.addSubview(zoomingImageView)
            zoomedInImageView = zoomingImageView
            
            imageView.isHidden = true
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .black
                self.optionalButtons.forEach({ $0?.alpha = 1 })
                
                let height = (startingFrame.height / startingFrame.width) * UIScreen.main.bounds.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
                zoomingImageView.center = self.blackBackground!.center
                
                zoomingImageView.layer.cornerRadius = 0
                
            }) { (finished: Bool) in
                
                self.zoomedInImageViewFrame = self.zoomedInImageView?.frame
                
                self.addImageViewPanGesture(view: self.zoomedInImageView)
                self.addImageViewPanGesture(view: self.blackBackground)
            }
        }
    }
    
    private func addImageViewPanGesture (view: UIView?) {
        
        if view != nil {
            
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleImageViewPan(sender:)))
            
            view?.addGestureRecognizer(panGesture!)
        }
    }
    
    @objc private func handleImageViewPan (sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .began, .changed:
            
            moveImageViewWithPan(sender: sender)
            
        case .ended:
            
            if (zoomedInImageView?.frame.minY ?? 0 > (UIScreen.main.bounds.height / 2)) {
                
                handleZoomOutOnImageView()
            }
            
            else if (zoomedInImageView?.frame.maxY ?? 0 < (UIScreen.main.bounds.height / 2)) {
                
                handleZoomOutOnImageView()
            }
            
            else {
                
                returnImageViewToOrigin()
            }
            
        default:
            break
        }
    }
    
    private func moveImageViewWithPan (sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: zoomedOutImageView?.superview)
        
        if let imageView = zoomedInImageView {

            let translatedMinYCoord = imageView.frame.minY + translation.y
            let translatedMinXCoord = imageView.frame.minX + translation.x
            let translatedMaxYCoord = imageView.frame.maxY + translation.y
            
            imageView.frame = CGRect(x: translatedMinXCoord, y: translatedMinYCoord, width: imageView.frame.width, height: imageView.frame.height)
            
            if let backgroundView = blackBackground, let zoomedInMinYCoord =  zoomedInImageViewFrame?.minY, let zoomedInMaxYCoord = zoomedInImageViewFrame?.maxY {
                    
                if translatedMinYCoord > zoomedInMinYCoord {
                    
                    let originalMinYDistanceToBottom = UIScreen.main.bounds.height - zoomedInMinYCoord
                    let adjustedMinYDistanceToBottom = abs((translatedMinYCoord - (UIScreen.main.bounds.height - originalMinYDistanceToBottom)) - originalMinYDistanceToBottom) //tricky but it works
                    let alphaPart = (1 / originalMinYDistanceToBottom)
                    
                    backgroundView.backgroundColor = UIColor.black.withAlphaComponent(alphaPart * adjustedMinYDistanceToBottom)
                    self.optionalButtons.forEach({ $0?.alpha = alphaPart * adjustedMinYDistanceToBottom })
                }
                
                else if translatedMinYCoord < zoomedInMinYCoord {
                    
                    let alphaPart = (1 / zoomedInMaxYCoord)
                    
                    backgroundView.backgroundColor = UIColor.black.withAlphaComponent(alphaPart * translatedMaxYCoord)
                    self.optionalButtons.forEach({ $0?.alpha = alphaPart * translatedMaxYCoord })
                }
            }
            
            sender.setTranslation(CGPoint.zero, in: zoomedOutImageView?.superview)
        }
    }
    
    private func returnImageViewToOrigin () {
        
        if let imageView = zoomedInImageView, let imageViewFrame = zoomedInImageViewFrame {
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .black
                self.optionalButtons.forEach({ $0?.alpha = 1 })
                
                imageView.frame = imageViewFrame
            })
        }
    }
    
    @objc func handleZoomOutOnImageView () {
        
        zoomOutCompletion()
        
        if let imageView = zoomedInImageView {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .clear
                self.optionalButtons.forEach({ $0?.alpha = 0 })
                
                imageView.frame = self.zoomedOutImageViewFrame!
                imageView.layer.cornerRadius = self.zoomedOutImageViewCornerRadius ?? 0
                imageView.clipsToBounds = true
                
            }) { (finished: Bool) in
                
                self.zoomedOutImageView?.isHidden = false
                
                self.blackBackground?.removeFromSuperview()
                self.optionalButtons.forEach({ $0?.removeFromSuperview() })
                imageView.removeFromSuperview()
            }
        }
    }
}
