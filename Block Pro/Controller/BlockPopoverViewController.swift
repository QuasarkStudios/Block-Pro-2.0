//
//  BlockPopoverViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/8/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class BlockPopoverViewController: UIViewController {

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
    
    var bigBlockData = [String : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewAdjustments()
        
        blockName.text = bigBlockData["blockName"]
        blockStartTime.text = bigBlockData["blockStart"]
        blockEndTime.text = bigBlockData["blockEnd"]
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

    @IBAction func editButton(_ sender: Any) {
        
        performSegue(withIdentifier: "moveToEditBlock", sender: self)
    }
    
    
    @IBAction func deleteButton(_ sender: Any) {
    }
    
    
    @IBAction func exitButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
