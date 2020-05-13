//
//  AddUpdateBlockViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/14/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import RealmSwift

//Protocol inherits from "class"; testing a way to stop a memory leak 
protocol ReloadData: class {
    
    func reloadData ()
    
    func nilSelectedBlock ()
}

class AddEditBlockViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var blockView: BigBlock!
    
    @IBOutlet weak var detailsTableView: UITableView!
    
    
    var timePicker: UIDatePicker = UIDatePicker()
    var timePickerBackground: UIView = UIView()
    
    //lazy var realm = try! Realm()
    var personalDatabase = PersonalRealmDatabase.sharedInstance
    var currentDateObject: TimeBlocksDate?
    
    let notificationScheduler = NotificationScheduler()
    
    let formatter = DateFormatter()
    
    var currentDate: Date?
    
    var selectedBlock: PersonalRealmDatabase.blockTuple?
    
    weak var reloadDataDelegate: ReloadData?
    
    var blockName: String? {
        didSet {
            
            if validateTextEntered(blockName!) == true {
                
                blockView.nameLabel.text = blockName
            }
            
            else {
                
                blockView.nameLabel.text = "Block"
            }
        }
    }
    
    var blockBegins: Date? {
        didSet {

            formatter.dateFormat = "yyyy-MM-dd"
            let blockDate: String = formatter.string(from: currentDate!)

            formatter.dateFormat = "HH:mm"
            let blockTime: String = formatter.string(from: blockBegins!)

            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            blockBegins = formatter.date(from: blockDate + " " + blockTime)
            
            formatter.dateFormat = "h:mm a"
            
            if blockEnds != nil {
                
                if blockBegins! < blockEnds! {
                    
                    blockView.timeLabel.text = formatter.string(from: blockBegins!)
                    blockView.timeLabel.text! += "  -  "
                    blockView.timeLabel.text! += formatter.string(from: blockEnds!)
                }
                
                else {
                    
                     blockEnds = blockBegins!.addingTimeInterval(300)
                     
                     blockView.timeLabel.text = formatter.string(from: blockBegins!)
                     blockView.timeLabel.text! += "  -  "
                     blockView.timeLabel.text! += formatter.string(from: blockEnds!)
                    
                    guard let cell = detailsTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? BlockOtherSettingCell else { return }
                        
                        cell.settingSelectionLabel.text = formatter.string(from: blockEnds!)
                }
            }
            
            else if blockEnds == nil {
                
                blockEnds = blockBegins!.addingTimeInterval(300)
                
                blockView.timeLabel.text = formatter.string(from: blockBegins!)
                blockView.timeLabel.text! += "  -  "
                blockView.timeLabel.text! += formatter.string(from: blockEnds!)
                
                guard let cell = detailsTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? BlockOtherSettingCell else { return }
                    
                    cell.settingSelectionLabel.text = formatter.string(from: blockEnds!)
            }
            
            guard let cell = detailsTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? BlockTimePickerCell else { return }
            
             //formatter.dateFormat = "HH:mm"
            
//            cell.timePicker.setDate(formatter.date(from: formatter.string(from: blockBegins!))!, animated: false)
            
                cell.timePicker.date = blockBegins!
        }
    }
    
    var blockEnds: Date? {
        didSet {
            
            formatter.dateFormat = "yyyy-MM-dd"
            let blockDate: String = formatter.string(from: currentDate!)

            formatter.dateFormat = "HH:mm"
            let blockTime: String = formatter.string(from: blockEnds!)

            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            blockEnds = formatter.date(from: blockDate + " " + blockTime)
            
            formatter.dateFormat = "h:mm a"
            
            if blockBegins != nil {
                
                if blockBegins! < blockEnds! {
                    
                    blockView.timeLabel.text = formatter.string(from: blockBegins!)
                    blockView.timeLabel.text! += "  -  "
                    blockView.timeLabel.text! += formatter.string(from: blockEnds!)
                }
                
                else {
                    
                    blockBegins = blockEnds!.addingTimeInterval(-300)
                    
                    blockView.timeLabel.text = formatter.string(from: blockBegins!)
                    blockView.timeLabel.text! += "  -  "
                    blockView.timeLabel.text! += formatter.string(from: blockEnds!)
                    
                    guard let cell = detailsTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? BlockOtherSettingCell else { return }
                        
                        cell.settingSelectionLabel.text = formatter.string(from: blockBegins!)
                }
            }
            
            else {
                
                blockBegins = blockEnds!.addingTimeInterval(-300)
                
                blockView.timeLabel.text = formatter.string(from: blockBegins!)
                blockView.timeLabel.text! += "  -  "
                blockView.timeLabel.text! += formatter.string(from: blockEnds!)
                
                guard let cell = detailsTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? BlockOtherSettingCell else { return }
                    
                    cell.settingSelectionLabel.text = formatter.string(from: blockBegins!)
            }
            
            guard let cell = detailsTableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? BlockTimePickerCell else { return }
                
                cell.timePicker.date = blockEnds!
//                cell.timePicker.setDate(blockEnds!, animated: false)
        }
    }
    
    var blockCategory: String? {
        didSet {
            
            blockView.backgroundColor = UIColor(hexString: categoryColors[blockCategory!] ?? "#AAAAAA", withAlpha: 0.85)
        }
    }
    
    let categoryColors: [String : String] = ["Work": "#5065A0", "Creativity" : "#FFCC02", "Sleep" : "#745EC4", "Food/Eat" : "#B8C9F2", "Leisure" : "#EFDDB3", "Exercise": "#E84D3C", "Self-Care" : "#1ABC9C", "Other" : "#AAAAAA"]
    
    var notificationSettings: [String : Any] = ["notificationID" : UUID().uuidString, "scheduled" : false, "minsBefore" : 0.0]

    var tag: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavBar()
        
        detailsTableView.dataSource = self
        detailsTableView.delegate = self
        
        detailsTableView.rowHeight = 80
        detailsTableView.separatorStyle = .none
        
        detailsTableView.register(UINib(nibName: "BlockNameSettingCell", bundle: nil), forCellReuseIdentifier: "blockNameSettingCell")
        
        detailsTableView.register(UINib(nibName: "BlockOtherSettingCell", bundle: nil), forCellReuseIdentifier: "blockOtherSettingCell")
        
        detailsTableView.register(UINib(nibName: "BlockTimePickerCell", bundle: nil), forCellReuseIdentifier: "blockTimePickerCell")
        
        detailsTableView.register(UINib(nibName: "BlockCategoryPickerCell", bundle: nil), forCellReuseIdentifier: "blockCategoryPickerCell")
        
        detailsTableView.register(UINib(nibName: "BlockNotificationSettingCell", bundle: nil), forCellReuseIdentifier: "blockNotificationCell")
        
        detailsTableView.register(UINib(nibName: "DeleteBlockCell", bundle: nil), forCellReuseIdentifier: "deleteBlockCell")

        //configureGestureRecognizors()
    
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//
//                self.modalPresentationStyle = .fullScreen
//                //self.present(self, animated: true, completion: nil)
//            }
        }
        
        guard let block = selectedBlock else { return }
        
            configureEditView(block)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        configureGestureRecognizors()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if selectedBlock == nil {
            
            return 8
        }
        
        else {
            
            return 9
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            
        case 0:
            
            return configureNameSettingCell(tableView, indexPath)
        
        case 1, 3, 5:
         
            return configureOtherSettingsCell(tableView, indexPath)
            
        case 2, 4, 6:
            
            return configurePickerCell(tableView, indexPath)
         
        case 7:
            
            return configureNotificationCell(tableView, indexPath)
        
        default:
            
            return configureDeleteCell(tableView, indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        
        case 0, 1, 3, 5:
         
            return 80
            
        case 2, 4, 6:
            
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
        
        case 7:
            
            if notificationSettings["scheduled"] as? Bool ?? false == true {
                
                return 150
            }
            
            else {
                
                return 80
            }
            
        default:
            
            return 80
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
        
        else if indexPath.row == 8 {

            blockDeleted(tableView, indexPath)
        }
        
        configureCellTextColor()
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    private func configureGestureRecognizors () {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let presentTabBar = UISwipeGestureRecognizer(target: self, action: #selector(presentDisabledTabBar))
        presentTabBar.delegate = self
        presentTabBar.cancelsTouchesInView = false
        presentTabBar.direction = .left
        view.addGestureRecognizer(presentTabBar)
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
    
    private func configurePickerCell (_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "blockTimePickerCell", for: indexPath) as! BlockTimePickerCell
            cell.currentDate = currentDate
            cell.timeSelectedDelegate = self
            cell.selectedTime = "begins"
            
            if let block = selectedBlock {

                //formatter.dateFormat = "HH:mm"
                
                //cell.timePicker.setDate(formatter.date(from: formatter.string(from: block.begins))!, animated: false)
                
                cell.timePicker.date = block.begins
            }
            
            else {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    
                    guard let beginsCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? BlockOtherSettingCell else { return }

                        self.formatter.dateFormat = "mm"
                        let fullMinute: Array = Array(self.formatter.string(from: cell.timePicker.date))
                        let incrementalMinute: String = "\(fullMinute[1])"

                        let minutesToSubtract: Double = Double((Int(incrementalMinute)! % 5) * -60)

                        self.formatter.dateFormat = "h:mm a"
                        beginsCell.settingSelectionLabel.text = self.formatter.string(from: cell.timePicker.date.addingTimeInterval(minutesToSubtract))

                        self.blockBegins = cell.timePicker.date.addingTimeInterval(minutesToSubtract)
                }
            }
            
            return cell
        }
        
        else if indexPath.row == 4 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "blockTimePickerCell", for: indexPath) as! BlockTimePickerCell
            cell.currentDate = currentDate
            cell.timeSelectedDelegate = self
            cell.selectedTime = "ends"
            
            if let block = selectedBlock {
                
//                formatter.dateFormat = "HH:mm"
//
//                cell.timePicker.setDate(formatter.date(from: formatter.string(from: block.ends))!, animated: false)

                cell.timePicker.date = block.ends
            }
            
            else {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    
                    guard let endsCell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? BlockOtherSettingCell else { return }

                        self.formatter.dateFormat = "h:mm a"
                        endsCell.settingSelectionLabel.text = self.formatter.string(from: self.blockBegins?.addingTimeInterval(300) ?? Date())

                        self.blockEnds = self.blockBegins?.addingTimeInterval(300) ?? Date()
                        cell.timePicker.date = self.blockBegins?.addingTimeInterval(300) ?? Date()
                }
                
            }

            return cell
        }
        
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "blockCategoryPickerCell", for: indexPath) as! BlockCategoryPickerCell
            cell.categorySelectedDelegate = self
            
            return cell
        }
    }
    
    private func configureNotificationCell (_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockNotificationCell", for: indexPath) as! BlockNotificationSettingCell
        cell.selectionStyle = .none
        cell.notificationSettingsDelegate = self
        
        if notificationSettings["scheduled"] as? Bool ?? false == true {
            
            let timeArray: [Double] = [5, 10, 15, 30, 45, 60, 120]
            let selectedReminderCell = timeArray.firstIndex(of: (notificationSettings["minsBefore"] as! Double) / -60)!
            
            cell.notificationSwitch.isOn = true
            cell.cellSelected[selectedReminderCell] = true
        }
        
        return cell
        
    }
    
    private func configureDeleteCell (_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "deleteBlockCell", for: indexPath) as! DeleteBlockCell
        cell.selectionStyle = .none
        
        return cell
    }
    
    private func configureCellTextColor () {
        
        var indexPath: IndexPath?
        
        indexPath = IndexPath(row: 1, section: 0)
        let beginCell = detailsTableView.cellForRow(at: indexPath!) as? BlockOtherSettingCell
        
        indexPath = IndexPath(row: 3, section: 0)
        let endCell = detailsTableView.cellForRow(at: indexPath!) as? BlockOtherSettingCell
        
        indexPath = IndexPath(row: 5, section: 0)
        let categoryCell = detailsTableView.cellForRow(at: indexPath!) as? BlockOtherSettingCell
        
        if tag == "begins" {
            
            beginCell?.settingSelectionLabel.textColor = UIColor.flatRed()
            endCell?.settingSelectionLabel.textColor = .black
            categoryCell?.settingSelectionLabel.textColor = .black
        }
        
        else if tag == "ends" {
            
            beginCell?.settingSelectionLabel.textColor = .black
            endCell?.settingSelectionLabel.textColor = UIColor.flatRed()
            categoryCell?.settingSelectionLabel.textColor = .black
        }
        
        else if tag == "category" {
            
            beginCell?.settingSelectionLabel.textColor = .black
            endCell?.settingSelectionLabel.textColor = .black
            categoryCell?.settingSelectionLabel.textColor = UIColor.flatRed()
        }
        
        else if tag == "notification" || tag == nil {
            
            beginCell?.settingSelectionLabel.textColor = .black
            endCell?.settingSelectionLabel.textColor = .black
            categoryCell?.settingSelectionLabel.textColor = .black
        }
    }
    
    private func configureNavBar () {
        
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 55))
        
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.backgroundColor = .clear  //.view.backgroundColor = .clear
        
        navBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 18)!]
        
        view.addSubview(navBar)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addEditBlock))
        addButton.style = .done
        
        let editButton = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(addEditBlock))
        editButton.style = .done
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action:#selector(cancelPressed))
        cancelButton.style = .done
            

        
        if selectedBlock == nil {
            
            let navItem = UINavigationItem(title: "Add A Block")
            navItem.leftBarButtonItem = cancelButton
            navItem.rightBarButtonItem = addButton
            
            navBar.setItems([navItem], animated: false)
        }
        
        else {
            
            let navItem = UINavigationItem(title: "Edit Block")
            navItem.leftBarButtonItem = cancelButton
            navItem.rightBarButtonItem = editButton
            
            navBar.setItems([navItem], animated: false)
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
        
        notificationSettings["notificationID"] = block.notificationID
        notificationSettings["scheduled"] = block.scheduled
        notificationSettings["minsBefore"] = block.minsBefore
    }
    
    @objc private func presentDisabledTabBar () {
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
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
    
    private func blockDeleted (_ tableView: UITableView, _ indexPath: IndexPath) {
        
        personalDatabase.deleteBlock(blockID: selectedBlock!.blockID)
        
        notificationScheduler.removePendingNotification()
        
        let cell = tableView.cellForRow(at: indexPath) as! DeleteBlockCell
        
        cell.cellBackground.transform = CGAffineTransform(scaleX: 0.9, y: 1.1)
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
            
            cell.cellBackground.transform = .identity
            
        }) { (finished: Bool) in
            
            self.dismiss(animated: true) {
                
                self.reloadDataDelegate?.reloadData()
            }
        }
    }
    
    @objc private func addEditBlock () {
        
        var blockDict: [String : Any] = [:]
        
        if validateTextEntered(blockName ?? "") != true {
            
            ProgressHUD.showError("Please enter a name for this Block")
            return
        }
        
        if personalDatabase.verifyBlock(selectedBlock?.blockID, blockBegins!, blockEnds!) == false {
            
            ProgressHUD.showError("Sorry, this Block conflicts with too many others in your schedule")
            return
        }
        
        blockDict["name"] = blockName ?? "Block"
        
        blockDict["begins"] = blockBegins!
        blockDict["ends"] = blockEnds!
        blockDict["category"] = blockCategory ?? "Other"
        
        blockDict["notificationID"] = notificationSettings["notificationID"]
        blockDict["scheduled"] = notificationSettings["scheduled"]
        blockDict["minsBefore"] = notificationSettings["minsBefore"] as! Double
        
        if selectedBlock == nil {
            
            personalDatabase.addBlock(blockDict, currentDateObject!)
        }
        
        else {
            
            blockDict["blockID"] = selectedBlock?.blockID
            
            personalDatabase.updateBlock(blockDict, currentDateObject!)
        }
        
        if notificationSettings["scheduled"] as? Bool ?? false == true {
            
            notificationScheduler.scheduleBlockNotificiation(blockDict)
        }
        
        else {
            
            notificationScheduler.removePendingNotification()
        }
        
        dismiss(animated: true) {
            self.reloadDataDelegate?.reloadData()
        }
    }
    
    @objc private func cancelPressed () {
        
        dismiss(animated: true) {
            self.reloadDataDelegate?.nilSelectedBlock()
        }
    }

    
    @objc func dismissKeyboard () {
        
        let indexPath: IndexPath = IndexPath(row: 0, section: 0)
        
        guard let cell = detailsTableView.cellForRow(at: indexPath) as? BlockNameSettingCell else { return }
            cell.nameTextField.endEditing(true)
        
    }
}

