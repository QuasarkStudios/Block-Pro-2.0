//
//  AddMembersViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/12/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol MembersAdded: AnyObject {
    
    func membersAdded (_ addedMembers: [Any])
}

class AddMembersViewController: UIViewController, UITextFieldDelegate {
    
    let navBarExtensionView = UIView()
    
    let membersTableView = UITableView()
    
    lazy var searchBar = SearchBar(parentViewController: self, placeholderText: "Search")
    
    let memberCountContainer = UIView()
    let memberCountLabel = UILabel()
    
    let currentUser = CurrentUser.sharedInstance
    let firebaseCollab = FirebaseCollab.sharedInstance
    
    var members: [Any]?
    var filteredMembers: [Any] = []
    
    //Set to be an empty dictionary from previous view controller
    var addedMembers: [String : Any]? {
        didSet {
            
            if addedMembers?.count ?? 0 != 0 {
                
                memberCountLabel.text = "\((addedMembers?.count ?? 0))/5"
            }
            
            animateCountContainer()
        }
    }
    
    weak var membersAddedDelegate: MembersAdded?
    
    var headerLabelText: String? {
        didSet {
            
            self.title = headerLabelText
        }
    }
    
    var searchBeingConducted: Bool = false
    var viewAppeared: Bool = false
    var shouldPresentCountContainer: Bool = true
    
    var navBarExtensionHeightAnchor: NSLayoutConstraint?
    var tableViewTopAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isModalInPresentation = true
        
