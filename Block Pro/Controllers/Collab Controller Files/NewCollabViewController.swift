//
//  NewCollabViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/9/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import Firebase

//Protocol required to reload collabs on the UpcomingCollabViewController
protocol GetNewCollab {
    
    func getNewCollab ()
}

//Protocol required to dismiss the SelectedFriendViewController
protocol DismissView {
    
    func dismissSelectedFriend (_ collabID: String, _ collabName: String, _ collabDate: String)
}

class NewCollabViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var newCollabView: UIView!
    @IBOutlet weak var collabViewTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var collabViewLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var collabViewTrailingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var newCollabLabelContainer: UIView!
    @IBOutlet weak var newCollabLabel: UILabel!
    
    @IBOutlet weak var collabNameTextField: UITextField!
    @IBOutlet weak var collabWithTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var collabButtonContainerView: UIView!
    @IBOutlet weak var collabButton: UIButton!
    @IBOutlet weak var buttonAnimationView: UIView!
    
    @IBOutlet weak var buttonAnimationLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var buttonAnimationTrailingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var exitButton: UIButton!
    
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var datePickerContainer: UIView!
    @IBOutlet weak var dateContainerTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var getCollabDelegate: GetNewCollab?
    var dismissViewDelegate: DismissView?
    
    var db = Firestore.firestore()

    let currentUser = UserData.singletonUser
    
    var collabID: String = ""
    var collabName: String = ""
    var collabDate: String = ""
    
    var friendObjectArray: [Friend] = [Friend]()
    var selectedFriend: Friend?
    var selectedCell: UITableViewCell?
    
    let formatter = DateFormatter()
    
    var collabViewInitialTop: CGFloat = 0.0
    
    var gradientLayer: CAGradientLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        
        friendsTableView.backgroundColor = UIColor(hexString: "2E2E2E")
        friendsTableView.separatorColor = .white
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame =  CGRect(x: 0, y: 0, width: 400, height: 44)
        gradientLayer.colors = [UIColor(hexString: "#e35d5b")?.cgColor as Any, UIColor(hexString: "#e53935")?.cgColor as Any]
        
        newCollabLabelContainer.layer.addSublayer(gradientLayer)
        
        newCollabLabelContainer.bringSubviewToFront(newCollabLabel)
        
        collabNameTextField.delegate = self
        collabWithTextField.delegate = self
        dateTextField.delegate = self
        
        newCollabView.layer.cornerRadius = 0.095 * newCollabView.bounds.size.width
        newCollabView.clipsToBounds = true
        
        collabButtonContainerView.layer.cornerRadius = 0.06 * collabButton.bounds.size.width
        collabButtonContainerView.clipsToBounds = true
        
