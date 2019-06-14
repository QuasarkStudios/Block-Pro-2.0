//
//  TabBarController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/14/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let tabBarIndex = tabBarController.selectedIndex
        
        print(tabBarIndex)
    }

    

}

