//
//  FriendsViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/15/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController {

    let searchBarContainer = UIView()
    lazy var searchBar = SearchBar(parentViewController: self, placeholderText: "Search")
    
    let friendsTableView = UITableView()
    let pendingFriendsHeader = UIView()
    let friendsHeader = UIView()
    let showAllPendingFriendsButton = UIButton(type: .system)
    
    let noFriendsImageViewContainer = UIView()
    let noFriendsImageView = UIImageView(image: UIImage(named: "friends"))
    let noFriendsLabel = UILabel()
    
    let tabBar = CustomTabBar.sharedInstance
    
    let currentUser = CurrentUser.sharedInstance
    let firebaseCollab = FirebaseCollab.sharedInstance
    
    var pendingFriends: [Friend] = []
    var friends: [Friend] = []
    
    var filteredPendingFriends: [Friend] = []
    var filteredFriends: [Friend] = []
    
    var searchBeingConducted: Bool = false
    var showAllPendingFriends: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Friends"
        
        self.view.backgroundColor = .white
        
        determineFriends()
        
        configureSearchBarContainer()
        configureSearchBar()
        
        configureTableView(friendsTableView)
        configureTableViewSectionHeaderView(0)
        configureTableViewSectionHeaderView(1)
        
        configureNoFriendsImageViewContainer()
        configureNoFriendsImageView()
        configureNoFriendsLabel()
        
        addObservors()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: - Configure Search Bar Container
    
    private func configureSearchBarContainer () {
        
        self.view.addSubview(searchBarContainer)
        searchBarContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            searchBarContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            searchBarContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            searchBarContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            searchBarContainer.heightAnchor.constraint(equalToConstant: 57)
        
        ].forEach({ $0.isActive = true })
        
        searchBarContainer.alpha = friends.count > 0 || pendingFriends.count > 0 ? 1 : 0
    }
    
    
    //MARK: - Configure Search Bar
    
    private func configureSearchBar () {
        
        searchBarContainer.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            searchBar.leadingAnchor.constraint(equalTo: searchBarContainer.leadingAnchor, constant: 25),
            searchBar.trailingAnchor.constraint(equalTo: searchBarContainer.trailingAnchor, constant: -25),
            searchBar.topAnchor.constraint(equalTo: searchBarContainer.topAnchor, constant: 20),
            searchBar.heightAnchor.constraint(equalToConstant: 37)
        
        ].forEach({ $0.isActive = true })
    }
    
    
    //MARK: - Configure Table View
    
    private func configureTableView (_ tableView: UITableView) {
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            tableView.topAnchor.constraint(equalTo: searchBarContainer.bottomAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 75, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 75, right: 0)
        
        tableView.delaysContentTouches = false
        tableView.separatorStyle = .none
        
        tableView.register(FriendCell.self, forCellReuseIdentifier: "friendCell")
    }
    
    
    //MARK: - Configure No Friends Container
    
    private func configureNoFriendsImageViewContainer () {
        
        self.view.addSubview(noFriendsImageViewContainer)
        noFriendsImageViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            noFriendsImageViewContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            noFriendsImageViewContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            noFriendsImageViewContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            noFriendsImageViewContainer.heightAnchor.constraint(equalToConstant: (tabBar.frame.minY - topBarHeight) * 0.75)
        
        ].forEach({ $0.isActive = true })
        
        noFriendsImageViewContainer.isUserInteractionEnabled = false
    }
    
    
    //MARK: - Configure No Friends Image View
    
    private func configureNoFriendsImageView () {
        
        let imageViewProposedWidth = UIScreen.main.bounds.width - 50
        let imageViewProposedHeight = (tabBar.frame.minY - topBarHeight) * 0.75
        
        let imageViewDimensionsConstant = min(imageViewProposedWidth, imageViewProposedHeight)
        
        self.view.addSubview(noFriendsImageView)
        noFriendsImageView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            noFriendsImageView.centerXAnchor.constraint(equalTo: noFriendsImageViewContainer.centerXAnchor, constant: 0),
            noFriendsImageView.centerYAnchor.constraint(equalTo: noFriendsImageViewContainer.centerYAnchor, constant: 0),
            noFriendsImageView.widthAnchor.constraint(equalToConstant: imageViewDimensionsConstant),
            noFriendsImageView.heightAnchor.constraint(equalToConstant: imageViewDimensionsConstant)
        
        ].forEach({ $0.isActive = true })
        
        noFriendsImageView.alpha = friends.count == 0 && pendingFriends.count == 0 ? 1 : 0
        noFriendsImageView.contentMode = .scaleAspectFit
    }
    
    
    //MARK: - Configure No Friends Label
    
    private func configureNoFriendsLabel () {
        
        self.view.addSubview(noFriendsLabel)
        noFriendsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            noFriendsLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            noFriendsLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            noFriendsLabel.topAnchor.constraint(equalTo: noFriendsImageView.bottomAnchor, constant: -10),
            noFriendsLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(UIScreen.main.bounds.height - tabBar.frame.minY) - 10)
        
        ].forEach({ $0.isActive = true })
        
        noFriendsLabel.alpha = friends.count == 0 && pendingFriends.count == 0 ? 1 : 0
        noFriendsLabel.numberOfLines = 0
        noFriendsLabel.font = UIFont(name: "Poppins-SemiBold", size: 25)
        noFriendsLabel.textAlignment = .center
        noFriendsLabel.text = "No Friends\nYet"
    }
    
    
    //MARK: - Configure Table View Section Header
    
    private func configureTableViewSectionHeaderView (_ section: Int) {
        
        let sectionHeaderView = section == 0 ? pendingFriendsHeader : friendsHeader
        let sectionLabel = UILabel()
        let showAllButton = section == 0 ? showAllPendingFriendsButton : nil
        
        sectionHeaderView.addSubview(sectionLabel)
        if showAllButton != nil { sectionHeaderView.addSubview(showAllButton!) }
        
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        showAllButton?.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            sectionLabel.topAnchor.constraint(equalTo: sectionHeaderView.topAnchor),
            sectionLabel.leadingAnchor.constraint(equalTo: sectionHeaderView.leadingAnchor, constant: 25),
            sectionLabel.widthAnchor.constraint(equalToConstant: 150),
            sectionLabel.heightAnchor.constraint(equalToConstant: 35),
            
            showAllButton?.trailingAnchor.constraint(equalTo: sectionHeaderView.trailingAnchor, constant: -17.5),
            showAllButton?.centerYAnchor.constraint(equalTo: sectionLabel.centerYAnchor),
            showAllButton?.widthAnchor.constraint(equalToConstant: 31),
            showAllButton?.heightAnchor.constraint(equalToConstant: 31)
        
        ].forEach({ $0?.isActive = true })
        
        sectionHeaderView.backgroundColor = .white
        
        sectionLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
        sectionLabel.textColor = .lightGray
        sectionLabel.textAlignment = .left
        sectionLabel.text = section == 0 ? "Pending Friends" : "Friends"
        
        showAllButton?.tintColor = UIColor(hexString: "222222")
        showAllButton?.setImage(UIImage(systemName: "chevron.down.circle.fill"), for: .normal)
        showAllButton?.contentVerticalAlignment = .fill
        showAllButton?.contentHorizontalAlignment = .fill
        
        //Pending Friends Section
        if section == 0 {

            showAllButton?.alpha = pendingFriends.count > 5 ? 1 : 0

            showAllButton?.addTarget(self, action: #selector(showAllPendingFriendsButtonPressed), for: .touchUpInside)
        }
    }
    
    
    //MARK: - Add Observors
    
    func addObservors () {
        
        NotificationCenter.default.addObserver(self, selector: #selector(friendsUpdated), name: .didUpdateFriends, object: nil)
    }
    
    
    //MARK: - Search Text Changed
    
    func searchTextChanged(searchText: String) {

        //Filters the users friends based on the searchText
        filterFriends(searchText)

        //Search is ongoing
        if searchText.leniantValidationOfTextEntered() {
            
            searchBeingConducted = true
            
            UIView.transition(with: friendsTableView, duration: 0.3, options: .transitionCrossDissolve) {
                
                self.friendsTableView.reloadData()
                
                self.showAllPendingFriendsButton.alpha = self.filteredPendingFriends.count > 5 ? 1 : 0
            }
        }
        
        //Search has ended
        else {
            
            searchBeingConducted = false
            
            UIView.transition(with: friendsTableView, duration: 0.3, options: .transitionCrossDissolve) {
                
                self.friendsTableView.reloadData()
                
                self.showAllPendingFriendsButton.alpha = self.pendingFriends.count > 5 ? 1 : 0
            }
        }
    }
    
    
    //MARK: - Determine Friends
    
    private func determineFriends () {
        
        var pendingFriendsToBeUsed: [Friend] = []
        firebaseCollab.friends.forEach({ if $0.accepted != true && $0.requestSentBy == currentUser.userID { pendingFriendsToBeUsed.append($0) } })
        pendingFriends = pendingFriendsToBeUsed.sorted(by: { $0.lastName < $1.lastName })
        
        var friendsToBeUsed: [Friend] = []
        firebaseCollab.friends.forEach({ if $0.accepted == true { friendsToBeUsed.append($0) } })
        friends = friendsToBeUsed.sorted(by: { $0.lastName < $1.lastName })
    }
    
    
    //MARK: - Filter Friends
    
    private func filterFriends (_ searchText: String) {
        
        filteredPendingFriends.removeAll()
        filteredFriends.removeAll()
        
        for pendingFriend in pendingFriends {
            
            if pendingFriend.firstName.localizedCaseInsensitiveContains(searchText) || pendingFriend.lastName.localizedCaseInsensitiveContains(searchText) || pendingFriend.username.localizedCaseInsensitiveContains(searchText) {
                
                filteredPendingFriends.append(pendingFriend)
            }
        }
        
        for friend in friends {
            
            if friend.firstName.localizedCaseInsensitiveContains(searchText) || friend.lastName.localizedCaseInsensitiveContains(searchText) || friend.username.localizedCaseInsensitiveContains(searchText) {
                
                filteredFriends.append(friend)
            }
        }
        
        filteredPendingFriends.sort(by: { $0.lastName < $1.lastName })
        filteredFriends.sort(by: { $0.lastName < $1.lastName })
    }
    
    
    //MARK: - Friends Updated
    
    @objc func friendsUpdated () {
        
        determineFriends()
        
        //Will filter the friends based on the searchText before reloading the tableView
        if searchBeingConducted {
            
            filterFriends(searchBar.searchTextField.text ?? "")
        }
        
        UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve) {
            
            self.searchBarContainer.alpha = self.friends.count > 0 || self.pendingFriends.count > 0 ? 1 : 0
            self.noFriendsImageView.alpha = self.friends.count == 0 && self.pendingFriends.count == 0 ? 1 : 0
            self.noFriendsLabel.alpha = self.friends.count == 0 && self.pendingFriends.count == 0 ? 1 : 0
            
            self.friendsTableView.reloadData()
            
            self.showAllPendingFriendsButton.alpha = self.searchBeingConducted ? (self.filteredPendingFriends.count > 5 ? 1 : 0) : (self.pendingFriends.count > 5 ? 1 : 0)
        }
    }
    
    
    //MARK: - Move to Friend Profile View
    
    private func moveToFriendProfileView (_ cell: FriendCell) {
        
        NotificationCenter.default.removeObserver(self)
        
        self.view.addSubview(tabBar)
        
        let friendProfileVC = FriendProfileViewController()
        friendProfileVC.modalPresentationStyle = .overCurrentContext
        
        friendProfileVC.friendCell = cell
        
        self.present(friendProfileVC, animated: false) {
            
            friendProfileVC.performZoomPresentationAnimation()
        }
    }
    
    
    //MARK: - Show All Pending Friends Button Pressed
    
    @objc private func showAllPendingFriendsButtonPressed () {
        
        showAllPendingFriends = !showAllPendingFriends
        
        showAllPendingFriendsButton.setImage(showAllPendingFriends ? UIImage(systemName: "chevron.up.circle.fill") : UIImage(systemName: "chevron.down.circle.fill"), for: .normal)
        
        friendsTableView.beginUpdates()
        friendsTableView.endUpdates()
    }
    
    
    //MARK: - Dismiss Keyboard
    
    @objc private func dismissKeyboard () {
        
        searchBar.searchTextField.resignFirstResponder()
    }
}


