//
//  BlockPopoverViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/8/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import RealmSwift

protocol UpdateTimeBlock {
    
    func moveToUpdateView ()
}

protocol BlockDeleted {
    
    func deleteBlock()
}

class BlockPopoverViewController: UIViewController {


    @IBOutlet weak var bigOutlineView: UIView!
    @IBOutlet weak var bigContainerView: UIView!
    
    @IBOutlet weak var alphaView: UIView!
    
    @IBOutlet weak var blockName: UILabel!
    
    @IBOutlet weak var blockStartTime: UILabel!
    @IBOutlet weak var blockEndTime: UILabel!
    
    @IBOutlet weak var blockCategory: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    
    let realm = try! Realm()
    var currentDateObject: TimeBlocksDate?
    
    let timeBlockViewObject = TimeBlockViewController()
    
    let blockCategoryColors: [String : String] = ["Work": "#5065A0", "Creative Time" : "#FFCC02", "Sleep" : "#745EC4", "Food/Eat" : "#B8C9F2", "Leisure" : "#EFDDB3", "Exercise": "#E84D3C", "Self-Care" : "#1ABC9C", "Other" : "#AAAAAA"]
    
    var updateTimeBlockDelegate: UpdateTimeBlock?
    var blockDeletedDelegate: BlockDeleted?
    
    var blockID: String = ""
    var notificationID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewAdjustments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        configureBigBlock()
    }
    
    //Function responsible for adjusting elements of the bigBlock
    func viewAdjustments () {
       
        //bigTimeBlock View Adjustments
        bigOutlineView.layer.cornerRadius = 0.055 * bigOutlineView.bounds.size.width
        bigOutlineView.clipsToBounds = true
        
        bigContainerView.layer.cornerRadius = 0.055 * bigContainerView.bounds.size.width
        bigContainerView.clipsToBounds = true
        
        //alphaView Adjustments
        alphaView.layer.cornerRadius = 0.1 * alphaView.bounds.size.width
        alphaView.clipsToBounds = true
        
        //Edit and Delete View Adjustments
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
        
        bigOutlineView.backgroundColor = UIColor(hexString: blockCategoryColors[bigBlockData.blockCategory] ?? "#AAAAAA")
        bigContainerView.backgroundColor = UIColor.flatWhite()
        
        blockName.text = bigBlockData.name
        blockName.adjustsFontSizeToFitWidth = true
        
        blockStartTime.text = convertTo12Hour(bigBlockData.startHour, bigBlockData.startMinute)
        blockEndTime.text = convertTo12Hour(bigBlockData.endHour, bigBlockData.endMinute) 
        
        blockCategory.text = bigBlockData.blockCategory
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
            return "Error"
        }
    }

    
    @IBAction func editButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
        updateTimeBlockDelegate?.moveToUpdateView()
    }
    
    @IBAction func deleteButton(_ sender: Any) {

        //Setting the title and message of the "deleteAlert"
        let deleteAlert = UIAlertController(title: "Delete Time Block", message: "Are you sure you would like to delete this Time Block?", preferredStyle: .actionSheet)
        
        //Setting the delete action of the deleteAlert
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (deleteAction) in
            
            self.dismiss(animated: true, completion: nil)
            
            self.blockDeletedDelegate?.deleteBlock()
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
