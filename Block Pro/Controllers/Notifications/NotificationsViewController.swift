//
//  NotificationsViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/28/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD
import Lottie

class NotificationsViewController: UIViewController {
    
    let notificationsTableView = UITableView()
    
    let friendRequestsHeader = UIView()
    let collabRequestsHeader = UIView()
    
    let showAllFriendRequestsButton = UIButton(type: .system)
    let showAllCollabsButton = UIButton(type: .system)
    
    let animationView = AnimationView(name: "notifications-animation")
    let animationTitleLabel = UILabel()
    
    lazy var tabBar = CustomTabBar.sharedInstance
    
    let currentUser = CurrentUser.sharedInstance
    
    lazy var firebaseCollab = FirebaseCollab.sharedInstance
    
    let formatter = DateFormatter()
    
    var friendRequests: [Friend]? {
        didSet {
            
            notificationsTableView.reloadSections([0], with: .fade)
            
            if tabBar.selectedIndex == 3 {
                
                firebaseCollab.markFriendRequestNotifications(friendRequests)
            }
            
            if collabRequests != nil {
                
                presentAnimationView()
            }
            
            showAllFriendRequestsButton.alpha = (friendRequests?.count ?? 0) > 5 ? 1 : 0
            
        }
    }
    
    var collabRequests: [Collab]? {
        didSet {
            
        }
    }
    
    var showAllFriendRequests: Bool = false
    var selectedFriendRequest: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Notifications"
        
        self.navigationController?.navigationBar.configureNavBar()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        
        configureTableView(notificationsTableView)
        configureTableViewSectionHeaderView(0)
        configureTableViewSectionHeaderView(1)
        
        configureAnimationView()
        configureAnimationTitleLabel()
        
        retrieveFriendRequests()
        
        collabRequests = []
        
