//
//  SendScheduleViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/19/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import JTAppleCalendar
import SVProgressHUD

class SendScheduleViewController: UIViewController {

    let navBar = UINavigationBar()
    
    let calendarHeaderLabel = UILabel()
    let previousMonthButton = UIButton(type: .system)
    let nextMonthButton = UIButton(type: .system)
    let dayStackView = UIStackView()
    
    let calendarView = JTAppleCalendarView()
    let tableViewContainer = UIView()
    
    let panGestureIndicator = UIView()
    let panGestureView = UIView()
    
    let blockTableView = UITableView()
    
    let sendButton = UIButton(type: .system)
    
    let currentUser = CurrentUser.sharedInstance
    let firebaseMessaging = FirebaseMessaging.sharedInstance
    let firebaseBlock = FirebaseBlock.sharedInstance
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    
    var containerTopAnchorConstantForVisibleMonth: CGFloat = 0
    
    var personalConversationID: String?
    var collabConversationID: String?
    
    var tableViewContainerTopAnchor: NSLayoutConstraint?
    var tableViewTopAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.isModalInPresentation = true
        self.view.backgroundColor = UIColor(hexString: "222222")
        
        configureNavBar()
        configureHeaderLabel()
        configureMonthButtons()
        configureDayStackView()
        configureCalendarView()
        
