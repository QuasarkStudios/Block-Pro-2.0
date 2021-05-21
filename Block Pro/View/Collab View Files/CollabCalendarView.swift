//
//  CollabCalendarView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 2/12/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CollabCalendarView: UIView {

    let calendarHeaderLabel = UILabel()
    let previousMonthButton = UIButton(type: .system)
    let nextMonthButton = UIButton(type: .system)
    let dayStackView = UIStackView()
    
    let calendarView = JTAppleCalendarView()
    
    var collabStartTime: Date?
    var collabDeadline: Date?
    var blocks: [Block]? {
        didSet {
            
            calendarView.reloadData()
        }
    }
    
    var selectedDate: Date? {
        didSet {
            
            if let viewController = collabViewController as? CollabViewController, let date = selectedDate {
                
                viewController.formatter.dateFormat = "MMM yyyy"
                
                calendarHeaderLabel.text = viewController.formatter.string(from: date)
                
                calendarView.selectDates([date])
                calendarView.scrollToDate(date, animateScroll: false)
            }
        }
    }
    
    let calendar = Calendar.current
    
    weak var collabViewController: AnyObject?
    
    init (_ collabViewController: AnyObject, collabStartTime: Date?, collabDeadline: Date?){
        super.init(frame: .zero)
        
        self.collabViewController = collabViewController
        
        self.collabStartTime = collabStartTime
        self.collabDeadline = collabDeadline
        
        self.backgroundColor = UIColor(hexString: "222222")
        
        configureHeaderLabel()
        configureMonthButtons()
        configureDayStackView()
        
        configureCalendarView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configure Header Label
    
    private func configureHeaderLabel () {
        
        self.addSubview(calendarHeaderLabel)
        calendarHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            calendarHeaderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 34),
            calendarHeaderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -34),
            calendarHeaderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: topBarHeight + 10),
            calendarHeaderLabel.heightAnchor.constraint(equalToConstant: 30)
        
        ].forEach({ $0.isActive = true })
        
        calendarHeaderLabel.font = UIFont(name: "Poppins-SemiBold", size: 28)
        calendarHeaderLabel.textAlignment = .left
        calendarHeaderLabel.textColor = .white
    }
    
    
    //MARK: - Configure Month Buttons
    
    private func configureMonthButtons () {
        
        self.addSubview(previousMonthButton)
        previousMonthButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(nextMonthButton)
        nextMonthButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            previousMonthButton.trailingAnchor.constraint(equalTo: nextMonthButton.leadingAnchor, constant: -7.5),
            previousMonthButton.centerYAnchor.constraint(equalTo: calendarHeaderLabel.centerYAnchor, constant: 0),
            previousMonthButton.widthAnchor.constraint(equalToConstant: 30),
            previousMonthButton.heightAnchor.constraint(equalToConstant: 30),
            
            nextMonthButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
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
        
        self.addSubview(dayStackView)
        dayStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            dayStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            dayStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
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
        
        self.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            calendarView.topAnchor.constraint(equalTo: self.dayStackView.bottomAnchor, constant: 5),
            calendarView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
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
        
        calendarView.register(UINib(nibName: "DateCell", bundle: nil), forCellWithReuseIdentifier: "dateCell")
    }
    
    
    //MARK: - Animate Collab Navigation View Top Anchor
    
    private func animateCollabNavigationViewTopAnchor (_ date: Date?) {
        
        if let viewController = collabViewController as? CollabViewController, let date = date {
            
            viewController.formatter.dateFormat = "MMM yyyy"
            calendarHeaderLabel.text = viewController.formatter.string(from: date)

            if date.determineNumberOfWeeks() == 4 {

                viewController.collabNavigationViewTopAnchor?.constant = topBarHeight + 330
            }

            else {
                
                viewController.collabNavigationViewTopAnchor?.constant = topBarHeight + 376
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                
                viewController.view.layoutIfNeeded()
            }
        }
    }
    
    
    //MARK: - Previous Month Button Pressed
    
    @objc private func previousMonthButtonPressed () {
        
        let visibleDates = calendarView.visibleDates()
        let firstVisibleDate = visibleDates.monthDates.first
        
        if let viewController = collabViewController as? CollabViewController, let date = firstVisibleDate?.date, let previousMonth = calendar.date(byAdding: .month, value: -1, to: date), let startTime = collabStartTime {
            
            viewController.formatter.dateFormat = "yyyy MM"
            
            //If the previous month will be after or the same as the start month
            if viewController.formatter.date(from: viewController.formatter.string(from: previousMonth)) ?? Date() >= viewController.formatter.date(from: viewController.formatter.string(from: startTime)) ?? Date() {
                
                calendarView.scrollToDate(previousMonth)

                viewController.formatter.dateFormat = "MMM yyyy"
                calendarHeaderLabel.text = viewController.formatter.string(from: previousMonth)
                
                animateCollabNavigationViewTopAnchor(previousMonth)
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
        
        if let viewController = collabViewController as? CollabViewController, let date = firstVisibleDate?.date, let nextMonth = calendar.date(byAdding: .month, value: 1, to: date), let deadline = collabDeadline {
            
            viewController.formatter.dateFormat = "yyyy MM"
            
            //If the next month will be before or the same as the deadline month
            if viewController.formatter.date(from: viewController.formatter.string(from: nextMonth)) ?? Date() <= viewController.formatter.date(from: viewController.formatter.string(from: deadline)) ?? Date() {
                
                calendarView.scrollToDate(nextMonth)
                
                viewController.formatter.dateFormat = "MMM yyyy"
                calendarHeaderLabel.text = viewController.formatter.string(from: nextMonth)
                
                animateCollabNavigationViewTopAnchor(nextMonth)
            }
            
            else {
                
                let vibrateMethods = VibrateMethods()
                vibrateMethods.warningVibration()
            }
        }
    }
}


//MARK: - CalendarView Extension

extension CollabCalendarView: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        if let startTime = collabStartTime, let deadline = collabDeadline {
            
            return ConfigurationParameters(startDate: startTime, endDate: deadline, numberOfRows: 6, calendar: .current, generateInDates: .forAllMonths, generateOutDates: .tillEndOfGrid)
        }
        
        else {
            
            return ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 6, calendar: .current, generateInDates: .forAllMonths, generateOutDates: .tillEndOfGrid)
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
        if let startTime = collabStartTime, let deadline = collabDeadline, date.isBetween(startDate: startTime, endDate: deadline) {

            return true
        }
        
        else {
            
            if let viewController = collabViewController as? CollabViewController, let startTime = collabStartTime {

                let formatter = viewController.formatter
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
                            
                            //Must perform these steps here because the "didSelectDate" func won't allow for them to be completed because the "deadline" was
                            //selected programatically
                            if let viewController = collabViewController as? CollabViewController {
                                
                                //Scrolling to the last row
                                viewController.scrollToFirstBlock(indexPathToScrollTo: IndexPath(row: viewController.collabNavigationView.collabTableView.numberOfRows(inSection: 0) - 1, section: 0))
                                
                                viewController.collabNavigationView.calendarView.selectDates([deadline])
                                viewController.collabNavigationView.calendarView.scrollToDate(deadline)
                            }
                            
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
                    
                    //Must perform these steps here because the "didSelectDate" funt won't allow for them to be completed because the "startTime" was
                    //selected programatically
                    if let viewController = collabViewController as? CollabViewController {
                        
                        viewController.scrollToFirstBlock(indexPathToScrollTo: IndexPath(row: 0, section: 0))
                        
                        viewController.collabNavigationView.calendarView.selectDates([startTime])
                        viewController.collabNavigationView.calendarView.scrollToDate(startTime)
                    }
                    
                    return false
                }
            }
            
            //If for some reason the viewController or start time is nil
            else {
                
                let vibrateMethods = VibrateMethods()
                vibrateMethods.warningVibration()
                
                return false
            }
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        configureCell(view: cell, cellState: cellState)
        
        if let viewController = collabViewController as? CollabViewController, viewController.calendarPresented {
            
            let formatter = viewController.formatter
            formatter.dateFormat = "MMM yyyy"
            
            calendarHeaderLabel.text = viewController.formatter.string(from: date)
            
            if cellState.selectionType != .programatic {
                
                viewController.collabNavigationView.calendarView.selectDates([date])
                viewController.collabNavigationView.calendarView.scrollToDate(date)
                
                formatter.dateFormat = "yyyy MM dd"
                
                //Formats the collabStartTime so that only the date and not the time is used
                if let startTime = formatter.date(from: formatter.string(from: collabStartTime ?? Date())), let row = Calendar.current.dateComponents([.day], from: startTime, to: date).day {
                        
                    viewController.scrollToFirstBlock(indexPathToScrollTo: IndexPath(row: row, section: 0))
                }
            }
            
            else {
                
                if viewController.collabNavigationViewTopAnchor?.constant ?? 0 != 0 {
                    
                    animateCollabNavigationViewTopAnchor(date)
                }
            }
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        let segmentInfo = visibleDates.monthDates.first
        let visibleDate = segmentInfo?.date
        
        animateCollabNavigationViewTopAnchor(visibleDate)
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
        
        if let startTime = collabStartTime, let deadline = collabDeadline {
            
            if calendar.isDate(cellState.date, inSameDayAs: startTime) || calendar.isDate(cellState.date, inSameDayAs: deadline) {
                
                cell.dotView.isHidden = false
                
                cell.dotView.backgroundColor = calendar.isDate(cellState.date, inSameDayAs: startTime) ? UIColor(hexString: "5065A0")?.lighten(byPercentage: 0.1) : UIColor(hexString: "2ECC70")
                
                cell.dotView.layer.cornerRadius = 2.5
                cell.dotView.clipsToBounds = true
                
                cell.dotViewBottomAnchor.constant = cellState.isSelected ? 8.5 : 2.5
            }
                
            else if blocks?.contains(where: { calendar.isDate($0.starts!, inSameDayAs: cellState.date) }) ?? false {
                
                cell.dotView.isHidden = false
                
                cell.dotView.layer.cornerRadius = 2.5
                cell.dotView.clipsToBounds = true
                
                cell.dotView.backgroundColor = cellState.isSelected ? .black : .white
                cell.dotViewBottomAnchor.constant = cellState.isSelected ? 8.5 : 2.5
            }
            
            else {
                
                cell.dotView.isHidden = true
            }
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
