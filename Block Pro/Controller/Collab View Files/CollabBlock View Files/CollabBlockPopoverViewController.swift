//
//  CollabBlockPopoverViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 8/1/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import Firebase

protocol UpdateCollabBlock {
    
    func moveToUpdateView ()
}

protocol DeleteCollabBlock {
    
    func deleteBlock ()
}

class CollabBlockPopoverViewController: UIViewController {

    @IBOutlet weak var bigCollabBlock: UIView!
    
    @IBOutlet weak var blockName: UILabel!
    @IBOutlet weak var initialContainer: UIView!
    @IBOutlet weak var initialLabel: UILabel!
    
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var blockStartTime: UILabel!
    @IBOutlet weak var blockEndTime: UILabel!
    
    @IBOutlet weak var blockCategory: UILabel!

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    
    let db = Firestore.firestore()
    var listener: ListenerRegistration?
    let currentUser = UserData.singletonUser
    
    var updateCollabBlockDelegate: UpdateCollabBlock?
    var deleteCollabBlockDelegate: DeleteCollabBlock?
    
    var collabID: String = ""
    var blockID: String = ""
    var notificationID: String = ""
    
    let blockCategoryColors: [String : String] = ["Work": "#5065A0", "Creative Time" : "#FFCC02", "Sleep" : "#745EC4", "Food/Eat" : "#B8C9F2", "Leisure" : "#EFDDB3", "Exercise": "#E84D3C", "Self-Care" : "#1ABC9C", "Other" : "#EFEFF4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewAdjustments()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        configureBigBlock()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        listener?.remove()
    }
    
    func viewAdjustments () {
        
        //bigCollabBlock View Adjustments
        bigCollabBlock.layer.cornerRadius = 0.055 * bigCollabBlock.bounds.size.width
        bigCollabBlock.clipsToBounds = true
        
        initialContainer.layer.cornerRadius = 0.5 * initialContainer.bounds.size.width
        initialContainer.clipsToBounds = true
        
        alphaView.layer.cornerRadius = 0.05 * alphaView.bounds.size.width
        alphaView.clipsToBounds = true
        
        editButton.backgroundColor = UIColor.flatWhite()
        editButton.layer.cornerRadius = 0.1 * editButton.bounds.size.width
        editButton.clipsToBounds = true
        
        deleteButton.backgroundColor = UIColor.flatRed()
        deleteButton.layer.cornerRadius = 0.1 * deleteButton.bounds.size.width
        deleteButton.clipsToBounds = true
    }
    
    func configureBigBlock () {
        
        listener = db.collection("Collaborations").document(collabID).collection("CollabBlocks").document(blockID).addSnapshotListener { (snapshot, error) in
            
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
            
            else {
                
                if snapshot?.data()?.count == 0 {
                    
                    print("something went wrong smh")
                }
                
                else {
                    
                    guard let data = snapshot?.data() else { return }
                    
                    let creator = data["creator"] as! [String : String]
                    
                    if creator["userID"] == self.currentUser.userID {

                        self.initialLabel.text = "Me"
                    }
                    else {
                        
                        let firstNameArray = Array(creator["firstName"]!)
                        let lastNameArray = Array(creator["lastName"]!)
                        
                        self.initialLabel.text = "\(firstNameArray[0])" + "\(lastNameArray[0])"
                    }
                    
                    if data["blockCategory"] as! String == "" {
                        self.bigCollabBlock.backgroundColor = UIColor(hexString: "#EFEFF4")
                    }
                    else {
                       self.bigCollabBlock.backgroundColor = UIColor(hexString: self.blockCategoryColors[data["blockCategory"] as! String])
                    }
                    
                    self.blockName.text = (data["name"] as! String)
                    self.blockStartTime.text = self.convertTo12Hour(data["startHour"] as! String, data["startMinute"] as! String)
                    self.blockEndTime.text = self.convertTo12Hour(data["endHour"] as! String, data["endMinute"] as! String)
                    
                    self.blockCategory.text = (data["blockCategory"] as! String)
                    
                }
            }
        }
    }
    
    //Function that converts the 24 hour format of the times from Firebase to a 12 hour format
    func convertTo12Hour (_ funcHour: String, _ funcMinute: String) -> String {
        
        if funcHour == "0" {
            return "12" + ":" + funcMinute + " " + "AM"
        }
        else if funcHour == "12" {
            return "12" + ":" + funcMinute + " " + "PM"
        }
        else if Int(funcHour)! < 12 {
            return funcHour + ":" + funcMinute + " " + "AM"
        }
        else if Int(funcHour)! > 12 {
            return "\(Int(funcHour)! - 12)" + ":" + funcMinute + " " + "PM"
        }
        else {
            return "Tehee Opps"
        }
    }
    
    
    @IBAction func editButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
        updateCollabBlockDelegate?.moveToUpdateView()
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        
        //Setting the title and message of the "deleteAlert"
        let deleteAlert = UIAlertController(title: "Delete Collab Block", message: "Are you sure you would like to delete this Collab Block?", preferredStyle: .alert)
        
        //Setting the delete action of the deleteAlert
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (deleteAction) in
            
            self.deleteCollabBlockDelegate?.deleteBlock()
            
            self.dismiss(animated: true, completion: nil)
        }
        
        //Setting the cancel action of the deleteAlert
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        deleteAlert.addAction(deleteAction) //Adds the delete action to the alert
        deleteAlert.addAction(cancelAction) //Adds the cancel action to the alert
        
        present(deleteAlert, animated: true, completion: nil) //Presents the deleteAlert
        
    }
    
    @IBAction func exitButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    

}
