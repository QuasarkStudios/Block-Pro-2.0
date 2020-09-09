//
//  Personal_CollabContainer.swift
//  Block Pro
//
//  Created by Nimat Azeez on 8/16/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class Personal_CollabContainer: UIView {
    
    let selectionIndicatorContainer: UIView = UIView()
    let selectionIndicator: UIView = UIView()
    
    let leftBorderAnimationView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 30))
    let leftBorderAnimationLayer: CAShapeLayer = CAShapeLayer()
    
    let rightBorderAnimationView: UIView = UIView(frame: CGRect(x: 45, y: 0, width: 45, height: 30))
    let rightBorderAnimationLayer: CAShapeLayer = CAShapeLayer()
    
    let borderAnimation = CABasicAnimation(keyPath: "strokeEnd")
    let borderColorAnimation = CABasicAnimation(keyPath: "strokeColor")
    
    let containerLabel = UILabel()
    
    init (containerType: String) {
        super.init(frame: .zero)
        
        configureContainer()
        configureSelectionIndicator(containerType)
        configureBorderAnimationViews()
        configureBorderAnimations(containerType)
        configureContainerLabel(containerType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureContainer () {
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 16
        
        if #available(iOS 13.0, *) {
            
            self.layer.cornerCurve = .continuous
        }
    }
    
    private func configureSelectionIndicator (_ containerType: String) {
        
        self.addSubview(selectionIndicatorContainer)
        selectionIndicatorContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            selectionIndicatorContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            selectionIndicatorContainer.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            selectionIndicatorContainer.widthAnchor.constraint(equalToConstant: 90),
            selectionIndicatorContainer.heightAnchor.constraint(equalToConstant: 30)
        
        ].forEach({ $0.isActive = true })
        
        selectionIndicatorContainer.layer.cornerRadius = 15
        selectionIndicatorContainer.clipsToBounds = true
        
        selectionIndicatorContainer.addSubview(selectionIndicator)
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        if containerType == "personal" {
            
            selectionIndicator.layer.cornerRadius = 35
            
            [

                selectionIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                selectionIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                selectionIndicator.widthAnchor.constraint(equalToConstant: 120),
                selectionIndicator.heightAnchor.constraint(equalToConstant: 70)

            ].forEach({ $0.isActive = true })
        }
        
        else {
            
            selectionIndicator.layer.cornerRadius = 0
            
            [

                selectionIndicator.centerXAnchor.constraint(equalTo: selectionIndicatorContainer.centerXAnchor),
                selectionIndicator.centerYAnchor.constraint(equalTo: selectionIndicatorContainer.centerYAnchor),
                selectionIndicator.widthAnchor.constraint(equalToConstant: 0),
                selectionIndicator.heightAnchor.constraint(equalToConstant: 0)

            ].forEach({ $0.isActive = true })
        }
        
        selectionIndicator.backgroundColor = UIColor(hexString: "222222")
        selectionIndicator.alpha = containerType == "personal" ? 1 : 0
    }
    
    private func configureBorderAnimationViews () {
        
        leftBorderAnimationView.backgroundColor = .clear
        leftBorderAnimationView.layer.cornerRadius = 16
        leftBorderAnimationView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        leftBorderAnimationView.transform = CGAffineTransform(scaleX: -1, y: -1) //Flips the leftAnimationView to allow the borderAnimation to appear to happen in reverse
        self.addSubview(leftBorderAnimationView)
        
        rightBorderAnimationView.backgroundColor = .clear
        rightBorderAnimationView.layer.cornerRadius = 16
        rightBorderAnimationView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        self.addSubview(rightBorderAnimationView)
    }
    
    private func configureBorderAnimations (_ containerType: String) {
        
        let leftBorderAnimationViewPath = UIBezierPath(roundedRect: leftBorderAnimationView.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: 16, height: 16))
        let rightBorderAnimationViewPath = UIBezierPath(roundedRect: rightBorderAnimationView.bounds, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: 16, height: 16))
        
        let strokeColor = containerType == "personal" ? UIColor.clear.cgColor : UIColor(hexString: "D8D8D8")?.cgColor
        
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
    
    private func configureContainerLabel (_ containerType: String) {
        
        self.addSubview(containerLabel)
        
        containerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            containerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            containerLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            containerLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            containerLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        containerLabel.text = containerType == "personal" ? "Personal" : "Collab"
        containerLabel.textColor = containerType == "personal" ? .white : .black
        containerLabel.textAlignment = .center
        containerLabel.font = UIFont(name: "Poppins-SemiBold", size: 13.5)
    }
    
    func selectContainer () {

        self.animateBorderColor(fromValue: UIColor(hexString: "D8D8D8"), toValue: UIColor.clear, duration: 0.5)

        selectionIndicator.constraints.forEach { (constraint) in

            if constraint.firstAttribute == .width {

                constraint.constant = 120
            }

            else if constraint.firstAttribute == .height {

                constraint.constant = 70
            }
        }

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {

            self.layoutIfNeeded()
            
            self.selectionIndicator.layer.cornerRadius = 35
            self.selectionIndicator.alpha = 1
        })

        //Animates the label text color change
        UIView.transition(with: containerLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {

            self.containerLabel.textColor = .white

        })
    }
    
    func deselectContainer () {
            
        self.animateBorderStroke(fromValue: 0, toValue: 0, duration: 0)
        self.animateBorderColor(fromValue: UIColor(hexString: "222222"), toValue: UIColor(hexString: "D8D8D8"), duration: 0)
        
        //Delays the animation of the border until the selectionIndicator animation has almost been completed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
            self.animateBorderStroke(fromValue: 0, toValue: 0.785, duration: 0.4)
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
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            
            self.layoutIfNeeded()

            self.selectionIndicator.layer.cornerRadius = 7.5
        })
        
        UIView.animate(withDuration: 0.2, delay: 0.3, options: .curveEaseInOut, animations: {

            self.selectionIndicator.alpha = 0

        })

        //Animates the label text color change
        UIView.transition(with: containerLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {

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
}
