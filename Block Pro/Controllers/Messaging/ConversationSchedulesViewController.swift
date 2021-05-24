//
//  ConversationSchedulesViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/23/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class ConversationSchedulesViewController: UIViewController {

    let navBar = UINavigationBar()
    let schedulesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    let firebaseMessaging = FirebaseMessaging.sharedInstance
    var personalConversation: Conversation?
    var collabConversation: Conversation?
    
    let formatter = DateFormatter()
    
    var scheduleMessages: [Message]? {
        didSet {
            
            schedulesCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        configureNavBar()
        configureCollectionView(schedulesCollectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        monitorMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        firebaseMessaging.messageListener?.remove()
    }
    
    
    //MARK: - Configure Nav Bar
    
    private func configureNavBar () {
        
        self.title = "Schedules"
        self.navigationController?.navigationBar.configureNavBar()
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(cancelButtonPressed))
        cancelButton.style = .done
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    
    //MARK: - Configure CollectionView
    
    private func configureCollectionView (_ collectionView: UICollectionView) {
        
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 54),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = .white
        
        //Appropriate item size based on factoring in the interitem and line spacing as well as the sections insets
        let itemSize = (UIScreen.main.bounds.size.width - 8) / 3
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        layout.scrollDirection = .vertical
        
        collectionView.collectionViewLayout = layout
        
        collectionView.register(ConvoScheduleCollectionViewCell.self, forCellWithReuseIdentifier: "convoScheduleCollectionViewCell")
    }
    
    
    //MARK: - Monitor Messages
    
    private func monitorMessages () {
        
        if let conversationID = personalConversation?.conversationID {
            
            firebaseMessaging.retrieveAllPersonalMessages(conversationID: conversationID) { [weak self] (messages, error) in
                
                if error != nil {
                    
                    print(error?.localizedDescription as Any)
                }
                
                else {
                    
                    let retrievedScheduleMessages = self?.firebaseMessaging.filterScheduleMessages(messages: messages)
                    
                    //If new schedule messages have been recieved
                    if retrievedScheduleMessages?.count != self?.scheduleMessages?.count {
                        
                        self?.scheduleMessages = retrievedScheduleMessages?.sorted(by: { $0.timestamp > $1.timestamp })
                        
                        self?.schedulesCollectionView.reloadData()
                    }
                }
            }
        }
        
        else if let collabID = collabConversation?.conversationID {
            
            firebaseMessaging.retrieveAllCollabMessages(collabID: collabID) { [weak self] (messages, error) in
                
                if error != nil {
                    
                    print(error?.localizedDescription as Any)
                }
                
                else {
                    
                    let retrievedScheduleMessages = self?.firebaseMessaging.filterScheduleMessages(messages: messages)
                    
                    //If new schedule messages have been recieved
                    if retrievedScheduleMessages?.count != self?.scheduleMessages?.count {
                        
                        self?.scheduleMessages = retrievedScheduleMessages?.sorted(by: { $0.timestamp > $1.timestamp })
                        
                        self?.schedulesCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    
    //MARK: - Move to Schedule View
    
    private func moveToScheduleView (message: Message) {
        
        let scheduleVC = ScheduleMessageViewController()
        scheduleVC.message = message
        scheduleVC.members = personalConversation != nil ? personalConversation?.historicMembers : collabConversation?.historicMembers
        
        self.navigationController?.pushViewController(scheduleVC, animated: true)
        
        let backBarItem = UIBarButtonItem()
        backBarItem.title = ""
        self.navigationItem.backBarButtonItem = backBarItem
    }
    
    
    //MARK: - Cancel Button Pressed
    
    @objc private func cancelButtonPressed () {
        
        self.dismiss(animated: true)
    }
}


//MARK: - CollectionView Delegate and DataSource Extension

extension ConversationSchedulesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return scheduleMessages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "convoScheduleCollectionViewCell", for: indexPath) as! ConvoScheduleCollectionViewCell
        
        cell.formatter = formatter
        cell.members = personalConversation != nil ? personalConversation?.historicMembers : collabConversation?.historicMembers
        cell.message = scheduleMessages?[indexPath.row]
        
        cell.layer.cornerRadius = 0
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let message = scheduleMessages?[indexPath.row] {
            
            moveToScheduleView(message: message)
        }
    }
}
