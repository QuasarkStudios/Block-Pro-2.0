//
//  HomeViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/8/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    let headerView = HomeHeaderView()
    let profilePicture = ProfilePicture()
    lazy var progressView = iProgressView(self, 100, .circleStrokeSpin)
    let welcomeLabel = UILabel()
    
    let collabTableView = UITableView()
    
    lazy var tabBar = CustomTabBar.sharedInstance
    
    let calendarButton = UIButton(type: .system)
    
    let currentUser = CurrentUser.sharedInstance
    let firebaseCollab = FirebaseCollab.sharedInstance
    
    var collabs: [Collab]?
    var selectedCollab: Collab?
    
    let formatter = DateFormatter()
    
    var headerViewHeightConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear)
        
        configureHomeHeaderView()

        configureTableView(collabTableView)
        
        configureTabBar()
        configureCalendarButton()
        
        firebaseCollab.retrieveCollabs { [weak self] (collabs, members, error) in
            
            if collabs != nil {
                
                self?.collabs = collabs
                
                self?.collabTableView.reloadData()
            }
            
//            if collabs != nil {
//
//                print("collab", collabs)
//            }
//
//            if members != nil {
//
//                print("members", members)
//            }
        }
        
        if currentUser.userSignedIn {
            
            firebaseCollab.retrieveUsersFriends()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBar.shouldHide = false
    }
    
    private func configureHomeHeaderView () {
        
        self.view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            headerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
//            headerView.heightAnchor.constraint(equalToConstant: 370)
        
        ].forEach({ $0.isActive = true })
        
        let headerViewHeight: CGFloat = (keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 40) + 337.5//60 + 25 + 30 + 5 + 55 + 20 + 120 + 20
        
        headerViewHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: headerViewHeight)
        headerViewHeightConstraint?.isActive = true
        
//        headerView.backgroundColor = UIColor.blue.withAlphaComponent(0.25)
    }
    
    private func configureTableView (_ tableView: UITableView) {
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.delaysContentTouches = false
        tableView.separatorStyle = .none
        
        tableView.register(HomeCollabCell.self, forCellReuseIdentifier: "homeCollabCell")
    }
    
    private func configureTableViewSectionHeaderView () -> UIView {
        
        let sectionHeaderView = UIView()
        let collabsLabel = UILabel()
        let addCollabButton = UIButton(type: .system)
        
        sectionHeaderView.addSubview(collabsLabel)
        sectionHeaderView.addSubview(addCollabButton)
        
        collabsLabel.translatesAutoresizingMaskIntoConstraints = false
        addCollabButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collabsLabel.topAnchor.constraint(equalTo: sectionHeaderView.topAnchor),
            collabsLabel.bottomAnchor.constraint(equalTo: sectionHeaderView.bottomAnchor),
            collabsLabel.leadingAnchor.constraint(equalTo: sectionHeaderView.leadingAnchor, constant: 30),
            collabsLabel.widthAnchor.constraint(equalToConstant: 125)
        
        ].forEach({ $0.isActive = true })
        
        [
        
            addCollabButton.trailingAnchor.constraint(equalTo: sectionHeaderView.trailingAnchor, constant: -30),
            addCollabButton.centerYAnchor.constraint(equalTo: sectionHeaderView.centerYAnchor),
            addCollabButton.widthAnchor.constraint(equalToConstant: 31),
            addCollabButton.heightAnchor.constraint(equalToConstant: 31)
        
        ].forEach({ $0.isActive = true })
        
        
        sectionHeaderView.backgroundColor = .white
        
        collabsLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
        collabsLabel.textColor = .black
        collabsLabel.textAlignment = .left
        collabsLabel.text = "Collabs"
        
        addCollabButton.backgroundColor = UIColor(hexString: "222222")
        addCollabButton.setImage(UIImage(named: "plus 2"), for: .normal)
        addCollabButton.tintColor = .white
        
        addCollabButton.layer.cornerRadius = 15.5
        
        addCollabButton.imageEdgeInsets = UIEdgeInsets(top: 8.25, left: 8.25, bottom: 8.25, right: 8.25)

        addCollabButton.addTarget(self, action: #selector(addCollabButtonPressed), for: .touchUpInside)
        
        return sectionHeaderView
    }
    
    private func configureTabBar () {
        
        tabBarController?.tabBar.isHidden = true
        
        tabBar.homeTabNavigationController = navigationController
        tabBar.tabBarController = tabBarController
        
        keyWindow?.addSubview(tabBar)
    }
    
    private func configureCalendarButton () {
        
        self.view.addSubview(calendarButton)
        calendarButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            calendarButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -29),
            calendarButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(self.view.frame.height - tabBar.frame.minY) - 25),
            calendarButton.widthAnchor.constraint(equalToConstant: 60),
            calendarButton.heightAnchor.constraint(equalToConstant: 60)
            
        ].forEach( { $0.isActive = true } )
        
        calendarButton.backgroundColor = UIColor(hexString: "222222")
        calendarButton.setImage(UIImage(systemName: "calendar"), for: .normal)
        calendarButton.tintColor = .white
        
        calendarButton.contentHorizontalAlignment = .fill
        calendarButton.contentVerticalAlignment = .fill

        calendarButton.imageView?.contentMode = .scaleAspectFit
        calendarButton.imageEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        
        calendarButton.layer.cornerRadius = 30

