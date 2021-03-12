//
//  HomeHeaderView.swift
//  Block Pro
//
//  Created by Nimat Azeez on 3/8/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import JTAppleCalendar

class HomeHeaderView: UIView {

    let profilePicture = ProfilePicture()
    lazy var profilePictureProgressView = iProgressView(self, 100, .circleStrokeSpin)
    let welcomeLabel = UILabel()
    
    let calendarHeaderLabel = UILabel()
    let calendarView = JTAppleCalendarView()
    
    let scheduleCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    let currentUser = CurrentUser.sharedInstance
    
    let firebaseStorage = FirebaseStorage()
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    
    lazy var selectedDate = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: Date()))!
    
    var showProfilePictureLoadingProgress: Bool = false
    
//    var previousContentOffsetXCoord: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.clipsToBounds = true
        
        configureProfilePicture()
        configureProfilePictureProgressView()
        configureWelcomeLabel()
        
        configureCalendarHeader()
        configureCalendarView()
        
        configureCollectionView(scheduleCollectionView)
//
//        self.backgroundColor = UIColor.blue.withAlphaComponent(0.25)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureProfilePicture () {
        
        self.addSubview(profilePicture)
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            profilePicture.topAnchor.constraint(equalTo: self.topAnchor, constant: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 40),
            profilePicture.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            profilePicture.widthAnchor.constraint(equalToConstant: 60),
            profilePicture.heightAnchor.constraint(equalToConstant: 60)
            
        ].forEach({ $0.isActive = true })
        
        retrieveProfilePicture()
    }
    
    private func configureProfilePictureProgressView () {
        
        self.addSubview(profilePictureProgressView)
        profilePictureProgressView.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            profilePictureProgressView.topAnchor.constraint(equalTo: self.topAnchor, constant: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 60 : 40),
            profilePictureProgressView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            profilePictureProgressView.widthAnchor.constraint(equalToConstant: 62.5),
            profilePictureProgressView.heightAnchor.constraint(equalToConstant: 62.5)
            
        ].forEach({ $0.isActive = true })
        
        profilePictureProgressView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        profilePictureProgressView.layer.cornerRadius = 30
        profilePictureProgressView.clipsToBounds = true
    }
    
    private func configureWelcomeLabel () {
        
        self.addSubview(welcomeLabel)
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            welcomeLabel.leadingAnchor.constraint(equalTo: profilePicture.trailingAnchor, constant: 25),
            welcomeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
            welcomeLabel.centerYAnchor.constraint(equalTo: profilePicture.centerYAnchor),
            welcomeLabel.heightAnchor.constraint(equalToConstant: 60/*35*/)
        
        ].forEach({ $0.isActive = true })
        
        welcomeLabel.font = UIFont(name: "Poppins-SemiBold", size: 20)
        welcomeLabel.textColor = .black
        welcomeLabel.textAlignment = .left
        welcomeLabel.numberOfLines = 2
