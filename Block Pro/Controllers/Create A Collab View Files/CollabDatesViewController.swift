//
//  CollabCalendarViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/14/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import JTAppleCalendar
import SVProgressHUD

protocol CollabDatesSelected: AnyObject {
    
    func datesSelected (startTime: Date, deadline: Date)
}

class CollabDatesViewController: UIViewController, JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var calendarContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var calendarHeader: UILabel!
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var calendarWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timeSelectorContainer: UIView!
    
    @IBOutlet weak var starts_deadlineLabel: UILabel!
    @IBOutlet weak var selectedTimeLabel: UILabel!
    
    @IBOutlet weak var timeSelectorCollectionView: UICollectionView!    
    @IBOutlet weak var selectedTimeIndicator: UIView!

    @IBOutlet weak var startsLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var deadlineLabelWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var segmentContainer: UIView!
    @IBOutlet weak var segmentBackground: UIView!
    @IBOutlet weak var selectedSegmentIndicator: UIView!
    @IBOutlet weak var segmentIndicatorLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var segmentIndicatorWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var startsButton: UIButton!
    @IBOutlet weak var startsButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var deadlineButton: UIButton!
    @IBOutlet weak var deadlineButtonWidthConstraint: NSLayoutConstraint!
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    
    var currentDate: Date = Date()
    
    var firstDate: Date?
    
    var twoDatesSelected: Bool {
        
        return firstDate != nil && calendarView.selectedDates.count > 1
    }
    
    var selectedStartTime: [String : Date] = [:]
    var selectedDeadline: [String : Date] = [:]
    
    weak var collabDatesSelectedDelegate: CollabDatesSelected?
    
    var viewInitiallyLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navBar.configureNavBar()
        
        configureView()

        configureCalendarView()

        configureCollectionView()
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !viewInitiallyLoaded {
            
            configureSegmentedControl()
            viewInitiallyLoaded = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        ProgressHUD.dismiss()
    }

    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = formatter.date(from: "2010 01 01")!
        let endDate = formatter.date(from: "2050 01 01")!
        
        let calendar = Calendar(identifier: .gregorian)
        
        return ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 6, calendar: calendar, generateInDates: .forAllMonths, generateOutDates: .tillEndOfGrid)
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
        
        if firstDate != nil {

            calendar.selectDates(from: self.firstDate!, to: date, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
            selectedDeadline["deadlineDate"] = date
            setDeadlineButtonText()
        }
        
        else {
            
            firstDate = date
            selectedStartTime["startDate"] = date
            setStartButtonText()
        }
        
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        
        if calendar.selectedDates.count > 0 {
            
            if twoDatesSelected && cellState.selectionType != .programatic || firstDate != nil && date < calendar.selectedDates[0] {
                
                let returnValue = !calendarView.selectedDates.contains(date)
                
                firstDate = nil
                calendarView.deselectAllDates()
                
                return returnValue
            }
        }
        
        return true
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {

        if twoDatesSelected && cellState.selectionType != .programatic {
            
            firstDate = nil
            calendarView.deselectAllDates()
            
            return false
        }
        
        firstDate = nil
        
        selectedStartTime["startDate"] = nil
        selectedDeadline["deadlineDate"] = nil
        
        startsButton.setTitle("Starts", for: .normal)
        deadlineButton.setTitle("Deadline", for: .normal)
        
        return true
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        let segmentInfo = visibleDates.monthDates.first
        let visibleDate = segmentInfo?.date
        
        formatter.dateFormat = "MMM yyyy"
        calendarHeader.text = formatter.string(from: visibleDate!)
    }
    
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        
        guard let cell = view as? DateCell else { return }
        
            cell.dateLabel.text = cellState.text
            handleCellTextColor(cell: cell, cellState: cellState)
            handleCellSelected(cell: cell, cellState: cellState)
    }
    
    func handleCellTextColor (cell: DateCell, cellState: CellState) {
        
        if cellState.dateBelongsTo == .thisMonth {
            
            cell.isHidden = false
        }
        
        else {
            
            cell.isHidden = true
        }
    }
    
    func handleCellSelected (cell: DateCell, cellState: CellState) {
        
        cell.singleSelectionView.isHidden = !cellState.isSelected
        cell.rangeSelectionView.isHidden = !cellState.isSelected
        
        switch cellState.selectedPosition() {
            
        case .left:
            
            cell.dateLabel.textColor = .white
            
            cell.singleSelectionView.isHidden = false
            cell.singleSelectionView.layer.cornerRadius = 0.5 * cell.singleSelectionView.frame.width
            
            cell.rangeSelectionView.isHidden = false
            cell.rangeViewLeadingAnchor.constant = cell.singleSelectionView.frame.minX - 3
            cell.rangeViewTrailingAnchor.constant = 0
            cell.rangeSelectionView.layer.cornerRadius = 18.5
            cell.rangeSelectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            
        case .middle:
            
            cell.dateLabel.textColor = .black
            
            cell.singleSelectionView.isHidden = true
            
            cell.rangeViewLeadingAnchor.constant = 0
            cell.rangeViewTrailingAnchor.constant = 0
            cell.rangeSelectionView.isHidden = false
            cell.rangeSelectionView.layer.cornerRadius = 0
            
        case .right:
            
            cell.dateLabel.textColor = .white
            
            cell.singleSelectionView.isHidden = false
            cell.singleSelectionView.layer.cornerRadius = 0.5 * cell.singleSelectionView.frame.width
            
            cell.rangeSelectionView.isHidden = false
            cell.rangeViewLeadingAnchor.constant = 0
            cell.rangeViewTrailingAnchor.constant = (cell.frame.width - cell.singleSelectionView.frame.maxX) - 3
            cell.rangeSelectionView.layer.cornerRadius = 18.5
            cell.rangeSelectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            
        case .full:
            
            cell.dateLabel.textColor = .white

            cell.singleSelectionView.layer.cornerRadius = 0.5 * cell.singleSelectionView.frame.width
            cell.singleSelectionView.isHidden = false
            
            cell.rangeSelectionView.isHidden = true
            
        case .none:
            
            cell.dateLabel.textColor = .black
        }
    }
    
    private func configureView () {
        
//        if UIScreen.main.bounds.width == 320.0 {
//            
//            calendarContainerHeightConstraint.constant -= 40
//        }
    }
    
    private func configureCalendarView () {
        
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        
        calendarView.isPagingEnabled = true
        calendarView.showsHorizontalScrollIndicator = false
        calendarView.scrollingMode =  .stopAtEachCalendarFrame
        calendarView.scrollDirection = .horizontal
        
        calendarView.allowsMultipleSelection = true
        calendarView.isRangeSelectionUsed = true
        
        calendarWidthConstraint.constant = view.frame.width -  view.frame.width.truncatingRemainder(dividingBy: 7)
        calendarView.cellSize = calendarWidthConstraint.constant / 7
        
        if selectedStartTime["startDate"] == nil && selectedDeadline["deadlineDate"] == nil {
            
            calendarView.scrollToDate(currentDate, animateScroll: false)
            calendarView.selectDates(from: currentDate, to: calendar.date(byAdding: .day, value: 1, to: currentDate)!)
            
            firstDate = currentDate; #warning("careful future nimat")
            
            formatter.dateFormat = "MMM yyyy"
            calendarHeader.text = formatter.string(from: currentDate)
            
            selectedStartTime["startDate"] = currentDate
            selectedDeadline["deadlineDate"] = calendar.date(byAdding: .day, value: 1, to: currentDate)
            
            formatter.dateFormat = "HH:mm"
            selectedStartTime["startTime"] = formatter.date(from: "0:00")
            selectedDeadline["deadlineTime"] = formatter.date(from: "17:00")
        }
        
        else if selectedStartTime["startDate"] != nil && selectedDeadline["deadlineDate"] != nil {
            
            calendarView.scrollToDate(selectedStartTime["startDate"]!, animateScroll: false)
            calendarView.selectDates(from: selectedStartTime["startDate"]!, to: selectedDeadline["deadlineDate"]!, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
            
            firstDate = selectedStartTime["startDate"]!; #warning("careful future nimat")
            
            formatter.dateFormat = "MMM yyyy"
            calendarHeader.text = formatter.string(from: selectedStartTime["startDate"]!)
        }
    }
    
    private func configureSegmentedControl () {
        
        startsLabelWidthConstraint.constant = segmentContainer.frame.width / 2
        deadlineLabelWidthConstraint.constant = segmentContainer.frame.width / 2
        
        segmentContainer.layer.cornerRadius = 10
        segmentContainer.clipsToBounds = true
        
        segmentBackground.layer.cornerRadius = 10
        segmentBackground.clipsToBounds = true
        
        segmentIndicatorWidthConstraint.constant = segmentContainer.frame.width / 2
        selectedSegmentIndicator.layer.cornerRadius = 10
        selectedSegmentIndicator.clipsToBounds = true
        
        startsButton.titleLabel?.textAlignment = .center
        setStartButtonText()
        
        startsButtonWidthConstraint.constant = segmentContainer.frame.width / 2
        startsButton.layer.cornerRadius = 10
        startsButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        startsButton.clipsToBounds = true
        
        deadlineButton.titleLabel?.textAlignment = .center
        setDeadlineButtonText()
        
        deadlineButtonWidthConstraint.constant = segmentContainer.frame.width / 2
        deadlineButton.layer.cornerRadius = 10
        deadlineButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        deadlineButton.clipsToBounds = true
    }
    
    internal func setStartButtonText () {
        
        if let date = selectedStartTime["startDate"] {
            
            let suffix = date.daySuffix()
            var dateString: String = ""

            formatter.dateFormat = "MMM d"
            dateString = formatter.string(from: date)
            dateString += suffix

            formatter.dateFormat = ", yyyy"
            dateString += formatter.string(from: date)
            
            formatter.dateFormat = "h:mm a"
            dateString += " \n at \(formatter.string(from: selectedStartTime["startTime"]!))"

            startsButton.setTitle(dateString, for: .normal)
        }
        
        else {
            
            startsButton.setTitle("Starts", for: .normal)
        }
    }
    
    internal func setDeadlineButtonText () {
        
        if let date = selectedDeadline["deadlineDate"] {
            
            let suffix = date.daySuffix()
            var dateString: String = ""
            
            formatter.dateFormat = "MMM d"
            dateString = formatter.string(from: date)
            dateString += suffix

            formatter.dateFormat = ", yyyy"
            dateString += formatter.string(from: date)
            
            formatter.dateFormat = "h:mm a"
            dateString += " \n at \(formatter.string(from: selectedDeadline["deadlineTime"]!))"
            
            deadlineButton.setTitle(dateString, for: .normal)
        }
        
        else {
            
            deadlineButton.setTitle("Deadline", for: .normal)
        }
    }
    
    private func presentErrorAlert (startError: Bool) {
        
        let errorAlert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        errorAlert.view.tintColor = .black
        
        let messageAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .bold), NSAttributedString.Key.foregroundColor : UIColor.systemRed]
        let messageString: NSAttributedString?
            
        if startError {
            
            messageString = NSAttributedString(string: "Please enter a Start Time", attributes: messageAttributes as [NSAttributedString.Key : Any])
            errorAlert.setValue(messageString, forKey: "attributedMessage")
        }
        
        else {
            
            messageString = NSAttributedString(string: "Please enter a Deadline", attributes: messageAttributes as [NSAttributedString.Key : Any])
            errorAlert.setValue(messageString, forKey: "attributedMessage")
        }
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (okAction) in
            
            errorAlert.dismiss(animated: true) {
                
                if startError {
                    
                    self.animateSegmentedControl(starts: true)
                }
                
                else {
                    
                    self.animateSegmentedControl(starts: false)
                }
            }
        }
        
        errorAlert.addAction(okAction)
        
        present(errorAlert, animated: true, completion: nil)
    }
    
    private func animateSegmentedControl (starts: Bool) {
        
        if starts {
            
            segmentIndicatorLeadingAnchor.constant = 0
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                
                self.view.layoutIfNeeded()
                
                self.deadlineButton.setTitleColor(.black, for: .normal)
                self.startsButton.setTitleColor(.white, for: .normal)
                
            }) { (finished: Bool) in
                
                self.starts_deadlineLabel.text = "Starts"
                self.calcSelectedIndex(start: true)
            }
        }
        
        else {
            
            segmentIndicatorLeadingAnchor.constant = segmentContainer.frame.width / 2
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                
                self.view.layoutIfNeeded()
                
                self.deadlineButton.setTitleColor(.white, for: .normal)
                self.startsButton.setTitleColor(.black, for: .normal)
                
            }) { (finished: Bool) in
                
                self.starts_deadlineLabel.text = "Deadline"
                self.calcSelectedIndex(start: false)
            }
        }
    }
    
    @IBAction func exitButton(_ sender: Any) {
        
        dismiss(animated: true) {
            
        }
    }
    
    @IBAction func doneButton(_ sender: Any) {
        
        if selectedStartTime["startDate"] == nil {
            
            presentErrorAlert(startError: true)
        }
        
        else if selectedDeadline["deadlineDate"] == nil {
            
            presentErrorAlert(startError: false)
        }
        
        else {
            
            formatter.dateFormat = "MMMM dd yyyy"
            let startDate: String = formatter.string(from: selectedStartTime["startDate"]!)
            let deadlineDate: String = formatter.string(from: selectedDeadline["deadlineDate"]!)
            
            formatter.dateFormat = "HH:mm"
            let startTime: String = formatter.string(from: selectedStartTime["startTime"]!)
            let deadlineTime: String = formatter.string(from: selectedDeadline["deadlineTime"]!)
            
            formatter.dateFormat = "MMMM dd yyyy HH:mm"
            let starts: Date = formatter.date(from: startDate + " " + startTime)!
            let deadline: Date = formatter.date(from: deadlineDate + " " + deadlineTime)!
            
            collabDatesSelectedDelegate?.datesSelected(startTime: starts, deadline: deadline)
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func previousMonth(_ sender: Any) {
        
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        
        calendarView.scrollToDate(currentDate)
        
        formatter.dateFormat = "MMM yyyy"
        calendarHeader.text = formatter.string(from: currentDate)
    }
    
    
    @IBAction func nextMonth(_ sender: Any) {
        
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
        
        calendarView.scrollToDate(currentDate)
        
        formatter.dateFormat = "MMM yyyy"
        calendarHeader.text = formatter.string(from: currentDate)
    }
    
    @IBAction func startsButton(_ sender: Any) {
        
        animateSegmentedControl(starts: true)
    }
    
    @IBAction func deadlineButton(_ sender: Any) {
        
        animateSegmentedControl(starts: false)
    }
}
