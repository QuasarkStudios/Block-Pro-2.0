//
//  BlockNotificationSettingCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/5/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol NotificationSettings {
    
    func switchToggled (_ sendNotif: Bool)
    
    func reminderTimeSelected (_ time: Int)
}

class BlockNotificationSettingCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var cellBackground: UIView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var reminderCollectionView: UICollectionView!
    
    var notificationSettingsDelegate: NotificationSettings?
    
    var cellSelected: [Bool] = Array(repeating: false, count: 7)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellBackground.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.35)
        
        cellBackground.layer.cornerRadius = 6
        cellBackground.clipsToBounds = true
        
        reminderCollectionView.dataSource = self
        reminderCollectionView.delegate = self
        
        reminderCollectionView.backgroundColor = .clear
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.itemSize = CGSize(width: 85, height: 50)
        
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        layout.scrollDirection = .horizontal
        
        reminderCollectionView.collectionViewLayout = layout
        
        reminderCollectionView.register(UINib(nibName: "ReminderCell", bundle: nil), forCellWithReuseIdentifier: "reminderCell")
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reminderCell", for: indexPath) as! ReminderCell
        cell.item = indexPath.item
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? ReminderCell else { return }
        
        if cellSelected[indexPath.row] == true {
            cell.cellSelected = true
            
            notificationSettingsDelegate?.reminderTimeSelected(indexPath.row)
        }
        
        else {
            cell.cellSelected = false
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var count = 0
        
        while count < 7 {
            
            let indexPaths: IndexPath = IndexPath(item: count, section: 0)
            
            if indexPath.row == count {
                
                cellSelected[count] = true
                notificationSettingsDelegate?.reminderTimeSelected(indexPath.row)
                
                if let cell = collectionView.cellForItem(at: indexPaths) as? ReminderCell  {
                    cell.reminderLabel.backgroundColor = UIColor.flatRed()
                }
            }
            
            else {
                
                cellSelected[count] = false
                
                if let cell = collectionView.cellForItem(at: indexPaths) as? ReminderCell  {
                    cell.reminderLabel.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.5)
                }
            }
            
            count += 1
        }
    }
    
    @IBAction func switchToggled(_ sender: Any) {
        
        if notificationSwitch.isOn {
            
            cellSelected[0] = true
            
            reminderCollectionView.reloadData()
        }
        
        else {
            
            cellSelected = Array(repeating: false, count: 7)
            
            reminderCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        }
        
        notificationSettingsDelegate?.switchToggled(notificationSwitch.isOn)
    }
    
}