//        welcomeLabel.adjustsFontSizeToFitWidth = true
        
        setWelcomeLabelText()
    }
    
    private func configureCalendarHeader () {
        
        self.addSubview(calendarHeaderLabel)
        calendarHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            calendarHeaderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
            calendarHeaderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            calendarHeaderLabel.topAnchor.constraint(equalTo: profilePicture.bottomAnchor, constant: 25),
            calendarHeaderLabel.heightAnchor.constraint(equalToConstant: 30)
            
        ].forEach({ $0.isActive = true })
        
        calendarHeaderLabel.font = UIFont(name: "Poppins-Medium", size: 20)
        calendarHeaderLabel.textColor = .black
        calendarHeaderLabel.textAlignment = .left
    }
    
    //MARK: - Configure Calendar View
    
    private func configureCalendarView () {

        self.addSubview(calendarView)
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

        formatter.dateFormat = "MMMM yyyy"

        calendarHeaderLabel.text = formatter.string(from: selectedDate)

        calendarView.scrollToDate(selectedDate, animateScroll: false)
        calendarView.selectDates([selectedDate])
    }
    
    private func configureCollectionView (_ collectionView: UICollectionView) {
        
        self.addSubview(scheduleCollectionView)
        scheduleCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            scheduleCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            scheduleCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            scheduleCollectionView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 20),
            scheduleCollectionView.heightAnchor.constraint(equalToConstant: 120)
        
        ].forEach({ $0.isActive = true })
        
        scheduleCollectionView.dataSource = self
        scheduleCollectionView.delegate = self
        
        scheduleCollectionView.backgroundColor = .clear
        
        scheduleCollectionView.isPagingEnabled = true
        scheduleCollectionView.showsHorizontalScrollIndicator = false
        scheduleCollectionView.delaysContentTouches = false
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 120)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        scheduleCollectionView.collectionViewLayout = layout
        
        scheduleCollectionView.register(ScheduleCollectionViewCell.self, forCellWithReuseIdentifier: "scheduleCollectionViewCell")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            self.formatter.dateFormat = "yyyy MM dd"
            
            let differenceInDates = self.calendar.dateComponents([.day], from: self.formatter.date(from: "2010 01 01") ?? Date(), to: self.selectedDate).day

            self.scheduleCollectionView.scrollToItem(at: IndexPath(item: differenceInDates ?? 0, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    private func retrieveProfilePicture (animate: Bool = true) {
        
        showProfilePictureLoadingProgress = true
        
        firebaseStorage.retrieveUserProfilePicFromStorage(userID: currentUser.userID) { [weak self] (profilePicture, _) in
            
            if self != nil {
                
                UIView.transition(with: self!.profilePicture, duration: 0.3, options: .transitionCrossDissolve) {
                    
                    self?.profilePicture.profilePic = profilePicture
                }
                
                UIView.animate(withDuration: 0.3) {
                    
                    self?.profilePictureProgressView.backgroundColor = .clear
                }
            }
            
            self?.profilePictureProgressView.dismissProgress()
            self?.showProfilePictureLoadingProgress = false
        }
    }
    
    private func setWelcomeLabelText () {
        
        formatter.dateFormat = "h:mm a"
        
        if let currentDate = formatter.date(from: formatter.string(from: Date())) {
            
            if currentDate.isBetween(startDate: formatter.date(from: "5:00 AM") ?? Date(), endDate: formatter.date(from: "12:00 PM") ?? Date()) {
                
                welcomeLabel.text = "Good Morning, \(currentUser.firstName)"
            }
            
            else if currentDate.isBetween(startDate: formatter.date(from: "12:00 PM") ?? Date(), endDate: formatter.date(from: "5:00 PM") ?? Date()) {
                
                welcomeLabel.text = "Good Afternoon, \(currentUser.firstName)"
            }
            
            else if currentDate.isBetween(startDate: formatter.date(from: "5:00 PM") ?? Date(), endDate: formatter.date(from: "9:00 PM") ?? Date()) {
                
                welcomeLabel.text = "Good Evening, \(currentUser.firstName)"
            }
            
            else {
                
                welcomeLabel.text = "Welcome \(currentUser.firstName)"
            }
        }
        
        else {
    
            welcomeLabel.text = "Welcome \(currentUser.firstName)"
        }
    }
}

extension HomeHeaderView: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        
        return ConfigurationParameters(startDate: formatter.date(from: "2010 01 01") ?? Date(), endDate: formatter.date(from: "2050 01 01") ?? Date() , numberOfRows: 1, calendar: Calendar(identifier: .gregorian), generateInDates: .forFirstMonthOnly, generateOutDates: .off, firstDayOfWeek: .sunday, hasStrictBoundaries: false)
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
        
        if cellState.selectionType != .programatic {
            
            selectedDate = cellState.date
            
            formatter.dateFormat = "yyyy MM dd"
            
            let differenceInDates = self.calendar.dateComponents([.day], from: formatter.date(from: "2010 01 01") ?? Date(), to: selectedDate).day
            
            scheduleCollectionView.scrollToItem(at: IndexPath(item: differenceInDates ?? 0, section: 0), at: .centeredHorizontally, animated: true)
        }
        
        else {
            
            formatter.dateFormat = "MMMM yyyy"
            calendarHeaderLabel.text = formatter.string(from: date)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        //Sets the headerLabel text
        let segmentInfo = visibleDates.monthDates.first
    
        if let visibleDate = segmentInfo?.date {
            
            formatter.dateFormat = "MMMM yyyy"
            calendarHeaderLabel.text = formatter.string(from: visibleDate)
        }
    }
    
    //MARK: - Configure Calendar Cell
    
    private func configureCell(view: JTAppleCell?, cellState: CellState) {
        
        guard let cell = view as? DateCell else { return }
        
            cell.dateLabel.font = UIFont(name: "Poppins-SemiBold", size: 19)
            cell.dateLabel.text = cellState.text
            cell.rangeSelectionView.isHidden = true
        
//            handleCellDotView(cell: cell, cellState: cellState)
            handleCellSelection(cell: cell, cellState: cellState)
    }
    
    
    //MARK: - Handle Cell Selected
    
    private func handleCellSelection (cell: DateCell, cellState: CellState) {

        cell.singleSelectionView.isHidden = cellState.isSelected ? false : true
        cell.singleSelectionView.layer.cornerRadius = 0.5 * cell.singleSelectionView.frame.width
        
        cell.dateLabel.textColor = cellState.isSelected ? .white : UIColor(hexString: "222222")
        cell.dateLabel.font = UIFont(name: "Poppins-SemiBold", size: 19)
    }
}