        configureTableViewContainer()
        configurePanGestureView()
        configureTableView(blockTableView)
        configureSendButton()
    }
    
    
    //MARK: - Configure Nav Bar
    
    private func configureNavBar () {
        
        self.view.addSubview(navBar)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            navBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            navBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            navBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            navBar.heightAnchor.constraint(equalToConstant: 44)
        
        ].forEach({ $0.isActive = true })
        
        navBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(cancelButtonPressed))
        cancelButton.style = .done
        navigationItem.leftBarButtonItem = cancelButton
        
        navBar.setItems([navigationItem], animated: false)
    }
    
    
    //MARK: - Configure Header Label
    
    private func configureHeaderLabel () {
        
        self.view.insertSubview(calendarHeaderLabel, belowSubview: navBar)
        calendarHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            calendarHeaderLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 34),
            calendarHeaderLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -34),
            calendarHeaderLabel.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 20),
            calendarHeaderLabel.heightAnchor.constraint(equalToConstant: 30)
        
        ].forEach({ $0.isActive = true })
        
        calendarHeaderLabel.font = UIFont(name: "Poppins-SemiBold", size: 28)
        calendarHeaderLabel.textAlignment = .left
        calendarHeaderLabel.textColor = .white
        
        formatter.dateFormat = "MMM yyyy"
        calendarHeaderLabel.text = formatter.string(from: Date())
    }
    
    
    //MARK: - Configure Month Buttons
    
    private func configureMonthButtons () {
        
        self.view.insertSubview(previousMonthButton, belowSubview: navBar)
        previousMonthButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.insertSubview(nextMonthButton, belowSubview: navBar)
        nextMonthButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            previousMonthButton.trailingAnchor.constraint(equalTo: nextMonthButton.leadingAnchor, constant: -7.5),
            previousMonthButton.centerYAnchor.constraint(equalTo: calendarHeaderLabel.centerYAnchor, constant: 0),
            previousMonthButton.widthAnchor.constraint(equalToConstant: 30),
            previousMonthButton.heightAnchor.constraint(equalToConstant: 30),
            
            nextMonthButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            nextMonthButton.centerYAnchor.constraint(equalTo: calendarHeaderLabel.centerYAnchor, constant: 0),
            nextMonthButton.widthAnchor.constraint(equalToConstant: 30),
            nextMonthButton.heightAnchor.constraint(equalToConstant: 30),
        
        ].forEach({ $0.isActive = true })
        
        previousMonthButton.tintColor = .white
        previousMonthButton.setImage(UIImage(named: "icons8-back-50"), for: .normal)
        previousMonthButton.addTarget(self, action: #selector(previousMonthButtonPressed), for: .touchUpInside)
        
        nextMonthButton.tintColor = .white
        nextMonthButton.setImage(UIImage(named: "icons8-forward-50"), for: .normal)
        nextMonthButton.addTarget(self, action: #selector(nextMonthButtonPressed), for: .touchUpInside)
    }
    
    
    //MARK: - Configure Day Stack View
    
    private func configureDayStackView () {
        
        self.view.insertSubview(dayStackView, belowSubview: navBar)
        dayStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            dayStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            dayStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            dayStackView.topAnchor.constraint(equalTo: calendarHeaderLabel.bottomAnchor, constant: 20),
            dayStackView.heightAnchor.constraint(equalToConstant: 21)
        
        ].forEach({ $0.isActive = true })
        
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
                dayLabel.textColor = .lightGray
                dayLabel.text = dayText[count]
                
                dayStackView.addArrangedSubview(dayLabel)
                
                count += 1
            }
        }
    }
    
    
    //MARK: - Configure Calendar View
    
    private func configureCalendarView () {
        
        self.view.insertSubview(calendarView, belowSubview: navBar)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            calendarView.topAnchor.constraint(equalTo: self.dayStackView.bottomAnchor, constant: 5),
            calendarView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            calendarView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - UIScreen.main.bounds.width.truncatingRemainder(dividingBy: 7)),
            calendarView.heightAnchor.constraint(equalToConstant: 280)
        
        ].forEach({ $0.isActive = true })
        
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        
        calendarView.backgroundColor = .clear
        
        calendarView.scrollingMode = .stopAtEachSection
        calendarView.scrollDirection = .horizontal
        calendarView.showsVerticalScrollIndicator = false
        calendarView.showsHorizontalScrollIndicator = false
        
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        //Removes white lines for the cells that appear
        calendarView.cellSize = (UIScreen.main.bounds.width - UIScreen.main.bounds.width.truncatingRemainder(dividingBy: 7)) / 7
        
        calendarView.allowsMultipleSelection = false
        calendarView.isRangeSelectionUsed = true
        
        calendarView.selectDates([Date()])
        calendarView.scrollToDate(Date(), animateScroll: false)
        
        calendarView.register(UINib(nibName: "DateCell", bundle: nil), forCellWithReuseIdentifier: "dateCell")
    }
    
    
    //MARK: - Configure TableView Container
    
    private func configureTableViewContainer () {
        
        self.view.insertSubview(tableViewContainer, belowSubview: navBar)
        tableViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            tableViewContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            tableViewContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            tableViewContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        tableViewContainer.backgroundColor = .white
    
        tableViewContainer.layer.cornerRadius = 27.5
        tableViewContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        if Date().determineNumberOfWeeks() == 4 {
            
            tableViewContainerTopAnchor = tableViewContainer.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 44 + 340)
            containerTopAnchorConstantForVisibleMonth = 44 + 340 //Height of the navBar + a value borrowed from the collabViewController + 10
        }
        
        else {
            
            tableViewContainerTopAnchor = tableViewContainer.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 44 + 386)
            containerTopAnchorConstantForVisibleMonth = 44 + 386 //Height of the navBar + a value borrowed from the collabViewController + 10
        }
        
        tableViewContainerTopAnchor?.isActive = true
    }
    
    
    //MARK: - Configure Pan Gesture View
    
    private func configurePanGestureView () {
        
        tableViewContainer.addSubview(panGestureIndicator) //Add this as a subview first
        tableViewContainer.addSubview(panGestureView)
        
        panGestureIndicator.translatesAutoresizingMaskIntoConstraints = false
        panGestureView.translatesAutoresizingMaskIntoConstraints = false
        
        [

            panGestureIndicator.topAnchor.constraint(equalTo: tableViewContainer.topAnchor, constant: 10),
            panGestureIndicator.centerXAnchor.constraint(equalTo: tableViewContainer.centerXAnchor),
            panGestureIndicator.widthAnchor.constraint(equalToConstant: 50),
            panGestureIndicator.heightAnchor.constraint(equalToConstant: 7.5),
            
            panGestureView.leadingAnchor.constraint(equalTo: tableViewContainer.leadingAnchor, constant: 0),
            panGestureView.trailingAnchor.constraint(equalTo: tableViewContainer.trailingAnchor, constant: 0),
            panGestureView.topAnchor.constraint(equalTo: tableViewContainer.topAnchor, constant: 0),
            panGestureView.heightAnchor.constraint(equalToConstant: 80)

        ].forEach{( $0.isActive = true )}
        
        panGestureView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:))))
        
        panGestureIndicator.backgroundColor = UIColor(hexString: "222222")
        panGestureIndicator.layer.cornerRadius = 4
        panGestureIndicator.layer.cornerCurve = .continuous
        panGestureIndicator.clipsToBounds = true
    }
    
    
    //MARK: - Configure TableView
    
    private func configureTableView (_ tableView: UITableView) {
        
        tableViewContainer.insertSubview(tableView, belowSubview: panGestureView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            tableView.leadingAnchor.constraint(equalTo: tableViewContainer.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: tableViewContainer.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: tableViewContainer.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        tableViewTopAnchor = tableView.topAnchor.constraint(equalTo: panGestureIndicator.bottomAnchor, constant: 10)
        tableViewTopAnchor?.isActive = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 0
        
        tableView.separatorStyle = .none
        tableView.scrollsToTop = true
        tableView.delaysContentTouches = false
        
        tableView.register(BlocksTableViewCell.self, forCellReuseIdentifier: "blocksTableViewCell")
    }
    
    
    //MARK: - Configure Send Button
    
    private func configureSendButton () {
        
        self.view.addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            sendButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? -29 : -20),
            sendButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? -29 : -20),
            sendButton.widthAnchor.constraint(equalToConstant: 50),
            sendButton.heightAnchor.constraint(equalToConstant: 50)
            
        ].forEach( { $0.isActive = true } )
        
        sendButton.layer.cornerRadius = 25
        sendButton.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        sendButton.layer.shadowRadius = 2
        sendButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        sendButton.layer.shadowOpacity = 0.65
        
        sendButton.backgroundColor = UIColor(hexString: "222222")
        sendButton.tintColor = .white
        sendButton.setImage(UIImage(named: "paper_plane")?.withRenderingMode(.alwaysTemplate), for: .normal)
        sendButton.imageEdgeInsets = UIEdgeInsets(top: 12.5, left: 12.5, bottom: 12.5, right: 12.5)
        
        sendButton.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
    }
    
    
    //MARK: - Handle Pan
    
    @objc private func handlePan (sender: UIPanGestureRecognizer) {
        
        switch sender.state {
        
        case .began, .changed:
            
            moveWithPan(sender)
            
        case .ended:
            
            if (tableViewContainerTopAnchor?.constant ?? 0) < (containerTopAnchorConstantForVisibleMonth * 0.8) {
                
                expandView()
            }
            
            else {
                
                returnToOrigin()
            }
            
        default:
            
            break
        }
    }
    
    
    //MARK: - Move with Pan
    
    private func moveWithPan (_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self.view)
        
        //Minimum and maximum allowable constant for the containerTopAnchor
        let topAnchorRange = 0 ... containerTopAnchorConstantForVisibleMonth
        
        //If the topAnchor + the translation is container within the topAnchorRange
        if topAnchorRange.contains((tableViewContainerTopAnchor?.constant ?? 0) + translation.y) {
            
            tableViewContainerTopAnchor?.constant += translation.y
        }
        
        else {
            
            if (tableViewContainerTopAnchor?.constant ?? 0) + translation.y < 0 {
                
                tableViewContainerTopAnchor?.constant = 0
            }
            
            else if (tableViewContainerTopAnchor?.constant ?? 0) + translation.y > containerTopAnchorConstantForVisibleMonth {
                
                tableViewContainerTopAnchor?.constant = containerTopAnchorConstantForVisibleMonth
            }
        }
        
        let alphaPart = 1 / containerTopAnchorConstantForVisibleMonth
        panGestureIndicator.alpha = 1 - (alphaPart * (containerTopAnchorConstantForVisibleMonth - (tableViewContainerTopAnchor?.constant ?? 0)))
        
        sender.setTranslation(.zero, in: self.view)
    }
    
    
    //MARK: - Return to Origin
    
    private func returnToOrigin () {
        
        navBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white)
        navBar.items?.first?.title = ""
        
        panGestureView.isUserInteractionEnabled = true
        
        tableViewContainerTopAnchor?.constant = containerTopAnchorConstantForVisibleMonth
        tableViewTopAnchor?.constant = 10
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
            
            self.tableViewContainer.layer.cornerRadius = 27.5
            self.panGestureIndicator.alpha = 1
            
        }
    }
    
    
    //MARK: - Expand View
    
    private func expandView () {
        
        panGestureView.isUserInteractionEnabled = false
        
        tableViewContainerTopAnchor?.constant = 0
        tableViewTopAnchor?.constant = 40
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut) {
            
            self.view.layoutIfNeeded()
            
            self.tableViewContainer.layer.cornerRadius = 0
            self.panGestureIndicator.alpha = 0
            
        } completion: { (finished: Bool) in
            
            self.navBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .black)
            self.navBar.items?.first?.title = "Share your Schedule"
        }
    }
    
    
    //MARK: - Animate Table View Container Top Anchor
    
    private func animateTableViewContainerTopAnchor (_ date: Date?) {
        
        if let date = date {
            
            if date.determineNumberOfWeeks() == 4 {
                
                tableViewContainerTopAnchor?.constant = 44 + 340
                containerTopAnchorConstantForVisibleMonth = 44 + 340
            }
            
            else {
                
                tableViewContainerTopAnchor?.constant = 44 + 386
                containerTopAnchorConstantForVisibleMonth = 44 + 386
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    //MARK: - Perform Reload and Scroll of TableView
    
    private func performReloadAndScrollOfTableView (_ date: Date) {
        
        UIView.transition(with: blockTableView, duration: 0.3, options: .transitionCrossDissolve) {
            
            self.blockTableView.reloadData()
            
            let sortedBlocks = self.firebaseBlock.cachedPersonalBlocks.filter({ self.calendar.isDate($0.starts!, inSameDayAs: date) }).sorted(by: { $0.starts! < $1.starts! })
            
            //Gets the first block for the selected date
            if let startTime = sortedBlocks.first?.starts {
                
                //yCoordForBlockTime
                let blockStartHour = self.calendar.dateComponents([.hour], from: startTime).hour!
                let blockStartMinute = self.calendar.dateComponents([.minute], from: startTime).minute!
                let yCoordForBlockTime = CGFloat((Double(blockStartHour) * 90) + (Double(blockStartMinute) * 1.5)) + 50
                
                //Small delay allows time for the tableView to reload
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    
                    //Stops the tableView from scroll out of the frame of the cell
                    if yCoordForBlockTime < 2210 - self.blockTableView.frame.height {
                        
                        self.blockTableView.contentOffset.y = yCoordForBlockTime
                    }
                    
                    else {
                        
                        self.blockTableView.contentOffset.y = 2210 - self.blockTableView.frame.height
                    }
                }
            }
            
            else {
                
                //Small delay allows time for the tableView to reload
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    
                    self.blockTableView.contentOffset.y = 0
                }
            }
        }
    }
    
    
    //MARK: - Send Button Pressed
    
    @objc private func sendButtonPressed () {
        
        if let selectedDate = calendarView.selectedDates.first {
            
            SVProgressHUD.show()
            
            //Gets all the blocks for the selectedDate
            let blocks: [Block] = firebaseBlock.cachedPersonalBlocks.filter({ calendar.isDate($0.starts!, inSameDayAs: selectedDate) })
            
            var message = Message()
            message.sender = currentUser.userID
            message.dateForBlocks = selectedDate
            message.messageBlocks = blocks
            message.timestamp = Date()
            
            //Personal Conversation
            if let conversationID = personalConversationID {
                
                firebaseMessaging.sendPersonalMessage(conversationID: conversationID, message) { [weak self] (error) in

                    if error != nil {

                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }

                    else {

                        SVProgressHUD.dismiss()
                        self?.dismiss(animated: true)
                    }
                }
            }
            
            //Collab Conversation
            else if let collabID = collabConversationID {
                
                firebaseMessaging.sendCollabMessage(collabID: collabID, message) { [weak self] (error) in

                    if error != nil {

                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }

                    else {

                        SVProgressHUD.dismiss()
                        self?.dismiss(animated: true)
                    }
                }
            }
        }
        
        else {
            
            SVProgressHUD.showError(withStatus: "Sorry, something went wrong sending your schedule")
        }
    }
    
    
    //MARK: - Previous Month Button Pressed
    
    @objc private func previousMonthButtonPressed () {
        
        let visibleDates = calendarView.visibleDates()
        let firstVisibleDate = visibleDates.monthDates.first
        
        if let date = firstVisibleDate?.date, let previousMonth = calendar.date(byAdding: .month, value: -1, to: date) {
            
            calendarView.scrollToDate(previousMonth)

            formatter.dateFormat = "MMM yyyy"
            calendarHeaderLabel.text = formatter.string(from: previousMonth)
            
            animateTableViewContainerTopAnchor(previousMonth)
        }
    }
    
    
    //MARK: - Next Month Button Pressed
    
    @objc private func nextMonthButtonPressed () {
        
        let visibleDates = calendarView.visibleDates()
        let firstVisibleDate = visibleDates.monthDates.first
        
        if let date = firstVisibleDate?.date, let nextMonth = calendar.date(byAdding: .month, value: 1, to: date) {
            
            calendarView.scrollToDate(nextMonth)

            formatter.dateFormat = "MMM yyyy"
            calendarHeaderLabel.text = formatter.string(from: nextMonth)
            
            animateTableViewContainerTopAnchor(nextMonth)
        }
    }
    
    
    //MARK: - Cancel Button Pressed
    
    @objc private func cancelButtonPressed () {
        
        if tableViewContainerTopAnchor?.constant == 0 {
            
            returnToOrigin()
        }
        
        else {
            
            dismiss(animated: true)
        }
    }
}