extension AddEditBlockViewController: TextEdits {
    
    func textBeganEditing() {
        
        tag = nil
        
        configureCellTextColor()
        
        detailsTableView.beginUpdates()
        detailsTableView.endUpdates()
    }
    
    func textEdited(_ text: String) {
        
        blockName = text
    }
}

extension AddEditBlockViewController: TimeSelected {
    
    func startTimeSelected (_ selectedTime: Date) {
        
        formatter.dateFormat = "h:mm a"
        
        let indexPath: IndexPath = IndexPath(row: 1, section: 0)
        
        let cell = detailsTableView.cellForRow(at: indexPath) as! BlockOtherSettingCell
        cell.settingSelectionLabel.text = formatter.string(from: selectedTime)

        blockBegins = selectedTime
    }
    
    func endTimeSelected (_ selectedTime: Date) {
        
        formatter.dateFormat = "h:mm a"
        
        let indexPath: IndexPath = IndexPath(row: 3, section: 0)
        
        let cell = detailsTableView.cellForRow(at: indexPath) as! BlockOtherSettingCell
        cell.settingSelectionLabel.text = formatter.string(from: selectedTime)

        blockEnds = selectedTime
    }
}

extension AddEditBlockViewController: CategorySelected {
    
    func categorySelected (_ category: String) {
        
        let indexPath: IndexPath = IndexPath(row: 5, section: 0)
        
        let cell = detailsTableView.cellForRow(at: indexPath) as! BlockOtherSettingCell
        cell.settingSelectionLabel.text = category
        
        blockCategory = category
    }
}

extension AddEditBlockViewController: NotificationSettings {
    
    func switchToggled(_ sendNotif: Bool) {
        
        if sendNotif == true {
            
            tag = "notification"
            
            notificationSettings["scheduled"] = true
        }
        
        else {
            
            tag = nil
            
            notificationSettings["scheduled"] = false
        }
        
        configureCellTextColor()
        
        detailsTableView.beginUpdates()
        detailsTableView.endUpdates()
        
    }
    
    func reminderTimeSelected(_ time: Int) {
        
        let timeArray: [Double] = [5, 10, 15, 30, 45, 60, 120]
        
        notificationSettings["minsBefore"] = timeArray[time] * -60
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

extension AddEditBlockViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
