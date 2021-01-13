//
//  ReminderConfigurationCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/11/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class ReminderConfigurationCollectionViewCell: UICollectionViewCell {
    
    let selectionIndicatorContainer: UIView = UIView()
    let selectionIndicator: UIView = UIView()
    
    let leftBorderAnimationView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
    let leftBorderAnimationLayer: CAShapeLayer = CAShapeLayer()
    
    let rightBorderAnimationView: UIView = UIView(frame: CGRect(x: 60, y: 0, width: 60, height: 40))
    let rightBorderAnimationLayer: CAShapeLayer = CAShapeLayer()
    
    let borderAnimation = CABasicAnimation(keyPath: "strokeEnd")
    let borderColorAnimation = CABasicAnimation(keyPath: "strokeColor")
    
    let containerLabel = UILabel()
    
    override init (frame: CGRect) {
        super.init(frame: .zero)
        
        configureContainer()
        configureSelectionIndicator()
        configureBorderAnimationViews()
        configureBorderAnimations()
        configureContainerLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implented")
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
        
        selectionIndicator.backgroundColor = UIColor(hexString: "222222")
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
    
    func setContainerLabelText (row: Int) {
        
        let cellText: [String] = ["5 minutes \nbefore", "10 minutes \nbefore", "15 minutes \nbefore", "30 minutes \nbefore", "45 minutes \nbefore", "1 hour \nbefore", "2 hours \nbefore"]
        
        let attributedString = NSMutableAttributedString(string: cellText[row])

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineHeightMultiple = 0.8

        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))

        containerLabel.attributedText = attributedString
    }
}
