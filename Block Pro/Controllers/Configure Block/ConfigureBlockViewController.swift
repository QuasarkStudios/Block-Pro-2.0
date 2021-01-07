//
//  ConfigureBlockViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 12/26/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class ConfigureBlockViewController: UIViewController {
    
    let navBarExtensionView = UIView()
    let segmentControl = CustomSegmentControl()
    
    let configureBlockTableView = UITableView()
    
    
    var navBarExtensionHeightAnchor: NSLayoutConstraint?
    var tableViewTopAnchor: NSLayoutConstraint?
    
    var selectedTableView = "details"
    
    var startsCalendarPresented: Bool = false
//    var startsCalendarExpanded: Bool = false
    
    var endsCalendarPresented: Bool = false
//    var endsCalendarExpanded: Bool = false
    
//    var calendarPresented: Bool = false
    var calendarExpanded: Bool = false
    
    var collab: Collab?
    var block = Block()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.configureNavBar()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(hexString: "222222") as Any, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.bold)]
        self.title = "Add a Block"
        
        self.navigationItem.largeTitleDisplayMode = .always
        
        self.isModalInPresentation = true

        configureTableView(configureBlockTableView) //Call first to allow for the navigation bar to work properly
        configureNavBarExtensionView()
        configureGestureRecognizors()


    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        print(self.view.gestureRecognizers)
        
