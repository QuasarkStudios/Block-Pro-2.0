//
//  BlockCategoryPickerCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/4/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol CategorySelected {
    
    func categorySelected (_ category: String)
}

class BlockCategoryPickerCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var categoryPicker: UIPickerView!
    
    let blockCategories: [String] = ["", "Work", "Creativity", "Sleep", "Food/Eat", "Leisure", "Exercise", "Self-Care", "Other"]
    
    var categorySelectedDelegate: CategorySelected?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return blockCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return blockCategories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        categorySelectedDelegate?.categorySelected(blockCategories[row])
    }
    
}
