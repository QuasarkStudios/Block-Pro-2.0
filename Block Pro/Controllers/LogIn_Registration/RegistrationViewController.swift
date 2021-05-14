//
//  RegistrationViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/27/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import Lottie
import SVProgressHUD

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
    let previewPreviousButton = UIButton(type: .system)
    let previewNextButton = UIButton(type: .system)
    
    let yourTurnLabel = UILabel()
    
    let trackBar = UIView()
    let progressBar = UIView()
    let onboardingPreviousButton = UIButton(type: .system)
    let onboardingNextButton = UIButton(type: .system)
    
    let firebaseAuth = FirebaseAuthentication()
    var signingUpWithApple: Bool = false
    
    var newUser = NewUser()
    
    var itemHeightForPreviewCells: CGFloat {
        
        var itemHeight = UIScreen.main.bounds.height
        itemHeight -= (keyWindow?.safeAreaInsets.top ?? 0) + 80 //Top anchor of the collectionView
        itemHeight -= (keyWindow?.safeAreaInsets.bottom ?? 0) > 0 ? 145 : 125 //Bottom anchor of the collectionView in relation to the sign in button
        itemHeight -= (keyWindow?.safeAreaInsets.bottom ?? 0) + 40 //minYCoord of the sign in button
        
        return itemHeight
    }
    
    var itemHeightForOnboardingCells: CGFloat {
        
        var itemHeight = UIScreen.main.bounds.height
        itemHeight -= (keyWindow?.safeAreaInsets.top ?? 0) + 130 //Top anchor of the collectionView
        itemHeight -= (keyWindow?.safeAreaInsets.bottom ?? 0) > 0 ? 145 : 125 //Bottom anchor of the collectionView in relation to the sign in button
        itemHeight -= (keyWindow?.safeAreaInsets.bottom ?? 0) + 40 //minYCoord of the sign in button
        
        return itemHeight
    }
    
    var itemHeightForProfilePictureCell: CGFloat {
        
        return UIScreen.main.bounds.height - ((keyWindow?.safeAreaInsets.top ?? 0) + 130)
    }
    
    var gifImageViewTopAnchor: NSLayoutConstraint?
    var gifImageViewBottomAnchor: NSLayoutConstraint?
    var gifImageViewWidthConstraint: NSLayoutConstraint?
    var gifImageViewHeightConstraint: NSLayoutConstraint?
    
    var welcomeContainerCenterXAnchor: NSLayoutConstraint?
    var startButtonContainerCenterXAnchor: NSLayoutConstraint?
    
    var collectionViewTopAnchor: NSLayoutConstraint?
    var collectionViewBottomAnchorWithSignInButton: NSLayoutConstraint?
    var collectionViewBottomAnchorWithView: NSLayoutConstraint?
    var collectionViewCenterXAnchor: NSLayoutConstraint?
    
    var progressBarWidthConstraint: NSLayoutConstraint?
    
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
        configurePreviewPreviousButton()
        configurePreviewNextButton()
        configurePreviewPageControl()
        
        configureProgressBar()
        configureOnboardingPreviousButton()
        configureOnboardingNextButton()
        
        configureYourTurnLabel()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Animates the entry to the view from the LogInViewController
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
            
            self.view.subviews.forEach { (subview) in
                
                //Will only animate these subviews
                if subview == self.gifImageView || subview == self.welcomeLabelsContainer || subview == self.startButtonContainer || subview == self.signInButton {
                    
                    subview.alpha = 1
                }
            }
        }
    }
    
    
    //MARK: - Configure Welcome Container
    
    private func configureWelcomeLabelsContainer () {
        
        self.view.addSubview(welcomeLabelsContainer)
        welcomeLabelsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            welcomeLabelsContainer.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0),
            welcomeLabelsContainer.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40),
            welcomeLabelsContainer.heightAnchor.constraint(equalToConstant: 95)
        
        ].forEach({ $0.isActive = true })
        
        welcomeContainerCenterXAnchor = welcomeLabelsContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0)
        welcomeContainerCenterXAnchor?.isActive = true
        
        welcomeLabelsContainer.alpha = 0
    }
    
    
    //MARK: - Configure Welcome Label
    
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
    
    
    //MARK: - Configure Subheading Label
    
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
    
    
    //MARK: - Configure Gif Image View
    
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
    
    
    //MARK: - Configure Start Button Container
    
    private func configureStartButtonContainer () {
        
        self.view.addSubview(startButtonContainer)
        startButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            startButtonContainer.topAnchor.constraint(equalTo: welcomeLabelsContainer.bottomAnchor, constant: 0),
            startButtonContainer.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: 0),
            startButtonContainer.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
            
        ].forEach({ $0.isActive = true })
        
        startButtonContainerCenterXAnchor = startButtonContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0)
        startButtonContainerCenterXAnchor?.isActive = true
        
        startButtonContainer.alpha = 0
    }
    
    
    //MARK: - Configure Start Button
    
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
    
    
    //MARK: - Configure Registration Collection View
    
    private func configureRegistrationCollectionView (_ collectionView: UICollectionView) {
        
        self.view.insertSubview(collectionView, belowSubview: gifImageView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionViewTopAnchor = collectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: (keyWindow?.safeAreaInsets.top ?? 0) + 80)
        collectionViewBottomAnchorWithSignInButton = collectionView.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: (keyWindow?.safeAreaInsets.bottom ?? 0) > 0 ? -145 : -125)
        collectionViewBottomAnchorWithView = collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        collectionViewCenterXAnchor = collectionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: UIScreen.main.bounds.width)
        collectionView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        
        collectionViewTopAnchor?.isActive = true
        collectionViewBottomAnchorWithSignInButton?.isActive = true
        collectionViewCenterXAnchor?.isActive = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = false
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: itemHeightForPreviewCells)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.estimatedItemSize = CGSize(width: 0, height: 0)
        
        collectionView.collectionViewLayout = layout
        
        collectionView.register(BlockPreviewCollectionViewCell.self, forCellWithReuseIdentifier: "blockPreviewCollectionViewCell")
        collectionView.register(MessagingPreviewCollectionViewCell.self, forCellWithReuseIdentifier: "messagingPreviewCollectionViewCell")
        collectionView.register(CollabPreviewCollectionViewCell.self, forCellWithReuseIdentifier: "collabPreviewCollectionViewCell")
        collectionView.register(EmailOnboardingCollectionViewCell.self, forCellWithReuseIdentifier: "emailOnboardingCollectionViewCell")
        collectionView.register(NameOnboardingCollectionViewCell.self, forCellWithReuseIdentifier: "nameOnboardingCollectionViewCell")
        collectionView.register(UsernameOnboardingCollectionViewCell.self, forCellWithReuseIdentifier: "usernameOnboardingCollectionViewCell")
        collectionView.register(PasswordOnboardingCollectionViewCell.self, forCellWithReuseIdentifier: "passwordOnboardingCollectionViewCell")
        collectionView.register(ProfilePictureOnboardingCollectionViewCell.self, forCellWithReuseIdentifier: "profilePictureOnboardingCollectionViewCell")
        
        //Appears to be helping fix the choppy scrolling that occurs when scrolling from the first to the second cell
        //Choppy scrolling appears to be caused by initializing two animationViews at the same time
        collectionView.dequeueReusableCell(withReuseIdentifier: "collabPreviewCollectionViewCell", for: IndexPath(item: 2, section: 0))
    }

    
    //MARK: - Configure Preview Previous Button
    
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
        previewPreviousButton.backgroundColor = UIColor(hexString: "AAAAAA")
        previewPreviousButton.tintColor = .white
        
        previewPreviousButton.layer.cornerRadius = 17.5
        previewPreviousButton.clipsToBounds = true
        
        previewPreviousButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        previewPreviousButton.setTitle("Prev", for: .normal)
        
        previewPreviousButton.addTarget(self, action: #selector(previewPreviousButtonPressed), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Preview Next Button
    
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
    
    
    //MARK: - Configure Preview Page Control
    
    private func configurePreviewPageControl () {
        
        self.view.addSubview(previewPageControl)
        previewPageControl.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            previewPageControl.bottomAnchor.constraint(equalTo: previewPreviousButton.topAnchor, constant: (keyWindow?.safeAreaInsets.bottom ?? 0) > 0 ? -30 : -20),
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
    
    
    //MARK: - Configure Progress Bar
    
    private func configureProgressBar () {
        
        self.view.addSubview(trackBar)
        trackBar.addSubview(progressBar)
        
        trackBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            trackBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: (keyWindow?.safeAreaInsets.top ?? 0) + 97.5),
            trackBar.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            trackBar.widthAnchor.constraint(equalToConstant: 150),
            trackBar.heightAnchor.constraint(equalToConstant: 15),
            
            progressBar.topAnchor.constraint(equalTo: trackBar.topAnchor, constant: 2),
            progressBar.bottomAnchor.constraint(equalTo: trackBar.bottomAnchor, constant: -2),
            progressBar.leadingAnchor.constraint(equalTo: trackBar.leadingAnchor, constant: 3),
        
        ].forEach({ $0.isActive = true })
        
        progressBarWidthConstraint = progressBar.widthAnchor.constraint(equalToConstant: 0)
        progressBarWidthConstraint?.isActive = true
        
        trackBar.alpha = 0
        trackBar.backgroundColor = UIColor(hexString: "F1F1F1")
        trackBar.layer.cornerRadius = 7.5
        trackBar.layer.cornerCurve = .continuous
        trackBar.clipsToBounds = true
        
        progressBar.backgroundColor = UIColor(hexString: "222222")
        progressBar.layer.cornerRadius = 5.5
        progressBar.layer.cornerCurve = .continuous
        progressBar.clipsToBounds = true
    }
    
    
    //MARK: - Configure Onboarding Previous Button
    
    private func configureOnboardingPreviousButton () {
        
        self.view.addSubview(onboardingPreviousButton)
        onboardingPreviousButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            onboardingPreviousButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 5),
            onboardingPreviousButton.trailingAnchor.constraint(equalTo: progressBar.leadingAnchor, constant: -5),
            onboardingPreviousButton.centerYAnchor.constraint(equalTo: trackBar.centerYAnchor, constant: 0),
            onboardingPreviousButton.heightAnchor.constraint(equalToConstant: 50)
        
        ].forEach({ $0.isActive = true })
        
        onboardingPreviousButton.isEnabled = false
        onboardingPreviousButton.alpha = 0
        onboardingPreviousButton.tintColor = .black
        
        onboardingPreviousButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        onboardingPreviousButton.setTitle("Prev", for: .normal)
        
        onboardingPreviousButton.addTarget(self, action: #selector(onboardingPreviousButtonPressed), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Onboarding Next Button
    
    private func configureOnboardingNextButton () {
        
        self.view.addSubview(onboardingNextButton)
        onboardingNextButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            onboardingNextButton.leadingAnchor.constraint(equalTo: trackBar.trailingAnchor, constant: -5),
            onboardingNextButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5),
            onboardingNextButton.centerYAnchor.constraint(equalTo: trackBar.centerYAnchor, constant: 0),
            onboardingNextButton.heightAnchor.constraint(equalToConstant: 50)
        
        ].forEach({ $0.isActive = true })
        
        onboardingNextButton.alpha = 0
        onboardingNextButton.tintColor = .black
        
        onboardingNextButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        onboardingNextButton.setTitle("Next", for: .normal)
        
        onboardingNextButton.addTarget(self, action: #selector(onboardingNextButtonPressed), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Your Turn Label
    
    private func configureYourTurnLabel () {
        
        self.view.addSubview(yourTurnLabel)
        yourTurnLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            yourTurnLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
            yourTurnLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50),
            yourTurnLabel.topAnchor.constraint(equalTo: gifImageView.bottomAnchor, constant: 0),
            yourTurnLabel.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        yourTurnLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        yourTurnLabel.alpha = 0
        yourTurnLabel.numberOfLines = 2
        yourTurnLabel.adjustsFontSizeToFitWidth = true
        yourTurnLabel.font = UIFont(name: "Poppins-SemiBold", size: 37.5)
        yourTurnLabel.textAlignment = .center
        yourTurnLabel.text = "Now it's your\nturn!"
    }
    
    
    //MARK: - CollectionView Reconfigurations
    
    private func reconfigureCollectionViewForOnboarding () {
        
        collectionViewTopAnchor?.constant = (keyWindow?.safeAreaInsets.top ?? 0) + 130

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: itemHeightForOnboardingCells)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.estimatedItemSize = CGSize(width: 0, height: 0)

        registrationCollectionView.collectionViewLayout = layout

        registrationCollectionView.scrollToItem(at: IndexPath(item: 3, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    internal func reconfigureCollectionViewLayoutForProfilePicture () {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: itemHeightForProfilePictureCell)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.estimatedItemSize = CGSize(width: 0, height: 0)

        registrationCollectionView.collectionViewLayout = layout
    }
    
    
    //MARK: - Start Button Pressed
    
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
            
            self.previewPageControl.alpha = 1
            self.previewPreviousButton.alpha = 1
            self.previewNextButton.alpha = 1
            
        } completion: { (finished: Bool) in
            
            self.welcomeLabelsContainer.removeFromSuperview()
            self.startButton.removeFromSuperview()
        }
    }
    
    
    //MARK: - Preview Previous Button Pressed
    
    @objc private func previewPreviousButtonPressed () {
        
        if let indexPathForFirstVisibleItem = registrationCollectionView.indexPathsForVisibleItems.first, let visibleCell = registrationCollectionView.cellForItem(at: indexPathForFirstVisibleItem) {
            
            //Stops the animation in the visible preview cell
            if let cell = visibleCell as? BlockPreviewCollectionViewCell {

                cell.animationView.pause()
            }

            else if let cell = visibleCell as? MessagingPreviewCollectionViewCell {

                cell.animationView.pause()
            }

            else if let cell = visibleCell as? CollabPreviewCollectionViewCell {

                cell.animationView.pause()
            }
            
            registrationCollectionView.scrollToItem(at: IndexPath(item: indexPathForFirstVisibleItem.row - 1, section: 0), at: .centeredHorizontally, animated: true)
            
            previewPageControl.currentPage = indexPathForFirstVisibleItem.row - 1
            
            //If the current indexPath's row is the row before the row of the first preview cell
            if indexPathForFirstVisibleItem.row == 1 {
                
                UIView.transition(with: previewPreviousButton, duration: 0.25, options: .transitionCrossDissolve) {
                    
                    self.previewPreviousButton.isEnabled = false
                    self.previewPreviousButton.backgroundColor = UIColor(hexString: "AAAAAA")
                }
            }
        }
    }
    
    
    //MARK: - Preview Next Button Pressed
    
    @objc private func previewNextButtonPressed () {
        
        if let indexPathForFirstVisibleItem = registrationCollectionView.indexPathsForVisibleItems.first, let visibleCell = registrationCollectionView.cellForItem(at: indexPathForFirstVisibleItem) {
            
            //Stops the animation in the visible preview cell
            if let cell = visibleCell as? BlockPreviewCollectionViewCell {

                cell.animationView.pause()
            }

            else if let cell = visibleCell as? MessagingPreviewCollectionViewCell {

                cell.animationView.pause()
            }

            else if let cell = visibleCell as? CollabPreviewCollectionViewCell {

                cell.animationView.pause()
            }
            
            //Scrolling to the next cell
            if indexPathForFirstVisibleItem.row == 0 {
                
                UIView.transition(with: previewPreviousButton, duration: 0.25, options: .transitionCrossDissolve) {
                    
                    self.previewPreviousButton.isEnabled = true
                    self.previewPreviousButton.backgroundColor = UIColor(hexString: "222222")
                }

                registrationCollectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: true)
                previewPageControl.currentPage = 1
            }
            
            else if indexPathForFirstVisibleItem.row == 1 {
                
                registrationCollectionView.scrollToItem(at: IndexPath(item: 2, section: 0), at: .centeredHorizontally, animated: true)
                previewPageControl.currentPage = 2
            }
            
            else if indexPathForFirstVisibleItem.row == 2 {
                
                //Animating the transition from the preview section of the registration process
                //to the onboarding section of the registration process
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {

                    self.registrationCollectionView.alpha = 0
                    self.previewPageControl.alpha = 0
                    self.previewPreviousButton.alpha = 0
                    self.previewNextButton.alpha = 0

                } completion: { (finished: Bool) in

                    self.previewPageControl.removeFromSuperview()
                    self.previewPreviousButton.removeFromSuperview()
                    self.previewNextButton.removeFromSuperview()

                    self.reconfigureCollectionViewForOnboarding()
                    
                    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 1, options: .curveEaseInOut) {

                        self.yourTurnLabel.alpha = 1
                        self.yourTurnLabel.transform = .identity //The yourTurn label is scaled to half of it's original size when configured

                    } completion: { (finished: Bool) in
                        
                        UIView.animate(withDuration: 0.75, delay: 1.75, options: .curveEaseInOut) {
        
                            self.yourTurnLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                            self.yourTurnLabel.alpha = 0
        
                            self.trackBar.alpha = 1
                            self.onboardingPreviousButton.alpha = 1
                            self.onboardingNextButton.alpha = 1
                            self.registrationCollectionView.alpha = 1
        
                        } completion: { (finished: Bool) in
        
                            self.yourTurnLabel.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
    
    
    //MARK: - Onboarding Previous Button Pressed
    
    @objc private func onboardingPreviousButtonPressed () {
        
        dismissKeyboard()
        
        //Email Onboarding Cell
        if progressBarWidthConstraint?.constant == 36 {
            
            progressBarWidthConstraint?.constant = 0
            
            UIView.animate(withDuration: 0.5) {
                
                self.view.layoutIfNeeded()
            }
            
            UIView.transition(with: onboardingPreviousButton, duration: 0.25, options: .transitionCrossDissolve) {
                
                self.onboardingPreviousButton.isEnabled = false
            }
            
            registrationCollectionView.scrollToItem(at: IndexPath(row: 3, section: 0), at: .centeredHorizontally, animated: true)
        }
        
        //Username Onboarding Cell
        else if progressBarWidthConstraint?.constant == 72 {
            
            progressBarWidthConstraint?.constant = signingUpWithApple ? 0 : 36
            
            UIView.animate(withDuration: 0.5) {
                
                self.view.layoutIfNeeded()
            }
            
            if signingUpWithApple {
                
                registrationCollectionView.scrollToItem(at: IndexPath(row: 3, section: 0), at: .centeredHorizontally, animated: true)
            }
            
            else {
                
                registrationCollectionView.scrollToItem(at: IndexPath(row: 4, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
        
        //Password Onboarding Cell
        else if progressBarWidthConstraint?.constant == 108 {
            
            progressBarWidthConstraint?.constant = 72
            
            UIView.animate(withDuration: 0.5) {
                
                self.view.layoutIfNeeded()
            }
            
            onboardingNextButton.setTitle("Next", for: .normal) //Is set to "Done" when this cell is present, so it has to be changed back to "Next"
            
            registrationCollectionView.scrollToItem(at: IndexPath(row: 5, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    
    //MARK: - Onboarding Next Button Pressed
    
    @objc private func onboardingNextButtonPressed () {
        
        dismissKeyboard()
        
        if let indexPathForVisibleItem = registrationCollectionView.indexPathsForVisibleItems.first {
            
            //Scrolling of the collectionView will be done in the validation methods
            if let cell = registrationCollectionView.cellForItem(at: indexPathForVisibleItem) as? NameOnboardingCollectionViewCell {

                validateName(cell)
            }
            
            else if let cell = registrationCollectionView.cellForItem(at: indexPathForVisibleItem) as? EmailOnboardingCollectionViewCell {
                
                validateEmail(cell)
            }
            
            else if let cell = registrationCollectionView.cellForItem(at: indexPathForVisibleItem) as? UsernameOnboardingCollectionViewCell {
                
                validateUsername(cell)
            }
            
            else if let cell = registrationCollectionView.cellForItem(at: indexPathForVisibleItem) as? PasswordOnboardingCollectionViewCell {
                
                validatePassword(cell)
            }
        }
    }

    
    //MARK: - Sign In Button Pressed
    
    @objc private func signInButtonPressed () {
        
        if let viewController = logInViewController as? LogInViewController {
            
            viewController.view.subviews.forEach({ $0.alpha = 0 })
            
            //Animating the dismissal of this view
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
                
                self.view.subviews.forEach({ $0.alpha = 0 })
                
            } completion: { (finished: Bool) in
                
                self.dismiss(animated: false) {
                    
                    //Will animate the alpha of every subview in the LogInViewController
                    UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
                        
                        viewController.view.subviews.forEach({ $0.alpha = 1 })
                    }
                }
            }
        }
    }
    
    
    //MARK: - Dismiss Keyboard
    
    @objc private func dismissKeyboard () {
        
        if let indexPathForVisibleItem = registrationCollectionView.indexPathsForVisibleItems.first {
            
            if let cell = registrationCollectionView.cellForItem(at: indexPathForVisibleItem) as? NameOnboardingCollectionViewCell {
                
                cell.firstNameTextField.resignFirstResponder()
                cell.lastNameTextField.resignFirstResponder()
            }
            
            else if let cell = registrationCollectionView.cellForItem(at: indexPathForVisibleItem) as? EmailOnboardingCollectionViewCell {
                
                cell.emailTextField.resignFirstResponder()
            }
            
            else if let cell = registrationCollectionView.cellForItem(at: indexPathForVisibleItem) as? UsernameOnboardingCollectionViewCell {
                
                cell.usernameTextField.resignFirstResponder()
            }
            
            else if let cell = registrationCollectionView.cellForItem(at: indexPathForVisibleItem) as? PasswordOnboardingCollectionViewCell {
                
                cell.passwordTextField.resignFirstResponder()
            }
        }
    }
    
    
    //MARK: - Move to Home View
    
    private func moveToHomeView () {
        
        if let viewController = logInViewController as? LogInViewController {
            
            //Performing the segue to the homeViewController from the LogInViewController
            viewController.performSegue(withIdentifier: "moveToHomeViewWithoutAnimation", sender: self)

            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {

                self.view.subviews.forEach({ $0.alpha = 0 })

            } completion: { (finished: Bool) in

                if let homeViewController = viewController.navigationController?.viewControllers.first(where: { $0 as? HomeViewController != nil }) as? HomeViewController {
                    
                    homeViewController.headerView.alpha = 0
                    homeViewController.animationView.alpha = 0
                    homeViewController.calendarButton.alpha = 0
                    
                    self.dismiss(animated: false) {

                        homeViewController.animateEntryToViewFromRegistration()
                    }
                }
            }
        }
    }
}


//MARK: - CollectionView DataSource and Delegate Methods

extension RegistrationViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if signingUpWithApple {
            
            return 6
        }
        
        else {
            
            return 8
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "blockPreviewCollectionViewCell", for: indexPath) as! BlockPreviewCollectionViewCell
        
            return cell
        }
        
        else if indexPath.row == 1 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messagingPreviewCollectionViewCell", for: indexPath) as! MessagingPreviewCollectionViewCell
            
            return cell
        }
        
        else if indexPath.row == 2 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collabPreviewCollectionViewCell", for: indexPath) as! CollabPreviewCollectionViewCell
            
            return cell
        }
        
        else if indexPath.row == 3 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nameOnboardingCollectionViewCell", for: indexPath) as! NameOnboardingCollectionViewCell
            
            cell.nameRegistrationDelegate = self
            
            cell.firstNameTextField.text = newUser.firstName
            cell.lastNameTextField.text = newUser.lastName
            
            return cell
        }
        
        else if indexPath.row == 4 {
            
            if signingUpWithApple {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "usernameOnboardingCollectionViewCell", for: indexPath) as! UsernameOnboardingCollectionViewCell
                
                cell.userFirstName = newUser.firstName
                
                cell.usernameRegistrationDelegate = self
                
                return cell
            }
            
            else {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emailOnboardingCollectionViewCell", for: indexPath) as! EmailOnboardingCollectionViewCell
                
                cell.emailAddressRegistrationDelegate = self
                
                return cell
            }
        }
        
        else if indexPath.row == 5 {
            
            if signingUpWithApple {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profilePictureOnboardingCollectionViewCell", for: indexPath) as! ProfilePictureOnboardingCollectionViewCell
                
                cell.itemHeight = itemHeightForProfilePictureCell
                
                cell.profilePictureRegistrationDelegate = self
                
                return cell
            }
            
            else {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "usernameOnboardingCollectionViewCell", for: indexPath) as! UsernameOnboardingCollectionViewCell
                
                cell.userFirstName = newUser.firstName
                
                cell.usernameRegistrationDelegate = self
                
                return cell
            }
        }
        
        else if indexPath.row == 6 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "passwordOnboardingCollectionViewCell", for: indexPath) as! PasswordOnboardingCollectionViewCell
            
            cell.passwordRegistrationDelegate = self
            
            return cell 
        }
        
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profilePictureOnboardingCollectionViewCell", for: indexPath) as! ProfilePictureOnboardingCollectionViewCell
            
            cell.itemHeight = itemHeightForProfilePictureCell
            
            cell.profilePictureRegistrationDelegate = self
            
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if let cell = cell as? BlockPreviewCollectionViewCell {

            cell.animationView.play()
        }

        else if let cell = cell as? MessagingPreviewCollectionViewCell {

            cell.animationView.play()
        }

        else if let cell = cell as? CollabPreviewCollectionViewCell {

            cell.animationView.play()
        }
    }
}


