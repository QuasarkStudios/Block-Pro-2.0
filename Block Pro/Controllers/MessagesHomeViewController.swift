//
//  MessagesViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/10/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

class MessagesHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var searchBarContainer: UIView!
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var personal_collabButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    
    @IBOutlet weak var messagingHomeTableView: UITableView!
    
    let newConversationButton = UIButton(type: .system)
    let tabBar = CustomTabBar.sharedInstance
    let deleteConversationButton = UIButton(type: .system)
    
    let firebaseMessaging = FirebaseMessaging.sharedInstance
    
    var personalConversations: [Conversation]? {
        didSet {
            
            guard let conversations = personalConversations else { return }
            
                populateEditConversationDictionary(conversations: conversations)
            
            #warning("when new messages are recieved and a user is editing, this will wipe out all they've check marked.... so fix it please future me")
        }
    }
    
    var collabConversations: [Conversation]? {
        didSet {
            
//            guard let conversations = personalConversations else { return }
//
//                populateEditConversationDictionary(conversations: conversations)
            
            #warning("when new messages are recieved and a user is editing, this will wipe out all they've check marked.... so fix it please future me")
        }
    }
    
    var selectedConversation: Conversation?
    
    var filteredConversations: [Conversation] = []
    var searchBeingConducted: Bool = false
    
    var viewEditing: Bool = false
    var editedConversations: [String : Bool] = [:]
    
    var selectedView: String = "personal"
    
    var membersLoadedCount: Int? = 0
    var conversationPreviewLoadedCount: Int? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureSearchBar()
        configureButtons()
        configureTableView(messagingHomeTableView)
        configureGestureRecognizors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        addNotificationObservors()
        
        configureNavBar()
        
        addConversationListener()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
