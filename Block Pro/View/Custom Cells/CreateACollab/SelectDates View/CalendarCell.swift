//
//  CalendarCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/20/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import JTAppleCalendar
import SVProgressHUD

protocol CalendarCellProtocol: AnyObject {
    
    func datesSelected (startDate: Date?, deadlineDate: Date?)
    
    func configureTableViewHeight (shrink: Bool)
}

class CalendarCell: UITableViewCell, JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {

    @IBOutlet weak var calendarHeader: UILabel!
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var calendarViewWidthConstraint: NSLayoutConstraint!
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    
    var currentDate: Date = Date()
    
    var firstDate: Date?
    
    var twoDatesSelected: Bool {
        
        return firstDate != nil && calendarView.selectedDates.count > 1
    }
    
    var selectedStartDate: Date?
    var selectedDeadlineDate: Date?
    
    weak var calendarCellDelegate: CalendarCellProtocol?
    
    var cellInitiallyLoaded: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        calendarView.register(UINib(nibName: "DateCell", bundle: nil), forCellWithReuseIdentifier: "dateCell")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutSubviews()
        
        if !cellInitiallyLoaded {
                
            configureCalendarView()
            cellInitiallyLoaded = true
        }
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

            formatter.dateFormat = "MM yyyy"
            
            //If the the selected dates span two different months; likely this will be a lengthy operation so present a Progress Indicator
            if formatter.string(from: firstDate!) != formatter.string(from: calendar.selectedDates.last!) {
            
                displayProgressIndicator {
                    
                    calendar.selectDates(from: self.firstDate!, to: date, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
                    self.selectedDeadlineDate = date
                    
                    self.calendarCellDelegate?.datesSelected(startDate: self.firstDate!, deadlineDate: date)
                }
            }
            
            else {
            
                calendar.selectDates(from: firstDate!, to: date, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
                selectedDeadlineDate = date
                
                calendarCellDelegate?.datesSelected(startDate: firstDate!, deadlineDate: date)
            }
        }
        
        else {
            
            firstDate = date
            calendarCellDelegate?.datesSelected(startDate: firstDate!, deadlineDate: nil)
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
            
            calendarCellDelegate?.datesSelected(startDate: nil, deadlineDate: nil)
            
            return false
        }
        
        firstDate = nil
        
        selectedStartDate = nil
        selectedDeadlineDate = nil
        
        calendarCellDelegate?.datesSelected(startDate: nil, deadlineDate: nil)
        
        return true
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        let segmentInfo = visibleDates.monthDates.first
        let visibleDate = segmentInfo?.date
        
        formatter.dateFormat = "MMM yyyy"
        calendarHeader.text = formatter.string(from: visibleDate!)
        
        currentDate = visibleDate!
        
        if currentDate.determineNumberOfWeeks() == 4 {
            
            calendarCellDelegate?.configureTableViewHeight(shrink: true)
        }
        
        else {
            
            calendarCellDelegate?.configureTableViewHeight(shrink: false)
        }
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
            cell.rangeSelectionView.layer.cornerRadius = 21.5
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
            cell.rangeSelectionView.layer.cornerRadius = 21.5
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
    
    private func configureCalendarView () {
        
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        
        calendarView.isPagingEnabled = true
        calendarView.showsVerticalScrollIndicator = false
        calendarView.showsHorizontalScrollIndicator = false
        calendarView.scrollingMode = .stopAtEachCalendarFrame
        calendarView.scrollDirection = .horizontal
        
        calendarView.allowsMultipleSelection = true
        calendarView.isRangeSelectionUsed = true
        
        //Removes white lines for the cells that appear
        calendarViewWidthConstraint.constant = contentView.frame.width - contentView.frame.width.truncatingRemainder(dividingBy: 7)
        calendarView.cellSize = calendarViewWidthConstraint.constant / 7

        formatter.dateFormat = "MM yyyy"
        
        //If statement fixes bug that would cause the range selection view's leading and trailing constraints to be off upon first view load 
        if formatter.string(from: selectedStartDate!) != formatter.string(from: selectedDeadlineDate!) {
            
            calendarView.scrollToDate(selectedStartDate!, animateScroll: false)
            calendarView.selectDates(from: selectedStartDate!, to: selectedDeadlineDate!, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
        }
        
        else {
            
            calendarView.scrollToDate(selectedStartDate!, animateScroll: false)
            calendarView.selectDates(from: selectedStartDate!, to: selectedDeadlineDate!, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
            calendarView.deselectAllDates(triggerSelectionDelegate: false)
            calendarView.selectDates(from: selectedStartDate!, to: selectedDeadlineDate!, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
        }

        firstDate = selectedStartDate!

        formatter.dateFormat = "MMM yyyy"
        calendarHeader.text = formatter.string(from: selectedStartDate!)
    }
    
    private func displayProgressIndicator (completion: @escaping (() -> Void)) {
        
        SVProgressHUD.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            completion()
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
}