//MARK: - TableView DataSource and Delegate Extension

extension FriendsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //Pending Friends
        if section == 0 {
            
            return searchBeingConducted ? filteredPendingFriends.count * 2 : pendingFriends.count * 2
        }
        
        //Friends
        else {
            
            return searchBeingConducted ? filteredFriends.count * 2 : friends.count * 2
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return section == 0 ? pendingFriendsHeader : friendsHeader
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Pending Friends
        if indexPath.section == 0 {
            
            if indexPath.row % 2 == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendCell
                cell.selectionStyle = .none
                
                cell.friend = searchBeingConducted ? filteredPendingFriends[indexPath.row / 2] : pendingFriends[indexPath.row / 2]
                
                return cell
            }
            
            else {
                
                let cell = UITableViewCell()
                cell.selectionStyle = .none
                
                return cell
            }
        }
        
        //Friends
        else {
            
            if indexPath.row % 2 == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendCell
                cell.selectionStyle = .none
                
                cell.friend = searchBeingConducted ? filteredFriends[indexPath.row / 2] : friends[indexPath.row / 2]
                
                return cell
            }
            
            else {
                
                let cell = UITableViewCell()
                cell.selectionStyle = .none
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    
        //Pending Friends
        if section == 0 {
            
            return searchBeingConducted ? (filteredPendingFriends.count > 0 ? 45 : 0) : (pendingFriends.count > 0 ? 45 : 0)
        }
        
        //Friends
        else {
            
            //Will only show the "Friends" section header if there are pending friends
            if pendingFriends.count > 0 {
                
                return searchBeingConducted ? (filteredFriends.count > 0 ? 45 : 0) : (friends.count > 0 ? 45 : 0)
            }
            
            else {
                
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row % 2 == 0 {
            
            //Pending Friends
            if indexPath.section == 0 {
                
                if showAllPendingFriends {
                    
                    return 80
                }
                
                else {
                    
                    //The first 5 pending friends
                    if indexPath.row <= 9 {
                        
                        return 80
                    }
                    
                    else {
                        
                        //Hides every other pending friend
                        return 0
                    }
                }
            }
            
            //Friends
            else {
                
                return 80
            }
        }
        
        //Seperator Cell
        else {
            
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? FriendCell {
            
            moveToFriendProfileView(cell)
            
            //Done for the animation
            cell.profilePicture.layer.shadowColor = UIColor.clear.cgColor
            cell.profilePicture.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
