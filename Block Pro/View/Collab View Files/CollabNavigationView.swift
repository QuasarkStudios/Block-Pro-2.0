//
//  CollabNavigationView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 9/29/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CollabNavigationView: UIView {
    
    let panGestureView = UIView()
    let panGestureIndicator = UIView()
    
    let buttonStackView = UIStackView()
    
    let progressButton = UIButton(type: .system)
    let blocksButton = UIButton(type: .system)
    let messagesButton = UIButton(type: .system)
    
    let calendarContainer = UIView()
    let calendarHeaderLabel = UILabel()
    let calendarView = JTAppleCalendarView()
    
    let collabTableView = UITableView()
    
    var tableViewTopAnchorWithStackView: NSLayoutConstraint?
    var tableViewTopAnchorWithCalendar: NSLayoutConstraint?
    
    var collabStartTime: Date?
    var collabDeadline: Date?
    
    let formatter = DateFormatter()
    
    weak var collabViewController: AnyObject?
    
    init (collabStartTime: Date?, collabDeadline: Date?) {
        super.init(frame: .zero)
        
        self.collabStartTime = collabStartTime
        self.collabDeadline = collabDeadline
        
        configureView()
        configurePanGestureView()
        configureButtonStackView()
        configureButtons()
        configureCalendarContainer()
        configureCalendarHeader()
        configureCalendarView()
        configureTableView()
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configure View
    
    private func configureView () {
        
        self.backgroundColor = .white
    
        self.layer.cornerRadius = 27.5
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    
    //MARK: - Configure Pan Gesture View
    
    private func configurePanGestureView () {
        
        self.addSubview(panGestureIndicator) //Add this as a subview first
        self.addSubview(panGestureView)
        
        panGestureIndicator.translatesAutoresizingMaskIntoConstraints = false
        panGestureView.translatesAutoresizingMaskIntoConstraints = false
        
        [

            panGestureIndicator.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            panGestureIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            panGestureIndicator.widthAnchor.constraint(equalToConstant: 50),
            panGestureIndicator.heightAnchor.constraint(equalToConstant: 7.5),
            
            panGestureView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            panGestureView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            panGestureView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            panGestureView.heightAnchor.constraint(equalToConstant: 80)

        ].forEach{( $0.isActive = true )}
        
        panGestureIndicator.backgroundColor = UIColor(hexString: "222222")
        panGestureIndicator.layer.cornerRadius = 4
        panGestureIndicator.layer.cornerCurve = .continuous
        panGestureIndicator.clipsToBounds = true
    }
    
    
    //MARK: - Configure Button Stack View
    
    private func configureButtonStackView () {
        
        self.addSubview(buttonStackView)
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            buttonStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            buttonStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            buttonStackView.topAnchor.constraint(equalTo: panGestureIndicator.bottomAnchor, constant: 10),
            buttonStackView.heightAnchor.constraint(equalToConstant: 40)
        
        ].forEach({ $0.isActive = true })
        
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillEqually
        
        buttonStackView.addArrangedSubview(progressButton)
        buttonStackView.addArrangedSubview(blocksButton)
        buttonStackView.addArrangedSubview(messagesButton)
    }
    
    
    //MARK: - Configure Buttons
    
    private func configureButtons () {
        
        progressButton.setTitle("Progress", for: .normal)
        progressButton.setTitleColor(UIColor.lightGray, for: .normal)
        progressButton.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 15)
        progressButton.addTarget(self, action: #selector(progressButtonTouchUpInside), for: .touchUpInside)
        
        blocksButton.setTitle("Blocks", for: .normal)
        blocksButton.setTitleColor(UIColor.black, for: .normal)
        blocksButton.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 15)
        blocksButton.addTarget(self, action: #selector(blocksButtonTouchUpInside), for: .touchUpInside)
        
        messagesButton.setTitle("Messages", for: .normal)
        messagesButton.setTitleColor(UIColor.lightGray, for: .normal)
        messagesButton.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 15)
        messagesButton.addTarget(self, action: #selector(messagesButtonTouchUpInside), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Table View
    
    private func configureTableView() {
        
        self.addSubview(collabTableView)
        collabTableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            collabTableView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            collabTableView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            collabTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        tableViewTopAnchorWithStackView = collabTableView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 10)
        tableViewTopAnchorWithStackView?.isActive = true
        
        tableViewTopAnchorWithCalendar = collabTableView.topAnchor.constraint(equalTo: calendarContainer.bottomAnchor, constant: 5)
        tableViewTopAnchorWithCalendar?.isActive = false
        
        collabTableView.keyboardDismissMode = .interactive
        
        collabTableView.register(UITableViewCell.self, forCellReuseIdentifier: "seperatorCell")
    }
    
    //MARK: - Configure Calendar Container
    
    private func configureCalendarContainer () {
        
        self.addSubview(calendarContainer)
        calendarContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            calendarContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: topBarHeight + 10),
            calendarContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            calendarContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            calendarContainer.heightAnchor.constraint(equalToConstant: 0) //Height will be set later
        
        ].forEach({ $0.isActive = true })
        
        calendarContainer.clipsToBounds = true //Prevents the calendar from being seen during view transitions
    }
    
    
    //MARK: - Configure Calendar Header
    
    private func configureCalendarHeader () {
        
        calendarContainer.addSubview(calendarHeaderLabel)
        calendarHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            calendarHeaderLabel.leadingAnchor.constraint(equalTo: calendarContainer.leadingAnchor, constant: 18),
            calendarHeaderLabel.trailingAnchor.constraint(equalTo: calendarContainer.trailingAnchor, constant: 0),
            calendarHeaderLabel.topAnchor.constraint(equalTo: calendarContainer.topAnchor, constant: 0),
            calendarHeaderLabel.heightAnchor.constraint(equalToConstant: 30)
            
        ].forEach({ $0.isActive = true })
        
        calendarHeaderLabel.font = UIFont(name: "Poppins-SemiBold", size: 18)
        calendarHeaderLabel.textColor = .black
        calendarHeaderLabel.textAlignment = .left
    }
    
    
    //MARK: - Configure Calendar View
    
    private func configureCalendarView () {
        
        calendarContainer.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            calendarView.topAnchor.constraint(equalTo: calendarHeaderLabel.bottomAnchor, constant: 5),
            calendarView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            calendarView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - UIScreen.main.bounds.width.truncatingRemainder(dividingBy: 7)),
            calendarView.heightAnchor.constraint(equalToConstant: 55)
        
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
        
        calendarView.backgroundColor = .white
        
        calendarView.register(UINib(nibName: "DateCell", bundle: nil), forCellWithReuseIdentifier: "dateCell")
        
        //Removes white lines for the cells that appear
        calendarView.cellSize = (UIScreen.main.bounds.width - UIScreen.main.bounds.width.truncatingRemainder(dividingBy: 7)) / 7
        
        formatter.dateFormat = "MMMM"
        
        if let startTime = collabStartTime, Date() < startTime {

            calendarHeaderLabel.text = formatter.string(from: startTime)
            
            calendarView.scrollToDate(startTime, animateScroll: false)
            calendarView.selectDates([startTime])
        }

        else if let deadline = collabDeadline, Date() > deadline {

            calendarHeaderLabel.text = formatter.string(from: deadline)

            calendarView.scrollToDate(deadline, animateScroll: false)
            calendarView.selectDates([deadline])
        }

        else {

            calendarHeaderLabel.text = formatter.string(from: Date())
            
            calendarView.scrollToDate(Date(), animateScroll: false)
            calendarView.selectDates([Date()])
        }
    }
    

    //MARK: - Present Calendar
    
    func presentCalendar () {
        
        calendarContainer.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = 90
            }
        }
        
        self.tableViewTopAnchorWithStackView?.isActive = false
        self.tableViewTopAnchorWithCalendar?.isActive = true
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.layoutIfNeeded()
            
            self.collabTableView.contentInset = UIEdgeInsets(top: -22, left: 0, bottom: 0, right: 0)
        }
    }
    
    
    //MARK: - Dismiss Calendar
    
    func dismissCalendar () {
        
        calendarContainer.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .height {
                
                constraint.constant = 0
            }
        }
        
        self.tableViewTopAnchorWithCalendar?.isActive = false
        self.tableViewTopAnchorWithStackView?.isActive = true
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            
            self.layoutIfNeeded()
            
            self.collabTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.collabTableView.contentOffset = CGPoint(x: 0, y: self.collabTableView.contentOffset.x - 22)
            
        }
    }
    
    
    //MARK: - Progress Button Action
    
    @objc private func progressButtonTouchUpInside () {
        
        if let viewController = collabViewController as? CollabViewController {
            
            viewController.progressButtonTouchUpInside()
            
            UIView.transition(with: buttonStackView, duration: 0.15, options: .transitionCrossDissolve, animations: {
                
                self.progressButton.setTitleColor(.black, for: .normal)
                self.blocksButton.setTitleColor(.lightGray, for: .normal)
                self.messagesButton.setTitleColor(.lightGray, for: .normal)
            })
        }
    }
    
    
    //MARK: - Blocks Button Action
    
    @objc private func blocksButtonTouchUpInside () {
        
        if let viewController = collabViewController as? CollabViewController {
            
            viewController.blocksButtonTouchUpInside()
            
            UIView.transition(with: buttonStackView, duration: 0.15, options: .transitionCrossDissolve, animations: {
                
                self.progressButton.setTitleColor(.lightGray, for: .normal)
                self.blocksButton.setTitleColor(.black, for: .normal)
                self.messagesButton.setTitleColor(.lightGray, for: .normal)
            })
        }
    }
    
    
    //MARK: - Messages Button Action
    
    @objc private func messagesButtonTouchUpInside () {
        
        if let viewController = collabViewController as? CollabViewController {
            
            viewController.messagesButtonTouchUpInside()
            
            UIView.transition(with: buttonStackView, duration: 0.15, options: .transitionCrossDissolve, animations: {
                
                self.progressButton.setTitleColor(.lightGray, for: .normal)
                self.blocksButton.setTitleColor(.lightGray, for: .normal)
                self.messagesButton.setTitleColor(.black, for: .normal)
            })
        }
    }
}