        configureNavBar()
        configureMembersTableView() //Call here to allow link between navBar and tableView to be established correctly
        configureNavBarExtensionView()
        configureSearchBar()
        configureMemberCountContainer()
        configureGestureRecognizors()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewAppeared = true
    }
    
    
    //MARK: - Configure Nav Bar
    
    private func configureNavBar () {
        
        //If the previous view controller wasn't already presented modally; meaning that a new navigation controller was intialized for this view and that there is no back button added to the navBar
        if navigationController?.viewControllers.count == 1 {
            
            self.navigationController?.navigationBar.configureNavBar()
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(hexString: "222222") as Any, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.bold)]
            
            self.navigationItem.largeTitleDisplayMode = .always
            
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(cancelButtonPressed))
            cancelButton.style = .done
            
            self.navigationItem.leftBarButtonItem = cancelButton
        }
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        doneButton.style = .done
        
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    
    //MARK: - Configure Table View
    
    private func configureMembersTableView () {
        
        self.view.addSubview(membersTableView)
        membersTableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            membersTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            membersTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            membersTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        membersTableView.dataSource = self
        membersTableView.delegate = self
        
        membersTableView.separatorStyle = .none
        membersTableView.showsVerticalScrollIndicator = false
        
        membersTableView.register(UINib(nibName: "MembersTableViewCell", bundle: nil), forCellReuseIdentifier: "membersTableViewCell")
    }
    
    
    //MARK: - Configure Nav Bar Extension
    
    private func configureNavBarExtensionView () {
        
        self.view.addSubview(navBarExtensionView)
        navBarExtensionView.translatesAutoresizingMaskIntoConstraints = false
        
        [

            navBarExtensionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            navBarExtensionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            navBarExtensionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),

        ].forEach({ $0.isActive = true })

        navBarExtensionHeightAnchor = navBarExtensionView.heightAnchor.constraint(equalToConstant: 77)
        navBarExtensionHeightAnchor?.isActive = true
        
        tableViewTopAnchor = membersTableView.topAnchor.constraint(equalTo: navBarExtensionView.bottomAnchor, constant: 0)
        tableViewTopAnchor?.isActive = true
        
        navBarExtensionView.backgroundColor = .white
        navBarExtensionView.clipsToBounds = true
    }
    
    
    //MARK: - Configure Search Bar
    
    private func configureSearchBar () {
        
        navBarExtensionView.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            searchBar.leadingAnchor.constraint(equalTo: self.navBarExtensionView.leadingAnchor, constant: 25),
            searchBar.trailingAnchor.constraint(equalTo: self.navBarExtensionView.trailingAnchor, constant: -25),
            searchBar.bottomAnchor.constraint(equalTo: self.navBarExtensionView.bottomAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 37)
        
        ].forEach({ $0.isActive = true })
    }
    
    
    //MARK: - Configure Member Count Container
    
    private func configureMemberCountContainer () {
        
        self.view.addSubview(memberCountContainer)
        memberCountContainer.translatesAutoresizingMaskIntoConstraints = false
        
        memberCountContainer.addSubview(memberCountLabel)
        memberCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            memberCountContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? -50 : -15),
            memberCountContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? -34 : -15),
            memberCountContainer.widthAnchor.constraint(equalToConstant: 55),
            memberCountContainer.heightAnchor.constraint(equalToConstant: 55),
            
            memberCountLabel.leadingAnchor.constraint(equalTo: memberCountContainer.leadingAnchor, constant: 0),
            memberCountLabel.trailingAnchor.constraint(equalTo: memberCountContainer.trailingAnchor, constant: 0),
            memberCountLabel.topAnchor.constraint(equalTo: memberCountContainer.topAnchor, constant: 0),
            memberCountLabel.bottomAnchor.constraint(equalTo: memberCountContainer.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        memberCountContainer.backgroundColor = UIColor(hexString: "222222")
        memberCountContainer.alpha = addedMembers?.count ?? 0 > 0 ? 1 : 0
        
        memberCountContainer.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        memberCountContainer.layer.shadowOpacity = 0.35
        memberCountContainer.layer.shadowRadius = 2
        memberCountContainer.layer.shadowOffset = CGSize(width: 0, height: 1)

        memberCountContainer.layer.cornerRadius = 55 * 0.5
        memberCountContainer.layer.cornerCurve = .continuous
        
        memberCountLabel.backgroundColor = .clear
        memberCountLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
        memberCountLabel.textColor = .white
        memberCountLabel.textAlignment = .center
    }
    
    
    //MARK: - Configure Gesture Recognizors
    
    private func configureGestureRecognizors () {
        
        let downSwipeGesture = UISwipeGestureRecognizer()
        downSwipeGesture.delegate = self
        downSwipeGesture.direction = .down
        downSwipeGesture.addTarget(self, action: #selector(swipDownGesture))
        self.view.addGestureRecognizer(downSwipeGesture)
        
        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dimissKeyboard))
        dismissKeyboardGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardGesture)
    }
    
    
    //MARK: - Search Text Changed
    
    func searchTextChanged(searchText: String) {
        
        filteredMembers.removeAll()
        
        if searchText.leniantValidationOfTextEntered() {
            
            searchBeingConducted = true
            
            for member in members ?? [] {
                
                if let currentMember = member as? Member {
                    
                    //If either the first or last name of the current member contains text from the searchBar
                    if currentMember.firstName.localizedCaseInsensitiveContains(searchText) || currentMember.lastName.localizedCaseInsensitiveContains(searchText) {
                        
                        filteredMembers.append(currentMember)
                    }
                }
                
                //If either the first or last name of the current member contains text from the searchBar
                else if let currentMember = member as? Friend {
                    
                    if currentMember.firstName.localizedCaseInsensitiveContains(searchText) || currentMember.lastName.localizedCaseInsensitiveContains(searchText) {
                        
                        filteredMembers.append(currentMember)
                    }
                }
            }
        }
        
        else {
            
            searchBeingConducted = false
        }
        
        membersTableView.reloadData()
    }
    
    
    //MARK: - Animate Count Container
    
    private func animateCountContainer () {
        
        if viewAppeared, shouldPresentCountContainer {
            
            if addedMembers?.count ?? 0 > 0 {

                //If the memberCountContainer isn't already visible
                if memberCountContainer.alpha == 0 {

                    UIView.animate(withDuration: 0.3) {

                        self.memberCountContainer.alpha = 1
                    }
                }
            }

            else {

                //If the memberCountContainer isn't already hidden
                if memberCountContainer.alpha == 1 {

                    UIView.animate(withDuration: 0.3) {

                        self.memberCountContainer.alpha = 0
                    }
                }
            }
        }
    }
    
    
    //MARK: - Dismiss Keyboard
    
    @objc private func dimissKeyboard () {
        
        searchBar.searchTextField.endEditing(true)
    }
    
    
    //MARK: - Swipe Down Gesture
    
    @objc private func swipDownGesture () {
        
        if membersTableView.contentOffset.y <= 0 {
            
            //Expands the navBarExtensionView when the view is swipped down
            navBarExtensionHeightAnchor?.constant = 75
    
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
    
                self.view.layoutIfNeeded()
            }
        }
    }

    
    //MARK: - Button Functions
    
    @objc private func cancelButtonPressed () {
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneButtonPressed () {
        
        if addedMembers?.count ?? 0 == 0 {
            
            ProgressHUD.showError("Please add at least 1 member")
        }
        
        else {
            
            var membersToBeUsed: [Any] = []
            
            //Adding the value (either of type Member or Friend) to the array that will be used as a parameter
            addedMembers?.forEach { (member) in
                
                membersToBeUsed.append(member.value)
            }
            
            membersAddedDelegate?.membersAdded(membersToBeUsed)
        }
    }
}


