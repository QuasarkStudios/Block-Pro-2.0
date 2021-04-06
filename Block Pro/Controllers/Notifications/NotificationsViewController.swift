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
    let showAllCollabRequestsButton = UIButton(type: .system)
    
    let animationView = AnimationView(name: "notifications-animation")
    let animationTitleLabel = UILabel()
    
    lazy var tabBar = CustomTabBar.sharedInstance
    
    let currentUser = CurrentUser.sharedInstance
    
    lazy var firebaseCollab = FirebaseCollab.sharedInstance
    
    let formatter = DateFormatter()
    
    var friendRequests: [Friend]? {
        didSet {
            
            UIView.transition(with: notificationsTableView, duration: 0.3, options: .transitionCrossDissolve) {
                
                self.notificationsTableView.reloadData()
            }
            
            //Will only mark the friend requests if the user is on the "Notifications" tab
            if tabBar.selectedIndex == 3 {
                
                firebaseCollab.markFriendRequestNotifications(friendRequests)
            }
            
            presentAnimationView()
            
            showAllFriendRequestsButton.alpha = (friendRequests?.count ?? 0) > 5 ? 1 : 0
        }
    }
    
    var collabRequests: [Collab]? {
        didSet {
            
            //Will only mark the collab requests if the user is on the "Notifications" tab
            if tabBar.selectedIndex == 3 {
                
                firebaseCollab.markCollabRequestNotifications(collabRequests)
            }
            
            presentAnimationView()
            
            showAllCollabRequestsButton.alpha = (collabRequests?.count ?? 0) > 5 ? 1 : 0
        }
    }
    
    var showAllFriendRequests: Bool = false
    var showAllCollabRequests: Bool = false
    
    var selectedFriendRequest: IndexPath?
    var selectedCollabRequest: IndexPath?
    
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
        retrieveCollabRequests()
        
        NotificationCenter.default.addObserver(self, selector: #selector(retrieveFriendRequests), name: .didUpdateFriends, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(retrieveCollabRequests), name: .didUpdateCollabs, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        firebaseCollab.markFriendRequestNotifications(friendRequests)
        firebaseCollab.markCollabRequestNotifications(collabRequests)
    }
    
    
    //MARK: - Configure Table View
    
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
        
        tableView.estimatedRowHeight = 0 //Important to be able to retrieve correct contentSize
        
        tableView.register(FriendRequestCell.self, forCellReuseIdentifier: "friendRequestCell")
        tableView.register(CollabRequestCell.self, forCellReuseIdentifier: "collabRequestCell")
    }
    
    
    //MARK: - Configure Table View Section Header
    
    private func configureTableViewSectionHeaderView (_ section: Int) {
        
        let sectionHeaderView = section == 0 ? friendRequestsHeader : collabRequestsHeader
        let sectionLabel = UILabel()
        let showAllButton = section == 0 ? showAllFriendRequestsButton : showAllCollabRequestsButton
        
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
        sectionLabel.textColor = .lightGray
        sectionLabel.textAlignment = .left
        sectionLabel.text = (section == 0 ? "Friend" : "Collab") + " Requests"
        
        showAllButton.tintColor = UIColor(hexString: "222222")
        showAllButton.setImage(UIImage(systemName: "chevron.down.circle.fill"), for: .normal)
        showAllButton.contentVerticalAlignment = .fill
        showAllButton.contentHorizontalAlignment = .fill
        
        if section == 0 {
            
            if friendRequests?.count ?? 0 > 5 {
                
                showAllButton.alpha = 1
            }
            
            showAllButton.addTarget(self, action: #selector(showAllFriendRequestsButtonPressed), for: .touchUpInside)
        }
        
        else {
            
            if collabRequests?.count ?? 0 > 5 {
                
                showAllButton.alpha = 1
            }
            
            showAllButton.addTarget(self, action: #selector(showAllCollabRequestsButtonPressed), for: .touchUpInside)
        }
    }
    
    
    //MARK: - Configure Animation View
    
    private func configureAnimationView () {
        
        //This topBarHeight accounts for the fact that this navigationController allows large titles
        let topBarHeight = (keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0) + (self.navigationController?.navigationBar.frame.height ?? 0)
        
        self.view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            animationView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            animationView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            animationView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            animationView.heightAnchor.constraint(equalToConstant: (tabBar.frame.minY - topBarHeight) * 0.75) //75% of the distance between the bottom of
                                                                                                                    //navBar and top of the tabBar
        
        ].forEach({ $0.isActive = true })
        
        animationView.alpha = 0
        
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
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
    
    
    //MARK: - Retrieve Friend Requests
    
    @objc private func retrieveFriendRequests () {
        
        var requests: [Friend] = []
        firebaseCollab.friends.forEach({ if $0.accepted != true && $0.requestSentBy != currentUser.userID { requests.append($0) } })
        
        friendRequests = requests.sorted(by: { $0.requestSentOn ?? Date() > $1.requestSentOn ?? Date() })
    }
    
    
    //MARK: - Retrieve Collab Requests
    
    @objc private func retrieveCollabRequests () {
        
        var requests: [Collab] = []
        firebaseCollab.collabs.forEach({ if $0.accepted?[currentUser.userID] != true { requests.append($0) } })
        
        //If the count of the collabRequests has changed
        if requests.count != collabRequests?.count ?? 0 {
            
            collabRequests = requests.sorted(by: { $0.requestSentOn?[currentUser.userID] ?? Date() > $1.requestSentOn?[currentUser.userID] ?? Date() })
            
            UIView.transition(with: notificationsTableView, duration: 0.3, options: .transitionCrossDissolve) {
                
                self.notificationsTableView.reloadData()
            }
        }
        
        else {
            
            var newCollabRequestFound: Bool = false
            
            var collabRequestIndexPaths: [IndexPath] = []
            var indexPathsToReload: [IndexPath] = []
            
            //Appending all the indexPaths in section 1, i.e. all the collab requests
            notificationsTableView.indexPathsForVisibleRows?.forEach({ if $0.section == 1 { collabRequestIndexPaths.append($0) } })
            
            for request in requests {
                
                //If this request has a matching cached collab request
                if let cachedCollabRequest = collabRequests?.first(where: { $0.collabID == request.collabID }) {
                    
                    var collabRequestIndexPath: IndexPath?
                        
                    for indexPath in collabRequestIndexPaths {
                        
                        //Finds the indexPath for this collab request
                        if let cell = notificationsTableView.cellForRow(at: indexPath) as? CollabRequestCell, cell.collabRequest?.collabID == request.collabID {
                            
                            collabRequestIndexPath = indexPath
                            break
                        }
                    }
                    
                    //If this request has a new cover photo
                    if cachedCollabRequest.coverPhotoID != request.coverPhotoID {
                        
                        if collabRequestIndexPath != nil {
                            
                            indexPathsToReload.append(collabRequestIndexPath!)
                        }
                    }
                    
                    //If this request has a new name
                    else if cachedCollabRequest.name != request.name {
                        
                        if collabRequestIndexPath != nil {
                            
                            indexPathsToReload.append(collabRequestIndexPath!)
                        }
                    }
                    
                    //If this request has a new deadline
                    else if cachedCollabRequest.dates["deadline"] != request.dates["deadline"] {
                        
                        if collabRequestIndexPath != nil {
                            
                            indexPathsToReload.append(collabRequestIndexPath!)
                        }
                    }
                    
                    //If this request has added, removed, or swapped out members
                    else if (cachedCollabRequest.currentMembers.count != request.currentMembers.count) || !(request.currentMembersIDs.allSatisfy({ cachedCollabRequest.currentMembersIDs.contains($0) })) {
                        
                        if collabRequestIndexPath != nil {
                            
                            indexPathsToReload.append(collabRequestIndexPath!)
                        }
                    }
                }
                
                //If this is a new request
                else {
                    
                    newCollabRequestFound = true
                    break
                }
            }
            
            //Sorting the requests by the date they were sent
            collabRequests = requests.sorted(by: { $0.requestSentOn?[currentUser.userID] ?? Date() > $1.requestSentOn?[currentUser.userID] ?? Date() })
            
            if !newCollabRequestFound {
                
                if indexPathsToReload.count == 1 {
        
                    notificationsTableView.reloadRows(at: indexPathsToReload, with: .none)
                }
        
                else if indexPathsToReload.count > 1 {
        
                    notificationsTableView.reloadRows(at: indexPathsToReload, with: .fade)
                }
            }
            
            //Reloads the tableView if a new request was found
            else {
                
                UIView.transition(with: notificationsTableView, duration: 0.3, options: .transitionCrossDissolve) {
                    
                    self.notificationsTableView.reloadData()
                }
            }
        }
    }
    
    
    //MARK: - Present Animation View
    
    private func presentAnimationView () {
        
        if let friendRequestsCount = friendRequests?.count, let collabRequestsCount = collabRequests?.count {
            
            //If there are no requests
            if friendRequestsCount == 0 && collabRequestsCount == 0 {
                
                notificationsTableView.isUserInteractionEnabled = false
                
                if animationView.alpha != 1 {
                    
                    animationView.play()
                    
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                        
                        self.friendRequestsHeader.alpha = 0
                        self.collabRequestsHeader.alpha = 0
                        
                        self.animationView.alpha = 1
                        self.animationTitleLabel.alpha = 1
                    }
                }
            }
            
            else {
                
                if animationView.alpha != 0 {
                    
                    notificationsTableView.isUserInteractionEnabled = true
                    
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                        
                        self.friendRequestsHeader.alpha = 1
                        self.collabRequestsHeader.alpha = 1
                        
                        self.animationView.alpha = 0
                        self.animationTitleLabel.alpha = 0
                        
                    } completion: { (finished: Bool) in
                        
                        self.animationView.stop()
                    }
                }
            }
        }
    }
    
    
    //MARK: - Show All Requests Pressed
    
    @objc private func showAllFriendRequestsButtonPressed () {
        
        showAllFriendRequests = !showAllFriendRequests
        
        showAllFriendRequestsButton.setImage(showAllFriendRequests ? UIImage(systemName: "chevron.up.circle.fill") : UIImage(systemName: "chevron.down.circle.fill"), for: .normal)
        
        notificationsTableView.beginUpdates()
        notificationsTableView.endUpdates()
    }
    
    @objc private func showAllCollabRequestsButtonPressed () {
        
        showAllCollabRequests = !showAllCollabRequests
        
        showAllCollabRequestsButton.setImage(showAllCollabRequests ? UIImage(systemName: "chevron.up.circle.fill") : UIImage(systemName: "chevron.down.circle.fill"), for: .normal)
        
        notificationsTableView.beginUpdates()
        notificationsTableView.endUpdates()
    }
}


