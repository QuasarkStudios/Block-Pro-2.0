//
//  LogInViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/20/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import FirebaseAuth
import AuthenticationServices
import GoogleSignIn
import CryptoKit
import BEMCheckBox
import SVProgressHUD
import iProgressHUD

class LogInViewController: UIViewController {

    let splashScreenBackgroundView = UIView()
    let zoomingIllustrationImageView = UIImageView(image: UIImage(named: "Launch-Log In Screen Illustration (Scaled)"))
    let signingInProgressView = UIView()
    
    let illustrationImageView = UIImageView(image: UIImage(named: "Launch-Log In Screen Illustration (Scaled)"))
    
    let stackViewContainer = UIView()
    let buttonStackView = UIStackView()
    let textFieldStackView = UIStackView()
    
    let withEmailButton = UIButton(type: .custom)
    
    let orLabel = UILabel()
    
    let withAppleButton = UIButton(type: .custom)
    let appleLogo = UIImageView(image: UIImage(systemName: "applelogo"))
    let withAppleLabel = UILabel()
    
    let withGoogleButton = UIButton()
    let googleLogo = UIImageView(image: UIImage(named: "google-logo"))
    let withGoogleLabel = UILabel()
    
    let signUpButton = UIButton(type: .system)
    
    let emailTextFieldContainer = UIView()
    let emailTextField = UITextField()
    
    let passwordTextFieldContainer = UIView()
    let passwordTextField = UITextField()
    
    let signInButtonContainer = UIView()
    let signInButton = UIButton(type: .custom)
    let cancelButton = UIButton(type: .custom)
    
    let firebaseAuth = FirebaseAuthentication()

    var buttonAnimationCompleted: Bool = false
    
    var progressAttachedToSignInContainer: Bool = false
    var allowProgressToShow: Bool = false
    
    var userSigningUp: Bool = false
    var signingInWithApple: Bool = false
    var signingInWithGoogle: Bool = false
    
    var currentNonce: String?
    
    var zoomingIllustrationImageViewTopAnchor: NSLayoutConstraint?
    var zoomingIllustrationImageViewWidthConstraint: NSLayoutConstraint?
    var zoomingIllustrationImageViewHeightConstraint: NSLayoutConstraint?
    
    var illustrationImageViewHeightConstraint: NSLayoutConstraint?
    
    var textFieldStackViewCenterYAnchor: NSLayoutConstraint?
    var textFieldStackViewTopAnchor: NSLayoutConstraint?
    
    var signInButtonContainerHeightConstraint: NSLayoutConstraint?
    
    var signInButtonLeadingAnchor: NSLayoutConstraint?
    var signInButtonTrailingAnchor: NSLayoutConstraint?
    
    var cancelButtonLeadingAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        configureSplashScreenBackgroundView()
        configureZoomingIllustrationImageView()
        configureSigningInProgressView()
        
        configureIllustrationView()
        configureSignUpButton() //Call here
        
        configureStackViewContainer()
        configureButtonStackView()
        configureTextFieldStackView()
        
        configureWithEmailButton()
        configureOrLabel()
        configureWithAppleButton()
        configureWithGoogleButton()
        
        configureEmailTextFieldContainer()
        configureEmailTextField()
        
        configurePasswordTextFieldContainer()
        configurePasswordTextField()
        