//MARK: - JTAppleCalendarView DataSource and Delegate Extension

extension SendScheduleViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        
        return ConfigurationParameters(startDate: formatter.date(from: "2010 01 01") ?? Date(), endDate: formatter.date(from: "2050 01 01") ?? Date(), numberOfRows: 6, calendar: Calendar(identifier: .gregorian), generateInDates: .forAllMonths, generateOutDates: .tillEndOfGrid)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        configureCell(view: cell, cellState: cellState)
        
        performReloadAndScrollOfTableView(date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        let segmentInfo = visibleDates.monthDates.first
        let visibleDate = segmentInfo?.date
        
        if let date = visibleDate {
            
            formatter.dateFormat = "MMM yyyy"
            calendarHeaderLabel.text = formatter.string(from: date)
        }
        
        animateTableViewContainerTopAnchor(visibleDate)
    }
    
    
    //MARK: - Configure Cell
    
    private func configureCell (view: JTAppleCell?, cellState: CellState) {
        
        guard let cell = view as? DateCell else { return }
        
            cell.backgroundColor = .clear
            cell.dateLabel.text = cellState.text
            cell.rangeSelectionView.isHidden = true
        
            handleCellVisibilty(cell: cell, cellState: cellState)
            handleCellDotView(cell: cell, cellState: cellState)
            handleCellSelection(cell: cell, cellState: cellState)
            handleCellText(cell: cell, cellState: cellState)
    }
    
    
    //MARK: - Handle Cell Visibility
    
    private func handleCellVisibilty (cell: DateCell, cellState: CellState) {
        
        if cellState.dateBelongsTo == .thisMonth {
            
            cell.isHidden = false
        }
        
        else {
            
            cell.isHidden = true
        }
    }
    
    
    //MARK: - Handle Cell Dot View
    
    private func handleCellDotView (cell: DateCell, cellState: CellState) {
        
        if firebaseBlock.cachedPersonalBlocks.filter({ calendar.isDate($0.starts!, inSameDayAs: cellState.date) }).first != nil {
            
            cell.dotView.isHidden = false

            cell.dotView.backgroundColor = cellState.isSelected ? .black : .white

            cell.dotView.layer.cornerRadius = 2.5
            cell.dotView.clipsToBounds = true

            cell.dotViewBottomAnchor.constant = cellState.isSelected ? 8.5 : 2.5
        }
        
        else {
            
            cell.dotView.isHidden = true
        }
    }
    
    
    //MARK: - Handle Cell Selection
    
    private func handleCellSelection (cell: DateCell, cellState: CellState) {
        
        if cellState.isSelected {
            
            cell.singleSelectionView.backgroundColor = .white
            cell.singleSelectionView.layer.cornerRadius = 0.5 * cell.singleSelectionView.frame.width
            cell.singleSelectionView.isHidden = false
            
            //Increasing the size of the single selection view
            cell.singleSelectionView.constraints.forEach { (constraint) in
                
                if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                    
                    constraint.constant = 37
                }
            }
            
            cell.singleSelectionView.layer.cornerRadius = 18.5
        }
        
        else {
            
            cell.singleSelectionView.isHidden = true
        }
    }
    
    
    //MARK: - Handle Cell Text
    
    private func handleCellText (cell: DateCell, cellState: CellState) {
        
        //If this is the cell for the currentDate
        if calendar.isDate(cellState.date, inSameDayAs: Date()) {
            
            cell.dateLabel.textColor = UIColor.systemRed.flatten().lighten(byPercentage: 0.1)
        }
        
        else {
            
            cell.dateLabel.textColor = cellState.isSelected ? .black : .white
        }
    }
}


//MARK: - TableView DataSource and Delegate Extension

extension SendScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Number of Rows
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    
    //MARK: - Cell for Row
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        let cell = tableView.dequeueReusableCell(withIdentifier: "blocksTableViewCell", for: indexPath) as! BlocksTableViewCell
        cell.selectionStyle = .none

        let date = calendarView.selectedDates.first ?? Date()
        cell.blocks = firebaseBlock.cachedPersonalBlocks.filter({ calendar.isDate($0.starts!, inSameDayAs: date) }).sorted(by: { $0.starts! < $1.starts! })
        
        return cell
    }
    
    
    //MARK: - Height for Row
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 2210
    }
}
