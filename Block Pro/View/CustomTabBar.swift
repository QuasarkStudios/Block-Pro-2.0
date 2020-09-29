//
//  TabBar.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/9/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

class CustomTabBar: UIView {
    
    let homeTab = UIButton(type: .custom)
    let pomodoroTab = UIButton(type: .custom)
    let messagesTab = UIButton(type: .custom)
    let notifsTab = UIButton(type: .custom)
    
    lazy var tabArray: [UIButton] = [homeTab, pomodoroTab, messagesTab, notifsTab]
    
    var selectedIndex: Int = 0
    
    var tabBarController: UITabBarController?
    
    var shouldHide: Bool? {
        didSet {

            if shouldHide! {

                let xCoord = UIScreen.main.bounds.width + 10
                frame = CGRect(x: xCoord, y: frame.origin.y, width: 240, height: 55)
                
                alpha = 0
            }

            else {

                let centeredXCoord = (UIScreen.main.bounds.width / 2) - 120
                frame = CGRect(x: centeredXCoord, y: frame.origin.y, width: 240, height: 55)
                
                alpha = 1
            }
        }
    }
    
    var workItem: DispatchWorkItem? {
        didSet {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: workItem!)
        }
    }
    
    var previousNavigationController: UINavigationController?
    var currentNavigationController: UINavigationController?
    
    lazy var presentActiveTabBarSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleActiveTabBarPresentation(sender:)))
    lazy var dismissActiveTabBarSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleActiveTabBarPresentation(sender:)))
    
    lazy var presentDisabledTabBarSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleDisabledTabBarGesturePresentation))
    
    var popped: Bool = false  //Tracks to see if the user popped back to the root view controller
    
    //REMOVE THIS WHEN TABBAR IS OVERHAULED; QUICK WORK AROUND CAUSE YOU OF THE PAST IS FEELING LAZY
    func bottomInset () -> CGFloat {
        
        //iPhone XS Max & iPhone XR
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {
            
            return 34
        }
            
        //iPhone XS
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            
            return 34
        }
            
        //Errythang else
        else {
            
            //Random inset; normally 0 for all phone with bezels
            return 15
        }
    }
    
    static let sharedInstance = CustomTabBar()
    
    override init (frame: CGRect) {
        super.init(frame: frame)

        configureTabBar()
        configureButtons()
    }

    convenience init () {
        self.init(frame: .zero)

        configureTabBar()
        configureButtons()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    private func configureTabBar () {
        
        let centeredXCoord = (UIScreen.main.bounds.width / 2) - 112.5
        //let yCoord = UIScreen.main.bounds.height - (61 + bottomInset()) //95
        
        //Height of the tabBar + 15 point buffer + bottom inset of the phone/view
        let yCoord = UIScreen.main.bounds.height - (45 + 15 + bottomInset())
        
        frame = CGRect(x: centeredXCoord, y: yCoord, width: 225, height: 45)
        backgroundColor = UIColor(hexString: "222222")//UIColor(hexString: "282828")
        layer.cornerRadius = 28.5
        
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
        
        layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.75
    }
    
    private func configureButtons () {
        
        let buttonStackView = UIStackView()
        buttonStackView.alignment = .center
        buttonStackView.distribution = .fillEqually
        buttonStackView.axis = .horizontal
        self.addSubview(buttonStackView)
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            buttonStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            buttonStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            buttonStackView.widthAnchor.constraint(equalToConstant: self.frame.width),
            buttonStackView.heightAnchor.constraint(equalToConstant: self.frame.height)
            
        ].forEach( { $0.isActive = true } )
        
        buttonStackView.addArrangedSubview(homeTab)
        homeTab.setImage(UIImage(named: "home")?.withRenderingMode(.alwaysTemplate), for: .normal)
        homeTab.adjustsImageWhenHighlighted = false
        //homeTab.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        homeTab.tintColor = UIColor.systemRed.flatten().lighten(byPercentage: 0.1)//UIColor(hexString: "#e35d5b")
        homeTab.addTarget(self, action: #selector(homeTabButton), for: .touchUpInside)

        buttonStackView.addArrangedSubview(pomodoroTab)
        pomodoroTab.setImage(UIImage(named: "timer")?.withRenderingMode(.alwaysTemplate), for: .normal)
        pomodoroTab.adjustsImageWhenHighlighted = false
        pomodoroTab.imageEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        pomodoroTab.tintColor = UIColor.white//.darken(byPercentage: 0.1)
        pomodoroTab.addTarget(self, action: #selector(pomodoroTabButton), for: .touchUpInside)
        
        buttonStackView.addArrangedSubview(messagesTab)
        messagesTab.setImage(UIImage(named: "chat")?.withRenderingMode(.alwaysTemplate), for: .normal)
        messagesTab.adjustsImageWhenHighlighted = false
        messagesTab.imageEdgeInsets = UIEdgeInsets(top: 9, left: 13, bottom: 9, right: 13)
        messagesTab.tintColor = UIColor.white//.darken(byPercentage: 0.1)
        messagesTab.addTarget(self, action: #selector(messageTabButton), for: .touchUpInside)
        
        buttonStackView.addArrangedSubview(notifsTab)
        notifsTab.setImage(UIImage(named: "bell")?.withRenderingMode(.alwaysTemplate), for: .normal)
        notifsTab.adjustsImageWhenHighlighted = false
        notifsTab.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        notifsTab.tintColor = UIColor.white//.darken(byPercentage: 0.1)
        notifsTab.addTarget(self, action: #selector(notifButtonPressed), for: .touchUpInside)
    }
    
    func animateEntryToView() {
         
        if previousNavigationController == currentNavigationController {
            
            alpha = 0
            
            UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseInOut, animations: {
                
                self.alpha = 1
            })
        }
    }
    
    func animateSelectedTab () {
        
        let selectedTab = tabArray[selectedIndex]

        selectedTab.imageEdgeInsets = UIEdgeInsets(top: selectedTab.imageEdgeInsets.top + 0.5, left: selectedTab.imageEdgeInsets.left + 1, bottom: selectedTab.imageEdgeInsets.bottom + 0.5, right: selectedTab.imageEdgeInsets.right + 1)
        
        UIView.animate(withDuration: 0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {

            self.layoutIfNeeded()

        }) { (finished: Bool) in

            self.tabSelected()
            
            selectedTab.imageEdgeInsets = UIEdgeInsets(top: selectedTab.imageEdgeInsets.top - 0.5, left: selectedTab.imageEdgeInsets.left - 1, bottom: selectedTab.imageEdgeInsets.bottom - 0.5, right: selectedTab.imageEdgeInsets.right - 1)

            UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {

                self.layoutIfNeeded()

            })
        }
    }
    
//    @objc func tabBarPresented () {
//
//        let centeredXCoord = (UIScreen.main.bounds.width / 2) - 112.5
//
//        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
//
//            self.frame = CGRect(x: centeredXCoord, y: self.frame.origin.y, width: 225, height: 45)
//
//        }) { (finished: Bool) in
//
//        }
//    }
    
    
    func configureActiveTabBarGestureRecognizers (_ view: UIView) {
        
        presentActiveTabBarSwipeGesture.cancelsTouchesInView = true
        presentActiveTabBarSwipeGesture.direction = .left
        view.addGestureRecognizer(presentActiveTabBarSwipeGesture)
        
        dismissActiveTabBarSwipeGesture.cancelsTouchesInView = true
        dismissActiveTabBarSwipeGesture.direction = .right
        view.addGestureRecognizer(dismissActiveTabBarSwipeGesture)
    }
    
    func configureDisabledTabBarGestureRecognizer (_ view: UIView) {
        
        let presentTabBarSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleDisabledTabBarGesturePresentation))
        presentTabBarSwipeGesture.cancelsTouchesInView = true
        presentTabBarSwipeGesture.direction = .left
        view.addGestureRecognizer(presentTabBarSwipeGesture)
    }
    
    @objc func handleActiveTabBarPresentation (sender: UISwipeGestureRecognizer) {
        
        if sender.direction == .left {
            
            self.workItem?.cancel()
            
            let workItem = DispatchWorkItem {
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.shouldHide = true
                    
                })
            }
            
            self.workItem = workItem
            
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {

                self.shouldHide = false
            })
        }
        
        else {
            
            self.workItem?.cancel()
            
            UIView.animate(withDuration: 0.5) {
                
                self.shouldHide = true
            }
        }
    }
    
    @objc func handleDisabledTabBarGesturePresentation () {
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    private func scheduleTabBarDismissal () {

        self.shouldHide = false

        workItem = DispatchWorkItem(block: {

            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                
                self.shouldHide = true

            })
        })
    }
    
    @objc private func homeTabButton () {
        
        homeTab.tintColor = UIColor.systemRed.flatten().lighten(byPercentage: 0.1)
        
        [pomodoroTab, messagesTab, notifsTab].forEach( { $0.tintColor = UIColor.white } )
        
        selectedIndex = 0
        
        animateSelectedTab()
        
        //tabSelected()
    }
    
    @objc private func pomodoroTabButton () {
        
        pomodoroTab.tintColor = UIColor.systemRed.flatten().lighten(byPercentage: 0.1)
        
        [homeTab, messagesTab, notifsTab].forEach( { $0.tintColor = UIColor.white } )
        
        selectedIndex = 1
        
        animateSelectedTab()
        
        //tabSelected()
    }
    
    @objc private func messageTabButton () {
        
        messagesTab.tintColor = UIColor.systemRed.flatten().lighten(byPercentage: 0.1)
        
        [homeTab, pomodoroTab, notifsTab].forEach( { $0.tintColor = UIColor.white } )
        
        selectedIndex = 2
        
        animateSelectedTab()
        
        //tabSelected()
    }
    
    @objc private func notifButtonPressed () {
        
        notifsTab.tintColor = UIColor.systemRed.flatten().lighten(byPercentage: 0.1)
        
        [homeTab, pomodoroTab, messagesTab].forEach( { $0.tintColor = UIColor.white } )
        
        selectedIndex = 3
        
        animateSelectedTab()
        
        //tabSelected()
    }
    
    private func tabSelected () {
        
        workItem?.cancel()
        
        tabBarController?.selectedIndex = selectedIndex
        tabBarController?.delegate?.tabBarController?(tabBarController!, didSelect: (tabBarController?.viewControllers![selectedIndex])!)
    }
}