        configureSignInButtonContainer()
        configureSignInButton()
        configureCancelButton()
        
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear)
        tabBarController?.tabBar.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingPresented(notification:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingDismissed(notification:)), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //If the user is already signed in
        if let currentUser = Auth.auth().currentUser {

            attachProgressAnimation(signingInProgressView)
            signingInProgressView.showProgress()

            //Will retrieve the data for the signed in user
            retrieveSignedInUserData(currentUser) { [weak self] (error, userDataFound) in
                
                if error != nil {
                    
                    print("error signing in user:", error?.localizedDescription as Any)
                    
                    self?.animateSplashScreen()
                }
                
                else {
                    
                    if userDataFound ?? false {
                        
                        //Ensures that if the user later logs out, the main illustrationImageView will be present
                        self?.illustrationImageView.isHidden = false
                        
                        self?.performSegue(withIdentifier: "moveToHomeView", sender: self)
                    }
                    
                    else {
                        
                        //Ensures that the splashScreen is still present on the screen
                        if self?.splashScreenBackgroundView.superview != nil {

                            self?.animateSplashScreen()
                        }
                    }
                }
            }
        }

        //Ensures that the splashScreen is still present on the screen
        else if splashScreenBackgroundView.superview != nil {

            animateSplashScreen()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.view.subviews.forEach({ $0.alpha = 1 })
        
        if splashScreenBackgroundView.superview != nil || zoomingIllustrationImageView.superview != nil {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                self.splashScreenBackgroundView.alpha = 0
                self.zoomingIllustrationImageView.alpha = 0
                
            } completion: { (finished: Bool) in
                
                self.splashScreenBackgroundView.removeFromSuperview()
                self.zoomingIllustrationImageView.removeFromSuperview()
                self.signingInProgressView.removeFromSuperview()
            }
        }
        
        emailTextField.text = ""
        passwordTextField.text = ""
        animateSignInButton(shrink: false)
        revertBackToSignInOptions()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: - Configure Splash Screen Background View
    
    private func configureSplashScreenBackgroundView () {
        
        if let window = keyWindow {
            
            window.addSubview(splashScreenBackgroundView)
            splashScreenBackgroundView.translatesAutoresizingMaskIntoConstraints = false
    
            [
    
                splashScreenBackgroundView.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 0),
                splashScreenBackgroundView.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: 0),
                splashScreenBackgroundView.topAnchor.constraint(equalTo: window.topAnchor, constant: 0),
                splashScreenBackgroundView.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: 0)
    
            ].forEach({ $0.isActive = true })
    
            splashScreenBackgroundView.backgroundColor = UIColor(hexString: "222222")
        }
    }
    
    
    //MARK: - Configure Zooming Illustration Image View
    
    private func configureZoomingIllustrationImageView () {
        
        if let window = keyWindow {
            
            window.addSubview(zoomingIllustrationImageView)
            zoomingIllustrationImageView.translatesAutoresizingMaskIntoConstraints = false
            
            zoomingIllustrationImageView.centerXAnchor.constraint(equalTo: window.centerXAnchor, constant: 0).isActive = true
            
            zoomingIllustrationImageViewTopAnchor = zoomingIllustrationImageView.topAnchor.constraint(equalTo: window.topAnchor, constant: (UIScreen.main.bounds.height / 2) - ((UIScreen.main.bounds.width - 80) / 2))
            zoomingIllustrationImageViewWidthConstraint = zoomingIllustrationImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 80)
            zoomingIllustrationImageViewHeightConstraint = zoomingIllustrationImageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 80)
            
            zoomingIllustrationImageViewTopAnchor?.isActive = true
            zoomingIllustrationImageViewWidthConstraint?.isActive = true
            zoomingIllustrationImageViewHeightConstraint?.isActive = true
            
            zoomingIllustrationImageView.tag = 2
            zoomingIllustrationImageView.contentMode = .scaleAspectFit
        }
    }
    
    
    //MARK: - Configure Signing In Progress View
    
    private func configureSigningInProgressView () {
        
        if let window = keyWindow {
            
            window.addSubview(signingInProgressView)
            signingInProgressView.translatesAutoresizingMaskIntoConstraints = false
            
            [
            
                signingInProgressView.topAnchor.constraint(equalTo: window.topAnchor, constant: (UIScreen.main.bounds.height / 2) + ((UIScreen.main.bounds.width - 80) / 2) + 25),
                signingInProgressView.centerXAnchor.constraint(equalTo: window.centerXAnchor, constant: 0),
                signingInProgressView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
                signingInProgressView.heightAnchor.constraint(equalToConstant: 150)
            
            ].forEach({ $0.isActive = true })
        }
    }
    
    
    //MARK: - Configure Illustration View
    
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
    
    
    //MARK: - Configure Sign Up Button
    
    private func configureSignUpButton () {
        
        self.view.addSubview(signUpButton)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            signUpButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            signUpButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            signUpButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            signUpButton.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        setSignUpButtonText()
        
        signUpButton.addTarget(self, action: #selector(signUpButtonPressed), for: .touchUpInside)
    }
    
    
    //MARK: - Configure StackView Container
    
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
    

    //MARK: - Configure Button StackView
    
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
        
        buttonStackView.addArrangedSubview(withEmailButton)
        buttonStackView.addArrangedSubview(orLabel)
        buttonStackView.addArrangedSubview(withAppleButton)
        buttonStackView.addArrangedSubview(withGoogleButton)
        
        buttonStackView.setCustomSpacing(20, after: withEmailButton)
        buttonStackView.setCustomSpacing(20, after: orLabel)
    }
    
    
    //MARK: - Configure TextField StackView
    
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
        textFieldStackView.distribution = .fillProportionally//.fillEqually
        textFieldStackView.alignment = .center
        textFieldStackView.spacing = 30
        
        textFieldStackView.addArrangedSubview(emailTextFieldContainer)
        textFieldStackView.addArrangedSubview(passwordTextFieldContainer)
        textFieldStackView.addArrangedSubview(signInButtonContainer)
    }
    
    
    //MARK: - Configure With Email Button
    
    private func configureWithEmailButton () {
        
        withEmailButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            withEmailButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 100),
            withEmailButton.heightAnchor.constraint(equalToConstant: 44)
        
        ].forEach({ $0.isActive = true })
        
        withEmailButton.backgroundColor = UIColor(hexString: "222222")
        withEmailButton.tintColor = .white

        withEmailButton.layer.cornerRadius = 22
        withEmailButton.layer.cornerCurve = .continuous

        withEmailButton.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        withEmailButton.layer.shadowRadius = 2
        withEmailButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        withEmailButton.layer.shadowOpacity = 0.3

        withEmailButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 15)
        withEmailButton.setTitle("Sign In with E -mail", for: .normal)

        withEmailButton.addTarget(self, action: #selector(buttonTouchDown(sender:)), for: .touchDown)
        withEmailButton.addTarget(self, action: #selector(buttonTouchDragExit(sender:)), for: .touchDragExit)
        withEmailButton.addTarget(self, action: #selector(buttonTouchUpInside(sender:)), for: .touchUpInside)
    }
    
    
    //MARK: Configure Or Label
    
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
    
    
    //MARK: - Configure With Apple Button
    
    private func configureWithAppleButton () {
        
        withAppleButton.addSubview(appleLogo)
        withAppleButton.addSubview(withAppleLabel)
        
        withAppleButton.translatesAutoresizingMaskIntoConstraints = false
        appleLogo.translatesAutoresizingMaskIntoConstraints = false
        withAppleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            withAppleButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 100),
            withAppleButton.heightAnchor.constraint(equalToConstant: 46),
            
            appleLogo.leadingAnchor.constraint(equalTo: withAppleButton.leadingAnchor, constant: 20),
            appleLogo.centerYAnchor.constraint(equalTo: withAppleButton.centerYAnchor, constant: 0),
            appleLogo.widthAnchor.constraint(equalToConstant: 25),
            appleLogo.heightAnchor.constraint(equalToConstant: 25),
            
            withAppleLabel.leadingAnchor.constraint(equalTo: withAppleButton.leadingAnchor, constant: (UIScreen.main.bounds.width - 100) > 250 ? 20 : 55),
            withAppleLabel.trailingAnchor.constraint(equalTo: withAppleButton.trailingAnchor, constant: -10),
            withAppleLabel.topAnchor.constraint(equalTo: withAppleButton.topAnchor, constant: 1),
            withAppleLabel.bottomAnchor.constraint(equalTo: withAppleButton.bottomAnchor, constant: -1)
        
        ].forEach({ $0.isActive = true })
        
        withAppleButton.backgroundColor = .clear
        
        withAppleButton.layer.borderWidth = 1
        withAppleButton.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        withAppleButton.layer.cornerRadius = 23
        withAppleButton.layer.cornerCurve = .continuous
        withAppleButton.clipsToBounds = true
        
        appleLogo.isUserInteractionEnabled = false
        appleLogo.contentMode = .scaleAspectFit
        appleLogo.tintColor = .black
        
        withAppleLabel.isUserInteractionEnabled = false
        withAppleLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
        withAppleLabel.adjustsFontSizeToFitWidth = true
        withAppleLabel.textAlignment = (UIScreen.main.bounds.width - 100) > 250 ? .center : .left
        withAppleLabel.text = "Sign In with Apple"
        
        withAppleButton.addTarget(self, action: #selector(buttonTouchDown(sender:)), for: .touchDown)
        withAppleButton.addTarget(self, action: #selector(buttonTouchDragExit(sender:)), for: .touchDragExit)
        withAppleButton.addTarget(self, action: #selector(buttonTouchUpInside(sender:)), for: .touchUpInside)
    }
    
    
    //MARK: - Configure With Google Button
    
    private func configureWithGoogleButton () {
        
        withGoogleButton.addSubview(googleLogo)
        withGoogleButton.addSubview(withGoogleLabel)
        
        withGoogleButton.translatesAutoresizingMaskIntoConstraints = false
        googleLogo.translatesAutoresizingMaskIntoConstraints = false
        withGoogleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            withGoogleButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 100),
            withGoogleButton.heightAnchor.constraint(equalToConstant: 46),
            
            googleLogo.leadingAnchor.constraint(equalTo: withGoogleButton.leadingAnchor, constant: 20),
            googleLogo.centerYAnchor.constraint(equalTo: withGoogleButton.centerYAnchor, constant: 0),
            googleLogo.widthAnchor.constraint(equalToConstant: 25),
            googleLogo.heightAnchor.constraint(equalToConstant: 25),
            
            withGoogleLabel.leadingAnchor.constraint(equalTo: withGoogleButton.leadingAnchor, constant: (UIScreen.main.bounds.width - 100) > 250 ? 20 : 55),
            withGoogleLabel.trailingAnchor.constraint(equalTo: withGoogleButton.trailingAnchor, constant: -10),
            withGoogleLabel.topAnchor.constraint(equalTo: withGoogleButton.topAnchor, constant: 1),
            withGoogleLabel.bottomAnchor.constraint(equalTo: withGoogleButton.bottomAnchor, constant: -1)
        
        ].forEach({ $0.isActive = true })
        
        withGoogleButton.backgroundColor = .clear
        
        withGoogleButton.layer.borderWidth = 1
        withGoogleButton.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        withGoogleButton.layer.cornerRadius = 23
        withGoogleButton.layer.cornerCurve = .continuous
        withGoogleButton.clipsToBounds = true
        
        googleLogo.isUserInteractionEnabled = false
        googleLogo.contentMode = .scaleAspectFit
        googleLogo.tintColor = .black
        
        withGoogleLabel.isUserInteractionEnabled = false
        withGoogleLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
        withGoogleLabel.adjustsFontSizeToFitWidth = true
        withGoogleLabel.textAlignment = (UIScreen.main.bounds.width - 100) > 250 ? .center : .left
        withGoogleLabel.text = "Sign In with Google"
        
        withGoogleButton.addTarget(self, action: #selector(buttonTouchDown(sender:)), for: .touchDown)
        withGoogleButton.addTarget(self, action: #selector(buttonTouchDragExit(sender:)), for: .touchDragExit)
        withGoogleButton.addTarget(self, action: #selector(buttonTouchUpInside(sender:)), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Email TextField Container
    
    private func configureEmailTextFieldContainer () {
        
        emailTextFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            emailTextFieldContainer.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 100),
            emailTextFieldContainer.heightAnchor.constraint(equalToConstant: 46)
        
        ].forEach({ $0.isActive = true })
        
        emailTextFieldContainer.backgroundColor = .white
        
        emailTextFieldContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        emailTextFieldContainer.layer.borderWidth = 1

        emailTextFieldContainer.layer.cornerRadius = 23
        emailTextFieldContainer.layer.cornerCurve = .continuous
        emailTextFieldContainer.clipsToBounds = true
    }
    
    
    //MARK: - Configure Email TextField
    
    private func configureEmailTextField () {
        
        emailTextFieldContainer.addSubview(emailTextField)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            emailTextField.leadingAnchor.constraint(equalTo: emailTextFieldContainer.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: emailTextFieldContainer.trailingAnchor, constant: -10),
            emailTextField.topAnchor.constraint(equalTo: emailTextFieldContainer.topAnchor, constant: 0),
            emailTextField.bottomAnchor.constraint(equalTo: emailTextFieldContainer.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        emailTextField.delegate = self
        
        emailTextField.borderStyle = .none
        emailTextField.font = UIFont(name: "Poppins-SemiBold", size: 15)
        emailTextField.placeholder = "E-mail Address"
        emailTextField.returnKeyType = .done
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
    }
    
    
    //MARK: - Configure Password TextField Container
    
    private func configurePasswordTextFieldContainer () {
        
        passwordTextFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            passwordTextFieldContainer.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 100),
            passwordTextFieldContainer.heightAnchor.constraint(equalToConstant: 46)
        
        ].forEach({ $0.isActive = true })
        
        passwordTextFieldContainer.backgroundColor = .white
        
        passwordTextFieldContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        passwordTextFieldContainer.layer.borderWidth = 1

        passwordTextFieldContainer.layer.cornerRadius = 23
        passwordTextFieldContainer.layer.cornerCurve = .continuous
        passwordTextFieldContainer.clipsToBounds = true
    }
    
    
    //MARK: - Configure Password TextField
    
    private func configurePasswordTextField () {
        
        passwordTextFieldContainer.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            passwordTextField.leadingAnchor.constraint(equalTo: passwordTextFieldContainer.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: passwordTextFieldContainer.trailingAnchor, constant: -10),
            passwordTextField.topAnchor.constraint(equalTo: passwordTextFieldContainer.topAnchor, constant: 0),
            passwordTextField.bottomAnchor.constraint(equalTo: passwordTextFieldContainer.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        passwordTextField.delegate = self
        
        passwordTextField.borderStyle = .none
        passwordTextField.font = UIFont(name: "Poppins-SemiBold", size: 15)
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.returnKeyType = .done
    }
    
    
    //MARK: - Configure Sign In Button Container
    
    private func configureSignInButtonContainer () {
        
        signInButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        signInButtonContainer.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 100).isActive = true
        
        signInButtonContainerHeightConstraint = signInButtonContainer.heightAnchor.constraint(equalToConstant: 44)
        signInButtonContainerHeightConstraint?.isActive = true
    }
    
    
    //MARK: - Configure Sign In Button
    
    private func configureSignInButton () {
        
        signInButtonContainer.addSubview(signInButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            signInButton.topAnchor.constraint(equalTo: signInButtonContainer.topAnchor, constant: 0),
            signInButton.bottomAnchor.constraint(equalTo: signInButtonContainer.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        signInButtonLeadingAnchor = signInButton.leadingAnchor.constraint(equalTo: signInButtonContainer.leadingAnchor, constant: 5)
        signInButtonTrailingAnchor = signInButton.trailingAnchor.constraint(equalTo: signInButtonContainer.trailingAnchor, constant: -5)
        
        signInButtonLeadingAnchor?.isActive = true
        signInButtonTrailingAnchor?.isActive = true
        
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
    
    
    //MARK: - Configure Cancel Button
    
    private func configureCancelButton () {
        
        signInButtonContainer.insertSubview(cancelButton, belowSubview: signInButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            cancelButton.centerYAnchor.constraint(equalTo: signInButton.centerYAnchor, constant: 0),
            cancelButton.widthAnchor.constraint(equalToConstant: 36),
            cancelButton.heightAnchor.constraint(equalToConstant: 36)
        
        ].forEach({ $0.isActive = true })
        
        cancelButtonLeadingAnchor = cancelButton.leadingAnchor.constraint(equalTo: signInButtonContainer.leadingAnchor, constant: ((UIScreen.main.bounds.width / 2) - 100) - 18)
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
        cancelButton.addTarget(self, action: #selector(revertBackToSignInOptions), for: .touchUpInside)
    }
    
    
    //MARK: - Sign In User with Email
    
    private func signInUserWithEmail () {
        
        //If the email hasn't been entered
        if !(emailTextField.text?.leniantValidationOfTextEntered() ?? false) {
            
            SVProgressHUD.showError(withStatus: "Please enter your E-mail")
        }
        
        //If the password hasn't been entered
        else if !(passwordTextField.text?.leniantValidationOfTextEntered() ?? false) {
            
            SVProgressHUD.showError(withStatus: "Please enter your password")
        }
        
        else {
        
            allowProgressToShow = true
            animateSignInButton(shrink: true)
            
            signUpButton.isEnabled = false
            
            firebaseAuth.signInUserWithEmail(email: emailTextField.text ?? "", password: passwordTextField.text ?? "") { [weak self] (error, _) in

                if error != nil {

                    SVProgressHUD.showError(withStatus: error?.localizedDescription)

                    self?.allowProgressToShow = false
                    self?.animateSignInButton(shrink: false)
                }

                else {

                    self?.performSegue(withIdentifier: "moveToHomeView", sender: self)
                }

                self?.signUpButton.isEnabled = true
            }
        }
    }
    
    
    //MARK: - Retrieve Signed In User Data
    
    private func retrieveSignedInUserData (_ user: User, completion: @escaping ((_ error: Error?, _ userDataFound: Bool?) -> Void)) {
        
        firebaseAuth.retrieveSignedInUser(user) {(error, userDataFound) in
            
            if error != nil {
                
                completion(error, nil)
            }
            
            else {
                
                if userDataFound ?? false {
                    
                    completion(nil, true)
                }
                
                else {
                    
                    completion(nil, false)
                }
            }
        }
    }
    
    
    //MARK: - Animate Splash Screen
    
    private func animateSplashScreen () {
        
        zoomingIllustrationImageViewTopAnchor?.constant = (keyWindow?.safeAreaInsets.top ?? 0) + (keyWindow?.safeAreaInsets.top ?? 0 > 0 ? 20 : 0)
        zoomingIllustrationImageViewWidthConstraint?.constant = calculateDimensionsOfIllustrationView()
        zoomingIllustrationImageViewHeightConstraint?.constant = calculateDimensionsOfIllustrationView()
        
        if let window = keyWindow {
            
            UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: .curveEaseInOut) {
                
                window.layoutIfNeeded()
                
                self.splashScreenBackgroundView.backgroundColor = .clear
                
            } completion: { (finished: Bool) in
                
                self.illustrationImageView.isHidden = false
                
                self.splashScreenBackgroundView.removeFromSuperview()
                self.zoomingIllustrationImageView.removeFromSuperview()
                self.signingInProgressView.removeFromSuperview()
            }
        }
    }
    
    
    //MARK: - Attach Progress Animation
    
    private func attachProgressAnimation (_ view: UIView) {
        
        let iProgress: iProgressHUD = iProgressHUD()
        
        iProgress.isShowModal = false
        iProgress.isShowCaption = false
        iProgress.isTouchDismiss = false
        iProgress.boxColor = .clear
        
        iProgress.indicatorSize = view == signInButtonContainer ? 100 : 60
        
        iProgress.attachProgress(toView: view)
        
        if view == signInButtonContainer {
            
            view.updateIndicator(style: .ballClipRotate)
            progressAttachedToSignInContainer = true
        }
        
        else if view == signingInProgressView {
            
            view.updateIndicator(style: .ballRotateChase)
        }
    }
    
    
    //MARK: - Set Sign Up Button Text
    
    private func setSignUpButtonText () {
        
        let lightGrayText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 14) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        let blackText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 14) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        let attributedString = NSMutableAttributedString(string: "")
        
        attributedString.append(NSAttributedString(string: userSigningUp ? "Already have an account?  " : "Don't have an account?  ", attributes: lightGrayText))
        attributedString.append(NSAttributedString(string: userSigningUp ? "Sign In!" : "Sign Up!" , attributes: blackText))
        
        signUpButton.setAttributedTitle(attributedString, for: .normal)
    }
    

    //MARK: - Animate Sign In Button
    
    private func animateSignInButton (shrink: Bool) {
        
        if !shrink {
            
            signInButtonContainer.dismissProgress()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                
                UIView.transition(with: self.signInButton, duration: 0.2, options: .transitionCrossDissolve) {
                    
                    self.signInButton.setTitle("Sign In", for: .normal)
                }
            }
        }
        
        else {
            
            signInButton.setTitle("", for: .normal)
        }
        
        signInButtonContainerHeightConstraint?.constant = shrink ? 55 : 44
        
        signInButtonLeadingAnchor?.constant = shrink ? (UIScreen.main.bounds.width / 2) - 77.5 : 100
        signInButtonTrailingAnchor?.constant = shrink ? -((UIScreen.main.bounds.width / 2) - 77.5) : -5
        
        cancelButtonLeadingAnchor?.constant = shrink ? ((UIScreen.main.bounds.width / 2) - 100) - 18 : 5
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
            
            self.signInButton.layer.cornerRadius = shrink ? 27.5 : 22
            
            self.cancelButton.alpha = shrink ? 0 : 1
            
        } completion: { (finished: Bool) in
            
            if shrink {
                
                //Checks to see if iProgress has yet to be attached to the signInButton
                if !self.progressAttachedToSignInContainer {
                    
                    //Would be false if an error has been returned from the signInUser func before this animation has completed
                    if self.allowProgressToShow {
                        
                        self.attachProgressAnimation(self.signInButtonContainer)
                        
                        self.signInButtonContainer.showProgress()
                    }
                }

                else {

                    //Would be false if an error has been returned from the signInUser func before this animation has completed
                    if self.allowProgressToShow {
                        
                        self.signInButtonContainer.showProgress()
                    }
                }
            }
        }
    }
    
    
    //MARK: - Revert Back to Sign In Options
    
    @objc private func revertBackToSignInOptions () {
        
        signInButtonLeadingAnchor?.constant = 0
        cancelButtonLeadingAnchor?.constant = ((UIScreen.main.bounds.width / 2) - 100) - 18
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut) {

            self.view.layoutIfNeeded()

            self.cancelButton.alpha = 0

        } completion: { (finished: Bool) in

            UIView.transition(from: self.textFieldStackView, to: self.buttonStackView, duration: 0.4, options: [.transitionCrossDissolve, .showHideTransitionViews]) { (finished: Bool) in

                self.cancelButton.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi / 4)
            }
        }
    }
    
    
    //MARK: - Calculate Dimensions of Illustration View
    
    private func calculateDimensionsOfIllustrationView () -> CGFloat {
        
        let topOfIllustrationView = (keyWindow?.safeAreaInsets.top ?? 0) + (keyWindow?.safeAreaInsets.top ?? 0 > 0 ? 20 : 0)
        let topOfSignUpButton = (keyWindow?.safeAreaInsets.bottom ?? 0) + 15 + 25
        
        //Maximum allowable height is the distance between topAnchor of the illustrationView and the top of the signUpButton plus an extra 40 point buffer for aesthetics
        let maximumAllowableHeightOfAllSubviews = UIScreen.main.bounds.height - topOfIllustrationView - topOfSignUpButton - 40
        
        //(UIScreen.main.bounds.width - 40) = height of the illustrationImageView
        //226 = height of the buttonStackView
        if maximumAllowableHeightOfAllSubviews < (UIScreen.main.bounds.width - 40) + 226 {
            
            //Returns the maximumAllowableHeight of the illustrationView by subtracting the height of the buttonStackView
            return maximumAllowableHeightOfAllSubviews - 226
        }
        
        else {
            
            return UIScreen.main.bounds.width - 40
        }
    }
    

    //MARK: - Keyboard Being Presented
    
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
    
    
    //MARK: - Keyboard Being Dismissed
    
    @objc private func keyboardBeingDismissed (notification: NSNotification) {
        
        let keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSValue
        
        textFieldStackViewTopAnchor?.isActive = false
        textFieldStackViewCenterYAnchor?.isActive = true
        
        illustrationImageViewHeightConstraint?.constant = calculateDimensionsOfIllustrationView()
        
        UIView.animate(withDuration: keyboardAnimationDuration as! Double, delay: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
        }
    }
    
    
    //MARK: - Create AppleID Request
    
    private func createAppleIDRequest () -> ASAuthorizationAppleIDRequest {
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        
        return request
    }
    
    
    //MARK: - Sign in with Apple
    
    private func signInWithApple () {
        
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        authorizationController.performRequests()
    }
    
    
    //MARK: - Move to Registration View
    
    private func moveToRegistrationView (newUser: NewUser? = nil) {
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
            
            self.view.subviews.forEach({ $0.alpha = 0 })
            
        } completion: { (finished: Bool) in
            
            let registrationVC = RegistrationViewController()
            registrationVC.modalPresentationStyle = .fullScreen
            registrationVC.modalTransitionStyle = .crossDissolve

            //Will be non-nil if the user is signing in with Apple or Google
            if let newUser = newUser {
                
                registrationVC.newUser = newUser
            }
            
            registrationVC.signingUpWithApple = self.signingInWithApple
            registrationVC.signingUpWithGoogle = self.signingInWithGoogle
            
            registrationVC.logInViewController = self
            
            self.present(registrationVC, animated: false)
        }
    }

    
    //MARK: - Button Touch Down
    
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
    
    
    //MARK: - Button Touch Drag Exit
    
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
    
    
    //MARK: - Button Touch Up Inside
    
    @objc private func buttonTouchUpInside (sender: UIButton) {
        
        //Sign In with Email Button
        if sender == withEmailButton {
            
            if !userSigningUp {
                
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
            
            else {
                
                UIView.animate(withDuration: 0.3, delay: buttonAnimationCompleted ? 0 : 0.15, options: .curveEaseInOut) {
                    
                    sender.transform = .identity
                }
                
                signingInWithApple = false
                signingInWithGoogle = false
                self.moveToRegistrationView()
            }
        }
        
        //Sign In with Apple Button
        else if sender == withAppleButton {
            
            UIView.animate(withDuration: 0.3, delay: buttonAnimationCompleted ? 0 : 0.15, options: .curveEaseInOut) {
                
                sender.transform = .identity
            }
            
            signingInWithApple = true
            signingInWithGoogle = false
            self.signInWithApple()
        }
        
        //Sign In with Google Button
        else if sender == withGoogleButton {
            
            UIView.animate(withDuration: 0.3, delay: buttonAnimationCompleted ? 0 : 0.15, options: .curveEaseInOut) {
                
                sender.transform = .identity
            }
            
            signingInWithApple = false
            signingInWithGoogle = true
            GIDSignIn.sharedInstance()?.signIn()
        }
        
        //Sign In Button
        else if sender == signInButton {
            
            signInUserWithEmail()
            
            UIView.animate(withDuration: 0.3, delay: buttonAnimationCompleted ? 0 : 0.15, options: .curveEaseInOut) {
                
                sender.transform = .identity
            }
        }
        
        buttonAnimationCompleted = false
    }
    
    
    //MARK: - Sign Up Button Pressed
    
    @objc private func signUpButtonPressed () {
        
        userSigningUp = !userSigningUp
        
        //Should only be hidden if the user wasn't previously attempting to sign up and was just attempting to sign in
        if buttonStackView.isHidden {
            
            withEmailButton.setTitle("Sign Up with Email", for: .normal)
            withAppleLabel.text = "Sign Up with Apple"
            withGoogleLabel.text = "Sign Up with Google"
            
            setSignUpButtonText()
            
            revertBackToSignInOptions()
        }
        
        else {
            
            UIView.transition(with: buttonStackView, duration: 0.5, options: userSigningUp ? .transitionFlipFromRight : .transitionFlipFromLeft) {
                
                self.withEmailButton.setTitle((self.userSigningUp ? "Sign Up" : "Sign In") + " with Email", for: .normal)
                self.withAppleLabel.text = (self.userSigningUp ? "Sign Up" : "Sign In") + " with Apple"
                self.withGoogleLabel.text = (self.userSigningUp ? "Sign Up" : "Sign In") + " with Google"
            }
            
            setSignUpButtonText()
        }
    }
    
    
    //MARK: - Dismiss Keyboard
    
    @objc private func dismissKeyboard () {
        
        self.view.endEditing(true)
    }
}