//MARK: - Name Registration Protocol Extension

extension RegistrationViewController: NameRegistration {
    
    func firstNameEntered(firstName: String) {
        
        newUser.firstName = firstName
    }
    
    func lastNameEntered(lastName: String) {
        
        newUser.lastName = lastName
    }
}


//MARK: - Email Address Registration Protocol Extension

extension RegistrationViewController: EmailAddressRegistration {
    
    func emailAddressEntered (email: String) {
        
        newUser.email = email
    }
}


//MARK: - Username Registration Protocol Extension

extension RegistrationViewController: UsernameRegistration {
    
    func usernameEntered (username: String) {
        
        newUser.username = username
    }
}


//MARK: - Password Registration Protocol Extension

extension RegistrationViewController: PasswordRegistration {
    
    func passwordEntered (password: String) {
        
        newUser.password = password
    }
}


//MARK: - Profile Picture Registration Protocol Extension

extension RegistrationViewController: ProfilePictureRegistration {
    
    func addProfilePicture() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func skipProfilePicture() {
        
        moveToHomeView()
    }
}


//MARK: - UIImagePickerDelegate Extension

extension RegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImage: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            
            selectedImage = editedImage
        }
        
        else if let originalImage = info[.originalImage] as? UIImage {
            
            selectedImage = originalImage
        }
        
        if let image = selectedImage {
            
            let firebaseStorage = FirebaseStorage()
            firebaseStorage.saveProfilePictureToStorage(image)
            
            if let cell = registrationCollectionView.visibleCells.first as? ProfilePictureOnboardingCollectionViewCell {
                
                cell.profilePictureAdded(image)
            }
        }
        
        else {
            
            SVProgressHUD.showError(withStatus: "Sorry, something went wrong saving your profile picture")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
}
