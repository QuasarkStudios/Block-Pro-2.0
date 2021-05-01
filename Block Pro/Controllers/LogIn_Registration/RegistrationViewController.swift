//
//  RegistrationViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/27/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import Lottie

class RegistrationViewController: UIViewController {
    
    let registrationCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    let welcomeLabelsContainer = UIView()
    let welcomeLabel = UILabel()
    let subheadingLabel = UILabel()
    
    let gifImageView = UIImageView()
    
    let signInButton = UIButton(type: .system)
    
    let startButtonContainer = UIView()
    let startButton = UIButton(type: .system)
    
    let previewPageControl = UIPageControl()
    let skipButton = UIButton(type: .system)
    let previewPreviousButton = UIButton(type: .system)
    let previewNextButton = UIButton(type: .system)
    
    let onboardingNextButton = UIButton(type: .system)
    
    var gifImageViewTopAnchor: NSLayoutConstraint?
    var gifImageViewBottomAnchor: NSLayoutConstraint?
    var gifImageViewWidthConstraint: NSLayoutConstraint?
    var gifImageViewHeightConstraint: NSLayoutConstraint?
    
    var welcomeContainerCenterXAnchor: NSLayoutConstraint?
    var startButtonContainerCenterXAnchor: NSLayoutConstraint?
    
    var collectionViewTopAnchor: NSLayoutConstraint?
    var collectionViewCenterXAnchor: NSLayoutConstraint?
    
    weak var logInViewController: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
        configureWelcomeLabelsContainer()
        configureWelcomeLabel()
        configureSubheadingLabel()
        
        configureGifImageView()
        
        configureSignInButton()
        
        configureStartButtonContainer()
        configureStartButton()
        
        configureRegistrationCollectionView(registrationCollectionView)
//        configureSkipButton()
        configurePreviewPreviousButton()
        configurePreviewNextButton()
        configurePreviewPageControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
            
