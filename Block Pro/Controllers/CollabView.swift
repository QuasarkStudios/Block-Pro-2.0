//
//  CollabView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/24/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

class CollabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var leftBarButtonItem: UIButton!
    var rightBarButtonItem1: UIButton!
    var rightBarButtonItem2: UIButton!
    
    @IBOutlet weak var collabName: UILabel!
    @IBOutlet weak var collabObjective: UITextView!
    
    @IBOutlet weak var editCollabButton: UIButton!
    
    @IBOutlet weak var collabNavigationContainer: UIView!
    @IBOutlet weak var collabNavigationContainerTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var panGestureIndicator: UIView!
    @IBOutlet weak var panGestureView: UIView!
    
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var blocksButton: UIButton!
    @IBOutlet weak var messagesButton: UIButton!
    
    @IBOutlet weak var collabTableView: UITableView!
    @IBOutlet weak var tableViewTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomAnchor: NSLayoutConstraint!
    
    let messageInputAccesoryView = InputAccesoryView()
    let textViewContainer = MessageTextViewContainer()
    let messageTextView = UITextView()
    let sendButton = UIButton(type: .system)
    
    let currentUser = CurrentUser.sharedInstance
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    var collab: Collab?
    
    var messages: [Message]?
    
    var viewInitiallyLoaded: Bool = false
    
    var selectedTab: String = "Blocks"
    
    var keyboardHeight: CGFloat?
    
    var gestureViewPanGesture: UIPanGestureRecognizer?
    var stackViewPanGesture: UIPanGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavBar()
        configureGestureRecognizers()
        
        configureTableView()
        
        configureTextViewContainer()
        
        retrieveMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        addKeyboardObservor()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        removeKeyboardObservor()
        
        firebaseCollab.messageListener?.remove()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !viewInitiallyLoaded {
           
            configureView()
            viewInitiallyLoaded = true
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return messageInputAccesoryView
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if selectedTab == "Messages" {
            
            return (messages?.count ?? 0) * 2
        }
        
        else {
            
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageCell
            cell.collabMembers = collab?.members // Must be set first
            cell.previousMessage = (indexPath.row / 2) - 1 >= 0 ? messages![(indexPath.row / 2) - 1] : nil
            cell.message = messages?[indexPath.row / 2]
            
            cell.selectionStyle = .none
            
            return cell
        }
        
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell", for: indexPath)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row % 2 == 0 {
        
            //First message
            if indexPath.row == 0 {
                
               //If the current user sent the message
                if messages?[indexPath.row / 2].sender == currentUser.userID {
                    
                    return (messages?[indexPath.row / 2].message.estimateFrameForMessageCell().height)! + 15
                }
                
                else {
                    
                   return (messages?[indexPath.row / 2].message.estimateFrameForMessageCell().height)! + 30
                }
            }
            
            //Not the first message
            else if (indexPath.row / 2) - 1 > 0 {
                
                //If the current user sent the message
                if messages?[indexPath.row / 2].sender == currentUser.userID {
                    
                    return (messages?[indexPath.row / 2].message.estimateFrameForMessageCell().height)! + 15
                }
                
                //If the previous message was sent by another user
                else if messages?[indexPath.row / 2].sender != messages![(indexPath.row / 2) - 1].sender {
                    
                    return (messages?[indexPath.row / 2].message.estimateFrameForMessageCell().height)! + 30
                }
            }
        
            return (messages?[indexPath.row / 2].message.estimateFrameForMessageCell().height)! + 15
        }
        
        else {
            
            //Seperator cell
            return determineSeperatorRowHeight(indexPath: indexPath)
        }
    }
    
    private func configureNavBar () {
        
        rightBarButtonItem1 = UIButton(type: .system)
        rightBarButtonItem1.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        rightBarButtonItem1.setImage(UIImage(named: "UserGroup"), for: .normal)
        rightBarButtonItem1.addTarget(self, action: #selector(usersButtonPressed), for: .touchUpInside)
        
        rightBarButtonItem2 = UIButton(type: .system)
        rightBarButtonItem2.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        rightBarButtonItem2.setImage(UIImage(named: "attach"), for: .normal)
        rightBarButtonItem2.addTarget(self, action: #selector(attachmentButtonPressed), for: .touchUpInside)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightBarButtonItem2), UIBarButtonItem(customView: rightBarButtonItem1)]
    }
    
    private func configureView () {
        
        collabName.text = collab?.name
        collabObjective.text = collab?.objective
        
        editCollabButton.layer.cornerRadius = 10
        
        collabNavigationContainer.backgroundColor = .white
        
        collabNavigationContainer.layer.shadowRadius = 2
        collabNavigationContainer.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        collabNavigationContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        collabNavigationContainer.layer.shadowOpacity = 0.35
        
        collabNavigationContainer.layer.cornerRadius = 25
        collabNavigationContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collabNavigationContainer.layer.masksToBounds = false
        
        collabNavigationContainerTopAnchor.constant = (editCollabButton.frame.minY - 10)
        
        panGestureIndicator.backgroundColor = UIColor(hexString: "35393C")
        panGestureIndicator.layer.cornerRadius = 3
        
        panGestureView.backgroundColor = .clear
        
        progressButton.setTitleColor(.lightGray, for: .normal)
        messagesButton.setTitleColor(.lightGray, for: .normal)
        
        tableViewBottomAnchor.constant = 0
    }
    
    private func configureTableView () {
        
        collabTableView.dataSource = self
        collabTableView.delegate = self
        
        collabTableView.rowHeight = 50
        collabTableView.separatorStyle = .none
        
        collabTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "messageCell")
    }
    
    private func addKeyboardObservor () {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingPresented), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingDismissed), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardObservor () {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureGestureRecognizers () {
        
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardTap)
        
        gestureViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        panGestureView.addGestureRecognizer(gestureViewPanGesture!)
        
        stackViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        buttonStackView.addGestureRecognizer(stackViewPanGesture!)
    }
    
    private func reconfigureGestureRecognizers () {
        
        panGestureView.addGestureRecognizer(gestureViewPanGesture!)
        buttonStackView.addGestureRecognizer(stackViewPanGesture!)
    }
    
    private func removeGestureRecognizers () {
        
        if let gestureViewGesture = gestureViewPanGesture, let stackViewGesture = stackViewPanGesture {
            
            panGestureView.removeGestureRecognizer(gestureViewGesture)
            buttonStackView.removeGestureRecognizer(stackViewGesture)
        }
    }
    
    @objc private func handlePan (sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .began, .changed:
            
            moveWithPan(sender: sender)
            
        case .ended:
            
            if (collabNavigationContainerTopAnchor.constant >= (editCollabButton.frame.minY - 70)) && (collabNavigationContainerTopAnchor.constant <= (editCollabButton.frame.minY + editCollabButton.frame.height / 2)) {
                
                returnToOrigin()
            }
            
            else if (collabNavigationContainerTopAnchor.constant > (editCollabButton.frame.minY + editCollabButton.frame.height / 2)){
                
                shrinkView()
            }
            
            else if (collabNavigationContainerTopAnchor.constant < (editCollabButton.frame.minY - 50)) {
                
                expandView()
            }
            
           break
        default:
            
            break
        }
    }
    
    private func moveWithPan (sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        
        if (collabNavigationContainerTopAnchor.constant + translation.y) > (editCollabButton.frame.maxY + 20) {
            
            collabNavigationContainerTopAnchor.constant = editCollabButton.frame.maxY + 20
        }
            
        else if (collabNavigationContainerTopAnchor.constant + translation.y) < (editCollabButton.frame.minY - 10) {
            
            let topAnchorValue = collabNavigationContainerTopAnchor.constant - 44 > 0 ? collabNavigationContainerTopAnchor.constant - 44 : 0
            let adjustedAlpha: CGFloat = ((1 / (editCollabButton.frame.minY - 10)) * topAnchorValue)
            
            panGestureIndicator.alpha = adjustedAlpha > 0 ? adjustedAlpha : 0
            buttonStackView.alpha = adjustedAlpha > 0 ? adjustedAlpha : 0
            
            
            collabNavigationContainerTopAnchor.constant += translation.y
            sender.setTranslation(CGPoint.zero, in: view)
        }
        
        else {
            
            collabNavigationContainerTopAnchor.constant += translation.y
            sender.setTranslation(CGPoint.zero, in: view)
        }
    }
    
    private func returnToOrigin () {
        
        collabNavigationContainerTopAnchor.constant = (editCollabButton.frame.minY - 10)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
            
            self.view.layoutIfNeeded()
            
            self.panGestureIndicator.alpha = 1
            self.buttonStackView.alpha = 1
        })
    }
    
    private func shrinkView () {
        
        collabNavigationContainerTopAnchor.constant = editCollabButton.frame.maxY + 20
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
            
            self.view.layoutIfNeeded()
        })
    }
    
    internal func expandView () {
        
        collabNavigationContainerTopAnchor.constant = 0
        tableViewTopAnchor.constant = setTableViewTopAnchor()//30
 
        title = selectedTab
        
        viewExpanded()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {

            self.view.layoutIfNeeded()

            self.panGestureIndicator.alpha = 0
            self.buttonStackView.alpha = 0
        })
    }
    
    internal func viewExpanded () {
        
        navigationItem.hidesBackButton = true

        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(cancelButtonPressed))
        cancelButton.style = .done
        
        navigationItem.leftBarButtonItem = cancelButton
        
        removeGestureRecognizers()
    }
    
    private func setTableViewTopAnchor () -> CGFloat {
        
        //iPhone 11 Pro Max & iPhone 11
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {
            
            return 30
        }
            
        //iPhone 11 Pro
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            
            return 30
        }
        
        else {
            
            return 0
        }
    }
    
    @objc private func dismissKeyboard () {
        
        messageTextView.resignFirstResponder()
    }
    
    @objc private func cancelButtonPressed () {
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = false

        collabNavigationContainerTopAnchor.constant = (editCollabButton.frame.minY - 10)

        title = ""
        
        reconfigureGestureRecognizers()

        tableViewTopAnchor.constant = 10
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {

           self.view.layoutIfNeeded()

           self.panGestureIndicator.alpha = 1
           self.buttonStackView.alpha = 1
           
        })
        
        if selectedTab == "Messages" {

            dismissKeyboard ()
            
            textViewContainer.constraints.forEach { (constraint) in
                
                if constraint.firstAttribute == .height {
                    
                    constraint.constant = 34
                }
            }
            
            messageTextView.constraints.forEach { (constraint) in
                
                if constraint.firstAttribute == .height {
                    
                    constraint.constant = 34
                }
            }
            
            messageInputAccesoryView.size = messageInputAccesoryView.configureSize()
            
            if messages?.count ?? 0 > 0 {
                
                collabTableView.scrollToRow(at: IndexPath(row: (messages!.count * 2) - 1, section: 0), at: .top, animated: true)
            }
        }
    }
    
    @objc private func usersButtonPressed () {
        
    }
    
    @objc private func attachmentButtonPressed () {
        
        
    }
    
    @IBAction func editCollab(_ sender: Any) {
    }
    
    
    @IBAction func progressButton(_ sender: Any) {
        
        selectedTab = "Progress"
        
        progressButton.setTitleColor(.black, for: .normal)
        blocksButton.setTitleColor(.lightGray, for: .normal)
        messagesButton.setTitleColor(.lightGray, for: .normal)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            
            self.messageInputAccesoryView.alpha = 0
            
        }) { (finished: Bool) in
            
            self.messageInputAccesoryView.isHidden = true
            
            self.tableViewBottomAnchor.constant = 0
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {

                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func blocksButton(_ sender: Any) {
        
        selectedTab = "Blocks"
        
        blocksButton.setTitleColor(.black, for: .normal)
        progressButton.setTitleColor(.lightGray, for: .normal)
        messagesButton.setTitleColor(.lightGray, for: .normal)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                            
            self.messageInputAccesoryView.alpha = 0
            
        }) { (finished: Bool) in
            
            self.messageInputAccesoryView.isHidden = true
            
            self.tableViewBottomAnchor.constant = 0
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func messagesButton(_ sender: Any) {
        
        selectedTab = "Messages"
        
        messagesButton.setTitleColor(.black, for: .normal)
        blocksButton.setTitleColor(.lightGray, for: .normal)
        progressButton.setTitleColor(.lightGray, for: .normal)
        
        tableViewBottomAnchor.constant = messageInputAccesoryView.configureSize().height
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            
            self.view.layoutIfNeeded()
            
            self.collabTableView.alpha = 0

        }) { (finished: Bool) in
            
            self.collabTableView.reloadData()
            
            let row = self.messages?.count ?? 0 > 0 ? (self.messages!.count * 2) - 1 : 0
            self.collabTableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .top, animated: false)
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {

                self.messageInputAccesoryView.isHidden = false
                self.messageInputAccesoryView.alpha = 1
                
                self.collabTableView.alpha = 1
            })
        }
    }
}
