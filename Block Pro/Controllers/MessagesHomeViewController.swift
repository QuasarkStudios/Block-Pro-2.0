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
    
    let tabBar = CustomTabBar.sharedInstance
    
    @IBOutlet weak var searchBarContainer: UIView!
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var personalButton: UIButton!
    @IBOutlet weak var sortByView: UIView!
    
    
    @IBOutlet weak var messagingHomeTableView: UITableView!
    
    let firebaseMessaging = FirebaseMessaging()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureSearchBar()
        configureButtons()
        configureTableView(messagingHomeTableView)
        
        configureGestureRecognizors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        configureNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //configureTabBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        tabBar.previousNavigationController = navigationController
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            
            let nameArray = ["Amy", "Jeff,  Kevin & Dave", "Jess & Sam", "Gabe"]
            let messageArray = ["Hey, are you still free to talk tomorrow? Because my meeting actually got cancelled so I'll be free.  Hey, are you still free to talk tomorrow?", "Hey, are you still free to talk?", "Hey, are you still free to talk tomorrow? If not, it's cool", "Ok. This message is gonna be used to"]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageHomeCell", for: indexPath) as! MessageHomeCell
            cell.messagesTitleLabel.text = nameArray[indexPath.row / 2]
            cell.messagePreview.text = messageArray[indexPath.row / 2]
            //cell.profilePicImageView.configureProfileImageView(profileImage: UIImage(named: profilePicArray[indexPath.row / 2]))
            
            cell.selectionStyle = .none
            
            cell.count = indexPath.row / 2
        
            return cell
        }
        
        else {

            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
//        return 100
        
        if indexPath.row % 2 == 0 {
            
            return 80
        }
        
        else {
            
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let generator: UIImpactFeedbackGenerator?
        
        if #available(iOS 13.0, *) {

            generator = UIImpactFeedbackGenerator(style: .rigid)
        
        } else {
            
            generator = UIImpactFeedbackGenerator(style: .medium)
        }
        
        generator?.impactOccurred()
    }
    
    private func configureNavBar () {
        
        navigationController?.navigationBar.configureNavBar()
        
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 20)!]
        navigationItem.title =  "Messages"
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
        
        personalButton.layer.cornerRadius = 16
        personalButton.clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            personalButton.layer.cornerCurve = .continuous
        }
        
        sortByView.layer.cornerRadius = 16
        sortByView.clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            sortByView.layer.cornerCurve = .continuous
        }
        
        let newMessageButton = UIButton(type: .system)
        newMessageButton.addTarget(self, action: #selector(newMessageButtonPressed), for: .touchUpInside)
        newMessageButton.backgroundColor = UIColor(hexString: "222222")
        newMessageButton.setImage(UIImage(named: "plus 2"), for: .normal)
        newMessageButton.tintColor = .white
        
        view.addSubview(newMessageButton)
        
        newMessageButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            newMessageButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -45),
            newMessageButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -130),
            newMessageButton.widthAnchor.constraint(equalToConstant: 60),
            newMessageButton.heightAnchor.constraint(equalToConstant: 60)
            
        ].forEach( { $0.isActive = true } )
        
        newMessageButton.layer.cornerRadius = 30
        newMessageButton.clipsToBounds = true
        
        
    }
    
    private func configureTableView (_ tableView: UITableView) {
    
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none

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
        
        let sortByGesture = UITapGestureRecognizer(target: self, action: #selector(sortByPressed))
        sortByGesture.cancelsTouchesInView = false
        sortByView.addGestureRecognizer(sortByGesture)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToAddMembersView" {
            
            let addMembersVC = segue.destination as! AddMembersViewController
            addMembersVC.membersAddedDelegate = self
            addMembersVC.headerLabelText = "Conversation With"
        }
    }
    
    @IBAction func personalButtonPressed(_ sender: Any) {
        
        print("personal button pressed")
    }
    
    @objc private func sortByPressed () {
        
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
        
        firebaseMessaging.createConversation(members: members) { (error) in
            
            if error != nil {
                
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
            
            else {
                
                SVProgressHUD.dismiss()
                
                self.dismiss(animated: true, completion: {
                    
                    self.performSegue(withIdentifier: "moveToMessagesView", sender: self)
                })
            }
        }

        
        //dismiss(animated: true, completion: nil)
        
        //print(members)
    }
}
