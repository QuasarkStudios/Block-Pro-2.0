//
//  EditSessionViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 9/14/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit

class EditPomodoroViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var pomodoroNameTextField: UITextField!
    @IBOutlet weak var nameTextFieldTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var lengthLabelTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var pomodoroStaticLengthLabel: UILabel!
    @IBOutlet weak var pomodoroDynamicLengthLabel: UILabel!
    @IBOutlet weak var pomodoroLengthLabelCenterY: NSLayoutConstraint!
    
    @IBOutlet weak var pomodoroLengthContainer: UIView!
    @IBOutlet weak var lengthContainerTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var lengthContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var decrementPomodoroLength: UIButton!
    @IBOutlet weak var incrementPomodoroLength: UIButton!
    
    @IBOutlet weak var pomodoroStaticCountLabel: UILabel!
    @IBOutlet weak var pomodoroDynamicCountLabel: UILabel!
    @IBOutlet weak var countLabelTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var pomodoroCountContainer: UIView!
    @IBOutlet weak var countContainerTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var countContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var decrementPomodoroCount: UIButton!
    @IBOutlet weak var incrementPomodoroCount: UIButton!
    
    let defaults = UserDefaults.standard
    
    let generator = UINotificationFeedbackGenerator()
    
    var pomodoroMinutes: Int = 25
    var pomodoroCount: Int = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureConstraints()
    }
    
    func configureView () {
        
        let gradientLayer: CAGradientLayer!
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.frame
        gradientLayer.colors = [UIColor.flatMint().lighten(byPercentage: 0.25)!.cgColor as Any, UIColor.white.cgColor as Any]
        
        view.layer.addSublayer(gradientLayer)
        
        view.bringSubviewToFront(pomodoroNameTextField)
        view.bringSubviewToFront(pomodoroStaticLengthLabel)
        view.bringSubviewToFront(pomodoroLengthContainer)
        view.bringSubviewToFront(pomodoroStaticCountLabel)
        view.bringSubviewToFront(pomodoroCountContainer)
        
        pomodoroNameTextField.delegate = self
        
        pomodoroLengthContainer.backgroundColor = UIColor.white
        pomodoroCountContainer.backgroundColor = UIColor.white
        
        //Setting button colors
        decrementPomodoroLength.tintColor = UIColor.flatRed()
        incrementPomodoroLength.tintColor = UIColor.flatRed()
        
        decrementPomodoroCount.tintColor = UIColor.flatRed()
        incrementPomodoroCount.tintColor = UIColor.flatRed()
        
        //Adding a tap gesture recognizer to the view to dismiss the keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func configureConstraints () {
        
        //iPhone 8
        if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 667.0 {
            
            nameTextFieldTopAnchor.constant -= 5
            lengthLabelTopAnchor.constant -= 5
            lengthContainerTopAnchor.constant -= 5
            countLabelTopAnchor.constant -= 5
            countContainerTopAnchor.constant -= 5
        }
        
        //iPhone SE
        else if UIScreen.main.bounds.width == 320.0 {
            
            nameTextFieldTopAnchor.constant -= 5
            lengthLabelTopAnchor.constant -= 5
            
            lengthContainerTopAnchor.constant -= 5
            lengthContainerHeightConstraint.constant = 50
            
            pomodoroDynamicLengthLabel.font = UIFont(name: "ChalkboardSE-Regular", size: 25)
            pomodoroLengthLabelCenterY.constant -= 1.5
            
            countLabelTopAnchor.constant -= 5
            
            countContainerTopAnchor.constant -= 5
            countContainerHeightConstraint.constant = 50
            
            pomodoroDynamicCountLabel.font = UIFont(name: "ChalkboardSE-Regular", size: 27)
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    @IBAction func doneButton(_ sender: Any) {
        
        let pomodoroNameArray = Array(pomodoroNameTextField.text ?? "")
        var pomodoroNameEntered: Bool = false
        
        //For loop that checks to see if "pomodoroNameTextField" isn't empty
        for char in pomodoroNameArray {
            
            if char != " " {
                pomodoroNameEntered = true
                break
            }
        }
        
        //Series of if statements that checks to see if the name, minutes, or count of the Pomodoro needs to be saved/changed
        
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
        
        defaults.set(nil, forKey: "pomodoroActive")
        defaults.set(nil, forKey: "currentPomodoro")
        defaults.set(nil, forKey: "currentPomodoroSession")
        defaults.set(nil, forKey: "currentPomodoroEndTime")
        defaults.set(nil, forKey: "currentPomodoroSoundEffect")
        defaults.set(nil, forKey: "pomodoroNotificationID")
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func decrementPomodoroLength(_ sender: Any) {
        
        if pomodoroMinutes != 15 {
            pomodoroMinutes -= 5
            pomodoroDynamicLengthLabel.text = "\(pomodoroMinutes):00"
        }
        else {
            
            generator.notificationOccurred(.warning)
        }
        
    }
    
    @IBAction func incrementPomodoroLength(_ sender: Any) {
        
        if pomodoroMinutes != 30 {
            pomodoroMinutes += 5
            pomodoroDynamicLengthLabel.text = "\(pomodoroMinutes):00"
        }
        else {
          
            generator.notificationOccurred(.warning)
        }
    }
    
    
    @IBAction func decrementPomodoroCount(_ sender: Any) {
        
        if pomodoroCount != 2 {
            pomodoroCount -= 1
            pomodoroDynamicCountLabel.text = "\(pomodoroCount)"
        }
        else {
            
            generator.notificationOccurred(.warning)
        }
    }
    
    
    @IBAction func incrementPomodoroCount(_ sender: Any) {
        
        if pomodoroCount != 5 {
            pomodoroCount += 1
            pomodoroDynamicCountLabel.text = "\(pomodoroCount)"
        }
        else {
            
            generator.notificationOccurred(.warning)
        }
    }
    
    @objc func dismissKeyboard () {
        view.endEditing(true)
    }
}
