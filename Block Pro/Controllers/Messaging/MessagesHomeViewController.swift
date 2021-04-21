//
//  MessagesViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/10/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import Lottie
import SVProgressHUD

class MessagesHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var navBarExtensionView: UIView!
    @IBOutlet weak var navBarExtensionBottomAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var messagingHomeTableView: UITableView!
    @IBOutlet weak var messagingTableViewTopAnchor: NSLayoutConstraint!
    
    lazy var searchBar = SearchBar(parentViewController: self, placeholderText: "Search")
    
    let personalContainer = Personal_CollabContainer(containerType: "personal")
    let personalButton = UIButton()
    
    let collabContainer = Personal_CollabContainer(containerType: "collab")
    let collabButton = UIButton()

    let conversationsAnimationContainer = ConversationAnimation()
    
    let newConversationButton = UIButton(type: .system)
    lazy var tabBar = CustomTabBar.sharedInstance
    let deleteMessagesButton = UIButton(type: .system)
    
    let currentUser = CurrentUser.sharedInstance
    
    let firebaseMessaging = FirebaseMessaging.sharedInstance
    
    var personalConversations: [Conversation]? {
        didSet {

            guard let conversations = personalConversations else { return }

                populateEditConversationDictionary(conversations: conversations)
        }
    }

    var collabConversations: [Conversation]?
    
    var sortConversationsBy = SortConversation.defaultSort
    
    var selectedConversation: Conversation?
    
    var filteredConversations: [Conversation] = []
    var searchBeingConducted: Bool = false
    
    var viewEditing: Bool = false
    var shouldPresentCheckbox: Bool = false
    var editedConversations: [String : Bool] = [:]
    
    var selectedView: String = "personal"
    
    var loadingAnimationTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        
        navBarExtensionView.backgroundColor = .white
        
        configureSearchBar()
        configurePersonal_CollabContainers()
        configureNewConversationButton()
        configureDeleteConversationsButton()
        
        configureTableView(messagingHomeTableView)
        configureGestureRecognizors()
        
        addConversationListeners()
        
        messagingTableViewTopAnchor.constant = 65
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavBar()
        
        tabBar.shouldHide = false
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        
        if personalConversations?.count ?? 0 == 0 {
            
            editButtonItem.title = "Edit"
            editButtonItem.style = .done
        }
        
        else {
            
            editConversations(beginEditing: editing)
            
            if editing {
                
                hideNewConversationButton(hide: true)
                hideTabBar(hide: true)
            }
            
            else {
                
                editButtonItem.style = .done
                navigationItem.rightBarButtonItem = editButtonItem
                
                
                //Only unhides the newConversationButton if the Collab view is currently or going to be presented
                if selectedView == "personal" {
                    
                    hideNewConversationButton(hide: false)
                }
                
                hideTabBar(hide: false)
            }
        }
    }
    
    //MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBeingConducted || viewEditing {

            return filteredConversations.count * 2
        }
        
        else {

            if selectedView == "personal" {
                
                return (personalConversations?.count ?? 0) * 2
            }
            
            else {
                
                return (collabConversations?.count ?? 0) * 2
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            
            var conversationToBeUsed: Conversation?
            
            if searchBeingConducted || viewEditing {
                
                conversationToBeUsed = filteredConversations[indexPath.row / 2]
            }
            
            else {
                
                conversationToBeUsed = selectedView == "personal" ? personalConversations?[indexPath.row / 2] : collabConversations?[indexPath.row / 2]
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageHomeCell", for: indexPath) as! MessageHomeCell
            
            //Helps reconfigure the cell if the views have switched
            if selectedView == "personal" {
                
                cell.collabConversation = nil
                cell.personalConversation = conversationToBeUsed
            }
            
            else {
                
                cell.personalConversation = nil
                cell.collabConversation = conversationToBeUsed
            }
            
            if viewEditing && shouldPresentCheckbox {

                cell.checkBox.on = editedConversations[conversationToBeUsed?.conversationID ?? ""] ?? false
                cell.beginEditing(animate: false)
            }

            else if viewEditing && !shouldPresentCheckbox {

                cell.checkBox.on = editedConversations[conversationToBeUsed?.conversationID ?? ""] ?? false
                cell.endEditing(animate: false)
            }

            else if !viewEditing {

                cell.endEditing(animate: false)
            }
            
            cell.selectionStyle = .none
            
            return cell
        }
        
        else {

            let cell = UITableViewCell()
            cell.selectionStyle = .none
            cell.isUserInteractionEnabled = false
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row % 2 == 0 {
            
            return 80
        }
        
        else {
            
            return 5
        }
    }
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if viewEditing {
            
            let cell = tableView.cellForRow(at: indexPath) as! MessageHomeCell
            
            if selectedView == "personal" {
                    
                cell.checkBox.setOn(!(editedConversations[cell.personalConversation!.conversationID] ?? false), animated: true)
                
                editedConversations[cell.personalConversation!.conversationID] = !(editedConversations[cell.personalConversation!.conversationID] ?? false)
            }
            
            //Checks to see if any conversations have been selected
            if editedConversations.first(where: { $0.value == true } ) != nil {
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.deleteMessagesButton.backgroundColor = .flatRed()
                    
                }) { (finished: Bool) in
                    
                    self.deleteMessagesButton.isEnabled = true
                }
            }
            
            else {
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.deleteMessagesButton.backgroundColor = .lightGray
                    
                }) { (finished: Bool) in
                    
                    self.deleteMessagesButton.isEnabled = false
                }
            }
        }
            
        else if searchBeingConducted {
            
            selectedConversation = filteredConversations[indexPath.row / 2]
            
            performSegue(withIdentifier: "moveToMessagesView", sender: self)
        }
        
        else {
            
            selectedConversation = selectedView == "personal" ? personalConversations?[indexPath.row / 2] : collabConversations?[indexPath.row / 2]

            performSegue(withIdentifier: "moveToMessagesView", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0

        //Full height the tableView can be expanded to; i.e. (height of the view - the navigation bar height - the status bar height)
        let tableViewExpandedHeight = Int(self.view.frame.height - 44 - statusBarHeight)

        //Height of the content in the tableView; i.e. all the cells (height all of the homeCells + the height of all the seperator cells; don't use the contentSize property of the tableView cause it sometimes returns an incorrect value)
        let tableViewContentSize = (messagingHomeTableView.numberOfRows(inSection: 0) / 2) * 80 + ((messagingHomeTableView.numberOfRows(inSection: 0) / 2) * 5)
        
        //If all the cells won't fit into a fully expanded tableView
        if tableViewContentSize > tableViewExpandedHeight {
            
            //If the last cell is about to be presented
            if indexPath.row + 1 == tableView.numberOfRows(inSection: 0) {
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.messagingHomeTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    self.messagingHomeTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    
                    self.newConversationButton.alpha = 0
                    self.tabBar.alpha = 0
                    
                    self.deleteMessagesButton.alpha = 0
                })
            }
        }
        
        else {
            
            //If the last cell is about to be presented
            if indexPath.row + 1 == tableView.numberOfRows(inSection: 0) {
                
                //Bottom inset if view is not editing is 5 points larger than the navBarExtensionView
                let bottomInset: CGFloat = !viewEditing ? 130 : (self.view.frame.height) - deleteMessagesButton.frame.minY
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    
                    if self.navigationController?.visibleViewController == self {
                        
                        self.messagingHomeTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
                        self.messagingHomeTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset + 15, right: 0)
                        
                        self.newConversationButton.alpha = !self.viewEditing ? 1 : 0
                        self.tabBar.alpha = !self.viewEditing ? 1 : 0
                        
                        self.deleteMessagesButton.alpha = self.viewEditing ? 1 : 0
                    }
                })
            }
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        //If the last cell is about to be dismissed
        if indexPath.row + 1 == tableView.numberOfRows(inSection: 0) {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                
                if self.navigationController?.visibleViewController == self {
                    
//                    self.messagingHomeTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//                    self.messagingHomeTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    
                    self.newConversationButton.alpha = !self.viewEditing ? 1 : 0
                    self.tabBar.alpha = !self.viewEditing ? 1 : 0
                    
                    self.deleteMessagesButton.alpha = self.viewEditing ? 1 : 0
                }
            })
        }
    }
    
    
    //MARK: - ScrollView Delegate Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y >= 0 {

            //If the navBarExtensionView hasn't been completely shrunken yet
            if (messagingTableViewTopAnchor.constant - scrollView.contentOffset.y) > 0 {

                messagingTableViewTopAnchor.constant -= scrollView.contentOffset.y
                scrollView.contentOffset.y = 0
            }

            else {

                messagingTableViewTopAnchor.constant = 0
            }
        }

        else {

            //If the navBarExtensionView hasn't been completely expanded
            if messagingTableViewTopAnchor.constant < 125 {

                messagingTableViewTopAnchor.constant = 125

                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {

                    self.view.layoutIfNeeded()
                })
            }

            else {

                navBarExtensionBottomAnchor.constant = scrollView.contentOffset.y //Grows the view the more the tableView is scrolled down
            }
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        
        //Full height the tableView can be expanded to; i.e. (height of the view - the navigation bar height - the status bar height)
        let tableViewExpandedHeight = Int(self.view.frame.height - 44 - statusBarHeight)
        
        //Height of the content in the tableView; i.e. all the cells (height all of the homeCells + the height of all the seperator cells; don't use the contentSize property of the tableView cause it sometimes returns an incorrect value)
        let tableViewContentSize = (messagingHomeTableView.numberOfRows(inSection: 0) / 2) * 80 + ((messagingHomeTableView.numberOfRows(inSection: 0) / 2) * 5)
        
        //If all the cells won't fit into a fully expanded tableView
        if tableViewContentSize > tableViewExpandedHeight {

            if velocity.y < 0 {

                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {

                    self.newConversationButton.alpha = self.selectedView == "personal" && !self.viewEditing ? 1 : 0
                    self.tabBar.alpha = !self.viewEditing ? 1 : 0
                    
                    self.deleteMessagesButton.alpha = self.viewEditing ? 1 : 0
                })
            }

            else if velocity.y > 0.5 {

                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {

                    self.newConversationButton.alpha = 0
                    self.tabBar.alpha = 0
                    
                    self.deleteMessagesButton.alpha = 0
                })
            }
        }
    }
    
    
    //MARK: - Configure NavBar Function
    
    private func configureNavBar () {
        
        navigationController?.navigationBar.configureNavBar()
        navigationItem.title =  "Messages"
        
        if selectedView == "personal" {
            
            editButtonItem.style = .done
            navigationItem.rightBarButtonItem = editButtonItem
        }
        
        else {
            
            navigationItem.rightBarButtonItem = nil
        }
        
        navBarExtensionView.clipsToBounds = true
    }
    
    
    //MARK: - Configure SearchBar Function
    
    func configureSearchBar () {
        
        navBarExtensionView.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            searchBar.leadingAnchor.constraint(equalTo: navBarExtensionView.leadingAnchor, constant: 25),
            searchBar.trailingAnchor.constraint(equalTo: navBarExtensionView.trailingAnchor, constant: -25),
            searchBar.bottomAnchor.constraint(equalTo: navBarExtensionView.bottomAnchor, constant: -68),
            searchBar.heightAnchor.constraint(equalToConstant: 37)
        
        ].forEach({ $0.isActive = true })
    }
    
    
    //MARK: - Configure Personal_Collab Containers Function
    
    func configurePersonal_CollabContainers () {
        
        navBarExtensionView.addSubview(personalContainer)
        personalContainer.translatesAutoresizingMaskIntoConstraints = false
        
        navBarExtensionView.addSubview(personalButton)
        personalButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            personalContainer.leadingAnchor.constraint(equalTo: navBarExtensionView.leadingAnchor, constant: 27),
            personalContainer.bottomAnchor.constraint(equalTo: navBarExtensionView.bottomAnchor, constant: -15),
            personalContainer.widthAnchor.constraint(equalToConstant: 90),
            personalContainer.heightAnchor.constraint(equalToConstant: 30),
            
            personalButton.leadingAnchor.constraint(equalTo: navBarExtensionView.leadingAnchor, constant: 27),
            personalButton.bottomAnchor.constraint(equalTo: navBarExtensionView.bottomAnchor, constant: -15),
            personalButton.widthAnchor.constraint(equalToConstant: 90),
            personalButton.heightAnchor.constraint(equalToConstant: 30)
        
        ].forEach({ $0.isActive = true })
        
        personalButton.addTarget(self, action: #selector(handlePersonalButtonTouchDown), for: .touchDown)
        personalButton.addTarget(self, action: #selector(handlePersonalButtonTouchDragExit), for: .touchDragExit)
        personalButton.addTarget(self, action: #selector(handlePersonalButtonTouchUpInside), for: .touchUpInside)
        personalButton.isEnabled = false
        
        navBarExtensionView.addSubview(collabContainer)
        collabContainer.translatesAutoresizingMaskIntoConstraints = false
        
        navBarExtensionView.addSubview(collabButton)
        collabButton.translatesAutoresizingMaskIntoConstraints = false
        
        [

            collabContainer.leadingAnchor.constraint(equalTo: personalContainer.trailingAnchor, constant: 20),
            collabContainer.bottomAnchor.constraint(equalTo: navBarExtensionView.bottomAnchor, constant: -15),
            collabContainer.widthAnchor.constraint(equalToConstant: 90),
            collabContainer.heightAnchor.constraint(equalToConstant: 30),

            collabButton.leadingAnchor.constraint(equalTo: personalContainer.trailingAnchor, constant: 20),
            collabButton.bottomAnchor.constraint(equalTo: navBarExtensionView.bottomAnchor, constant: -15),
            collabButton.widthAnchor.constraint(equalToConstant: 90),
            collabButton.heightAnchor.constraint(equalToConstant: 30)

        ].forEach({ $0.isActive = true })
        
        collabButton.addTarget(self, action: #selector(handleCollabButtonTouchDown), for: .touchDown)
        collabButton.addTarget(self, action: #selector(handleCollabButtonTouchDragExit), for: .touchDragExit)
        collabButton.addTarget(self, action: #selector(handleCollabButtonTouchUpInside), for: .touchUpInside)
        collabButton.isEnabled = false
    }

    
    //MARK: - Configure Conversations Animation Function
    
    private func configureConversationsAnimation (conversationsLoading: Bool) {
        
        //This topBarHeight accounts for the fact that this navigationController allows large titles
        let topBarHeight = (keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0) + (self.navigationController?.navigationBar.frame.height ?? 0)
        
        //Distance from the bottom of the navBarExtension view to the top of the addConversations button
        let containerHeight = ((tabBar.frame.minY - 85) - (topBarHeight + 65))
        
        self.view.addSubview(conversationsAnimationContainer)
        conversationsAnimationContainer.translatesAutoresizingMaskIntoConstraints = false

        [

            conversationsAnimationContainer.topAnchor.constraint(equalTo: navBarExtensionView.bottomAnchor, constant: 0),
            conversationsAnimationContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            conversationsAnimationContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            conversationsAnimationContainer.heightAnchor.constraint(equalToConstant: containerHeight)

        ].forEach({ $0.isActive = true })
        
        conversationsAnimationContainer.containerHeight = containerHeight
        
        //If the conversations are being loaded for the first time
        if conversationsLoading {
            
            loadingAnimationTimer = Timer(fireAt: Date(), interval: 0.7, target: conversationsAnimationContainer, selector: #selector(conversationsAnimationContainer.loadingAnimation), userInfo: nil, repeats: true)
            
            guard let timer = loadingAnimationTimer else { return }
            
                RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    
    //MARK: - Configure TableView Function
    
    private func configureTableView (_ tableView: UITableView) {
    
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        tableView.scrollsToTop = false
        
        tableView.alpha = 0

        tableView.register(UINib(nibName: "MessageHomeCell", bundle: nil), forCellReuseIdentifier: "messageHomeCell")
    }
    
    
    //MARK: - Configure Gesture Recognizors Function
    
    private func configureGestureRecognizors () {
        
        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardGesture)
    }
    
    
    //MARK: - Configure NewConversation Button Function
    
    private func configureNewConversationButton () {
        
        view.addSubview(newConversationButton)
        newConversationButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            newConversationButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -29),
            newConversationButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(self.view.frame.height - tabBar.frame.minY) - 25),
            newConversationButton.widthAnchor.constraint(equalToConstant: 60),
            newConversationButton.heightAnchor.constraint(equalToConstant: 60)
            
        ].forEach( { $0.isActive = true } )
        
        newConversationButton.layer.cornerRadius = 30
        newConversationButton.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        newConversationButton.layer.shadowRadius = 2
        newConversationButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        newConversationButton.layer.shadowOpacity = 0.65
        
        newConversationButton.backgroundColor = UIColor(hexString: "222222")
        newConversationButton.tintColor = .white
        newConversationButton.setImage(UIImage(named: "plus 2"/*"chat"*/), for: .normal)
        newConversationButton.addTarget(self, action: #selector(newMessageButtonPressed), for: .touchUpInside)
    
//        newConversationButton.imageEdgeInsets = UIEdgeInsets(top: 15.5, left: 15.5, bottom: 15.5, right: 15.5)
    }
    
    
    //MARK: - Configure DeleteConversations Button Function
    
    private func configureDeleteConversationsButton () {
        
        deleteMessagesButton.frame = tabBar.frame
        
        deleteMessagesButton.backgroundColor = .lightGray
        deleteMessagesButton.alpha = 0
        
        deleteMessagesButton.setTitle("Delete Messages", for: .normal)
        deleteMessagesButton.titleLabel?.font = UIFont(name: "Poppins-Semibold", size: 18)
        deleteMessagesButton.tintColor = .white
        
        deleteMessagesButton.layer.cornerRadius = 28.5
        
        deleteMessagesButton.isEnabled = false
        deleteMessagesButton.addTarget(self, action: #selector(deleteMessages), for: .touchUpInside)
        
        view.addSubview(deleteMessagesButton)
    }
    
    
    //MARK: - Add Conversation Listeners Functions
    
    private func addConversationListeners () {
        
        configureConversationsAnimation(conversationsLoading: true) //Will only be called once from here in viewDidLoad
        
        firebaseMessaging.retrievePersonalConversations { [weak self] (conversations, convoMembers, messagePreview, error) in

            if error != nil {

                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }

            else {

                if conversations != nil {

                    self?.personalConversations = conversations
                    self?.sortPersonalConversations()
                    
                    self?.personalConversationsUpdated(conversations)

                    if conversations?.count ?? 0 == 0 && self?.selectedView == "personal" {

                        self?.personalButton.isEnabled = true
                        self?.collabButton.isEnabled = true
                        
                        self?.handleConversationsAnimation(conversationsCount: conversations?.count ?? 0)
                    }
                }

                else if convoMembers != nil {

                    if let historicMembers = convoMembers?["historicMembers"], let currentMembers = convoMembers?["currentMembers"] {

                        self?.personalConversationMembersRetrieved(historicMembers: historicMembers, currentMembers: currentMembers)
                    }
                }

                else if messagePreview != nil {

                    self?.personalConversationPreviewRetrieved(message: messagePreview?["message"] as? Message)
                }
            }
        }

        firebaseMessaging.retrieveCollabConversations { [weak self] (conversations, convoMembers, messagePreview, error) in

            if error != nil {

                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }

            else {

                if conversations != nil {

                    self?.collabConversations = conversations
                    self?.sortCollabConversations()
                    
                    self?.collabConversationsUpdated(conversations)

                    if conversations?.count ?? 0 == 0 && self?.selectedView == "collab" {

                        self?.personalButton.isEnabled = true
                        self?.collabButton.isEnabled = true
                        self?.handleConversationsAnimation(conversationsCount: conversations?.count ?? 0)
                    }
                }

                else if convoMembers != nil {

                    if let historicMembers = convoMembers?["historicMembers"], let currentMembers = convoMembers?["currentMembers"] {

                        self?.collabConversationMembersRetrieved(historicMembers: historicMembers, currentMembers: currentMembers)
                    }
                }

                else if messagePreview != nil {

                    self?.collabConversationPreviewRetrieved(message: messagePreview?["message"] as? Message)
                }
            }
        }
    }
    
    
    //MARK: - Conversations Updated Functions
    
    private func personalConversationsUpdated (_ conversations: [Conversation]?) {

        for convo in conversations ?? [] {
            
            for indexPath in messagingHomeTableView.indexPathsForVisibleRows ?? [] {

                if let cell = messagingHomeTableView.cellForRow(at: indexPath) as? MessageHomeCell {

                    if let cellPersonalConvoID = cell.personalConversation?.conversationID, cellPersonalConvoID == convo.conversationID {

                        if cell.personalConversation?.conversationName != convo.conversationName {
                            
                            messagingHomeTableView.reloadRows(at: [indexPath], with: .none)
                            break
                        }
                        
                        else if cell.personalConversation?.coverPhotoID != convo.coverPhotoID {
                            
                            messagingHomeTableView.reloadRows(at: [indexPath], with: .none)
                            break
                        }
                        
                        else if cell.personalConversation?.memberActivity?[currentUser.userID] as? Date != convo.memberActivity?[currentUser.userID] as? Date {
                            
                            messagingHomeTableView.reloadRows(at: [indexPath], with: .none)
                            break
                        }
                    }
                }
            }
        }
    }
    
    private func collabConversationsUpdated (_ conversations: [Conversation]?) {
        
        for convo in conversations ?? [] {
            
            for indexPath in messagingHomeTableView.indexPathsForVisibleRows ?? [] {

                if let cell = messagingHomeTableView.cellForRow(at: indexPath) as? MessageHomeCell {

                    if let cellCollabConvoID = cell.collabConversation?.conversationID, cellCollabConvoID == convo.conversationID {

                        if cell.collabConversation?.conversationName != convo.conversationName {
                            
                            messagingHomeTableView.reloadRows(at: [indexPath], with: .none)
                            break
                        }
                        
                        else if cell.collabConversation?.coverPhotoID != convo.coverPhotoID {
                            
                            messagingHomeTableView.reloadRows(at: [indexPath], with: .none)
                            break
                        }
                        
                        else if cell.collabConversation?.memberActivity?[currentUser.userID] as? Date != convo.memberActivity?[currentUser.userID] as? Date {
                            
                            messagingHomeTableView.reloadRows(at: [indexPath], with: .none)
                            break
                        }
                    }
                }
            }
        }
    }
    
    
    //MARK: - Conversations Members Retrieved Functions
    
    private func personalConversationMembersRetrieved (historicMembers: [Member], currentMembers: [Member]) {
        
        sortPersonalConversations()
        
        if selectedView != "personal"{

            return
        }
        
        //Updates the filteredConversations when conversation members have changed
        if searchBeingConducted {
            
            searchTextChanged(searchText: searchBar.searchTextField.text ?? "")
            return //Returns out the function because "searchTextChanged" will handle the reloading of the tableView
        }
        
        else if viewEditing {
            
            filteredConversations = filterConversationWithMessages(conversations: personalConversations) ?? []
        }
        
        if conversationsFullyLoaded() {
            
            var indexPathsToReload: [IndexPath] = []
            let conversations: [Conversation]? = viewEditing ? filteredConversations : personalConversations
            
            //If no conversations have been added or removed
            if (messagingHomeTableView.numberOfRows(inSection: 0) / 2) == conversations?.count ?? 0 {
                
                for indexPath in messagingHomeTableView?.indexPathsForVisibleRows ?? [] {

                    if indexPath.row % 2 == 0 {
                            
                        if let cell = messagingHomeTableView.cellForRow(at: indexPath) as? MessageHomeCell {
                                
                            //If the amount of memebrs in the conversation has changed
                            if cell.personalConversation?.currentMembers.count ?? 0 != personalConversations?[indexPath.row / 2].currentMembers.count {
                                
                                indexPathsToReload.append(indexPath)
                            }
                            
                            else {
                                
                                //Checks to see if any members now exist that didn't previously
                                for member in cell.personalConversation?.currentMembers ?? [] {
                                    
                                    if personalConversations?[indexPath.row / 2].currentMembers.first(where: { $0.userID == member.userID }) == nil {
                                        
                                        indexPathsToReload.append(indexPath)
                                    }
                                }
                            }
                        }
                    }
                }
                        
                if indexPathsToReload.count == 0 {
                    
                    messagingHomeTableView.reloadData()
                }
                
                else if indexPathsToReload.count == 1 {
        
                    messagingHomeTableView.reloadRows(at: indexPathsToReload, with: .none)
                }
        
                else if indexPathsToReload.count > 1 {
        
                    messagingHomeTableView.reloadRows(at: indexPathsToReload, with: .fade)
                }
            }
            
            //If conversations have been added or removed
            else {
                
                messagingHomeTableView.reloadData()
            }
            
            personalButton.isEnabled = true
            collabButton.isEnabled = true
        }
    }
    
    private func collabConversationMembersRetrieved (historicMembers: [Member], currentMembers: [Member]) {
        
        sortCollabConversations()
        
        if selectedView != "collab"{
            
            return
        }
        
        //Updates the filteredConversations when conversation members have changed
        if searchBeingConducted {
            
            searchTextChanged(searchText: searchBar.searchTextField.text ?? "")
            return //Returns out the function because "searchTextChanged" will handle the reloading of the tableView
        }
        
        if conversationsFullyLoaded() {
            
            var indexPathsToReload: [IndexPath] = []
            
            //If no conversations have been added or removed
            if (messagingHomeTableView.numberOfRows(inSection: 0) / 2) == collabConversations?.count ?? 0 {
                
                for indexPath in messagingHomeTableView?.indexPathsForVisibleRows ?? [] {

                    if indexPath.row % 2 == 0 {
                            
                        if let cell = messagingHomeTableView.cellForRow(at: indexPath) as? MessageHomeCell {
                                
                            //If the amount of memebrs in the conversation has changed
                            if cell.collabConversation?.currentMembers.count ?? 0 != collabConversations?[indexPath.row / 2].currentMembers.count {

                                indexPathsToReload.append(indexPath)
                            }

                            else {

                                //Checks to see if any members now exist that didn't previously
                                for member in cell.collabConversation?.currentMembers ?? [] {

                                    if collabConversations?[indexPath.row / 2].currentMembers.first(where: { $0.userID == member.userID }) == nil {

                                        indexPathsToReload.append(indexPath)
                                    }
                                }
                            }
                        }
                    }
                }
                
                if indexPathsToReload.count == 0 {
                    
                    messagingHomeTableView.reloadData()
                }
                
                else if indexPathsToReload.count == 1 {
        
                    messagingHomeTableView.reloadRows(at: indexPathsToReload, with: .none)
                }
        
                else if indexPathsToReload.count > 1 {
        
                    messagingHomeTableView.reloadRows(at: indexPathsToReload, with: .fade)
                }
            }
            
            //If conversations have been added or removed
            else {
                
                messagingHomeTableView.reloadData()
            }
            
            personalButton.isEnabled = true
            collabButton.isEnabled = true
        }
    }

    //MARK: - Conversations Previews Retrieved Functions
    
    private func personalConversationPreviewRetrieved (message: Message?) {
        
        sortPersonalConversations()
        
        if selectedView != "personal"{
            
            return
        }
        
        //Updates the filteredConversations when conversation preview have changed
        if searchBeingConducted {
            
            searchTextChanged(searchText: searchBar.searchTextField.text ?? "")
            return //Returns out the function because "searchTextChanged" will handle the reloading of the tableView
        }
        
        else if viewEditing {
            
            filteredConversations = filterConversationWithMessages(conversations: personalConversations) ?? []
        }
        
        if conversationsFullyLoaded() {
            
            var indexPathsToReload: [IndexPath] = []
            let conversations: [Conversation]?
            
            if viewEditing {
                
                conversations = filteredConversations
            }
            
            else {
                
                conversations = personalConversations
            }
            
            //If no conversations have been added or removed
            if (messagingHomeTableView.numberOfRows(inSection: 0) / 2) == conversations?.count ?? 0 {
                
                for indexPath in messagingHomeTableView?.indexPathsForVisibleRows ?? [] {

                    if indexPath.row % 2 == 0 {
                            
                        if let cell = messagingHomeTableView.cellForRow(at: indexPath) as? MessageHomeCell {
                                
                            //If the last message of this conversation has changed
                            if cell.personalConversation?.messagePreview?.messageID != conversations?[indexPath.row / 2].messagePreview?.messageID {

                                indexPathsToReload.append(indexPath)
                            }
                        }
                    }
                }
                
                if indexPathsToReload.count == 0 {
                    
                    messagingHomeTableView.reloadData()
                }
                
                else if indexPathsToReload.count == 1 {
        
                    messagingHomeTableView.reloadRows(at: indexPathsToReload, with: .none)
                }
        
                else if indexPathsToReload.count > 1 {
                    
                    messagingHomeTableView.reloadRows(at: indexPathsToReload, with: .fade)
                }
            }
            
            //If conversations have been added or removed
            else {
                
                messagingHomeTableView.reloadData()
            }
            
            personalButton.isEnabled = true
            collabButton.isEnabled = true
        }
    }
    
    
    private func collabConversationPreviewRetrieved (message: Message?) {
        
        sortCollabConversations()
        
        if selectedView != "collab"{
            
            return
        }
        
        //Updates the filteredConversations when conversation preview have changed
        if searchBeingConducted {
            
            searchTextChanged(searchText: searchBar.searchTextField.text ?? "")
            return //Returns out the function because "searchTextChanged" will handle the reloading of the tableView
        }
        
        if conversationsFullyLoaded() {
            
            var indexPathsToReload: [IndexPath] = []
            
            //If no conversations have been added or removed
            if (messagingHomeTableView.numberOfRows(inSection: 0) / 2) == collabConversations?.count ?? 0 {
                
                for indexPath in messagingHomeTableView?.indexPathsForVisibleRows ?? [] {

                    if indexPath.row % 2 == 0 {
                            
                        if let cell = messagingHomeTableView.cellForRow(at: indexPath) as? MessageHomeCell {

                            //If the last message of this conversation has changed
                            if cell.collabConversation?.messagePreview?.messageID != collabConversations?[indexPath.row / 2].messagePreview?.messageID {

                                indexPathsToReload.append(indexPath)
                            }
                        }
                    }
                }
                
                if indexPathsToReload.count == 0 {
                    
                    messagingHomeTableView.reloadData()
                }
                
                else if indexPathsToReload.count == 1 {
        
                    messagingHomeTableView.reloadRows(at: indexPathsToReload, with: .none)
                }
        
                else if indexPathsToReload.count > 1 {
                    
                    messagingHomeTableView.reloadRows(at: indexPathsToReload, with: .fade)
                }
            }
            
            //If conversations have been added or removed
            else {
                
                messagingHomeTableView.reloadData()
            }
            
            personalButton.isEnabled = true
            collabButton.isEnabled = true
        }
    }
    
    
    //MARK: - Conversations Fully Loaded Functions
    
    private func conversationsFullyLoaded () -> Bool {
        
        var reload: Bool = true
        
        if selectedView == "personal" {
            
            for conversation in personalConversations ?? [] {
                
                //Gets set in the firebaseMessaging file
                if conversation.messagePreviewLoaded == false || conversation.membersLoaded == false {
                    
                    reload = false
                    break
                }
            }
            
            handleConversationsAnimation(conversationsFullyLoaded: reload)
            
            return reload
        }
        
        else {
            
            for conversation in collabConversations ?? [] {
                
                //Gets set in the firebaseMessaging file
                if conversation.messagePreviewLoaded == false || conversation.membersLoaded == false {
                    
                    reload = false
                    break
                }
            }
            
            handleConversationsAnimation(conversationsFullyLoaded: reload)
            
            return reload
        }
    }
    
    
    //MARK: - Handle Conversation Animation Function
    
    private func handleConversationsAnimation (conversationsCount: Int? = nil, conversationsFullyLoaded: Bool? = nil) {
        
        if conversationsCount == 0 {
            
            loadingAnimationTimer?.invalidate()
            
            stopSearch()
            
            //If the conversations animation is already presented
            if conversationsAnimationContainer.superview != nil {
                
                UIView.transition(with: conversationsAnimationContainer.conversationAnimationTitle, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    
                    self.conversationsAnimationContainer.conversationAnimationTitle.text = "No Messages \n Yet"
                })
            }
            
            else {
                
                //Reconfigures the conversationAnimationContainer if it isn't added to this view
                configureConversationsAnimation(conversationsLoading: false)
                conversationsAnimationContainer.conversationAnimationTitle.text = "No Messages \n Yet"
                
                messagingTableViewTopAnchor.constant = 65 //Hides the searchBar
                
                UIView.animate(withDuration: 0.3) {
                    
                    self.view.layoutIfNeeded()
                    
                    self.messagingHomeTableView.alpha = 0
                    self.conversationsAnimationContainer.alpha = 1
                }
            }
        }
        
        //If all the messagePreviews and convoMembers have been retrieved
        else if conversationsFullyLoaded ?? false {
            
            loadingAnimationTimer?.invalidate()
            
            //If the conversations animation is presented
            if conversationsAnimationContainer.superview != nil {
                
                self.messagingTableViewTopAnchor.constant = 125 //Shows the searchBar
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.view.layoutIfNeeded()
                    
                    self.messagingHomeTableView.alpha = 1
                    self.conversationsAnimationContainer.alpha = 0
                    
                }) { (finished: Bool) in
                    
                    self.conversationsAnimationContainer.removeFromSuperview()
                }
            }
        }
        
        //If the function call couldn't provide the conversation loading status but there are conversations loaded; likely called from the personal/collab buttons
        else if conversationsFullyLoaded == nil {
            
            loadingAnimationTimer?.invalidate()
            
            _ = self.conversationsFullyLoaded() //Will call the conversationsFullyLoaded func which in turn will call this func again with the conversations loading status and update the view accordingly
        }
    }
    
    
    //MARK: - Search Functions
    
    func searchTextChanged (searchText: String) {
        
        filteredConversations.removeAll()
        
        if searchText.leniantValidationOfTextEntered() {
            
            searchBeingConducted = true
            
            var conversations = selectedView == "personal" ? personalConversations : collabConversations
            
            if viewEditing {
                
                conversations = filterConversationWithMessages(conversations: conversations)
            }
            
            for conversation in conversations ?? [] {
                
                if conversation.conversationName != nil {
                    
                    if conversation.conversationName!.localizedCaseInsensitiveContains(searchText) {
                        
                        filteredConversations.append(conversation)
                    }
                }
                
                //If the conversation has yet to be named, search by the name of the members
                else {
                    
                    var filteredMembers = conversation.currentMembers
                    filteredMembers.removeAll(where: { $0.userID == currentUser.userID })
                    
                    for member in filteredMembers {
                        
                        if member.firstName.localizedCaseInsensitiveContains(searchText) {
                            
                            filteredConversations.append(conversation)
                            break
                        }
                        
                        else if member.lastName.localizedCaseInsensitiveContains(searchText) {
                            
                            filteredConversations.append(conversation)
                            break
                        }
                    }
                }
            }
        }
        
        else {
            
            searchBeingConducted = false
            
            if viewEditing {
                
                let conversations = personalConversations
                filteredConversations = filterConversationWithMessages(conversations: conversations) ?? []
            }
        }
        
        UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve) {
            
            self.messagingHomeTableView.reloadData()
        }
    }
    
    
    private func stopSearch () {
        
        searchBar.searchTextField.text = ""
        
        searchBar.searchTextField.endEditing(true)
        
        searchBeingConducted = false
    }
    
    
    //MARK: - Sorting Functions
    
    private func presentSortMessagesAlert () {
        
        let sortAlertController = UIAlertController(title: "Sort Messages By:", message: nil, preferredStyle: .actionSheet)
        
        //Default Action
        let defaultAction = UIAlertAction(title: "     Default", style: .default) { [weak self] (defaultAction) in
            
            self?.sortActionPressed(sortBy: .defaultSort)
        }
        
        let defaultImage = UIImage(systemName: "line.horizontal.3")
        defaultAction.setValue(defaultImage, forKey: "image")
        defaultAction.setValue(sortConversationsBy == .defaultSort ? true : false, forKey: "checked")
        defaultAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        //Unread Messages Action
        let unreadMessagesAction = UIAlertAction(title: "     Unread Messages", style: .default) { [weak self] (newMessagesAction) in
            
            self?.sortActionPressed(sortBy: .unreadMessages)
        }
        
        let unreadMessageImage = UIImage(systemName: "message.circle.fill")
        unreadMessagesAction.setValue(unreadMessageImage, forKey: "image")
        unreadMessagesAction.setValue(sortConversationsBy == .unreadMessages ? true : false, forKey: "checked")
        unreadMessagesAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        //Date Joined/Created Action
        let dateJoined_CreatedTitle: String = selectedView == "personal" ? "     Date Joined" : "     Date Created"
        let dateJoinedAction = UIAlertAction(title: dateJoined_CreatedTitle, style: .default) { [weak self] (dateJoinedAction) in
            
            self?.sortActionPressed(sortBy: self?.sortConversationsBy != .dateJoined_CreatedAscending ? .dateJoined_CreatedAscending : .dateJoined_CreatedDescending)
        }
        
        let dateJoinedImage = sortConversationsBy != .dateJoined_CreatedAscending ? UIImage(systemName: "arrow.up") : UIImage(systemName: "arrow.down")
        dateJoinedAction.setValue(dateJoinedImage, forKey: "image")
        dateJoinedAction.setValue(sortConversationsBy == .dateJoined_CreatedAscending || sortConversationsBy == .dateJoined_CreatedDescending ? true : false, forKey: "checked")
        dateJoinedAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        //Name Action
        let nameAction = UIAlertAction(title: "     Name", style: .default) { [weak self] (nameAction) in
            
            self?.sortActionPressed(sortBy: self?.sortConversationsBy != .nameAscending ? .nameAscending : .nameDescending)
        }
        
        let nameImage = sortConversationsBy != .nameAscending ? UIImage(systemName: "arrow.up") : UIImage(systemName: "arrow.down")
        nameAction.setValue(nameImage, forKey: "image")
        nameAction.setValue(sortConversationsBy == .nameAscending || sortConversationsBy == .nameDescending ? true : false, forKey: "checked")
        nameAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

        //Cancel Action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        sortAlertController.addAction(defaultAction)
        sortAlertController.addAction(unreadMessagesAction)
        sortAlertController.addAction(dateJoinedAction)
        sortAlertController.addAction(nameAction)
        
        sortAlertController.addAction(cancelAction)
        
        present(sortAlertController, animated: true, completion: nil)
    }
    
    private func sortActionPressed (sortBy: SortConversation) {
        
        sortConversationsBy = sortBy
        
        if selectedView == "personal" {
            
            sortPersonalConversations()
        }
        
        else {
            
            sortCollabConversations()
        }
    }
    
    private func sortPersonalConversations () {
        
        switch sortConversationsBy {
            
            case .defaultSort:
            
                //Sorted by either the timestamp of the last message or if a conversation doesn't have a last message then by the date the user gained access to the conversation
                personalConversations = firebaseMessaging.personalConversations.sorted(by: { $0.messagePreview?.timestamp ?? firebaseMessaging.convertTimestampToDate($0.memberGainedAccessOn?[currentUser.userID] as Any) > $1.messagePreview?.timestamp ?? firebaseMessaging.convertTimestampToDate($1.memberGainedAccessOn?[currentUser.userID] as Any) })
            
            case .unreadMessages:
                
                handlePersonalConversationsUnreadMessageSort()
                
            case .dateJoined_CreatedAscending:
                
                personalConversations = firebaseMessaging.personalConversations.sorted(by: { firebaseMessaging.convertTimestampToDate($0.memberGainedAccessOn?[currentUser.userID] as Any) < firebaseMessaging.convertTimestampToDate($1.memberGainedAccessOn?[currentUser.userID] as Any) })
                
            case .dateJoined_CreatedDescending:
                
                personalConversations = firebaseMessaging.personalConversations.sorted(by: { firebaseMessaging.convertTimestampToDate($0.memberGainedAccessOn?[currentUser.userID] as Any) > firebaseMessaging.convertTimestampToDate($1.memberGainedAccessOn?[currentUser.userID] as Any) })
                
            case .nameAscending:
                
                handlePersonalConversationsNameAscendingSort()
                
            case .nameDescending:
                
                personalConversations = firebaseMessaging.personalConversations.sorted(by: { $0.conversationName ?? "" > $1.conversationName ?? "" })
        }
        
        if selectedView == "personal" {
            
            messagingHomeTableView.reloadData()
        }
    }
    
    private func sortCollabConversations () {
        
        switch sortConversationsBy {
            
            case .defaultSort:
                
                //Sorted by either the timestamp of the last message or if a conversation doesn't have a last message then by the date the collab was created
                collabConversations = firebaseMessaging.collabConversations.sorted(by: { $0.messagePreview?.timestamp ?? $0.dateCreated! > $1.messagePreview?.timestamp ?? $1.dateCreated! })
            
            case .unreadMessages:
                
                handleCollabConversationsUnreadMessageSort()
                
            case .dateJoined_CreatedAscending:
                
                collabConversations = firebaseMessaging.collabConversations.sorted(by: { $0.dateCreated! < $1.dateCreated! })
                
            case .dateJoined_CreatedDescending:
                
                collabConversations = firebaseMessaging.collabConversations.sorted(by: { $0.dateCreated! > $1.dateCreated! })
            
            case .nameAscending:

                collabConversations = firebaseMessaging.collabConversations.sorted(by: { $0.conversationName ?? "" < $1.conversationName ?? "" })
                
            case .nameDescending:
                
                collabConversations = firebaseMessaging.collabConversations.sorted(by: { $0.conversationName ?? "" > $1.conversationName ?? "" })
        }
        
        if selectedView == "collab" {
            
            messagingHomeTableView.reloadData()
        }
    }
    
    private func handlePersonalConversationsUnreadMessageSort () {
            
        var sortedConversations: [Conversation] = []

        //Finds all the conversations that have unread messages
        firebaseMessaging.personalConversations.forEach { (conversation) in

            if let messagePreviewTimestamp = conversation.messagePreview?.timestamp, let memberActivity = conversation.memberActivity?[currentUser.userID] as? Date {

                //If the last message hasn't been read yet
                if messagePreviewTimestamp > memberActivity {

                    sortedConversations.append(conversation)
                }
            }
        }

        sortedConversations = sortedConversations.sorted(by: { $0.messagePreview?.timestamp ?? Date() >  $1.messagePreview?.timestamp ?? Date()})

        //Finds all the conversations that have don't unread messages
        firebaseMessaging.personalConversations.forEach { (conversation) in

            if sortedConversations.contains(where: { $0.conversationID == conversation.conversationID }) == false {

                sortedConversations.append(conversation)
            }
        }

        personalConversations = sortedConversations
    }
    
    private func handlePersonalConversationsNameAscendingSort () {
        
        var sortedConversations: [Conversation] = []

        //Finds all the conversations that have a name
        firebaseMessaging.personalConversations.forEach({ (conversation) in

            if conversation.conversationName != nil {

                sortedConversations.append(conversation)
            }
        })

        sortedConversations = sortedConversations.sorted(by: { $0.conversationName ?? "" < $1.conversationName ?? "" })

        //Finds all the conversations that don't have a name
        firebaseMessaging.personalConversations.forEach { (conversation) in

            if conversation.conversationName == nil {

                sortedConversations.append(conversation)
            }
        }

        personalConversations = sortedConversations
    }
    
    private func handleCollabConversationsUnreadMessageSort () {
        
        var sortedConversations: [Conversation] = []

        //Finds all the conversations that have unread messages
        firebaseMessaging.collabConversations.forEach { (conversation) in

            if let messagePreviewTimestamp = conversation.messagePreview?.timestamp, let memberActivity = conversation.memberActivity?[currentUser.userID] as? Date {

                //If the last message hasn't been read yet
                if messagePreviewTimestamp > memberActivity {

                    sortedConversations.append(conversation)
                }
            }
        }

        sortedConversations = sortedConversations.sorted(by: { $0.messagePreview?.timestamp ?? Date() >  $1.messagePreview?.timestamp ?? Date()})

        //Finds all the conversations that have don't unread messages
        firebaseMessaging.collabConversations.forEach { (conversation) in

            if sortedConversations.contains(where: { $0.conversationID == conversation.conversationID }) == false {

                sortedConversations.append(conversation)
            }
        }

        collabConversations = sortedConversations
    }
    
    
    //MARK: - Conversation Verification Functions
    
    private func verifyNewPersonalConversation (member: Friend) -> Conversation? {
        
        for convo in personalConversations ?? [] {
            
            if convo.currentMembersIDs.contains(member.userID) && convo.historicMembers.count == 2 {
                
                return convo
            }
        }
        
        return nil
    }
    
    private func verifyNewGroupConversation (members: [Friend]) -> Conversation? {
        
        var convoArray: [Conversation] = []
        
        //Checks to see which convos have the same amount of members as the one being created
        for convo in personalConversations ?? [] {

            if (members.count + 1) == convo.currentMembers.count {

                convoArray.append(convo)
            }
        }
        
        for convo in convoArray {
            
            var sameMembers: Bool = true
            
            for member in members {
                
                //If the new convo has a member that the current convo in the loop doesn't have
                if convo.currentMembers.contains(where: { $0.userID == member.userID }) != true {
                   
                    sameMembers = false
                    break
                }
            }
            
            if sameMembers {
                
                if let conversation = personalConversations?.first(where: { $0.conversationID == convo.conversationID }) {
                    
                    //If the convo has yet to be given a name
                    if conversation.conversationName == nil {

                        return conversation
                    }
                }
            }
        }
        
        return nil
    }
    
    
    //MARK: - Edit Conversation Function
    
    private func editConversations (beginEditing: Bool) {
        
        viewEditing = beginEditing
        stopSearch()

        if beginEditing {

            shouldPresentCheckbox = false //Neccasary

            self.filteredConversations = self.filterConversationWithMessages(conversations: self.personalConversations) ?? []

            if self.filteredConversations.count != self.personalConversations?.count {

                self.messagingHomeTableView.reloadSections([0], with: .fade)
            }

            //Delays until the tabBar and newConversationButton have been hidden
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {

                for visibleCell in self.messagingHomeTableView.visibleCells {

                    if let cell = visibleCell as? MessageHomeCell {

                        cell.checkBox.on = false

                        cell.beginEditing(animate: true)
                    }
                }

                self.shouldPresentCheckbox = true
            }
        }

        else {

            for visibleCell in messagingHomeTableView.visibleCells {

                if let cell = visibleCell as? MessageHomeCell {

                    cell.endEditing(animate: true)
                }
            }
            
            //Delays until cells have finished animating
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                
                self.messagingHomeTableView.reloadSections([0], with: .fade)
            }
        }
    }
    
    
    //MARK: - Populate Edit Conversation Dictionary Function
    
    private func populateEditConversationDictionary (conversations: [Conversation]) {
        
        if viewEditing {
            
            for convo in conversations {
                
                //If a conversation hasn't been added to the dictionary yet; i.e. it's a new conversation
                if editedConversations.keys.contains(convo.conversationID) == false {
                    
                    editedConversations[convo.conversationID] = false
                }
            }
        }
        
        else {
            
            for convo in conversations {
                
                editedConversations[convo.conversationID] = false
            }
        }
    }
    
    
    //MARK: - Filter Conversations Function
    
    private func filterConversationWithMessages (conversations: [Conversation]?) -> [Conversation]? {

        var filteredConversations: [Conversation]? = conversations
        filteredConversations?.removeAll(where: { $0.messagePreview == nil })

        return filteredConversations
    }
    
    
    //MARK: - Hide New Conversation Button Function
    
    private func hideNewConversationButton (hide: Bool) {
        
        if hide {
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                
                self.newConversationButton.alpha = 0
                
            }) { (finished: Bool) in
                
                self.newConversationButton.isHidden = true
            }
        }
        
        else {
            
            self.newConversationButton.isHidden = false
            
            let delay = tabBar.alpha == 0 ? 0.25 : 0 //If the tabBar is hidden, delay the animation
            
            UIView.animate(withDuration: 0.25, delay: delay, options: .curveEaseInOut, animations: {
                
                self.newConversationButton.alpha = 1
            })
        }
    }
    
    
    //MARK: - Hide TabBar Function
    
    private func hideTabBar (hide: Bool) {
        
        if hide {
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                
                self.tabBar.alpha = 0
                
            }) { (finished: Bool) in
            
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.deleteMessagesButton.alpha = 1
                })
            }
        }
        
        else {
            
            deleteMessagesButton.backgroundColor = .lightGray
            deleteMessagesButton.isEnabled = false //Will be enabled when at least one convo is selected
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                
                self.deleteMessagesButton.alpha = 0
                
            }) { (finished: Bool) in
                
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.tabBar.alpha = 1
                })
            }
        }
    }
    
    
    //MARK: - Prepare for Segue Function
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToMessagesView" {
            
            let messagesVC = segue.destination as! MessagingViewController
            messagesVC.moveToConversationWithFriendDelegate = self
            
            if selectedView == "personal" {
                
                messagesVC.personalConversation = selectedConversation
                
            } else {

                messagesVC.collabConversation = selectedConversation

            }
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    
    //MARK: - Delete Messages Button Function
    
    @objc private func deleteMessages () {
        
        if personalConversations != nil {
            
            SVProgressHUD.show()
            
            var conversations: [Conversation] = []
            
            editedConversations.forEach { (conversation) in
                
                //If this conversations messages have been selected to be deleted
                if conversation.value == true {
                    
                    if let conversationIndex = firebaseMessaging.personalConversations.firstIndex(where: { $0.conversationID == conversation.key }) {
                        
                        firebaseMessaging.personalConversations[conversationIndex].messagePreview = nil
                    }
                    
                    if let conversationIndex = personalConversations?.firstIndex(where: { $0.conversationID == conversation.key }) {
                        
                        personalConversations?[conversationIndex].messagePreview = nil
                        
                        if personalConversations?[conversationIndex] != nil {
                            
                            conversations.append(personalConversations![conversationIndex])
                        }
                    }
                }
            }
            
            firebaseMessaging.deleteMessages(conversations: conversations) { (error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    SVProgressHUD.dismiss()
                    
                    self.setEditing(false, animated: true)
                }
            }
        }
    }
    
    
    //MARK: - Personal Button Functions
    
    @objc func handlePersonalButtonTouchDown () {
        
        UIView.animate(withDuration: 0.4) {

            self.personalContainer.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
        
        if selectedView == "collab" {
            
            personalContainer.selectContainer()
            collabContainer.deselectContainer()
        }
    }
    
    @objc func handlePersonalButtonTouchDragExit () {
        
        UIView.animate(withDuration: 0.4) {

            self.personalContainer.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        if selectedView == "collab" {
            
            personalContainer.deselectContainer()
            collabContainer.selectContainer()
        }
    }
    
    @objc func handlePersonalButtonTouchUpInside () {
        
        UIView.animate(withDuration: 0.4) {

            self.personalContainer.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        if selectedView == "collab" {
            
            selectedView = "personal"

            navigationItem.rightBarButtonItem = self.editButtonItem
            super.setEditing(false, animated: true)
            editButtonItem.style = .done

            messagingHomeTableView.reloadSections([0], with: .none)

            handleConversationsAnimation(conversationsCount: self.personalConversations?.count ?? 0)
                
            hideNewConversationButton(hide: false)
        }
    }
    
    
    //MARK: - Collab Button Functions
    
    @objc func handleCollabButtonTouchDown () {
        
        UIView.animate(withDuration: 0.4) {

            self.collabContainer.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
        
        if selectedView == "personal" {
            
            collabContainer.selectContainer()
            personalContainer.deselectContainer()
        }
    }
    
    @objc func handleCollabButtonTouchDragExit () {
        
        UIView.animate(withDuration: 0.4) {

            self.collabContainer.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        if selectedView == "personal" {
            
            collabContainer.deselectContainer()
            personalContainer.selectContainer()
        }
    }
    
    @objc func handleCollabButtonTouchUpInside () {
        
        UIView.animate(withDuration: 0.4) {

            self.collabContainer.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        if selectedView == "personal" {
            
            selectedView = "collab"
            
            let delayDuration = viewEditing ? 0.7 : 0 //Initialize here before the call to "editConversations"
            
            if viewEditing {
                
                editConversations(beginEditing: false)
            }
        
            hideNewConversationButton(hide: true)
            hideTabBar(hide: false)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delayDuration) {
                
                self.navigationItem.rightBarButtonItem = nil
                
                self.messagingHomeTableView.reloadSections([0], with: .none)

                self.handleConversationsAnimation(conversationsCount: self.collabConversations?.count ?? 0)
            }
        }
    }
    
    
    //MARK: - Sort Button Function
    
    @IBAction func sortButtonPressed () {
        
        presentSortMessagesAlert()
    }
    
    
    //MARK: - New Message Button Function
    
    @objc private func newMessageButtonPressed () {
        
        let addMembersVC: AddMembersViewController = AddMembersViewController()
        addMembersVC.membersAddedDelegate = self
        addMembersVC.headerLabelText = "Conversate With"
        
        let firebaseCollab = FirebaseCollab.sharedInstance
        addMembersVC.members = []
        firebaseCollab.friends.forEach({ if $0.accepted == true { addMembersVC.members?.append($0) } })
        
        addMembersVC.addedMembers = [:]
        
        //Creating the navigation controller for the AddMembersViewController
        let addMembersNavigationController = UINavigationController(rootViewController: addMembersVC)
        
        self.present(addMembersNavigationController, animated: true, completion: nil)
    }
    
    
    //MARK: - Dismiss Keyboard Function
    
    @objc private func dismissKeyboard () {
        
        searchBar.searchTextField.endEditing(true)
    }
}


//MARK: - MembersAdded Extension

extension MessagesHomeViewController: MembersAdded {
    
    func membersAdded(_ addedMembers: [Any]) {
        
        var members: [Friend] = []
        
        for addedMember in addedMembers {
            
            if let member = addedMember as? Friend {
                
                members.append(member)
            }
        }
        
        //If it isn't a new personal conversation
        if members.count == 1, let member = members.first, let conversation = verifyNewPersonalConversation(member: member) {
            
            dismiss(animated: true) {
                
                self.selectedConversation = conversation
                
                self.performSegue(withIdentifier: "moveToMessagesView", sender: self)
            }
        }
        
        //If it isn't a group new conversation
        else if members.count > 1, let conversation = verifyNewGroupConversation(members: members) {
            
            dismiss(animated: true) {
                
                self.selectedConversation = conversation
                
                self.performSegue(withIdentifier: "moveToMessagesView", sender: self)
            }
        }
        
        else {
            
            SVProgressHUD.show()
            
            firebaseMessaging.createPersonalConversation(members: members) { [weak self] (conversationID, error) in

                if error != nil {

                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }

                else {

                    SVProgressHUD.dismiss()

                    self?.dismiss(animated: true, completion: {
                        
                        let conversations = self?.selectedView == "personal" ? self?.personalConversations : self?.collabConversations
                        
                        for convo in conversations ?? [] {
                            
                            if convo.conversationID == conversationID {
                                
                                self?.selectedConversation = convo
                                
                                self?.performSegue(withIdentifier: "moveToMessagesView", sender: self)
                                
                                break
                            }
                        }
                    })
                }
            }
        }
    }
}


//MARK: - Move to Conversation with Friend Extension

extension MessagesHomeViewController: MoveToConversationWithFriendProtcol {
    
    func moveToConversationWithFriend(_ friend: Friend) {
        
        if selectedView != "personal" {
            
            personalContainer.selectContainer()
            collabContainer.deselectContainer()
            
            handlePersonalButtonTouchUpInside()
        }
        
        membersAdded([friend])
    }
}