//        addConversationListener() // Will crash app if called from viewwillappear, seemingly caused by the readmessages func in the messaging view
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        tabBar.previousNavigationController = navigationController
        
        NotificationCenter.default.removeObserver(self)
        
        removeListeners()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        
        editConversations(beginEditing: editing)
        
        if editing {
            
            hideNewConversationButton(hide: true)
            hideTabBar(hide: true)
        }
        
        else {
            
            editButtonItem.style = .done
            navigationItem.rightBarButtonItem = editButtonItem
            
            if selectedView == "personal" {
                
                hideNewConversationButton(hide: false)
            }
            
            hideTabBar(hide: false)
        }
        
    }
    
    //MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBeingConducted {

            return filteredConversations.count * 2
        }
        
        else {

            if selectedView == "personal" {
                
                return (personalConversations?.count ?? 0) * 2
            }
            
            else {
                
                return (collabConversations?.count ?? 0) * 2
            }
            
//            if let conversations = personalConversations {
//
//                return conversations.count * 2
//            }
//
//            else {
//
//                return (collabConversations?.count ?? 0) * 2
//            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            
            var conversationToBeUsed: Conversation?
            
            if searchBeingConducted {
                
                conversationToBeUsed = filteredConversations[indexPath.row / 2]
            }
            
            else {
                
//                if let conversations = personalConversations {
//
//                    conversationToBeUsed = conversations[indexPath.row / 2]
//                }
//
//                else if let conversations = collabConversations {
//
//                    conversationToBeUsed = conversations[indexPath.row / 2]
//                }
                
                //conversationToBeUsed = conversations?[indexPath.row / 2] ?? nil
                
                conversationToBeUsed = selectedView == "personal" ? personalConversations?[indexPath.row / 2] : collabConversations?[indexPath.row / 2]
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageHomeCell", for: indexPath) as! MessageHomeCell
            
            if selectedView == "personal" {
                
                cell.personalConversation = conversationToBeUsed
            }
            
            else {
                
                cell.collabConversation = conversationToBeUsed
            }
            
//            if personalConversations != nil {
//
//                cell.personalConversation = conversationToBeUsed
//            }
//
//            else {
//
//                cell.collabConversation = conversationToBeUsed
//            }
            
            if viewEditing {
                
                cell.checkBox.on = editedConversations[conversationToBeUsed?.conversationID ?? ""] ?? false
                cell.beginEditing(animate: false)
            }
            
            else {
                
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
            
            return 10
        }
    }
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        vibrate()
        
        if viewEditing {
            
            let cell = tableView.cellForRow(at: indexPath) as! MessageHomeCell
            
//            if personalConversations != nil {
//
//                cell.checkBox.setOn(!(editedConversations[cell.personalConversation!.conversationID] ?? false), animated: true)
//
//                editedConversations[cell.personalConversation!.conversationID] = !(editedConversations[cell.personalConversation!.conversationID] ?? false)
//            }
            
            if selectedView == "personal" {
                
                cell.checkBox.setOn(!(editedConversations[cell.personalConversation!.conversationID] ?? false), animated: true)
                
                editedConversations[cell.personalConversation!.conversationID] = !(editedConversations[cell.personalConversation!.conversationID] ?? false)
            }
            
            //Checks to see if any conversations have been selected
            if editedConversations.first(where: { $0.value == true } ) != nil {
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.deleteConversationButton.backgroundColor = .flatRed()
                    
                }) { (finished: Bool) in
                    
                    self.deleteConversationButton.isEnabled = true
                }
            }
            
            else {
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.deleteConversationButton.backgroundColor = .lightGray
                    
                }) { (finished: Bool) in
                    
                    self.deleteConversationButton.isEnabled = false
                }
            }
        }
        
        else {
            
            selectedConversation = selectedView == "personal" ? personalConversations?[indexPath.row / 2] : collabConversations?[indexPath.row / 2]
            
//            if let conversations = personalConversations {
//
//                selectedConversation = conversations[indexPath.row / 2]
//            }
//
//            else if let conversations = collabConversations {
//
//                selectedConversation = conversations[indexPath.row / 2]
//            }
            
            //selectedConversation = conversations?[indexPath.row / 2]

            performSegue(withIdentifier: "moveToMessagesView", sender: self)
        }
    }
    
    //MARK: - Configuration Functions
    
    private func configureNavBar () {
        
        navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear)
        
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 20)!]
        navigationItem.title =  "Messages"
        
        if selectedView == "personal" {
            
            editButtonItem.style = .done
            navigationItem.rightBarButtonItem = editButtonItem
        }
        
        else {
            
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func configureSearchBar () {
        
        searchBarContainer.backgroundColor = .white
        searchBarContainer.layer.cornerRadius = 18
        searchBarContainer.clipsToBounds = true
        searchBarContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        searchBarContainer.layer.borderWidth = 1
        
        if #available(iOS 13.0, *) {
            searchBarContainer.layer.cornerCurve = .continuous
        }
        
        searchTextField.delegate = self
        searchTextField.borderStyle = .none
    }
    
    private func configureButtons () {
        
        personal_collabButton.layer.cornerRadius = 16
        personal_collabButton.clipsToBounds = true
        
        sortButton.layer.cornerRadius = 16
        sortButton.clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            
            personal_collabButton.layer.cornerCurve = .continuous
            sortButton.layer.cornerCurve = .continuous
        }
        
        configureNewConversationButton()
        configureDeleteConversationsButton()
    }
    
    private func configureTableView (_ tableView: UITableView) {
    
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 140, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 155, right: 0)

        tableView.register(UINib(nibName: "MessageHomeCell", bundle: nil), forCellReuseIdentifier: "messageHomeCell")
    }
    
    func configureTabBar () {

        tabBarController?.tabBar.isHidden = true
        tabBarController?.delegate = tabBar

        tabBar.shouldHide = false
        tabBar.tabBarController = tabBarController
        tabBar.currentNavigationController = self.navigationController
        
        view.addSubview(tabBar)
    }
    
    private func configureGestureRecognizors () {
        
        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardGesture)
    }
    
    private func configureNewConversationButton () {
        
        newConversationButton.addTarget(self, action: #selector(newMessageButtonPressed), for: .touchUpInside)
        newConversationButton.backgroundColor = UIColor(hexString: "222222")
        newConversationButton.setImage(UIImage(named: "plus 2"), for: .normal)
        newConversationButton.tintColor = .white
        
        view.addSubview(newConversationButton)
        
        newConversationButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            newConversationButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -29),
            newConversationButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -120),
            newConversationButton.widthAnchor.constraint(equalToConstant: 60),
            newConversationButton.heightAnchor.constraint(equalToConstant: 60)
            
        ].forEach( { $0.isActive = true } )
        
        newConversationButton.layer.cornerRadius = 30
        newConversationButton.clipsToBounds = true
    }
    
    private func configureDeleteConversationsButton () {
        
        //Delete button is 2 points smaller than the tabBar
        let xCoord = (UIScreen.main.bounds.width / 2) - 119
        let yCoord = UIScreen.main.bounds.height - 95
        deleteConversationButton.frame = CGRect(x: xCoord, y: yCoord, width: 238, height: 55)
        
        deleteConversationButton.backgroundColor = .lightGray
        deleteConversationButton.alpha = 0
        
        deleteConversationButton.setTitle("Delete", for: .normal)
        deleteConversationButton.titleLabel?.font = UIFont(name: "Poppins-Semibold", size: 18)
        deleteConversationButton.tintColor = .white
        
        deleteConversationButton.layer.cornerRadius = 28.5
        
        deleteConversationButton.isEnabled = false
        deleteConversationButton.addTarget(self, action: #selector(deleteConversation), for: .touchUpInside)
        
        view.addSubview(deleteConversationButton)
    }
    
    //MARK: - Observors and Listeners Functions
    
    func addNotificationObservors () {
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRetrieveConversationMembers), name: .didRetrieveConversationMembers, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(didRetrieveConversationPreview), name: .didRetrieveConversationPreview, object: nil)
    }
    
    private func addConversationListener () {
        
        if selectedView == "personal" {
            
            //collabConversations = nil
            
            firebaseMessaging.retrievePersonalConversations2 { (conversations, error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    self.personalConversations = conversations.sorted(by: { $0.messagePreview?.timestamp ?? $0.dateCreated! > $1.messagePreview?.timestamp ?? $1.dateCreated! })
                    
                    self.messagingHomeTableView.reloadData()
                    
//                    if self.messagingHomeTableView.visibleCells.count == 0 {
//
//                        self.messagingHomeTableView.reloadData()
//                    }
//
//                    else {
//
//                        if self.membersLoadedCount == 0 && self.conversationPreviewLoadedCount == 0 {
//
//                            self.messagingHomeTableView.reloadData()
//                        }
//
//                        else {
//
//                            self.messagingHomeTableView.reloadRows(at: self.messagingHomeTableView.indexPathsForVisibleRows ?? [], with: .none)
//                        }
//                    }
                }
            }
        }
        
        else {
            
            //personalConversations = nil
            
            firebaseMessaging.retrieveCollabConversations { (conversations, error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    self.collabConversations = conversations.sorted(by: { $0.messagePreview?.timestamp ?? $0.dateCreated! > $1.messagePreview?.timestamp ?? $1.dateCreated! })
                    
                    self.messagingHomeTableView.reloadData()
                }
            }
        }
    }
    
    private func removeListeners () {
        
        firebaseMessaging.conversationListener?.remove()
        
        for listener in firebaseMessaging.conversationMembersListeners {
            
            listener.remove()
        }
        
        for listener in firebaseMessaging.conversationPreviewListeners {
            
            listener.remove()
        }
        
        firebaseMessaging.conversationMembersListeners.removeAll()
        firebaseMessaging.conversationPreviewListeners.removeAll()
    }
    
    @objc private func didRetrieveConversationMembers () {
        
        
//        self.conversations = firebaseMessaging.conversations.sorted(by: { $0.messagePreview?.timestamp ?? $0.dateCreated! > $1.messagePreview?.timestamp ?? $1.dateCreated! })
        
        //Sorted by either the timeStamp of the last message or the time the convo was created if no message has been sent yet
        if selectedView == "personal" {
            
            personalConversations = firebaseMessaging.personalConversations.sorted(by: { $0.messagePreview?.timestamp ?? $0.dateCreated! > $1.messagePreview?.timestamp ?? $1.dateCreated! })
        }
        
        else {
            
            collabConversations = firebaseMessaging.collabConversations.sorted(by: { $0.messagePreview?.timestamp ?? $0.dateCreated! > $1.messagePreview?.timestamp ?? $1.dateCreated! })
        }
        
//        if personalConversations != nil {
//
//            personalConversations = firebaseMessaging.personalConversations.sorted(by: { $0.messagePreview?.timestamp ?? $0.dateCreated! > $1.messagePreview?.timestamp ?? $1.dateCreated! })
//        }
//
//        else {
//
//            collabConversations = firebaseMessaging.collabConversations.sorted(by: { $0.messagePreview?.timestamp ?? $0.dateCreated! > $1.messagePreview?.timestamp ?? $1.dateCreated! })
//        }
        
        //Updates the filteredConversations when conversation members have changed
        if searchBeingConducted {
            
            searchTextChanged(self)
            return
        }
        
        var indexPathsToReload: [IndexPath] = []

        for indexPath in messagingHomeTableView?.indexPathsForVisibleRows ?? [] {

            if indexPath.row % 2 == 0 {

                //If all the conversation members haven't already been initially loaded
                if membersLoadedCount != nil {
                    
                    messagingHomeTableView.reloadData()
                }
                
                else {
                    
                    let cell = messagingHomeTableView.cellForRow(at: indexPath) as! MessageHomeCell
                    
                    if selectedView == "personal" {
                        
                        //If the amount of memebrs in the conversation has changed
                        if cell.personalConversation?.members.count ?? 0 != personalConversations?[indexPath.row / 2].members.count {
                            
                            indexPathsToReload.append(indexPath)
                        }
                        
                        else {
                            
                            //Checks to see if any members now exist that didn't previously
                            for member in cell.personalConversation?.members ?? [] {
                                
                                if personalConversations?[indexPath.row / 2].members.first(where: { $0.userID == member.userID }) == nil {
                                    
                                    indexPathsToReload.append(indexPath)
                                }
                            }
                        }
                    }
                    
                    else {
                        
                        //If the amount of memebrs in the conversation has changed
                        if cell.collabConversation?.members.count ?? 0 != collabConversations?[indexPath.row / 2].members.count {
                            
                            indexPathsToReload.append(indexPath)
                        }
                        
                        else {
                            
                            //Checks to see if any members now exist that didn't previously
                            for member in cell.collabConversation?.members ?? [] {
                                
                                if collabConversations?[indexPath.row / 2].members.first(where: { $0.userID == member.userID }) == nil {
                                    
                                    indexPathsToReload.append(indexPath)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        //let conversations = personalConversations != nil ? personalConversations : collabConversations
        
        let conversations = selectedView == "personal" ? personalConversations : collabConversations
        
        //If the conversation members hasn't been completely intially loaded
        if let memberCount = membersLoadedCount, memberCount < (conversations?.count ?? 0) - 1 {
            
            membersLoadedCount! += 1
        }
        
        else {
            
            membersLoadedCount = nil
        }
        
        if indexPathsToReload.count == 1 {
            
            messagingHomeTableView.reloadRows(at: indexPathsToReload, with: .none)
        }
        
        else if indexPathsToReload.count > 1 {
            
            messagingHomeTableView.reloadRows(at: indexPathsToReload, with: .fade)
        }
    }
    
    @objc private func didRetrieveConversationPreview () {
        
//        //Sorted by either the timeStamp of the last message or the time the convo was created if no message has been sent yet
//        self.conversations = firebaseMessaging.conversations.sorted(by: { $0.messagePreview?.timestamp ?? $0.dateCreated! > $1.messagePreview?.timestamp ?? $1.dateCreated! })
        
        //Sorted by either the timeStamp of the last message or the time the convo was created if no message has been sent yet
        if selectedView == "personal" {
            
            personalConversations = firebaseMessaging.personalConversations.sorted(by: { $0.messagePreview?.timestamp ?? $0.dateCreated! > $1.messagePreview?.timestamp ?? $1.dateCreated! })
        }
        
        else {
            
            collabConversations = firebaseMessaging.collabConversations.sorted(by: { $0.messagePreview?.timestamp ?? $0.dateCreated! > $1.messagePreview?.timestamp ?? $1.dateCreated! })
        }
        
        //        if personalConversations != nil {
//
//            personalConversations = firebaseMessaging.personalConversations.sorted(by: { $0.messagePreview?.timestamp ?? $0.dateCreated! > $1.messagePreview?.timestamp ?? $1.dateCreated! })
//        }
//
//        else {
//
//            collabConversations = firebaseMessaging.collabConversations.sorted(by: { $0.messagePreview?.timestamp ?? $0.dateCreated! > $1.messagePreview?.timestamp ?? $1.dateCreated! })
//        }
        
        //Updates the filteredConversations when conversation preview have changed
        if searchBeingConducted {
            
            searchTextChanged(self)
            return
        }
        
        var indexPathsToReload: [IndexPath] = []

        for indexPath in messagingHomeTableView?.indexPathsForVisibleRows ?? [] {

            if indexPath.row % 2 == 0 {
                
                //If all the conversation previews haven't already been initially loaded
                if conversationPreviewLoadedCount != nil {
                
                    messagingHomeTableView.reloadData()
                }
                
                else {
                    
                    let cell = messagingHomeTableView.cellForRow(at: indexPath) as! MessageHomeCell
                    
                    if selectedView == "personal" {
                        
                        //If the last message of this conversation has changed
                        if cell.personalConversation?.messagePreview?.messageID != personalConversations?[indexPath.row / 2].messagePreview?.messageID {
                            
                            indexPathsToReload.append(indexPath)
                        }
                        
                        //If the conversation name has changed
                        else if cell.personalConversation?.conversationName != personalConversations?[indexPath.row / 2].conversationName {
                            
                            indexPathsToReload.append(indexPath)
                        }
                    }
                    
                    else {
                        
                        //If the last message of this conversation has changed
                        if cell.collabConversation?.messagePreview?.messageID != collabConversations?[indexPath.row / 2].messagePreview?.messageID {
                            
                            indexPathsToReload.append(indexPath)
                        }
                        
                        //If the conversation name has changed
                        else if cell.collabConversation?.conversationName != collabConversations?[indexPath.row / 2].conversationName {
                            
                            indexPathsToReload.append(indexPath)
                        }
                    }
                }
            }
        }
        
        //let conversations = personalConversations != nil ? personalConversations : collabConversations
        
        let conversations = selectedView == "personal" ? personalConversations : collabConversations
        
        //If the conversation previews hasn't been completely intially loaded
        if let conversationCount = conversationPreviewLoadedCount, conversationCount < (conversations?.count ?? 0) - 1 {
            
            conversationPreviewLoadedCount! += 1
        }
        
        else {
            
           conversationPreviewLoadedCount = nil
        }

        if indexPathsToReload.count == 1 {
            
            messagingHomeTableView.reloadRows(at: indexPathsToReload, with: .none)
        }
        
        else if indexPathsToReload.count > 1 {
            
            messagingHomeTableView.reloadRows(at: indexPathsToReload, with: .fade)
        }
    }
    
    //MARK: - Conversation Verification Function
    
    private func verifyNewConversation (members: [Friend]) -> Conversation? {
        
        var convoArray: [Conversation] = []
//
//        let conversations = selectedView == "personal" ? personalConversations : collabConversations
        
        //Checks to see which convos have the same amount of members as the one being created
        for convo in personalConversations ?? [] {

            if (members.count + 1) == convo.members.count {

                convoArray.append(convo)
            }
        }
        
        for convo in convoArray {
            
            var sameMembers: Bool = true
            
            for member in members {
                
                //If the new convo has a member that the current convo in the loop doesn't have
                if convo.members.contains(where: { $0.userID == member.userID }) != true {
                   
                    sameMembers = false
                    break
                }
            }
            
            if sameMembers {
                
                if let conversation = personalConversations?.first(where: { $0.conversationID == convo.conversationID }) {
                    
                    //If the convo has yet to be given a name
                    if conversation.conversationName == nil {
                        
//                        return conversation.conversationID
                        return conversation
                    }
                }
                
//                else if let conversation = collabConversations?.first(where: { $0.conversationID == convo.conversationID }) {
//
//                    if conversation.conversationName == nil {
//
//                        return conversation
//                    }
//                }
            }
        }
        
        return nil
    }
    
    //MARK: - Edit Conversation Function
    
    private func editConversations (beginEditing: Bool) {
        
        viewEditing = beginEditing
        
        if beginEditing {
            
            for visibleCell in messagingHomeTableView.visibleCells {
                
                if let cell = visibleCell as? MessageHomeCell {
                    
                    cell.checkBox.on = false
                    
                    cell.beginEditing(animate: true)
                }
            }
        }
        
        else {
            
            //let conversations = personalConversations != nil ? personalConversations : collabConversations
            
            let conversations = selectedView == "personal" ? personalConversations : collabConversations
            
            populateEditConversationDictionary(conversations: conversations ?? [])
            
            for visibleCell in messagingHomeTableView.visibleCells {
                
                if let cell = visibleCell as? MessageHomeCell {
                    
                    cell.endEditing(animate: true)
                }
            }
        }
    }
    
    //MARK: - Populate Conversation Dictionary Function
    
    private func populateEditConversationDictionary (conversations: [Conversation]) {
        
        for convo in conversations {
            
            editedConversations[convo.conversationID] = false
        }
    }
    
//    private func reloadTableView () {
//
//        var count = 0
//
//        var indexPathsToReload: [IndexPath] = []
//        var indexPathsToRemove: [IndexPath] = []
//
//        for indexPath in messagingHomeTableView.indexPathsForVisibleRows ?? [] {
//
//            if indexPath.row % 2 == 0 {
//
//                if count / 2 < conversations?.count ?? 0 {
//
//                    indexPathsToReload.append(indexPath)
//                }
//
//                else {
//
//                    indexPathsToRemove.append(indexPath)
//                }
//            }
//
//            else {
//
//                if indexPath.row < ((conversations?.count ?? 0) * 2) {
//
//                    indexPathsToRemove.append(indexPath)
//                }
//            }
//
//            count += 1
//        }
//
//        print(indexPathsToReload)
//        print(indexPathsToRemove)
//
//        messagingHomeTableView.deleteRows(at: indexPathsToRemove, with: .fade)
//
//        messagingHomeTableView.reloadRows(at: indexPathsToReload, with: .fade)
//
//    }
    
    //MARK: - Hide New Conversation Button Function
    
    private func hideNewConversationButton (hide: Bool) {
        
        if hide {
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                
                self.newConversationButton.alpha = 0
                
            }) { (finished: Bool) in
                
                self.newConversationButton.isHidden = true
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.messagingHomeTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
                    self.messagingHomeTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 75, right: 0)
                })
            }
        }
        
        else {
            
            self.newConversationButton.isHidden = false
            
            let delay = tabBar.alpha == 0 ? 0.4 : 0 //If the tabBar is hidden, delay the animation
            
            UIView.animate(withDuration: 0.5, delay: delay, options: .curveEaseInOut, animations: {
                
                self.newConversationButton.alpha = 1
                
            }) { (finished: Bool) in
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.messagingHomeTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 140, right: 0)
                    self.messagingHomeTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 155, right: 0)
                })
            }
        }
    }
    
    //MARK: - Hide TabBar Function
    
    private func hideTabBar (hide: Bool) {
        
        if hide {
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                
                self.tabBar.alpha = 0
                
            }) { (finished: Bool) in
            
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.deleteConversationButton.alpha = 1
                })
            }
        }
        
        else {
            
            deleteConversationButton.backgroundColor = .lightGray
            deleteConversationButton.isEnabled = false //Will be enabled when at least one convo is selected
            
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                
                self.deleteConversationButton.alpha = 0
                
            }) { (finished: Bool) in
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.tabBar.alpha = 1
                })
            }
        }
    }
    
    //MARK: - Vibrate Function
    
    private func vibrate () {
        
        let generator: UIImpactFeedbackGenerator?
        
        if #available(iOS 13.0, *) {

            generator = UIImpactFeedbackGenerator(style: .rigid)
        
        } else {
            
            generator = UIImpactFeedbackGenerator(style: .medium)
        }
        
        generator?.impactOccurred()
    }
    
    //MARK: - Prepare for Segue Function
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToAddMembersView" {
            
            let addMembersVC = segue.destination as! AddMembersViewController
            addMembersVC.membersAddedDelegate = self
            addMembersVC.headerLabelText = "Conversate With"
        }
        
        else if segue.identifier == "moveToMessagesView" {
            
            let messagesVC = segue.destination as! MessagingViewController
            messagesVC.moveToConversationWithFriendDelegate = self
            
            if selectedView == "personal" {
                
                //messagesVC.conversationID = selectedConversationID
                
                messagesVC.personalConversation = selectedConversation
                
            } else {

                messagesVC.collabConversation = selectedConversation
                
                //messagesVC.collabID = selectedConversationID
            }

            //messagesVC.conversationMembers = selectedConversationMembers
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    //MARK: - Buttons and IBAction Functions
    
    @objc private func deleteConversation () {
        
    }
    
    @IBAction func searchTextChanged(_ sender: Any) {
        
        filteredConversations.removeAll()
        
        if searchTextField.text!.leniantValidationOfTextEntered() {
            
            searchBeingConducted = true
            
            //let conversations = personalConversations != nil ? personalConversations : collabConversations
            
            let conversations = selectedView == "personal" ? personalConversations : collabConversations
            
            for conversation in conversations ?? [] {
                
                if conversation.conversationName != nil {
                    
                    if conversation.conversationName!.localizedCaseInsensitiveContains(searchTextField.text!) {
                        
                        filteredConversations.append(conversation)
                    }
                }
                
                //If the conversation has yet to be named, search by the name of the members
                else {
                    
                    for member in conversation.members {
                        
                        if member.firstName.localizedCaseInsensitiveContains(searchTextField.text!) {
                            
                            filteredConversations.append(conversation)
                            break
                        }
                    }
                }
            }
        }
        
        else {
            
            searchBeingConducted = false
        }
        
        messagingHomeTableView.reloadData()
    }
    
    @IBAction func personal_collabButtonPressed(_ sender: Any) {
        
        //firebaseMessaging.conversations.removeAll()
        removeListeners()
        
        if selectedView == "personal" {
            
            selectedView = "collab"
            
            //personalConversations = nil
            
            let delayDuration = viewEditing ? 0.7 : 0
            
            editConversations(beginEditing: false)
            hideNewConversationButton(hide: true)
            hideTabBar(hide: false)
            
            NotificationCenter.default.removeObserver(self)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delayDuration) {
                
                self.firebaseMessaging.retrieveCollabConversations { [weak self] (conversations, error) in
    
                    if error != nil {
    
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }
    
                    else {
                        
                        self?.collabConversations = conversations
                        self?.addNotificationObservors()
                        //self?.reloadTableView()
                        self?.messagingHomeTableView.reloadData()
                        self?.personal_collabButton.setTitle("Personal", for: .normal)
    
                        self?.navigationItem.rightBarButtonItem = nil
                    }
                }
            }
        }
        
        else {
            
            selectedView = "personal"
            
            //collabConversations = nil
            
            hideNewConversationButton(hide: false)
            
            NotificationCenter.default.removeObserver(self)
            
            firebaseMessaging.retrievePersonalConversations2 { (conversations, error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    self.personalConversations = conversations
                    self.addNotificationObservors()
                    //self.reloadTableView()
                    self.messagingHomeTableView.reloadData()
                    self.personal_collabButton.setTitle("Collab", for: .normal)
                    
                    self.navigationItem.rightBarButtonItem = self.editButtonItem
                    super.setEditing(false, animated: true)
                    self.editButtonItem.style = .done
                }
            }
        }
    }
    
    @IBAction func sortButtonPressed () {
        
        print("sort by pressed")
    }
    
    @objc private func newMessageButtonPressed () {
        
        performSegue(withIdentifier: "moveToAddMembersView", sender: self)
    }
    
    
    @objc private func dismissKeyboard () {
        
        searchTextField.endEditing(true)
    }
}

