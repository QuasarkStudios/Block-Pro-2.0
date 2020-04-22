//
//  CollabDates2ViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/20/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol CollabDatesSelected: AnyObject {
    
    func datesSelected (startTime: Date, deadline: Date)
}

class CollabDates2ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var datesTableView: UITableView!
    
    let formatter = DateFormatter()
    let currentDate = Date()
    
    var selectedStartTime: [String : Date] = [:]
    var selectedDeadline: [String : Date] = [:]
    
    var calendarCellRowHeight: CGFloat = 370
    
    weak var collabDatesSelectedDelegate: CollabDatesSelected?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navBar.configureNavBar()
        
        configureTableView()
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        SVProgressHUD.dismiss()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath) as! CalendarCell
            cell.selectionStyle = .none
            cell.calendarCellDelegate = self
            
            if let startDate = selectedStartTime["startDate"], let deadlineDate = selectedDeadline["deadlineDate"] {
                
                cell.selectedStartDate = startDate
                cell.selectedDeadlineDate = deadlineDate
                
                if startDate.determineNumberOfWeeks() == 4 {
                    
                    configureTableViewHeight(shrink: true)
                }
                
                else {
                    
                    configureTableViewHeight(shrink: false)
                }
            }
            
            else {
                
                cell.selectedStartDate = currentDate
                cell.selectedDeadlineDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)
                
                if currentDate.determineNumberOfWeeks() == 4 {
                    
                    configureTableViewHeight(shrink: true)
                }
                
                else {
                    
                    configureTableViewHeight(shrink: false)
                }
            }

            return cell
        }
        
        else if indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeSelectorCell", for: indexPath) as! TimeSelectorCell
            cell.selectionStyle = .none
            cell.timeSelectorCellDelegate = self
            
            if let startTime = selectedStartTime["startTime"], let deadlineTime = selectedDeadline["deadlineTime"] {
                
                cell.selectedStartTime = startTime
                cell.selectedDeadlineTime = deadlineTime
            }
            
            else {
                
                formatter.dateFormat = "HH:mm"
                cell.selectedStartTime = formatter.date(from: "0:00")
                cell.selectedDeadlineTime = formatter.date(from: "17:00")
            }
            
            cell.calcSelectedIndex(start: true)
            cell.cellInitiallyLoaded = true
            
            return cell
        }
        
        else if indexPath.row == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "segmentCell", for: indexPath) as! SegmentCell
            cell.selectionStyle = .none
            cell.segmentCellDelegate = self

            cell.selectedStart = selectedStartTime
            cell.selectedDeadline = selectedDeadline
            
            cell.setStartButtonText()
            cell.setDeadlineButtonText()
            
            return cell
        }
        
        else {
            
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            
            return calendarCellRowHeight
        }
        
        else if indexPath.row == 1 {
            
            return 155
        }
        
        else if indexPath.row == 2 {
            
            return 110
        }
        
        else {
            
            return 20
        }
    }
    
    private func configureTableView () {
        
        datesTableView.dataSource = self
        datesTableView.delegate = self
        
        datesTableView.showsVerticalScrollIndicator = false
        datesTableView.separatorStyle = .none
        
        datesTableView.register(UINib(nibName: "CalendarCell", bundle: nil), forCellReuseIdentifier: "calendarCell")
        datesTableView.register(UINib(nibName: "TimeSelectorCell", bundle: nil), forCellReuseIdentifier: "timeSelectorCell")
        datesTableView.register(UINib(nibName: "SegmentCell", bundle: nil), forCellReuseIdentifier: "segmentCell")
        
        //iPhone 11 Pro Max & iPhone 11
        if UIScreen.main.bounds.width == 414.0 && UIScreen.main.bounds.height == 896.0 {
            datesTableView.isScrollEnabled = false
        }
            
        //iPhone 11 Pro
        else if UIScreen.main.bounds.width == 375.0 && UIScreen.main.bounds.height == 812.0 {
            datesTableView.isScrollEnabled = false
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
                
                guard let cell = self.datesTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? SegmentCell else { return }
                
                    if startError {
                        
                        cell.animateSegmentedControl(starts: true)
                    }
                    
                    else {
                        
                        cell.animateSegmentedControl(starts: false)
                    }
            }
        }
        
        errorAlert.addAction(okAction)
        
        present(errorAlert, animated: true, completion: nil)
    }
    
    @IBAction func exitButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
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
    
}

extension CollabDates2ViewController: CalendarCellProtocol {
    
    func datesSelected(startDate: Date?, deadlineDate: Date?) {
        
        SVProgressHUD.dismiss()
        
        selectedStartTime["startDate"] = startDate
        selectedDeadline["deadlineDate"] = deadlineDate
        
        guard let cell = datesTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? SegmentCell else { return }
        
            cell.selectedStart["startDate"] = startDate
            cell.selectedDeadline["deadlineDate"] = deadlineDate
            
            cell.setStartButtonText()
            cell.setDeadlineButtonText()
    }
    
    func configureTableViewHeight(shrink: Bool) {
        
        if shrink {
            
            calendarCellRowHeight = 320
        }
        
        else {
            
            calendarCellRowHeight = 370
        }
        
        datesTableView.beginUpdates()
        datesTableView.endUpdates()
    }
}

extension CollabDates2ViewController: TimeSelectorCellProtocol {
    
    func startTimeSelected(time: Date) {
        
        selectedStartTime["startTime"] = time
        
        guard let cell = datesTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? SegmentCell else { return }
        cell.selectedStart["startTime"] = time
        cell.setStartButtonText()
    }
    
    func deadlineTimeSelected(time: Date) {
        
        selectedDeadline["deadlineTime"] = time
        
        guard let cell = datesTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? SegmentCell else { return }
        cell.selectedDeadline["deadlineTime"] = time
        cell.setDeadlineButtonText()
    }
}

extension CollabDates2ViewController: SegmentCellProtocol {
    
    func selectedSegment(start: Bool) {
        
        guard let cell = datesTableView.cellForRow(at: IndexPath(item: 1, section: 0)) as? TimeSelectorCell else { return }
        
            if start {
                
                cell.selectedSegment = "starts"
            }
            
            else {
                
                cell.selectedSegment = "deadline"
            }
    }
}
