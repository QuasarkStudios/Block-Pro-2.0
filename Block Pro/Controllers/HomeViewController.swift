//
//  HomeViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/29/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var faceImage: UIImageView!
    
    @IBOutlet weak var selectionIndicator: UIView!
    
    @IBOutlet weak var homeTableView: UITableView!
    
    @IBOutlet weak var monthButton: UIButton!
    
    var viewInitiallyLoaded: Bool = false
    
    let formatter = DateFormatter()
    
    var weekSectionArray: [[Date]] = [[]]
    
    var tableViewAutoScrolled: Bool = false
    
    var visibleCell: IndexPath?
    
    var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        //self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        formatter.dateFormat = "MMMM"
        navigationItem.title = formatter.string(from: Date())
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 25)!]
        
        
        faceImage.layer.cornerRadius = 0.5 * faceImage.bounds.width
        faceImage.clipsToBounds = true
        
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        homeTableView.showsVerticalScrollIndicator = false
        homeTableView.separatorStyle = .none
        //homeTableView.rowHeight = 430
        
        homeTableView.register(UINib(nibName: "WeekHeaderCell", bundle: nil), forCellReuseIdentifier: "weekHeaderCell")
        homeTableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: "homeCell")
        
        view.bringSubviewToFront(monthButton)
        
        monthButton.configureMonthButton()
        
        determineWeeks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        formatter.dateFormat = "MMMM"
        navigationItem.title = formatter.string(from: Date())
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Poppins-SemiBold", size: 25)!]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if viewInitiallyLoaded == false {
            
            scrollToCurrentWeek()
            viewInitiallyLoaded = true
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
         
        return weekSectionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section != weekSectionArray.count - 1 {
            
            return 2
        }
        
        else {
            
            return 3
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 || indexPath.row == 2 {
            
            return 55
        }
            
        else {
            
            return 450
        }
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "weekHeaderCell", for: indexPath) as! WeekHeaderCell
            cell.selectionStyle = .none
            
            if weekSectionArray[indexPath.section].count == 1 {
                
                formatter.dateFormat = "M/d"
                cell.weekRangeLabel.text = formatter.string(from: weekSectionArray[indexPath.section][indexPath.row])
            }
            
            else {
                
                formatter.dateFormat = "M/d"
                cell.weekRangeLabel.text = formatter.string(from: weekSectionArray[indexPath.section].first!) + " - " + formatter.string(from: weekSectionArray[indexPath.section].last!)
                
                cell.leftButton.isHidden = true
                cell.rightButton.isHidden = true
//                cell.homeViewController = self
//                cell.indexPath = indexPath
            }
            
            return cell
        }
        
        else if indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell
            //cell.selectionStyle = .none
            
            cell.personalCollectionContent = weekSectionArray[indexPath.section]
            cell.homeViewController = self
            
            return cell
        }
        
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //Checks to see if the cell matching the current date is going to be displayed; done after the tableView is autoScrolled
        if tableViewAutoScrolled == true {
            
            scrollToCurrentDay(tableView, cell, indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("check1")
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if visibleCell ?? nil != nil {
            
            if let cell = homeTableView.cellForRow(at: visibleCell!) as? HomeTableViewCell {
                
                cell.shrinkPersonalCell()
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if decelerate == false {
            
            scrollToMostVisibleCell()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        scrollToMostVisibleCell()
    }

    
//    func testFunc (cell: UITableViewCell, indexPath: IndexPath) {
//
//        let homeCell = cell as! HomeTableViewCell
//
//        print(homeCell.personalCollectionContent)
//
//        homeCell.personalCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//
//        print("hello")
//    }
    
    private func determineWeeks () {
        
        formatter.dateFormat = "M/d"
        
        let calendar = Calendar.current
        let date = Date()
        
        let interval = calendar.dateInterval(of: .month, for: date)
        
        let days = calendar.dateComponents([.day], from: interval!.start, to: interval!.end).day!
        
        let startOfMonth = interval!.start
        
        var loopCount: Int = 0
        var weekCount: Int = 0
        
        while loopCount < days {
            
            let currentDate: Date = calendar.date(byAdding: .day, value: loopCount, to: startOfMonth)!
            
            weekSectionArray[weekCount].append(currentDate)//(formatter.string(from: currentDate))
            
            if (calendar.component(.weekday, from: currentDate) == 7) && (loopCount + 1 != days) {
                
                weekCount += 1
                weekSectionArray.append([])
            }
            
            loopCount += 1
        }
    }
    
    private func scrollToCurrentWeek () {
        
        homeTableView.isUserInteractionEnabled = false
        
        let currentDate: Date = Date()
        formatter.dateFormat = "MMMM d yyyy"
        
        var sectionToScrollTo: Int?
         
        var count: Int = 0
        
        for dates in weekSectionArray {
            
            for date in dates {

                if formatter.string(from: date) == formatter.string(from: currentDate) {

                    sectionToScrollTo = count

                    break
                }
            }
            
            if sectionToScrollTo != nil {
                
                break
            }
            
            count += 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            
            let indexPath: IndexPath = IndexPath(row: 0, section: sectionToScrollTo ?? 0)
            self.visibleCell = IndexPath(row: 1, section: indexPath.section)
            
            if indexPath.section == 0 {
                
                let cell = self.homeTableView.cellForRow(at: self.visibleCell!)
                
                self.scrollToCurrentDay(self.homeTableView, cell!, self.visibleCell!)
            }
            
            else {
                
                self.homeTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                
                self.tableViewAutoScrolled = true
            }
        }
    }
    
    private func scrollToCurrentDay (_ tableView: UITableView, _ cell: UITableViewCell, _ indexPath: IndexPath) {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
            let confirmedVisibleCell: Int?

            //If the user is not on the last section of the homeTableView
            if indexPath.section != self.weekSectionArray.count - 1 {

                confirmedVisibleCell = 1
            }

            else {

                confirmedVisibleCell = 2
            }
            
            if tableView.cellForRow(at: indexPath) == tableView.visibleCells[confirmedVisibleCell ?? 1] {
                
                let currentDate: Date = Date()
                self.formatter.dateFormat = "MMMM d yyyy"
                
                if let homeCell = cell as? HomeTableViewCell {
                    
                    var indexToScrollTo: Int = 0
                    var count: Int = 0
                    
                    for date in homeCell.personalCollectionContent {
                        
                        if self.formatter.string(from: date) == self.formatter.string(from: currentDate) {
                            
                            indexToScrollTo = count
                            break
                        }
                        
                        count += 1
                    }
                    
                    let indexPath: IndexPath = IndexPath(row: indexToScrollTo, section: 0)
                    homeCell.personalCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                    homeCell.visibleItem = indexPath
                    
                    homeCell.growPersonalCell(delay: 0.5)
                    
                    self.homeTableView.isUserInteractionEnabled = true
                    self.tableViewAutoScrolled = false
                }
            }
        }
    }
    
    private func scrollToMostVisibleCell () {
        
        let visibleRows: [IndexPath] = homeTableView.indexPathsForVisibleRows!
        let topHalfRect: CGRect = CGRect(x: 0, y: selectionIndicator.frame.maxY, width: view.frame.width, height: (view.center.y - selectionIndicator.frame.maxY))
        var topHalfCells: [IndexPath] = []
        
        var count = 0
        
        for cell in homeTableView.visibleCells {
            
            let cellFrame: CGRect = CGRect(x: cell.frame.minX, y: cell.frame.minY - homeTableView.contentOffset.y, width: cell.frame.width, height: cell.frame.height)
                
            if cellFrame.intersects(topHalfRect) {
                
                topHalfCells.append(visibleRows[count])
            }
            
            count += 1
        }
        
        let indexPath: IndexPath = IndexPath(row: 0, section: topHalfCells[0][0])
        homeTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        
        visibleCell = IndexPath(row: 1, section: indexPath.section)
        
        let cell = homeTableView.cellForRow(at: visibleCell!) as! HomeTableViewCell
        
        cell.assignVisibleCell {
            cell.growPersonalCell()
        }
    }
    
    func moveToTimeBlockView (selectedDate: Date) {
        
        self.selectedDate = selectedDate
        
                    print(selectedDate)
        
        performSegue(withIdentifier: "moveToTimeBlockView", sender: self)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let item = UIBarButtonItem()
        item.title = ""
        navigationItem.backBarButtonItem = item
        
        
        if segue.identifier == "moveToTimeBlockView" {
            
            
            
//            formatter.dateFormat = "EEEE, MMMM d"
//            navigationItem.title =  formatter.string(from: selectedDate ?? Date())
            
            let timeBlockVC = segue.destination as! TimeBlockViewController2
            timeBlockVC.currentDate = selectedDate! //?? Date()
        
            
            //timeBlockVC.currentDate = selectedDate ?? Date()
        }
        

    }
}


extension UIButton {
    
    func configureMonthButton () {

        backgroundColor = UIColor(hexString: "#CFDEF3")

        layer.shadowRadius = 2.5
        layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.35
        
        layer.cornerRadius = 0.5 * bounds.size.width
        layer.masksToBounds = false
        clipsToBounds = false
    }
    
}
