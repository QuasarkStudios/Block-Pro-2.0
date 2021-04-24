//
//  LogInViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/20/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import BEMCheckBox

class LogInViewController: UIViewController {

    let illustrationBackgroundView = UIView()
    let zoomingIllustrationImageView = UIImageView(image: UIImage(named: "Launch-Log In Screen Illustration (Scaled)"))
    let illustrationImageView = UIImageView(image: UIImage(named: "Launch-Log In Screen Illustration (Scaled)"))
    
    let stackViewContainer = UIView()
    let buttonStackView = UIStackView()
    let textFieldStackView = UIStackView()
    
    let signInWithEmailButton = UIButton(type: .custom)
    
    let orLabel = UILabel()
    
    let signInWithAppleButton = UIButton(type: .custom)
    let appleLogo = UIImageView(image: UIImage(systemName: "applelogo"))
    let signInWithAppleLabel = UILabel()
    
    let signInWithGoogleButton = UIButton()
    let googleLogo = UIImageView(image: UIImage(named: "google-logo"))
    let signInWithGoogleLabel = UILabel()
    
    
    let signUpButton = UIButton(type: .system)
    
    let emailTextFieldContainer = UIView()
    let emailTextField = UITextField()
    
    let passwordTextFieldContainer = UIView()
    let passwordTextField = UITextField()
    
    let signInButtonContainer = UIView()
    let signInButton = UIButton(type: .custom)
    let cancelButton = UIButton(type: .custom)
    
    var illustrationTopAnchorConstant: CGFloat {
        
        return (keyWindow?.safeAreaInsets.top ?? 0) + 20
    }
    
    var illustrationViewMaximumHeight: CGFloat {
        
        return UIScreen.main.bounds.height - (((keyWindow?.safeAreaInsets.bottom ?? 0) + 326) + illustrationTopAnchorConstant)
    }
    
    var buttonAnimationCompleted: Bool = false
    
    var zoomingIllustrationImageViewTopAnchor: NSLayoutConstraint?
    var zoomingIllustrationImageViewWidthConstraint: NSLayoutConstraint?
    var zoomingIllustrationImageViewHeightConstraint: NSLayoutConstraint?
    
    var illustrationImageViewHeightConstraint: NSLayoutConstraint?
    
    var textFieldStackViewCenterYAnchor: NSLayoutConstraint?
    var textFieldStackViewTopAnchor: NSLayoutConstraint?
    
    var signInButtonLeadingAnchor: NSLayoutConstraint?
    var cancelButtonLeadingAnchor: NSLayoutConstraint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSignUpButton()
        
        configureIllustrationView()
        
        configureStackViewContainer()
        
        configureButtonStackView()
        configureTextFieldStackView()
        
        configureSignInWithEmailButton()
        configureOrLabel()
        configureSignInWithAppleContainer()
        configureSignInWithGoogleContainer()
        
        configureEmailTextFieldContainer()
        configureEmailTextField()
        
        configurePasswordTextFieldContainer()
        configurePasswordTextField()
        
        configureSignInButtonContainer()
        configureSignInButton()
        configureCancelButton()
        
