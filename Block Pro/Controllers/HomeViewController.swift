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
    
    @IBOutlet weak var selectionIndicator: SelectionIndicator!
    
    @IBOutlet weak var homeTableView: UITableView!
    
    @IBOutlet weak var monthButton: UIButton!
    
    let formatter = DateFormatter()
    
    var weekSectionArray: [[Date]] = [[]]
    
    var tableViewAutoScrolled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
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
    
    override func viewDidAppear(_ animated: Bool) {
        
        scrollToCurrentDate()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
         
        return weekSectionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            
            return 55
        }
        
        else {
    
            return 450
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "weekHeaderCell", for: indexPath) as! WeekHeaderCell
            //cell.selectionStyle = .none
            
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
        
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell
            cell.selectionStyle = .none
            
            cell.personalCollectionContent = weekSectionArray[indexPath.section]
            
            return cell
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
    
    private func scrollToCurrentDate () {
        
        homeTableView.allowsSelection = false
        
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
            self.homeTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            
            self.tableViewAutoScrolled = true
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if tableViewAutoScrolled == true {
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                
                if tableView.cellForRow(at: indexPath) == tableView.visibleCells[1] {
                    
                    let currentDate: Date = Date()
                    self.formatter.dateFormat = "MMMM d yyyy"
                    
                    let homeCell = cell as! HomeTableViewCell
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
                    
                    self.tableViewAutoScrolled = false
                }
            }
        }
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
    }
    
    private func determineWeeks () {
        
        formatter.dateFormat = "M/d"
        
        let calendar = Calendar.current
        let date = Date()
        
        let interval = calendar.dateInterval(of: .month, for: date)
        
        let days = calendar.dateComponents([.day], from: interval!.start, to: interval!.end).day!
        
        
        let startOfMonth = interval!.start
        
        //print(calendar.component(.weekday, from: startOfMonth))
        
        var loopCount: Int = 0
        var weekCount: Int = 0
        
        while loopCount < days {
            
            let currentDate: Date = calendar.date(byAdding: .day, value: loopCount, to: startOfMonth)!
            
            weekSectionArray[weekCount].append(currentDate)//(formatter.string(from: currentDate))
            
            if (calendar.component(.weekday, from: currentDate) == 7) && (loopCount + 1 != days) {
                
                weekCount += 1
                weekSectionArray.append([])
            }
            
            //print(weekSectionArray)

            
            loopCount += 1
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let item = UIBarButtonItem()
        item.title = ""
        navigationItem.backBarButtonItem = item
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