extension HomeHeaderView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        formatter.dateFormat = "yyyy MM dd"
        
        return calendar.dateComponents([.day], from: formatter.date(from: "2010 01 01") ?? Date(), to: formatter.date(from: "2050 01 01") ?? Date()).day ??
            0//selectedDate.determineNumberOfDays()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "scheduleCollectionViewCell", for: indexPath) as! ScheduleCollectionViewCell
        
        formatter.dateFormat = "yyyy MM dd"
        
        if let dateForCell = calendar.date(byAdding: .day, value: indexPath.row, to: formatter.date(from: "2010 01 01") ?? Date()) {
            
            cell.formatter = formatter
            cell.dateForCell = dateForCell
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        formatter.dateFormat = "yyyy MM dd"
        
        if let adjustedDate = calendar.date(byAdding: .day, value: indexPath.row, to: formatter.date(from: "2010 01 01") ?? Date()), !calendar.isDate(adjustedDate, inSameDayAs: selectedDate), collectionView.isDragging {

            selectedDate = adjustedDate

            calendarView.selectDates([adjustedDate])
            calendarView.scrollToDate(adjustedDate)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            self.formatter.dateFormat = "yyyy MM dd"
            
            if let firstVisibleRow = self.scheduleCollectionView.indexPathsForVisibleItems.first?.row, let adjustedDate = self.calendar.date(byAdding: .day, value: firstVisibleRow, to: self.formatter.date(from: "2010 01 01") ?? Date()), !self.calendar.isDate(adjustedDate, inSameDayAs: self.selectedDate) {

                self.selectedDate = adjustedDate

                self.calendarView.selectDates([adjustedDate])
                self.calendarView.scrollToDate(adjustedDate)
            }
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//
//        formatter.dateFormat = "yyyy MM dd"
//
////        print(collectionView.isDragging)
//
//        if let firstVisibleRow = scheduleCollectionView.indexPathsForVisibleItems.first?.row, let adjustedDate = calendar.date(byAdding: .day, value: firstVisibleRow, to: formatter.date(from: "2010 01 01") ?? Date()), !calendar.isDate(adjustedDate, inSameDayAs: selectedDate), collectionView.isDragging {
//
//            selectedDate = adjustedDate
//
//            calendarView.selectDates([adjustedDate])
//            calendarView.scrollToDate(adjustedDate)
//        }
//    }
}
