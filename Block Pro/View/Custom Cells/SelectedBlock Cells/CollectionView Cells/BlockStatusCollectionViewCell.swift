//
//  BlockStatusCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/25/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class BlockStatusCollectionViewCell: UICollectionViewCell {
    
    let selectionIndicatorContainer: UIView = UIView()
    let selectionIndicator: UIView = UIView()
    
    let leftBorderAnimationView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
    let leftBorderAnimationLayer: CAShapeLayer = CAShapeLayer()
    
    let rightBorderAnimationView: UIView = UIView(frame: CGRect(x: 60, y: 0, width: 60, height: 40))
    let rightBorderAnimationLayer: CAShapeLayer = CAShapeLayer()
    
    let borderAnimation = CABasicAnimation(keyPath: "strokeEnd")
    let borderColorAnimation = CABasicAnimation(keyPath: "strokeColor")
    
    let containerLabel = UILabel()
    
    var statusSelected: Bool = false
    
    var status: BlockStatus? {
        didSet {
            
            selectionIndicator.backgroundColor = statusColors[status!] as? UIColor
            setContainerLabelText(status!)
        }
    }
    
    let statusColors: [BlockStatus : UIColor?] = [.notStarted : UIColor(hexString: "AAAAAA", withAlpha: 0.75), .inProgress : UIColor(hexString: "5065A0", withAlpha: 0.75), .completed : UIColor(hexString: "2ECC70", withAlpha: 0.80), .needsHelp : UIColor(hexString: "FFCC02", withAlpha: 0.75), .late : UIColor(hexString: "E84D3C", withAlpha: 0.75)]
    
    override init (frame: CGRect) {
        super.init(frame: .zero)
        
        configureContainer()
        configureSelectionIndicator()
        configureBorderAnimationViews()
        configureBorderAnimations()
        configureContainerLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implmented")
    }
    
    private func configureContainer () {
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 20
        self.layer.cornerCurve = .continuous
    }
    
    private func configureSelectionIndicator () {
        
        self.addSubview(selectionIndicatorContainer)
        selectionIndicatorContainer.translatesAutoresizingMaskIntoConstraints = false
        
        selectionIndicatorContainer.addSubview(selectionIndicator)
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            selectionIndicatorContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            selectionIndicatorContainer.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            selectionIndicatorContainer.widthAnchor.constraint(equalToConstant: 120),
            selectionIndicatorContainer.heightAnchor.constraint(equalToConstant: 40),
            
            selectionIndicator.centerXAnchor.constraint(equalTo: selectionIndicatorContainer.centerXAnchor),
            selectionIndicator.centerYAnchor.constraint(equalTo: selectionIndicatorContainer.centerYAnchor),
            selectionIndicator.widthAnchor.constraint(equalToConstant: 0),
            selectionIndicator.heightAnchor.constraint(equalToConstant: 0)
        
        ].forEach({ $0.isActive = true })
        
        selectionIndicatorContainer.layer.cornerRadius = 20
        selectionIndicatorContainer.clipsToBounds = true
        
        selectionIndicator.alpha = 0
        selectionIndicator.layer.cornerRadius = 0
    }
    
    private func configureBorderAnimationViews () {
        
        leftBorderAnimationView.backgroundColor = .clear
        leftBorderAnimationView.layer.cornerRadius = 20
        leftBorderAnimationView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        leftBorderAnimationView.transform = CGAffineTransform(scaleX: -1, y: -1) //Flips the leftAnimationView to allow the borderAnimation to appear to happen in reverse
        self.addSubview(leftBorderAnimationView)
        
        rightBorderAnimationView.backgroundColor = .clear
        rightBorderAnimationView.layer.cornerRadius = 20
        rightBorderAnimationView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        self.addSubview(rightBorderAnimationView)
    }
    
    private func configureBorderAnimations () {
        
        let leftBorderAnimationViewPath = UIBezierPath(roundedRect: leftBorderAnimationView.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: 20, height: 20))
        let rightBorderAnimationViewPath = UIBezierPath(roundedRect: rightBorderAnimationView.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: 20, height: 20))
        
        let strokeColor = UIColor(hexString: "D8D8D8")?.cgColor
        
        leftBorderAnimationLayer.fillColor = UIColor.clear.cgColor
        leftBorderAnimationLayer.strokeColor = strokeColor
        leftBorderAnimationLayer.lineWidth = 1
        leftBorderAnimationLayer.path = leftBorderAnimationViewPath.cgPath
        
        leftBorderAnimationView.layer.addSublayer(leftBorderAnimationLayer)
        
        rightBorderAnimationLayer.fillColor = UIColor.clear.cgColor
        rightBorderAnimationLayer.strokeColor = strokeColor
        rightBorderAnimationLayer.lineWidth = 1
        rightBorderAnimationLayer.path = rightBorderAnimationViewPath.cgPath
        
        rightBorderAnimationView.layer.addSublayer(rightBorderAnimationLayer)
        
        animateBorderStroke(fromValue: 0.785, toValue: 0.785, duration: 0)
    }
    
    private func configureContainerLabel () {
        
        self.addSubview(containerLabel)
        containerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            containerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            containerLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            containerLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 2),
            containerLabel.heightAnchor.constraint(equalToConstant: 40)
            
        ].forEach({ $0.isActive = true })
        
        containerLabel.numberOfLines = 0
        containerLabel.font = UIFont(name: "Poppins-SemiBold", size: 13.5)
        containerLabel.textColor = .black
        containerLabel.textAlignment = .center
    }
    
    func selectContainer (animate: Bool = true) {

        self.animateBorderColor(fromValue: UIColor(hexString: "D8D8D8"), toValue: UIColor.clear, duration: animate ? 0.5 : 0)

        selectionIndicator.constraints.forEach { (constraint) in

            if constraint.firstAttribute == .width {

                constraint.constant = 150
            }

            else if constraint.firstAttribute == .height {

                constraint.constant = 80
            }
        }

        UIView.animate(withDuration: animate ? 0.5 : 0, delay: 0, options: .curveEaseInOut, animations: {

            self.layoutIfNeeded()
            
            self.selectionIndicator.layer.cornerRadius = 40
            self.selectionIndicator.alpha = 1
        })

        //Animates the label text color change
        UIView.transition(with: containerLabel, duration: animate ? 0.5 : 0, options: .transitionCrossDissolve, animations: {

            self.containerLabel.textColor = .white
        })
    }
    
    func deselectContainer (animate: Bool = true) {
            
        self.animateBorderStroke(fromValue: 0, toValue: 0, duration: 0)
        self.animateBorderColor(fromValue: UIColor(hexString: "222222"), toValue: UIColor(hexString: "D8D8D8"), duration: 0)
        
        //Delays the animation of the border until the selectionIndicator animation has almost been completed
        DispatchQueue.main.asyncAfter(deadline: .now() + (animate ? 0.3 : 0)) {
            
            self.animateBorderStroke(fromValue: 0, toValue: 0.785, duration: animate ? 0.4 : 0)
        }
        
        selectionIndicator.constraints.forEach { (constraint) in

            if constraint.firstAttribute == .width {

                constraint.constant = 15
            }

            else if constraint.firstAttribute == .height {

                constraint.constant = 15
            }
        }

        //Animates the selectionIndicator to be a little circle
        UIView.animate(withDuration: animate ? 0.4 : 0, delay: 0, options: .curveEaseInOut, animations: {
            
            self.layoutIfNeeded()

            self.selectionIndicator.layer.cornerRadius = 7.5
        })
        
        UIView.animate(withDuration: animate ? 0.2 : 0, delay: animate ? 0.3 : 0, options: .curveEaseInOut, animations: {

            self.selectionIndicator.alpha = 0

        })

        //Animates the label text color change
        UIView.transition(with: containerLabel, duration: animate ? 0.5 : 0, options: .transitionCrossDissolve, animations: {

            self.containerLabel.textColor = .black
        })
    }
    
    private func animateBorderStroke (fromValue: Double, toValue: Double, duration: Double) {
        
        borderAnimation.fromValue = fromValue
        borderAnimation.toValue = toValue
        borderAnimation.duration = duration
        borderAnimation.fillMode = CAMediaTimingFillMode.forwards
        borderAnimation.isRemovedOnCompletion = false
        
        leftBorderAnimationLayer.add(borderAnimation, forKey: "borderStrokeAnimation")
        rightBorderAnimationLayer.add(borderAnimation, forKey: "borderStrokeAnimation")
    }
    
    private func animateBorderColor (fromValue: UIColor?, toValue: UIColor?, duration: Double) {
        
        borderColorAnimation.fromValue = fromValue?.cgColor
        borderColorAnimation.toValue = toValue?.cgColor
        borderColorAnimation.duration = duration
        borderColorAnimation.fillMode = CAMediaTimingFillMode.forwards
        borderColorAnimation.isRemovedOnCompletion = false
        
        leftBorderAnimationLayer.add(borderColorAnimation, forKey: "borderColorAnimation")
        rightBorderAnimationLayer.add(borderColorAnimation, forKey: "borderColorAnimation")
    }
    
    func setContainerLabelText (_ status: BlockStatus) {
        
        let cellText: [BlockStatus : String] = [.notStarted : "Not \nStarted", .inProgress : "In \nProgress", .completed : "Completed", .needsHelp : "Needs \nHelp", .late : "Late"]
        
        let attributedString = NSMutableAttributedString(string: cellText[status] ?? "")

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineHeightMultiple = status == .completed || status == .late ? 0 : 0.8

        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))

        containerLabel.attributedText = attributedString
        
        //Changing the constraints of the containerLabel
        self.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .centerY && constraint.firstItem as? UILabel != nil {
                
                constraint.constant = status == .completed || status == .late ? 0 : 0.8
            }
        }
    }
}
