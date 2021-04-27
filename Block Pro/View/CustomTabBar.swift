//
//  CustomTabBar.swift
//  Block Pro
//
//  Created by Nimat Azeez on 12/23/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class CustomTabBar: UIView {
    
    let tabStackView = UIStackView()
    
    let homeTabContainer = UIView()
    let homeTabImageView = UIImageView(image: UIImage(named: "home")?.withRenderingMode(.alwaysTemplate))
    
    let searchTabContainer = UIView()
    let searchTabImageView = UIImageView(image: UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysTemplate))
    
    let messagesTabContainer = UIView()
    let messagesTabImageView = UIImageView(image: UIImage(named: "chat")?.withRenderingMode(.alwaysTemplate))
    
    let notificationsTabContainer = UIView()
    let notificationsTabImageView = UIImageView(image: UIImage(named: "bell")?.withRenderingMode(.alwaysTemplate))
    
    let notificationIndicator = UILabel()
    
    var homeTabNavigationController: UINavigationController?
    var tabBarController: UITabBarController?
    
    var selectedIndex: Int = 0
    
    var indicatorWidthConstraint: NSLayoutConstraint?
    var indicatorHeightConstraint: NSLayoutConstraint?
    
    var distanceFromBottom: CGFloat {
        
        return keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 34 : 15
    }
    
    var shouldHide: Bool? {
        
        didSet {
            
            if shouldHide ?? false {
                
                UIView.animate(withDuration: 0.15) {
                    
                    self.alpha = 0
                }
            }
            
            else {
                
                UIView.animate(withDuration: 0.3, delay: 0.15, options: []) {
                    
                    self.alpha = 1
                }
            }
        }
    }
    
    static let sharedInstance = CustomTabBar()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureTabBar()
        configureTabs()
        configureNotificationIndicator()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configure Tab Bar
    
    private func configureTabBar () {
        
        let centeredXCoord = (UIScreen.main.bounds.width / 2) - 120
        
        //Height of the tabBar + 15 point buffer + bottom inset of the phone/view
        let yCoord = UIScreen.main.bounds.height - (45 + 15 + distanceFromBottom)
        
        frame = CGRect(x: centeredXCoord, y: yCoord, width: 240, height: 55)
        alpha = 0
        backgroundColor = UIColor(hexString: "222222")
        layer.cornerRadius = 28.5
        
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
        
        layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.75
    }
    
    
    //MARK: - Configure Tabs
    
    private func configureTabs () {
        
        self.addSubview(tabStackView)
        tabStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            tabStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            tabStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            tabStackView.widthAnchor.constraint(equalToConstant: self.frame.width - 30),
            tabStackView.heightAnchor.constraint(equalToConstant: self.frame.height)
            
        ].forEach( { $0.isActive = true } )
        
        tabStackView.alignment = .center
        tabStackView.distribution = .equalSpacing
        tabStackView.axis = .horizontal
        
        ///////////////////////////////////////////////////////////////////////
        
        tabStackView.addArrangedSubview(homeTabContainer)
        homeTabContainer.addSubview(homeTabImageView)
        
        tabStackView.addArrangedSubview(searchTabContainer)
        searchTabContainer.addSubview(searchTabImageView)
        
        tabStackView.addArrangedSubview(messagesTabContainer)
        messagesTabContainer.addSubview(messagesTabImageView)
        
        tabStackView.addArrangedSubview(notificationsTabContainer)
        notificationsTabContainer.addSubview(notificationsTabImageView)
        
        ///////////////////////////////////////////////////////////////////////
        
        setTabConstraints(tabContainer: homeTabContainer, tabImageView: homeTabImageView, constant: 31)
        setTabConstraints(tabContainer: searchTabContainer, tabImageView: searchTabImageView, constant: 30)
        setTabConstraints(tabContainer: messagesTabContainer, tabImageView: messagesTabImageView, constant: 28)
        setTabConstraints(tabContainer: notificationsTabContainer, tabImageView: notificationsTabImageView, constant: 27)
        
        ///////////////////////////////////////////////////////////////////////
        
        homeTabContainer.isUserInteractionEnabled = true
        homeTabContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(homeTabPressed)))
        
        searchTabContainer.isUserInteractionEnabled = true
        searchTabContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(searchTabPressed)))
        
        messagesTabContainer.isUserInteractionEnabled = true
        messagesTabContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(messagesTabPressed)))
        
        notificationsTabContainer.isUserInteractionEnabled = true
        notificationsTabContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(notificationsTabPressed)))
        
        ///////////////////////////////////////////////////////////////////////
        
        homeTabImageView.tintColor = UIColor.systemRed.flatten().lighten(byPercentage: 0.1)
        homeTabImageView.contentMode = .scaleAspectFit
        
        searchTabImageView.tintColor = UIColor.white
        searchTabImageView.contentMode = .scaleAspectFit
        
        messagesTabImageView.tintColor = UIColor.white
        messagesTabImageView.contentMode = .scaleAspectFit
        
        notificationsTabImageView.tintColor = UIColor.white
        notificationsTabImageView.contentMode = .scaleAspectFit
    }
    
    
    //MARK: - Configure Notification Indicator
    
    private func configureNotificationIndicator () {
        
        self.addSubview(notificationIndicator)
        notificationIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            notificationIndicator.topAnchor.constraint(equalTo: self.tabStackView.topAnchor, constant: 5),
            notificationIndicator.trailingAnchor.constraint(equalTo: self.tabStackView.trailingAnchor, constant: -5.5),

        ].forEach({ $0.isActive = true })
        
        indicatorWidthConstraint = notificationIndicator.widthAnchor.constraint(equalToConstant: 23)
        indicatorWidthConstraint?.isActive = true
        
        indicatorHeightConstraint = notificationIndicator.heightAnchor.constraint(equalToConstant: 23)
        indicatorHeightConstraint?.isActive = true
        
        notificationIndicator.alpha = 0
        notificationIndicator.backgroundColor = UIColor.systemRed.flatten().lighten(byPercentage: 0.1)
        
        notificationIndicator.layer.cornerRadius = 11.5 //12.5 when two or more digits, 11.5 when smaller
        notificationIndicator.layer.cornerCurve = .continuous
        notificationIndicator.clipsToBounds = true
        
        notificationIndicator.font = UIFont(name: "Poppins-Medium", size: 15.5) //15.5 when just one digit, 13.5 when two digits, 11 when too many notifs
        notificationIndicator.textAlignment = .center
        notificationIndicator.textColor = .white
    }
    
    //MARK: - Set Tab Constraints
    
    private func setTabConstraints (tabContainer: UIView, tabImageView: UIImageView, constant: CGFloat) {
        
        tabContainer.translatesAutoresizingMaskIntoConstraints = false
        tabImageView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            tabContainer.widthAnchor.constraint(equalToConstant: (self.frame.width - 30) / 4),
            tabContainer.heightAnchor.constraint(equalToConstant: self.frame.height),
            
            tabImageView.centerXAnchor.constraint(equalTo: tabContainer.centerXAnchor),
            tabImageView.centerYAnchor.constraint(equalTo: tabContainer.centerYAnchor),
            tabImageView.widthAnchor.constraint(equalToConstant: constant),
            tabImageView.heightAnchor.constraint(equalToConstant: constant)
        
        ].forEach({ $0.isActive = true })
    }
    
    
    //MARK: - Animate Selected Tab
    
    private func animateSelectedTabImageView (_ selectedTabImageView: UIImageView) {

        //Changing the color of the selected tab
        selectedTabImageView.tintColor = UIColor.systemRed.flatten().lighten(byPercentage: 0.1)
        
        //Changing the color of the other tabs
        tabStackView.arrangedSubviews.forEach { (tab) in
            
            tab.subviews.forEach { (subview) in
                
                if let imageView = subview as? UIImageView, imageView != selectedTabImageView {
                    
                    imageView.tintColor = .white
                }
            }
        }
        
        //Animating the selected tab
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.75, options: .curveEaseInOut, animations: {

            selectedTabImageView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)

        })

        UIView.animate(withDuration: 2, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {

            selectedTabImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
    
    
    //MARK: - Set Notification Indicator
    
    func setNotificationIndicator (notificationCount: Int = 0) {
        
        //If there are no notifications or the notifications tab is currently selected
        if notificationCount == 0 || selectedIndex == 3 {
            
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
                
                self.notificationIndicator.alpha = 0
            }
        }
        
        else {
            
            //Setting the notification indicator text
            notificationIndicator.text = notificationCount < 100 ? "\(notificationCount)" : "99+"
            
            if notificationIndicator.alpha != 1 {
                
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                    
                    self.notificationIndicator.alpha = 1
                }
            }
            
            //Changing the size of the notficationIndicator based on the amount of notifications
            indicatorWidthConstraint?.constant = notificationCount < 10 ? 23 : 25
            indicatorHeightConstraint?.constant = notificationCount < 10 ? 23 : 25
            
            //Changing the corner radius of the notficationIndicator based on the amount of notifications
            notificationIndicator.layer.cornerRadius = notificationCount < 10 ? 11.5 : 12.5
            
            //Changing the font size of the notficationIndicator based on the amount of notifications
            if notificationCount < 10 {
                
                notificationIndicator.font = UIFont(name: "Poppins-Medium", size: 15.5)
            }
            
            else if notificationCount < 100 {
                
                notificationIndicator.font = UIFont(name: "Poppins-Medium", size: 14)
            }
            
            else {
                
                notificationIndicator.font = UIFont(name: "Poppins-Medium", size: 11)
            }
        }
    }
    
    
    //MARK: - Tab Pressed Functions
    
    @objc private func homeTabPressed () {
        
        if selectedIndex == 0 {
            
            if let homeViewController = homeTabNavigationController?.viewControllers[1] {
                
                homeTabNavigationController?.popToViewController(homeViewController, animated: true)
                
                animateSelectedTabImageView(homeTabImageView)
            }
        }
        
        else {
            
            selectedIndex = 0
            tabBarController?.selectedIndex = selectedIndex
            
            animateSelectedTabImageView(homeTabImageView)
        }
    }
    
    @objc private func searchTabPressed () {
        
        if selectedIndex == 1 {
            
            //will be used to pop back to home view once search tab is configured
            
            animateSelectedTabImageView(searchTabImageView)
        }
        
        else {
            
            selectedIndex = 1
            tabBarController?.selectedIndex = selectedIndex
            
            animateSelectedTabImageView(searchTabImageView)
        }
    }
    
    @objc private func messagesTabPressed () {
            
        selectedIndex = 2
        tabBarController?.selectedIndex = selectedIndex
        
        animateSelectedTabImageView(messagesTabImageView)
    }
    
    @objc private func notificationsTabPressed () {
        
        if selectedIndex == 3 {
            
            //will be used to pop back to home view once notif tab is configured
            
            animateSelectedTabImageView(notificationsTabImageView)
        }
        
        else {
            
            selectedIndex = 3
            tabBarController?.selectedIndex = selectedIndex
            
            setNotificationIndicator()
            
            animateSelectedTabImageView(notificationsTabImageView)
        }
    }
}