extension CustomTabBar: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    
        if let selectedNavigationController = viewController as? UINavigationController {
            
            if currentNavigationController == selectedNavigationController {
                
                if selectedIndex == 0 {

                    if currentNavigationController?.visibleViewController != currentNavigationController?.viewControllers[1] {
                    
                        popToHomeView()
                    }
                }
            }

            else {
                
                if selectedIndex == 0 {
                    
                    let homeViewController = selectedNavigationController.viewControllers[1] as! HomeViewController
                    
                    if selectedNavigationController.visibleViewController != homeViewController {
                        
                        determinePresentedHomeTabView(selectedNavigationController.visibleViewController)
                    }
                    
                    else {
                        
                        homeViewController.configureTabBar()
                    }
                }
                    
                else if selectedIndex == 1 {
                    
                    let pomodoroViewController = selectedNavigationController.visibleViewController as! PomodoroViewController
                    pomodoroViewController.configureTabBar()
                }
                
                else if selectedIndex == 2 {
                    
                    #warning("stop force unwrapping here; was crashing and tho it was caused by the simulator its still probably not the best practice")
                    let messagesViewController = selectedNavigationController.visibleViewController as! MessagesHomeViewController
                    messagesViewController.configureTabBar()
                }
                
                else if selectedIndex == 3 {
                    
                    let notificationViewController = selectedNavigationController.visibleViewController as! NotificationsViewController
                    notificationViewController.configureTabBar()
                }
            }
        }
    }
    
    private func popToHomeView () {

        popped = true
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            
            self.alpha = 0
            
        }) { (finished: Bool) in
            
            let homeViewController = self.currentNavigationController?.viewControllers[1] as! HomeViewController
            homeViewController.configureTabBar()
            
            self.currentNavigationController!.popToViewController((self.currentNavigationController?.viewControllers[1])!, animated: true)

            UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseInOut, animations: {

                self.alpha = 1
            })
        }
    }
}

extension CustomTabBar {
    
    private func determinePresentedHomeTabView (_ selectedViewController: UIViewController?) {
        
        if let viewController = selectedViewController as? TimeBlockViewController2 {
            
            viewController.configureTabBar()
            scheduleTabBarDismissal()
        }
        
        else if let viewController = selectedViewController as? CollabViewController {
            
            viewController.configureTabBar()
            scheduleTabBarDismissal()
        }
        
        else if let viewController = selectedViewController as? ProfileViewController {
            
            viewController.configureTabBar()
            scheduleTabBarDismissal()
        }
    }
}
