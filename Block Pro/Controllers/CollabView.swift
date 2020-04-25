//
//  CollabView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/24/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class CollabViewController: UIViewController {
    
    var rightBarButtonItem1: UIButton!
    var rightBarButtonItem2: UIButton!
    
    @IBOutlet weak var collabName: UILabel!
    @IBOutlet weak var collabObjective: UITextView!
    
    @IBOutlet weak var editCollabButton: UIButton!
    
    @IBOutlet weak var collabNavigationContainer: UIView!
    @IBOutlet weak var collabNavigationContainerTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var panGestureIndicator: UIView!
    @IBOutlet weak var panGestureView: UIView!
    
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var blocksButton: UIButton!
    @IBOutlet weak var messagesButton: UIButton!
    
    var collab: Collab?
    
    var viewInitiallyLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavBar()
        //configureView()
        configurePanGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !viewInitiallyLoaded {
           
            configureView()
            viewInitiallyLoaded = true
        }
    }
    
    private func configureNavBar () {
        
        rightBarButtonItem1 = UIButton(type: .system)
                rightBarButtonItem1.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        rightBarButtonItem1.setImage(UIImage(named: "UserGroup"), for: .normal)
        rightBarButtonItem1.addTarget(self, action: #selector(usersButtonPressed), for: .touchUpInside)
        
        rightBarButtonItem2 = UIButton(type: .system)
        rightBarButtonItem2.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        rightBarButtonItem2.setImage(UIImage(named: "attach"), for: .normal)
        rightBarButtonItem2.addTarget(self, action: #selector(attachmentButtonPressed), for: .touchUpInside)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightBarButtonItem2), UIBarButtonItem(customView: rightBarButtonItem1)]
    }
    
    private func configureView () {
        
        collabName.text = collab?.name
        collabObjective.text = collab?.objective
        
        editCollabButton.layer.cornerRadius = 10
        
        collabNavigationContainer.backgroundColor = .white
        
        collabNavigationContainer.layer.shadowRadius = 2
        collabNavigationContainer.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        collabNavigationContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        collabNavigationContainer.layer.shadowOpacity = 0.35
        
//        collabNavigationContainer.layer.borderWidth = 1
//        collabNavigationContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        
        collabNavigationContainer.layer.cornerRadius = 25
        collabNavigationContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collabNavigationContainer.layer.masksToBounds = false
        
        collabNavigationContainerTopAnchor.constant = (editCollabButton.frame.minY - 10)
        
        panGestureIndicator.backgroundColor = UIColor(hexString: "35393C")
        panGestureIndicator.layer.cornerRadius = 3
        
        panGestureView.backgroundColor = .clear
        
        progressButton.setTitleColor(.lightGray, for: .normal)
        messagesButton.setTitleColor(.lightGray, for: .normal)
    }
    
    @objc private func usersButtonPressed () {
        
    }
    
    @objc private func attachmentButtonPressed () {
        
        
    }
    
    private func configurePanGesture () {
        
        let getsureViewPan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        panGestureView.addGestureRecognizer(getsureViewPan)
        
        let stackViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        buttonStackView.addGestureRecognizer(stackViewPanGesture)
    }
    
    @objc private func handlePan (sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .began, .changed:
            
            moveWithPan(sender: sender)
            
        case .ended:
            
           break
        default:
            
            break
        }
    }
    
    private func moveWithPan (sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        
        if (collabNavigationContainerTopAnchor.constant + translation.y) > (editCollabButton.frame.maxY + 20) {
            
            collabNavigationContainerTopAnchor.constant = editCollabButton.frame.maxY + 20
        }
            
        else if (collabNavigationContainerTopAnchor.constant + translation.y) < (editCollabButton.frame.minY - 10) {
            
            let topAnchorValue = collabNavigationContainerTopAnchor.constant - 44 > 0 ? collabNavigationContainerTopAnchor.constant - 44 : 0
            let adjustedAlpha: CGFloat = ((1 / (editCollabButton.frame.minY - 10)) * topAnchorValue)
            
            panGestureIndicator.alpha = adjustedAlpha > 0 ? adjustedAlpha : 0
            buttonStackView.alpha = adjustedAlpha > 0 ? adjustedAlpha : 0
            
            
            collabNavigationContainerTopAnchor.constant += translation.y
            sender.setTranslation(CGPoint.zero, in: view)
        }
        
        else {
            
            collabNavigationContainerTopAnchor.constant += translation.y
            sender.setTranslation(CGPoint.zero, in: view)
        }
        
        
    }
    
    private func returnToOrigin () {
        
        
    }
    
    private func expandView () {
        
        
    }
    
    @IBAction func editCollab(_ sender: Any) {
    }
    
    
    @IBAction func progressButton(_ sender: Any) {
        
        progressButton.setTitleColor(.black, for: .normal)
        blocksButton.setTitleColor(.lightGray, for: .normal)
        messagesButton.setTitleColor(.lightGray, for: .normal)
    }
    
    @IBAction func blocksButton(_ sender: Any) {
        
        blocksButton.setTitleColor(.black, for: .normal)
        progressButton.setTitleColor(.lightGray, for: .normal)
        messagesButton.setTitleColor(.lightGray, for: .normal)
    }
    
    @IBAction func messagesButton(_ sender: Any) {
        
        messagesButton.setTitleColor(.black, for: .normal)
        blocksButton.setTitleColor(.lightGray, for: .normal)
        progressButton.setTitleColor(.lightGray, for: .normal)
    }
    
}
