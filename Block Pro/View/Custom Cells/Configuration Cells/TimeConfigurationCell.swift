//
//  TimeConfigurationCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 12/29/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import JTAppleCalendar

class TimeConfigurationCell: UITableViewCell {

    let titleLabel = UILabel()
    let timeContainer = UIView()
    let dateLabel = UILabel()
    let timeDivider = UIView()
    let timeLabel = UILabel()
    
    let calendarHeaderLabel = UILabel()
    let previousMonthButton = UIButton(type: .system)
    let nextMonthButton = UIButton(type: .system)
    let dayStackView = UIStackView()
    let calendarView = JTAppleCalendarView()
    
    let timeSelectorContainer = UIView()
    let setATimeLabel = UILabel()
    let hourTextField = UITextField()
    let semiColonLabel = UILabel()
    let minuteTextField = UITextField()
    let periodButton = UIButton(type: .custom)
    
    let doneButton = UIButton(type: .system)
    
    var collab: Collab?
    
    var starts: Date? {
        didSet {
            
            setDateLabelText()
            setTimeLabelText()
        }
    }
    
    var ends: Date? {
        didSet {
            
            setDateLabelText()
            setTimeLabelText()
        }
    }
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    
    var keyboardPresent: Bool = false
    var originalContentOffsetOfTableView: CGFloat = 0
    