//MARK: - Gesture Recognizor Extension

extension AddMembersViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


//MARK: - Table View Extension

extension AddMembersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !searchBeingConducted {
            
            return (members?.count ?? 0) * 2
        }
        
        else {
            
            return filteredMembers.count * 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            
            if !searchBeingConducted {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "membersTableViewCell", for: indexPath) as! MembersTableViewCell
                cell.selectionStyle = .none
                
                ////////////////////////////////////////////////////////////////////
                if let member = members?[indexPath.row / 2] as? Member {
                    
                    cell.memberUserID = member.userID
                    cell.nameLabel.text = member.firstName + " " + member.lastName
                    cell.profilePicImageView.configureProfileImageView(profileImage: member.profilePictureImage)
                }
                
                else if let member = members?[indexPath.row / 2] as? Friend {
                    
                    cell.memberUserID = member.userID
                    cell.nameLabel.text = member.firstName + " " + member.lastName
                    cell.profilePicImageView.configureProfileImageView(profileImage: member.profilePictureImage)
                }
                
                ////////////////////////////////////////////////////////////////////
                if let member = members?[indexPath.row / 2] as? Member {
                    
                    if addedMembers?[member.userID] != nil {
                        
                        cell.addedIndicator.isHidden = false
                    }
                    
                    else {
                        
                        cell.addedIndicator.isHidden = true
                    }
                }
                
                else if let member = members?[indexPath.row / 2] as? Friend {
                    
                    if addedMembers?[member.userID] != nil {
                        
                        cell.addedIndicator.isHidden = false
                    }
                    
                    else {
                        
                        cell.addedIndicator.isHidden = true
                    }
                }
                
                return cell
            }
            
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "membersTableViewCell", for: indexPath) as! MembersTableViewCell
                cell.selectionStyle = .none
                
                ////////////////////////////////////////////////////////////////////
                if let member = filteredMembers[indexPath.row / 2] as? Member {
                    
                    cell.memberUserID = member.userID
                    cell.nameLabel.text = member.firstName + " " + member.lastName
                    cell.profilePicImageView.configureProfileImageView(profileImage: member.profilePictureImage)
                }
                
                else if let member = filteredMembers[indexPath.row / 2] as? Friend {
                    
                    cell.memberUserID = member.userID
                    cell.nameLabel.text = member.firstName + " " + member.lastName
                    cell.profilePicImageView.configureProfileImageView(profileImage: member.profilePictureImage)
                }
                
                ////////////////////////////////////////////////////////////////////
                if let member = filteredMembers[indexPath.row / 2] as? Member {
                    
                    if addedMembers?[member.userID] != nil {
                        
                        cell.addedIndicator.isHidden = false
                    }
                    
                    else {
                        
                        cell.addedIndicator.isHidden = true
                    }
                }
                
                else if let member = filteredMembers[indexPath.row / 2] as? Friend {
                    
                    if addedMembers?[member.userID] != nil {
                        
                        cell.addedIndicator.isHidden = false
                    }
                    
                    else {
                        
                        cell.addedIndicator.isHidden = true
                    }
                }
                
                return cell
            }
            
        }
        
        else {
            
            let cell = UITableViewCell()
            cell.isUserInteractionEnabled = false
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row % 2 == 0 {
            
            return 70
        }
        
        else {
            
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! MembersTableViewCell
        tableView.deselectRow(at: indexPath, animated: true)
        
        //If the maximum amount of members hasn't been reached yet
        if addedMembers?.count ?? 0 < 5 {
            
            cell.addedIndicator.isHidden = !cell.addedIndicator.isHidden
            
            //If a member has been removed
            if cell.addedIndicator.isHidden {
                
                addedMembers?.removeValue(forKey: cell.memberUserID)
            }
            
            //If a member has been added
            else {
                
                if !searchBeingConducted {
                    
                    if let member = members?[indexPath.row / 2] as? Member {
                        
                        addedMembers?[cell.memberUserID] = member
                    }
                    
                    else if let member = members?[indexPath.row / 2] as? Friend {
                        
                        addedMembers?[cell.memberUserID] = member
                    }
                }
                
                else {
                    
                    if let member = filteredMembers[indexPath.row / 2] as? Member {
                        
                        addedMembers?[cell.memberUserID] = member
                    }
                    
                    else if let member = filteredMembers[indexPath.row / 2] as? Friend {
                        
                        addedMembers?[cell.memberUserID] = member
                    }
                }
            }
        }
        
        //If the maximum amount of members has been reached
        else {
            
            if !cell.addedIndicator.isHidden {
                
                cell.addedIndicator.isHidden = true
                
                addedMembers?.removeValue(forKey: cell.memberUserID)
            }
            
            else {
                
                ProgressHUD.showError("Sorry, only 5 members can be added")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //Full height the tableView can be expanded to; i.e. (height of the view - the navigation bar height)
        let tableViewExpandedHeight = Int(self.view.frame.height - 44)
        
        //Height of the content in the tableView; i.e. all the cells (height all of the homeCells + the height of all the seperator cells; don't use the contentSize property of the tableView cause it sometimes returns an incorrect value)
        let tableViewContentSize = ((tableView.numberOfRows(inSection: 0) / 2) * 70) + ((tableView.numberOfRows(inSection: 0) / 2) * 10)
        
        //If all the cells won't fit into a fully expanded tableView
        if tableViewContentSize > tableViewExpandedHeight {
            
            //If the last cell is about to be presented
            if indexPath.row + 1 == tableView.numberOfRows(inSection: 0) {
                
                shouldPresentCountContainer = false
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    
                    self.memberCountContainer.alpha = 0
                }
            }
        }
        
        else {
            
            //If the last cell is about to be presented
            if indexPath.row + 1 == tableView.numberOfRows(inSection: 0) {
                
                let bottomInset: CGFloat = addedMembers?.count ?? 0 > 0 ? 60 : 0
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    
                    tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
                    
                    self.memberCountContainer.alpha = self.addedMembers?.count ?? 0 > 0 ? 1 : 0
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //If the last cell is about to be dismissed
        if indexPath.row + 1 == tableView.numberOfRows(inSection: 0) {
            
            shouldPresentCountContainer = true
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                
                self.memberCountContainer.alpha = self.addedMembers?.count ?? 0 > 0 ? 1 : 0
            }
        }
    }
    
    
    //MARK: - ScrollView Delegate Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y >= 0 {
            
            //If the navBarExtensionView hasn't been completely shrunken yet
            if ((navBarExtensionHeightAnchor?.constant ?? 0) - scrollView.contentOffset.y) > 0 {
                
                navBarExtensionHeightAnchor?.constant -= scrollView.contentOffset.y
                scrollView.contentOffset.y = 0
            }
            
            else {
                
                navBarExtensionHeightAnchor?.constant = 0
            }
        }
        
        else {
            
            //If the navBarExtensionView hasn't been completely expanded
            if navBarExtensionHeightAnchor?.constant ?? 0 < 77 {

                navBarExtensionHeightAnchor?.constant = 70
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {

                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}