        if friendRequests?.count ?? 0 == 0 && collabRequests?.count ?? 0 == 0 {
            
            friendRequestsHeader.alpha = 0
            collabRequestsHeader.alpha = 0
            
            animationView.alpha = 1
            animationTitleLabel.alpha = 1
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(retrieveFriendRequests), name: .didUpdateFriends, object: nil)
    }
    
    private func configureTableView (_ tableView: UITableView) {
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.delaysContentTouches = false
        tableView.separatorStyle = .none
        
//        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        tableView.register(FriendRequestCell.self, forCellReuseIdentifier: "friendRequestCell")
    }
    
    private func configureTableViewSectionHeaderView (_ section: Int) {
        
        let sectionHeaderView = section == 0 ? friendRequestsHeader : collabRequestsHeader
        let sectionLabel = UILabel()
        let showAllButton = section == 0 ? showAllFriendRequestsButton : showAllCollabsButton
        
        sectionHeaderView.addSubview(sectionLabel)
        sectionHeaderView.addSubview(showAllButton)
        
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        showAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            sectionLabel.topAnchor.constraint(equalTo: sectionHeaderView.topAnchor),
            sectionLabel.leadingAnchor.constraint(equalTo: sectionHeaderView.leadingAnchor, constant: 25),
            sectionLabel.widthAnchor.constraint(equalToConstant: 150),
            sectionLabel.heightAnchor.constraint(equalToConstant: 35),
            
            showAllButton.trailingAnchor.constraint(equalTo: sectionHeaderView.trailingAnchor, constant: -17.5),
            showAllButton.centerYAnchor.constraint(equalTo: sectionLabel.centerYAnchor),
            showAllButton.widthAnchor.constraint(equalToConstant: 31),
            showAllButton.heightAnchor.constraint(equalToConstant: 31)
        
        ].forEach({ $0.isActive = true })
        
        sectionHeaderView.backgroundColor = .white
        
        sectionLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
        sectionLabel.textColor = .lightGray//.black
        sectionLabel.textAlignment = .left
        sectionLabel.text = (section == 0 ? "Friend" : "Collab") + " Requests"
        
        showAllButton.tintColor = UIColor(hexString: "222222")
        showAllButton.setImage(UIImage(systemName: "chevron.down.circle.fill"), for: .normal)
        showAllButton.contentVerticalAlignment = .fill
        showAllButton.contentHorizontalAlignment = .fill
        
        if section == 0 {
            
            showAllButton.addTarget(self, action: #selector(showAllFriendRequestsButtonPressed), for: .touchUpInside)
            
            if friendRequests?.count ?? 0 > 5 {
                
                showAllButton.alpha = 1
            }
        }
    }
    
    private func configureAnimationView () {
        
        //This topBarHeight accounts for the fact that this navigationController allows large titles
        let topBarHeight = (keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0) + (self.navigationController?.navigationBar.frame.height ?? 0)
        
        self.view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            animationView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            animationView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            animationView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            animationView.heightAnchor.constraint(equalToConstant: (tabBar.frame.minY - topBarHeight) * 0.75) //80% of the distance between the bottom of
                                                                                                                    //navBar and top of the tabBar
        
        ].forEach({ $0.isActive = true })
        
        animationView.alpha = 0
        
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
        
        animationView.play()
    }
    
    
    //MARK: - Configure Animation Title
    
    private func configureAnimationTitleLabel () {
        
        let topBarHeight = (keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0) + (self.navigationController?.navigationBar.frame.height ?? 0)
        
        self.view.addSubview(animationTitleLabel)
        animationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            animationTitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            animationTitleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            animationTitleLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: (keyWindow?.safeAreaInsets.bottom ?? 0) > 0 ? -20 : -12.5),
            animationTitleLabel.heightAnchor.constraint(equalToConstant: (tabBar.frame.minY - (topBarHeight)) * 0.25) //Distance between the bottom of the                                                                                                                 //animation view and top of the tabBar
        
        ].forEach({ $0.isActive = true })
        
        animationTitleLabel.alpha = 0
        
        animationTitleLabel.numberOfLines = 0
        animationTitleLabel.font = UIFont(name: "Poppins-SemiBold", size: 25)
        animationTitleLabel.textAlignment = .center
        animationTitleLabel.text = "No Notifications\nYet"
    }
    
    @objc private func retrieveFriendRequests () {
        
        var requests: [Friend] = []
        firebaseCollab.friends.forEach({ if $0.accepted != true && $0.requestSentBy != currentUser.userID { requests.append($0) } })
        
        friendRequests = requests.sorted(by: { $0.requestSentOn ?? Date() > $1.requestSentOn ?? Date() })
    }
    
    private func presentAnimationView () {
        
        if friendRequests?.count ?? 0 == 0 {
            
            if animationView.alpha != 1 {
                
                animationView.play()
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    
                    self.friendRequestsHeader.alpha = 0
                    
                    self.animationView.alpha = 1
                    self.animationTitleLabel.alpha = 1
                }
            }
        }
        
        else {
            
            if animationView.alpha != 0 {
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    
                    self.friendRequestsHeader.alpha = 1
                    
                    self.animationView.alpha = 0
                    self.animationTitleLabel.alpha = 0
                    
                } completion: { (finished: Bool) in
                    
                    self.animationView.stop()
                }
            }
        }
    }
    
    @objc private func showAllFriendRequestsButtonPressed () {
        
        showAllFriendRequests = !showAllFriendRequests
        
        showAllFriendRequestsButton.setImage(showAllFriendRequests ? UIImage(systemName: "chevron.up.circle.fill") : UIImage(systemName: "chevron.down.circle.fill"), for: .normal)
        
        notificationsTableView.beginUpdates()
        notificationsTableView.endUpdates()
        
//        notificationsTableView.reloadSections([0], with: .none)
    }
}

extension NotificationsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (friendRequests?.count ?? 0) * 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return section == 0 ? friendRequestsHeader : collabRequestsHeader
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendRequestCell", for: indexPath) as! FriendRequestCell
            cell.selectionStyle = .none
            
            cell.formatter = formatter
            
            cell.friendRequest = friendRequests?[indexPath.row / 2]
            
            cell.friendRequestDelegate = self
            
            cell.animateButtons(animate: false, hide: !(indexPath == selectedFriendRequest))
            
            return cell
        }
        
        else {
            
            let cell = UITableViewCell()
            cell.isUserInteractionEnabled = false
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row % 2 == 0 {
            
            if showAllFriendRequests {
                
                return indexPath == selectedFriendRequest ? 125 : 80
            }
            
            else {
                
                if indexPath.row <= 9 {
                    
                    return indexPath == selectedFriendRequest ? 125 : 80
                }
                
                else {
                    
                    return 0
                }
            }
        }
        
        else {
            
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FriendRequestCell
        cell.animateButtons (animate: true, hide: indexPath == selectedFriendRequest ? true : false)
        
        selectedFriendRequest = indexPath == selectedFriendRequest ? nil : indexPath
        
        notificationsTableView.beginUpdates()
        notificationsTableView.endUpdates()
    }
}

extension NotificationsViewController: FriendRequestProtocol {
    
    func acceptFriendRequest(_ friendRequest: Friend) {
        
        selectedFriendRequest = nil
        
        firebaseCollab.acceptFriendRequest(friendRequest)
    }
    
    func declineFriendRequest(_ friendRequest: Friend) {
        
        selectedFriendRequest = nil
        
        firebaseCollab.declineFriendRequest(friendRequest)
    }
}
