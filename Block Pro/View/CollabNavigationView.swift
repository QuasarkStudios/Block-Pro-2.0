//
//  CollabNavigationView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 9/29/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class CollabNavigationView: UIView {
    
    let panGestureView = UIView()
    let panGestureIndicator = UIView()
    
    let buttonStackView = UIStackView()
    
    let progressButton = UIButton(type: .system)
    let blocksButton = UIButton(type: .system)
    let messagesButton = UIButton(type: .system)
    
    let collabTableView = UITableView()
    
    weak var collabViewController: AnyObject?
    
    init () {
        super.init(frame: .zero)
        
        configureView()
        configurePanGestureView()
        configureButtonStackView()
        configureButtons()
        configureTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView () {
        
        self.backgroundColor = .white
        
//        self.layer.shadowRadius = 1
//        self.layer.shadowColor = UIColor.white.cgColor
//        self.layer.shadowOffset = CGSize(width: 0, height: -2)
//        self.layer.shadowOpacity = 0.75
        
        self.layer.cornerRadius = 27.5
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        self.layer.masksToBounds = false
    }
    
    private func configurePanGestureView () {
        
        self.addSubview(panGestureIndicator) //Add this as a subview first
        self.addSubview(panGestureView)
        
        panGestureIndicator.translatesAutoresizingMaskIntoConstraints = false
        panGestureView.translatesAutoresizingMaskIntoConstraints = false
        
        [

            panGestureIndicator.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            panGestureIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            panGestureIndicator.widthAnchor.constraint(equalToConstant: 50),
            panGestureIndicator.heightAnchor.constraint(equalToConstant: 7.5),
            
            panGestureView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            panGestureView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            panGestureView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            panGestureView.heightAnchor.constraint(equalToConstant: 80)

        ].forEach{( $0.isActive = true )}
        
//        panGestureView.backgroundColor = UIColor.red.withAlphaComponent(0.1)
        
        panGestureIndicator.backgroundColor = UIColor(hexString: "222222")
        panGestureIndicator.layer.cornerRadius = 4
        panGestureIndicator.layer.cornerCurve = .continuous
        panGestureIndicator.clipsToBounds = true
    }
    
    private func configureButtonStackView () {
        
        self.addSubview(buttonStackView)
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            buttonStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            buttonStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            buttonStackView.topAnchor.constraint(equalTo: panGestureIndicator.bottomAnchor, constant: 10),
            buttonStackView.heightAnchor.constraint(equalToConstant: 40)
        
        ].forEach({ $0.isActive = true })
        
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillEqually
        
        buttonStackView.addArrangedSubview(progressButton)
        buttonStackView.addArrangedSubview(blocksButton)
        buttonStackView.addArrangedSubview(messagesButton)
    }
    
    private func configureButtons () {
        
        progressButton.setTitle("Progress", for: .normal)
        progressButton.setTitleColor(UIColor.lightGray, for: .normal)
        progressButton.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 15)
        progressButton.addTarget(self, action: #selector(progressButtonTouchUpInside), for: .touchUpInside)
        
        blocksButton.setTitle("Blocks", for: .normal)
        blocksButton.setTitleColor(UIColor.black, for: .normal)
        blocksButton.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 15)
        blocksButton.addTarget(self, action: #selector(blocksButtonTouchUpInside), for: .touchUpInside)
        
        messagesButton.setTitle("Messages", for: .normal)
        messagesButton.setTitleColor(UIColor.lightGray, for: .normal)
        messagesButton.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 15)
        messagesButton.addTarget(self, action: #selector(messagesButtonTouchUpInside), for: .touchUpInside)
    }
    
    private func configureTableView() {
        
        self.addSubview(collabTableView)
        
        collabTableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collabTableView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            collabTableView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            collabTableView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 10),
            collabTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        collabTableView.keyboardDismissMode = .interactive
        
        collabTableView.register(UITableViewCell.self, forCellReuseIdentifier: "seperatorCell")
    }
    
    @objc private func progressButtonTouchUpInside () {
        
        if let viewController = collabViewController as? CollabViewController {
            
            viewController.progressButtonTouchUpInside()
            
            UIView.transition(with: buttonStackView, duration: 0.15, options: .transitionCrossDissolve, animations: {
                
                self.progressButton.setTitleColor(.black, for: .normal)
                self.blocksButton.setTitleColor(.lightGray, for: .normal)
                self.messagesButton.setTitleColor(.lightGray, for: .normal)
            })
        }
    }
    
    @objc private func blocksButtonTouchUpInside () {
        
        if let viewController = collabViewController as? CollabViewController {
            
            viewController.blocksButtonTouchUpInside()
            
            UIView.transition(with: buttonStackView, duration: 0.15, options: .transitionCrossDissolve, animations: {
                
                self.progressButton.setTitleColor(.lightGray, for: .normal)
                self.blocksButton.setTitleColor(.black, for: .normal)
                self.messagesButton.setTitleColor(.lightGray, for: .normal)
            })
            
//            progressButton.setTitleColor(.lightGray, for: .normal)
//            blocksButton.setTitleColor(.black, for: .normal)
//            messagesButton.setTitleColor(.lightGray, for: .normal)
        }
    }
    
    @objc private func messagesButtonTouchUpInside () {
        
        if let viewController = collabViewController as? CollabViewController {
            
            viewController.messagesButtonTouchUpInside()
            
            UIView.transition(with: buttonStackView, duration: 0.15, options: .transitionCrossDissolve, animations: {
                
                self.progressButton.setTitleColor(.lightGray, for: .normal)
                self.blocksButton.setTitleColor(.lightGray, for: .normal)
                self.messagesButton.setTitleColor(.black, for: .normal)
            })
            
//            progressButton.setTitleColor(.lightGray, for: .normal)
//            blocksButton.setTitleColor(.lightGray, for: .normal)
//            messagesButton.setTitleColor(.black, for: .normal)
        }
    }
}
