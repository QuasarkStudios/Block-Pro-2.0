//
//  ReminderConfigurationCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/9/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class ReminderConfigurationCell: UITableViewCell {

    let remindersLabel = UILabel()
    let remindersCountLabel = UILabel()
    let remindersContainer = UIView()
    let remindMeAtLabel = UILabel()
    let remindersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    
    var startTime: Date? {
        didSet {
            
            setRemindMeLabelText()
        }
    }
    
    var selectedReminders: [Int] = []
    
    let minutesToSubtractBy: [Int] = [-5, -10, -15, -30, -45 ,-60, -120]
    
    weak var reminderConfigurationDelegate: ReminderConfigurationProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "reminderConfigurationCell")
        
        configureRemindersLabel()
        configureRemindersCountLabel()
        configureRemindersContainer()
        configureRemindMeAtLabel()
        configureCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Configure Reminders Label
    
    private func configureRemindersLabel () {
        
        self.contentView.addSubview(remindersLabel)
        remindersLabel.configureTitleLabelConstraints()
        
        remindersLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
        remindersLabel.textColor = .black
        remindersLabel.textAlignment = .left
        remindersLabel.text = "Reminders"
    }
    
    
    //MARK: - Configure Reminders Count Label
    
    private func configureRemindersCountLabel () {
        
        self.contentView.addSubview(remindersCountLabel)
        remindersCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            remindersCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            remindersCountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            remindersCountLabel.widthAnchor.constraint(equalToConstant: 75),
            remindersCountLabel.heightAnchor.constraint(equalToConstant: 20)
        
        ].forEach({ $0.isActive = true })
        
        remindersCountLabel.alpha = 0
        remindersCountLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
        remindersCountLabel.textColor = .black
        remindersCountLabel.textAlignment = .right
    }
    
    
    //MARK: - Configure Reminders Container
    
    private func configureRemindersContainer () {
        
        self.contentView.addSubview(remindersContainer)
        remindersContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            remindersContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            remindersContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            remindersContainer.topAnchor.constraint(equalTo: self.remindersLabel.bottomAnchor, constant: 10),
            remindersContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        remindersContainer.backgroundColor = .white
        
        remindersContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        remindersContainer.layer.borderWidth = 1

        remindersContainer.layer.cornerRadius = 10
        remindersContainer.layer.cornerCurve = .continuous
        remindersContainer.clipsToBounds = true
    }
    
    
    //MARK: - Configure Remind Me At Label
    
    private func configureRemindMeAtLabel () {
        
        remindersContainer.addSubview(remindMeAtLabel)
        remindMeAtLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            remindMeAtLabel.leadingAnchor.constraint(equalTo: remindersContainer.leadingAnchor, constant: 15),
            remindMeAtLabel.trailingAnchor.constraint(equalTo: remindersContainer.trailingAnchor, constant: -15),
            remindMeAtLabel.topAnchor.constraint(equalTo: remindersContainer.topAnchor, constant: 10),
            remindMeAtLabel.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        setRemindMeLabelText()
    }
    
    
    //MARK: - Configure Collection View
    
    private func configureCollectionView () {
        
        remindersContainer.addSubview(remindersCollectionView)
        remindersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            remindersCollectionView.leadingAnchor.constraint(equalTo: remindersContainer.leadingAnchor, constant: 0),
            remindersCollectionView.trailingAnchor.constraint(equalTo: remindersContainer.trailingAnchor, constant: 0),
            remindersCollectionView.bottomAnchor.constraint(equalTo: remindersContainer.bottomAnchor, constant: -7.5),
            remindersCollectionView.heightAnchor.constraint(equalToConstant: 55)
            
        ].forEach({ $0.isActive = true })
        
        remindersCollectionView.dataSource = self
        remindersCollectionView.delegate = self
        
        remindersCollectionView.backgroundColor = .white
        remindersCollectionView.showsHorizontalScrollIndicator = false
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 40)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        
        remindersCollectionView.collectionViewLayout = layout
        
        remindersCollectionView.register(ReminderConfigurationCollectionViewCell.self, forCellWithReuseIdentifier: "reminderConfigurationCollectionViewCell")
    }

    
    //MARK: - Set Remind Me Label Text
    
    private func setRemindMeLabelText () {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let semiBoldText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 15) as Any, NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.paragraphStyle : paragraphStyle]
        let regularText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Regular", size: 15) as Any, NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.paragraphStyle : paragraphStyle]
        
        let attributedString = NSMutableAttributedString(string: "")
        
        formatter.dateFormat = "h:mm a"
        
        if selectedReminders.count == 0 {
            
            attributedString.append(NSAttributedString(string: "Remind me:", attributes: semiBoldText))
        }
        
        else if selectedReminders.count == 1 {
            
            attributedString.append(NSAttributedString(string: "Remind me at: ", attributes: semiBoldText))
            
            if let time = startTime, let reminderTime = calendar.date(byAdding: .minute, value: minutesToSubtractBy[selectedReminders[0]], to: time) {
                
                attributedString.append(NSAttributedString(string: formatter.string(from: reminderTime), attributes: regularText))
            }
        }
        
        else if selectedReminders.count == 2 {
            
            attributedString.append(NSAttributedString(string: "Remind me at: ", attributes: semiBoldText))
            
            selectedReminders = selectedReminders.sorted() //Sorting the reminders
            
            if let time = startTime, let firstReminder = calendar.date(byAdding: .minute, value: minutesToSubtractBy[selectedReminders[1]], to: time), let secondReminder = calendar.date(byAdding: .minute, value: minutesToSubtractBy[selectedReminders[0]], to: time) {
                
                attributedString.append(NSAttributedString(string: formatter.string(from: firstReminder) + " and " + formatter.string(from: secondReminder), attributes: regularText))
            }
        }
        
        remindMeAtLabel.attributedText = attributedString
    }
}


//MARK: - Collection View Extension

extension ReminderConfigurationCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reminderConfigurationCollectionViewCell", for: indexPath) as! ReminderConfigurationCollectionViewCell
        
        if selectedReminders.contains(indexPath.row) {
            
            cell.selectContainer(animate: false)
        }
        
        else {
            
            cell.deselectContainer(animate: false)
        }
        
        cell.setContainerLabelText(row: indexPath.row)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! ReminderConfigurationCollectionViewCell
        
        //If the user is deselecting a cell
        if selectedReminders.contains(indexPath.row) {
            
            cell.deselectContainer()
            selectedReminders.removeAll(where: { $0 == indexPath.row })
            
            if selectedReminders.count == 0 {
                
                UIView.animate(withDuration: 0.3) {
                    
                    self.remindersCountLabel.alpha = 0
                }
            }
            
            else {
                
                remindersCountLabel.text = "\(selectedReminders.count)/2"
            }
            
            reminderConfigurationDelegate?.reminderDeleted(indexPath.row)
        }
        
        //If the user is selecting a cell
        else {
            
            //If the maximum amount of reminders hasn't been selected yet
            if selectedReminders.count != 2 {
                
                cell.selectContainer()
                selectedReminders.append(indexPath.row)
                
                remindersCountLabel.text = "\(selectedReminders.count)/2"
                
                UIView.animate(withDuration: 0.3) {
                    
                    self.remindersCountLabel.alpha = 1
                }
                
                reminderConfigurationDelegate?.reminderSelected(selectedReminders)
            }
            
            //If the maximum amount of reminders has been selected
            else {
                
                let vibrateMethods = VibrateMethods()
                vibrateMethods.warningVibration()
            }
        }
        
        setRemindMeLabelText()
    }
}