//        tableViewTopAnchor?.constant = 75 + (navigationController?.navigationBar.frame.height ?? 0)
    }
    
    private func configureNavBarExtensionView () {
        
        self.view.addSubview(navBarExtensionView)
        navBarExtensionView.translatesAutoresizingMaskIntoConstraints = false
        
        [

            navBarExtensionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            navBarExtensionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            navBarExtensionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),

        ].forEach({ $0.isActive = true })

        navBarExtensionHeightAnchor = navBarExtensionView.heightAnchor.constraint(equalToConstant: 70)
        navBarExtensionHeightAnchor?.isActive = true
        
        tableViewTopAnchor = configureBlockTableView.topAnchor.constraint(equalTo: navBarExtensionView.bottomAnchor, constant: 0)
        tableViewTopAnchor?.isActive = true
        
        navBarExtensionView.addSubview(segmentControl)
    }
    
    private func configureTableView (_ tableView: UITableView) {
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        [
            
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)

        ].forEach({ $0.isActive = true })
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.delaysContentTouches = false
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
//        tableView.contentInset = UIEdgeInsets(top: 17.5, left: 0, bottom: 0, right: 0)
        
        tableView.register(NameConfigurationCell.self, forCellReuseIdentifier: "nameConfigurationCell")
        tableView.register(TimeConfigurationCell.self, forCellReuseIdentifier: "timeConfigurationCell")
    }
    
    private func configureGestureRecognizors () {
        
        let downSwipeGesture = UISwipeGestureRecognizer()
        downSwipeGesture.direction = .down
        downSwipeGesture.delegate = self
        downSwipeGesture.addTarget(self, action: #selector(swipDownGesture))
        self.view.addGestureRecognizer(downSwipeGesture)
        
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(dismissKeyboardTap)
    }
    
    @objc private func dismissKeyboard () {
        
        self.view.endEditing(true)
    }
    
    @objc private func swipDownGesture () {
        
        if configureBlockTableView.contentOffset.y <= 0 {
            
            //Expands the navBarExtensionView when the view is swipped down
            navBarExtensionHeightAnchor?.constant = 75
    
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
    
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension ConfigureBlockViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if selectedTableView == "details" {
            
            if indexPath.row == 1 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "nameConfigurationCell", for: indexPath) as! NameConfigurationCell
                cell.selectionStyle = .none
                
                cell.nameConfigurationDelegate = self
                
                return cell
            }
            
            else if indexPath.row == 3 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "timeConfigurationCell", for: indexPath) as! TimeConfigurationCell
                cell.selectionStyle = .none
                
                cell.collab = collab
                cell.starts = block.starts ?? Date().adjustTime(roundDown: true)
                
                cell.timeConfigurationDelegate = self
                
                cell.titleLabel.text = "Starts"
                
                return cell
            }
            
            else if indexPath.row == 5 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "timeConfigurationCell", for: indexPath) as! TimeConfigurationCell
                cell.selectionStyle = .none
                
                cell.collab = collab
                cell.ends = block.ends ?? Date().adjustTime(roundDown: false)
                
                cell.timeConfigurationDelegate = self
                
                cell.titleLabel.text = "Ends"
                
                return cell
            }
        }
            
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if selectedTableView == "details" {
            
            switch indexPath.row {
               
            case 0:
                
                return 15
            
            case 1:
                
                return 80
                
            case 3:
                
                //258 = height without calendar
//                1 233.33333333333331
//                2 280.0
                
                if startsCalendarPresented {
                    
                    if calendarExpanded {
                        
                        return 538
                    }
                    
                    else {
                        
                        return 491
                    }
                }
                
                else {
                    
                    return 135
                }
                
            case 5:
                
                if endsCalendarPresented {
                    
                    if calendarExpanded {
                        
                        return 538
                    }
                    
                    else {
                        
                        return 491
                    }
                }
                
                else {
                    
                    return 135
                }
                
            case 7, 9:
                
                return 70
                
            default:
                
                return 25
                
            }
        }
        
        else {
            
            return 0
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y >= 0 {
            
            //If the navBarExtensionView hasn't been completely shrunken yet
            if ((navBarExtensionHeightAnchor?.constant ?? 0) - scrollView.contentOffset.y) > 0 {
                
                navBarExtensionHeightAnchor?.constant -= scrollView.contentOffset.y
                scrollView.contentOffset.y = 0
            }
            
            else {
                
                navBarExtensionHeightAnchor?.constant = 0
            }
        }
        
        else {
            
            //If the navBarExtensionView hasn't been completely expanded
            if navBarExtensionHeightAnchor?.constant ?? 0 < 70 {

                navBarExtensionHeightAnchor?.constant = 70
                
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {

                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}

extension ConfigureBlockViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ConfigureBlockViewController: NameConfigurationProtocol {
    
    func nameEntered (_ text: String) {
        
        block.name = text
    }
}

extension ConfigureBlockViewController: TimeConfigurationProtocol {
    
    func presentCalendar (startsCalendar: Bool) {
        
        //If the starts calendar should be presented
        if startsCalendar {
            
            //If the ends calendar is currently presented; this will stagger the animations required to present the starts calendar
            if endsCalendarPresented {
                
                //Removing the calendar from ends cell
                if let cell = self.configureBlockTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? TimeConfigurationCell {
                    
                    cell.reconfigureCellWithoutCalendar()
                }
                
                //Animation of the tableView after a 0.25 delay to improve the animation of the ends calendar removal
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    
                    self.endsCalendarPresented = false
                    
                    self.configureBlockTableView.beginUpdates()
                    self.configureBlockTableView.endUpdates()
                }
                
                //Configuring the calendar in the starts cell after the ends calendar has been removed
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    
                    if let cell = self.configureBlockTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? TimeConfigurationCell {
                        
                        cell.reconfigureCellWithCalendar()
                    }
                }
                
                //Animation of the tableView 0.25 seconds after the starts calendar has begun to be configured to improve animations
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    
                    self.startsCalendarPresented = true
                    
                    self.configureBlockTableView.beginUpdates()
                    self.configureBlockTableView.endUpdates()
                    
                    self.configureBlockTableView.scrollToRow(at: IndexPath(row: 3, section: 0), at: .top, animated: true)
                }
            }
            
            //If the ends calendar isn't currently presented
            else {
                
                //Configuring the starts calendar in the starts cell
                if let cell = self.configureBlockTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? TimeConfigurationCell {
                    
                    cell.reconfigureCellWithCalendar()
                }
                
                //Animation of the tableView after a 0.25 seconds delay to improve animations
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    
                    self.startsCalendarPresented = true
                    
                    self.configureBlockTableView.beginUpdates()
                    self.configureBlockTableView.endUpdates()
                    
                    self.configureBlockTableView.scrollToRow(at: IndexPath(row: 3, section: 0), at: .top, animated: true)
                }
            }
        }
        
        //Comments required for this block exist in the previous block
        else {
            
            if startsCalendarPresented {
                
                if let cell = self.configureBlockTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? TimeConfigurationCell {
                    
                    cell.reconfigureCellWithoutCalendar()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    
                    self.startsCalendarPresented = false
                    
                    self.configureBlockTableView.beginUpdates()
                    self.configureBlockTableView.endUpdates()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    
                    if let cell = self.configureBlockTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? TimeConfigurationCell {
                        
                        cell.reconfigureCellWithCalendar()
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    
                    self.endsCalendarPresented = true
                    
                    self.configureBlockTableView.beginUpdates()
                    self.configureBlockTableView.endUpdates()
                    
                    self.configureBlockTableView.scrollToRow(at: IndexPath(row: 5, section: 0), at: .top, animated: true)
                }
            }
            
            else {
                
                if let cell = self.configureBlockTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? TimeConfigurationCell {
                    
                    cell.reconfigureCellWithCalendar()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    
                    self.endsCalendarPresented = true
                    
                    self.configureBlockTableView.beginUpdates()
                    self.configureBlockTableView.endUpdates()
                    
                    self.configureBlockTableView.scrollToRow(at: IndexPath(row: 5, section: 0), at: .top, animated: true)
                }
            }
        }
    }
    
    func dismissCalendar (startsCalendar: Bool) {
        
        if startsCalendar {
            
            startsCalendarPresented = false
        }
        
        else {
            
            endsCalendarPresented = false
        }
        
        configureBlockTableView.beginUpdates()
        configureBlockTableView.endUpdates()
        
        //Expands the navBarExtensionView when the view is swipped down
        navBarExtensionHeightAnchor?.constant = 75

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {

            self.view.layoutIfNeeded()
        }
    }
    
    func expandCalendarCellHeight (expand: Bool) {
        
        calendarExpanded = expand
        
        configureBlockTableView.beginUpdates()
        configureBlockTableView.endUpdates()
    }
    
    func timeEntered (startTime: Date?, endTime: Date?) {
        
        let formatter = DateFormatter()
        
        if let time = startTime {
            
            block.starts = time //Setting the selected start time
            
            //Ensures that the blocks dates match and that the start time is before the end time
            if let cell = configureBlockTableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? TimeConfigurationCell {
                
                formatter.dateFormat = "yyyy MM dd "
                let newDate = formatter.string(from: time)
                
                formatter.dateFormat = "h:mm a"
                let endTime = formatter.string(from: cell.ends ?? Date())

                formatter.dateFormat = "yyyy MM dd h:mm a"
                
                //If the end time is before the start time, likely because of the time and not the date
                if let adjustedEndTime = formatter.date(from: newDate + endTime), adjustedEndTime <= time {
                    
                    //Incrementing the end time by 5 minutes
                    block.ends = Calendar.current.date(byAdding: .minute, value: 5, to: time)
                    cell.ends = Calendar.current.date(byAdding: .minute, value: 5, to: time)
                }
                
                else {
                    
                    block.ends = formatter.date(from: newDate + endTime)
                    cell.ends = formatter.date(from: newDate + endTime)
                }
            }
        }
        
        else if let time = endTime {
            
            block.ends = time //Setting the selected end time
            
            //Ensures that the blocks dates match and that the start time is before the end time
            if let cell = configureBlockTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? TimeConfigurationCell {
                
                formatter.dateFormat = "yyyy MM dd "
                let newDate = formatter.string(from: time)
                
                formatter.dateFormat = "h:mm a"
                let startTime = formatter.string(from: cell.starts ?? Date())

                formatter.dateFormat = "yyyy MM dd h:mm a"
                
                //If the end time is before the start time, likely because of the time and not the date
                if let adjustedStartTime = formatter.date(from: newDate + startTime), adjustedStartTime >= time {
                    
                    //Decrementing the start time by 5 minutes
                    block.starts = Calendar.current.date(byAdding: .minute, value: -5, to: time)
                    cell.starts = Calendar.current.date(byAdding: .minute, value: -5, to: time)
                }
                
                else {
                    
                    block.starts = formatter.date(from: newDate + startTime)
                    cell.starts = formatter.date(from: newDate + startTime)
                }
            }
        }
    }
}