    weak var timeConfigurationDelegate: TimeConfigurationProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "timeConfigurationCell")
        
        configureTitleLabel()
        configureTimeContainer()
        configureDateLabel()
        configureTimeDivider()
        configureTimeLabel()
        
        configureNotificationObservors()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configure Title Label
    
    private func configureTitleLabel () {
        
        self.contentView.addSubview(titleLabel)
        titleLabel.configureConfigurationTitleLabelConstraints()
        
        titleLabel.textColor = .black
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont(name: "Poppins-SemiBold", size: 15)
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: - Configure Time Container
    
    private func configureTimeContainer () {
        
        self.contentView.addSubview(timeContainer)
        timeContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            timeContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
            timeContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            timeContainer.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40),
            timeContainer.heightAnchor.constraint(equalToConstant: 105)
        
        ].forEach({ $0.isActive = true })
        
        timeContainer.backgroundColor = .white
        
        timeContainer.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        timeContainer.layer.borderWidth = 1

        timeContainer.layer.cornerRadius = 10
        timeContainer.layer.cornerCurve = .continuous
        timeContainer.clipsToBounds = true
        
        timeContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerTapped)))
    }
    
    
    //MARK: - Configure Date Label
    
    private func configureDateLabel () {
        
        self.timeContainer.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            dateLabel.topAnchor.constraint(equalTo: timeContainer.topAnchor, constant: 0),
            dateLabel.bottomAnchor.constraint(equalTo: timeContainer.bottomAnchor, constant: 0),
            dateLabel.leadingAnchor.constraint(equalTo: timeContainer.leadingAnchor, constant: 10),
            dateLabel.widthAnchor.constraint(equalToConstant: ((UIScreen.main.bounds.width - 40) / 2) - 20)
        
        ].forEach({ $0.isActive = true })
        
        dateLabel.numberOfLines = 0
    }
    
    
    //MARK: - Configure Time Divider
    
    private func configureTimeDivider () {
        
        timeContainer.addSubview(timeDivider)
        timeDivider.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            timeDivider.topAnchor.constraint(equalTo: timeContainer.topAnchor, constant: 20),
            timeDivider.bottomAnchor.constraint(equalTo: timeContainer.bottomAnchor, constant: -20),
            timeDivider.widthAnchor.constraint(equalToConstant: 1),
            timeDivider.centerXAnchor.constraint(equalTo: timeContainer.centerXAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        timeDivider.backgroundColor = UIColor(hexString: "D8D8D8")
        timeDivider.layer.cornerRadius = 0.5
    }
    
    
    //MARK: - Configure Time Label
    
    private func configureTimeLabel () {
        
        timeContainer.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            timeLabel.topAnchor.constraint(equalTo: timeContainer.topAnchor, constant: 0),
            timeLabel.bottomAnchor.constraint(equalTo: timeContainer.bottomAnchor, constant: 0),
            timeLabel.trailingAnchor.constraint(equalTo: timeContainer.trailingAnchor, constant: -10),
            timeLabel.widthAnchor.constraint(equalToConstant: ((UIScreen.main.bounds.width - 40) / 2) - 20)
        
        ].forEach({ $0.isActive = true })
        
        timeLabel.numberOfLines = 0
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: - Configure Calendar Header Label
    
    private func configureCalendarHeaderLabel () {
        
        self.contentView.addSubview(calendarHeaderLabel)
        calendarHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            calendarHeaderLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            calendarHeaderLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor, constant: 0),
            calendarHeaderLabel.widthAnchor.constraint(equalToConstant: 150),
            calendarHeaderLabel.heightAnchor.constraint(equalToConstant: 35)
        
        ].forEach({ $0.isActive = true })
        
        calendarHeaderLabel.alpha = 0
        
        calendarHeaderLabel.font = UIFont(name: "Poppins-SemiBold", size: 25)
        calendarHeaderLabel.textAlignment = .center
        
        formatter.dateFormat = "MMM yyyy"
        calendarHeaderLabel.text = formatter.string(from: Date())
    }
    
    
    //MARK: - Configure Month Selection Buttons
    
    private func configureMonthSelectionButtons () {
        
        self.contentView.addSubview(previousMonthButton)
        previousMonthButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(nextMonthButton)
        nextMonthButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            previousMonthButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            previousMonthButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 22),
            previousMonthButton.widthAnchor.constraint(equalToConstant: 26),
            previousMonthButton.heightAnchor.constraint(equalToConstant: 26),
            
            nextMonthButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            nextMonthButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -22),
            nextMonthButton.widthAnchor.constraint(equalToConstant: 26),
            nextMonthButton.heightAnchor.constraint(equalToConstant: 26),
        
        ].forEach({ $0.isActive = true })
        
        previousMonthButton.alpha = 0
        previousMonthButton.tintColor = .black
        previousMonthButton.setImage(UIImage(named: "icons8-back-50"), for: .normal)
        previousMonthButton.addTarget(self, action: #selector(previousMonthButtonPressed), for: .touchUpInside)
        
        nextMonthButton.alpha = 0
        nextMonthButton.tintColor = .black
        nextMonthButton.setImage(UIImage(named: "icons8-forward-50"), for: .normal)
        nextMonthButton.addTarget(self, action: #selector(nextMonthButtonPressed), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Day Stack View
    
    private func configureDayStackView () {
        
        self.contentView.addSubview(dayStackView)
        dayStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            dayStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            dayStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            dayStackView.topAnchor.constraint(equalTo: calendarHeaderLabel.bottomAnchor, constant: 20),
            dayStackView.heightAnchor.constraint(equalToConstant: 21)
        
        ].forEach({ $0.isActive = true })
        
        dayStackView.alpha = 0
        
        dayStackView.axis = .horizontal
        dayStackView.alignment = .fill
        dayStackView.distribution = .fillEqually
        dayStackView.spacing = 0
        
        if dayStackView.arrangedSubviews.count == 0 {
            
            var count = 0
            let dayText = ["S", "M", "Tu", "W", "Th", "F", "S"]
            
            while count < 7 {
                
                let dayLabel = UILabel()
                dayLabel.font = UIFont(name: "Poppins-Medium", size: 15)
                dayLabel.textAlignment = .center
                dayLabel.textColor = .placeholderText
                dayLabel.text = dayText[count]
                
                dayStackView.addArrangedSubview(dayLabel)
                
                count += 1
            }
        }
    }
    
    
    //MARK: - Configure Calendar View
    
    private func configureCalendarView () {
        
        self.contentView.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            calendarView.topAnchor.constraint(equalTo: self.dayStackView.bottomAnchor, constant: 5),
            calendarView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            calendarView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - UIScreen.main.bounds.width.truncatingRemainder(dividingBy: 7)),
            calendarView.heightAnchor.constraint(equalToConstant: 280)
        
        ].forEach({ $0.isActive = true })
        
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        
        calendarView.scrollingMode = .stopAtEachSection
        calendarView.scrollDirection = .horizontal
        calendarView.showsVerticalScrollIndicator = false
        calendarView.showsHorizontalScrollIndicator = false
        
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        calendarView.allowsMultipleSelection = false
        calendarView.isRangeSelectionUsed = false
        
        calendarView.alpha = 0
        calendarView.backgroundColor = .clear
        
        calendarView.register(UINib(nibName: "DateCell", bundle: nil), forCellWithReuseIdentifier: "dateCell")
        
        //Removes white lines for the cells that appear
        calendarView.cellSize = (UIScreen.main.bounds.width - UIScreen.main.bounds.width.truncatingRemainder(dividingBy: 7)) / 7
        
        formatter.dateFormat = "MMM yyyy"
        calendarHeaderLabel.text = formatter.string(from: starts != nil ? starts! : ends ?? Date())
        
        calendarView.scrollToDate(starts != nil ? starts! : ends ?? Date(), animateScroll: false)
        calendarView.selectDates([starts != nil ? starts! : ends ?? Date()])
        
        //Determines how many weeks are in the month the calendarView will display, and adjusts the height of the TimeConfigurationCell in the tableView cell accordingly
        if (starts != nil ? starts! : ends ?? Date()).determineNumberOfWeeks() == 4 {
            
            timeConfigurationDelegate?.expandCalendarCellHeight(expand: false)
        }
        
        else {
            
            timeConfigurationDelegate?.expandCalendarCellHeight(expand: true)
        }
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: - Configure Time Selector Container
    
    private func configureTimeSelectorContainer () {
        
        self.contentView.addSubview(timeSelectorContainer)
        timeSelectorContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            timeSelectorContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -55),
            timeSelectorContainer.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor, constant: 0),
            timeSelectorContainer.widthAnchor.constraint(equalToConstant: 245),
            timeSelectorContainer.heightAnchor.constraint(equalToConstant: 77)
        
        ].forEach({ $0.isActive = true })
        
        timeSelectorContainer.alpha = 0
        timeSelectorContainer.backgroundColor = UIColor(hexString: "222222")
        timeSelectorContainer.layer.cornerRadius = 38
        timeSelectorContainer.layer.cornerCurve = .continuous
        
        timeSelectorContainer.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        timeSelectorContainer.layer.shadowRadius = 2
        timeSelectorContainer.layer.shadowOffset = CGSize(width: 0, height: 1)
        timeSelectorContainer.layer.shadowOpacity = 0.75
        
        //Calling functions that will configure all of the containers subviews
        configureSetATimeLabel()
        configureHourTextField()
        configureSemiColonLabel()
        configureMinuteTextField()
        configurePeriodButton()
    }
    
    
    //MARK: - Configure Set a Time Label
    
    private func configureSetATimeLabel () {
        
        timeSelectorContainer.addSubview(setATimeLabel)
        setATimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            setATimeLabel.leadingAnchor.constraint(equalTo: timeSelectorContainer.leadingAnchor, constant: 10),
            setATimeLabel.trailingAnchor.constraint(equalTo: timeSelectorContainer.trailingAnchor, constant: -10),
            setATimeLabel.topAnchor.constraint(equalTo: timeSelectorContainer.topAnchor, constant: 5),
            setATimeLabel.heightAnchor.constraint(equalToConstant: 25)
        
        ].forEach({ $0.isActive = true })
        
        setATimeLabel.font = UIFont(name: "Poppins-SemiBold", size: 17)
        setATimeLabel.textColor = .white
        setATimeLabel.textAlignment = .center
        setATimeLabel.text = "Set a Time"
    }
    
    
    //MARK: - Configure Hour Text Field
    
    private func configureHourTextField () {
        
        timeSelectorContainer.addSubview(hourTextField)
        hourTextField.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            hourTextField.leadingAnchor.constraint(equalTo: timeSelectorContainer.leadingAnchor, constant: 25),
            hourTextField.bottomAnchor.constraint(equalTo: timeSelectorContainer.bottomAnchor, constant: -10),
            hourTextField.widthAnchor.constraint(equalToConstant: 50),
            hourTextField.heightAnchor.constraint(equalToConstant: 30)
        
        ].forEach({ $0.isActive = true })
        
        hourTextField.delegate = self
        hourTextField.keyboardType = .numberPad
        
        hourTextField.layer.borderWidth = 1
        hourTextField.layer.borderColor = UIColor.white.cgColor
        hourTextField.layer.cornerRadius = 10
        
        hourTextField.borderStyle = .none
        hourTextField.font = UIFont(name: "Poppins-SemiBold", size: 18)
        hourTextField.textColor = .white
        hourTextField.textAlignment = .center
        
        hourTextField.setCustomPlaceholder(text: "H", alignment: .center)
        
        formatter.dateFormat = "h"
        hourTextField.text = formatter.string(from: starts != nil ? starts! : ends ?? Date())
    }
    
    
    //MARK: - Configure Semi-Colon Label
    
    private func configureSemiColonLabel () {
        
        timeSelectorContainer.addSubview(semiColonLabel)
        semiColonLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            semiColonLabel.leadingAnchor.constraint(equalTo: hourTextField.trailingAnchor, constant: 0),
            semiColonLabel.bottomAnchor.constraint(equalTo: timeSelectorContainer.bottomAnchor, constant: -10),
            semiColonLabel.widthAnchor.constraint(equalToConstant: 20),
            semiColonLabel.heightAnchor.constraint(equalToConstant: 30)
        
        ].forEach({ $0.isActive = true })
        
        semiColonLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
        semiColonLabel.textColor = .white
        semiColonLabel.textAlignment = .center
        semiColonLabel.text = ":"
    }
    
    
    //MARK: - Configure Minute Text Field
    
    private func configureMinuteTextField () {
        
        timeSelectorContainer.addSubview(minuteTextField)
        minuteTextField.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            minuteTextField.leadingAnchor.constraint(equalTo: semiColonLabel.trailingAnchor, constant: 0),
            minuteTextField.bottomAnchor.constraint(equalTo: timeSelectorContainer.bottomAnchor, constant: -10),
            minuteTextField.widthAnchor.constraint(equalToConstant: 50),
            minuteTextField.heightAnchor.constraint(equalToConstant: 30)
        
        ].forEach({ $0.isActive = true })
        
        minuteTextField.delegate = self
        minuteTextField.keyboardType = .numberPad
        
        minuteTextField.layer.borderWidth = 1
        minuteTextField.layer.borderColor = UIColor.white.cgColor
        minuteTextField.layer.cornerRadius = 10
        
        minuteTextField.borderStyle = .none
        minuteTextField.font = UIFont(name: "Poppins-SemiBold", size: 18)
        minuteTextField.textColor = .white
        minuteTextField.textAlignment = .center
        
        minuteTextField.setCustomPlaceholder(text: "MM", alignment: .center)
        
        formatter.dateFormat = "mm"
        minuteTextField.text = formatter.string(from: starts != nil ? starts! : ends ?? Date())
    }
    
    
    //MARK: - Configure Period Button
    
    private func configurePeriodButton () {
        
        timeSelectorContainer.addSubview(periodButton)
        periodButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            periodButton.trailingAnchor.constraint(equalTo: timeSelectorContainer.trailingAnchor, constant: -25),
            periodButton.bottomAnchor.constraint(equalTo: timeSelectorContainer.bottomAnchor, constant: -10),
            periodButton.widthAnchor.constraint(equalToConstant: 50),
            periodButton.heightAnchor.constraint(equalToConstant: 30)
        
        ].forEach({ $0.isActive = true })
        
        periodButton.layer.borderWidth = 1
        periodButton.layer.borderColor = UIColor.white.cgColor
        periodButton.layer.cornerRadius = 10
        
        periodButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 18)
        periodButton.titleLabel?.textColor = .white
        periodButton.titleLabel?.textAlignment = .center
        
        formatter.dateFormat = "a"
        periodButton.setTitle(formatter.string(from: starts != nil ? starts! : ends ?? Date()), for: .normal)
        
        periodButton.addTarget(self, action: #selector(periodButtonPressed), for: .touchUpInside)
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: - Configure Done Button
    private func configureDoneButton () {
        
        self.contentView.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            doneButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -30),
            doneButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
            doneButton.widthAnchor.constraint(equalToConstant: 75),
            doneButton.heightAnchor.constraint(equalToConstant: 35)
        
        ].forEach({ $0.isActive = true })
        
        doneButton.alpha = 0
        doneButton.tintColor = .black
        doneButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 17)
        doneButton.titleLabel?.textAlignment = .center
        doneButton.setTitle("Done", for: .normal)
        
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: - Configure Notification Observors
    
    private func configureNotificationObservors () {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingPresented), name: UIApplication.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardBeingDismissed), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: - Reconfigure Cell with Calendar
    
    func reconfigureCellWithCalendar () {

        configureCalendarHeaderLabel()
        configureMonthSelectionButtons()
        configureDayStackView()
        configureCalendarView()

        configureTimeSelectorContainer()
        
        configureDoneButton()
        
        titleLabel.textColor = .red
        
        //Animating the removal of the timeContainer
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut) {
            
            self.timeContainer.alpha = 0
            
        } completion: { (finished: Bool) in
            
            self.timeContainer.removeFromSuperview()
        }
        
        //Animating the addition of the calendar and done button
        UIView.animate(withDuration: 0.4, delay: 0.2, options: .curveEaseInOut) {
            
            self.calendarHeaderLabel.alpha = 1
            self.previousMonthButton.alpha = 1
            self.nextMonthButton.alpha = 1
            self.dayStackView.alpha = 1
            self.calendarView.alpha = 1
            
            self.doneButton.alpha = 1
        }
        
        //Animating the addition of the time selector delayed slightly to improve animations
        UIView.animate(withDuration: 0.4, delay: 0.35, options: .curveEaseInOut) {
            
            self.timeSelectorContainer.alpha = 1
        }
    }
    
    
    //MARK: - Reconfigure Cell without Calendar
    
    func reconfigureCellWithoutCalendar () {
        
        titleLabel.textColor = .black
        
        //Animating the removal of the calendar, time selector, and the done button
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut) {
            
            self.calendarHeaderLabel.alpha = 0
            self.previousMonthButton.alpha = 0
            self.nextMonthButton.alpha = 0
            self.dayStackView.alpha = 0
            self.calendarView.alpha = 0
            
            self.timeSelectorContainer.alpha = 0
            self.doneButton.alpha = 0
            
        } completion: { (finished: Bool) in
            
            self.calendarHeaderLabel.removeFromSuperview()
            self.previousMonthButton.removeFromSuperview()
            self.nextMonthButton.removeFromSuperview()
            self.dayStackView.removeFromSuperview()
            self.calendarView.removeFromSuperview()
            
            self.timeSelectorContainer.removeFromSuperview()
            self.doneButton.removeFromSuperview()
        }
        
        configureTimeContainer() //Reconfiguring the time container
        
        UIView.animate(withDuration: 0.4, delay: 0.2, options: .curveEaseInOut) {
            
            self.timeContainer.alpha = 1
        }
    }

    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: - Set Date Label Text
    
    private func setDateLabelText () {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let largeText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Medium", size: 32) as Any, NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.paragraphStyle : paragraphStyle]
        let smallText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Medium", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray, NSAttributedString.Key.paragraphStyle : paragraphStyle]

        let attributedString = NSMutableAttributedString(string: "")
        
        formatter.dateFormat = "d"
        attributedString.append(NSAttributedString(string: formatter.string(from: starts != nil ? starts! : ends ?? Date()), attributes: largeText))
        
        attributedString.append(NSAttributedString(string: "\n"))
        
        formatter.dateFormat = "MMMM"
        attributedString.append(NSAttributedString(string: formatter.string(from: starts != nil ? starts! : ends ?? Date()), attributes: smallText))
        
        dateLabel.attributedText = attributedString
    }
    
    
    //MARK: - Set Time Label Text
    
    private func setTimeLabelText () {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let largeText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Medium", size: 32) as Any, NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.paragraphStyle : paragraphStyle]
        let smallText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Medium", size: 17) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray, NSAttributedString.Key.paragraphStyle : paragraphStyle]
        let attributedString = NSMutableAttributedString(string: "")
        
        formatter.dateFormat = "h:mm"
        attributedString.append(NSAttributedString(string: formatter.string(from: starts != nil ? starts! : ends ?? Date()), attributes: largeText))
        
        attributedString.append(NSAttributedString(string: "\n"))
        
        formatter.dateFormat = "a"
        attributedString.append(NSAttributedString(string: formatter.string(from: starts != nil ? starts! : ends ?? Date()), attributes: smallText))
        
        timeLabel.attributedText = attributedString
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: - Keyboard Being Presented
    
    @objc private func keyboardBeingPresented (notification: NSNotification) {
        
        if !keyboardPresent {
            
            var timeTextFieldSelected: Bool = false
            
            //Ensures that the hourTextField or the minuteTextField is the textField that called the keyboard
            if hourTextField.isFirstResponder || minuteTextField.isFirstResponder {
                
                timeTextFieldSelected = true
            }
            
            if timeTextFieldSelected {
                
                keyboardPresent = true
                
                if let viewController = timeConfigurationDelegate as? ConfigureBlockViewController {
                    
                    let tableView = viewController.configureBlockTableView
                    
                    let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
                    let keyboardHeight = keyboardFrame.cgRectValue.height
                    
                    //y-coord the timeConfigurationCell that called the keyboard
                    let timeConfigurationCellMinY = starts != nil ? tableView.rectForRow(at: IndexPath(row: 3, section: 0)).minY : tableView.rectForRow(at: IndexPath(row: 5, section: 0)).minY
                    
                    //Center of the hourTextField/minuteTextField
                    let timeTextFieldCenter = timeSelectorContainer.frame.minY + 18.5
                    
                    let tableViewMinY = viewController.view.convert(tableView.frame, to: keyWindow).minY
                    
                    let keyboardMinY = UIScreen.main.bounds.height - keyboardHeight
                    
                    let middleOfTableViewAndKeyboard = tableViewMinY.distance(to: keyboardMinY) / 2
                    
                    originalContentOffsetOfTableView = tableView.contentOffset.y
                    
                    UIView.animate(withDuration: 0.3) {
                        
                        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
                        tableView.contentOffset.y = (timeConfigurationCellMinY + timeTextFieldCenter - middleOfTableViewAndKeyboard)
                    }
                }
            }
        }
    }
    
    
    //MARK: - Keyboard Being Dismissed
    
    @objc private func keyboardBeingDismissed (notification: NSNotification) {
        
        if keyboardPresent {
            
            keyboardPresent = false
            
            if let viewController = timeConfigurationDelegate as? ConfigureBlockViewController {
                
                UIView.animate(withDuration: 0.3) {
                    
                    viewController.configureBlockTableView.contentOffset.y = self.originalContentOffsetOfTableView
                }
                
                viewController.configureBlockTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: - Hour Input Verification
    
    private func hourInputVerification (_ textField: UITextField) {
        
        //If the textField has had text entered
        if textField.text?.leniantValidationOfTextEntered() ?? false, let hour = Int(textField.text ?? "12") {
            
            //If the entered hour is less than 0 or greater than 12, default to 12
            if hour < 1 || hour > 12 {
                
                textField.text = "12"
            }
        }
        
        //If the textField hasn't had text entered
        else {
            
            formatter.dateFormat = "h"
            
            //Re-entering the previously selected time
            if starts != nil {
                
                textField.text = formatter.string(from: starts!)
            }
            
            else if ends != nil {
                
                textField.text = formatter.string(from: ends!)
            }
        }
        
        //Verifying that the selected hour falls within the accepted range
        if starts != nil {
            
            //Done this way to preserve the correct time period
            formatter.dateFormat = ":mm a yyyy MMMM dd"
            let enteredTime = (textField.text ?? "12") + formatter.string(from: starts!)
            
            formatter.dateFormat = "h:mm a yyyy MMMM dd"
            var components = calendar.dateComponents(in: .current, from: formatter.date(from: enteredTime) ?? Date())

            //If this is a start time, setting it to be 11:55 PM isn't permitted
            if components.hour == 23 && components.minute == 55 {
                
                //Setting the time to be 11:50 PM instead
                minuteTextField.text = "50"
                
                components.minute = 50
            }
            
            starts = components.date
        }
        
        else if ends != nil {
            
            //Done this way to preserve the correct time period
            formatter.dateFormat = ":mm a yyyy MMMM dd"
            let enteredTime = (textField.text ?? "12") + formatter.string(from: ends!)
            
            formatter.dateFormat = "h:mm a yyyy MMMM dd"
            var components = calendar.dateComponents(in: .current, from: formatter.date(from: enteredTime) ?? Date())
            
            //If this is a end time, setting it to be 12:00 AM isn't permitted
            if components.hour == 0 && components.minute == 0 {
                
                //Setting the time to be 12:05 AM instead
                minuteTextField.text = "05"
                
                components.hour = 0
                components.minute = 5
            }
            
            ends = components.date
        }
    }
    
    
    //MARK: - Minute Input Verification
    
    private func minuteInputVerification(_ textField: UITextField) {
        
        //If the textField has had text entered
        if textField.text?.leniantValidationOfTextEntered() ?? false, let minutes = Int(textField.text ?? "0") {
            
            //If the entered minute isn't already in a increment of 5
            if minutes % 5 != 0 {
                
                //If the remainder is less than 3, signifying it should be rounded down
                if minutes % 5 < 3 {
                    
                    //If the minutes rounded down is less than or equal to 0 or greater than or equal to 60
                    if minutes - (minutes % 5) <= 0 || minutes - (minutes % 5) >= 60 {
                        
                        textField.text = "00"
                    }
                    
                    else {
                        
                        textField.text = "\(minutes - (minutes % 5))"
                    }
                }
                
                //If the remainder is less than 3, signifying it should be rounded up
                else {
                    
                    //If the minutes rounded up is less than or equal to 0 or is greater than or equal to 60
                    if minutes + (5 - (minutes % 5)) <= 0 || minutes + (5 - (minutes % 5)) >= 60 {
                        
                        textField.text = "00"
                    }
                    
                    else {
                        
                        textField.text = "\(minutes + (5 - (minutes % 5)))"
                    }
                }
            }
            
            //If the entered minute is already in a increment of 5
            else {
                
                if minutes <= 0 || minutes >= 60 {
                    
                    textField.text = "00"
                }
            }
        }
        
        //If the textField hasn't had text entered
        else {
            
            formatter.dateFormat = "mm"
             
            //Re-entering the previously selected time
            if starts != nil {
                
                textField.text = formatter.string(from: starts!)
            }
            
            else if ends != nil {
                
                textField.text = formatter.string(from: ends!)
            }
        }
        
        //Verifying that the selected hour falls within the accepted range
        if starts != nil {

            var components = calendar.dateComponents(in: .current, from: starts ?? Date())

            if let minute = Int(textField.text ?? "00") {

                components.minute = minute
                
                //If this is a start time, setting it to be 11:55 PM isn't permitted
                if components.hour == 23 && components.minute == 55 {
                    
                    //Setting the time to be 11:50 PM instead
                    minuteTextField.text = "50"
                    
                    components.minute = 50
                }
                
                starts = components.date
            }
        }

        else if ends != nil {

            var components = calendar.dateComponents(in: .current, from: ends!)
            
            if let minute = Int(textField.text ?? "00") {
                
                components.minute = minute
                
                //If this is a end time, setting it to be 12:00 AM isn't permitted
                if components.hour == 0 && components.minute == 0 {

                    //Setting the time to be 12:05 AM instead
                    minuteTextField.text = "05"
                    
                    components.hour = 0
                    components.minute = 5
                }

                ends = components.date
            }
        }
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: - Container Tapped
    
    @objc private func containerTapped () {
        
        timeConfigurationDelegate?.presentCalendar(startsCalendar: starts != nil)
    }
    
    
    //MARK: - Previous Month Button Pressed
    
    @objc private func previousMonthButtonPressed () {
        
        let visibleDates = calendarView.visibleDates()
        let firstVisibleDate = visibleDates.monthDates.first
        
        if let date = firstVisibleDate?.date, let previousMonth = calendar.date(byAdding: .month, value: -1, to: date), let startTime = collab?.dates["startTime"] {
            
            formatter.dateFormat = "yyyy MM"
            
            //If the previous month will be after or the same as the start month
            if formatter.date(from: formatter.string(from: previousMonth)) ?? Date() >= formatter.date(from: formatter.string(from: startTime)) ?? Date() {
                
                calendarView.scrollToDate(previousMonth)

                formatter.dateFormat = "MMM yyyy"
                calendarHeaderLabel.text = formatter.string(from: previousMonth)
            }
            
            else {
                
                let vibrateMethods = VibrateMethods()
                vibrateMethods.warningVibration()
            }
        }
    }
    
    
    //MARK: - Next Month Button Pressed
    
    @objc private func nextMonthButtonPressed () {
        
        let visibleDates = calendarView.visibleDates()
        let firstVisibleDate = visibleDates.monthDates.first
        
        if let date = firstVisibleDate?.date, let nextMonth = calendar.date(byAdding: .month, value: 1, to: date), let deadline = collab?.dates["deadline"] {
            
            formatter.dateFormat = "yyyy MM"
            
            //If the next month will be before or the same as the deadline month
            if formatter.date(from: formatter.string(from: nextMonth)) ?? Date() <= formatter.date(from: formatter.string(from: deadline)) ?? Date() {
                
                calendarView.scrollToDate(nextMonth)
                
                formatter.dateFormat = "MMM yyyy"
                calendarHeaderLabel.text = formatter.string(from: nextMonth)
            }
            
            else {
                
                let vibrateMethods = VibrateMethods()
                vibrateMethods.warningVibration()
            }
        }
    }
    
    
    //MARK: - Period Button Pressed
    
    @objc private func periodButtonPressed () {
        
        let vibrateMethods = VibrateMethods()
        vibrateMethods.quickVibration()
        
        formatter.dateFormat = "a"
        
        var currentPeriod: String
        currentPeriod = starts != nil ? formatter.string(from: starts!) : formatter.string(from: ends ?? Date())
        
        //Either adding or subtracting 12 hours from the current time to change the period
        var dateComponents = calendar.dateComponents(in: .current, from: starts != nil ? starts! : ends ?? Date())
        dateComponents.hour = currentPeriod == "AM" ? (dateComponents.hour ?? 0) + 12 : (dateComponents.hour ?? 12) - 12
        
        periodButton.setTitle(currentPeriod == "AM" ? "PM" : "AM", for: .normal)
        
        //Setting the updated time
        if starts != nil, let date = dateComponents.date {
            
            starts = date
            timeConfigurationDelegate?.timeEntered(startTime: starts, endTime: nil)
        }
        
        else if ends != nil, let date = dateComponents.date {
            
            ends = date
            timeConfigurationDelegate?.timeEntered(startTime: nil, endTime: ends!)
        }
    }
    
    
    //MARK: - Done Button Pressed
    
    @objc private func doneButtonPressed () {
        
        reconfigureCellWithoutCalendar()
        
        //Delayed to improve animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

            self.timeConfigurationDelegate?.dismissCalendar(startsCalendar: self.starts != nil)
        }
    }
}


//MARK: - CalendarView Extension

extension TimeConfigurationCell: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        if let collabStartTime = collab?.dates["startTime"], let collabDeadline = collab?.dates["deadline"] {
            
            return ConfigurationParameters(startDate: collabStartTime, endDate: collabDeadline, numberOfRows: 6, calendar: Calendar(identifier: .gregorian), generateInDates: .forAllMonths, generateOutDates: .tillEndOfGrid)
        }
        
        else {
            
            formatter.dateFormat = "yyyy MM dd"
            
            return ConfigurationParameters(startDate: formatter.date(from: "2010 01 01") ?? Date(), endDate: formatter.date(from: "2050 01 01") ?? Date(), numberOfRows: 6, calendar: Calendar(identifier: .gregorian), generateInDates: .forAllMonths, generateOutDates: .tillEndOfGrid)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {

        //If the selected date is between the startTime and the deadline
        if let collabStartTime = collab?.dates["startTime"], let collabDeadline = collab?.dates["deadline"], date.isBetween(startDate: collabStartTime, endDate: collabDeadline) {

            return true
        }
        
        else if let collabStartTime = collab?.dates["startTime"], let collabDeadline = collab?.dates["deadline"] {
            
            formatter.dateFormat = "yyyy MM dd"
            
            //If the selected date is equal to the start time
            if formatter.date(from: formatter.string(from: date)) == formatter.date(from: formatter.string(from: collabStartTime)) {
                
                return true
            }
            
            //If the selected date is equal to the deadline
            else if formatter.date(from: formatter.string(from: date)) == formatter.date(from: formatter.string(from: collabDeadline)) {
                
                return true
            }
            
            else {
                
                let vibrateMethods = VibrateMethods()
                vibrateMethods.warningVibration()
                
                //If the selected date is before the start time
                if formatter.date(from: formatter.string(from: date)) ?? Date() < formatter.date(from: formatter.string(from: collabStartTime)) ?? Date() {
                    
                    calendar.selectDates([collabStartTime]) //Selecting the start time instead
                }
                
                //If the selected date is after the deadline
                else if formatter.date(from: formatter.string(from: date)) ?? Date() > formatter.date(from: formatter.string(from: collabDeadline)) ?? Date() {
                    
                    calendar.selectDates([collabDeadline]) //Selecting the deadline instead
                }
                
                return false
            }
        }
        
        else {
            
            let vibrateMethods = VibrateMethods()
            vibrateMethods.warningVibration()
            
            return false
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        configureCell(view: cell, cellState: cellState)
        
        if starts != nil {
            
            formatter.dateFormat = "h:mm a"
            let selectedTime = formatter.string(from: starts!)
            
            formatter.dateFormat = "yyyy MM dd "
            let selectedDate = formatter.string(from: date)
            
            formatter.dateFormat = "yyyy MM dd h:mm a"
            starts = formatter.date(from: selectedDate + selectedTime)
            
            timeConfigurationDelegate?.timeEntered(startTime: starts, endTime: nil)
        }
        
        else if ends != nil {
            
            formatter.dateFormat = "h:mm a"
            let selectedTime = formatter.string(from: ends!)
            
            formatter.dateFormat = "yyyy MM dd "
            let selectedDate = formatter.string(from: date)
            
            formatter.dateFormat = "yyyy MM dd h:mm a"
            ends = formatter.date(from: selectedDate + selectedTime)
            
            timeConfigurationDelegate?.timeEntered(startTime: nil, endTime: ends!)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        let segmentInfo = visibleDates.monthDates.first
        
        if let visibleDate = segmentInfo?.date {
            
            formatter.dateFormat = "MMM yyyy"
            calendarHeaderLabel.text = formatter.string(from: visibleDate)
            
            if visibleDate.determineNumberOfWeeks() == 4 {
                
                timeConfigurationDelegate?.expandCalendarCellHeight(expand: false)
            }
            
            else {
                
                timeConfigurationDelegate?.expandCalendarCellHeight(expand: true)
            }
        }
    }
    
    
    //MARK: - Configure Calendar Cell
    
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        
        guard let cell = view as? DateCell else { return }
        
            cell.dateLabel.text = cellState.text
        
            handleCellVisibility(cell: cell, cellState: cellState)
            handleCellSelected(cell: cell, cellState: cellState)
    }
    
    
    //MARK: - Handle Cell Visibility
    
    func handleCellVisibility (cell: DateCell, cellState: CellState) {
        
        if cellState.dateBelongsTo == .thisMonth {
            
            cell.isHidden = false
        }
        
        else {
            
            cell.isHidden = true
        }
    }
    
    
    //MARK: - Handle Cell Selected
    
    func handleCellSelected (cell: DateCell, cellState: CellState) {
        
        cell.dateLabel.textColor = cellState.isSelected ? .white : UIColor(hexString: "222222")
        cell.dateLabel.font = cellState.isSelected ? UIFont(name: "Poppins-SemiBold", size: 19) : UIFont(name: "Poppins-Medium", size: 19)
        
        cell.singleSelectionView.isHidden = cellState.isSelected ? false : true
        cell.rangeSelectionView.isHidden = true
        
        //Increasing the size of the single selection view
        cell.singleSelectionView.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                
                constraint.constant = 37
            }
        }
        
        cell.singleSelectionView.layer.cornerRadius = 18.5
    }
}


//MARK: - TextField Delegate Extension

extension TimeConfigurationCell: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == hourTextField {
            
            hourInputVerification(hourTextField)
        }
        
        else if textField == minuteTextField {
            
            minuteInputVerification(minuteTextField)
        }
        
        //Setting the time in the parentViewController
        if starts != nil {
            
            timeConfigurationDelegate?.timeEntered(startTime: starts, endTime: nil)
        }
        
        else if ends != nil {
            
            timeConfigurationDelegate?.timeEntered(startTime: nil, endTime: ends)
        }
    }
}