//MARK: - UITextFieldDelegate Extension

extension LogInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}


//MARK: - ASAuthorizationControllerDelegate Extension

extension LogInViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        //Extracting the authorization credential provided by Apple
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let nonce = currentNonce else {
                
                fatalError("Invalid state: A login callback was registered, but no login request was sent")
            }
            
            //Retrieval of the identityToken
            guard let appleIDToken = appleIDCredential.identityToken else {
                
                print("Unable to fetch identity token")
                return
            }
            
            //Conversion of the identity token it into a string
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            SVProgressHUD.show()
            
            //Using the nonce and the idToken, this will ask the OAuth provider to mint a credential representing the user that has just signed in
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            //Using the credential to sign into Firebase
            //If this is a new user, Firebase will create a new user account
            firebaseAuth.signInUserWithCredential(credential) { [weak self] (user, error) in
                
                if error != nil {
                    
                    print(error?.localizedDescription as Any)
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    if let user = user {
                        
                        //Retrieves the users data from the "Users" collection in Firebase
                        self?.retrieveSignedInUserData(user, completion: { (error, userDataFound) in
                            
                            if error != nil {
                                
                                print(error?.localizedDescription as Any)
                                
                                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                            }
                            
                            else {
                                
                                SVProgressHUD.dismiss()
                                
                                if userDataFound ?? false {
                                    
                                    self?.performSegue(withIdentifier: "moveToHomeView", sender: self)
                                }
                                
                                //If this user is signing in with Apple for the first time
                                //or if this user did not complete the onboarding process during their first sign in
                                else {
                                    
                                    var newUser = NewUser()
                                    newUser.email = user.email ?? ""
                                    newUser.firstName = appleIDCredential.fullName?.givenName ?? ""
                                    newUser.lastName = appleIDCredential.fullName?.familyName ?? ""
                                    
                                    self?.moveToRegistrationView(newUser: newUser)
                                }
                            }
                        })
                    }
                }
            }
        }
    }
}


