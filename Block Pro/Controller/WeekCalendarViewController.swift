//
//  WeekCalendarViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/21/19.
//  Copyright © 2019 Nimat Azeez. All rights reserved.
//

import UIKit
import JTAppleCalendar

class WeekCalendarViewController: UIViewController, JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {

    
    @IBOutlet weak var weekCalendarView: JTAppleCalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        weekCalendarView.calendarDelegate = self
        weekCalendarView.calendarDataSource = self
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = formatter.date(from: "2019 05 17")!
        let endDate = Date()
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 1, generateInDates: .forFirstMonthOnly, generateOutDates: .off, hasStrictBoundaries: false)
        
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath)
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
        configureCell(view: cell, cellState: cellState)
    }
    
    //Function that configures the cell
    func configureCell (view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? DateCell else { return }
        cell.dateLabel.text = cellState.text
//        handleCellTextColor(cell: cell, cellState: cellState)
//        handleCellSelected(cell: cell, cellState: cellState)
    }
}
