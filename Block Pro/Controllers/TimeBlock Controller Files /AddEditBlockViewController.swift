//
//  AddUpdateBlockViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/14/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import RealmSwift

protocol ReloadData {
    
    func reloadData ()
    
    func nilSelectedBlock ()
}

class AddEditBlockViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var addEditButton: UIBarButtonItem!
    
    
    @IBOutlet weak var blockView: BigBlock!
    
    @IBOutlet weak var detailsTableView: UITableView!
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var beginsTextField: UITextField!
    @IBOutlet weak var endsTextField: UITextField!
    
    var timePicker: UIDatePicker = UIDatePicker()
    var timePickerBackground: UIView = UIView()
    
    //lazy var realm = try! Realm()
    var personalDatabase: PersonalRealmDatabase?
    var currentDateObject: TimeBlocksDate?
    
    let formatter = DateFormatter()
    
    var currentDate: Date?
    
    var selectedBlock: PersonalRealmDatabase.blockTuple?
    
    var reloadDataDelegate: ReloadData?
    
    var blockName: String? {
        didSet {
            
            if validateTextEntered(blockName!) == true {
                
                blockView.nameLabel.text = blockName
            }
            
            else {
                
                blockView.nameLabel.text = "Block Name"
            }
            
            
        }
    }
    
    var blockCategory: String? {
        didSet {
            //categoryTextField.text = blockCategory
        }
    }
    
    var blockBegins: Date? {
        didSet {
            
            formatter.dateFormat = "h:mm a"
            //beginsTextField.text = formatter.string(from: blockBegins!)
        }
    } //HH:mm - 24 hour format; h:mm a - 12 hour format
    
    var blockEnds: Date? {
        didSet {
            
            formatter.dateFormat = "h:mm a"
            //endsTextField.text = formatter.string(from: blockEnds!)
        }
    }
    
    var tag: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        //self.navigationController?.navigationBar.isTranslucent = true
        navigationBar.backgroundColor = .clear  //.view.backgroundColor = .clear
        
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 18)!]

        detailsTableView.dataSource = self
        detailsTableView.delegate = self
        
        detailsTableView.rowHeight = 80
        detailsTableView.separatorStyle = .none
        
        detailsTableView.register(UINib(nibName: "BlockNameSettingCell", bundle: nil), forCellReuseIdentifier: "blockNameSettingCell")
        
        detailsTableView.register(UINib(nibName: "BlockOtherSettingCell", bundle: nil), forCellReuseIdentifier: "blockOtherSettingCell")
        
        detailsTableView.register(UINib(nibName: "BlockTimePickerCell", bundle: nil), forCellReuseIdentifier: "blockTimePickerCell")
        
        detailsTableView.register(UINib(nibName: "BlockCategoryPickerCell", bundle: nil), forCellReuseIdentifier: "blockCategoryPickerCell")
        
        //timeSelected(timePicker: timePicker)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        guard let block = selectedBlock else { return }

            configureEditView(block)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 7
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            
        case 0:
            
            return configureNameSettingCell(tableView, indexPath)
        
        case 1, 3, 5:
         
            return configureOtherSettingsCell(tableView, indexPath)
            
        default:
            
            return configurePickerCell(tableView, indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        
        case 0, 1, 3, 5:
         
            return 80
            
        default:
            
            if tag == "begins" {
                
                if indexPath.row == 2 {
                    
                    return 160
                }
                
                else {
                    
                    return 0
                }
            }
            
            else if tag == "ends" {
                
                if indexPath.row == 4 {
                    
                    return 160
                }
                
                else {
                    
                    return 0
                }
            }
            
            else if tag == "category" {
                
                if indexPath.row == 6 {
                    
                    return 160
                }
                
                else {
                    
                    return 0
                }
            }
            
            else {
                
                return 0
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            tag = nil
            
        }
        
        else if indexPath.row == 1 {
            
            if tag != "begins" {
                
                tag = "begins"
            }
            
            else {
                
                tag = nil
            }
        }

        else if indexPath.row == 3 {
            
            if tag != "ends" {
                
                tag = "ends"
            }
            
            else {
                
                tag = nil
            }
        }

        else if indexPath.row == 5 {
            
            if tag != "category" {
                
                tag = "category"
            }
            
            else {
                
                tag = nil
            }
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
    }
    
    private func configureNameSettingCell (_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockNameSettingCell", for: indexPath) as! BlockNameSettingCell
        cell.selectionStyle = .none
        
        cell.textEditsDelegate = self
        
        if let block = selectedBlock {

            cell.nameTextField.text = block.name

        }
        
        return cell
        
    }
    
    private func configureOtherSettingsCell (_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockOtherSettingCell", for: indexPath) as! BlockOtherSettingCell
        cell.selectionStyle = .none
        
        if indexPath.row == 1 {
            
            cell.settingLabel.text = "Begins:"
            
            if let block = selectedBlock {
                
                formatter.dateFormat = "h:mm a"
                cell.settingSelectionLabel.text = formatter.string(from: block.begins)
            }
                
            else {
                
                cell.settingSelectionLabel.text = "12:00 PM"
            }
        }
        
        else if indexPath.row == 3 {
            
            cell.settingLabel.text = "Ends:"
            
            if let block = selectedBlock {
                
                formatter.dateFormat = "h:mm a"
                cell.settingSelectionLabel.text = formatter.string(from: block.ends)
            }
            
            else {
                
                cell.settingSelectionLabel.text = "12:05 PM"
            }
        }
        
        else {
            
            cell.settingLabel.text = "Category:"
            
            if let block = selectedBlock {
               
                cell.settingSelectionLabel.text = block.category
            }
            
            else {
                
                cell.settingSelectionLabel.text = "None"
            }
        }
        
        return cell
    }
    
    private func configurePickerCell (_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell{
        
        if indexPath.row == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "blockTimePickerCell", for: indexPath) as! BlockTimePickerCell
            cell.currentDate = currentDate
            cell.timeSelectedDelegate = self
            
            return cell
        }
        
        else if indexPath.row == 4 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "blockTimePickerCell", for: indexPath) as! BlockTimePickerCell
            cell.currentDate = currentDate
            cell.timeSelectedDelegate = self
            
            return cell
        }
        
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "blockCategoryPickerCell", for: indexPath) as! BlockCategoryPickerCell
            
            return cell
        }
        
        
        
    }
    
    private func configureEditView (_ block: PersonalRealmDatabase.blockTuple) {
        
        blockView.nameLabel.text = block.name

        formatter.dateFormat = "h:mm a"

        blockView.timeLabel.text = formatter.string(from: block.begins)
        blockView.timeLabel.text! += "  -  "
        blockView.timeLabel.text! += formatter.string(from: block.ends)

        blockView.category = block.category

        blockName = block.name
        blockCategory = block.category
        blockBegins = block.begins
        blockEnds = block.ends
        
//        nameTextField.text = block.name
//        categoryTextField.text = block.category
//        beginsTextField.text = formatter.string(from: block.begins)
//        endsTextField.text = formatter.string(from: block.ends)
        
    
        
    }
    
    
  
    
    func validateTextEntered (_ text: String) -> Bool {
        
        let textArray = Array(text)
        var textEntered: Bool = false
        
        //For loop that checks to see if "blockNameTextField" isn't empty
        for char in textArray {
            
            if char != " " {
                textEntered = true
                break
            }
        }
        
        return textEntered
    }
    
    @objc func dismissKeyboard () {
        
        let indexPath: IndexPath = IndexPath(row: 0, section: 0)
        
        let cell = detailsTableView.cellForRow(at: indexPath) as! BlockNameSettingCell
        cell.nameTextField.endEditing(true)
        
    }
    
    
    @IBAction func addEditButton(_ sender: Any) {
        
        var blockDict: [String : Any] = [:]
        
        blockDict["name"] = nameTextField.text!
        blockDict["begins"] = blockBegins!
        blockDict["ends"] = blockEnds!
        blockDict["category"] = categoryTextField.text!

        blockDict["notificationID"] = ""
        blockDict["scheduled"] = false
        blockDict["minsBefore"] = 0
        
        if selectedBlock == nil {
            
            personalDatabase?.addBlock(blockDict, currentDateObject!)
        }
        
        else {
            
            blockDict["blockID"] = selectedBlock?.blockID
            
            personalDatabase?.updateBlock(blockDict, currentDateObject!)
        }
        
        dismiss(animated: true) {
            self.reloadDataDelegate?.reloadData()
        }
        
        //dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        
        dismiss(animated: true) {
            self.reloadDataDelegate?.nilSelectedBlock()
        }
    }
}

extension AddEditBlockViewController: TextEdits {
    
    func textBeganEditing() {
        
        tag = nil
        
        detailsTableView.beginUpdates()
        detailsTableView.endUpdates()
    }
    
    func textEdited(_ text: String) {
        
        blockName = text
    }
}

extension AddEditBlockViewController: TimeSelected {
    
    func startTimeSelected(_ selectedTime: Date) {
        
        formatter.dateFormat = "h:mm a"
        
        let indexPath: IndexPath = IndexPath(row: 1, section: 0)
        
        let cell = detailsTableView.cellForRow(at: indexPath) as! BlockOtherSettingCell
        cell.settingSelectionLabel.text = formatter.string(from: selectedTime)
        
    }
    
    func endTimeSelected(_ selectedTime: Date) {
        
        formatter.dateFormat = "h:mm a"
        
        let indexPath: IndexPath = IndexPath(row: 3, section: 0)
        
        let cell = detailsTableView.cellForRow(at: indexPath) as! BlockOtherSettingCell
        cell.settingSelectionLabel.text = formatter.string(from: selectedTime)
    }
    
    
    
}

extension UILabel {
    
    func addCharacterSpacing(kernValue: Double = 1.15) {

        if let labelText = text, labelText.count > 0 {

            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}
