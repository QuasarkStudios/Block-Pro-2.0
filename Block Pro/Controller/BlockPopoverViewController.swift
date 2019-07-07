//
//  BlockPopoverViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/8/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import RealmSwift

protocol BlockDeleted {
    
    func deleteBlock ()
}

class BlockPopoverViewController: UIViewController {

    let realm = try! Realm()
    var currentDateObject: TimeBlocksDate?
    
    let blockCategoryColors: [String : String] = ["Work": "#5065A0", "Creative Time" : "#FFCC02", "Sleep" : "#745EC4", "Food/Eat" : "#B8C9F2", "Leisure" : "#EFDDB3", "Exercise": "#E84D3C", "Self-Care" : "#1ABC9C", "Other" : "#EFEFF4"]
    
    var delegate: BlockDeleted?
    
    @IBOutlet weak var bigTimeBlock: UIView!
    
    @IBOutlet weak var alphaView: UIView!
    
    @IBOutlet weak var blockName: UILabel!
    
    @IBOutlet weak var blockStartTime: UILabel!
    @IBOutlet weak var blockEndTime: UILabel!
    
    @IBOutlet weak var note1Bullet: UIView!
    @IBOutlet weak var note2Bullet: UIView!
    @IBOutlet weak var note3Bullet: UIView!
    
    @IBOutlet weak var note1TextView: UITextView!
    @IBOutlet weak var note2TextView: UITextView!
    @IBOutlet weak var note3TextView: UITextView!
    
    @IBOutlet weak var blockCategory: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    
    var blockID: String = ""
    var notificationID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureBigBlock()
        viewAdjustments()
    }
    
    //Function responsible for adjusting elements of the bigBlock
    func viewAdjustments () {
       
        //bigTimeBlock View Adjustments
        bigTimeBlock.layer.cornerRadius = 0.05 * bigTimeBlock.bounds.size.width
        bigTimeBlock.clipsToBounds = true
        
        //alphaView Adjustments
        alphaView.layer.cornerRadius = 0.05 * alphaView.bounds.size.width
        alphaView.clipsToBounds = true
        
        //Note Bullet View Adjustements
        note1Bullet.layer.cornerRadius = 0.5 * note1Bullet.bounds.size.width
        note1Bullet.clipsToBounds = true
        
        note2Bullet.layer.cornerRadius = 0.5 * note2Bullet.bounds.size.width
        note2Bullet.clipsToBounds = true
        
        note3Bullet.layer.cornerRadius = 0.5 * note3Bullet.bounds.size.width
        note3Bullet.clipsToBounds = true
        
        //Note TextView Adjustments
        note1TextView.layer.cornerRadius = 0.05 * note1TextView.bounds.size.width
        note1TextView.clipsToBounds = true
        
        note2TextView.layer.cornerRadius = 0.05 * note2TextView.bounds.size.width
        note2TextView.clipsToBounds = true
        
        note3TextView.layer.cornerRadius = 0.05 * note3TextView.bounds.size.width
        note3TextView.clipsToBounds = true
        
        //Exit, Edit, and Delete View Adjustments
        exitButton.layer.cornerRadius = 0.5 * exitButton.bounds.size.width
        exitButton.clipsToBounds = true
        
        editButton.backgroundColor = UIColor.flatWhite()
        editButton.layer.cornerRadius = 0.1 * editButton.bounds.size.width
        editButton.clipsToBounds = true
        
        deleteButton.backgroundColor = UIColor.flatRed()
        deleteButton.layer.cornerRadius = 0.1 * deleteButton.bounds.size.width
        deleteButton.clipsToBounds = true
    }
    
    //Function that retrieves and sets all the data for the bigBlock
    func configureBigBlock () {
        
        guard let bigBlockData = realm.object(ofType: Block.self, forPrimaryKey: blockID) else { return }
        
        bigTimeBlock.backgroundColor = UIColor(hexString: blockCategoryColors[bigBlockData.blockCategory])
        
        blockName.text = bigBlockData.name
        blockStartTime.text = convertTo12Hour(bigBlockData.startHour, bigBlockData.startMinute)
        blockEndTime.text = convertTo12Hour(bigBlockData.endHour, bigBlockData.endMinute) 
        
        blockCategory.text = bigBlockData.blockCategory
        
        note1TextView.text = bigBlockData.note1
        note2TextView.text = bigBlockData.note2
        note3TextView.text = bigBlockData.note3
    }

    //Function that converts the 24 hour format of the times from Realm to a 12 hour format
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToUpdateBlockView" {
            
            let editBlockView = segue.destination as! Add_Update_BlockViewController
            
            editBlockView.blockID = blockID //Setting the blockID in the editBlockView to the blockID of the selected TimeBlock
            editBlockView.notificationID = notificationID //Setting the notificationID in the editBlockView to the notificationID of the selected TimeBlock
            editBlockView.currentDateObject = currentDateObject //Setting the currentDateObject of the editBlockView to the currentDateObject of this view
        }
    }
    
    @IBAction func editButton(_ sender: Any) {
        
        performSegue(withIdentifier: "moveToUpdateBlockView", sender: self)
    }
    
    @IBAction func deleteButton(_ sender: Any) {

        //Setting the title and message of the "deleteAlert"
        let deleteAlert = UIAlertController(title: "Delete Time Block", message: "Are you sure you would like to delete this Time Block?", preferredStyle: .alert)
        
        //Setting the delete action of the deleteAlert
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (deleteAction) in
            
            self.delegate?.deleteBlock()
            
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