//MARK: - MembersAdded Extension

extension MessagesHomeViewController: MembersAdded {
    
    func membersAdded(members: [Friend]) {
        
//        membersLoadedCount = 0
//        conversationPreviewLoadedCount = 0
        
        //If it isn't a new conversation
        if let conversation = verifyNewConversation(members: members) {
            
            dismiss(animated: true) {
                
                //self.selectedConversationID = conversation
                
                self.selectedConversation = conversation
                
                self.performSegue(withIdentifier: "moveToMessagesView", sender: self)
            }
        }
        
        else {
            
            SVProgressHUD.show()
            
            firebaseMessaging.createPersonalConversation(members: members) { (conversationID, error) in

                if error != nil {

                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }

                else {

                    SVProgressHUD.dismiss()

                    self.dismiss(animated: true, completion: {

                        //let conversations = self.personalConversations != nil ? self.personalConversations : self.collabConversations
                        
                        let conversations = self.selectedView == "personal" ? self.personalConversations : self.collabConversations
                        
                        for convo in conversations ?? [] {
                            
                            if convo.conversationID == conversationID {
                                
                                self.selectedConversation = convo
                                
                                self.performSegue(withIdentifier: "moveToMessagesView", sender: self)
                                
                                break
                            }
                        }

                        
                        //self.selectedConversationID = conversationID

//                        self.performSegue(withIdentifier: "moveToMessagesView", sender: self)
                    })
                }
            }
        }
    }
}

extension MessagesHomeViewController: MoveToConversationWithFriendProtcol {
    
    func moveToConversationWithFriend(_ friend: Friend) {
        
        if selectedView != "personal" {
            
            personal_collabButtonPressed(self)
        }
        
        membersAdded(members: [friend])
    }
}
