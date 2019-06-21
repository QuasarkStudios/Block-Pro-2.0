//
//  CalendarViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/19/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController, JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        
        calendarView.scrollDirection = .horizontal
        // Do any additional setup after loading the view.
    }
    
    //First required delegate for "JTAppleCalendarViewDataSource" protocol
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = formatter.date(from: "2019 05 17")!
        let endDate = Date()
        
        let calendar = Calendar(identifier: .gregorian)
        
        calendarView.scrollingMode = .stopAtEachCalendarFrame
        
        return ConfigurationParameters(startDate: startDate, endDate: endDate, calendar: calendar, generateInDates: .forAllMonths, generateOutDates: .tillEndOfGrid)
        
        //return ConfigurationParameters(startDate: startDate, endDate: endDate) //These are the only two mandatory parameters for this function but you can asdd more for additional customization
    }
    
    //Two required delegate functions for "JTAppleCalendarViewDelegate"; should share the same exact code except the dequeuing code in the first function
/**********************************************************************************************************************************************************/

    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        let myDateFormatter = DateFormatter()
        myDateFormatter.locale = Locale(identifier: "en_US")
        myDateFormatter.dateFormat = "dd"
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)

        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
        configureCell(view: cell, cellState: cellState)
    }
    
/**********************************************************************************************************************************************************/
    
    
    //Function that configures the cell 
    func configureCell (view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? DateCell else { return }
            cell.dateLabel.text = cellState.text
            handleCellTextColor(cell: cell, cellState: cellState)
            handleCellSelected(cell: cell, cellState: cellState)
    }
    
    //Function that handles the color of the text of a cell depending on if it belongs to the current month or not
    func handleCellTextColor(cell: DateCell, cellState: CellState) {
        
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.textColor = UIColor.black
        }
        
        else {
            cell.dateLabel.textColor = UIColor.gray
        }
    }
    
    func handleCellSelected (cell: DateCell, cellState: CellState) {
        
        if cellState.isSelected == true {
            cell.selectedView.layer.cornerRadius = 13
            cell.selectedView.alpha = 0.5
            cell.selectedView.isHidden = !cell.selectedView.isHidden
        }
        
        else {
            cell.selectedView.isHidden = true
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
//Two functions that handle if a certain cell should be selected or deselcted
/*****************************************************************************************************************************************
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        return true
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        return false
    }
 *****************************************************************************************************************************************/
    
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "DateHeader", for: indexPath) as! DateHeader
        header.monthLabel.text = formatter.string(from: range.start)
        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return MonthSize(defaultSize: 50)
    }
    
}