//        addBlockButton.addTarget(self, action: #selector(addBlockButtonPressed), for: .touchUpInside)
    }
    
    @objc private func addCollabButtonPressed () {
        
        let configureCollabVC = ConfigureCollabViewController()
        configureCollabVC.title = "Create a Collab"
        configureCollabVC.configurationView = true
        
        configureCollabVC.configureBarButtonItems()
        
//        configureCollabVC.collabCreatedDelegate = self
        
        let configureCollabNavigationController = UINavigationController(rootViewController: configureCollabVC)
        configureCollabNavigationController.navigationBar.prefersLargeTitles = true
        
        self.present(configureCollabNavigationController, animated: true, completion: nil)
    }
    
//    private func moveToCollabView (_ selectedCollab: Collab) {
//
//        let collabVC = CollabViewController()
//        collabVC.collab = selectedCollab
//
//        let backButtonItem = UIBarButtonItem()
//        backButtonItem.title = ""
//        self.navigationItem.backBarButtonItem = backButtonItem
//
//        self.navigationController?.pushViewController(collabVC, animated: true)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToCollabView" {
            
            let collabVC = segue.destination as! CollabViewController
            collabVC.collab = selectedCollab
            
            let backButtonItem = UIBarButtonItem()
            backButtonItem.title = ""
            self.navigationItem.backBarButtonItem = backButtonItem
        }
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (collabs?.count ?? 0) * 2//20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 || indexPath.row % 2 == 0 {
            
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            
            return cell
        }
        
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeCollabCell", for: indexPath) as! HomeCollabCell
            cell.selectionStyle = .none
            
            cell.formatter = formatter
            
            cell.collab = collabs?[indexPath.row / 2]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return configureTableViewSectionHeaderView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 35
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            
            return 20
        }
        
        else if indexPath.row % 2 == 0 {
            
            return 20
        }
        
        else {
            
            return 165
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? HomeCollabCell {
            
            if let selectedCollab = firebaseCollab.collabs.first(where: { $0.collabID == cell.collab?.collabID }) {
                
                self.selectedCollab = selectedCollab
                
                performSegue(withIdentifier: "moveToCollabView", sender: self)
                
//                moveToCollabView(selectedCollab)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y >= 0 {
            
            let minimumHeaderViewHeight: CGFloat = (keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 40) + 80
            
            //If the homeHeaderView is larger than minimum allowable height, process to decrementing its height
            if (headerViewHeightConstraint?.constant ?? 140) - scrollView.contentOffset.y > minimumHeaderViewHeight {
                
                headerViewHeightConstraint?.constant -= scrollView.contentOffset.y
                
                scrollView.contentOffset.y = 0
            }
            
            else {
                
                headerViewHeightConstraint?.constant = (keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 40) + 80
            }
        }
        
        else {
            
            let maximumHeaderViewHeight: CGFloat = (keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 40) + 337.5
            
            if headerViewHeightConstraint?.constant ?? 0 < maximumHeaderViewHeight {
                
                headerViewHeightConstraint?.constant = maximumHeaderViewHeight
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}

extension HomeViewController: HomeViewProtocol {
    
    func collabCreated (_ collabID: String) {
        
    }
    
    func moveToPersonalScheduleView () {
        
    }
}
