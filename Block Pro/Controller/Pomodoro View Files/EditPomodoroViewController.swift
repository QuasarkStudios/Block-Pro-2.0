//
//  EditSessionViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 9/14/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class EditPomodoroViewController: UIViewController {

    @IBOutlet weak var pomodoroNameTextField: UITextField!
    
    @IBOutlet weak var pomodoroLengthContainer: UIView!
    @IBOutlet weak var pomodoroLengthLabel: UILabel!
    @IBOutlet weak var decrementPomodoroLength: UIButton!
    @IBOutlet weak var incrementPomodoroLength: UIButton!
    
    @IBOutlet weak var pomodoroCountContainer: UIView!
    @IBOutlet weak var pomodoroCountLabel: UILabel!
    @IBOutlet weak var decrementPomodoroCount: UIButton!
    @IBOutlet weak var incrementPomodoroCount: UIButton!
    
    let defaults = UserDefaults.standard
    
    let generator = UINotificationFeedbackGenerator()
    
    var pomodoroMinutes: Int = 25
    var pomodoroCount: Int = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.flatMint().lighten(byPercentage: 0.25)
        
        pomodoroLengthLabel.center = pomodoroLengthContainer.center
        decrementPomodoroLength.frame.origin = CGPoint(x: 15, y: pomodoroLengthContainer.center.y - 10)
        incrementPomodoroLength.frame.origin = CGPoint(x: 307, y: pomodoroLengthContainer.center.y - 10)
        
        pomodoroCountLabel.center = pomodoroCountContainer.center
        decrementPomodoroCount.frame.origin = CGPoint(x: 15, y: pomodoroCountContainer.center.y - 10)
        incrementPomodoroCount.frame.origin = CGPoint(x: 307, y: pomodoroCountContainer.center.y - 10)
        
        
    }
    
    @IBAction func doneButton(_ sender: Any) {
        
        let pomodoroNameArray = Array(pomodoroNameTextField.text ?? "")
        var pomodoroNameEntered: Bool = false
        
        for char in pomodoroNameArray {
            
            if char != " " {
                pomodoroNameEntered = true
                break
            }
        }
        
        if pomodoroNameEntered == true {
            defaults.set(pomodoroNameTextField.text, forKey: "pomodoroName")
        }
        else {
            defaults.set(nil, forKey: "pomodoroName")
        }
        
        if pomodoroMinutes != 25 {
            defaults.set(pomodoroMinutes, forKey: "pomodoroMinutes")
        }
        else {
            defaults.set(nil, forKey: "pomodoroMinutes")
        }
        
        if pomodoroCount != 4 {
            defaults.set(pomodoroCount, forKey: "totalPomodoroCount")
        }
        else {
            defaults.set(nil, forKey: "totalPomodoroCount")
        }
        
        defaults.set(nil, forKey: "currentPomodoro")
        
        navigationController?.popViewController(animated: true)
        
//        if pomodoroNameEntered == true || pomodoroMinutes != 25 || pomodoroCount != 4 {
//
//            defaults.set(true, forKey: "pomodoroCustomized")
//
//            if pomodoroNameEntered == true {
//                defaults.set(pomodoroNameTextField.text, forKey: "pomodoroName")
//            }
//            else {
//                defaults.set("Pomodoro", forKey: "pomodoroName")
//            }
//
//            defaults.set(pomodoroMinutes, forKey: "pomodoroMinutes")
//            defaults.set(pomodoroCount, forKey: "pomodoroCount")
//            defaults.set(nil, forKey: "currentPomodoro")
//
//            navigationController?.popViewController(animated: true)
//        }
//
//        else {
//
//            defaults.set(false, forKey: "pomodoroCustomized")
//
//            navigationController?.popViewController(animated: true)
//        }
        
    }
    
    @IBAction func decrementPomodoroLength(_ sender: Any) {
        
        if pomodoroMinutes != 15 {
            pomodoroMinutes -= 5
            pomodoroLengthLabel.text = "\(pomodoroMinutes):00"
        }
        else {
            
            generator.notificationOccurred(.warning)
        }
        
    }
    
    @IBAction func incrementPomodoroLength(_ sender: Any) {
        
        if pomodoroMinutes != 30 {
            pomodoroMinutes += 5
            pomodoroLengthLabel.text = "\(pomodoroMinutes):00"
        }
        else {
          
            generator.notificationOccurred(.warning)
        }
    }
    
    
    @IBAction func decrementPomodoroCount(_ sender: Any) {
        
        if pomodoroCount != 2 {
            pomodoroCount -= 1
            pomodoroCountLabel.text = "\(pomodoroCount)"
        }
        else {
            
            generator.notificationOccurred(.warning)
        }
    }
    
    
    @IBAction func incrementPomodoroCount(_ sender: Any) {
        
        if pomodoroCount != 5 {
            pomodoroCount += 1
            pomodoroCountLabel.text = "\(pomodoroCount)"
        }
        else {
            
            generator.notificationOccurred(.warning)
        }
    }
    

}