        configureIllustrationBackgroundView()
        configureZoomingIllustrationImageView()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingPresented(notification:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingDismissed(notification:)), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if illustrationBackgroundView.superview != nil {
            
            
            animateSplashScreen()
        }
    }

    private func configureStackViewContainer () {
        
        self.view.addSubview(stackViewContainer)
        stackViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            stackViewContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            stackViewContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            stackViewContainer.topAnchor.constraint(equalTo: illustrationImageView.bottomAnchor, constant: 0),
            stackViewContainer.bottomAnchor.constraint(equalTo: signUpButton.topAnchor, constant: 0),
        
        ].forEach({ $0.isActive = true })
    }
    

    
    private func configureButtonStackView () {
        
        stackViewContainer.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            buttonStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            buttonStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            buttonStackView.centerYAnchor.constraint(equalTo: stackViewContainer.centerYAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })

        buttonStackView.axis = .vertical
        buttonStackView.distribution = .fillProportionally
        buttonStackView.alignment = .center
        buttonStackView.spacing = 30
        
        buttonStackView.addArrangedSubview(signInWithEmailButton)
        buttonStackView.addArrangedSubview(orLabel)
        buttonStackView.addArrangedSubview(signInWithAppleButton)
        buttonStackView.addArrangedSubview(signInWithGoogleButton)
        
        buttonStackView.setCustomSpacing(20, after: signInWithEmailButton)
        buttonStackView.setCustomSpacing(20, after: orLabel)
    }
    
    private func configureTextFieldStackView () {
        
        stackViewContainer.addSubview(textFieldStackView)
        textFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        
        textFieldStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        textFieldStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        
        textFieldStackViewCenterYAnchor = textFieldStackView.centerYAnchor.constraint(equalTo: stackViewContainer.centerYAnchor, constant: 0)
        textFieldStackViewCenterYAnchor?.isActive = true
        
        textFieldStackViewTopAnchor = textFieldStackView.topAnchor.constraint(equalTo: stackViewContainer.topAnchor, constant: 25)
        textFieldStackViewTopAnchor?.isActive = false
        
        textFieldStackView.isHidden = true
        textFieldStackView.axis = .vertical
        textFieldStackView.distribution = .fillEqually
        textFieldStackView.alignment = .center
        textFieldStackView.spacing = 30
        
        textFieldStackView.addArrangedSubview(emailTextFieldContainer)
        textFieldStackView.addArrangedSubview(passwordTextFieldContainer)
        textFieldStackView.addArrangedSubview(signInButtonContainer)
    }
    
    private func configureSignInWithEmailButton () {
        
        signInWithEmailButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            signInWithEmailButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 100),
            signInWithEmailButton.heightAnchor.constraint(equalToConstant: 44)
        
        ].forEach({ $0.isActive = true })
        
        signInWithEmailButton.backgroundColor = UIColor(hexString: "222222")
        signInWithEmailButton.tintColor = .white

        signInWithEmailButton.layer.cornerRadius = 22
        signInWithEmailButton.layer.cornerCurve = .continuous

        signInWithEmailButton.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        signInWithEmailButton.layer.shadowRadius = 2
        signInWithEmailButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        signInWithEmailButton.layer.shadowOpacity = 0.3

        signInWithEmailButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 15)
        signInWithEmailButton.setTitle("Sign in with E -mail", for: .normal)

        signInWithEmailButton.addTarget(self, action: #selector(buttonTouchDown(sender:)), for: .touchDown)
        signInWithEmailButton.addTarget(self, action: #selector(buttonTouchDragExit(sender:)), for: .touchDragExit)
        signInWithEmailButton.addTarget(self, action: #selector(buttonTouchUpInside(sender:)), for: .touchUpInside)
    }
    
    private func configureOrLabel () {
        
        orLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            orLabel.widthAnchor.constraint(equalToConstant: 30),
            orLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        orLabel.font = UIFont(name: "Poppins-SemiBold", size: 17)
        orLabel.textAlignment = .center
        orLabel.text = "or"
    }
    
    private func configureSignInWithAppleContainer () {
        
        signInWithAppleButton.addSubview(appleLogo)
        signInWithAppleButton.addSubview(signInWithAppleLabel)
        
        signInWithAppleButton.translatesAutoresizingMaskIntoConstraints = false
        appleLogo.translatesAutoresizingMaskIntoConstraints = false
        signInWithAppleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            signInWithAppleButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 100),
            signInWithAppleButton.heightAnchor.constraint(equalToConstant: 46),
            
            appleLogo.leadingAnchor.constraint(equalTo: signInWithAppleButton.leadingAnchor, constant: 20),
            appleLogo.centerYAnchor.constraint(equalTo: signInWithAppleButton.centerYAnchor, constant: 0),
            appleLogo.widthAnchor.constraint(equalToConstant: 25),
            appleLogo.heightAnchor.constraint(equalToConstant: 25),
            
            signInWithAppleLabel.leadingAnchor.constraint(equalTo: signInWithAppleButton.leadingAnchor, constant: (UIScreen.main.bounds.width - 100) > 250 ? 20 : 55),
            signInWithAppleLabel.trailingAnchor.constraint(equalTo: signInWithAppleButton.trailingAnchor, constant: -10),
            signInWithAppleLabel.topAnchor.constraint(equalTo: signInWithAppleButton.topAnchor, constant: 1),
            signInWithAppleLabel.bottomAnchor.constraint(equalTo: signInWithAppleButton.bottomAnchor, constant: -1)
        
        ].forEach({ $0.isActive = true })
        
        signInWithAppleButton.backgroundColor = .white
        
        signInWithAppleButton.layer.borderWidth = 1
        signInWithAppleButton.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        signInWithAppleButton.layer.cornerRadius = 23
        signInWithAppleButton.layer.cornerCurve = .continuous
        signInWithAppleButton.clipsToBounds = true
        
        appleLogo.isUserInteractionEnabled = false
        appleLogo.contentMode = .scaleAspectFit
        appleLogo.tintColor = .black
        
        signInWithAppleLabel.isUserInteractionEnabled = false
        signInWithAppleLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
        signInWithAppleLabel.adjustsFontSizeToFitWidth = true
        signInWithAppleLabel.textAlignment = (UIScreen.main.bounds.width - 100) > 250 ? .center : .left
        signInWithAppleLabel.text = "Sign in with Apple"
        
        signInWithAppleButton.addTarget(self, action: #selector(buttonTouchDown(sender:)), for: .touchDown)
        signInWithAppleButton.addTarget(self, action: #selector(buttonTouchDragExit(sender:)), for: .touchDragExit)
        signInWithAppleButton.addTarget(self, action: #selector(buttonTouchUpInside(sender:)), for: .touchUpInside)
    }
    
    private func configureSignInWithGoogleContainer () {
        
        signInWithGoogleButton.addSubview(googleLogo)
        signInWithGoogleButton.addSubview(signInWithGoogleLabel)
        
        signInWithGoogleButton.translatesAutoresizingMaskIntoConstraints = false
        googleLogo.translatesAutoresizingMaskIntoConstraints = false
        signInWithGoogleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            signInWithGoogleButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 100),
            signInWithGoogleButton.heightAnchor.constraint(equalToConstant: 46),
            
            googleLogo.leadingAnchor.constraint(equalTo: signInWithGoogleButton.leadingAnchor, constant: 20),
            googleLogo.centerYAnchor.constraint(equalTo: signInWithGoogleButton.centerYAnchor, constant: 0),
            googleLogo.widthAnchor.constraint(equalToConstant: 25),
            googleLogo.heightAnchor.constraint(equalToConstant: 25),
            
            signInWithGoogleLabel.leadingAnchor.constraint(equalTo: signInWithGoogleButton.leadingAnchor, constant: (UIScreen.main.bounds.width - 100) > 250 ? 20 : 55),
            signInWithGoogleLabel.trailingAnchor.constraint(equalTo: signInWithGoogleButton.trailingAnchor, constant: -10),
            signInWithGoogleLabel.topAnchor.constraint(equalTo: signInWithGoogleButton.topAnchor, constant: 1),
            signInWithGoogleLabel.bottomAnchor.constraint(equalTo: signInWithGoogleButton.bottomAnchor, constant: -1)
        
        ].forEach({ $0.isActive = true })
        
        signInWithGoogleButton.backgroundColor = .white
        
        signInWithGoogleButton.layer.borderWidth = 1
        signInWithGoogleButton.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        signInWithGoogleButton.layer.cornerRadius = 23
        signInWithGoogleButton.layer.cornerCurve = .continuous
        signInWithGoogleButton.clipsToBounds = true
        
        googleLogo.isUserInteractionEnabled = false
        googleLogo.contentMode = .scaleAspectFit
        googleLogo.tintColor = .black
        
        signInWithGoogleLabel.isUserInteractionEnabled = false
        signInWithGoogleLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
        signInWithGoogleLabel.adjustsFontSizeToFitWidth = true
        signInWithGoogleLabel.textAlignment = (UIScreen.main.bounds.width - 100) > 250 ? .center : .left
        signInWithGoogleLabel.text = "Sign in with Google"
        
        signInWithGoogleButton.addTarget(self, action: #selector(buttonTouchDown(sender:)), for: .touchDown)
        signInWithGoogleButton.addTarget(self, action: #selector(buttonTouchDragExit(sender:)), for: .touchDragExit)
        signInWithGoogleButton.addTarget(self, action: #selector(buttonTouchUpInside(sender:)), for: .touchUpInside)
    }
    
    private func configureSignInButtonContainer () {
        
        signInButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            signInButtonContainer.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 100),
            signInButtonContainer.heightAnchor.constraint(equalToConstant: 46)
        
        ].forEach({ $0.isActive = true })
    }
    
    private func configureSignInButton () {
        
        signInButtonContainer.addSubview(signInButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            signInButton.trailingAnchor.constraint(equalTo: signInButtonContainer.trailingAnchor, constant: -5),
            signInButton.centerYAnchor.constraint(equalTo: signInButtonContainer.centerYAnchor, constant: 0),
            signInButton.heightAnchor.constraint(equalToConstant: 44)
        
        ].forEach({ $0.isActive = true })
        
        signInButtonLeadingAnchor = signInButton.leadingAnchor.constraint(equalTo: signInButtonContainer.leadingAnchor, constant: 0)
        signInButtonLeadingAnchor?.isActive = true
        
        signInButton.backgroundColor = UIColor(hexString: "222222")
        signInButton.tintColor = .white

        signInButton.layer.cornerRadius = 22
        signInButton.layer.cornerCurve = .continuous

        signInButton.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        signInButton.layer.shadowRadius = 2
        signInButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        signInButton.layer.shadowOpacity = 0.3

        signInButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 15)
        signInButton.setTitle("Sign In", for: .normal)

        signInButton.addTarget(self, action: #selector(buttonTouchDown(sender:)), for: .touchDown)
        signInButton.addTarget(self, action: #selector(buttonTouchDragExit(sender:)), for: .touchDragExit)
        signInButton.addTarget(self, action: #selector(buttonTouchUpInside(sender:)), for: .touchUpInside)
    }
    
    private func configureCancelButton () {
        
        signInButtonContainer.insertSubview(cancelButton, belowSubview: signInButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            cancelButton.centerYAnchor.constraint(equalTo: signInButton.centerYAnchor, constant: 0),
            cancelButton.widthAnchor.constraint(equalToConstant: 36),
            cancelButton.heightAnchor.constraint(equalToConstant: 36)
        
        ].forEach({ $0.isActive = true })
        
        cancelButtonLeadingAnchor = cancelButton.leadingAnchor.constraint(equalTo: signInButtonContainer.leadingAnchor, constant: (UIScreen.main.bounds.width / 2) - 18)
        cancelButtonLeadingAnchor?.isActive = true
        
        cancelButton.alpha = 0
        cancelButton.backgroundColor = UIColor(hexString: "222222")
        cancelButton.tintColor = .white
        cancelButton.adjustsImageWhenHighlighted = false
        
        cancelButton.layer.cornerRadius = 18
        cancelButton.layer.cornerCurve = .continuous
        
        cancelButton.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        cancelButton.layer.shadowRadius = 2
        cancelButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        cancelButton.layer.shadowOpacity = 0.3
        
        cancelButton.setImage(UIImage(named: "plus 2")?.withRenderingMode(.alwaysTemplate), for: .normal)
        cancelButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        cancelButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
        
        cancelButton.addTarget(self, action: #selector(buttonTouchDown(sender:)), for: .touchDown)
        cancelButton.addTarget(self, action: #selector(buttonTouchDragExit(sender:)), for: .touchDragExit)
        cancelButton.addTarget(self, action: #selector(buttonTouchUpInside(sender:)), for: .touchUpInside)
    }
    
    private func configureSignUpButton () {
        
        self.view.addSubview(signUpButton)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            signUpButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            signUpButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            signUpButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            signUpButton.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        let lightGrayText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 14) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        let blackText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 14) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        let attributedString = NSMutableAttributedString(string: "")
        
        attributedString.append(NSAttributedString(string: "Don't have an account?  ", attributes: lightGrayText))
        attributedString.append(NSAttributedString(string: "Sign Up!", attributes: blackText))
        
        signUpButton.setAttributedTitle(attributedString, for: .normal)
    }
    
    private func configureIllustrationBackgroundView () {
        
        self.view.addSubview(illustrationBackgroundView)
        illustrationBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            illustrationBackgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            illustrationBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            illustrationBackgroundView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            illustrationBackgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        illustrationBackgroundView.backgroundColor = UIColor(hexString: "222222")
    }
    
    private func configureIllustrationView () {
        
        let illustrationViewDimensions = calculateDimensionsOfIllustrationView()
        
        self.view.addSubview(illustrationImageView)
        illustrationImageView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            illustrationImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: (keyWindow?.safeAreaInsets.top ?? 0) + (keyWindow?.safeAreaInsets.top ?? 0 > 0 ? 20 : 0)),
            illustrationImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            illustrationImageView.widthAnchor.constraint(equalToConstant: illustrationViewDimensions)
        
        ].forEach({ $0.isActive = true })
        
        illustrationImageViewHeightConstraint = illustrationImageView.heightAnchor.constraint(equalToConstant: illustrationViewDimensions)
        illustrationImageViewHeightConstraint?.isActive = true
        
        illustrationImageView.isHidden = true
        illustrationImageView.contentMode = .scaleAspectFit
    }
    
    private func configureZoomingIllustrationImageView () {
        
        self.view.addSubview(zoomingIllustrationImageView)
        zoomingIllustrationImageView.translatesAutoresizingMaskIntoConstraints = false
        
        zoomingIllustrationImageViewTopAnchor = zoomingIllustrationImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: (UIScreen.main.bounds.height / 2) - 200)
//        illustrationImageViewBottomAnchor = illustrationImageView.bottomAnchor.constraint(equalTo: signInWithEmailButton.topAnchor, constant: -30)
        zoomingIllustrationImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        zoomingIllustrationImageViewWidthConstraint = zoomingIllustrationImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 80)
        zoomingIllustrationImageViewHeightConstraint = zoomingIllustrationImageView.heightAnchor.constraint(equalToConstant: 400)
        
        zoomingIllustrationImageViewTopAnchor?.isActive = true
        zoomingIllustrationImageViewWidthConstraint?.isActive = true
        zoomingIllustrationImageViewHeightConstraint?.isActive = true
        
        zoomingIllustrationImageView.contentMode = .scaleAspectFit
    }
    

    private func configurePasswordTextFieldContainer () {
        
        passwordTextFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            passwordTextFieldContainer.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 100),
            passwordTextFieldContainer.heightAnchor.constraint(equalToConstant: 46)
        
        ].forEach({ $0.isActive = true })
        