            self.view.subviews.forEach { (subview) in
                
                if subview != self.skipButton && subview != self.previewPageControl && subview != self.previewPreviousButton && subview != self.previewNextButton {
                    
                    subview.alpha = 1
                }
            }
            
        } completion: { (finished: Bool) in
            
            
        }
    }
    
    private func configureWelcomeLabelsContainer () {
        
        self.view.addSubview(welcomeLabelsContainer)
        welcomeLabelsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
//            welcomeLabelsContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
//            welcomeLabelsContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            welcomeLabelsContainer.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0),
            welcomeLabelsContainer.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40),
            welcomeLabelsContainer.heightAnchor.constraint(equalToConstant: 95)
        
        ].forEach({ $0.isActive = true })
        
        welcomeContainerCenterXAnchor = welcomeLabelsContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0)
        welcomeContainerCenterXAnchor?.isActive = true
        
        welcomeLabelsContainer.alpha = 0
    }
    
    private func configureWelcomeLabel () {
        
        welcomeLabelsContainer.addSubview(welcomeLabel)
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            welcomeLabel.leadingAnchor.constraint(equalTo: welcomeLabelsContainer.leadingAnchor, constant: 0),
            welcomeLabel.trailingAnchor.constraint(equalTo: welcomeLabelsContainer.trailingAnchor, constant: 0),
            welcomeLabel.topAnchor.constraint(equalTo: welcomeLabelsContainer.topAnchor, constant: 0),
            welcomeLabel.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        welcomeLabel.font = UIFont(name: "Poppins-SemiBold", size: 23)
        welcomeLabel.adjustsFontSizeToFitWidth = true
        welcomeLabel.textAlignment = .center
        welcomeLabel.text = "Welcome to BlockPro 2.0"
    }
    
    private func configureSubheadingLabel () {
        
        welcomeLabelsContainer.addSubview(subheadingLabel)
        subheadingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            subheadingLabel.leadingAnchor.constraint(equalTo: welcomeLabelsContainer.leadingAnchor, constant: 10),
            subheadingLabel.trailingAnchor.constraint(equalTo: welcomeLabelsContainer.trailingAnchor, constant: -10),
            subheadingLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 15),
            subheadingLabel.heightAnchor.constraint(equalToConstant: 55)
        
        ].forEach({ $0.isActive = true })
        
        subheadingLabel.numberOfLines = 2
        subheadingLabel.font = UIFont(name: "Poppins-Regular", size: 18)
        subheadingLabel.adjustsFontSizeToFitWidth = true
        subheadingLabel.textAlignment = .center
        subheadingLabel.textColor = .lightGray
        subheadingLabel.text = "Let’s start off by getting to know each other a little better"
    }
    
    private func configureGifImageView () {
        
        let topAnchorConstant = (keyWindow?.safeAreaInsets.top ?? 0) + ((keyWindow?.safeAreaInsets.bottom ?? 0) > 0 ? 30 : 20)
        let bottomAnchorConstant: CGFloat = (keyWindow?.safeAreaInsets.bottom ?? 0) > 0 ? -topAnchorConstant + 15 : -topAnchorConstant + 7.5
        
        self.view.addSubview(gifImageView)
        gifImageView.translatesAutoresizingMaskIntoConstraints = false

        gifImageViewTopAnchor = gifImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: topAnchorConstant)
        gifImageViewBottomAnchor = gifImageView.bottomAnchor.constraint(equalTo: welcomeLabelsContainer.topAnchor, constant: bottomAnchorConstant)
        gifImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        gifImageViewWidthConstraint = gifImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        gifImageViewHeightConstraint = gifImageView.heightAnchor.constraint(equalToConstant: 75)
            
        gifImageViewTopAnchor?.isActive = true
        gifImageViewBottomAnchor?.isActive = true
        gifImageViewWidthConstraint?.isActive = true
        
        gifImageView.alpha = 0
        gifImageView.contentMode = .scaleAspectFit
        
        gifImageView.loadGif(name: "giphy")
    }
    
    //MARK: - Configure Sign In Button
    
    private func configureSignInButton () {
        
        self.view.addSubview(signInButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            signInButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            signInButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            signInButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            signInButton.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        signInButton.alpha = 0
        
        let lightGrayText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 14) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        let blackText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 14) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        let attributedString = NSMutableAttributedString(string: "")
        
        attributedString.append(NSAttributedString(string: "Already have an account?  ", attributes: lightGrayText))
        attributedString.append(NSAttributedString(string: "Sign In!", attributes: blackText))
        
        signInButton.setAttributedTitle(attributedString, for: .normal)
        
        signInButton.addTarget(self, action: #selector(signInButtonPressed), for: .touchUpInside)
    }
    
    private func configureStartButtonContainer () {
        
        self.view.addSubview(startButtonContainer)
        startButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
//            startButtonContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
//            startButtonContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            startButtonContainer.topAnchor.constraint(equalTo: welcomeLabelsContainer.bottomAnchor, constant: 0),
            startButtonContainer.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: 0),
            startButtonContainer.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
            
        ].forEach({ $0.isActive = true })
        
        startButtonContainerCenterXAnchor = startButtonContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0)
        startButtonContainerCenterXAnchor?.isActive = true
        
        startButtonContainer.alpha = 0
    }
    
    private func configureStartButton () {
        
        startButtonContainer.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            startButton.centerXAnchor.constraint(equalTo: startButtonContainer.centerXAnchor, constant: 0),
            startButton.centerYAnchor.constraint(equalTo: startButtonContainer.centerYAnchor, constant: 0),
            startButton.widthAnchor.constraint(equalToConstant: 140),
            startButton.heightAnchor.constraint(equalToConstant: 44)
        
        ].forEach({ $0.isActive = true })
        
        startButton.backgroundColor = UIColor(hexString: "222222")
        startButton.tintColor = .white

        startButton.layer.cornerRadius = 22
        startButton.layer.cornerCurve = .continuous

        startButton.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        startButton.layer.shadowRadius = 2
        startButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        startButton.layer.shadowOpacity = 0.3

        startButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 17)
        startButton.setTitle("Start", for: .normal)

        startButton.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
    }
    
    private func configureRegistrationCollectionView (_ collectionView: UICollectionView) {
        
//        self.view.addSubview(collectionView)
        self.view.insertSubview(collectionView, belowSubview: gifImageView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collectionView.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: (keyWindow?.safeAreaInsets.bottom ?? 0) > 0 ? -145 : -125),
            collectionView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            
        ].forEach({ $0.isActive = true })
        
        collectionViewTopAnchor = collectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: (keyWindow?.safeAreaInsets.top ?? 0) + 80)
        collectionViewCenterXAnchor = collectionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: UIScreen.main.bounds.width)
        
        collectionViewTopAnchor?.isActive = true
        collectionViewCenterXAnchor?.isActive = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = false
        
        
        
        var itemHeight = UIScreen.main.bounds.height
        itemHeight -= (keyWindow?.safeAreaInsets.top ?? 0) + 80 //Top anchor of the collectionView
        itemHeight -= (keyWindow?.safeAreaInsets.bottom ?? 0) > 0 ? 145 : 125 //Bottom anchor of the collectionView in relation to the sign in button
        itemHeight -= (keyWindow?.safeAreaInsets.bottom ?? 0) + 40 //minYCoord of the sign in button
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: itemHeight)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.estimatedItemSize = CGSize(width: 0, height: 0)
        
        collectionView.collectionViewLayout = layout
        
