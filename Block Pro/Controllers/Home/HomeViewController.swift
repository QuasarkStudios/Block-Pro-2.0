//
//  HomeViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/8/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    lazy var tabBar = CustomTabBar.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTabBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBar.shouldHide = false
    }
    
    private func configureTabBar () {
        
        tabBarController?.tabBar.isHidden = true
        
        tabBar.homeTabNavigationController = navigationController
        tabBar.tabBarController = tabBarController
        
        keyWindow?.addSubview(tabBar)
    }
}