//MARK: - JTAppleCalendar Extension
extension CollabNavigationView: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
    
        formatter.dateFormat = "yyyy MM dd"
        
        let startTimeDayOfWeek = Calendar.current.dateComponents([.weekday], from: collabStartTime ?? Date()).weekday
        
        return ConfigurationParameters(startDate: collabStartTime ?? Date(), endDate: collabDeadline ?? formatter.date(from: "2050 01 01")!, numberOfRows: 1, calendar: Calendar(identifier: .gregorian), generateInDates: .forFirstMonthOnly, generateOutDates: .off, firstDayOfWeek: DaysOfWeek(rawValue: startTimeDayOfWeek ?? 1) ?? .sunday, hasStrictBoundaries: false)
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
        if let startTime = collabStartTime, let deadline = collabDeadline, date.isBetween(startDate: startTime, endDate: deadline) {

            return true
        }

        else {

            if let startTime = collabStartTime {
                
                formatter.dateFormat = "yyyy MM dd"
                
                //If the selected date is greater than or equal to the startTime
                if formatter.date(from: formatter.string(from: date)) ?? Date() >= formatter.date(from: formatter.string(from: startTime)) ?? Date() {
                    
                    if let deadline = collabDeadline {
                        
                        //If the selected date is less than or equal to the deadline
                        if formatter.date(from: formatter.string(from: date)) ?? Date() <= formatter.date(from: formatter.string(from: deadline)) ?? Date() {
                            
                            return true
                        }
                        
                        //If the selected date is greater than the deadline
                        else {
                            
                            let vibrateMethods = VibrateMethods()
                            vibrateMethods.warningVibration()
                            
                            calendar.selectDates([deadline])
                            
                            return false
                        }
                    }
                    
                    //If there is no deadline and the selected date is greater than the start time
                    else {
                        
                        return true
                    }
                }
                
                //If the selected date is less than the start time
                else {
                    
                    let vibrateMethods = VibrateMethods()
                    vibrateMethods.warningVibration()
                    
                    calendar.selectDates([startTime])
                    
                    return false
                }
            }
            
            //If for some reason the start time is nil
            else {
                
                let vibrateMethods = VibrateMethods()
                vibrateMethods.warningVibration()
                
                return false
            }
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        //Sets the headerLabel text
        let segmentInfo = visibleDates.monthDates.first
    
        if let visibleDate = segmentInfo?.date {
            
            formatter.dateFormat = "MMMM"
            calendarHeaderLabel.text = formatter.string(from: visibleDate)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        //If the user scrolled to a date before the start time
        if let startTime = collabStartTime, visibleDates.monthDates.first?.date ?? Date() < startTime {
            
            calendar.scrollToDate(startTime)
        }
        
        //If the user scrolled to a date after the deadline
        else if let deadline = collabDeadline, visibleDates.monthDates.first?.date ?? Date() > deadline {
            
            calendar.scrollToDate(deadline)
        }
    }
    
    
    //MARK: - Configure Calendar Cell
    
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        
        guard let cell = view as? DateCell else { return }
        
            cell.dateLabel.text = cellState.text
            cell.rangeSelectionView.isHidden = true
        
            handleCellSelected(cell: cell, cellState: cellState)
    }
    
    
    //MARK: - Handle Cell Selected
    
    func handleCellSelected (cell: DateCell, cellState: CellState) {
        
        cell.singleSelectionView.isHidden = cellState.isSelected ? false : true
        
        cell.dateLabel.textColor = cellState.isSelected ? .white : UIColor(hexString: "222222")
        cell.dateLabel.font = UIFont(name: "Poppins-SemiBold", size: 19)
        
        cell.singleSelectionView.layer.cornerRadius = 0.5 * cell.singleSelectionView.frame.width
    }
}