//        collectionView.lay
        
        collectionView.register(BlockOnboardingCollectionViewCell.self, forCellWithReuseIdentifier: "blockOnboardingCollectionViewCell")
        collectionView.register(MessagingOnboardingCollectionViewCell.self, forCellWithReuseIdentifier: "messagingOnboardingCollectionViewCell")
        collectionView.register(CollabOnboardingCollectionViewCell.self, forCellWithReuseIdentifier: "collabOnboardingCollectionViewCell")
        
        //Appears to be helping fix the choppy scrolling that occurs when scrolling from the first to the second cell
        //Choppy scrolling appears to be caused by initializing two animationViews at the same time
        collectionView.dequeueReusableCell(withReuseIdentifier: "collabOnboardingCollectionViewCell", for: IndexPath(item: 2, section: 0))
    }
    
    private func configureSkipButton () {
        
        self.view.addSubview(skipButton)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            skipButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -45),
            skipButton.bottomAnchor.constraint(equalTo: registrationCollectionView.topAnchor, constant: -11),
            skipButton.widthAnchor.constraint(equalToConstant: 45),
            skipButton.heightAnchor.constraint(equalToConstant: 35)
        
        ].forEach({ $0.isActive = true })
        
        skipButton.alpha = 0
        skipButton.tintColor = .lightGray
        
        skipButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        skipButton.setTitle("Skip", for: .normal)
    }
    
    private func configurePreviewPreviousButton () {
        
        self.view.addSubview(previewPreviousButton)
        previewPreviousButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            previewPreviousButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40),
            previewPreviousButton.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: (keyWindow?.safeAreaInsets.bottom ?? 0) > 0 ? -40 : -30),
            previewPreviousButton.widthAnchor.constraint(equalToConstant: 75),
            previewPreviousButton.heightAnchor.constraint(equalToConstant: 35)
        
        ].forEach({ $0.isActive = true })
        
        previewPreviousButton.alpha = 0
        previewPreviousButton.isEnabled = false
        previewPreviousButton.backgroundColor = UIColor(hexString: "AAAAAA"/*"222222"*/)
        previewPreviousButton.tintColor = .white
        
        previewPreviousButton.layer.cornerRadius = 17.5
        previewPreviousButton.clipsToBounds = true
        
        previewPreviousButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        previewPreviousButton.setTitle("Prev", for: .normal)
        
        previewPreviousButton.addTarget(self, action: #selector(previewPreviousButtonPressed), for: .touchUpInside)
    }
    
    private func configurePreviewNextButton () {
        
        self.view.addSubview(previewNextButton)
        previewNextButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            previewNextButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40),
            previewNextButton.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: (keyWindow?.safeAreaInsets.bottom ?? 0) > 0 ? -40 : -30),
            previewNextButton.widthAnchor.constraint(equalToConstant: 75),
            previewNextButton.heightAnchor.constraint(equalToConstant: 35)
        
        ].forEach({ $0.isActive = true })
        
        previewNextButton.alpha = 0
        previewNextButton.backgroundColor = UIColor(hexString: "222222")
        previewNextButton.tintColor = .white
        
        previewNextButton.layer.cornerRadius = 17.5
        previewNextButton.clipsToBounds = true
        
        previewNextButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        previewNextButton.setTitle("Next", for: .normal)
        
        previewNextButton.addTarget(self, action: #selector(previewNextButtonPressed), for: .touchUpInside)
    }
    
    private func configurePreviewPageControl () {
        
        self.view.addSubview(previewPageControl)
        previewPageControl.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            previewPageControl.bottomAnchor.constraint(equalTo: previewPreviousButton.topAnchor, constant: (keyWindow?.safeAreaInsets.bottom ?? 0) > 0 ? -30 : -20/*-20*/),
            previewPageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            previewPageControl.widthAnchor.constraint(equalToConstant: 200),
            previewPageControl.heightAnchor.constraint(equalToConstant: 27.5)
        
        ].forEach({ $0.isActive = true })
        
        previewPageControl.alpha = 0
        previewPageControl.isUserInteractionEnabled = false
        previewPageControl.numberOfPages = 3
        previewPageControl.pageIndicatorTintColor = UIColor(hexString: "D8D8D8")
        previewPageControl.currentPageIndicatorTintColor = UIColor(hexString: "222222")
        previewPageControl.currentPage = 0
    }
    
    @objc private func startButtonPressed () {
        
        gifImageViewTopAnchor?.constant = self.view.safeAreaInsets.top + 5
        gifImageViewBottomAnchor?.isActive = false
        gifImageViewWidthConstraint?.constant = 75
        gifImageViewHeightConstraint?.isActive = true
        
        welcomeContainerCenterXAnchor?.constant = -UIScreen.main.bounds.width
        startButtonContainerCenterXAnchor?.constant = -UIScreen.main.bounds.width
        
        collectionViewCenterXAnchor?.constant = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
            
            self.welcomeLabelsContainer.alpha = 0
            self.startButton.alpha = 0
            
            self.skipButton.alpha = 1
            self.previewPageControl.alpha = 1
            self.previewPreviousButton.alpha = 1
            self.previewNextButton.alpha = 1
            
        } completion: { (finished: Bool) in
            
            self.welcomeLabelsContainer.removeFromSuperview()
            self.startButton.removeFromSuperview()
        }

    }
    
    @objc private func previewPreviousButtonPressed () {
        
        if let indexPathForFirstVisibleItem = registrationCollectionView.indexPathsForVisibleItems.first, let visibleCell = registrationCollectionView.cellForItem(at: indexPathForFirstVisibleItem) {
            
            if let cell = visibleCell as? BlockOnboardingCollectionViewCell {

                cell.animationView.pause()
            }

            else if let cell = visibleCell as? MessagingOnboardingCollectionViewCell {

                cell.animationView.pause()
            }

            else if let cell = visibleCell as? CollabOnboardingCollectionViewCell {

                cell.animationView.pause()
            }
            
            registrationCollectionView.scrollToItem(at: IndexPath(item: indexPathForFirstVisibleItem.row - 1, section: 0), at: .centeredHorizontally, animated: true)
            
            previewPageControl.currentPage = indexPathForFirstVisibleItem.row - 1
            
            if indexPathForFirstVisibleItem.row == 1 {
                
                UIView.transition(with: previewPreviousButton, duration: 0.25, options: .transitionCrossDissolve) {
                    
                    self.previewPreviousButton.isEnabled = false
                    self.previewPreviousButton.backgroundColor = UIColor(hexString: "AAAAAA")
                }

                
//                previewPreviousButton.isEnabled = false
//                previewPreviousButton.backgroundColor = UIColor(hexString: "AAAAAA")
            }
        }
    }
    
    @objc private func previewNextButtonPressed () {
        
        if let indexPathForFirstVisibleItem = registrationCollectionView.indexPathsForVisibleItems.first, let visibleCell = registrationCollectionView.cellForItem(at: indexPathForFirstVisibleItem) {
            
            if let cell = visibleCell as? BlockOnboardingCollectionViewCell {

                cell.animationView.pause()
            }

            else if let cell = visibleCell as? MessagingOnboardingCollectionViewCell {

                cell.animationView.pause()
            }

            else if let cell = visibleCell as? CollabOnboardingCollectionViewCell {

                cell.animationView.pause()
            }
            
            registrationCollectionView.scrollToItem(at: IndexPath(item: indexPathForFirstVisibleItem.row + 1, section: 0), at: .centeredHorizontally, animated: true)
            
            previewPageControl.currentPage = indexPathForFirstVisibleItem.row + 1
            
            if indexPathForFirstVisibleItem.row == 0 {
                
                UIView.transition(with: previewPreviousButton, duration: 0.25, options: .transitionCrossDissolve) {
                    
                    self.previewPreviousButton.isEnabled = true
                    self.previewPreviousButton.backgroundColor = UIColor(hexString: "222222")
                }

                
//                previewPreviousButton.isEnabled = true
//                previewPreviousButton.backgroundColor = UIColor(hexString: "222222")
            }
            
            else if indexPathForFirstVisibleItem.row == 2 {
                
                
            }
        }
    }

    @objc private func signInButtonPressed () {
        
        if let viewController = logInViewController as? LogInViewController {
            
            viewController.view.subviews.forEach({ $0.alpha = 0 })
            
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
                
                self.view.subviews.forEach({ $0.alpha = 0 })
                
            } completion: { (finished: Bool) in
                
                self.dismiss(animated: false) {
                    
                    UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
                        
                        viewController.view.subviews.forEach({ $0.alpha = 1 })
                    }
                }
            }
        }
    }
}

extension RegistrationViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "blockOnboardingCollectionViewCell", for: indexPath) as! BlockOnboardingCollectionViewCell
        
            
            return cell
        }
        
        else if indexPath.row == 1 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messagingOnboardingCollectionViewCell", for: indexPath) as! MessagingOnboardingCollectionViewCell
            
            return cell
        }
        
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collabOnboardingCollectionViewCell", for: indexPath) as! CollabOnboardingCollectionViewCell
            
            return cell
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        
        if let cell = cell as? BlockOnboardingCollectionViewCell {

            cell.animationView.play()
        }

        else if let cell = cell as? MessagingOnboardingCollectionViewCell {

            cell.animationView.play()
        }

        else if let cell = cell as? CollabOnboardingCollectionViewCell {

            cell.animationView.play()
        }
    }
}
