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
    @IBOutlet weak var newCollabContainer: UIView!
    @IBOutlet weak var newCollabLabel: UILabel!
    
    @IBOutlet weak var collabNameTextField: UITextField!
    @IBOutlet weak var collabWithTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var collabButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    
    @IBOutlet weak var buttonAnimationView: UIView!
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    @IBOutlet weak var datePickerContainer: UIView!
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
    
    var gradientLayer: CAGradientLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        
        friendsTableView.backgroundColor = UIColor(hexString: "2E2E2E")
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = newCollabContainer.bounds
        gradientLayer.colors = [UIColor(hexString: "#e35d5b")?.cgColor as Any, UIColor(hexString: "#e53935")?.cgColor as Any]
        
        newCollabContainer.layer.addSublayer(gradientLayer)
        
        newCollabContainer.bringSubviewToFront(newCollabLabel)
        
        collabNameTextField.delegate = self
        collabWithTextField.delegate = self
        dateTextField.delegate = self
        
        newCollabView.layer.cornerRadius = 0.095 * newCollabView.bounds.size.width
        newCollabView.clipsToBounds = true
        
        collabButton.layer.cornerRadius = 0.065 * collabButton.bounds.size.width
        collabButton.clipsToBounds = true
        
        buttonAnimationView.layer.cornerRadius = 0.3 * buttonAnimationView.bounds.size.width
        buttonAnimationView.clipsToBounds = true
        buttonAnimationView.isHidden = true
        
        datePickerContainer.layer.cornerRadius = 0.1 * datePickerContainer.bounds.size.width
        datePickerContainer.clipsToBounds = true
        
        friendsTableView.layer.cornerRadius = 0.065 * friendsTableView.bounds.size.width
        friendsTableView.clipsToBounds = true
        
        datePicker.setValue(UIColor.white, forKey: "textColor")
        datePicker?.addTarget(self, action: #selector(dateSelected(datePicker:)), for: .valueChanged)
        
        collabWithTextField.inputView = UIView()
        dateTextField.inputView = UIView()
        
        datePickerContainer.frame.origin.y = 850
        datePicker.minimumDate = Date()
        
        friendsTableView.frame = CGRect(x: friendsTableView.frame.origin.x, y: 850, width: friendsTableView.frame.width, height: 810)
        
        formatter.dateFormat = "MMMM dd, yyyy"
        dateTextField.text = formatter.string(from: datePicker.date)
        
        friendPreselected()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFriends()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Friends"
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
        
        switch textField {
            
        case collabNameTextField:
            UIView.animate(withDuration: 0.25) {
                self.newCollabView.frame.origin.y = 135
                self.friendsTableView.frame.origin.y = 850
                self.datePickerContainer.frame.origin.y = 850
            }
        
        case collabWithTextField:
            UIView.animate(withDuration: 0.25) {
                self.newCollabView.frame.origin.y = 100
                self.friendsTableView.frame.origin.y = 400
                self.datePickerContainer.frame.origin.y = 850
            }
            
            
        case dateTextField:
            UIView.animate(withDuration: 0.25) {
                self.newCollabView.frame.origin.y = 135
                self.friendsTableView.frame.origin.y = 850
                self.datePickerContainer.frame.origin.y = 500
            }
        default:
            break
        }
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
                    self.friendObjectArray = self.friendObjectArray.sorted(by: {$0.lastName < $1.lastName})
                    self.friendsTableView.reloadData()
                }
            }
        }
    }
    
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
        
        UIView.animate(withDuration: 0.4, animations: {
            
            self.buttonAnimationView.frame = CGRect(x: self.collabButton.frame.origin.x, y: self.collabButton.frame.origin.y, width: self.collabButton.frame.width, height: self.collabButton.frame.height)
            
            self.buttonAnimationView.layer.cornerRadius = 0.065 * self.buttonAnimationView.bounds.size.width
            self.buttonAnimationView.clipsToBounds = true
            
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
            getCollabDelegate?.getNewCollab()
        }
        
    }
    
    @IBAction func exitButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