//MARK: - UITableView DataSource and Delegate Extension

extension NotificationsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return (friendRequests?.count ?? 0) * 2
        }
        
        else {
            
            return (collabRequests?.count ?? 0) * 2
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return section == 0 ? friendRequestsHeader : collabRequestsHeader
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
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
        
        else {
            
            if indexPath.row % 2 == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "collabRequestCell", for: indexPath) as! CollabRequestCell
                cell.selectionStyle = .none
                
                cell.formatter = formatter

                cell.collabRequest = collabRequests?[indexPath.row / 2]
                
                cell.collabRequestDelegate = self
                
                cell.animateHiddenViews(animate: false, hide: !(indexPath == selectedCollabRequest))
                
                return cell
            }
            
            else {
                
                let cell = UITableViewCell()
                cell.isUserInteractionEnabled = false
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row % 2 == 0 {
            
            if indexPath.section == 0 {
                
                if showAllFriendRequests {
                    
                    return indexPath == selectedFriendRequest ? 125 : 80
                }
                
                else {
                    
                    //The first 5 requests
                    if indexPath.row <= 9 {
                        
                        return indexPath == selectedFriendRequest ? 125 : 80
                    }
                    
                    else {
                        
                        //Hides every other request
                        return 0
                    }
                }
            }
            
            else {
                
                if showAllCollabRequests {
                    
                    return indexPath == selectedCollabRequest ? 218 : 80
                }
                
                else {
                    
                    //The first 5 requests
                    if indexPath.row <= 9 {
                        
                        return indexPath == selectedCollabRequest ? 218 : 80
                    }
                    
                    else {
                        
                        //Hides every other request
                        return 0
                    }
                }
            }
        }
        
        //Buffer cell
        else {
            
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    
        if section == 0 {
            
            return friendRequests?.count ?? 0 > 0 ? 45 : 0
        }
        
        else {
            
            return collabRequests?.count ?? 0 > 0 ? 45 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let tableViewExpandedHeight = self.view.frame.height - topBarHeight
        
        if tableView.contentSize.height > tableViewExpandedHeight {
            
            //If the last cell is about to be presented
            if indexPath.row + 1 == tableView.numberOfRows(inSection: (collabRequests?.count ?? 0) > 0 ? 1 : 0) {
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {

                    self.tabBar.alpha = 0
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        //If the last cell is about to be dismissed
        if indexPath.row + 1 == tableView.numberOfRows(inSection: (collabRequests?.count ?? 0) > 0 ? 1 : 0) {

            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {

                self.tabBar.alpha = 1
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? FriendRequestCell {
            
            cell.animateButtons(animate: true, hide: indexPath == selectedFriendRequest)
            
            selectedFriendRequest = indexPath == selectedFriendRequest ? nil : indexPath
            
            notificationsTableView.beginUpdates()
            notificationsTableView.endUpdates()
        }
        
        else if let cell = tableView.cellForRow(at: indexPath) as? CollabRequestCell {
            
            cell.animateHiddenViews(animate: true, hide: indexPath == selectedCollabRequest)
            
            selectedCollabRequest = indexPath == selectedCollabRequest ? nil : indexPath
            
            notificationsTableView.beginUpdates()
            notificationsTableView.endUpdates()
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        //Full height the tableView can be expanded to
        let tableViewExpandedHeight = self.view.frame.height - topBarHeight
        
        //If all the cells won't fit into a fully expanded tableView
        if notificationsTableView.contentSize.height > tableViewExpandedHeight {
            
            if velocity.y < 0 {
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {

                    self.tabBar.alpha = 1
                })
            }
            
            else if velocity.y > 0.5 {

                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {

                    self.tabBar.alpha = 0
                })
            }
        }
    }
}


//MARK: - Friend Request Protocol

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


//MARK: - Collab Request Protocol

extension NotificationsViewController: CollabRequestProtocol {
    
    func acceptCollabRequest(_ collabRequest: Collab) {
        
        selectedCollabRequest = nil
        
        firebaseCollab.acceptCollabRequest(collabRequest.collabID)
    }
    
    func declineCollabRequest(_ collabRequest: Collab) {
        
        selectedCollabRequest = nil
        
        firebaseCollab.declineCollabRequest(collabRequest)
    }
}
