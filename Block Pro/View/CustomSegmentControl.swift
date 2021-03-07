//
//  CustomSegmentControl.swift
//  Block Pro
//
//  Created by Nimat Azeez on 12/26/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class CustomSegmentControl: UIView {
    
    let segmentBackground = UIView()
    let selectedSegmentIndicator = UIView()
    
    let detailsButton = UIButton(type: .system)
    let attachmentsButton = UIButton(type: .system)
    
    var segmentIndicatorLeadingAnchor: NSLayoutConstraint?
    
    weak var parentViewController: AnyObject?
    
    init(parentViewController: AnyObject) {
        super.init(frame: .zero)
        
        self.parentViewController = parentViewController
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        configureView()
        configureSegmentBackground()
        configureSelectedSegmentIndicator()
        configureButtons()
    }
    
    private func configureView () {
        
        guard let superview = self.superview else { return }
        
            self.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 50),
                self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -50),
                self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -15),
                self.heightAnchor.constraint(equalToConstant: 40)
                
            ].forEach({ $0.isActive = true })
            
            self.backgroundColor = UIColor(hexString: "D8D8D8")
            self.layer.cornerRadius = 10
            self.clipsToBounds = true
    }
    
    private func configureSegmentBackground () {
        
        self.addSubview(segmentBackground)
        segmentBackground.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            segmentBackground.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1.5),
            segmentBackground.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1.5),
            segmentBackground.topAnchor.constraint(equalTo: self.topAnchor, constant: 1.5),
            segmentBackground.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1.5)
        
        ].forEach({ $0.isActive = true })
        
        segmentBackground.backgroundColor = .white
        segmentBackground.layer.cornerRadius = 10
        segmentBackground.clipsToBounds = true
    }
    
    private func configureSelectedSegmentIndicator () {
        
        self.addSubview(selectedSegmentIndicator)
        selectedSegmentIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            selectedSegmentIndicator.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            selectedSegmentIndicator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            selectedSegmentIndicator.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - 100) / 2)
        
        ].forEach({ $0.isActive = true })
        
        segmentIndicatorLeadingAnchor = selectedSegmentIndicator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0)
        segmentIndicatorLeadingAnchor?.isActive = true
        
        selectedSegmentIndicator.backgroundColor = UIColor(hexString: "222222")
        selectedSegmentIndicator.layer.cornerRadius = 10
        selectedSegmentIndicator.clipsToBounds = true
    }
    
    private func configureButtons () {
        
        self.addSubview(detailsButton)
        detailsButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(attachmentsButton)
        attachmentsButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            detailsButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 1.5),
            detailsButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1.5),
            detailsButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1.5),
            detailsButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - 100) / 2),
            
            attachmentsButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 1.5),
            attachmentsButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1.5),
            attachmentsButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1.5),
            attachmentsButton.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - 100) / 2)
        
        ].forEach({ $0.isActive = true })
        
        detailsButton.tintColor = .white
        detailsButton.setTitle("Details", for: .normal)
        detailsButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 13)
        detailsButton.addTarget(self, action: #selector(detailsButtonPressed), for: .touchUpInside)
        
        attachmentsButton.tintColor = .black
        attachmentsButton.setTitle("Attachments", for: .normal)
        attachmentsButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 13)
        attachmentsButton.addTarget(self, action: #selector(attachmentsButtonPressed), for: .touchUpInside)
    }
    
    @objc private func detailsButtonPressed () {
        
        segmentIndicatorLeadingAnchor?.constant = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.layoutIfNeeded()
            
        } completion: { (finished: Bool) in
            
            
        }
        
        UIView.transition(with: detailsButton, duration: 0.3, options: .transitionCrossDissolve) {
            
            self.detailsButton.tintColor = .white
        }

        UIView.transition(with: attachmentsButton, duration: 0.3, options: .transitionCrossDissolve) {
            
            self.attachmentsButton.tintColor = .black
        }
        
        if let viewController = parentViewController as? ConfigureBlockViewController {
            
            viewController.changeSelectedTableView(detailsTableView: true)
        }
        
        else if let viewController = parentViewController as? ConfigureCollabViewController {
            
            viewController.changeSelectedTableView(detailsTableView: true)
        }
    }
    
    @objc private func attachmentsButtonPressed () {
        
        segmentIndicatorLeadingAnchor?.constant = self.frame.width / 2
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.layoutIfNeeded()
            
        } completion: { (finished: Bool) in
            
            
        }
        
        UIView.transition(with: attachmentsButton, duration: 0.3, options: .transitionCrossDissolve) {
            
            self.attachmentsButton.tintColor = .white
        }
        
        UIView.transition(with: detailsButton, duration: 0.3, options: .transitionCrossDissolve) {
            
            self.detailsButton.tintColor = .black
        }
        
        if let viewController = parentViewController as? ConfigureBlockViewController {
            
            viewController.changeSelectedTableView(detailsTableView: false)
        }
        
        else if let viewController = parentViewController as? ConfigureCollabViewController {
            
            viewController.changeSelectedTableView(detailsTableView: false)
        }
    }
}
