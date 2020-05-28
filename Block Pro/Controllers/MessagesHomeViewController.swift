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
    
    let firebaseMessaging = FirebaseMessaging()
    
    var conversations: [Conversation]? {
        didSet {
            
            populateEditConversationDictionary(conversations: conversations!)
            
            messagingHomeTableView.reloadData()
        }
    }
    
    var selectedConversationID: String?
    
    var filteredConversations: [Conversation] = []
    var searchBeingConducted: Bool = false
    
    var viewEditing: Bool = false
    var editedConversations: [String : Bool] = [:]
    
    var selectedView: String = "personal"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureSearchBar()
        configureButtons()
        configureTableView(messagingHomeTableView)
        configureGestureRecognizors()
        
        firebaseMessaging.retrievePersonalConversations { (conversations, error) in
            
            if error != nil {
                
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
            
            else {
                
                self.conversations = conversations
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRetrieveConversationMembers), name: .didRetrieveConversationMembers, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRetrieveConversationPreview), name: .didRetrieveConversationPreview, object: nil)
        
        configureNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        tabBar.previousNavigationController = navigationController
        
        NotificationCenter.default.removeObserver(self)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchBeingConducted {

            return filteredConversations.count * 2
        }
        
        else {

            return (conversations?.count ?? 0) * 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            
            var conversationToBeUsed: Conversation?
            
            if searchBeingConducted {
                
                conversationToBeUsed = filteredConversations[indexPath.row / 2]
            }
            
            else {
                
                conversationToBeUsed = conversations?[indexPath.row / 2] ?? nil
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageHomeCell", for: indexPath) as! MessageHomeCell
            cell.conversationID = conversationToBeUsed?.conversationID ?? ""
            cell.conversationCreationDate = conversationToBeUsed?.dateCreated
            cell.conversationName = conversationToBeUsed?.conversationName
            cell.messagePreview = conversationToBeUsed?.messagePreview
            cell.convoMembers = conversationToBeUsed?.members
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        vibrate()
        
        if viewEditing {
            
            let cell = tableView.cellForRow(at: indexPath) as! MessageHomeCell
            cell.checkBox.setOn(!(editedConversations[cell.conversationID] ?? false), animated: true)
            
            editedConversations[cell.conversationID] = !(editedConversations[cell.conversationID] ?? false)
            
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
            
            selectedConversationID = conversations?[indexPath.row / 2].conversationID
            performSegue(withIdentifier: "moveToMessagesView", sender: self)
        }
    }
    
    private func configureNavBar () {
        
        navigationController?.navigationBar.configureNavBar()
        
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 20)!]
        navigationItem.title =  "Messages"
        
        editButtonItem.style = .done
        navigationItem.rightBarButtonItem = editButtonItem
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
    
    @objc private func didRetrieveConversationMembers () {
        
        self.conversations = firebaseMessaging.conversations
    }
    
    @objc private func didRetrieveConversationPreview () {
        
        //Sorted by either the timeStamp of the last message or the time the convo was created if no message has been sent yet
        self.conversations = firebaseMessaging.conversations.sorted(by: { $0.messagePreview?.timestamp ?? $0.dateCreated! > $1.messagePreview?.timestamp ?? $1.dateCreated! })
    }
    
    private func verifyNewConversation (members: [Friend]) -> String? {
        
        var convoArray: [Conversation] = []
        
        //Checks to see which convos have the same amount of members as the one being created
        for convo in conversations ?? [] {
            
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
                
                if let conversation = conversations?.first(where: { $0.conversationID == convo.conversationID }) {
                    
                    //If the convo has yet to be given a name
                    if conversation.conversationName == nil {
                        
                        return conversation.conversationID
                    }
                }
            }
        }
        
        return nil
    }
    
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
            
            populateEditConversationDictionary(conversations: conversations ?? [])
            
            for visibleCell in messagingHomeTableView.visibleCells {
                
                if let cell = visibleCell as? MessageHomeCell {
                    
                    cell.endEditing(animate: true)
                }
            }
        }
    }
    
    private func populateEditConversationDictionary (conversations: [Conversation]) {
        
        for convo in conversations {
            
            editedConversations[convo.conversationID] = false
        }
    }
    
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
    
    private func vibrate () {
        
        let generator: UIImpactFeedbackGenerator?
        
        if #available(iOS 13.0, *) {

            generator = UIImpactFeedbackGenerator(style: .rigid)
        
        } else {
            
            generator = UIImpactFeedbackGenerator(style: .medium)
        }
        
        generator?.impactOccurred()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToAddMembersView" {
            
            let addMembersVC = segue.destination as! AddMembersViewController
            addMembersVC.membersAddedDelegate = self
            addMembersVC.headerLabelText = "Conversate With"
        }
        
        else if segue.identifier == "moveToMessagesView" {
            
            let messagesVC = segue.destination as! MessagingViewController
            messagesVC.conversationID = selectedConversationID
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    @objc private func deleteConversation () {
        
    }
    
    @IBAction func searchTextChanged(_ sender: Any) {
        
        filteredConversations.removeAll()
        
        if searchTextField.text!.leniantValidationOfTextEntered() {
            
            searchBeingConducted = true
            
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
        
        if selectedView == "personal" {
            
            selectedView = "collab"
            
            let delayDuration = viewEditing ? 0.7 : 0
            
            editConversations(beginEditing: false)
            hideNewConversationButton(hide: true)
            hideTabBar(hide: false)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delayDuration) {
                
                self.firebaseMessaging.retrieveCollabConversations { (conversations, error) in
    
                    if error != nil {
    
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }
    
                    else {
    
                        self.conversations = conversations
                        self.personal_collabButton.setTitle("Personal", for: .normal)
    
                        self.navigationItem.rightBarButtonItem = nil
                    }
                }
            }
        }
        
        else {
            
            selectedView = "personal"
            
            hideNewConversationButton(hide: false)
            
            firebaseMessaging.retrievePersonalConversations { (conversations, error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    self.conversations = conversations
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

extension MessagesHomeViewController: MembersAdded {
    
    func membersAdded(members: [Friend]) {
        
        SVProgressHUD.show()
        
        //If it isn't a new conversation
        if let conversation = verifyNewConversation(members: members) {
            
            SVProgressHUD.dismiss()
            
            dismiss(animated: true) {
                
                self.selectedConversationID = conversation
                
                self.performSegue(withIdentifier: "moveToMessagesView", sender: self)
            }
        }
        
        else {
            
            firebaseMessaging.createPersonalConversation(members: members) { (conversationID, error) in

                if error != nil {

                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }

                else {

                    SVProgressHUD.dismiss()

                    self.dismiss(animated: true, completion: {

                        self.selectedConversationID = conversationID

                        self.performSegue(withIdentifier: "moveToMessagesView", sender: self)
                    })
                }
            }
        }
    }
}