//        collabButton.layer.cornerRadius = 0.065 * collabButton.bounds.size.width
//        collabButton.clipsToBounds = true
        
        buttonAnimationView.layer.cornerRadius = 0.3 * buttonAnimationView.bounds.size.width
        buttonAnimationView.clipsToBounds = true
        //buttonAnimationView.backgroundColor = UIColor(hexString: "#e35d5b")
        buttonAnimationView.isHidden = true
        
        datePickerContainer.layer.cornerRadius = 0.1 * datePickerContainer.bounds.size.width
        datePickerContainer.clipsToBounds = true
        
        friendsTableView.layer.cornerRadius = 0.065 * friendsTableView.bounds.size.width
        friendsTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] //Top left corner and top right corner respectively
        friendsTableView.clipsToBounds = true
        
        datePicker.setValue(UIColor.white, forKey: "textColor")
        datePicker?.addTarget(self, action: #selector(dateSelected(datePicker:)), for: .valueChanged)
        
        datePicker.setValue(false, forKey: "highlightsToday") //Stops the current date text from being black
        
        collabWithTextField.inputView = UIView()
        dateTextField.inputView = UIView()
        
        datePickerContainer.frame.origin.y = 850
        datePicker.minimumDate = Date()
        
        friendsTableView.frame = CGRect(x: friendsTableView.frame.origin.x, y: 850, width: friendsTableView.frame.width, height: 810)
        
        formatter.dateFormat = "MMMM dd, yyyy"
        dateTextField.text = formatter.string(from: datePicker.date)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        newCollabView.addGestureRecognizer(tap)
        
        friendPreselected()
        
        configureConstraints()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFriends()
    }
    
    func configureConstraints () {
        
        dateContainerTopAnchor.constant = 900
        tableViewHeightConstraint.constant = 0
        
        //iPhone XS Max & iPhone XR
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {
            
            collabViewInitialTop = collabViewTopAnchor.constant // 150
        }
            
        //iPhone 8 Plus
        else if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 736.0 {
            
            collabViewTopAnchor.constant = 110
            collabViewInitialTop = 110
            
        }
            
        //iPhone XS
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            
            collabViewInitialTop = collabViewTopAnchor.constant // 150

        }
            
        //iPhone 8
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0 {
            
            collabViewTopAnchor.constant = 110
            collabViewInitialTop = 110
        }
            
        //iPhone SE
        else if UIScreen.main.bounds.width == 320.0 {
            
            collabViewTopAnchor.constant = 90
            collabViewInitialTop = 90
            
            collabViewLeadingAnchor.constant = 15
            collabViewTrailingAnchor.constant = 15
            
            buttonAnimationTrailingAnchor.constant = 93
            buttonAnimationLeadingAnchor.constant = 93
            
        }
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Friends"
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
//        headerView.backgroundColor = UIColor(hexString: "2E2E2E")
//        return headerView
//
//    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        view.tintColor = UIColor(hexString: "2E2E2E")?.darken(byPercentage: 0.025)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendObjectArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendName", for: indexPath)
        
        cell.backgroundColor = UIColor(hexString: "2E2E2E")
        cell.tintColor = UIColor.white
        cell.textLabel?.textColor = UIColor.white
        
        cell.textLabel!.text = friendObjectArray[indexPath.row].firstName + " " + friendObjectArray[indexPath.row].lastName
        
        guard selectedFriend != nil else { return cell }
        
            if friendObjectArray[indexPath.row].friendID == selectedFriend?.friendID {
                cell.accessoryType = .checkmark
                selectedCell = cell
            }
        
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
            if cell.accessoryType == .none {
                
                selectedCell?.accessoryType = .none
                
                cell.accessoryType = .checkmark
                selectedFriend = friendObjectArray[indexPath.row]
                collabWithTextField.text = friendObjectArray[indexPath.row].firstName + " " + friendObjectArray[indexPath.row].lastName
                
                selectedCell = cell
            }
            else {
               
                selectedCell?.accessoryType = .none
                
                cell.accessoryType = .none
                selectedFriend = nil
                collabWithTextField.text = ""
                
                selectedCell = cell
        }
        
            tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        animateViews(textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        view.layoutIfNeeded()
        collabViewTopAnchor.constant = collabViewInitialTop
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
        return true
    }
    
    func friendPreselected () {
        
        guard let friend = selectedFriend else { return }
        
            collabWithTextField.text! = friend.firstName + " " + friend.lastName
    }
    
    func getFriends () {
        
        db.collection("Users").document(Auth.auth().currentUser!.uid).collection("Friends").getDocuments { (snapshot, error) in
            
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
            else {
                
                if snapshot?.isEmpty == true {
                    print ("you have no friends")
                }
                else {
                    
                    for document in snapshot!.documents {
                        
                        let friend = Friend()
                        
                        friend.friendID = document.data()["friendID"] as! String
                        friend.firstName = document.data()["firstName"] as! String
                        friend.lastName = document.data()["lastName"] as! String
                        friend.username = document.data()["username"] as! String
                        
                        self.friendObjectArray.append(friend)
                    }
                    self.friendObjectArray = self.friendObjectArray.sorted(by: {$0.lastName.lowercased() < $1.lastName.lowercased()})
                    self.friendsTableView.reloadData()
                }
            }
        }
    }
    
    #warning("due to the fact that users can now delete thier accounts, write a way to check to see if the user a person wants to collab with still has an active account")
    
    func createCollab () {
        
        collabID = UUID().uuidString
        collabName = collabNameTextField.text!
        collabDate = dateTextField.text!
        
        let collabData: [String : String] = ["collabID" : collabID, "collabName" : collabNameTextField.text!, "collabDate" : dateTextField.text!]
        
        let collabCreator: [String : String] = ["userID" : currentUser.userID, "firstName" : currentUser.firstName, "lastName" : currentUser.lastName, "username" : currentUser.username, "role" : "Creator"]
        let collaborator: [String : String] = ["userID" : selectedFriend!.friendID, "firstName" : selectedFriend!.firstName, "lastName" : selectedFriend!.lastName, "username" : selectedFriend!.username, "role" : "Collaborator"]
        
        let creatorData: [String : Any] = ["collabID" : collabID, "collabName" : collabNameTextField.text!, "with" : collaborator, "collabDate" : dateTextField.text!]
        let collaboratorData: [String : Any] = ["collabID" : collabID, "collabName" : collabNameTextField.text!, "with" : collabCreator, "collabDate" : dateTextField.text!]
        
        db.collection("Collaborations").document(collabID).setData(collabData)
        db.collection("Collaborations").document(collabID).collection("Participants").document(currentUser.userID).setData(collabCreator)
        db.collection("Collaborations").document(collabID).collection("Participants").document(selectedFriend!.friendID).setData(collaborator)
        
        db.collection("Users").document(currentUser.userID).collection("UpcomingCollabs").document(collabID).setData(creatorData)
        db.collection("Users").document(selectedFriend!.friendID).collection("PendingCollabs").document(collabID).setData(collaboratorData)
    }
    
    func animateButton () {
        
        buttonAnimationView.isHidden = false
        
        buttonAnimationLeadingAnchor.constant = -10
        buttonAnimationTrailingAnchor.constant = -10
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.collabButton.backgroundColor = .white
            self.view.layoutIfNeeded()
            
        }) { (finished: Bool) in

            self.dismiss(animated: true, completion: {

                self.dismissViewDelegate?.dismissSelectedFriend(self.collabID, self.collabName, self.collabDate)
            })
        }
    }
    
    @objc func dateSelected (datePicker: UIDatePicker) {
        
        dateTextField.text = formatter.string(from: datePicker.date)
        
    }
    

    @IBAction func collabButton(_ sender: Any) {
        
        //animateButton()
        
        if collabNameTextField.text == "" {
            ProgressHUD.showError("Please enter a name for your Collab")
        }
        else if selectedFriend == nil {
            ProgressHUD.showError("Please select a friend you would like to Collab with")
        }
        else {
            createCollab()
            animateButton()
            //getCollabDelegate?.getNewCollab()
        }
        
    }
    
    //Function that dismisses the keyboard and the PickerViews
    @objc func dismissKeyboard () {
        
        view.endEditing(true)
        
        view.layoutIfNeeded()
        collabViewTopAnchor.constant = collabViewInitialTop
        tableViewHeightConstraint.constant = 0
        dateContainerTopAnchor.constant = 900
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction func exitButton(_ sender: Any) {
        
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
}

extension NewCollabViewController {
    
    func animateViews (_ textField: UITextField) {
        
        //iPhone XS Max & iPhone XR
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {
            
            switch textField {
                
            case collabNameTextField:
                
                self.view.layoutIfNeeded()
                collabViewTopAnchor.constant = 150
                dateContainerTopAnchor.constant = 900
                tableViewHeightConstraint.constant = 0
                
                UIView.animate(withDuration: 0.25) {
                    
                    self.view.layoutIfNeeded()
                }
                
            case collabWithTextField:
                
                self.view.layoutIfNeeded()
                dateContainerTopAnchor.constant = 900
                
                UIView.animate(withDuration: 0.15, animations: {
                    
                    self.view.layoutIfNeeded()
                    
                }) { (finished: Bool) in
                    
                    self.view.layoutIfNeeded()
                    self.collabViewTopAnchor.constant = 80
                    self.tableViewHeightConstraint.constant = 500
                    
                    UIView.animate(withDuration: 0.15, animations: {
                        self.view.layoutIfNeeded()
                    })
                }
                
            case dateTextField:
                
                self.view.layoutIfNeeded()
                tableViewHeightConstraint.constant = 0
                
                
                UIView.animate(withDuration: 0.15, animations: {
                    
                    self.view.layoutIfNeeded()
                    
                }) { (finished: Bool) in
                    
                    self.view.layoutIfNeeded()
                    self.collabViewTopAnchor.constant = 150
                    self.dateContainerTopAnchor.constant = 550
                    
                    UIView.animate(withDuration: 0.15) {
                        
                        self.view.layoutIfNeeded()
                    }
                }
                
            default:
                break
            }
        }
            
        //iPhone 8 Plus
        else if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 736.0 {
            
            switch textField {
                
            case collabNameTextField:
                
                self.view.layoutIfNeeded()
                collabViewTopAnchor.constant = 90
                dateContainerTopAnchor.constant = 900
                tableViewHeightConstraint.constant = 0
                
                UIView.animate(withDuration: 0.25) {
                    
                    self.view.layoutIfNeeded()
                }
                
            case collabWithTextField:
                
                self.view.layoutIfNeeded()
                collabViewTopAnchor.constant = 60
                dateContainerTopAnchor.constant = 900
                tableViewHeightConstraint.constant = 375
                
                UIView.animate(withDuration: 0.25) {
                    
                    self.view.layoutIfNeeded()
                }
                
            case dateTextField:
                
                self.view.layoutIfNeeded()
                collabViewTopAnchor.constant = 90
                tableViewHeightConstraint.constant = 0
                dateContainerTopAnchor.constant = 450
                
                UIView.animate(withDuration: 0.25) {
                    
                    self.view.layoutIfNeeded()
                }
                
            default:
                break
            }
            
        }
            
        //iPhone XS
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            
            switch textField {
                
            case collabNameTextField:
                
                self.view.layoutIfNeeded()
                collabViewTopAnchor.constant = 130
                dateContainerTopAnchor.constant = 900
                tableViewHeightConstraint.constant = 0
                
                UIView.animate(withDuration: 0.25) {
                    
                    self.view.layoutIfNeeded()
                }
                
            case collabWithTextField:
                
                self.view.layoutIfNeeded()
                collabViewTopAnchor.constant = 75
                dateContainerTopAnchor.constant = 900
                tableViewHeightConstraint.constant = 400
                
                UIView.animate(withDuration: 0.25) {
                    
                    self.view.layoutIfNeeded()
                }
                
            case dateTextField:
                
                self.view.layoutIfNeeded()
                collabViewTopAnchor.constant = 130//collabViewInitialTop
                tableViewHeightConstraint.constant = 0
                dateContainerTopAnchor.constant = 480
                
                UIView.animate(withDuration: 0.25) {
                    
                    self.view.layoutIfNeeded()
                }
                
            default:
                break
            }
            
        }
            
        //iPhone 8
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0{
            
            switch textField {
                
            case collabNameTextField:
                
                self.view.layoutIfNeeded()
                collabViewTopAnchor.constant = 80
                dateContainerTopAnchor.constant = 900
                tableViewHeightConstraint.constant = 0
                
                UIView.animate(withDuration: 0.25) {
                    
                    self.view.layoutIfNeeded()
                }
                
            case collabWithTextField:
                
                self.view.layoutIfNeeded()
                collabViewTopAnchor.constant = 60
                dateContainerTopAnchor.constant = 900
                tableViewHeightConstraint.constant = 300
                
                UIView.animate(withDuration: 0.25) {
                    
                    self.view.layoutIfNeeded()
                }
                
                
            case dateTextField:
                
                self.view.layoutIfNeeded()
                collabViewTopAnchor.constant = 80
                tableViewHeightConstraint.constant = 0
                dateContainerTopAnchor.constant = 400
                
                UIView.animate(withDuration: 0.25) {
                    
                    self.view.layoutIfNeeded()
                }
                
            default:
                break
            }
            
        }
            
        //iPhone SE
        else if UIScreen.main.bounds.width == 320.0 {
            
            switch textField {
                
            case collabNameTextField:
                
                self.view.layoutIfNeeded()
                collabViewTopAnchor.constant = 40
                dateContainerTopAnchor.constant = 900
                tableViewHeightConstraint.constant = 0
                
                UIView.animate(withDuration: 0.25) {
                    
                    self.view.layoutIfNeeded()
                }
                
            case collabWithTextField:
                
                self.view.layoutIfNeeded()
                collabViewTopAnchor.constant = 40
                dateContainerTopAnchor.constant = 900
                tableViewHeightConstraint.constant = 250
                
                UIView.animate(withDuration: 0.25) {
                    
                    self.view.layoutIfNeeded()
                }
                
                
            case dateTextField:
                
                self.view.layoutIfNeeded()
                collabViewTopAnchor.constant = 40
                tableViewHeightConstraint.constant = 0
                dateContainerTopAnchor.constant = 325
                
                UIView.animate(withDuration: 0.25) {
                    
                    self.view.layoutIfNeeded()
                }
                
            default:
                break
            }
            
        }
    }
}
