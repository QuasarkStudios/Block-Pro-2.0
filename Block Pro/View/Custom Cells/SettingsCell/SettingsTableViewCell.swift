//
//  SettingsTableViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 10/5/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var settingLabelLeadingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var settingSwitch: UISwitch!
    
    let defaults = UserDefaults.standard
    
    var setting: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func settingSwitch(_ sender: Any) {
        
        if setting == "autoDeleteTasks" {

            defaults.setValue(settingSwitch.isOn, forKey: "autoDeleteTasks")
        }
            
        else if setting == "playPomodoroSoundEffects" {

            defaults.setValue(settingSwitch.isOn, forKey: "playPomodoroSoundEffects")
        }
        
    }
    
}
