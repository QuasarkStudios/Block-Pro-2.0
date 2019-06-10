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
    var realmData: Results<Block>?
    
    let timeBlockViewObject = TimeBlockViewController()
    
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
    
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    
    var bigBlockDataIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        realmData = realm.objects(Block.self)
        
        viewAdjustments()
        configureBigBlock()
    }
    
    
    func viewAdjustments () {
       
        //bigTimeBlock View Adjustments
        bigTimeBlock.backgroundColor = UIColor.flatMint()
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
    
    func configureBigBlock () {
        
        blockName.text = realmData![bigBlockDataIndex].name
        blockStartTime.text = realmData![bigBlockDataIndex].startHour + ":" + realmData![bigBlockDataIndex].startMinute + " " + realmData![bigBlockDataIndex].startPeriod
        blockEndTime.text = realmData![bigBlockDataIndex].endHour + ":" + realmData![bigBlockDataIndex].endMinute + " " + realmData![bigBlockDataIndex].endPeriod
        
        note1TextView.text = realmData![bigBlockDataIndex].note1
        note2TextView.text = realmData![bigBlockDataIndex].note2
        note3TextView.text = realmData![bigBlockDataIndex].note3
    }

    @IBAction func editButton(_ sender: Any) {
        
        performSegue(withIdentifier: "moveToEditBlock", sender: self)
    }
    
    
    @IBAction func deleteButton(_ sender: Any) {

        delegate?.deleteBlock()

        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func exitButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
