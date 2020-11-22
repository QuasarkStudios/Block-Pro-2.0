//
//  DetailsViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/13/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var detailsTableView: UITableView!
    
    lazy var tabBar = CustomTabBar.sharedInstance
    
    var categoriesCellHeight: CGFloat = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()

        detailsTableView.dataSource = self
        detailsTableView.delegate = self
        
        detailsTableView.separatorStyle = .none
        detailsTableView.showsVerticalScrollIndicator = false
        
        detailsTableView.register(UINib(nibName: "ProgressCirclesCell", bundle: nil), forCellReuseIdentifier: "progressCirclesCell")
        
        detailsTableView.register(UINib(nibName: "CategoriesCell", bundle: nil), forCellReuseIdentifier: "categoriesCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        configureTabBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        tabBar.previousNavigationController = navigationController
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "progressCirclesCell", for: indexPath) //as! ProgressCirclesCell
            
            cell.selectionStyle = .none
            
            return cell
        }
        
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesCell", for: indexPath)
            
            cell.selectionStyle = .none
            
            return cell
        }
        

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            
            return 400
        }
        
        else {
            
            return categoriesCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 1 {
            
            let cell = tableView.cellForRow(at: indexPath) as! CategoriesCell
            
            
            //If the cell hasn't been animated
            if categoriesCellHeight == 200 {
                
                categoriesCellHeight = 500
                
                cell.animateBarTopAnchor(cell.categoryArray, animateUp: false, duration: 0.5)
            }
            
            //If the cell has been animated 
            else {
                
                categoriesCellHeight = 200
                
                cell.animateBarTopAnchor(cell.categoryArray, animateUp: true, duration: 0.5)
            }
            
            detailsTableView.beginUpdates()
            detailsTableView.endUpdates()
            
            detailsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func configureTabBar () {

        tabBarController?.tabBar.isHidden = true
        tabBarController?.delegate = tabBar
        
        tabBar.tabBarController = tabBarController
        tabBar.currentNavigationController = self.navigationController
        
        tabBar.configureActiveTabBarGestureRecognizers(self.view)
        
        if tabBar.previousNavigationController == tabBar.currentNavigationController {
            
            tabBar.shouldHide = true
        }
        
        view.addSubview(tabBar)
    }
}
