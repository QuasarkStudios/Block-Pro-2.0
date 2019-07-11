//
//  NewCollabViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/9/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class NewCollabViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var collabWithTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var collabButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    @IBOutlet weak var datePickerContainer: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let formatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        
        friendsTableView.backgroundColor = UIColor(hexString: "2E2E2E")
        
        datePickerContainer.layer.cornerRadius = 0.1 * datePickerContainer.bounds.size.width
        datePickerContainer.clipsToBounds = true
        
        datePicker.setValue(UIColor.white, forKey: "textColor")
        datePicker?.addTarget(self, action: #selector(dateSelected(datePicker:)), for: .valueChanged)
        
        //datePickerContainer.frame.origin.y = 400
        
        formatter.dateFormat = "MM/dd/yyyy"
        dateTextField.text = formatter.string(from: datePicker.date)
        
        exitButton.layer.cornerRadius = 0.5 * exitButton.bounds.size.width
        exitButton.clipsToBounds = true
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Friends"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendName", for: indexPath)
        
        cell.backgroundColor = UIColor(hexString: "2E2E2E")
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel!.text = "Jeff Davis"
        return cell
    }
    
    
    @objc func dateSelected (datePicker: UIDatePicker) {
        
        formatter.dateFormat = "MM/dd/yyyy"
        
        print(formatter.string(from: datePicker.date))
        
    }
    

    @IBAction func collabButton(_ sender: Any) {
        
    }
    @IBAction func exitButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
