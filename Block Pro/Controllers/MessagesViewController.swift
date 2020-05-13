//
//  MessagesViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/10/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController {

    let tabBar = CustomTabBar.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //configureTabBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        tabBar.previousNavigationController = navigationController
    }
    
    func configureTabBar () {

        tabBarController?.tabBar.isHidden = true
        tabBarController?.delegate = tabBar

        tabBar.shouldHide = false
        tabBar.tabBarController = tabBarController
        tabBar.currentNavigationController = self.navigationController
        
        view.addSubview(tabBar)
    }
}
