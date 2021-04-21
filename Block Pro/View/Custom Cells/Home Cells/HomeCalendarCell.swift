//
//  HomeCalendarCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/14/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import JTAppleCalendar

class HomeCalendarCell: UITableViewCell {

    let calendarHeaderLabel = UILabel()
    let dayStackView = UIStackView()
    let calendarView = JTAppleCalendarView()
    
    let calendar = Calendar.current
    var formatter: DateFormatter?
    
    var dateForCell: Date? {
        didSet {
            
            if let date = dateForCell, let formatter = formatter {
                
                formatter.dateFormat = "MMMM yyyy"
                calendarHeaderLabel.text = formatter.string(from: date)
            }
        }
    }
    
    var selectedDate: Date?
    
    var deadlinesForCollabs: [Date]? {
        didSet {
            
            DispatchQueue.main.async {
                
                //Will reload the calendar with the correct date for this cell
                self.calendarView.reloadData(withanchor: nil) {

                    if let date = self.selectedDate {

                        self.calendarView.selectDates([date])
                    }
                }
            }
        }
    }
    
    weak var homeViewController: AnyObject?
    
    override init (style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "homeCalendarCell")
        
        configureCalendarHeaderLabel()
        configureDayStackView()
        configureCalendarView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Configure Calendar Header Label
    
    private func configureCalendarHeaderLabel () {
        
        self.contentView.addSubview(calendarHeaderLabel)
        calendarHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            calendarHeaderLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            calendarHeaderLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor, constant: 0),
            calendarHeaderLabel.widthAnchor.constraint(equalToConstant: 200),
            calendarHeaderLabel.heightAnchor.constraint(equalToConstant: 35)
        
        ].forEach({ $0.isActive = true })
        
        calendarHeaderLabel.font = UIFont(name: "Poppins-SemiBoldItalic", size: 21)
        calendarHeaderLabel.textColor = .black
        calendarHeaderLabel.textAlignment = .center
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

        calendarView.backgroundColor = .clear

        calendarView.register(UINib(nibName: "DateCell", bundle: nil), forCellWithReuseIdentifier: "dateCell")

        //Removes white lines for the cells that appear
        calendarView.cellSize = (UIScreen.main.bounds.width - UIScreen.main.bounds.width.truncatingRemainder(dividingBy: 7)) / 7
    }
}


//MARK: - CalendarView Extension
extension HomeCalendarCell: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        if let startDate = dateForCell {
            
            return ConfigurationParameters(startDate: startDate, endDate: startDate.endOfMonth, numberOfRows: 6, calendar: Calendar(identifier: .gregorian), generateInDates: .forAllMonths, generateOutDates: .tillEndOfGrid)
        }
        
        else {
            
            return ConfigurationParameters(startDate: Date(), endDate: Date(), numberOfRows: 6, calendar: Calendar(identifier: .gregorian), generateInDates: .forAllMonths, generateOutDates: .tillEndOfGrid)
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
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        configureCell(view: cell, cellState: cellState)
        
        if let viewController = homeViewController as? HomeViewController, cellState.selectionType != .programatic {
            
            selectedDate = date
            
            viewController.selectedDate = date
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        configureCell(view: cell, cellState: cellState)
        
    }
    
    
    //MARK: - Configure Calendar Cell
    
    private func configureCell(view: JTAppleCell?, cellState: CellState) {
        
        guard let cell = view as? DateCell else { return }
        
            cell.dateLabel.text = cellState.text
        
            handleCellVisibility(cell: cell, cellState: cellState)
            handleCellDotView(cell: cell, cellState: cellState)
            handleCellSelection(cell: cell, cellState: cellState)
            handleCellText(cell: cell, cellState: cellState)
    }
    
    
    //MARK: - Handle Cell Visibility
    
    private func handleCellVisibility (cell: DateCell, cellState: CellState) {
        
        if cellState.dateBelongsTo == .thisMonth {
            
            cell.isHidden = false
        }
        
        else {
            
            cell.isHidden = true
        }
    }
    
    
    //MARK: Handle Cell Dot View

    private func handleCellDotView (cell: DateCell, cellState: CellState) {

        if deadlinesForCollabs?.first(where: { calendar.isDate(cellState.date, inSameDayAs: $0) }) != nil {
            
            cell.dotView.isHidden = false

            cell.dotView.backgroundColor = cellState.isSelected ? .white : .black

            cell.dotView.layer.cornerRadius = 2.5
            cell.dotView.clipsToBounds = true

            cell.dotViewBottomAnchor.constant = cellState.isSelected ? 8.5 : 2.5
        }
        
        else {
            
            cell.dotView.isHidden = true
        }
    }
    
    
    //MARK: - Handle Cell Selected
    
    private func handleCellSelection (cell: DateCell, cellState: CellState) {
        
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
    
    
    //MARK: - Handle Cell Text
    
    private func handleCellText (cell: DateCell, cellState: CellState) {
        
        //If this is the cell for the currentDate
        if calendar.isDate(cellState.date, inSameDayAs: Date()) {
            
            cell.dateLabel.font = UIFont(name: "Poppins-SemiBold", size: 19)
            cell.dateLabel.textColor = UIColor.systemRed.flatten().lighten(byPercentage: 0.1)
        }
        
        else {
            
            cell.dateLabel.font = cellState.isSelected ? UIFont(name: "Poppins-SemiBold", size: 19) : UIFont(name: "Poppins-Medium", size: 19)
            cell.dateLabel.textColor = cellState.isSelected ? .white : UIColor(hexString: "222222")
        }
    }
}