//MARK: - ASAuthorizationControllerPresentationContextProviding Extension

extension LogInViewController: ASAuthorizationControllerPresentationContextProviding {
    
    //Tells the delegate from which window it should present content to the user
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return self.view.window!
    }
}


//MARK: - GIDSignInDelegate Extension

extension LogInViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if error != nil {

            print(error.localizedDescription)
        }
        
        else {

            guard let authentication = user.authentication else { return }

            SVProgressHUD.show()
            
            //Using the Google ID token and the Google access token from the GIDAuthentication object and exchanging them for a Firebase credential
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            
            //Using the credential to sign into Firebase
            //If this is a new user, Firebase will create a new user account
            firebaseAuth.signInUserWithCredential(credential) { [weak self] (signedInUser, error) in
                
                if error != nil {
                    
                    print(error?.localizedDescription as Any)
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    if let signedInUser = signedInUser {
                        
                        //Retrieves the users data from the "Users" collection in Firebase
                        self?.retrieveSignedInUserData(signedInUser, completion: { (error, userDataFound) in
                            
                            if error != nil {
                                
                                print(error?.localizedDescription as Any)
                                
                                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                            }
                            
                            else {
                                
                                SVProgressHUD.dismiss()
                                
                                if userDataFound ?? false {
                                    
                                    self?.performSegue(withIdentifier: "moveToHomeView", sender: self)
                                }
                                
                                //If this user is signing in with Google for the first time
                                //or if this user did not complete the onboarding process during their first sign in
                                else {
                                    
                                    var newUser = NewUser()
                                    newUser.email = user.profile.email ?? ""
                                    newUser.firstName = user.profile.givenName
                                    newUser.lastName = user.profile.familyName
                                    
                                    self?.moveToRegistrationView(newUser: newUser)
                                }
                            }
                        })
                    }
                }
            }
        }
    }
}


//MARK: - Google's Stuff

private func randomNonceString(length: Int = 32) -> String {
  precondition(length > 0)
  let charset: Array<Character> =
      Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
  var result = ""
  var remainingLength = length

  while remainingLength > 0 {
    let randoms: [UInt8] = (0 ..< 16).map { _ in
      var random: UInt8 = 0
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
      if errorCode != errSecSuccess {
        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
      }
      return random
    }

    randoms.forEach { random in
      if remainingLength == 0 {
        return
      }

      if random < charset.count {
        result.append(charset[Int(random)])
        remainingLength -= 1
      }
    }
  }

  return result
}

private func sha256(_ input: String) -> String {
  let inputData = Data(input.utf8)
  let hashedData = SHA256.hash(data: inputData)
  let hashString = hashedData.compactMap {
    return String(format: "%02x", $0)
  }.joined()

  return hashString
}