//        passwordTextFieldContainer.alpha = 0
        passwordTextFieldContainer.backgroundColor = .white
        
        passwordTextFieldContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        passwordTextFieldContainer.layer.borderWidth = 1

        passwordTextFieldContainer.layer.cornerRadius = 23//10
        passwordTextFieldContainer.layer.cornerCurve = .continuous
        passwordTextFieldContainer.clipsToBounds = true
    }
    
    private func configureEmailTextFieldContainer () {
        
        emailTextFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            emailTextFieldContainer.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 100),
            emailTextFieldContainer.heightAnchor.constraint(equalToConstant: 46)
        
        ].forEach({ $0.isActive = true })
        
//        emailAddressContainerTopAnchor?.isActive = true
        
//        emailTextFieldContainer.alpha = 0
        emailTextFieldContainer.backgroundColor = .white
        
        emailTextFieldContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        emailTextFieldContainer.layer.borderWidth = 1

        emailTextFieldContainer.layer.cornerRadius = 23//10
        emailTextFieldContainer.layer.cornerCurve = .continuous
        emailTextFieldContainer.clipsToBounds = true
    }
    
    private func configureEmailTextField () {
        
        emailTextFieldContainer.addSubview(emailTextField)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            emailTextField.leadingAnchor.constraint(equalTo: emailTextFieldContainer.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: emailTextFieldContainer.trailingAnchor, constant: -10),
            emailTextField.topAnchor.constraint(equalTo: emailTextFieldContainer.topAnchor, constant: 0),
            emailTextField.bottomAnchor.constraint(equalTo: emailTextFieldContainer.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
//        emailTextField.delegate = self
        
        emailTextField.borderStyle = .none
        emailTextField.font = UIFont(name: "Poppins-SemiBold", size: 15)
        emailTextField.placeholder = "E-mail Address"
        emailTextField.returnKeyType = .done
    }
    
    private func configurePasswordTextField () {
        
        passwordTextFieldContainer.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            passwordTextField.leadingAnchor.constraint(equalTo: passwordTextFieldContainer.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: passwordTextFieldContainer.trailingAnchor, constant: -10),
            passwordTextField.topAnchor.constraint(equalTo: passwordTextFieldContainer.topAnchor, constant: 0),
            passwordTextField.bottomAnchor.constraint(equalTo: passwordTextFieldContainer.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
//        passwordTextField.delegate = self
        
        passwordTextField.borderStyle = .none
        passwordTextField.font = UIFont(name: "Poppins-SemiBold", size: 15)
        passwordTextField.placeholder = "Password"
        passwordTextField.returnKeyType = .done
    }
    
    private func calculateDimensionsOfIllustrationView () -> CGFloat {
        
        let topOfIllustrationView = (keyWindow?.safeAreaInsets.top ?? 0) + (keyWindow?.safeAreaInsets.top ?? 0 > 0 ? 20 : 0)
        let topOfSignUpButton = (keyWindow?.safeAreaInsets.bottom ?? 0) + 15 + 25
        
        //Maximum allowable height is the distance between topAnchor of the illustrationView and the top of the signUpButton plus an extra 40 point buffer for aesthetics
        let maximumAllowableHeightOfAllSubviews = UIScreen.main.bounds.height - topOfIllustrationView - topOfSignUpButton - 40
        
        if maximumAllowableHeightOfAllSubviews < (UIScreen.main.bounds.width - 40) + 226 {
            
            //Returns the maximumAllowableHeight of the illustrationView by subtracting the height of the buttonStackView
            return maximumAllowableHeightOfAllSubviews - 226
        }
        
        else {
            
            return UIScreen.main.bounds.width - 40
        }
    }
    
    private func animateSplashScreen () {
        
        zoomingIllustrationImageViewTopAnchor?.constant = (keyWindow?.safeAreaInsets.top ?? 0) + (keyWindow?.safeAreaInsets.top ?? 0 > 0 ? 20 : 0)
        zoomingIllustrationImageViewWidthConstraint?.constant = calculateDimensionsOfIllustrationView()
        
        zoomingIllustrationImageViewHeightConstraint?.constant = calculateDimensionsOfIllustrationView()
        
        UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
            
            self.illustrationBackgroundView.backgroundColor = .clear
            
        } completion: { (finished: Bool) in
            
            self.illustrationBackgroundView.removeFromSuperview()
            self.illustrationImageView.isHidden = false
            self.zoomingIllustrationImageView.isHidden = true
        }
    }
    
    @objc private func keyboardBeingPresented (notification: NSNotification) {
        
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSValue
        
        let illustrationViewTopAnchor = (keyWindow?.safeAreaInsets.top ?? 0) + (keyWindow?.safeAreaInsets.top ?? 0 > 0 ? 20 : 0)
        
        textFieldStackViewCenterYAnchor?.isActive = false
        textFieldStackViewTopAnchor?.isActive = true
        
        //147 is the height of the visible views in the textFieldStackView plus the 20 point topAnchor
        //25 is an extra buffer between the passwordTextField and the keyboard
        illustrationImageViewHeightConstraint?.constant = UIScreen.main.bounds.height - illustrationViewTopAnchor - keyboardFrame.cgRectValue.height - 147 - 25
        
        UIView.animate(withDuration: keyboardAnimationDuration as! Double, delay: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardBeingDismissed (notification: NSNotification) {
        
        let keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSValue
        
        textFieldStackViewTopAnchor?.isActive = false
        textFieldStackViewCenterYAnchor?.isActive = true
        
        illustrationImageViewHeightConstraint?.constant = calculateDimensionsOfIllustrationView()
        
        UIView.animate(withDuration: keyboardAnimationDuration as! Double, delay: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func buttonTouchDown (sender: UIButton) {
        
        let vibrationMethods = VibrateMethods()
        vibrationMethods.warningVibration()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
            
            if sender == self.cancelButton {
                
                sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9).rotated(by: CGFloat.pi / 4)
            }
            
            else {
                
                sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
        } completion: { (finished: Bool) in
            
            self.buttonAnimationCompleted = true
        }
    }
    
    @objc private func buttonTouchDragExit (sender: UIButton) {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            if sender == self.cancelButton {
                
                sender.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi / 4)
            }
            
            else {
                
                sender.transform = .identity
            }
        }
        
        buttonAnimationCompleted = false
    }
    
    @objc private func buttonTouchUpInside (sender: UIButton) {
        
        if sender == signInWithEmailButton {
            
            UIView.transition(from: buttonStackView, to: textFieldStackView, duration: 0.4, options: [.transitionCrossDissolve, .showHideTransitionViews]) { (finished: Bool) in
                
                sender.transform = .identity

                self.signInButtonLeadingAnchor?.constant = 100
                self.cancelButtonLeadingAnchor?.constant = 5

                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 1, options: .curveEaseInOut) {

                    self.view.layoutIfNeeded()

                    self.cancelButton.alpha = 1
                }
            }
        }
        
        else if sender == signInWithAppleButton {
            
            UIView.animate(withDuration: 0.3, delay: buttonAnimationCompleted ? 0 : 0.15, options: .curveEaseInOut) {
                
                sender.transform = .identity
                
            } completion: { (finished: Bool) in
                
                
            }

        }
        
        else if sender == signInWithGoogleButton {
            
            UIView.animate(withDuration: 0.3, delay: buttonAnimationCompleted ? 0 : 0.15, options: .curveEaseInOut) {
                
                sender.transform = .identity
                
            } completion: { (finished: Bool) in
                
                
            }
        }
        
        else if sender == cancelButton {
            
            signInButtonLeadingAnchor?.constant = 0
            cancelButtonLeadingAnchor?.constant = (UIScreen.main.bounds.width / 2) - 18
            
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut) {

                self.view.layoutIfNeeded()

                self.cancelButton.alpha = 0

            } completion: { (finished: Bool) in

                UIView.transition(from: self.textFieldStackView, to: self.buttonStackView, duration: 0.4, options: [.transitionCrossDissolve, .showHideTransitionViews]) { (finished: Bool) in

                    sender.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi / 4)
                }
            }
        }
        
        else if sender == signInButton {
            
            UIView.animate(withDuration: 0.3, delay: buttonAnimationCompleted ? 0 : 0.15, options: .curveEaseInOut) {
                
                sender.transform = .identity
                
            } completion: { (finished: Bool) in
                
                
            }
        }
        
        buttonAnimationCompleted = false
    }
    
    @objc private func dismissKeyboard () {
        
        self.view.endEditing(true)
    }
}
